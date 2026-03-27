{ ... }:
{
  flake.modules.nixos.k3s =
    {
      config,
      lib,
      pkgs,
      nodes,
      ...
    }:
    let
      cfg = config.myNixos.k3s;
      gatewayCfg = cfg.gateway;

      # Find all servers in the same cluster
      clusterServers = lib.filterAttrs (
        name: nodeConfig:
        let
          k3sConfig = nodeConfig.config.myNixos.k3s or { };
          nodeCfg = k3sConfig.node or { };
          hasServerRole = builtins.elem "server" (nodeCfg.roles or [ ]);
          sameCluster = (nodeCfg.clusterName or "") == cfg.node.clusterName;
          hasAdvertiseEndpoint = (nodeCfg.advertiseEndpoint or null) != null;
        in
        sameCluster && hasServerRole && hasAdvertiseEndpoint
      ) nodes;

      # Format servers for HAProxy backend
      backendServers = lib.concatStringsSep "\n      " (
        lib.mapAttrsToList (
          name: nodeConfig:
          let
            endpoint = nodeConfig.config.myNixos.k3s.node.advertiseEndpoint;
          in
          "server ${name} ${endpoint} check"
        ) clusterServers
      );

      hasServers = builtins.length (lib.attrNames clusterServers) > 0;
    in
    with lib;
    {
      options.myNixos.k3s.gateway = {
        publicIface = mkOption {
          type = types.str;
          default = "eth0";
          description = "The public interface to use for the gateway";
        };

        domain = mkOption {
          type = types.str;
          default = "k3s.local";
          description = "The domain from which we will take traffic, and route it to the cluster nodes via tls passthrough.";
        };
      };

      config = mkIf (cfg.enable && builtins.elem "gateway" cfg.node.roles) {
        assertions = [
          {
            assertion = hasServers;
            message = "No servers found in cluster '${cfg.node.clusterName}' with advertiseEndpoint set.";
          }
        ];

        # services.haproxy = {
        #   enable = true;
        #   config = ''
        #     global
        #       log /dev/log local0
        #       maxconn 4096

        #     defaults
        #       log global
        #       mode tcp
        #       option tcplog
        #       timeout connect 5s
        #       timeout client 50s
        #       timeout server 50s

        #     frontend k3s_frontend
        #       bind *:${toString lbCfg.apiPort}
        #       bind [::]:${toString lbCfg.apiPort}
        #       default_backend k3s_backend

        #     backend k3s_backend
        #       balance roundrobin
        #       ${backendServers}

        #     ${lbCfg.extraConfig}
        #   '';
        # };

        networking.firewall.interfaces."${gatewayCfg.publicIface}".allowedTCPPorts = [
          80
          443
        ];
      };
    };
}
