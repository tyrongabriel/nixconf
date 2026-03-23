{ inputs, self, ... }:
{
  flake.modules.nixos.host_yoga =
    { ... }:
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

        hardware.facter.reportPath = ./facter.json;
        system.stateVersion = "25.05";
      };
    };
}
