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
        desktop
        user_tyron
        user_deploy
      ];
      config = {
        networking.hostName = "yoga";
        deployment = {
          targetHost = "yoga.netbird.cloud";
          targetUser = "deploy";
          # sshOptions = [
          #   "-i"
          #   "/home/tyron/.ssh/id_ed25519"
          # ];
          allowLocalDeployment = true;
          tags = [
            "dev"
            "desktop"
          ];
        };
        time.timeZone = lib.mkDefault "Europe/Vienna";

        # Sops
        myNixos.sops = {
          sopsFile = ./secrets/secrets.yaml;
          users.tyron.sopsSecretsFile = ./secrets/users/tyron.yaml;
        };

        # Config
        myNixos.users.tyron.homeManager = {
          enable = true;
          tags = [
            "dev"
            "desktop"
          ];
          extraImports = [
            self.modules.homeManager.yoga_tyron
          ];
        };

        myNixos.ssh = {
          enable = mkForce true;
          fail2ban = mkForce true;
        };

        hardware.facter.reportPath = ./facter.json;
        system.stateVersion = "26.05";
      };
    };
}
