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
      imports = [ self.modules.nixos.k8s ];

      config = {
        myNixos.k8s.lb = {
          enable = true;
          k8sApi.hosts = [
            "ncvps01.netbird.cloud:6443"
            "ltc01.netbird.cloud:6443"
            "hp01.netbird.cloud:6443"
          ];
          talosApi.hosts = [
            "ncvps01.netbird.cloud:50000"
            "ltc01.netbird.cloud:50000"
            "hp01.netbird.cloud:50000"
          ];
        };
      };

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
