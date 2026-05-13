{ self, ... }:
{
  flake.modules.nixos.core =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.home-manager;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.home-manager = with lib; {
        #enable = mkEnableOption "Enable home-manager";
      };
      config = {
        # Your configuration here
        home-manager.backupFileExtension = "hm-bak";
      };
    };
}
