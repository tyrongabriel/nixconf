{ self, ... }:
{
  flake.modules.nixos.host_ncvps02 =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      ncvps01 = "152.53.149.109";
    in
    with lib;
    {
      imports = [ self.modules.nixos.k8s ];

      config = {
        myNixos.k8s.lb = {
          enable = true;
          k8sApi.hosts = [
            "${ncvps01}:6443"
          ];
          talosApi.hosts = [
            "${ncvps01}:50000"
          ];
          ingress.http.hosts = [
            ncvps01
          ];
          ingress.https.hosts = [
            ncvps01
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
