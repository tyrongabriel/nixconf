{ ... }:
{
  flake.modules.nixos.dev =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.dev.docker;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.dev.docker = with lib; {
        enable = mkEnableOption "Enable docker";
      };
      config = mkIf cfg.enable {
        virtualisation.docker = {
          enable = true;
          storageDriver = "btrfs";
          daemon.settings = {
            userland-proxy = false;
            experimental = true;
            #metrics-addr = "0.0.0.0:9323";
            ipv6 = true;
            fixed-cidr-v6 = "fd00::/80";
          };
        };

        environment.systemPackages = [
          pkgs.docker-compose
        ];

      };
    };
}
