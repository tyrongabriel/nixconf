{ ... }:
{
  flake.modules.homeManager.apps =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.apps.yubico;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.apps.yubico = with lib; {
        enable = mkEnableOption "Enable yubico";
      };
      config = mkIf cfg.enable {
        home.packages = with pkgs; [
        ];
      };
    };
}
