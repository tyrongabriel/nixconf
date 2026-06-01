{ ... }:
{
  flake.modules.homeManager.apps =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.apps.yubico.ssh-keys;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.apps.yubico.ssh-keys = with lib; {
        enable = mkEnableOption "Enable yubico.ssh-keys";
        yubiKeys = mkOption {
          type = lib.types.listOf (lib.types.str);
          default = [ ];
          description = "List of YubiKeys, which need a corresponding secret in the given secret file";
        };
        secretPrefix = mkOption {
          type = lib.types.str;
          default = "ssh_keys";
          description = "Prefix path within the secret file where the SSH keys are stored";
        };
      };
      config = mkIf cfg.enable {
        sops.secrets = lib.foldl' (
          acc: yubikey:
          acc
          // {
            "${cfg.secretPrefix}/${yubikey}/private" = {
              path = "${config.home.homeDirectory}/.ssh/id_${yubikey}";
            };
            "${cfg.secretPrefix}/${yubikey}/public" = {
              path = "${config.home.homeDirectory}/.ssh/id_${yubikey}.pub";
            };
          }
        ) { } cfg.yubiKeys;
      };

    };
}
