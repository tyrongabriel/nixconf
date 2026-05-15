{ self, inputs, ... }:
{
  flake.modules.homeManager.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.spotify;
    in
    with lib;
    {
      imports = [
        inputs.spicetify-nix.homeManagerModules.spicetify
      ];
      options.myHome.spotify = with lib; {
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
