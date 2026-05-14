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
        self.modules.homeManager.niri
        self.modules.homeManager.cosmic
        self.modules.homeManager.rio
        self.modules.homeManager.alacritty
        self.modules.homeManager.mullvad
      ];
      options.myHome.desktop = with lib; {
        #enable = mkEnableOption "Enable desktop";
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
      config = {
        # Your configuration here
        myHome.alacritty.enable = true;
        myHome.mullvad.enable = true;
        myHome.desktop = {
          niri.enable = true;
          noctalia.enable = true;
        };

        home.packages = with pkgs; [
          brave
          discord
          wl-clipboard
          cosmic-files
          vial
          yaak
          signal-desktop
          vlc
          spotify
          thunderbird
          mullvad-vpn
          vscode
        ];

        # fix warnings stylix makes
        gtk.gtk4.theme = config.gtk.theme;
      };
    };
}
