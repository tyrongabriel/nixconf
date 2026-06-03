{ inputs, ... }:

{
  flake.modules.nixos.core =
    { lib, ... }:
    with lib;
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
      nixpkgs.config.allowUnfree = mkDefault true;

      # 1. Make 'nix-shell -p' and 'nix shell' use the same nixpkgs as your flake
      nix.registry.nixpkgs.flake = inputs.nixpkgs;

      # 2. Map the old NIX_PATH to the flake's nixpkgs
      # This fixes 'nix-shell -p' and 'nixos-rebuild'
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      # !TODO: when flakes/deps get updated, remove
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
}
