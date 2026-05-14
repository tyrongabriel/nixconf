{ self, ... }:
{
  # Module aggregation for dev modules
  flake.modules.homeManager.dev =
    { config, pkgs, ... }:
    {
      # import all dev-modules
      imports = [
        self.modules.homeManager.zed-editor
        #self.modules.homeManager.git
      ];
      config = {
        # Dev configuration aggregation
        #programs.zed-editor.enable = true;
        #
        myHome = {
          zed-editor.enable = true;
        };

        # Direnv
        programs.direnv = {
          enable = true;
          enableZshIntegration = true;
          silent = true;
          nix-direnv = {
            enable = true;
          };
        };

        home.packages = with pkgs; [
          devbox
          nixd
          nixfmt
          alejandra
        ];
      };
    };
}
