{ self, ... }:
{
  flake.modules.nixos.host_droplet =
    { lib, config, ... }:
    {
      #system = "x86_64-linux";
      #specialArgs = { inherit inputs; };
      imports = with self.modules.nixos; [
        core
        user_tyron
        user_deploy
      ];
      config = {
        networking.hostName = "droplet";
        deployment = {
          targetHost = "droplet.tail1c2108.ts.net";
          targetUser = "deploy";
        };
        time.timeZone = lib.mkDefault "Europe/Vienna";

        myNixos.users.tyron.homeManager = {
          enable = true;
          tags = [ "dev" ];
        };

        hardware.facter.reportPath = ./facter.json;
        nixpkgs.system = "x86_64-linux";
        system.stateVersion = "25.11";
      };

    };
}
