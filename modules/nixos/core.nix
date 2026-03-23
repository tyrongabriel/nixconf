{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  flake.nixosModules.core =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        vim
        git
        htop
        curl
        wget
      ];
      time.timeZone = lib.mkDefault "Europe/London";

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
