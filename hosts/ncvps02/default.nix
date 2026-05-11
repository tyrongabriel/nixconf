{ self, ... }:
{
  flake.modules.nixos.host_ncvps02 =
    { lib, config, ... }:
    let
      ncvps02 = "152.53.149.109";
    in
    with lib;
    {
      imports = with self.modules.nixos; [
        core
        user_tyron
        user_deploy
        k8s
        server
      ];
      config = {
        networking.hostName = "ncvps02";
        deployment = {
          targetHost = "ncvps02.netbird.cloud";
          targetUser = "deploy";
          tags = [
            "vps"
            "server"
          ];
        };
        time.timeZone = lib.mkDefault "Europe/Vienna";

        myNixos = {
          users.tyron.homeManager = {
            enable = true;
            tags = [ ];
          };
          k8s.lb = {
            enable = true;
            k8sApi.hosts = [
              "${ncvps02}:6443"
            ];
            talosApi.hosts = [
              "${ncvps02}:50000"
            ];
            ingress.http.hosts = [
              ncvps02
            ];
            ingress.https.hosts = [
              ncvps02
            ];
          };
        };

        hardware.facter.reportPath = ./facter.json;
        nixpkgs.system = "x86_64-linux";
        system.stateVersion = "25.11";
      };
    };
}
