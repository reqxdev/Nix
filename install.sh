#!/usr/bin/env bash

set -Eeuo pipefail

readonly network_test_host="cache.nixos.org"

usage() {
  echo "Usage: $0 [/dev/disk/by-id/<drive>]" >&2
}

if (($# > 1)); then
  usage
  exit 2
fi

if ((EUID != 0)); then
  script_path="$(readlink -f "$0")"
  echo "Switching to a root login environment with sudo -i..."
  exec sudo -i -- "$script_path" "$@"
fi

echo "Checking network access with $network_test_host..."
if ! ping -c 1 -W 5 "$network_test_host" >/dev/null 2>&1; then
  echo >&2
  echo "No network connection was detected." >&2
  echo "Run 'nmtui' to configure a network, then re-run this installer." >&2
  exit 1
fi
echo "Network connection detected."

if [[ ! -d /sys/firmware/efi/efivars ]]; then
  echo "The NixOS Minimal ISO must be booted in UEFI mode." >&2
  exit 1
fi

check_disk() {
  local disk="$1" label="$2" mounted
  if [[ ! -b "$disk" ]]; then
    echo "$label: not a block device: $disk" >&2
    exit 1
  fi
  if [[ "$(lsblk -dnro TYPE "$disk")" != "disk" ]]; then
    echo "$label: select an entire drive, not a partition: $disk" >&2
    exit 1
  fi
  mounted="$(lsblk -nrpo MOUNTPOINT "$disk" | sed '/^$/d')"
  if [[ -n "$mounted" ]]; then
    echo "$label: the drive or one of its partitions is mounted:" >&2
    echo "$mounted" >&2
    echo "Unmount it before re-running this installer." >&2
    exit 1
  fi
}

extra_disks=()
extra_names=()
extra_partitions=()

disk_field() {
  lsblk -dno "$2" "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

drive_kind() {
  if [[ "$(disk_field "$1" TRAN)" == "nvme" ]]; then
    echo "NVMe"
  elif [[ "$(disk_field "$1" ROTA)" == "1" ]]; then
    echo "HDD"
  else
    echo "SSD"
  fi
}

contains() {
  local needle="$1" item
  shift
  for item in "$@"; do
    [[ "$item" != "$needle" ]] || return 0
  done
  return 1
}

list_extra_disks() {
  local disk disks
  disks="$(lsblk -dnrpo PATH,TYPE,RM,RO | sed -n 's/^\([^ ]*\) disk 0 0$/\1/p')"
  for disk in $disks; do
    [[ "$disk" != "$1" && "$disk" != /dev/zram* ]] || continue
    ! contains "$disk" "${extra_disks[@]}" || continue
    [[ -z "$(lsblk -nrpo MOUNTPOINT "$disk" | sed '/^$/d')" ]] || continue
    echo "$disk"
  done
}

choose_extra_drives() {
  local system_disk answer choice index disk name default
  local -a disks
  system_disk="$(readlink -f "$1")"

  echo
  read -r -p "Do you have any additional drives (HDD, SSD or NVMe) to format and mount? [y/N] " answer
  while [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]; do
    mapfile -t disks < <(list_extra_disks "$system_disk")
    if ((${#disks[@]} == 0)); then
      echo "No additional unmounted drives are available."
      return
    fi

    echo
    echo "Additional drives (removable and in-use drives are hidden):"
    for index in "${!disks[@]}"; do
      disk="${disks[index]}"
      echo "  $((index + 1))) $disk  $(disk_field "$disk" SIZE)  $(drive_kind "$disk")  $(disk_field "$disk" MODEL)  $(disk_field "$disk" SERIAL)"
    done
    read -r -p "Choose a number, or press Enter to finish: " choice
    [[ -n "$choice" ]] || return 0
    if [[ ! "$choice" =~ ^[1-9][0-9]{0,2}$ ]] || ((choice > ${#disks[@]})); then
      echo "Not a valid choice: $choice"
      continue
    fi
    disk="${disks[choice - 1]}"

    default="drive$((${#extra_disks[@]} + 1))"
    while true; do
      read -r -p "Name for this drive, mounted at /mnt/<name> [$default]: " name
      name="${name:-$default}"
      if [[ ! "$name" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]]; then
        echo "Use only letters, numbers, '-' and '_'."
      elif contains "$name" "${extra_names[@]}"; then
        echo "/mnt/$name is already used."
      else
        break
      fi
    done

    echo
    lsblk -o NAME,PATH,SIZE,FSTYPE,LABEL,MODEL,SERIAL "$disk"
    echo "This drive will be erased and formatted as ext4. All data on it will be lost."
    read -r -p "Type 'ERASE' to confirm, or press Enter to skip it: " choice
    if [[ "$choice" == "ERASE" ]]; then
      extra_disks+=("$disk")
      extra_names+=("$name")
    else
      echo "Skipped $disk."
    fi

    echo
    read -r -p "Add another drive? [y/N] " answer
  done
}

format_extra_drives() {
  local disk partition
  for disk in "${extra_disks[@]}"; do
    check_disk "$disk" "Additional drive"
    echo
    echo "Erasing and formatting $disk..."
    while read -r partition; do
      wipefs --all --force --quiet "$partition"
    done < <(lsblk -nrpo PATH,TYPE "$disk" | sed -n 's/^\([^ ]*\) part$/\1/p')
    wipefs --all --force --quiet "$disk"
    printf 'type=linux\n' | sfdisk --quiet --label gpt --wipe always --wipe-partitions always "$disk"
    udevadm settle
    partition="$(lsblk -nrpo PATH,TYPE "$disk" | sed -n 's/^\([^ ]*\) part$/\1/p')"
    if [[ ! -b "$partition" ]]; then
      echo "Could not find the new partition on $disk." >&2
      exit 1
    fi
    mkfs.ext4 -q -F -m 0 -E "root_owner=${INSTALL_UID:-1000}:${INSTALL_GID:-100}" "$partition"
    extra_partitions+=("$partition")
  done
  udevadm settle
}

write_extra_drives() {
  local file="$1" index uuid
  ((${#extra_partitions[@]} > 0)) || return 0
  {
    echo "{"
    for index in "${!extra_partitions[@]}"; do
      uuid="$(blkid -c /dev/null -s UUID -o value "${extra_partitions[index]}")"
      echo "  fileSystems.\"/mnt/${extra_names[index]}\" = {"
      echo "    device = \"/dev/disk/by-uuid/$uuid\";"
      echo "    fsType = \"ext4\";"
      echo "    options = [ \"noatime\" \"nofail\" ];"
      echo "  };"
    done
    echo "}"
  } >"$file"
}

target_disk="${1:-}"

echo
echo "Available drives:"
lsblk -d -e 7 -o NAME,PATH,SIZE,MODEL,SERIAL,TRAN,TYPE
echo
echo "Tip: ls -l /dev/disk/by-id/ shows stable names for each drive."

if [[ -z "$target_disk" ]]; then
  echo
  read -r -p "Drive to erase (prefer /dev/disk/by-id/...): " target_disk
fi
check_disk "$target_disk" "Drive"

echo
echo "Disko will completely erase this drive and create:"
echo "  - 1 GiB EFI System Partition mounted at /boot"
echo "  - 4 GiB swap partition"
echo "  - ext4 root partition using the remaining space"
echo
lsblk -o NAME,PATH,SIZE,MODEL,SERIAL,TRAN,TYPE,MOUNTPOINTS "$target_disk"
echo
read -r -p "Type 'ERASE' to erase the selected drive: " confirmation

if [[ "$confirmation" != "ERASE" ]]; then
  echo "Installation cancelled."
  exit 1
fi

choose_extra_drives "$target_disk"

username="${INSTALL_USER:-USERNAME}"
flake_ref="${INSTALL_FLAKE:-github:reqxdev/Nix#Nix}"
flake_source="${flake_ref%%#*}"
config_source="${INSTALL_SOURCE:-$flake_source}"
mount_point="/mnt"
config_target="$mount_point/etc/nixos"
swap_device="/dev/disk/by-label/swap"

if [[ ! -d "$config_source" ]]; then
  echo "Cannot locate the flake source to copy into /etc/nixos: $config_source" >&2
  echo "Run the installer through 'nix run', as documented in README.md." >&2
  exit 1
fi

format_extra_drives

echo
echo "Wiping, partitioning, formatting, and mounting with Disko..."
disko \
  --mode destroy,format,mount \
  --flake "$flake_source#install" \
  --argstr device "$target_disk" \
  --root-mountpoint "$mount_point" \
  --yes-wipe-all-disks

if ! swapon --show=NAME --noheadings --raw | grep -Fxq "$(readlink -f "$swap_device")"; then
  swapon "$swap_device"
fi

echo
echo "Copying the editable configuration to $config_target (/etc/nixos after reboot)..."
install -d -m 0755 "$config_target"
cp -a --no-preserve=ownership "$config_source/." "$config_target/"
chmod -R u+rwX "$config_target"

echo
echo "Generating hardware configuration for this machine..."
rm -f "$config_target/hardware-configuration.nix"
nixos-generate-config --root "$mount_point" --no-filesystems
if [[ ! -s "$config_target/hardware-configuration.nix" ]]; then
  echo "Hardware configuration was not generated." >&2
  exit 1
fi
write_extra_drives "$config_target/extra-drives.nix"

echo
echo "Swap is active. Building and installing Nix..."
nixos-install \
  --flake "path:$config_target#${flake_ref#*#}" \
  --root "$mount_point" \
  --no-channel-copy \
  --no-root-password \
  --max-jobs 1 \
  --cores 1

echo
echo "Set the root password for the installed system."
nixos-enter --root "$mount_point" --command "passwd root"

echo
echo "Set the password for user $username (used for sudo)."
nixos-enter --root "$mount_point" --command "passwd $username"

echo
echo "Installation complete. Reboot when ready."
echo "After reboot, run 'sudo tailscale up' to join your tailnet."
echo "After reboot, edit your Nix configuration in /etc/nixos, including home/ and home/hyprland/."
echo "Apply changes with: sudo nixos-rebuild switch --flake /etc/nixos#${flake_ref#*#}"
