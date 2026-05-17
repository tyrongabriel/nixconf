{ ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.cli.nushell;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.cli.nushell = with lib; {
        enable = mkEnableOption "Enable nushell";
      };
      config = mkIf cfg.enable {
        programs.nushell = {
          enable = true;

          #configFile = ./config.nu;
        };
      };
    };
}
