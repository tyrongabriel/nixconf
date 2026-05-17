{ ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.cli.fish;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.cli.fish = with lib; {
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
