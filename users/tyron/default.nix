{ ... }:
let
  username = "tyron";
in
{
  flake.modules.nixos.user_tyron =
    {
      config,
      pkgs,
      ...
    }:
    {

      config = {
        users.users.${username} = {
          isNormalUser = true;
          uid = 3801;
          description = "Tyron";
          shell = pkgs.zsh;
          group = "users";
          extraGroups = [
            "wheel"
            "networkmanager"
            "video"
            "audio"
            "input"
            "kvm"
            "docker"
          ];
          #initialPassword = "password";
          hashedPasswordFile = config.sops.secrets."tyron/password_hash".path;

          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com"
          ];
        };

        programs.zsh.enable = true;

        sops.secrets."tyron/password_hash" = {
          sopsFile = ../../secrets/secrets.yaml;
          key = "tyron/password_hash";
          neededForUsers = true;
          #owner = "tyron";
        };

        # sops.secrets."tyron/ssh/public_key" = {
        #   sopsFile = ./secrets/secrets.yaml;
        #   mode = "0444";
        # };
      };
    };
}
