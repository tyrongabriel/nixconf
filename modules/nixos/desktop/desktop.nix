{ self, inputs, ... }:
{
  flake.modules.nixos.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop;
    in
    with lib;
    {
      imports = [
        inputs.nix-index-database.nixosModules.nix-index
        self.modules.nixos.desktopEnvironments
        self.modules.nixos.displayManagers
        self.modules.nixos.windowManagers
        self.modules.nixos.apps
      ];
      options.myNixos.desktop = with lib; {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable desktop environment features";
        };
      };
      config = mkIf cfg.enable {
        # Your configuration here
        programs.nix-index-database.comma.enable = true;
        security.polkit.enable = true;

        myNixos = {
          core.yubico.enable = true;
          core.yubico.identifiers = {
            yelen = 37374407;
            yusuf = 37373134;
          };
          networking = {
            tuvpn.enable = true;
            netbird.mullvadBypass.enable = mkDefault true;
          };

          desktop = {
            displayManager.greetd.enable = mkDefault true;
            windowManager.niri.enable = mkDefault true;
          };

          desktop.apps = {
            # Enable desktop-specific applications here
            vial.enable = mkDefault true;
            yubico.enable = mkDefault true;
          };
        };

        environment.systemPackages = with pkgs; [
          # Add desktop-specific packages here
          kitty
          alacritty
          adwaita-icon-theme
          hicolor-icon-theme
          inputs.hyprpolkitagent.packages.${stdenv.hostPlatform.system}.default
          gparted
        ];

        programs.gnome-disks.enable = true;
        services.udisks2.enable = true;

        services.printing.enable = true;
      };

    };
}
