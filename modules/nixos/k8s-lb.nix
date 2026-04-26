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
      k8sApiServers = lib.concatStringsSep "\n      " (
        lib.imap0 (i: hostStr: "server server-${toString i} ${hostStr} check") lbCfg.k8sApi.hosts
      );

      talosApiServers = lib.concatStringsSep "\n      " (
        lib.imap0 (i: hostStr: "server server-${toString i} ${hostStr} check") lbCfg.talosApi.hosts
      );
    in
    with lib;
    {
      options.myNixos.k8s.lb = {
        enable = mkEnableOption "HAProxy Load Balancer";

        k8sApi = mkOption {
          type = types.submodule {
            options = {
              apiPort = mkOption {
                type = types.port;
                default = 6443;
                description = "Port on which the load balancer listens.";
              };
              hosts = mkOption {
                type = types.listOf types.str;
                default = [ ];
                example = [
                  "host1.tailnet-name.ts.net:6443"
                  "host2.netbird.cloud:6443"
                  "100.64.0.5:6443"
                ];
                description = "List of backend hosts in hostname:port or ip:port format.";
              };
            };
          };
        };

        talosApi = mkOption {
          type = types.submodule {
            options = {
              apiPort = mkOption {
                type = types.port;
                default = 50000;
                description = "Port on which the load balancer listens.";
              };
              hosts = mkOption {
                type = types.listOf types.str;
                default = [ ];
                example = [
                  "host1.tailnet-name.ts.net:50000"
                  "host2.netbird.cloud:50000"
                  "100.64.0.5:50000"
                ];
                description = "List of backend hosts in hostname:port or ip:port format.";
              };
            };
          };
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
            # resolvers tailscale
            #   nameserver magicdns 100.100.100.100:53
            #   resolve_retries 100
            #   timeout retry 5s
            #   hold valid 10s
            #   hold nx 5s
            #   hold other 5s
            #   hold timeout 10s

            frontend k8s_api
                bind *:${toString lbCfg.k8sApi.apiPort}
                default_backend k8s_control_plane

            backend k8s_control_plane
                balance roundrobin
                ${k8sApiServers}
                # Use Netbird DNS names — resolves to Netbird IPs dynamically
                # server vps    cloud-cp.netbird.selfhosted:6443 check ssl verify none
                # Future nodes will be added here:
                # server home1  home-cp1.netbird.selfhosted:6443 check ssl verify none
                # server home2  home-cp2.netbird.selfhosted:6443 check ssl verify none

            frontend talos_api
                bind *:${toString lbCfg.talosApi.apiPort}
                default_backend talos_control_plane

            backend talos_control_plane
                balance roundrobin
                ${talosApiServers}

            listen stats
                bind *:8404
                stats enable
                stats uri /monitor
                stats refresh 5s
          '';
        };

        networking.firewall.allowedTCPPorts = [
          lbCfg.k8sApi.apiPort
          lbCfg.talosApi.apiPort
          8404
        ];
      };
    };
}
