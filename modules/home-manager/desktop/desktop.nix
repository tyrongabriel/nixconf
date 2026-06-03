{ self, ... }:
{
  flake.modules.homeManager.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop;
    in
    with lib;
    {
      imports = [
        self.modules.homeManager.noctalia
        self.modules.homeManager.cosmic
        self.modules.homeManager.terminal
        self.modules.homeManager.apps
      ];
      options.myHome.desktop = with lib; {
        enable = mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable desktop configuration";
        };
        monitors = mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                name = mkOption {
                  type = lib.types.str;
                  description = "Display name (e.g. 'Some cool name')";
                };
                id = mkOption {
                  type = lib.types.str;
                  description = "Output identifier (e.g. 'hdmi-1', 'eDP-1')";
                };
                primary = mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Whether this is the primary monitor";
                };
                vrr = mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable variable refresh rate (VRR)";
                };
                bar = mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Whether to show the bar on this monitor";
                };
                scale = mkOption {
                  type = lib.types.float;
                  default = 1.0;
                  description = "Display scale";
                };
                mode = mkOption {
                  type = lib.types.submodule {
                    options = {
                      height = mkOption {
                        type = lib.types.nullOr lib.types.int;
                        default = null;
                        description = "Height in pixels";
                      };
                      width = mkOption {
                        type = lib.types.nullOr lib.types.int;
                        default = null;
                        description = "Width in pixels";
                      };
                      refresh = mkOption {
                        type = lib.types.nullOr lib.types.float;
                        default = null;
                        description = "Refresh rate in Hz";
                      };
                    };
                  };
                  default = { };
                  description = "Display mode settings";
                };
              };
            }
          );
          default = [ ];
          description = "List of monitor configurations";
        };
      };
      config = mkIf cfg.enable {
        # Your configuration here
        myHome.desktop.apps = {
          spotify.enable = true;
          nixcord.enable = true;
          zed-editor.enable = true;
          onlyoffice.enable = true;
          bitwarden.enable = true;
          yubico = {
            enable = true;
            touchDetector.enable = true;
          };
        };
        myHome.desktop.terminal = {
          alacritty.enable = true;
          ghostty.enable = true;
        };
        myHome.desktop = {
          niri.enable = true;
          noctalia.enable = true;
        };

        programs.fuzzel = {
          enable = true;
        };
        # 2. Automatically mount USBs on plugin and handle notifications
        services.udiskie.enable = true;

        xdg.enable = true;
        xdg.cacheHome = "${config.home.homeDirectory}/.cache";
        xdg.userDirs = {
          enable = true; # needed by switcheroo etc. to find the correct paths for downloads, documents, etc.
          setSessionVariables = true;
          createDirectories = true;
          extraConfig = {
            # needed by switcheroo, it looks for cache, and expects a tmp folder to be there
            HOME = "${config.home.homeDirectory}/.cache";
            TMP_HOME = "${config.home.homeDirectory}/.cache/tmp";
          };
        };

        myHome.cli.nvf.enable = true; # enable nvf for desktop
        home.packages = with pkgs; [
          qrencode
          xdg-user-dirs
          xdg-user-dirs-gtk
          inkscape-with-extensions
          mattermost-desktop
          mattermost
          vorta
          mission-center
          localsend
          blanket # ambient sounds
          brave
          audacity
          switcheroo
          vlc
          mpv
          #discord # do not install if using nixcord
          wl-clipboard
          cosmic-files
          nautilus
          vial
          yaak
          signal-desktop
          vlc
          #spotify # do not install if using spicetify
          thunderbird
          mullvad-vpn
          vscode
          oculante

          # Extra icon packs
          hicolor-icon-theme
          gnome-themes-extra # Provides fallback assets that Electron apps expect
        ];

        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "image/png" = [ "oculante.desktop" ];
            "image/jpeg" = [ "oculante.desktop" ];
            "image/gif" = [ "oculante.desktop" ];
            "image/avif" = [ "oculante.desktop" ];
            "image/webp" = [ "oculante.desktop" ];
            "video/mp4" = [ "mpv.desktop" ];
            "video/x-matroska" = [ "mpv.desktop" ];
          };
        };

      };
    };
}
