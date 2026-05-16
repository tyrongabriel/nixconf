{ ... }:
{
  flake.modules.nixos.tailscale =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.myNixos.networking.tailscale;
    in
    {
      options.myNixos.networking.tailscale = with lib; {
        enable = mkEnableOption "Tailscale VPN";

        authKeyFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path to the Tailscale auth key file.";
        };

        autoconnect = mkOption {
          type = types.bool;
          default = true;
          description = "Automatically connect to the Tailscale network.";
        };

        tailnetName = mkOption {
          type = types.str;
          default = "";
          description = "Tailscale network (tailnet) name, used for TLS cert generation.";
        };

        exitNode = mkOption {
          type = types.bool;
          default = false;
          description = "Enable exit node functionality.";
        };

        enableSSH = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Tailscale SSH (allows root login).";
        };

        openFirewall = mkOption {
          type = types.bool;
          default = true;
          description = "Open the firewall for Tailscale.";
        };

        extraUpFlags = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Extra flags to pass to tailscale up.";
        };

        allowLanAccess = mkOption {
          type = types.bool;
          default = true;
          description = "Allow access to the local network when using an exit node.";
        };

        externalInterface = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "External interface for NAT (used with exit nodes). Defaults to eth0 if available.";
        };

        advertiseRoutes = mkOption {
          type = types.str;
          default = "";
          description = "Routes to advertise to other nodes (comma-separated, e.g. \"10.0.0.0/8,192.168.0.0/24\") or empty string to not advertise routes.";
        };
      };

      config = lib.mkIf cfg.enable {
        warnings = lib.lists.optional cfg.enableSSH "Tailscale SSH enabled, allows root login!";

        services.tailscale = {
          enable = true;
          useRoutingFeatures = lib.mkDefault "both";
          authKeyFile = lib.mkDefault cfg.authKeyFile;
          openFirewall = cfg.openFirewall;
          extraUpFlags =
            (lib.optional cfg.enableSSH "--ssh")
            ++ (lib.optional cfg.exitNode "--advertise-exit-node")
            ++ (lib.optional cfg.allowLanAccess "--accept-routes")
            ++ (lib.optional (cfg.advertiseRoutes != "") "--advertise-routes=${cfg.advertiseRoutes}")
            ++ cfg.extraUpFlags;
        };

        # Don't block boot on autoconnect
        systemd.services.tailscaled-autoconnect = lib.mkIf cfg.autoconnect {
          wantedBy = lib.mkForce [ ];
        };

        # TLS cert renewal via tailscale cert
        systemd.services.update-tailscale-tls-cert = lib.mkIf (cfg.tailnetName != "") {
          description = "Renew Tailscale TLS certificate";
          environment = {
            HOSTNAME = config.networking.hostName;
            TAILNET_NAME = cfg.tailnetName;
          };
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.tailscale}/bin/tailscale cert \${HOSTNAME}.\${TAILNET_NAME}";
          };
        };

        systemd.timers.update-tailscale-tls-cert = lib.mkIf (cfg.tailnetName != "") {
          description = "Renew Tailscale TLS certificate monthly";
          wantedBy = [ "timers.target" ];
          partOf = [ "update-tailscale-tls-cert.service" ];
          timerConfig = {
            Unit = "update-tailscale-tls-cert.service";
            OnCalendar = "monthly";
            Persistent = true;
          };
        };

        networking.firewall = lib.mkIf cfg.openFirewall {
          checkReversePath = "loose";
          trustedInterfaces = [ "tailscale0" ];
          allowedUDPPorts = [ 41641 ];
        };

        # NAT for exit nodes
        networking.nat = lib.mkIf cfg.exitNode {
          enable = true;
          externalInterface = lib.mkDefault (
            if cfg.externalInterface != null then
              cfg.externalInterface
            else if config.networking.interfaces ? "eth0" then
              "eth0"
            else
              ""
          );
          internalInterfaces = [ "tailscale0" ];
        };

        environment.systemPackages = [ pkgs.tailscale ];
      };
    };
}
