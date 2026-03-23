{ self, ... }:
{
  flake.modules.nixos.host_template =
    { lib, ... }:
    {
      #system = "x86_64-linux";
      #specialArgs = { inherit inputs; };
      imports = with self.modules.nixos; [
        core
        user_tyron
        user_deploy
      ];
      config = {
        networking.hostName = "template";
        deployment = {
          targetHost = "localhost";
          targetUser = "deploy";
          allowLocalDeployment = true;
        };
        time.timeZone = lib.mkDefault "Europe/Vienna";

        myNixos.users.tyron.homeManager = {
          enable = true;
          tags = [ "dev" ];
        };

        hardware.facter.reportPath = ./facter.json;
        system.stateVersion = "25.11";
      };
    };
}
