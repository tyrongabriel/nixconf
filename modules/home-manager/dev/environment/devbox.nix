{ self, ... }:
{
  flake.modules.homeManager.dev_env =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.development.env.devbox;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.development.env.devbox = with lib; {
        enable = mkEnableOption "Enable devbox";
      };
      config = mkIf cfg.enable {
        home.packages = with pkgs; [
          devbox
        ];
      };
    };
}
