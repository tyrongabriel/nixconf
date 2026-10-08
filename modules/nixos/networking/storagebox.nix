{ ... }:
{
  flake.modules.nixos.storagebox =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.myNixos.storagebox;

      # Resolve uid/gid either from explicit numbers or from the configured user
      uid =
        if cfg.uid != null then
          cfg.uid
        else if cfg.user != null then
          config.users.users.${cfg.user}.uid
        else
          null;
      gid =
        if cfg.gid != null then
          cfg.gid
        else if cfg.user != null then
          config.users.groups.${config.users.users.${cfg.user}.group}.gid
        else
          null;

      ownershipOptions =
        lib.optionals (uid != null) [ "uid=${toString uid}" ]
        ++ lib.optionals (gid != null) [ "gid=${toString gid}" ];
    in
    with lib;
    {
      options.myNixos.storagebox = with lib; {
        enable = mkEnableOption "Hetzner Storage Box SMB (CIFS) mount via sops-managed credentials";

        server = mkOption {
          type = types.str;
          default = "";
          description = ''
            Hostname of the storage box, e.g. "u123456.your-storagebox.de".
            For sub-accounts, the endpoint is the sub-account name, e.g.
            "u123456-sub1.your-storagebox.de".
          '';
        };

        share = mkOption {
          type = types.str;
          default = "backup";
          description = "Share name. Hetzner Storage Boxes always expose ''backup''.";
        };

        mountPoint = mkOption {
          type = types.str;
          default = "/mnt/storagebox";
          description = "Mount point for the share.";
        };

        user = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Local user that owns the mount (uid/gid are derived automatically).
            Set to null for a root-owned, world-visible mount.
          '';
        };

        uid = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Explicit uid override for the mount. Takes precedence over ''user''.";
        };

        gid = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Explicit gid override for the mount. Takes precedence over ''user''.";
        };

        protocolVersion = mkOption {
          type = types.str;
          default = "3.0";
          description = "SMB protocol version. Hetzner documents vers=3.0; try 3.1.1 if 3.0 is rejected.";
        };

        idleTimeout = mkOption {
          type = types.str;
          default = "600s";
          description = ''
            Autounmount idle timeout (systemd time span). Only used when autoMount is enabled.
          '';
        };

        autoMount = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Mount on first access (automount unit) and unmount when idle, instead of mounting
            at boot. Survives network outages; the boot-time variant would not.
          '';
        };

        usernameSecret = mkOption {
          type = types.str;
          default = "storagebox/username";
          description = "sops secret key holding the storage box username.";
        };

        passwordSecret = mkOption {
          type = types.str;
          default = "storagebox/password";
          description = "sops secret key holding the storage box password.";
        };

        sopsFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = ''
            Explicit sops file for the credentials secrets. When null, the host's
            sops.defaultSopsFile (myNixos.sops.sopsFile) is used.
          '';
        };

        extraMountOptions = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [
            "file_mode=0660"
            "dir_mode=0770"
          ];
          description = "Additional options passed to mount.cifs.";
        };
      };

      config = mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.server != "";
            message = "myNixos.storagebox.server must be set (e.g. u123456.your-storagebox.de).";
          }
          {
            assertion = cfg.user == null || config.users.users ? ${cfg.user};
            message = "myNixos.storagebox.user = \"${cfg.user}\" does not exist.";
          }
        ];

        # Declare both secrets. When cfg.sopsFile is null they decrypt from the
        # host's sops.defaultSopsFile; otherwise the explicit file overrides it.
        sops.secrets = {
          ${cfg.usernameSecret}.sopsFile = mkIf (cfg.sopsFile != null) cfg.sopsFile;
          ${cfg.passwordSecret}.sopsFile = mkIf (cfg.sopsFile != null) cfg.sopsFile;
        };

        # Rendered credentials file for mount.cifs (default owner root, 0400).
        # Placeholder interpolation embeds the decrypted secret VALUES into the template.
        sops.templates."storagebox-credentials" = {
          content = ''
            username=${config.sops.placeholder.${cfg.usernameSecret}}
            password=${config.sops.placeholder.${cfg.passwordSecret}}
          '';
          owner = "root";
        };

        environment.systemPackages = [ pkgs.cifs-utils ];

        boot.supportedFilesystems = [ "cifs" ];

        fileSystems.${cfg.mountPoint} = {
          device = "//${cfg.server}/${cfg.share}";
          fsType = "cifs";
          options = [
            "credentials=${config.sops.templates."storagebox-credentials".path}"
            "vers=${cfg.protocolVersion}"
            "iocharset=utf8"
            "_netdev"
            "nofail"
          ]
          ++ optionals cfg.autoMount [
            "x-systemd.automount"
            "x-systemd.idle-timeout=${cfg.idleTimeout}"
          ]
          ++ ownershipOptions
          ++ cfg.extraMountOptions;
        };
      };
    };
}
