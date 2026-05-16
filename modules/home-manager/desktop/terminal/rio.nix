{ self, ... }:
{
  flake.modules.homeManager.terminal =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.terminal.rio;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.terminal.rio = with lib; {
        enable = mkEnableOption "Enable rio";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        # https://home-manager-options.extranix.com/?query=rio&release=release-25.11
        programs.rio = {
          enable = true;
          package = pkgs.rio;
          settings = {
            # Add rio-specific settings here
          };
          themes = {
            # Add rio-specific themes here
          };
        };
      };
    };
}
