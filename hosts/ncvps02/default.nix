{ self, ... }:
{
  flake.modules.nixos.host_ncvps02 =
    { lib, config, ... }:
    {
      imports = with self.modules.nixos; [
        core
        user_tyron
        user_deploy
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

        hardware.facter.reportPath = ./facter.json;
        nixpkgs.system = "x86_64-linux";
        system.stateVersion = "25.11";
      };
    };
}
