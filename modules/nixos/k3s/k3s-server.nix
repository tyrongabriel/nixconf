{ ... }:
{
  flake.modules.nixos.k3s =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.myNixos.k3s;
      serverCfg = cfg.server;
    in
    with lib;
    {
      options.myNixos.k3s.server = {
        clusterInit = mkOption {
          type = types.bool;
          default = false;
          description = "Whether this server initializes the cluster (only one server should have this).";
        };

        apiPort = mkOption {
          type = types.port;
          default = 6443;
          description = "Port on which the K3s API server listens.";
        };

        advertisedApiPort = mkOption {
          type = types.port;
          default = 6443;
          description = "Port on which the K3s server advertises for API requests.";
        };

        serverAddr = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Address of the load balancer or init server to join the cluster. Only needed for non-init servers.";
          example = "https://[fd00::100]:6443";
        };

        nodePortRange = mkOption {
          type = types.submodule {
            options = {
              from = mkOption {
                type = types.port;
                description = "Lower bound of the node port range.";
              };
              to = mkOption {
                type = types.port;
                description = "Upper bound of the node port range.";
              };
            };
          };
          default = {
            from = 30000;
            to = 32767;
          };
          description = "Port range for service node ports.";
        };

        extraFlags = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Extra flags to pass to k3s server.";
        };

        tlsSANs = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Additional TLS Subject Alternative Names for the API server certificate.";
        };
      };

      config = mkIf (cfg.enable && builtins.elem "server" cfg.node.roles) {
        services.k3s = {
          role = "server";
          clusterInit = serverCfg.clusterInit;
          disableAgent = mkForce (!(builtins.elem "agent" cfg.node.roles));
          serverAddr = mkIf (!serverCfg.clusterInit) (mkForce (serverCfg.serverAddr));
          extraFlags =
            serverCfg.extraFlags
            ++ [
              "--advertise-port=${toString serverCfg.advertisedApiPort}"
              "--https-listen-port=${toString serverCfg.apiPort}"
              "--service-node-port-range=${toString serverCfg.nodePortRange.from}-${toString serverCfg.nodePortRange.to}"
              "--advertise-address=${cfg.node.nodeIP}"
              # For kube-prometheus
              "--kube-scheduler-arg=bind-address=::"
              "--etcd-expose-metrics"
              "--kube-controller-manager-arg=bind-address=::"
              "--kube-apiserver-arg=bind-address=::"
            ]
            ++ map (san: "--tls-san=${san}") serverCfg.tlsSANs;
        };

        networking.firewall.interfaces."${cfg.internalIface}" = {
          allowedTCPPorts = [
            serverCfg.apiPort # K3s API
            2379 # etcd client
            2380 # etcd peer
          ];
          allowedTCPPortRanges = [ serverCfg.nodePortRange ];
        };

      };
    };
}
