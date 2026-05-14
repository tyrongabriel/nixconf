{ self, ... }:
{
  flake.modules.homeManager.alacritty =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.alacritty;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.alacritty = with lib; {
        enable = mkEnableOption "Enable rio";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        # https://home-manager-options.extranix.com/?query=rio&release=release-25.11
        programs.alacritty = {
          enable = true;
          package = pkgs.alacritty;
        };
      };
    };
}
