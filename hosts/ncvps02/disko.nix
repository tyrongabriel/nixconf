{ inputs, ... }:
{
  flake.modules.nixos.host_ncvps02 = {
    imports = [
      inputs.disko.nixosModules.disko
      ./disko.mod.nix
    ];

    fileSystems."/var/log".neededForBoot = true;
  };
}
