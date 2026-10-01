{
  disko.enableConfig = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Corsair_MP700_PRO_A7GDB34000MNOX";

    content = {
      type = "gpt";

      partitions = {
        ESP = {
          type = "EF00";
          size = "1G";

          content = {
            type = "filesystem";
            format = "vfat";
            extraArgs = [ "-n" "boot" ];
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        swap = {
          size = "4G";

          content = {
            type = "swap";
            extraArgs = [ "--label" "swap" ];
          };
        };

        root = {
          size = "100%";

          content = {
            type = "filesystem";
            format = "ext4";
            extraArgs = [ "-L" "nixos" ];
            mountpoint = "/";
          };
        };
      };
    };
  };
}
