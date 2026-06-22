{ inputs, ... }:
{
  flake.modules.nixos.displayManagers =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop.displayManager.noctalia-greeter;
    in
    with lib;
    {
      imports = [
        inputs.noctalia-greeter.nixosModules.default
      ];
      options.myNixos.desktop.displayManager.noctalia-greeter = with lib; {
        enable = mkEnableOption "Enable noctalia-greeter";
      };
      config = mkIf cfg.enable {
        services.gnome.gnome-keyring.enable = true;
        security.pam.services.greetd.enableGnomeKeyring = true;

        # noctalia-greeter is a wlroots-based Wayland compositor;
        # the greeter user needs GPU access to initialize.
        users.users.greeter.extraGroups = [
          "video"
          "render"
        ];

        programs.noctalia-greeter = {
          enable = true;
          package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
          greeter-args = "--session niri";
          settings.cursor = {
            theme = "Adwaita";
            size = 24;
            package = pkgs.adwaita-icon-theme;
          };
        };

        # Force wlroots to use the DRM backend. Without this, a leaked
        # $DISPLAY env var (from PAM/systemd) causes the X11 backend to
        # be selected, which fails because there is no X server running.
        services.greetd.settings.default_session.command =
          let
            greeterPkg = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
          in
          "${pkgs.coreutils}/bin/env WLR_BACKENDS=drm,libinput XCURSOR_THEME=Adwaita XCURSOR_SIZE=24 XCURSOR_PATH=${pkgs.adwaita-icon-theme}/share/icons ${greeterPkg}/bin/noctalia-greeter-session -- --session niri";
      };
    };
}
