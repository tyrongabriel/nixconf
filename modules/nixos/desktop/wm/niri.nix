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
        };

        services.pipewire = {
          enable = true;
          alsa.enable = true;
          pulse.enable = true;
        };

        # Screensharing
        xdg.portal = {
          enable = true;
          xdgOpenUsePortal = true;
          extraPortals = [
            pkgs.xdg-desktop-portal-gtk
            pkgs.xdg-desktop-portal-gnome
            pkgs.xdg-desktop-portal-wlr
          ];
          config = {
            common.default = [
              "gnome"
              "gtk"
              "wlr"
            ];
          };
        };

        networking.networkmanager.enable = true;
        hardware.bluetooth.enable = true;
        services.power-profiles-daemon.enable = true; # or services.tuned.enable
        services.upower.enable = true;

        environment.systemPackages = with pkgs; [
          # niri dependencies
          xwayland-satellite
          libXcursor
          xdg-desktop-portal-wlr
          brightnessctl # Required by Noctalia for brightness control
          imagemagick # Required for wallpaper/theming
        ];

        # Essential Wayland environment variables
        environment.sessionVariables = {
          LD_LIBRARY_PATH = "${pkgs.libXcursor}/lib:$LD_LIBRARY_PATH"; # ESSENTIAL WHEN USING STYLIX!
          CLUTTER_BACKEND = "wayland";
          GDK_BACKEND = "wayland,x11";
          MOZ_ENABLE_WAYLAND = "1";
          QT_QPA_PLATFORM = "wayland";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";

          XDG_SESSION_TYPE = "wayland";
          XDG_CURRENT_DESKTOP = "niri";
          DISPLAY = ":0";
          NIXOS_OZONE_WL = "1"; # Hint for Electron/Chromium apps to use Wayland
        };
        # Graphics drivers are crucial for Wayland compositors
        hardware.graphics.enable = true;
      };
    };
}
