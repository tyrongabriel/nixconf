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
      cfg = config.myHome.desktop.apps.t3code;
    in
    with lib;
    {
      options.myHome.desktop.apps.t3code = with lib; {
        enable = mkEnableOption "Enable T3 Code";
      };
      config = mkIf cfg.enable {
        home.packages = [
          # Put OpenCode on T3 Code's PATH so it can control it. Codex is
          # disabled because this setup only uses OpenCode as the provider.
          (pkgs.t3code.override {
            enableOpencode = true;
            enableCodex = false;
          })
        ];
      };
    };
}
