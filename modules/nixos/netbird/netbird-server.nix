{ self, ... }:
{
  flake.modules.nixos.netbird =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.netbird.server;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.netbird.server = with lib; {
        enable = mkEnableOption "NetBird for Homelab nodes";
        authFile = mkOption {
          type = types.path;
          description = "Path to the NetBird pre-shared key file from sops";
        };
      };
      config = {
        # Your configuration here
      };
    };
}
