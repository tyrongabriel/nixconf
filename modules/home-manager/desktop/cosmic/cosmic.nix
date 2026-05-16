{ self, inputs, ... }:
{
  flake.modules.homeManager.cosmic =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.cosmic;
    in
    with lib;
    {
      imports = [ inputs.cosmic-manager.homeManagerModules.cosmic-manager ];
      options.myHome.desktop.cosmic = with lib; {
        enable = mkEnableOption "Enable cosmic";
      };
      config = mkIf cfg.enable {
        # Options: https://heitoraugustoln.github.io/cosmic-manager/options/index.html
      };
    };
}
