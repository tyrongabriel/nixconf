{ self, ... }:
{
  flake.modules.nixos.server =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.server;
    in
    with lib;
    {
      imports = [
        # Servers should import their specific stuff!
        # Saves on eval time
      ];
      options.myNixos.server = with lib; {
        #enable = mkEnableOption "Enable server";
      };
      config = {
        myNixos = {
          # Servers must! enable ssh
          ssh = {
            enable = mkForce true;
            fail2ban = mkForce true;
          };
        };
      };
    };
}
