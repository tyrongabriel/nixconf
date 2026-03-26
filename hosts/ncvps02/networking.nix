{ self, ... }:
{
  flake.modules.nixos.host_ncvps02 =
    { ... }:
    {
      imports = [

      ];

      networking.useDHCP = true;
      #networking.useNetworkd = true;

      # systemd.network.networks."10-wan" = {
      #   matchConfig.Name = "eth0";
      #   address = [
      #     # v4
      #     #     "159.195.9.89/22"
      #     #     # v6
      #     #     "2a0a:4cc0:ff:505::/64"
      #     #   ];
      #   routes = [
      #     # v4
      #     #     { Gateway = "159.195.8.1"; }
      #     #     # v6
      #     #     { Gateway = "fe80::1"; }
      #     #   ];
      #   networkConfig.DNS = [
      #     #     "1.1.1.1"
      #     #     "1.0.0.1"
      #     #   ];
      # };

      networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"

      ];
      networking.interfaces.eth0 = {
        # Set this to false to ensure no DHCP is used for this interface
        #useDHCP = true; # Cloud providers dont give dhcp!!
        # Configure the IPv4 address and subnet mask
        ipv4.addresses = [
          {
            address = "159.195.9.89";
            prefixLength = 22;
          }

        ];
        # Configure the IPv6 address and prefix length
        ipv6.addresses = [
          {
            address = "2a0a:4cc0:ff:505::";
            prefixLength = 64;
          }

        ];
      };

      # Set the default gateway
      networking.defaultGateway = {
        address = "159.195.8.1";
        interface = "eth0";
      };
      networking.defaultGateway6 = {
        address = "fe80::1";
        interface = "eth0";
      };
    };
}
