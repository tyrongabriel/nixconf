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
      cfg = config.myHome.desktop.terminal.alacritty;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.terminal.alacritty = with lib; {
        enable = mkEnableOption "Enable rio";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        # https://home-manager-options.extranix.com/?query=rio&release=release-25.11
        programs.alacritty = {
          enable = true;
          package = pkgs.alacritty;
          settings = {
            env.TERM = "xterm-256color";
            #window.opacity = lib.mkForce 0.9;
          };
        };

        home.packages = with pkgs; [
          ffmpegthumbnailer # For video previews
          unzip # For archive previews
          jq # For JSON previews
          poppler # For PDF previews
          fd # Better file searching
          ripgrep # Better content searching
          fzf # Fuzzy finding
          imagemagick # For image manipulation/previews
          ueberzugpp
        ];
      };
    };
}
