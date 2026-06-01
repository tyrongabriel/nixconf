{ self, ... }:
let
  username = "tyron";
in
{
  flake.modules.nixos.user_tyron =
    { lib, config, ... }:
    let
      cfg = config.myNixos.users.${username}.homeManager;
    in
    {
      options.myNixos.users.${username}.homeManager = {
        enable = lib.mkEnableOption "Enable Home Manager";
        tags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "List of tags to enable user-specific home manager modules";
        };
        extraImports = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [ ];
          example = [ self.modules.homeManager.dev ];
          description = "Extra home manager modules to import for this user";
        };
      };

      config = lib.mkIf cfg.enable {
        home-manager.users.${username} =
          {
            osConfig,
            ...
          }:
          let
            tagImport =
              tag: self.modules.homeManager.${tag} or (throw "Unknown tag: ${tag} for user ${username}");
          in
          {
            home = {
              username = username;
              homeDirectory = "/home/${username}";
              stateVersion = osConfig.system.stateVersion;
              sessionVariables = {
                SOPS_AGE_KEY_FILE = "/home/${username}/.config/sops/age/keys.txt";
              };
            };
            programs.git.settings.user = {
              name = "tyrongabriel";
              email = "51530686+tyrongabriel@users.noreply.github.com";
            };

            programs.home-manager.enable = true;
            imports = [
              self.modules.homeManager.core
            ]
            ++ (map (tag: (tagImport tag)) cfg.tags)
            ++ cfg.extraImports;
            # ++ lib.optionals (lib.elem "dev" cfg.tags) [
            #   self.modules.homeManager.dev
            # ];

          };
      };
    };
}
