{ ... }:
{
  flake.modules.homeManager.core =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.myHome.ssh;
      # Names of SSH keypairs in the global secrets/secrets.yaml under ssh_keys.<name>
      sshKeyNames = [
        "ml-sec"
      ];
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
        home.file.".ssh/config_custom".text = cfg.customConfig;

        # Place SSH keypairs from the global secrets file into ~/.ssh as id_<name>/.pub
        sops.secrets = lib.foldl' (
          acc: name:
          acc
          // {
            "ssh_keys/${name}/private" = {
              path = "${config.home.homeDirectory}/.ssh/id_${name}";
              mode = "0600";
            };
            "ssh_keys/${name}/public" = {
              path = "${config.home.homeDirectory}/.ssh/id_${name}.pub";
              mode = "0644";
            };
          }
        ) { } sshKeyNames;

        services.ssh-agent.enable = false;

        # The systemd-managed ssh-agent can't find ssh-sk-helper at signing time.
        # Explicitly point it to the FIDO2 security key helper binary.
        systemd.user.services.ssh-agent.Service.Environment = [
          "SSH_SK_HELPER=${pkgs.openssh}/libexec/ssh-sk-helper"
        ];
        programs.ssh = {
          enable = true;

          enableDefaultConfig = false;
          # needed for yubikey-agent
          # extraConfig = ''
          #   AddKeysToAgent yes
          # '';
          includes = [
            "~/.ssh/config_custom"
            "~/.ssh/config_stateful"
          ];
          settings = {
            "*" = {
              IdentityFile = if config.myHome.ssh.useYubiKey then "~/.ssh/id_yubikey" else "~/.ssh/id_ed25519";
              SetEnv = {
                TERM = "xterm-256color";
              };
              addKeysToAgent = "yes";
            };
            "mlsec.hackthe.space" = {
              IdentityFile = "~/.ssh/id_ml-sec";
            };
          }
          // cfg.matchBlocks;
        };

      };
    };
}
