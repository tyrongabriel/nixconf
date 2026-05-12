{ self, ... }:
{
  flake.modules.nixos.host_yoga =
    { lib, ... }:
    with lib;
    {
      #system = "x86_64-linux";
      #specialArgs = { inherit inputs; };
      imports = with self.modules.nixos; [
        core
        user_tyron
        user_deploy
      ];
      config = {
        networking.hostName = "yoga";
        deployment = {
          targetHost = "localhost";
          targetUser = "deploy";
          allowLocalDeployment = true;
        };
        time.timeZone = lib.mkDefault "Europe/Vienna";

        myNixos = {
          ssh = {
            enable = mkForce true;
            fail2ban = mkForce true;
          };
          users.tyron.homeManager = {
            enable = true;
            tags = [ "dev" ];
            #extraImports = [ self.modules.homeManager.git ];
          };
        };

        hardware.facter.reportPath = ./facter.json;
        system.stateVersion = "25.05";
      };
    };
}
