{ inputs, self, ... }:

{
  flake.nixosModules.user_builder =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.myNixos.users.builder;
    in
    {
      #options.users.users.builder.enable = lib.mkEnableOption "builder user";
      options.myNixos.users.builder.enable = lib.mkEnableOption "builder user";

      config = lib.mkIf cfg.enable {
        users.users.builder = {
          isSystemUser = true;
          uid = 901;
          description = "Distributed build user";
          shell = pkgs.bash;
          group = "builder";
          home = "/var/lib/builder";
          createHome = true;
        };

        users.groups.builder.gid = 901;

        nix.settings.trusted-users = [ "builder" ];
      };
    };
}
