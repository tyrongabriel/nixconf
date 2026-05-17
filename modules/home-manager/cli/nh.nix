{ ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.cli.nh;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.cli.nh = with lib; {
        enable = mkEnableOption "Enable nh";
      };
      config = mkIf cfg.enable {
        programs.nh = {
          enable = true;

          clean = {
            dates = "weekly";
            enable = true;
            extraArgs = "--keep-since 4d --keep 3";
          };
        };
      };
    };
}
