{ inputs, ... }:
{
  flake.modules.nixos.host_yoga = {
    imports = [
      inputs.disko.nixosModules.disko
      ./disks.mod.nix
    ];

    services.btrfs.autoScrub = {
      enable = true;
      limit = "100M";
      interval = "monthly"; # Uses systemd.timer calendar syntax (e.g., "weekly")
      fileSystems = [ "/" ]; # Add other distinct Btrfs pool mount points if you have them
    };

    fileSystems."/var/log".neededForBoot = true;
  };
}
