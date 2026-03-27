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
      lbCfg = cfg.lb;

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
      options.myNixos.k3s.lb = {
        enable = mkEnableOption "K3s Load Balancer (HAProxy)";

        apiPort = mkOption {
          type = types.port;
          default = 6443;
          description = "Port on which the load balancer listens for K3s API traffic.";
        };

        extraConfig = mkOption {
          type = types.lines;
          default = "";
          description = "Additional HAProxy configuration to append.";
        };
      };

      config = mkIf (cfg.enable && lbCfg.enable && builtins.elem "lb" cfg.node.roles) {
        assertions = [
          {
            assertion = hasServers;
            message = "No servers found in cluster '${cfg.node.clusterName}' with advertiseEndpoint set.";
          }
        ];

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

            frontend k3s_frontend
              bind *:${toString lbCfg.apiPort}
              bind [::]:${toString lbCfg.apiPort}
              default_backend k3s_backend

            backend k3s_backend
              balance roundrobin
              ${backendServers}

            ${lbCfg.extraConfig}
          '';
        };

        networking.firewall.allowedTCPPorts = [ lbCfg.apiPort ];
      };
    };
}
