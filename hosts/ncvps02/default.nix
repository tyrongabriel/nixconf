{ self, ... }:
{
  flake.modules.nixos.host_ncvps02 =
    { lib, config, ... }:
    {
      imports = with self.modules.nixos; [
        core
        user_tyron
        user_deploy
        k8s
      ];
      config = {
        networking.hostName = "ncvps02";
        deployment = {
          targetHost = "ncvps02.tail1c2108.ts.net";
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

        myNixos.k8s.lb = {
          enable = true;
          hosts = [
            "talos-ltc01-01:6443"
            "talos-hp01-01:6443"
          ];
        };

        hardware.facter.reportPath = ./facter.json;
        nixpkgs.system = "x86_64-linux";
        system.stateVersion = "25.11";
      };
    };
}
