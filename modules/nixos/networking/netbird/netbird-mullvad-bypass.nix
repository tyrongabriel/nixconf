{ ... }:
{
  flake.modules.nixos.netbird =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.networking.netbird.mullvadBypass;

      # Enumerate all NetBird client interfaces and ports from the NixOS config
      nbClients = config.services.netbird.clients;
      nbInterfaces = lib.mapAttrsToList (_: c: c.interface) nbClients;
      nbPorts = lib.unique (lib.mapAttrsToList (_: c: c.port) nbClients);

      # nftables set syntax: { "nb-home", "wt0" } or { 51820, 51830 }
      ifaceSet = "{ ${lib.concatStringsSep ", " (map (i: "\"${i}\"") nbInterfaces)} }";
      portSet = "{ ${lib.concatStringsSep ", " (map (p: toString p) nbPorts)} }";

      nftTable = pkgs.writeText "netbird-mullvad-bypass.nft" ''
        # Mark        Purpose                Origin
        # 0x0001bd00  NetBird control plane  netbird/client/net/net.go
        # 0x6d6f6c65  Mullvad split-tunnel   mullvadvpn-app/mullvad-types/src/lib.rs
        # 0x00000f41  Mullvad filter accept  mullvadvpn-app/talpid-core/src/split_tunnel/linux/mod.rs

        # Mullvad's rules have higher default priority, so re-mark NetBird packets to bypass Mullvad
        # priority -199 is after conntrack (-200) and before Mullvad (0)
        # The output chain uses `type route` so routing is re-evaluated after meta mark changes

        # Ensure the table exists before delete so `delete table` doesn't error if the table is absent
        table inet netbird-mullvad-bypass
        delete table inet netbird-mullvad-bypass

        table inet netbird-mullvad-bypass {
            # NetBird-routed networks
            # Filled by  netbird-mullvad-bypass.service
            # Updated by netbird-mullvad-bypass-watch.service
            # Empty here for idempotent `nft -f`
            set nb_routed {
                type ipv4_addr
                flags interval
            }

            # Route bypass
            chain output {
                type route hook output priority -199;

                # user-space packets to a NetBird-routed network
                ip daddr @nb_routed ct mark set 0x00000f41 meta mark set 0x6d6f6c65

                # NetBird-emitted packets
                meta mark 0x0001bd00 ct mark set 0x00000f41 meta mark set 0x6d6f6c65

                # inner overlay packets to any NetBird interface
                oifname ${ifaceSet} ct mark set 0x00000f41
            }

            # Filter bypass
            chain input {
                type filter hook input priority -199;

                # outer WireGuard packets from peers on the physical interface
                udp dport ${portSet} iifname != "wg0-mullvad" ct mark set 0x00000f41

                # inner overlay packets from any NetBird interface after WireGuard decapsulation
                iifname ${ifaceSet} ct mark set 0x00000f41
            }

            # Re-routed packet masquerade
            chain nat-postrouting {
                type nat hook postrouting priority srcnat - 5;
                meta mark 0x6d6f6c65 oifname ${ifaceSet} masquerade
            }
        }
      '';

      populateScript = pkgs.writeShellScript "populate-routed-nets.sh" ''
        # Mirror NetBird's routing table (7120 = 0x1bd0) into the netbird-mullvad-bypass `nb_routed` set
        set -eu

        nft_table='inet netbird-mullvad-bypass'
        nft_set='nb_routed'
        nb_table=7120

        # Include both CIDR prefixes and bare host IPs (add /32 for bare IPs)
        prefixes="$(ip -4 route show table "$nb_table" 2>/dev/null \
          | awk '$1 ~ /\//{print $1} $1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/{print $1"/32"}' \
          | sort -u \
          || true)"

        if [ -z "$prefixes" ]; then
            nft flush set "$nft_table" "$nft_set"
            exit 0
        fi

        elements="$(echo "$prefixes" | paste -sd ',')"
        nft -f - <<EOF
        flush set $nft_table $nft_set
        add element $nft_table $nft_set { $elements }
        EOF
      '';

      watchScript = pkgs.writeShellScript "watch-routed-nets.sh" ''
        # Subscribe to the kernel's IPv4 route netlink group via `ip monitor`
        # and refresh the nb_routed nft set whenever a route in NetBird's
        # routing table (7120) is added or removed.
        set -eu

        populate=${populateScript}
        nb_table=7120

        ip -4 monitor route | {
            "$populate"

            while IFS= read -r line; do
                case " $line " in
                    *" table $nb_table "*)
                        "$populate" || true
                        ;;
                esac
            done
        }
      '';
    in
    with lib;
    {
      options.myNixos.networking.netbird.mullvadBypass = {
        enable = mkEnableOption "NetBird bypass rules for Mullvad VPN";
      };

      config = mkIf cfg.enable {
        systemd.services.netbird-mullvad-bypass = {
          description = "NetBird bypass rules for Mullvad VPN";
          after = [
            "netbird.service"
          ]
          ++ (lib.mapAttrsToList (name: _: "netbird-${name}.service") nbClients);
          wants = [ "netbird-mullvad-bypass-watch.service" ];

          path = with pkgs; [
            nftables
            gawk
            iproute2
            coreutils
          ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.nftables}/bin/nft -f ${nftTable}";
            ExecStartPost = populateScript;
            ExecStop = "-${pkgs.nftables}/bin/nft delete table inet netbird-mullvad-bypass";
          };

          wantedBy = [ "multi-user.target" ];
        };

        systemd.services.netbird-mullvad-bypass-watch = {
          description = "Auto-refresh NetBird routed-network set for Mullvad bypass";
          after = [ "netbird-mullvad-bypass.service" ];
          requires = [ "netbird-mullvad-bypass.service" ];
          partOf = [ "netbird-mullvad-bypass.service" ];

          path = with pkgs; [
            nftables
            gawk
            iproute2
            coreutils
          ];

          serviceConfig = {
            Type = "simple";
            ExecStart = watchScript;
            Restart = "on-failure";
            RestartSec = 3;
          };

          wantedBy = [ "multi-user.target" ];
        };
      };
    };
}
