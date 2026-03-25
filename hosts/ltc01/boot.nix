{ ... }:
{
  flake.modules.nixos.host_ltc01=
    { lib, ... }:
    {
      ## Boot Config ##
      boot = {
        #kernelPackages = pkgs.linuxPackages_latest;
        supportedFilesystems = lib.mkForce [ "btrfs" ]; # Force support for my used filesystem

        ## Bootloader ##
        # TODO: Fit into a module!
        loader.grub = {
          # no need to set devices, disko will add all devices that have a EF02 partition to the list already
          # devices = [ ];
          # device = "nodev"; # No specific partition
          # useOSProber = true; # Autodetect windows
          efiSupport = true;
          efiInstallAsRemovable = true;
        };
      };
    };
}
