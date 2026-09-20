{ ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.cli.pi-agent;
    in
    with lib;
    {
      imports = [
      ];
      options.myHome.cli.pi-agent = with lib; {
        enable = mkEnableOption "Enable pi-agent";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        programs.pi-coding-agent = {
          enable = mkDefault true;

          # models = {

          # };

          extraPackages = [
            pkgs.nodejs
            pkgs.bun
          ];

          # extraPackages = [
          #   "npm:pi-subagents"
          #   "npm:@joemccann/pi-pdf"
          # ];
        };
      };
    };
}
