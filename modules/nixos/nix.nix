{ inputs, ... }:

{
  flake.nixosModules.nix =
    { lib, ... }:
    {
      nix.settings = {
        trusted-users = [ "@wheel" ];
        max-jobs = lib.mkDefault 4;
      };
    };
}
