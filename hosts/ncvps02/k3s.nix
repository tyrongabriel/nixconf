{ self, ... }:
{
  flake.modules.nixos.host_ncvps02 =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    with lib;
    {
      # imports = [ self.modules.nixos.k3s ];

      # config = {
      #   # sops.secrets."k3s/main/token" = {
      #   #   sopsFile = ../../secrets/secrets.yaml;
      #   # };

      #   myNixos.k3s = {
      #     enable = true;
      #     node = {
      #       clusterName = "main";
      #       roles = [
      #         "lb"
      #         "gateway"
      #       ];
      #     };
      #     lb = {
      #       apiPort = 6443;
      #     };
      #     gateway = {
      #       publicIface = "eth0";
      #       domains = [
      #         "^.+\.example\.com$"
      #         "^tyrongabriel\.com$"
      #       ];
      #     };
      #   };

      # };
    };
}
