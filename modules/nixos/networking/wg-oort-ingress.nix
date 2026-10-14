# Public ingress tunnel, VPS side.
#
# The VPS is the WireGuard *server*; the homelab gateway dials in as a client
# with a .conf file. The VPS 1:1 proxies all public TCP/UDP traffic (except the
# excluded ports) to the cluster ingress VIP through the tunnel, without
# terminating anything (raw DNAT, not a userspace proxy).
#
# The SNAT to the VPS's own WireGuard address is what makes this work with a
# tightly-scoped client AllowedIPs: replies from the VIP are routed back into
# the tunnel (they only know 10.100.0.1), and inbound packets always carry a
# source the gateway's cryptokey routing accepts.
{
  flake.modules.nixos.wgOortIngress =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.networking.wgOortIngress;

      excludedPorts = lib.unique (cfg.excludedPorts ++ [ cfg.listenPort ]);

      portSet = "{ ${lib.concatStringsSep ", " (map toString excludedPorts)} }";

      nftRules = pkgs.writeText "wg-oort-ingress.nft" ''
        # 1:1 L4 proxy: everything arriving on the WAN goes to the VIP, except
        # traffic addressed to the VPS itself (ssh, k8s/talos LB frontends, wg).
        # Traffic arriving via the tunnel is never re-DNAT'd (loop guard).
        table ip oort_ingress {
            set excluded_tcp {
                type inet_service
                elements = ${portSet}
            }
            set excluded_udp {
                type inet_service
                elements = ${portSet}
            }

            chain prerouting {
                type nat hook prerouting priority dstnat; policy accept;
                iifname != "wg0" ip daddr ${cfg.publicIp} tcp dport != @excluded_tcp counter dnat to ${cfg.vip}
                iifname != "wg0" ip daddr ${cfg.publicIp} udp dport != @excluded_udp counter dnat to ${cfg.vip}
            }

            # Rewrites forwarded traffic so its source is the VPS's tunnel
            # address; this is the only address the gateway peer accepts.
            chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
                oifname "wg0" ip daddr ${cfg.vip} counter snat to ${cfg.address}
            }

            chain forward {
                type filter hook forward priority filter; policy accept;
                iifname "wg0" oifname != "wg0" counter accept
                oifname "wg0" iifname != "wg0" counter accept
                oifname "wg0" ip daddr ${cfg.vip} counter accept
            }

            # WireGuard overhead can exceed the path MTU; clamp so large
            # sessions don't blackhole.
            chain clamp {
                type filter hook forward priority -150; policy accept;
                oifname "wg0" tcp flags syn tcp option maxseg size set rt mtu
            }
        }
      '';
    in
    with lib;
    {
      options.myNixos.networking.wgOortIngress = {
        enable = mkEnableOption "WireGuard public-ingress tunnel (VPS side) forwarding to the homelab ingress VIP";

        publicIp = mkOption {
          type = types.str;
          description = "Public IPv4 address of the VPS (the DNAT match address).";
        };

        vip = mkOption {
          type = types.str;
          default = "192.168.8.50";
          description = "Cluster ingress VIP inside the homelab.";
        };

        address = mkOption {
          type = types.str;
          default = "10.100.0.1";
          description = "WireGuard tunnel address of the VPS.";
        };

        peerAddress = mkOption {
          type = types.str;
          default = "10.100.0.2";
          description = "WireGuard tunnel address of the home gateway peer.";
        };

        listenPort = mkOption {
          type = types.port;
          default = 51820;
          description = "UDP port the VPS WireGuard server listens on.";
        };

        mtu = mkOption {
          type = types.int;
          default = 1420;
          description = "WireGuard interface MTU.";
        };

        privateKeyFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Explicit path to the VPS WireGuard private key. When null, the sops secret 'wg_oort_ingress_priv' from the host's default sops file is used.";
        };

        peerPublicKey = mkOption {
          type = types.str;
          description = "Public key of the home gateway WireGuard peer.";
        };

        excludedPorts = mkOption {
          type = types.listOf types.port;
          default = [
            22
            50000
            6443
            8404
          ];
          description = ''
            Ports that stay local on the VPS instead of being forwarded to the
            VIP (ssh, talos/k8s API LB, haproxy stats). Ports 80/443 are
            intentionally NOT excluded: they belong to the VIP now, which
            shadows the haproxy ingress frontends on the VPS.
          '';
        };
      };

      config = mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.peerPublicKey != "" && !hasInfix "REPLACE_WITH" cfg.peerPublicKey;
            message = "myNixos.networking.wgOortIngress.peerPublicKey must be set to the gateway's WireGuard public key (see hosts/ncvps02/default.nix).";
          }
        ];

        sops.secrets =
          let
            useSopsSecret = cfg.privateKeyFile == null;
          in
          mkIf useSopsSecret {
            # Uses sops.defaultSopsFile configured per-host.
            "wg_oort_ingress_priv" = { };
          };

        boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

        networking.wireguard = {
          enable = true;
          interfaces.wg0 = {
            ips = [ "${cfg.address}/24" ];
            listenPort = cfg.listenPort;
            mtu = cfg.mtu;
            privateKeyFile =
              if cfg.privateKeyFile != null then
                cfg.privateKeyFile
              else
                config.sops.secrets."wg_oort_ingress_priv".path;
            peers = [
              {
                publicKey = cfg.peerPublicKey;
                allowedIPs = [
                  "${cfg.peerAddress}/32"
                  "${cfg.vip}/32"
                ];
              }
            ];
          };
        };

        networking.firewall.allowedUDPPorts = [ cfg.listenPort ];

        systemd.services.oort-ingress-nft = {
          description = "DNAT/SNAT rules proxying public traffic to the ingress VIP over WireGuard";
          wantedBy = [ "multi-user.target" ];
          wants = [
            "network-online.target"
            "wireguard-wg0.service"
          ];
          after = [
            "network-online.target"
            "wireguard-wg0.service"
            "sops-nix.service"
          ];
          path = [ pkgs.nftables ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.nftables}/bin/nft -f ${nftRules}";
            ExecStop = "-${pkgs.nftables}/bin/nft delete table ip oort_ingress";
          };
        };
      };
    };
}
