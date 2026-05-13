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
          # # The shell itself and its runner
          # noctalia-shell
          noctalia-qs
          brightnessctl # Required by Noctalia for brightness control
          imagemagick # Required for wallpaper/theming
        ];

        # home.file.".cache/noctalia/wallpapers.json" = {
        #   text = builtins.toJSON {
        #     defaultWallpaper = "../wallpapers/waterfall.png";
        #     # wallpapers = {
        #     #   "DP-1" = "/path/to/monitor/wallpaper.png";
        #     # };
        #   };
        # };

        home.file = {
          ".face".source = ../images/catppuccin-pfp.png;
        };

        programs.niri = {
          package = pkgs.niri;
          settings = {
            # ...
            spawn-at-startup = [
              {
                command = [
                  "noctalia-shell"
                ];
              }
            ];
          };
        };

        programs.noctalia-shell.enable = true;
        programs.noctalia-shell.settings = {
          # binds = with config.lib.niri.actions; {
          #   # ...
          #   #"Mod+L".action.spawn = noctalia "lockScreen lock";
          # };
          # configure noctalia here
          bar = {
            density = "compact";
            position = "top";
            showCapsule = false;
            widgets = {
              left = [
                {
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
                {
                  id = "Network";
                }
                {
                  id = "Bluetooth";
                }
              ];
              center = [
                {
                  hideUnoccupied = false;
                  id = "Workspace";
                  labelMode = "none";
                }
              ];
              right = [
                {
                  alwaysShowPercentage = true;
                  id = "Battery";
                  warningThreshold = 30;
                }
                {
                  formatHorizontal = "HH:mm";
                  formatVertical = "HH mm";
                  id = "Clock";
                  useMonospacedFont = true;
                  usePrimaryColor = true;
                }
              ];
            };
          };
          #colorSchemes.predefinedScheme = "Monochrome";
          general = {
            avatarImage = "/home/${config.home.username}/.face";
            radiusRatio = 0.2;
          };
          location = {
            monthBeforeDay = false;
            name = "Vienna, Austria";
          };
        };
        # this may also be a string or a path to a JSON file.
      };

    };
}
