{ ... }:
{
  flake.modules.nixos.k8s =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.myNixos.k8s;
      lbCfg = cfg.lb;

      # Map the list of strings into HAProxy server lines
      # Input: ["host1.tailnet:6443"] -> Output: "server server-0 host1.tailnet:6443 check resolvers tailscale"
      backendServers = lib.concatStringsSep "\n      " (
        lib.imap0 (
          i: hostStr:
          "server server-${toString i} ${hostStr} check resolvers tailscale init-addr last,libc,none"
        ) lbCfg.hosts
      );
    in
    with lib;
    {
      options.myNixos.k8s.lb = {
        enable = mkEnableOption "HAProxy Load Balancer";

        hosts = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [
            "host1.tailnet-name.ts.net:6443"
            "100.64.0.5:6443"
          ];
          description = "List of backend hosts in hostname:port or ip:port format.";
        };

        apiPort = mkOption {
          type = types.port;
          default = 6443;
          description = "Port on which the load balancer listens.";
        };
      };

      config = mkIf lbCfg.enable {
        services.haproxy = {
          enable = true;
          config = ''
            global
              log /dev/log local0
              maxconn 4096

            defaults
              log global
              mode tcp
              option tcplog
              timeout connect 5s
              timeout client 50s
              timeout server 50s

            # Resolver for Tailscale MagicDNS
            resolvers tailscale
              nameserver magicdns 100.100.100.100:53
              resolve_retries 100
              timeout retry 5s
              hold valid 10s
              hold nx 5s
              hold other 5s
              hold timeout 10s

            frontend k3s_frontend
              bind *:${toString lbCfg.apiPort}
              default_backend k3s_backend

            backend k3s_backend
              balance roundrobin
              ${backendServers}
          '';
        };

        networking.firewall.allowedTCPPorts = [ lbCfg.apiPort ];
      };
    };
}
