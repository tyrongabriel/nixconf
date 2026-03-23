{ inputs, ... }:
{
  flake.modules.nixos.core =
    { inputs, ... }:
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
    };
}
