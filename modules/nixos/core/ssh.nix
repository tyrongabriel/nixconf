{ ... }:
{
  flake.modules.nixos.core =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.ssh;
    in
    with lib;
    {
      options = {
        myNixos.ssh = {
          enable = mkEnableOption "Enable SSH server";
          fail2ban = mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable fail2ban for SSH";
          };
        };
      };
      config = mkIf cfg.enable {
        assertions = [
          {
            assertion = lib.any (
              user:
              (user.openssh.authorizedKeys.keys or [ ]) != [ ]
              || (user.openssh.authorizedKeys.keyFiles or [ ]) != [ ]
            ) (lib.attrValues config.users.users);
            message = "No users have authorized SSH keys configured for machine ${config.networking.hostName}! You will be locked out of SSH.";
          }
        ];
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
          };
        };
        services.fail2ban.enable = if cfg.fail2ban then (mkDefault true) else mkDefault false;
      };
    };
}
