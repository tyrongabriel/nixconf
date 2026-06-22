{ ... }:
{
  flake.modules.nixos.core =
    {
      config,
      lib,
      pkgs,
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
        programs.ssh.askPassword = "${pkgs.openssh-askpass}/libexec/gtk-ssh-askpass";
        programs.ssh.enableAskPassword = true;
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
          };
          openFirewall = true;
        };

        services.gnome.gcr-ssh-agent.enable = false; # conflicts if i have gnome keyring enabled
        programs.ssh.startAgent = false; # doesnt work with yubikeys

        # Ensure the seahorse package is available
        environment.systemPackages = [
          pkgs.seahorse
        ];

        services.fail2ban.enable = if cfg.fail2ban then (mkDefault true) else mkDefault false;
      };
    };
}
