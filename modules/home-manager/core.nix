{ ... }:
{
  flake.modules.homeManager.core =
    { pkgs, ... }:
    {
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
        ];
      };
    };
}
