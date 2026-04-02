{ self, ... }:
{
  flake.modules.nixos.host_hp01 =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      nodeIp = "fd7a:115c:a1e0::fe01:b912";
      lbIp = "fd7a:115c:a1e0::4d01:f6e";
    in
    with lib;
    {
      # imports = [ self.modules.nixos.k3s ];
      # config = {
      #   sops.secrets."k3s/main/token" = {
      #     sopsFile = ../../secrets/secrets.yaml;
      #   };

      #   myNixos.k3s = {
      #     enable = true;
      #     node = {
      #       clusterName = "main";
      #       roles = [
      #         "server"
      #         "agent"
      #       ];
      #       tokenFile = config.sops.secrets."k3s/main/token".path;
      #       nodeIP = nodeIp;
      #       #advertiseEndpoint = "[${nodeIp}]:6443"; # Used by LB to discover this server
      #     };
      #     server = {
      #       #clusterInit = true; # Only on first server
      #       serverAddr = "https://[${lbIp}]:6443"; # LB IP for cert
      #       tlsSANs = [ lbIp ]; # LB IP for cert
      #     };
      #   };
      # };
    };
}
