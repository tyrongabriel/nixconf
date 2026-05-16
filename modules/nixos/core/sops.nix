{ ... }:
{
  flake.modules.nixos.core =
    { inputs, ... }:
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      config = {
        # Secrets
        #sops.defaultSopsFile = ./secrets/secrets.yaml;
        sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        sops.age.keyFile = "/var/lib/sops-nix/cluster-key.txt";

        # sops.secrets."path/to/secret" = {
        #   sopsFile = ./secrets/secrets.yaml;
        # };
      };
    };
}
