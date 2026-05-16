{ self, inputs, ... }:
{
  flake.modules.homeManager.apps =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.apps.spotify;
    in
    with lib;
    {
      imports = [
        inputs.spicetify-nix.homeManagerModules.spicetify
      ];
      options.myHome.desktop.apps.spotify = with lib; {
        enable = mkEnableOption "Enable module";
      };
      config = mkIf cfg.enable {
        # https://gerg-l.github.io/spicetify-nix/usage.html
        programs.spicetify = {
          enable = true;
        };
      };
    };
}
