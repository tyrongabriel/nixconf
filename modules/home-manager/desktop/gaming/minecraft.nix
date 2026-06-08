{ ... }:
{
  flake.modules.homeManager.gaming =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.gaming.minecraft;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.gaming.minecraft = with lib; {
        enable = mkEnableOption "Enable minecraft";
      };
      config = mkIf cfg.enable {
        programs.java.enable = mkForce true;
        home.packages = with pkgs; [
          prismlauncher
        ];
      };
    };
}
