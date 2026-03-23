{ ... }:
{
  flake.modules.nixos.core =
    {
      config,
      lib,
      ...
    }:
    {
      config = {
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

        services.fail2ban.enable = true;
      };
    };
}
