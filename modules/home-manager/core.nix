{ self, ... }:
{
  flake.modules.homeManager.core =
    { pkgs, ... }:
    {
      imports = [
        self.modules.homeManager.cli
        self.modules.homeManager.git
        self.modules.homeManager.ssh
      ];
      config = {
        # Base packages every home should have
        home.packages = with pkgs; [
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

        myHome = {
          git.enable = true;
          zsh.enable = true;
        };
      };
    };
}
