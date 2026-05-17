{ ... }:
{
  flake.modules.nixos.apps =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop.apps.vial;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.desktop.apps.vial = with lib; {
        enable = mkEnableOption "Enable vial keyboard configurator";
      };
      config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          # Add desktop-specific packages here
          qmk
          vial

        ];

        hardware.keyboard.qmk.enable = true;

        # This is necessary for vial to see my keyboard https://discourse.nixos.org/t/via-vial-cant-find-my-keyboard/52525
        services.udev = {
          packages = with pkgs; [
            qmk
            qmk-udev-rules # the only relevant
            qmk_hid
            via
            vial
          ]; # packages
        }; # udev

      };

    };
}
