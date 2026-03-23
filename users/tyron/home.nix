{ self, ... }:
let
  username = "tyron";
in
{
  flake.modules.nixos.user_tyron =
    { lib, config, ... }:
    let
      cfg = config.myNixos.users.${username};
    in
    {
      options.myNixos.users.${username}.homeManager = {
        enable = lib.mkEnableOption "Enable Home Manager";
        tags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "List of tags to enable user-specific home manager modules";
        };
      };

      config = lib.mkIf cfg.homeManager.enable {
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
            };
            programs.home-manager.enable = true;

            imports = [
              self.modules.homeManager.core
            ]
            ++ (map (tag: (tagImport tag)) cfg.homeManager.tags);
            # ++ lib.optionals (lib.elem "dev" cfg.tags) [
            #   self.modules.homeManager.dev
            # ];

          };
      };
    };
}
