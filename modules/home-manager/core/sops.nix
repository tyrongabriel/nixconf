{ inputs, ... }:
{
  flake.modules.homeManager.core =
    {
      lib,
      config,
      osConfig ? { },
      ...
    }:
    with lib;
    let
      username = config.home.username;
      sopsUserCfg = osConfig.myNixos.sops.users.${username} or null;
    in
    {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];
      options.myHome.core.sops = with lib; {
        enable = mkEnableOption "Enable sops";
      };
      config = {
        sops = {
          age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
          defaultSopsFile = mkIf (
            sopsUserCfg != null && sopsUserCfg.sopsSecretsFile != null
          ) sopsUserCfg.sopsSecretsFile;
        };
      };
    };
}
