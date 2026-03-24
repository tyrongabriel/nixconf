{
  ...
}:

{
  flake.modules.nixos.core =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
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
        ];
      };
    };
}
