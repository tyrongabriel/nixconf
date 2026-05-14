{ self, ... }:
{
  flake.modules.nixos.tuvpn =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.tuvpn;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.tuvpn = with lib; {
        enable = mkEnableOption "Enable tuvpn";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        environment.shellAliases = {
          tuvpn-up = "sudo systemctl start openconnect-tuvienna";
          tuvpn-down = "sudo systemctl stop openconnect-tuvienna";
          tuvpn-stat = "systemctl status openconnect-tuvienna";
        };
        sops.secrets = {
          tu-network-password = {
            sopsFile = ../../../secrets/secrets.yaml;
          };
          tu-totp-token = {
            sopsFile = ../../../secrets/secrets.yaml;
          };
        };
        networking.openconnect = {
          interfaces."tuvienna" = {
            autoStart = false;
            user = "e12326136@student.tuwien.ac.at";
            passwordFile = config.sops.secrets.tu-network-password.path;
            protocol = "anyconnect";
            gateway = "vpn.tuwien.ac.at";
            extraOptions = {
              authgroup = "1_TU_getunnelt"; # "2_Alles_getunnelt"; #

              #no-external-auth = true;
              token-mode = "totp";
              token-secret = "@${config.sops.secrets.tu-totp-token.path}";
              #verbose = true;
              #dump-http-traffic = true;
            };
          };
        };
        # networking.networkmanager = {
        #   enable = true;
        #   # Add this line to link the plugin into NetworkManager's search path
        #   plugins = with pkgs; [
        #     networkmanager-openconnect
        #   ];
        #   ensureProfiles.profiles = {
        #     TU-VPN = {
        #       connection = {
        #         id = "TU-VPN";
        #         type = "vpn";
        #         autoconnect = "false";
        #       };
        #       vpn = {
        #         service-type = "org.freedesktop.NetworkManager.openconnect";
        #         gateway = "vpn.tuwien.ac.at";
        #         protocol = "anyconnect";
        #         authtype = "password";
        #         user = "e12326136@student.tuwien.ac.at";
        #         # Note: NetworkManager doesn't handle sops paths in vpn.data easily.
        #         # You may need to enter the password/token manually once in the UI.
        #       };
        #     };
        #   };
        # };

        # # Also ensure the base package is available
        # environment.systemPackages = with pkgs; [
        #   networkmanager-openconnect
        # ];
      };
    };
}
