{ self, ... }:
{
  flake.modules.homeManager.core =
    { pkgs, lib, ... }:
    with lib;
    {
      imports = [
        self.modules.homeManager.cli
      ];
      config = {
        myHome = {
          cli = {
            zsh.enable = mkDefault true;
            zellij.enable = mkDefault true;
          };
          ssh.enable = mkDefault true;
          mullvad.enable = mkDefault true;
        };

        programs = {
          bat.enable = true;
          fzf.enable = true;
          btop.enable = true;
          neovim.enable = true;
        };

        # Base packages every home should have
        home.packages = with pkgs; [
          git
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
          lnav
          tmux
          zellij
          tldr
          nmap
          dig
          btop
          yazi
          unzip
          fastfetch
        ];

      };
    };
}
