{ self, ... }:
{
  flake.modules.nixos.netbird =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.netbird.home;
    in
    with lib;
    {
      options.myNixos.netbird.home = {
        enable = mkEnableOption "NetBird for Homelab nodes";
        authFile = mkOption {
          type = types.path;
          description = "Path to the NetBird pre-shared key file from sops";
        };
      };

      config = mkIf cfg.enable {
        # DNS is fucked otherwisee
        security.polkit.enable = true;
        environment.systemPackages = [ pkgs.openresolv ];
        services.resolved.enable = true;
        services.netbird = {
          enable = true;
          package = pkgs.netbird;

          clients = {
            home = {
              autoStart = true;
              openFirewall = true;
              port = 51830;
              login = {
                enable = true;
                setupKeyFile = cfg.authFile;
                #systemdDependencies = [ "sops-install-secrets.service" ];
              };
            };
          };
        };
      };
    };
}
