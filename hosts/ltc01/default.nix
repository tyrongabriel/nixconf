{ self, ... }:
{
  flake.modules.nixos.host_ltc01 =
    { lib, ... }:
    {
      imports = with self.modules.nixos; [
        core
        user_tyron
        user_deploy
      ];
      config = {
        networking.hostName = "ltc01";
        deployment = {
          targetHost = "ltc01.tail1c2108.ts.net";
          targetUser = "deploy";
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
