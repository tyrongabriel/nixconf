{ ... }:
{
  flake.modules.nixos.core =
    {
      lib,
      ...
    }:
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
