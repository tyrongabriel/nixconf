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
      wrapIpv6 = (ip: if lib.hasInfix ":" ip then "[${ip}]" else ip);

      # Whether this node actually runs the K3s daemon (server or agent).
      # A pure "lb" node does NOT run K3s — it only load-balances via HAProxy.
      hasK3sRole = builtins.any (
        r:
        builtins.elem r [
          "server"
          "agent"
        ]
      ) cfg.node.roles;
    in
    with lib;
    {
      options.myNixos.k3s = {
        enable = mkEnableOption "K3s Kubernetes";
        internalIface = mkOption {
          type = types.nullOr types.str;
          default = "tailscale0";
          example = "tailscale0";
          description = ''
            Internal interface for the node to manage k3s traffic on.
            This will be the only port where the node will accept k3s traffic on.
            (Either the iface of the intranet, or overlay network eg. "tailscale0")
          '';
        };

        node = {
          clusterName = mkOption {
            type = types.str;
            description = "Unique identifier for the K3s cluster this node belongs to.";
            example = "production";
          };

          roles = mkOption {
            type = types.listOf (
              types.enum [
                "server"
                "agent"
                "lb"
                "gateway"
              ]
            );
            default = [ ];
            description = "Roles this node has in the cluster.";
            example = [
              "server"
              "agent"
            ];
          };

          tokenFile = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to the K3s cluster token file.";
          };

          nodeName = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Override the node name. Defaults to networking.hostName.";
          };

          nodeIP = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "IP address for the node to advertise.";
          };

          extraFlags = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Extra flags to pass to k3s (applies to both server and agent).";
          };

          disableSwap = mkOption {
            type = types.bool;
            default = true;
            description = "Disable swap devices (required for K3s).";
          };

          enableHelm = mkOption {
            type = types.bool;
            default = true;
            description = "Install kubernetes-helm.";
          };

          enableLonghornSupport = mkOption {
            type = types.bool;
            default = true;
            description = "Enable packages and services required for Longhorn CSI.";
          };

          enableThermald = mkOption {
            type = types.bool;
            default = true;
            description = "Enable thermald for CPU temperature management.";
          };

          cpuFreqGovernor = mkOption {
            type = types.nullOr types.str;
            default = "performance";
            description = "CPU frequency governor. Set to null to disable.";
          };

          clusterCIDR = mkOption {
            type = types.str;
            default = "fdba:bb29:4301::/56";
            description = "Cluster CIDR for pod networking.";
          };

          serviceCIDR = mkOption {
            type = types.str;
            default = "fdba:bb29:4302::/112";
            description = "Service CIDR for Kubernetes services.";
          };

          flannelBackend = mkOption {
            type = types.str;
            default = "wireguard-native";
            description = "Flannel backend to use.";
          };

        };
      };

      config = mkMerge [
        # --- Assertions & warnings (apply to ALL enabled roles, including lb-only) ---
        (mkIf cfg.enable {
          assertions = [
            {
              assertion = cfg.node.clusterName != "";
              message = "myNixos.k3s.node.clusterName must be set.";
            }
            {
              assertion = builtins.length cfg.node.roles > 0;
              message = "myNixos.k3s.node.roles must contain at least one role.";
            }
          ];

          warnings = optional (
            cfg.node.tokenFile == null && builtins.elem "agent" cfg.node.roles
          ) "K3s agent enabled but no tokenFile specified.";
        })

        # --- K3s daemon infrastructure (only for server/agent nodes) ---
        (mkIf (cfg.enable && hasK3sRole) {
          # Disable swap (K3s requirement)
          swapDevices = mkIf cfg.node.disableSwap [ ];

          # Kernel modules required for K3s
          boot.kernelModules = [
            "overlay"
            "br_netfilter"
            "nft_counter"
            "nf_conntrack"
            "nft-expr-counter"
          ];

          boot.kernel.sysctl = {
            "net.bridge-nf-call-iptables" = mkDefault 1;
            "net.bridge-nf-call-ip6tables" = mkDefault 1;
            "net.ipv4.ip_forward" = 1;
            # For cloudflare tunnel
            "net.core.rmem_max" = 10000000;
            "net.core.wmem_max" = 10000000;
          };

          # Nftables backend for iptables
          systemd.services.nftables = {
            enable = true;
            after = [ "network.target" ];
            serviceConfig.Environment = "IPTABLES_BACKEND=nft";
          };

          # Base K3s service configuration
          services.k3s = mkMerge [
            {
              enable = true;
              tokenFile = mkDefault cfg.node.tokenFile;
              nodeName = mkDefault (
                if cfg.node.nodeName != null then cfg.node.nodeName else config.networking.hostName
              );
              nodeIP = mkDefault cfg.node.nodeIP;
              extraFlags = mkMerge [
                cfg.node.extraFlags
                [
                  "--flannel-ipv6-masq"
                  "--cluster-cidr=${cfg.node.clusterCIDR}"
                  "--service-cidr=${cfg.node.serviceCIDR}"
                  "--flannel-backend=${cfg.node.flannelBackend}"
                  # For kube-prometheus
                  "--kube-proxy-arg=metrics-bind-address=::"
                ]
                (optional (cfg.node.nodeIP != null) "--bind-address=${cfg.node.nodeIP}")
                (optional (cfg.node.nodeIP != null) "--node-external-ip=${cfg.node.nodeIP}")
              ];
            }
          ];

          # Common firewall ports for all K3s nodes
          networking.firewall.interfaces."${cfg.internalIface}" = {
            allowedTCPPorts = [ 10250 ];
            allowedUDPPorts = [
              8472 # Flannel VXLAN
              10250 # Kubelet
              7844 # Cloudflare quic
            ];
          };

          # Optional packages
          environment.systemPackages =
            #with pkgs;
            [ ]
            ++ optional cfg.node.enableHelm pkgs.kubernetes-helm
            ++ optional cfg.node.enableLonghornSupport pkgs.openiscsi
            ++ optional cfg.node.enableLonghornSupport pkgs.util-linux;

          # Longhorn support
          services.openiscsi = mkIf cfg.node.enableLonghornSupport {
            enable = true;
            name = "${config.networking.hostName}-initiatorhost";
          };

          systemd.services.iscsid.serviceConfig = mkIf cfg.node.enableLonghornSupport {
            PrivateMounts = "yes";
            BindPaths = "/run/current-system/sw/bin:/bin";
          };

          # Longhorn fstrim hack
          system.activationScripts.longhorn-fstrim = mkIf cfg.node.enableLonghornSupport {
            text = ''
              mkdir -p /usr/bin
              ln -sfn /run/current-system/sw/bin/fstrim /usr/bin/fstrim
            '';
          };

          # Performance tuning
          services.thermald.enable = mkIf cfg.node.enableThermald true;
          powerManagement.cpuFreqGovernor = mkDefault cfg.node.cpuFreqGovernor;
        })
      ];
    };
}
