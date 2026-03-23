{ inputs, self, ... }:

{
  flake.modules.nixos.user_deploy =
    {
      config,
      lib,
      pkgs,
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
