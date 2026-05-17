{ ... }:
{
  flake.modules.nixos.traefik =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.traefik;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.traefik = with lib; {
        enable = mkEnableOption "Enable module";
      };
      config = lib.mkIf cfg.enable {
        sops.secrets."traefik/cf_api_email" = {
          sopsFile = ../../../../secrets/secrets.yaml;
        };
        sops.secrets."traefik/cf_api_token" = {
          sopsFile = ../../../../secrets/secrets.yaml;
        };

        systemd.services.traefik = {
          environment = {
            # CF_API_EMAIL = config.sops.secrets.cloudflare_api_email.value;
            # CF_API_KEY = config.sops.secrets.cloudflare_api_key.value;
          };
          serviceConfig = {
            EnvironmentFile = [
              config.sops.secrets."traefik/cf_api_email".path
              config.sops.secrets."traefik/cf_api_token".path
            ];
          };
        };

        services.traefik = {
          enable = true;
          staticConfigOptions = {
            entryPoints = {
              web = {
                address = ":80";
                # Redirect all HTTP traffic to HTTPS
                http.redirections.entryPoint = {
                  to = "websecure";
                  scheme = "https";
                };
              };
              websecure = {
                address = ":443";
              };
            };

            certificatesResolvers = {
              cloudflare = {
                acme = {
                  email = "support@tyrongabriel.com";
                  storage = "/var/lib/traefik/acme.json";
                  dnsChallenge = {
                    provider = "cloudflare";
                    # Optional: specify reliable DNS servers for verification
                    resolvers = [
                      "1.1.1.1:53"
                      "1.0.0.1:53"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
}
