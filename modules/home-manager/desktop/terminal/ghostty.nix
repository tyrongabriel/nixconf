{ self, ... }:
{
  flake.modules.homeManager.terminal =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.ghostty;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.ghostty = with lib; {
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
