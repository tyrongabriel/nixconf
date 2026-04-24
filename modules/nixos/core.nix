{
  self,
  ...
}:

{
  flake.modules.nixos.core =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      imports = [
        self.modules.nixos.tailscale
        self.modules.nixos.netbird
      ];

      config = {
        environment.systemPackages = with pkgs; [
          git
          vim
          ripgrep
          fd
          fzf
          bat
          jq
          tree
          wget
          curl
          gnupg
          pass
          btop
          dig
        ];

        myNixos = {
          tailscale = {
            enable = false;
            tailnetName = "tail1c2108.ts.net";
            authKeyFile = config.sops.secrets."tailscale_auth".path;
          };

          netbird.home = {
            enable = true;
            authFile = config.sops.secrets."netbird_home_auth".path;
          };
        };

        sops.secrets."tailscale_auth" = {
          sopsFile = ../../secrets/secrets.yaml;
        };

        sops.secrets."netbird_home_auth" = {
          sopsFile = ../../secrets/secrets.yaml;
        };

        # services.tailscale = {
        #   enable = false;
        #   openFirewall = true;

        #   authKeyFile = config.sops.secrets."tailscale_auth".path;
        # };
      };
    };
}
