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
      cfg = config.myHome.desktop.apps.misc;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.apps.misc = with lib; {
        enable = mkEnableOption "Enable misc";
      };
      config = mkIf cfg.enable {
        # Miscalleneous apps
        home.packages = with pkgs; [

        ];
      };
    };
}
