{ self, ... }:
{
  flake.modules.homeManager.ssh =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.ssh;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.ssh = with lib; {
        customConfig = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Custom SSH configuration text that is written to ~/.ssh/config_custom and included into ssh.";
        };
      };
      config = {
        # Your configuration here
        home.file.".ssh/config_custom".text = cfg.customConfig;

      };
    };
}
