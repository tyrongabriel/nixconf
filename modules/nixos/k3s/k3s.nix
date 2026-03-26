{ self, ... }:
{
  flake.modules.nixos.k3s =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.k3s;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.k3s = with lib; {
        #enable = mkEnableOption "Enable k3s";
      };
      config = {
        # Your configuration here
      };
    };
}
