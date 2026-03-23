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
          uid = 3001;
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
          initialPassword = "password";
          #hashedPasswordFile = config.sops.secrets."tyron/password".path;
          # openssh.authorizedKeys.keys = [
          #   "ssh-ed25519 AAAA... tyron@yoga"
          # ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com"
          ];
        };

        programs.zsh.enable = true;

        sops.secrets."tyron/password" = {
          sopsFile = ./secrets/secrets.yaml;
          key = "tyron/password";
          neededForUsers = true;
          #owner = "tyron";
        };

        sops.secrets."tyron/ssh/public_key" = {
          sopsFile = ./secrets/secrets.yaml;
          mode = "0444";
        };
      };
    };
}
