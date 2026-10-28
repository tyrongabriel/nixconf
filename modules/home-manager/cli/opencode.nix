{ ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.cli.opencode;
    in
    with lib;
    {
      options.myHome.cli.opencode = with lib; {
        enable = mkEnableOption "Enable the OpenCode CLI";
      };
      config = mkIf cfg.enable {
        home.packages = [ pkgs.opencode ];
      };
    };
}
