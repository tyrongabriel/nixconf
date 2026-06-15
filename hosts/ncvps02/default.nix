{ self, inputs, ... }:
{
  flake.modules.nixos.host_ncvps02 =
    { lib, ... }:
    let
      ncvps02 = "152.53.149.109";
    in
    with lib;
    {
      imports =
        with self.modules.nixos;
        [
          core
          user_tyron
          user_deploy
          k8s
          server
        ]
        ++ [ inputs.nix-index-database.nixosModules.nix-index ];
      config = {
        networking.hostName = "ncvps02";
        deployment = {
          targetHost = "159.195.9.89";
          targetUser = "deploy";
          # sshOptions = [
          #   "-i"
          #   "/home/tyron/.ssh/id_ed25519"
          # ];
          tags = [
            "vps"
            "server"
          ];
        };

        # I like comma
        programs.nix-index-database.comma.enable = true;

        myNixos.sops = {
          sopsFile = ./secrets/secrets.yaml;
          users.tyron.sopsSecretsFile = ./secrets/users/tyron.yaml;
        };

        myNixos = {
          users.tyron.homeManager = {
            enable = true;
            tags = [
              "dev"
            ];
          };
          k8s.lb = {
            enable = true;
            k8sApi.hosts = [
              "${ncvps02}:6443"
            ];
            talosApi.hosts = [
              "${ncvps02}:50000"
            ];
            ingress.http.hosts = [
              ncvps02
            ];
            ingress.https.hosts = [
              ncvps02
            ];
          };
        };

        hardware.facter.reportPath = ./facter.json;
        nixpkgs.system = "x86_64-linux";
        system.stateVersion = "25.11";
      };
    };
}
