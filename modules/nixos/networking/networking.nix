{ self, ... }:
{
  flake.modules.nixos.networking =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.networking;
    in
    with lib;
    {
      imports = [
        self.modules.nixos.tailscale
        self.modules.nixos.netbird
        self.modules.nixos.tuvpn
      ];
      options.myNixos.networking = with lib; {
        #enable = mkEnableOption "Enable networking";
      };
      config = {
        # DNS Settings
        services.resolved.enable = true;
        networking.networkmanager.dns = "systemd-resolved";

        # OVERLAY NETWORKS
        sops.secrets = {
          "tailscale_auth" = {
            sopsFile = ../../../secrets/secrets.yaml;
          };
          "netbird_home_auth" = {
            sopsFile = ../../../secrets/secrets.yaml;
          };
        };
        myNixos = {
          tailscale = {
            enable = mkDefault false;
            tailnetName = "tail1c2108.ts.net";
            authKeyFile = config.sops.secrets."tailscale_auth".path;
          };

          netbird.home = {
            enable = mkDefault true;
            authFile = config.sops.secrets."netbird_home_auth".path;
          };
        };

      };
    };
}
