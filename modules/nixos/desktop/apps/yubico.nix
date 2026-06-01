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
      cfg = config.myNixos.desktop.apps.yubico;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.desktop.apps.yubico = with lib; {
        enable = mkEnableOption "Enable yubico";
      };
      config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          yubioath-flutter
        ];
      };
    };
}
