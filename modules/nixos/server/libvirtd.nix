{ ... }:
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
        enable = mkEnableOption "Enable libvirtd";
      };
      config = mkIf cfg.enable {
        virtualisation.libvirtd = {
          enable = true;
          #onBoot = "start"; # start|ignore -> start lets all guests run no matter autostart
        };
        programs.dconf.enable = lib.mkDefault true;

        systemd.tmpfiles.rules = [
          "d /var/lib/libvirt/images 0770 root libvirtd -"
        ];

        # So guests can talk
        boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

        environment.systemPackages = with pkgs; [
          virt-manager # The GUI for managing VMs
          qemu # The emulator
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
