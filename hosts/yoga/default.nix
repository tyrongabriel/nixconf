{ self, ... }:
{
  flake.modules.nixos.host_yoga =
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
        networking.hostName = "yoga";
        time.timeZone = lib.mkDefault "Europe/London";

        myNixos.users.tyron.tags = [ "dev" ];

        hardware.facter.reportPath = ./facter.json;
        system.stateVersion = "25.05";
      };
    };
}
