{ self, ... }:
{
  flake.modules.nixos.desktopEnvironments =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop.desktopEnvironments.cosmic;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.desktop.desktopEnvironments.cosmic = with lib; {
        enable = mkEnableOption "Enable desktop.cosmic";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        # Enable the COSMIC login manager
        services.displayManager.cosmic-greeter.enable = true;

        # Enable the COSMIC desktop environment
        services.desktopManager.cosmic.enable = true;
        services.system76-scheduler.enable = true;
        environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
        # environment.cosmic.excludePackages = with pkgs; [
        #   cosmic-edit
        # ];

        # services.displayManager.autoLogin = {
        #     enable = true;
        #     # Replace `yourUserName` with the actual username of user who should be automatically logged in
        #     user = "yourUserName";
        #   };
      };
    };
}
