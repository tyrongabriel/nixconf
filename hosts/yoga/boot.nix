{ ... }:
{
  flake.modules.nixos.host_yoga =
    { lib, ... }:
    {
      ## Boot Config ##
      networking.dhcpcd.wait = "background"; # makes boot faster by not waiting for network
      ## Boot Config ##
      boot = {
        supportedFilesystems = lib.mkForce [ "btrfs" ];

        ## Bootloader ##
        loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot = {
            enable = true;
            configurationLimit = 10;
          };
          timeout = 0; # Skip boot menu — hold key at boot to show
        };

        ## Kernel ##
        initrd = {
          availableKernelModules = [
            "xhci_pci"
            "ahci"
            "nvme"
            "usb_storage"
            "sd_mod"
            "rtsx_pci_sdmmc"
          ];
          systemd.enable = true; # Parallel initrd for faster boot
        };

        kernelModules = [
          "kvm-amd"
          "amdgpu"
        ];

        kernelParams = [
          "quiet"
          "loglevel=0"
          "rd.systemd.show_status=0"
          "rd.udev.log_level=0"
          "udev.log_level=0"
          "vt.global_cursor_default=0"
        ];

        consoleLogLevel = 0;

        ## Plymouth splash — clean transition from OEM splash to desktop ##
        plymouth.enable = true;
      };
    };
}
