{ ... }:
{
  flake.modules.nixos.traefik =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      lbCfg = config.myNixos.traefik.k8s-lb;

      # Map the list of strings into Traefik server configurations for TCP load balancing
      # Input: ["host1.tailnet:6443"] -> Output: { address = "host1.tailnet:6443"; }
      k8sApiServers = lib.imap0 (i: hostStr: { address = hostStr; }) lbCfg.k8sApi.hosts;

      talosApiServers = lib.imap0 (i: hostStr: { address = hostStr; }) lbCfg.talosApi.hosts;

    in
    with lib;
    {
      options.myNixos.traefik.k8s-lb = {
        enable = mkEnableOption "Traefik Load Balancer for Kubernetes and Talos APIs";

        k8sApi = mkOption {
          type = types.submodule {
            options = {
              apiPort = mkOption {
                type = types.port;
                default = 6443;
                description = "Port on which the load balancer listens for Kubernetes API.";
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
                description = "Port on which the load balancer listens for Talos API.";
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
        services.traefik = {
          enable = true;
          staticConfigOptions = {
            entryPoints = {
              k8s-api = {
                address = ":${toString lbCfg.k8sApi.apiPort}";
                transport = {
                  respondingTimeouts = {
                    readTimeout = "50s";
                  };
                };
              };
              talos-api = {
                address = ":${toString lbCfg.talosApi.apiPort}";
                transport = {
                  respondingTimeouts = {
                    readTimeout = "50s";
                  };
                };
              };
              metrics = {
                address = ":8080";
              };
            };
            metrics = {
              prometheus = {
                entryPoint = "metrics";
              };
            };
          };

          dynamicConfigOptions = {
            tcp = {
              routers = {
                k8s-api = {
                  entryPoints = [ "k8s-api" ];
                  service = "k8s-api";
                  # No rule required when using HostSNI(*), but let's be explicit
                  rule = "HostSNI(`*`)";
                  tls = {
                    passthrough = true;
                  };
                };
                talos-api = {
                  entryPoints = [ "talos-api" ];
                  service = "talos-api";
                  rule = "HostSNI(`*`)";
                  tls = {
                    passthrough = true;
                  };
                };
              };
              services = {
                k8s-api = {
                  loadBalancer = {
                    servers = k8sApiServers;
                  };
                };
                talos-api = {
                  loadBalancer = {
                    servers = talosApiServers;
                  };
                };
              };
            };
          };
        };

        networking.firewall.allowedTCPPorts = [
          lbCfg.k8sApi.apiPort
          lbCfg.talosApi.apiPort
          8080
        ];
      };
    };
}
