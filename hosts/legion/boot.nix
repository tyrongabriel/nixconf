{ ... }:
{
  flake.modules.nixos.host_legion =
    { config, lib, ... }:
    with lib;
    {
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
          "kvm-intel"
          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm"
        ];

        kernelParams = [
          "quiet"
          "loglevel=0"
          "rd.systemd.show_status=0"
          "rd.udev.log_level=0"
          "udev.log_level=0"
          "vt.global_cursor_default=0"
          "nvidia-drm.modeset=1"
        ];

        consoleLogLevel = 0;

        ## Plymouth splash — clean transition from OEM splash to desktop ##
        plymouth.enable = true;
      };

      ## CPU ##
      hardware.cpu.intel.updateMicrocode = true;

      ## NVIDIA RTX 2060 ##
      hardware.nvidia = {
        modesetting.enable = true;
        open = false; # Proprietary driver for RTX 2060 (Turing)
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;

        ## Hybrid offload — Intel iGPU for desktop, NVIDIA on demand ##
        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
          # Verify on hardware: lspci | grep -E 'VGA|3D'
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };

        ## Power down dGPU when idle ##
        powerManagement = {
          enable = true;
          finegrained = true;
        };
      };

      ## Unfree for NVIDIA proprietary driver ##
      nixpkgs.config.allowUnfree = mkForce true;

      ## Video driver priority ##
      services.xserver.videoDrivers = [ "nvidia" ];
    };
}
