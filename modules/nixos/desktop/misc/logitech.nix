{ ... }:
{
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop.logitech;
    in
    with lib;
    {
      options.myNixos.desktop.logitech = {
        enable = mkEnableOption "Enable Logitech utilities";
      };

      config = mkIf cfg.enable {
        hardware.logitech.wireless.enable = true;
        programs.solaar.enable = true;
      };
    };
}
