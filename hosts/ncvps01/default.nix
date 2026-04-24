{ self, ... }:
{
  flake.modules.nixos.host_ncvps01 =
    { lib, config, ... }:
    {
      imports = with self.modules.nixos; [
        core
        user_tyron
        user_deploy
        traefik
      ];
      config = {
        networking.hostName = "ncvps01";
        deployment = {
          targetHost = "152.53.149.109";
          #"ncvps01.netbird.cloud";
          targetUser = "deploy";
          tags = [
            "vps"
            "server"
          ];
        };
        time.timeZone = lib.mkDefault "Europe/Vienna";

        myNixos.users.tyron.homeManager = {
          enable = true;
          tags = [ ];
        };

        myNixos.traefik = {
          enable = true;
          netbird.enable = true;
          k8s-lb = {
            enable = true;
            k8sApi.hosts = [
              "ltc01.netbird.cloud:6443"
              "hp01.netbird.cloud:6443"
            ];
            talosApi.hosts = [
              "ltc01.netbird.cloud:50000"
              "hp01.netbird.cloud:50000"
            ];
          };
        };

        hardware.facter.reportPath = ./facter.json;
        nixpkgs.system = "x86_64-linux";
        system.stateVersion = "25.11";
      };
    };
}
