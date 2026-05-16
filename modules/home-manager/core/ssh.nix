{ self, ... }:
{
  flake.modules.homeManager.core =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.ssh;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.ssh = with lib; {
        enable = mkEnableOption "Enable SSH configuration";
        customConfig = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Custom SSH configuration text that is written to ~/.ssh/config_custom and included into ssh.";
        };
        matchBlocks = lib.mkOption {
          type = lib.types.attrsOf (lib.types.attrs);
          default = { };
          example = {
            "*" = {
              identityFile = "~/.ssh/id_ed25519";
              setEnv = {
                TERM = "xterm-256color";
              };
            };
          };
          description = "SSH match blocks to be included in the SSH configuration.";
        };
      };
      config = mkIf cfg.enable {
        # Your configuration here
        home.file.".ssh/config_custom".text = cfg.customConfig;
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          includes = [ "~/.ssh/config_custom" ];
          matchBlocks = {
            "*" = {
              identityFile = "~/.ssh/id_ed25519";
              setEnv = {
                TERM = "xterm-256color";
              };
            };
          }
          // cfg.matchBlocks;
        };

      };
    };
}
