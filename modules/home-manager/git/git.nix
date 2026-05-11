{ self, ... }:
{
  flake.modules.homeManager.git =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.myHome.git;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.git = with lib; {
        enable = mkEnableOption "Enable Git configuration";
        includes = lib.mkOption {
          description = "A list of included configurations for Git";
          type =
            with pkgs.lib.types;
            listOf (submodule {
              options = {
                condition = lib.mkOption {
                  type = str;
                  description = "Condition to include (gitdir:<PATH>)";
                };
                contents = lib.mkOption {
                  type = attrs;
                  description = "Name of the .desktop file inside of the package ({pkg}/share/appliactions/{name}.desktop)";
                };
              };
            });
          default = [ ];
        };
      };

      config = {
        # Configure Git
        programs.git = {
          enable = lib.mkDefault true;
          settings = {
            # Set default branch [init] defaultBranch = xxx
            init = {
              defaultBranch = "main";
            };
            # Set default editor
            core = {
              editor = "nvim";
            };
            # Automatically setup remote
            push = {
              autoSetupRemote = true;
            };

          };

          includes = [

          ]
          ++ builtins.map (cfg: {
            condition = cfg.condition;
            contents = cfg.contents;
          }) cfg.includes;

        };

      };
    };
}
