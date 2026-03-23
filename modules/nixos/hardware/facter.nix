{ inputs, ... }:
{
  flake.modules.nixos.core =
    { inputs, ... }:
    {
      imports = [
        inputs.nixos-facter-modules.nixosModules.facter
      ];
    };
}
