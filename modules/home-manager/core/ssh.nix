{ ... }:
{
  flake.modules.homeManager.core =
    {
      config,
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
        useYubiKey = mkEnableOption "Use YubiKey for SSH authentication, which will set the default IdentityFile to ~/.ssh/id_yubikey instead of ~/.ssh/id_ed25519.";
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
          # needed for yubikey-agent
          extraConfig = ''
            AddKeysToAgent yes
          '';
          includes = [ "~/.ssh/config_custom" ];
          settings = {
            "*" = {
              IdentityFile = if config.myHome.ssh.useYubiKey then "~/.ssh/id_yubikey" else "~/.ssh/id_ed25519";
              SetEnv = {
                TERM = "xterm-256color";
              };
            };
          }
          // cfg.matchBlocks;
        };

      };
    };
}
