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
      cfg = config.myHome.development.env.direnv;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.development.env.direnv = with lib; {
        enable = mkEnableOption "Enable dev-environment";
      };
      config = mkIf cfg.enable {
        # Direnv
        programs.direnv = {
          enable = true;
          enableZshIntegration = true;
          silent = true;
          nix-direnv = {
            enable = true;
          };
        };
      };
    };
}
