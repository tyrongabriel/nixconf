{ self, ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.fish;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.fish = with lib; {
        enable = mkEnableOption "Enable fish";
      };
      config = mkIf cfg.enable {
        programs.fish = {
          enable = true;
          generateCompletions = true;

        };
      };
    };
}
