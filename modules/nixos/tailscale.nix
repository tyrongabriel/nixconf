{ ... }:
{
  flake.modules.nixos.tailscale =
    { config, ... }:
    {
      config = {
        sops.secrets."tailscale_auth" = {
          sopsFile = ../../secrets/secrets.yaml;
        };

        services.tailscale = {
          enable = true;
          openFirewall = true;

          authKeyFile = config.sops.secrets."tailscale_auth".path;
        };
      };
    };
}
