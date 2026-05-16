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
        #security.polkit.enable = true;

        myNixos = {
          networking.tuvpn.enable = true;

          desktop = {
            displayManager.greetd.enable = mkDefault true;
            windowManager.niri.enable = mkDefault true;
          };

          desktop.apps = {
            # Enable desktop-specific applications here
            vial.enable = mkDefault true;
          };
        };

        environment.systemPackages = with pkgs; [
          # Add desktop-specific packages here
          kitty
          alacritty
        ];

        services.printing.enable = true;
      };

    };
}
