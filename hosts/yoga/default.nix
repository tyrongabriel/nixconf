{ inputs, self, ... }:
let
in
{
  flake.nixosModules.host_yoga =
    { ... }:
    {
      #system = "x86_64-linux";
      #specialArgs = { inherit inputs; };
      imports = [
        inputs.sops-nix.nixosModules.sops
        inputs.nixos-facter-modules.nixosModules.facter

        self.nixosModules.core
        self.nixosModules.disko_yoga

        self.nixosModules.user_tyron
        self.nixosModules.user_deploy
      ];
      config = {
        networking.hostName = "yoga";
        myNixos.users = {
          tyron.enable = true;
          deploy.enable = true;
        };

        sops.defaultSopsFile = ./secrets/secrets.yaml;
        sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

        # sops.secrets."yoga/wireguard/private" = {
        #   sopsFile = ./hosts/yoga/secrets/secrets.yaml;
        # };

        hardware.facter.reportPath = ./facter.json;
        system.stateVersion = "25.05";
      };
    };
}
