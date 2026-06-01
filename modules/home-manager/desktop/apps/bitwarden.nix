{ ... }:
{
  flake.modules.homeManager.apps =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.apps.bitwarden;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.apps.bitwarden = with lib; {
        enable = mkEnableOption "Enable bitwarden";
      };
      config = mkIf cfg.enable {
        home.packages = with pkgs; [
          bitwarden-desktop
          bitwarden-cli
        ];
      };
    };
}
