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
      ];

      config = {
        environment.variables.EDITOR = "nvim";

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
