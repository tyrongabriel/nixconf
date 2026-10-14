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
            enable = false;
            k8sApi.hosts = [
              "${ncvps02}:6443"
            ];
            talosApi.hosts = [
              "${ncvps02}:50000"
            ];
            # NOTE: 80/443 on the VPS are now DNAT'd to the homelab ingress VIP
            # over the WireGuard tunnel (myNixos.networking.wgOortIngress), so
            # these haproxy ingress frontends are shadowed and only kept as a
            # fallback config.
            ingress.http.hosts = [
              ncvps02
            ];
            ingress.https.hosts = [
              ncvps02
            ];
          };

          # networking.wgOortIngress = {
          #   enable = true;
          #   publicIp = "159.195.9.89"; # eth0
          #   vip = "192.168.8.50";
          #   # Public key of the home gateway peer; generate with:
          #   #   wg genkey | tee gateway.key | wg pubkey > gateway.pub
          #   peerPublicKey = "BPNCGqCeAimRyIL7UP+npzmD6kqgqMHef87h43syCCs=";
          # };
        };

        hardware.facter.reportPath = ./facter.json;
        nixpkgs.system = "x86_64-linux";
        system.stateVersion = "25.11";
      };
    };
}
