{ ... }:
{
  flake.modules.homeManager.legion_tyron =
    { config, lib, ... }:
    with lib;
    {
      myHome = {
        desktop = {
          niri = {
            startupCommands = [
              #"${pkgs.bitwarden-desktop}/bin/bitwarden"
              "discord --start-minimized"
            ];
          };
        };
      };
    };
}
