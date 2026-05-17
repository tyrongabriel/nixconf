{ ... }:
{
  flake.modules.homeManager.core =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.core.stylix;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.core.stylix = with lib; {
        enable = mkEnableOption "Enable stylix";
      };
      config = mkIf cfg.enable {
        stylix = {
          opacity = {
            popups = 0.7;
            # terminal = 0.5;
            # applications = 0.9;
          };
        };
      };
    };
}
