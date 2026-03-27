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
      wrapIpv6 = (ip: if lib.hasInfix ":" ip then "[${ip}]" else ip);

      # Find all servers in the same cluster
      clusterServers = lib.filterAttrs (
        name: nodeConfig:
        let
          k3sConfig = nodeConfig.config.myNixos.k3s or { };
          nodeCfg = k3sConfig.node or { };
          hasServerRole = builtins.elem "server" (nodeCfg.roles or [ ]);
          sameCluster = (nodeCfg.clusterName or "") == cfg.node.clusterName;
          hasNodeIp = (nodeCfg.nodeIp or null) != null;
        in
        sameCluster && hasServerRole && hasNodeIp
      ) nodes;

      # Format servers for HAProxy backend
      backendServers = lib.concatStringsSep "\n      " (
        lib.mapAttrsToList (
          name: nodeConfig:
          let
            ip = wrapIpv6 nodeConfig.config.myNixos.k3s.node.nodeIp;
            port = nodeConfig.config.myNixos.k3s.server.apiPort;
          in
          "server ${name} ${ip}:${toString port} check"
        ) clusterServers
      );

      hasServers = builtins.length (lib.attrNames clusterServers) > 0;
    in
    with lib;
    {
      options.myNixos.k3s.lb = {
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

      config = mkIf (cfg.enable && builtins.elem "lb" cfg.node.roles) {
        assertions = [
          {
            assertion = hasServers;
            message = "No servers found in cluster '${cfg.node.clusterName}' with nodeIp set.";
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

        networking.firewall.interfaces."${cfg.internalIface}".allowedTCPPorts = [ lbCfg.apiPort ];
      };
    };
}
