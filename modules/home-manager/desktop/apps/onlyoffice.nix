{ ... }:
{
  flake.modules.homeManager.apps =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.apps.onlyoffice;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.apps.onlyoffice = with lib; {
        enable = mkEnableOption "Enable onlyoffice";
      };
      config = mkIf cfg.enable {
        programs.onlyoffice = {
          enable = true;
        };
      };
    };
}
