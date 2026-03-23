{ ... }:

{
  flake.modules.nixos.user_builder =
    {
      pkgs,
      ...
    }:
    {
      config = {
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
