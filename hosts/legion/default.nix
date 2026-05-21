{ self, ... }:
{
  flake.modules.nixos.host_legion =
    { lib, ... }:
    let
      deployTags = [
        "dev"
        "desktop"
      ];
      tags = [
        "dev"
        "desktop"
      ];
    in
    with lib;
    {
      #system = "x86_64-linux";
      #specialArgs = { inherit inputs; };
      imports = with self.modules.nixos; [
        core
        desktop
        user_tyron
        user_deploy
        dev
      ];
      config = {
        # Deployment
        networking.hostName = "legion";
        deployment = {
          targetHost = "legion.netbird.cloud"; # "192.168.8.172";
          targetUser = "deploy";
          allowLocalDeployment = true;
          tags = [ ] ++ deployTags;
        };

        # Config
        myNixos.users.tyron.homeManager = {
          enable = true;
          tags = [ ] ++ tags;
          extraImports = [
            self.modules.homeManager.legion_tyron
          ];
        };

        myNixos.ssh = {
          enable = mkForce true;
          fail2ban = mkForce true;
        };

        hardware.facter.reportPath = ./facter.json;
        system.stateVersion = "25.11";
      };
    };
}
