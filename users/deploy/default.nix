{ inputs, self, ... }:

{
  flake.nixosModules.user_deploy =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.myNixos.users.deploy;
    in
    {
      options.myNixos.users.deploy.enable = lib.mkEnableOption "deploy user";

      config = lib.mkIf cfg.enable {
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
