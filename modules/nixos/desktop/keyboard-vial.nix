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
      cfg = config.myNixos.desktop.keyboard-vial;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.desktop.keyboard-vial = with lib; {
        enable = mkEnableOption "Enable desktop";
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
