{ self, ... }:
{
  flake.modules.homeManager.zellij =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.zellij;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.zellij = with lib; {
        enable = mkEnableOption "Enable zellij";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        programs.zellij = {
          enable = true;
          # extraConfig = ''
          #   theme catppuccin-macchiato
          # '';

        };
      };
    };
}
