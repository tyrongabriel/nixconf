{ self, ... }:
{
  flake.modules.nixos.displayManagers =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop.displayManager.greetd;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.desktop.displayManager.greetd = with lib; {
        enable = mkEnableOption "Enable greetd";
      };
      config = mkIf cfg.enable {
        services.gnome.gnome-keyring.enable = true;
        security.pam.services.greetd.enableGnomeKeyring = true;

        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.programs.niri.package}/bin/niri-session";
              user = "greeter";
            };
          };
        };
      };
    };
}
