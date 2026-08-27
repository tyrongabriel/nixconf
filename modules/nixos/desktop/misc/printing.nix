{ ... }:
{
  flake.modules.nixos.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop.printing;
    in
    with lib;
    {
      options.myNixos.desktop.printing = {
        enable = mkEnableOption "Enable Printing";
      };

      config = mkIf cfg.enable {
        # Enable CUPS print daemon
        services.printing = {
          enable = true;
          # Optional: Common printer drivers (add HP, Brother, Epson drivers if your printer isn't IPP Everywhere compatible)
          drivers = with pkgs; [
            cups-filters
            gutenprint # broad driver support
            hplip # for HP printers
            # brlaser  # for Brother printers
          ];
        };

        # Enable mDNS / Avahi for network printer autodiscovery
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
      };
    };
}
