{ ... }:
{
  flake.modules.homeManager.gaming =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.gaming;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.gaming = with lib; {
        enable = mkEnableOption "Enable gaming configs";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        myHome.desktop.gaming = {
          minecraft.enable = true;
        };
      };
    };
}
