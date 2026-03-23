{ ... }:
{
  flake.modules.nixos.host_droplet =
    { ... }:
    {
      networking.nameservers = [
        "2606:4700:4700::1111"
        "8.8.8.8" # Google's public DNS
        "8.8.4.4" # Google's public DNS
        "1.1.1.1" # Cloudflare's public DNS
        "9.9.9.9" # Quad9 DNS
      ];
      networking.interfaces.eth0 = {
        # Set this to false to ensure no DHCP is used for this interface
        useDHCP = true;
        # Configure the IPv4 address and subnet mask
        ipv4.addresses = [
          {
            address = "209.38.235.240";
            prefixLength = 19;
          }
          {
            address = "10.19.0.5";
            prefixLength = 16;
          }
        ];
        # Configure the IPv6 address and prefix length
        ipv6.addresses = [
          {
            address = "2a03:b0c0:3:f0:0:2:30b4:9000"; # CHOOSE YOUR HOST ADDRESS in the subnet
            prefixLength = 64; # Your subnet's prefix length
          }
        ];
      };

      # Set the default gateway
      networking.defaultGateway = {
        address = "209.38.224.1";
        interface = "eth0";
      };
      networking.defaultGateway6 = {
        address = "2a03:b0c0:3:f0::1"; # Your VPS's provided gateway
        interface = "eth0";
      };
    };
}
