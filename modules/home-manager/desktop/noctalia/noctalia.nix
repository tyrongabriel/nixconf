{ inputs, ... }:
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
      noctaliaConf = fromTOML (builtins.readFile ./noctalia.toml);
    in
    with lib;
    {
      imports = [
        inputs.noctalia.homeModules.default
      ];
      options.myHome.desktop.noctalia = with lib; {
        enable = mkEnableOption "Enable noctalia shell for wayland";
        location.name = mkOption {
          type = types.str;
          default = "Vienna";
          description = "Set the location name for weather and time display in the bar (e.g. 'Vienna', 'New York')";
        };
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
          "Pictures/Wallpapers/default.png".source = config.stylix.image;
        };

        # Manages idle behavior, to lock when idle
        # services.swayidle = {
        #   enable = true;
        #   systemdTarget = "graphical-session.target"; # Tells systemd to start this when Niri starts
        #   events = [
        #     {
        #       event = "before-sleep";
        #       # Instructs Noctalia to lock the screen right before suspend
        #       command = "qs -c noctalia-shell ipc call lockScreen lock";
        #     }
        #   ];
        # };

        programs.noctalia.enable = true;
        programs.noctalia.settings = lib.mkMerge [
          (lib.mapAttrsRecursive (_path: value: lib.mkOverride 2000 value) noctaliaConf)
          {
            shell = {
              avatar_path = lib.mkForce "~/.face";
            };
            bar.monitors = lib.mkForce (lib.map (m: m.id) (lib.filter (m: m.bar == true) desktopCfg.monitors));
            location.address = mkForce "${cfg.location.name}";
            weather.address = mkForce "${cfg.location.name}";
            wallpaper.directory = mkForce "~/Pictures/Wallpapers";
            wallpaper.default = mkForce "~/Pictures/Wallpapers/default.png";
          }
        ];

      };
    };
}
