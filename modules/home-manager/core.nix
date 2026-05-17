{ self, ... }:
{
  flake.modules.homeManager.core =
    {
      pkgs,
      lib,
      config,
      ...
    }:
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
            nvf.enable = mkDefault false; # heavy for servers, desktop enables
          };
          ssh.enable = mkDefault true;
          mullvad.enable = mkDefault true;
        };

        programs = {
          bat.enable = true;
          fzf.enable = true;
          btop.enable = true;
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
          neovim # not via programs.enable, cuz stylix
        ];

        # fix warnings stylix makes
        gtk.gtk4.theme = config.gtk.theme;
      };
    };
}
