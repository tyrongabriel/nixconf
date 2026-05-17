{ ... }:
{
  flake.modules.nixos.displayManagers =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop.displayManager.sddm;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.desktop.displayManager.sddm = {
        enable = mkEnableOption "Enable sddm displayManager";
        wayland = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to run SDDM itself on Wayland (instead of X11)";
        };
      };
      config = mkIf cfg.enable {
        # Your configuration here
        services.displayManager.sddm = {
          enable = true;
          wayland.enable = mkDefault cfg.wayland; # Ensures SDDM itself runs on Wayland
        };
      };
    };
}
