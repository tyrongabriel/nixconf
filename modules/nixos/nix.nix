{ inputs, ... }:

{
  flake.modules.nixos.core =
    { ... }:
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

      # 1. Make 'nix-shell -p' and 'nix shell' use the same nixpkgs as your flake
      nix.registry.nixpkgs.flake = inputs.nixpkgs;

      # 2. Map the old NIX_PATH to the flake's nixpkgs
      # This fixes 'nix-shell -p' and 'nixos-rebuild'
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
}
