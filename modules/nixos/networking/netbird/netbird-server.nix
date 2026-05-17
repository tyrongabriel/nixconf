{ ... }:
{
  flake.modules.nixos.netbird =
    {
      lib,
      ...
    }:
    with lib;
    {
      imports = [ ];
      options.myNixos.networking.netbird.server = with lib; {
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
