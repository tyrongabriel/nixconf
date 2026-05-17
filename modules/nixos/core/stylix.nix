{ self, inputs, ... }:
{
  flake.modules.nixos.stylix =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.stylix;
    in
    with lib;
    {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];
      options.myNixos.stylix = with lib; {
        # As soon as you import this, stylix DEMANDS to be enabled
        #enable = mkEnableOption "Enable stylix";
      };
      config = {
        # Stylix imported as flake

        stylix = {
          enable = lib.mkDefault true;
          opacity = {
            terminal = 0.5;
          };

          # The whole nixpkgs.config while using useGlobalPkgs:
          # https://github.com/danth/stylix/issues/865
          # https://github.com/nix-community/home-manager/pull/6172#issuecomment-2661425250
          # https://github.com/brckd/stylix/commit/ce6e96cbd88dcbc22e411120455b23bd3cdd5963
          # This will soon enable:
          # overlays.enable = false;
          polarity = "dark";
          image = ../../home-manager/desktop/assets/wallpapers/waterfall.png;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
          # base16Scheme = {
          #   # https://github.com/catppuccin/catppuccin mocha flavor
          #   base00 = "1e1e2e"; # base
          #   base01 = "181825"; # mantle
          #   base02 = "313244"; # surface0
          #   base03 = "45475a"; # surface1
          #   base04 = "585b70"; # surface2
          #   base05 = "cdd6f4"; # text
          #   base06 = "f5e0dc"; # rosewater
          #   base07 = "b4befe"; # lavender
          #   base08 = "f38ba8"; # red
          #   base09 = "fab387"; # peach
          #   base0A = "f9e2af"; # yellow
          #   base0B = "a6e3a1"; # green
          #   base0C = "94e2d5"; # teal
          #   base0D = "89b4fa"; # blue
          #   base0E = "cba6f7"; # mauve
          #   base0F = "f2cdcd"; # flamingo
          # };

          fonts = {
            monospace = {
              package = pkgs.nerd-fonts.jetbrains-mono;
              name = "JetBrainsMono Nerd Font Mono";
            };
            sansSerif = {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Sans";
            };
            serif = {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Serif";
            };

            sizes = {
              applications = 12;
              terminal = 12;
              desktop = 10;
              popups = 10;
            };
          };

          targets.chromium.enable = true;
          targets.grub.enable = true;
          targets.grub.useWallpaper = true;
          targets.plymouth.enable = true;
          #targets.gnome-text-editor.enable = false;

          autoEnable = true;

          # See https://github.com/NixOS/nixpkgs/blob/88a55dffa4d44d294c74c298daf75824dc0aafb5/pkgs/by-name/bi/bibata-cursors/package.nix#L61
          # For available cursor names
          cursor.name = "Bibata-Modern-Ice";
          cursor.package = pkgs.bibata-cursors;
          cursor.size = 24;

        };

        # Explaination:
        # https://blogs.kde.org/2024/10/09/cursor-size-problems-in-wayland-explained/
        # environment.variables = lib.mkForce {
        #   # Fixes scaling in electron apps, which use X11 while we are in wayland
        #   XCURSOR_SIZE = (config.stylix.cursor.size * 2);
        # };

        environment.variables = {
          # # Force Wayland for apps that support it
          # MOZ_ENABLE_WAYLAND = "1"; # For Firefox & Mozilla-based apps
          # #QT_QPA_PLATFORM = "wayland-egl"; # For Qt apps (Telegram, etc.)
          # GDK_BACKEND = "wayland"; # For GTK apps
          # SDL_VIDEODRIVER = "wayland"; # For SDL-based apps (Games, Emulators)
          # CLUTTER_BACKEND = "wayland"; # Clutter-based apps (e.g., some GNOME apps)
          # XDG_SESSION_TYPE = "wayland"; # Ensure session is Wayland
          # XDG_CURRENT_DESKTOP = "gnome"; # Set your desktop environment explicitly

          # # Electron and Chromium apps (VSCode, Brave, Discord, etc.)
          # NIXOS_OZONE_WL = "1"; # Forces apps using XWayland to prefer Wayland
          # # Enables Wayland for Electron apps
          # ELECTRON_OZONE_PLATFORM_HINT = "auto"; # Ensures Electron apps use native Wayland
        };
      };
    };
}
