{ inputs, ... }:

{
  flake.modules.nixos.core =
    { lib, ... }:
    {
      nix.settings = {
        trusted-users = [ "@wheel" ];
        #max-jobs = lib.mkDefault 4;
      };
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };

      nix.gc = {
        automatic = true;
        dates = "weekly";
      };
    };
}
