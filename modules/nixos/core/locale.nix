{ self, ... }:
{
  flake.modules.nixos.core =
    {
      lib,
      ...
    }:
    with lib;
    {
      imports = [ ];
      config = {
        # Your configuration here
        # # Set your time zone.
        time.timeZone = mkDefault "Europe/Vienna"; # "Europe/Vienna";

        # For time format in windows dualboot
        time.hardwareClockInLocalTime = mkDefault true;

        # Select internationalisation properties.
        i18n.defaultLocale = mkDefault "en_US.UTF-8";

        i18n.extraLocaleSettings = {
          LC_ADDRESS = mkDefault "de_AT.UTF-8";
          LC_IDENTIFICATION = mkDefault "de_AT.UTF-8";
          LC_MEASUREMENT = mkDefault "de_AT.UTF-8";
          LC_MONETARY = mkDefault "de_AT.UTF-8";
          LC_NAME = mkDefault "de_AT.UTF-8";
          LC_NUMERIC = mkDefault "de_AT.UTF-8";
          LC_PAPER = mkDefault "de_AT.UTF-8";
          LC_TELEPHONE = mkDefault "de_AT.UTF-8";
          LC_TIME = mkDefault "de_AT.UTF-8";
        };

        console.useXkbConfig = mkDefault true;
        # Configure keymap in X11
        services.xserver.xkb = {
          layout = mkDefault "at";
          variant = mkDefault "nodeadkeys";
          options = mkDefault "caps:escape";
        };
      };
    };
}
