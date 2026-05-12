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
      ];
      options.myHome.desktop = with lib; {
        #enable = mkEnableOption "Enable desktop";
      };
      config = {
        # Your configuration here
      };
    };
}
