{ self, ... }:
{
  flake.modules.homeManager.dev =
    {
      config,
      pkgs,
      lib,
      options,
      ...
    }:
    let
      cfg = config.myHome.development;

      desktopEnabled = ((options.myHome ? desktop)).enable or false;
    in
    {
      imports = [
        self.modules.homeManager.dev_env
        self.modules.homeManager.git
      ];

      options.myHome.development = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable development configuration";
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            myHome.development = {
              git.enable = lib.mkDefault true;
              env = {
                direnv.enable = lib.mkDefault true;
                devbox.enable = lib.mkDefault true;
              };
            };

            home.packages = with pkgs; [
              nixd
              nixfmt
              alejandra
            ];
          }

          # Completely abstracts away the attribute name unless desktopEnabled evaluates to true
          (lib.optionalAttrs desktopEnabled {
            myHome.desktop.apps.zed-editor.enable = lib.mkDefault true;
          })
        ]
      );
    };
}
