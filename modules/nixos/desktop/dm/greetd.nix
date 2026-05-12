{ self, ... }:
{
  flake.modules.nixos.greetd =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop.greetd;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.desktop.greetd = with lib; {
        enable = mkEnableOption "Enable greetd";
      };
      config = mkIf cfg.enable {
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${config.programs.niri.package}/bin/niri-session";
              user = "tyron";
            };
          };
        };
      };
    };
}
