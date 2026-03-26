{ self, ... }:
{
  flake.modules.nixos.host_hp01 =
    { ... }:
    {
      imports = [

      ];

      networking.useDHCP = true;
      networking.interfaces.eno1 = {
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
