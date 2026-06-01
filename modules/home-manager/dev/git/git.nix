{ ... }:
{
  flake.modules.homeManager.git =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.myHome.development.git;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.development.git = with lib; {
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

      config = mkIf cfg.enable {
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

        programs.lazygit.enable = true;
        # Enable github cli
        programs.gh.enable = true;

        # Configure ssh to use the right keys
        myHome.ssh = {
          matchBlocks = {
            "github.com" = {
              IdentityFile = "~/.ssh/id_ed25519";
              User = "git";
              IdentitiesOnly = true;
            };
          };
        };
      };
    };
}
