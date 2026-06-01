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
            "disk"
            "storage"
          ];
          #initialPassword = "password";
          hashedPasswordFile = config.sops.secrets."tyron/password_hash".path;

          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBY2DkFamhhD8nnS8zqCnJRMD2GKvmiV9QQk+1dfA/Z tyron@legion"

            # Legion Tyron
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBqmSrL50wt06SvVxM3e/BK62SeOQk37/qR7MWhC3lp1AAAABHNzaDo= tyron@legion" # yelen
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN/+Vj/gR3pP/Y1vctxiNOgOosnH3edSG6vTmxoPrCPxAAAABHNzaDo= tyron@legion" # yusuf
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
