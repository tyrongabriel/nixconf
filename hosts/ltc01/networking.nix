{ self, ... }:
{
  flake.modules.nixos.host_ltc01 =
    { ... }:
    {
      imports = [

      ];

      networking.useDHCP = true;
      networking.interfaces.enp0s31f6 = {
        # Set this to false to ensure no DHCP is used for this interface
        useDHCP = true;

        wakeOnLan = {
          enable = true;
          policy = [ "magic" ];
        };
      };

      networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"

      ];
    };
}
