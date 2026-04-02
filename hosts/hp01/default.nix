{ self, ... }:
{
  flake.modules.nixos.host_hp01 =
    { lib, config, ... }:
    {
      imports = with self.modules.nixos; [
        core
        user_tyron
        user_deploy
        libvirtd
      ];
      config = {
        networking.hostName = "hp01";
        deployment = {
          targetHost = "hp01.tail1c2108.ts.net";
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
