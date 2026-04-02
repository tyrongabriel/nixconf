{ self, ... }:
{
  flake.modules.nixos.libvirtd =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.libvirtd;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.libvrt = with lib; {
        #enable = mkEnableOption "Enable libvirtd";
      };
      config = {
        virtualisation.libvirtd = {
          enable = true;
          #onBoot = "start"; # start|ignore -> start lets all guests run no matter autostart
        };
        programs.dconf.enable = lib.mkDefault true;

        systemd.tmpfiles.rules = [
          "d /var/lib/libvirt/images 0770 root libvirtd -"
        ];

        boot.kernelModules = [
          "kvm-intel"
          "kvm-amd"
          "bridge"
          "tap"
          "tun"
        ];
      };
    };
}
