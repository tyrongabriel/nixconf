{ self, ... }:
{
  flake.modules.nixos.adguard =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.adguard;
    in
    with lib;
    {
      imports = [ ];

      options.myNixos.adguard = with lib; {
        enable = mkEnableOption "Enable adguard";
        netbirdIp = mkOption {
          type = types.str;
          default = "10.0.0.1";
          description = "IP address of the Netbird interface";
        };
        netbird-interface = mkOption {
          type = types.str;
          default = "wt0";
          description = "Interface for the Netbird interface";
        };
        webUiPort = mkOption {
          type = types.port;
          default = 3000;
          description = "Port for the Web UI";
        };

      };
      config = mkIf cfg.enable {
        # Your configuration here
        services.adguardhome = {
          enable = true;
          host = "${cfg.netbirdIp}";
          port = cfg.webUiPort;

          # We set this to false because we want to open the firewall ONLY
          # for the Netbird interface, not globally.
          openFirewall = false;

          settings = {
            # Web Interface Configuration
            http = {
              address = "${cfg.netbirdIp}:${toString webUiPort}";
            };

            # DNS Server Configuration
            dns = {
              bind_hosts = [ cfg.netbirdIp ];
              port = 53;

              # Optional: Define your upstream DNS servers (e.g., Quad9 DoT)
              bootstrap_dns = [ "9.9.9.9" ];
              upstream_dns = [ "tls://dns.quad9.net" ];

              # Optional but recommended: Rate limiting
              ratelimit = 20;
            };
          };
        };

        # Restrict Firewall to the Netbird interface.
        # Note: Netbird usually uses "wt0". Change this if yours is different.
        networking.firewall.interfaces."${cfg.netbird-interface}" = {
          allowedTCPPorts = [
            53
            cfg.webUiPort
          ];
          allowedUDPPorts = [ 53 ];
        };
      };
    };
}
