{ ... }:
{
  flake.modules.homeManager.core =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.mullvad;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.mullvad = with lib; {
        enable = mkEnableOption "Enable mullvad";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        programs.mullvad-vpn = {
          enable = true;
          settings = {
            animateMap = true;
            autoConnect = true;
            browsedForSplitTunnelingApplications = [ ];
            changelogDisplayedForVersion = "";
            enableSystemNotifications = true;
            monochromaticIcon = false;
            preferredLocale = "system";
            startMinimized = true;
            unpinnedWindow = true;
            updateDismissedForVersion = "";
          };
        };
      };
    };
}
