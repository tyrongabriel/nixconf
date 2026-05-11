{ ... }:
{
  flake.modules.nixos.host_yoga =
    { ... }:
    {

      sops.defaultSopsFile = ./secrets/secrets.yaml;
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      # sops.secrets."path/to/secret" = {
      #   sopsFile = ./secrets/secrets.yaml;
      # };
    };
}
