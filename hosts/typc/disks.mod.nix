{
  disko.devices.disk.main = {
    type = "disk";
    # OS drive — Samsung 970 EVO Plus 500GB NVMe
    device = "/dev/disk/by-id/nvme-eui.0025385891b424b4";
    content.type = "gpt";
    content.partitions.boot = {
      name = "boot";
      size = "1M";
      type = "EF02";
    };

    # Boot Partition
    content.partitions.ESP = {
      label = "boot";
      name = "ESP";
      size = "2G";
      type = "EF00";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
        mountOptions = [
          "defaults"
          "umask=0077"
        ];
      };
    };

    # Root partition (In the future, impermanent!)
    content.partitions.root = {
      size = "100%";
      content = {
        type = "btrfs";
        extraArgs = [
          "-L"
          "nixos"
          "-f"
        ]; # Label it nixos
        subvolumes = {
          "@" = {
            mountpoint = "/";
            mountOptions = [
              "subvol=@" # This is the "root" part.
              "compress=zstd"
              "noatime"
            ];
          };
          "@home" = {
            mountpoint = "/home";
            mountOptions = [
              "subvol=@home"
              "compress=zstd"
              "noatime"
            ];
          };
          "@nix" = {
            mountpoint = "/nix";
            mountOptions = [
              "subvol=@nix"
              "compress=zstd"
              "noatime"
            ];
          };
          "@log" = {
            mountpoint = "/var/log";
            mountOptions = [
              "subvol=@log"
              "compress=zstd"
              "noatime"
            ];
          };
          "@swap" = {
            mountpoint = "/.swapvol";
            swap.swapfile.size = "32G";
          };
        };
      };
    };
  };

  # Bulk storage — WD Blue 1TB HDD
  disko.devices.disk.data = {
    type = "disk";
    device = "/dev/disk/by-id/wwn-0x50014ee2b800b5b5";
    content.type = "gpt";
    content.partitions.data = {
      size = "100%";
      content = {
        type = "btrfs";
        extraArgs = [
          "-L"
          "data"
          "-f"
        ];
        subvolumes = {
          "@data" = {
            mountpoint = "/data";
            mountOptions = [
              "subvol=@data"
              "compress=zstd"
              "noatime"
            ];
          };
        };
      };
    };
  };
}
