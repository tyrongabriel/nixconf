{ ... }:
{
  flake.modules.nixos.core =
    {
      inputs,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.myNixos.sops;
    in
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      options.myNixos.sops = {
        sopsFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Path to the host's secrets.yaml file";
        };
        users = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                sopsSecretsFile = lib.mkOption {
                  type = lib.types.nullOr lib.types.path;
                  default = null;
                  description = "Path to the user's per-host secrets file";
                };
              };
            }
          );
          default = { };
          description = "Users with sops secret files";
        };
      };

      config = {
        # Use SSH host key for system-level secret decryption
        sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

        # Set the default sops file to the host's secrets (when configured)
        sops.defaultSopsFile = lib.mkIf (cfg.sopsFile != null) cfg.sopsFile;

        # Pre-create the user's .config directory with the right permissions, fails otherwise since
        # .config will be owned by root!!!!!
        systemd.tmpfiles.rules = lib.mapAttrsToList (
          username: _userCfg:
          "d /home/${username}/.config 0700 ${username} ${config.users.users.${username}.group} - -"
        ) cfg.users;

        # Deploy each user's age private key to their home directory
        # This allows home-manager sops to decrypt user-specific secrets
        sops.secrets = lib.mkMerge (
          lib.mapAttrsToList (username: _userCfg: {
            "age_keys/${username}/private" = lib.mkIf (cfg.sopsFile != null) {
              sopsFile = cfg.sopsFile;
              path = "/home/${username}/.config/sops/age/keys.txt";
              owner = config.users.users.${username}.name;
              group = if pkgs.stdenv.isLinux then config.users.users.${username}.group else "staff";
              key = "age_keys/${username}/private";
            };
          }) cfg.users
        );
      };
    };
}
