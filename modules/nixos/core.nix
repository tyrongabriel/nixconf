{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  flake.modules.nixos.core =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
      ];

      config = {
        environment.systemPackages = with pkgs; [
          vim
          git
          htop
          curl
          wget
        ];
        time.timeZone = lib.mkDefault "Europe/London";

      };
    };
}
