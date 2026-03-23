{ inputs, self, ... }:

{
  flake.nixosModules.user_tyron =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.myNixos.users.tyron;
    in
    {
      #options.users.users.tyron.enable = lib.mkEnableOption "tyron user";
      options.myNixos.users.tyron.enable = lib.mkEnableOption "tyron user";

      config = lib.mkIf cfg.enable {
        users.users.tyron = {
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
          hashedPasswordFile = config.sops.secrets."tyron/password".path;
          # openssh.authorizedKeys.keys = [
          #   "ssh-ed25519 AAAA... tyron@yoga"
          # ];
          openssh.authorizedKeys.keyFiles = [ config.sops.secrets."tyron/ssh/public_key".path ];
        };

        programs.zsh.enable = true;

        sops.secrets."tyron/password" = {
          sopsFile = ./secrets/secrets.yaml;
          neededForUsers = true;
          owner = "tyron";
        };
      };
    };
}
