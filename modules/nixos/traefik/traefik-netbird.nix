{ self, ... }:
{
  flake.modules.nixos.traefik =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.traefik.netbird;
    in
    with lib;
    {
      imports = [ ];

      options.myNixos.traefik.netbird = with lib; {
        enable = mkEnableOption "Enable netbird traefik module";
      };

      config = mkIf cfg.enable {
        # Configure Traefik for NetBird
        services.traefik.dynamicConfigOptions = {
          http = {
            routers.netbird = {
              rule = "Host(`netbird.tyrongabriel.com`)";
              entryPoints = [ "websecure" ];
              tls = {
                certResolver = "cloudflare";
                domains = [ { main = "netbird.tyrongabriel.com"; } ];
              };
              service = "netbird";
            };

            services.netbird.loadBalancer = {
              servers = [
                {
                  url = "http://127.0.0.1:33073";
                }
              ];
              passHostHeader = true;
            };
          };
        };
      };
    };
}
