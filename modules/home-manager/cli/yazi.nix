{ ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.cli.yazi;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.cli.yazi = with lib; {
        enable = mkEnableOption "Enable yazi";
      };
      config = mkIf cfg.enable {
        programs.yazi = {
          enable = true;
        };
      };
    };
}
