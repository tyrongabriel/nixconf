{ ... }:
{
  flake.modules.homeManager.terminal =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.terminal.ghostty;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.terminal.ghostty = with lib; {
        enable = mkEnableOption "Enable ghostty";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        programs.ghostty = {
          enable = true;
          package = pkgs.ghostty;
          enableZshIntegration = true;
        };
      };
    };
}
