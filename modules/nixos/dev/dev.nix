{ self, ... }:
{
  flake.modules.nixos.dev =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.development;
      selfPkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.development = with lib; {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable development configuration";
        };
      };
      config = mkIf cfg.enable {

        environment.systemPackages = with pkgs; [
          selfPkgs.ox
          selfPkgs.iburg
          selfPkgs.bfe
        ];
      };
    };
}
