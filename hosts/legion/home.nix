{ ... }:
{
  flake.modules.homeManager.legion_tyron =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    with lib;
    {
      myHome = {
        desktop = {
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
              { command = [ "bitwarden" ]; }
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
