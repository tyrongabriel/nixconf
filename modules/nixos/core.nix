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
    with lib;
    {
      imports = [
        self.modules.nixos.networking
        self.modules.nixos.stylix
      ];

      config = {
        environment.variables.EDITOR = "nvim";

        boot.tmp.cleanOnBoot = true;

        programs = {
          zsh.enable = true;
          fish.enable = true;
        };

        # enabled for the daemon to run
        services.mullvad-vpn.enable = true;

        environment.systemPackages = with pkgs; [
          git
          neovim
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
          ncdu
          tmux
          ssh-to-age
          openssl
          yq
          busybox
          wireguard-tools
          wireshark
        ];

        # Unpatched binaries
        programs.nix-ld = {
          enable = true;
        };
      };
    };
}
