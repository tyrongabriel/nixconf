{ self, ... }:
{
  flake.modules.nixos.host_droplet =
    { ... }:
    {
      imports = [
        self.modules.nixos.tailscale
      ];

      networking.useDHCP = true;
      # networking.nameservers = [
      #   "2606:4700:4700::1111"
      #   "1.1.1.1" # Cloudflare's public DNS
      #   "9.9.9.9" # Quad9 DNS
      # ];
      #
      networking.useNetworkd = true;

      systemd.network.networks."10-wan" = {
        matchConfig.Name = "eth0";
        address = [
          "YOUR_PUBLIC_IP/20" # e.g., 104.248.x.x/20
          "YOUR_IPV6_ADDRESS/64"
        ];
        routes = [
          { Gateway = "YOUR_IPV4_GATEWAY"; }
          { Gateway = "YOUR_IPV6_GATEWAY"; }
        ];
        # DigitalOcean DNS
        networkConfig.DNS = [
          "67.207.67.2"
          "67.207.67.3"
        ];
      };

      #networking.interfaces.eth0 = {
      # # Set this to false to ensure no DHCP is used for this interface
      # #useDHCP = true; # Cloud providers dont give dhcp!!
      #   # Configure the IPv4 address and subnet mask
      #   ipv4.addresses = [
      #     {
      #       address = "164.92.163.68";
      #       prefixLength = 20;
      #     }
      #     {
      #       address = "10.19.0.5";
      #       prefixLength = 16;
      #     }
      #   ];
      #   # Configure the IPv6 address and prefix length
      #   ipv6.addresses = [
      #     {
      #       address = "2a03:b0c0:3:f0:0:2:3129:9000"; # CHOOSE YOUR HOST ADDRESS in the subnet
      #       prefixLength = 64; # Your subnet's prefix length
      #     }
      #   ];
      # };

      # # Set the default gateway
      # networking.defaultGateway = {
      #   address = "164.92.160.1";
      #   interface = "eth0";
      # };
      # networking.defaultGateway6 = {
      #   address = "2a03:b0c0:3:f0::1"; # Your VPS's provided gateway
      #   interface = "eth0";
      # };
    };
}
