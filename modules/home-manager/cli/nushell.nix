{ self, ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      pkgs,
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
