{ self, inputs, ... }:
{
  flake.modules.nixos.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop;
    in
    with lib;
    {
      imports = [
        inputs.nix-index-database.nixosModules.nix-index
      ];
      options.myNixos.desktop = with lib; {
        #enable = mkEnableOption "Enable desktop";
      };
      config = {
        # Your configuration here
        programs.nix-index-database.comma.enable = true;

      };
    };
}
