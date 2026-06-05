{ ... }:
{
  flake.modules.homeManager.yoga_tyron =
    {
      lib,
      ...
    }:
    with lib;
    {
      myHome = {
        ssh.useYubiKey = true;
        desktop = {
          enable = true;
          apps.yubico.ssh-keys = {
            enable = true;
            yubiKeys = [
              "yelen"
              "yusuf"
            ];
          };
          # niri msg outputs
          monitors = [
            {
              name = "Inbuilt Display";
              id = "eDP-1";
              primary = true;
              bar = true;
              vrr = true;
              scale = 1.75;
              mode = {
                width = 2880;
                height = 1800;
                refresh = 90.001;
              };
            }
            # {
            #   name = "Inbuilt Display";
            #   id = "eDP-1";
            #   primary = false;
            #   bar = false;
            #   vrr = true;
            #   scale = 1.1;
            #   mode = {
            #     width = 1920;
            #     height = 1080;
            #     refresh = 143.998;
            #   };
            # }
            # {
            #   name = "External Monitor";
            #   id = "HDMI-A-1";
            #   primary = true;
            #   bar = true;
            #   vrr = true;
            #   scale = 1.0;
            #   mode = {
            #     width = 1920;
            #     height = 1080;
            #     refresh = 144.001;
            #   };
            # }
          ];
          niri = {
            startupCommands = [
              { command = [ "mullvad-daemon" ]; }
              {
                command = [
                  "tray-launch"
                  "mullvad-vpn --ozone-platform=wayland"
                ];
              }
              # {
              #   command = [
              #     "tray-launch"
              #     "bitwarden"
              #   ];
              # }
              {
                command = [
                  "tray-launch"
                  "signal-desktop"
                ];
              }
            ];
          };
        };
      };

      # xdg.autostart = {
      #   enable = true;
      #   entries = [
      #     #"${pkgs.evolution}/share/applications/org.gnome.Evolution.desktop"
      #     "${pkgs.bitwarden-desktop}/share/applications/bitwarden.desktop"
      #   ];
      # };
    };
}
