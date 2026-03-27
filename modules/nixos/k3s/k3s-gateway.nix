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
      backendIps = lib.mapAttrsToList (
        _: nodeConfig: nodeConfig.config.myNixos.k3s.node.nodeIp
      ) clusterServers;

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

        domains = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "*.mydomain.com" ];
          description = "The domains from which we will take traffic, and route it to the cluster nodes via tls passthrough.";
        };
      };

      config = mkIf (cfg.enable && builtins.elem "gateway" cfg.node.roles) {
        assertions = [
          {
            assertion = hasServers;
            message = "No servers found in cluster '${cfg.node.clusterName}' with nodeIp set.";
          }
        ];

        services.traefik = {
          enable = true;

          staticConfigOptions = {
            entryPoints = {
              # Empty address strings inside Traefik naturally bind to both IPv4 (0.0.0.0)
              # and IPv6 (::) automatically, so these do not need to change.
              web = {
                address = ":80";
                http.redirections.entryPoint.to = "websecure";
                http.redirections.entryPoint.scheme = "https";
              };
              websecure = {
                address = ":443";
              };
            };
          };

          dynamicConfigOptions = {
            tcp = {
              routers = {
                k3s-passthrough = {
                  rule = "HostSNI(" + lib.concatStringsSep ", " (map (d: "\`${d}\`") cfg.domains) + ")";
                  service = "k3s-cluster";
                  entryPoints = [ "websecure" ];
                  tls.passthrough = true;
                };
              };

              services = {
                k3s-cluster = {
                  loadBalancer = {
                    # This map dynamically formats the IP based on whether it is IPv4 or IPv6
                    servers = map (ip: {
                      address = "${wrapIpv6 ip}:443";
                    }) backendIps;

                    proxyProtocol = {
                      version = 2; # PROXY v2 natively supports passing IPv6 source IPs
                    };
                  };
                };
              };
            };
          };
        };

        networking.firewall.interfaces."${gatewayCfg.publicIface}".allowedTCPPorts = [
          80
          443
        ];
      };
    };
}
