{ self, ... }:
{
  flake.modules.homeManager.core =
    { pkgs, ... }:
    {
      imports = [
        self.modules.homeManager.cli
        self.modules.homeManager.git
      ];
      config = {
        # Base packages every home should have
        home.packages = with pkgs; [
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
          lnav
        ];

        myHome = {
          git.enable = true;
          zsh.enable = true;
        };
      };
    };
}
