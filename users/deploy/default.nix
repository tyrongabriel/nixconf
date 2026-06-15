{ ... }:

{
  flake.modules.nixos.user_deploy =
    {
      pkgs,
      ...
    }:
    {
      config = {
        users.users.deploy = {
          isSystemUser = true;
          uid = 900;
          description = "Colmena deploy user";
          shell = pkgs.bash;
          group = "deploy";
          extraGroups = [
            "wheel"
            "libvirtd"
            "kvm"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBY2DkFamhhD8nnS8zqCnJRMD2GKvmiV9QQk+1dfA/Z tyron@legion"

            # Yubikeys
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsJ5MFDfXhkemPUaDDL2Ozkxj8m+90+HYs80om11q7ZAAAACXNzaDp5dXN1Zg== tyron@yusuf"
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIC0zX/W36xFcPSeDnhJKZrOaWUeKIXkDFA+i/IZpRrXGAAAACXNzaDp5ZWxlbg== tyron@yelen"

          ];
        };

        users.groups.deploy.gid = 900;

        security.sudo.extraRules = [
          {
            users = [ "deploy" ];
            commands = [
              {
                command = "ALL";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];
      };
    };
}
