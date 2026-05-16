{ inputs, ... }:
{
  flake.modules.nixos.host_legion = {
    imports = [
      inputs.disko.nixosModules.disko
      ./disks.mod.nix
    ];

    fileSystems."/var/log".neededForBoot = true;
  };
}
