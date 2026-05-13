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
        self.modules.nixos.sddm
        self.modules.nixos.niri
        self.modules.nixos.greetd
        self.modules.nixos.cosmic
        self.modules.nixos.stylix
      ];
      options.myNixos.desktop = with lib; {
        #enable = mkEnableOption "Enable desktop";
      };
      config = {
        # Your configuration here
        programs.nix-index-database.comma.enable = true;

        myNixos.desktop = {
          #cosmic.enable = true;
          greetd = {
            enable = mkDefault true;
          };
          niri = {
            enable = mkDefault true;
          };
        };

        environment.systemPackages = with pkgs; [
          # Add desktop-specific packages here
          kitty
        ];

      };
    };
}
