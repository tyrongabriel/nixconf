{ ... }:
{
  flake.modules.homeManager.core =
    {
      lib,
      ...
    }:
    with lib;
    {
      imports = [
        #inputs.sops-nix.homeManagerModules.sops
      ];
      options.myHome.core.sops = with lib; {
        enable = mkEnableOption "Enable sops";
      };
      config = {
        # Your configuration here
        # would need to find a way to avoid using machine ssh key, as users dont have perms!

        # sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        # sops.defaultSopsFile = "${self.outPath}/hosts/${osConfig.networking.hostName}/secrets/secrets.yaml";
      };
    };
}
