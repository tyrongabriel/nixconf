{ self, ... }:
{
  flake.modules.nixos.host_legion =
    { lib, ... }:
    with lib;
    {
      #system = "x86_64-linux";
      #specialArgs = { inherit inputs; };
      imports = with self.modules.nixos; [
        core
        desktop
        user_tyron
        user_deploy
      ];
      config = {
        networking.hostName = "legion";
        deployment = {
          targetHost = "192.168.8.172";
          targetUser = "deploy";
          allowLocalDeployment = true;
          tags = [
            "desktop"
          ];
        };
        time.timeZone = lib.mkDefault "Europe/Vienna";

        myNixos = {
          users.tyron.homeManager = {
            enable = true;
            tags = [
              "dev"
              "desktop"
            ];
          };
          ssh = {
            enable = mkForce true;
            fail2ban = mkForce true;
          };
        };

        hardware.facter.reportPath = ./facter.json;
        system.stateVersion = "25.11";
      };
    };
}
