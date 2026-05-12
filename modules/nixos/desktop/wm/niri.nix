{ self, inputs, ... }:
{
  flake.modules.nixos.niri =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop.niri;
    in
    with lib;
    {
      imports = [
        inputs.niri-flake.nixosModules.niri # Also imports home-manager for all users! https://github.com/sodiboo/niri-flake/blob/main/docs.md
      ];
      options.myNixos.desktop.niri = with lib; {
        enable = mkEnableOption "Enable niri";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        # Enables niri in my DM
        programs.niri = {
          enable = true;
          package = pkgs.niri;
        };

        networking.networkmanager.enable = true;
        hardware.bluetooth.enable = true;
        services.power-profiles-daemon.enable = true; # or services.tuned.enable
        services.upower.enable = true;

        environment.systemPackages = with pkgs; [
          # niri dependencies
          brightnessctl # Required by Noctalia for brightness control
          imagemagick # Required for wallpaper/theming
        ];

        # Essential Wayland environment variables
        environment.sessionVariables = {
          NIXOS_OZONE_WL = "1"; # Hint for Electron/Chromium apps to use Wayland
        };
        # Graphics drivers are crucial for Wayland compositors
        hardware.graphics.enable = true;
      };
    };
}
