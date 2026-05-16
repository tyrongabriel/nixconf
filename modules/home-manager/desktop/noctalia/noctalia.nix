{ self, inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.noctalia;
      desktopCfg = config.myHome.desktop;
    in
    with lib;
    {
      imports = [
        inputs.noctalia.homeModules.default
      ];
      options.myHome.desktop.noctalia = with lib; {
        enable = mkEnableOption "Enable noctalia shell for wayland";
      };
      config = mkIf cfg.enable {
        home.packages = with pkgs; [
          noctalia-qs
          brightnessctl
          imagemagick

          # screen toolkit deps https://noctalia.dev/plugins/screen-toolkit
          grim
          slurp
          wl-clipboard
          tesseract
          imagemagick
          zbar
          curl
          ffmpeg
          jq
          wl-screenrec
          python3
          hyprpicker
          translate-shell
          gifski
          zenity
        ];

        home.file = {
          ".face".source = ../assets/catppuccin-pfp.png;
        };

        programs.noctalia-shell.enable = true;
        programs.noctalia-shell.settings = {
          general = {
            avatarImage = mkForce "/home/${config.home.username}/.face";
          };
        };

      };
    };
}
