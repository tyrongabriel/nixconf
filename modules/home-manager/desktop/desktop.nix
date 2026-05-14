{ self, ... }:
{
  flake.modules.homeManager.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop;
    in
    with lib;
    {
      imports = [
        self.modules.homeManager.noctalia
        self.modules.homeManager.niri
        self.modules.homeManager.cosmic
      ];
      options.myHome.desktop = with lib; {
        #enable = mkEnableOption "Enable desktop";
      };
      config = {
        # Your configuration here
        myHome.desktop = {
          niri.enable = true;
          noctalia.enable = true;
        };

        home.packages = with pkgs; [
          brave
          discord
          wl-clipboard
          cosmic-files
          vial
        ];

        # fix warnings stylix makes
        gtk.gtk4.theme = config.gtk.theme;
      };
    };
}
