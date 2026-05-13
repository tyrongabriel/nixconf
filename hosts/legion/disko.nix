{ inputs, ... }:
{
  flake.modules.nixos.host_legion = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
    disko.devices.disk.main = {
      type = "disk";
      # The storage device
      device = "/dev/disk/by-id/nvme-eui.1845184226420001001b444a446ee5a2";
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
              swap.swapfile.size = "8G";
            };
          };
        };
      };
    };

    fileSystems."/var/log".neededForBoot = true;
  };
}
