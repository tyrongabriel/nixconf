{ self, ... }:
{
  flake.modules.homeManager.core =
    { pkgs, ... }:
    {
      imports = [
        self.modules.homeManager.cli
        self.modules.homeManager.git
        self.modules.homeManager.ssh
        self.modules.homeManager.mullvad
      ];
      config = {
        myHome.mullvad.enable = true;
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

        programs = {
          bat.enable = true;
          fzf.enable = true;
          btop.enable = true;
          lazygit.enable = true;
          neovim.enable = true;
        };

        myHome = {
          git.enable = true;
          zsh.enable = true;
        };
      };
    };
}
