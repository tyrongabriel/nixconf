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
      cfg = config.myHome.cli.kubernetes;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.cli.kubernetes = with lib; {
        enable = mkEnableOption "Enable kubernetes";
      };
      config = mkIf cfg.enable {
        programs.k9s.enable = true;
        home.packages = with pkgs; [
          k9s
          kubectl
          helm
          fluxcd
          kns
        ];
      };
    };
}
