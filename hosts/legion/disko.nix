{ inputs, ... }:
{
  flake.modules.nixos.host_legion = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
    disko.devices = {
      disk = {
        sda = {
          type = "disk";
          # The storage device
          device = "/dev/disk/by-id/nvme-WD_PC_SN740_SDDPMQD-1T00-1101_2335QP404844";
          content = {
            type = "gpt";
            partitions = {
              # Boot Partition
              ESP = {
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
              root = {
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
                      swap.swapfile.size = "8G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

    fileSystems."/var/log".neededForBoot = true;
  };
}
