{ ... }:
{
  flake.modules.nixos.gaming =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.desktop.gaming;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.desktop.gaming = with lib; {
        enable = mkEnableOption "Enable gaming";
      };
      config = mkIf cfg.enable {
        # Your configuration here
        programs.steam.enable = mkForce true;

        hardware.graphics.enable = mkForce true;
        # Vulkan support (required for many Proton games)
        environment.systemPackages = with pkgs; [
          vulkan-loader
          libvdpau
          jdk25
        ];
      };
    };
}
