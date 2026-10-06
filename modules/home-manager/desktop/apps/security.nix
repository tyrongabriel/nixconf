{ ... }:
{
  flake.modules.homeManager.apps =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.myHome.desktop.apps.security;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.apps.security = with lib; {
        enable = mkEnableOption "Enable security apps";
      };
      config = mkIf cfg.enable {
        home.packages = with pkgs; [
          stable.binaryninja-free # to not have to recomplile it all the time
        ];
      };
    };
}
