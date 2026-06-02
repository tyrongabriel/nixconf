{ ... }:
{
  flake.modules.homeManager.legion_tyron =
    {
      lib,
      pkgs,
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
              primary = false;
              bar = false;
              vrr = true;
              scale = 1.1;
              mode = {
                width = 1920;
                height = 1080;
                refresh = 143.998;
              };
            }
            {
              name = "External Monitor";
              id = "HDMI-A-1";
              primary = true;
              bar = true;
              vrr = true;
              scale = 1.0;
              mode = {
                width = 1920;
                height = 1080;
                refresh = 144.001;
              };
            }
          ];
          niri = {
            startupCommands = [
              { command = [ "${pkgs.bitwarden-desktop}/bin/bitwarden" ]; }
              { command = [ "mullvad-vpn" ]; }
              #{ command = [ "vorta -d" ]; }
              # {
              #   command = [
              #     "discord"
              #     "--start-minimized"
              #   ];
              # }
            ];
          };
        };
      };

    };
}
