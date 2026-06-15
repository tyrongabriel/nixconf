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

            # Yubikeys
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsJ5MFDfXhkemPUaDDL2Ozkxj8m+90+HYs80om11q7ZAAAACXNzaDp5dXN1Zg== tyron@yusuf"
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIC0zX/W36xFcPSeDnhJKZrOaWUeKIXkDFA+i/IZpRrXGAAAACXNzaDp5ZWxlbg== tyron@yelen"
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
