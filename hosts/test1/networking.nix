{ self, ... }:
{
  flake.modules.nixos.host_test1 =
    { ... }:
    {
      imports = [
        self.modules.nixos.tailscale

      ];

      networking.useDHCP = true;
      #networking.useNetworkd = true;

      # systemd.network.networks."10-wan" = {
      #   matchConfig.Name = "eth0";
      #   address = [
      #     # v4
      #     #     "64.226.108.218/20"
      #     #     # v6
      #     #     "2a03:b0c0:3:f0:0:2:3211:2000/64"
      #     #   ];
      #   routes = [
      #     # v4
      #     #     { Gateway = "64.226.96.1"; }
      #     #     # v6
      #     #     { Gateway = "2a03:b0c0:3:f0::1"; }
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
            address = "64.226.108.218";
            prefixLength = 20;
          }

        ];
        # Configure the IPv6 address and prefix length
        ipv6.addresses = [
          {
            address = "2a03:b0c0:3:f0:0:2:3211:2000";
            prefixLength = 64;
          }

        ];
      };

      # Set the default gateway
      networking.defaultGateway = {
        address = "64.226.96.1";
        interface = "eth0";
      };
      networking.defaultGateway6 = {
        address = "2a03:b0c0:3:f0::1";
        interface = "eth0";
      };
    };
}
