{ ... }:
{
  flake.modules.nixos.host_droplet =
    { ... }:
    {

      #sops.defaultSopsFile = ./secrets/secrets.yaml;
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      # sops.secrets."yoga/wireguard/private" = {
      #   sopsFile = ./hosts/yoga/secrets/secrets.yaml;
      # };
    };
}
