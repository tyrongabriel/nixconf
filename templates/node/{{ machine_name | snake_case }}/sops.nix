{ ... }:
{
  flake.modules.nixos.host_{{ machine_name | snake_case }} =
    { ... }:
    {
      #sops.defaultSopsFile = ./secrets/secrets.yaml;
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      # Cluster secrets at /var/lib/sops-nix/cluster-key.txt
      sops.age.keyFile = "/var/lib/sops-nix/cluster-key.txt";

      # sops.secrets."path/to/secret" = {
      #   sopsFile = ./secrets/secrets.yaml;
      # };
    };
}
