{ ... }:

{
  flake.modules.nixos.user_deploy =
    {
      pkgs,
      config,
      ...
    }:
    {
      config = {
        users.users.deploy = {
          isSystemUser = true;
          uid = 900;
          description = "Colmena deploy user";
          shell = pkgs.bash;
          group = "deploy";
          extraGroups = [ "wheel" ];
          openssh.authorizedKeys.keyFiles = [ config.sops.secrets."tyron/ssh/public_key".path ];
        };

        users.groups.deploy.gid = 900;

        security.sudo.extraRules = [
          {
            users = [ "deploy" ];
            commands = [
              {
                command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild *";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];
      };
    };
}
