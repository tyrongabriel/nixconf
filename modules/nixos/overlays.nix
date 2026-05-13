{ ... }:
{
  flake.modules.nixos.core =
    {
      inputs,
      pkgs,
      ...
    }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          stable = import inputs.nixpkgs-stable {
            system = pkgs.stdenv.hostPlatform.system;
            config.allowUnfree = true;
          };
        })

        (final: prev: {
          unstable-small = import inputs.nixpkgs-unstable-small {
            system = pkgs.stdenv.hostPlatform.system;
            config.allowUnfree = true;
          };
        })
      ];
    };
}
