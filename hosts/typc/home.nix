{ ... }:
{
  flake.modules.homeManager.typc_tyron =
    {
      lib,
      ...
    }:
    with lib;
    {
      myHome = {
        ssh.useYubiKey = true;
        cli.kubernetes.enable = true;
        desktop = {
          enable = true;
          gaming.enable = true;

          apps.yubico.ssh-keys = {
            enable = true;
            yubiKeys = [
              "yelen"
              "yusuf"
            ];
          };
          # TODO: run `niri msg outputs` after install to get correct monitor IDs
          monitors = [
            # {
            #   name = "Primary Monitor";
            #   id = "DP-1";
            #   primary = true;
            #   bar = true;
            #   vrr = true;
            #   scale = 1.0;
            #   mode = {
            #     width = 1920;
            #     height = 1080;
            #     refresh = 144.0;
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
