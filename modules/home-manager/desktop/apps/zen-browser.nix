{ inputs, ... }:
{
  flake.modules.homeManager.apps =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.apps.zen-browser;
    in
    with lib;
    {
      imports = [ inputs.zen-browser.homeModules.beta ];
      options.myHome.desktop.apps.zen-browser = with lib; {
        enable = mkEnableOption "Enable zen-browser";
      };
      config = mkIf cfg.enable {
        # https://github.com/0xc000022070/zen-browser-flake
        programs.zen-browser = {
          enable = true;
          #setAsDefaultBrowser = true;
          profiles = {
            tyron = {
              # bookmarks, extensions, search engines...
            };
          };
        };
        stylix.targets.zen-browser.profileNames = [
          "tyron"
        ];

      };
    };
}
