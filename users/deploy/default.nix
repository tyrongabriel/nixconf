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

            # legion
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBqmSrL50wt06SvVxM3e/BK62SeOQk37/qR7MWhC3lp1AAAABHNzaDo= tyron@legion" # yelen
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN/+Vj/gR3pP/Y1vctxiNOgOosnH3edSG6vTmxoPrCPxAAAABHNzaDo= tyron@legion" # yusuf
            # Yoga
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAII3eGSG9pGTvpXhFO2veBym9PSucRniOr4xQdis2gvkSAAAABHNzaDo= tyron@yoga"
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB91FdHgHdNIc6W6AKeSGSRpg9aNJkpXfCYL2Ogv9Iy2AAAABHNzaDo= tyron@yoga"

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
