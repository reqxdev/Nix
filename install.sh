#!/usr/bin/env bash

set -Eeuo pipefail

readonly network_test_host="mynixos.com"

usage() {
  echo "Usage: $0 [/dev/disk/by-id/<nvme-drive>]" >&2
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

target_disk="${1:-}"

if [[ -z "$target_disk" ]]; then
  echo
  echo "Available NVMe drives:"
  lsblk -d -e 7 -o NAME,PATH,SIZE,MODEL,SERIAL,TRAN,TYPE
  echo
  read -r -p "NVMe drive to erase (prefer /dev/disk/by-id/...): " target_disk
fi

if [[ ! -b "$target_disk" ]]; then
  echo "Not a block device: $target_disk" >&2
  exit 1
fi

if [[ "$(lsblk -dnro TYPE "$target_disk")" != "disk" ]]; then
  echo "Select an entire drive, not a partition: $target_disk" >&2
  exit 1
fi

if [[ "$(lsblk -dnro TRAN "$target_disk")" != "nvme" ]]; then
  echo "The selected drive is not an NVMe drive: $target_disk" >&2
  exit 1
fi

mounted="$(lsblk -nrpo MOUNTPOINT "$target_disk" | sed '/^$/d')"
if [[ -n "$mounted" ]]; then
  echo "The selected drive or one of its partitions is mounted:" >&2
  echo "$mounted" >&2
  echo "Unmount it before re-running this installer." >&2
  exit 1
fi

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

flake_ref="${MYNIX_FLAKE:-github:reqxdev/Nix#MyNix}"
flake_source="${flake_ref%%#*}"
config_source="${MYNIX_SOURCE:-$flake_source}"
mount_point="/mnt"
swap_device="/dev/disk/by-label/swap"

if [[ ! -d "$config_source" ]]; then
  echo "Cannot locate the flake source to copy into /etc/nixos: $config_source" >&2
  echo "Run the installer through 'nix run', as documented in README.md." >&2
  exit 1
fi

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
echo "Swap is active. Building and installing MyNixOS..."
nixos-install \
  --flake "$flake_ref" \
  --root "$mount_point" \
  --no-channel-copy \
  --no-root-password \
  --max-jobs 1 \
  --cores 1

echo
echo "Copying the editable configuration to $mount_point/etc/nixos..."
install -d -m 0755 "$mount_point/etc/nixos"
cp -a "$config_source/." "$mount_point/etc/nixos/"
chmod -R u+rwX "$mount_point/etc/nixos"

echo
echo "Set the root password for the installed system."
nixos-enter --root "$mount_point" --command "passwd root"

echo
echo "Set the password for user rex."
nixos-enter --root "$mount_point" --command "passwd rex"

echo
echo "Installation complete. Reboot when ready."
