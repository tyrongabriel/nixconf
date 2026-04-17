{ self, ... }:
{
  flake.modules.nixos.host_ncvps01 =
    { ... }:
    {
      imports = [
        self.modules.nixos.adguard
      ];

      myNixos.adguard = {
        enable = true;
        netbirdIp = "100.64.100.154";
        webUiPort = 3000;
        netbird-interface = "nb-home";
      };

      networking.useDHCP = true;
      #networking.useNetworkd = true;

      # systemd.network.networks."10-wan" = {
      #   matchConfig.Name = "ens3";
      #   address = [
      #     # v4
      #     #     "152.53.149.109/22"
      #     #     # v6
      #     #     "2a00:11c0:47:195b::10/64"
      #     #   ];
      #   routes = [
      #     # v4
      #     #     { Gateway = "152.53.148.1"; }
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
      networking.interfaces.ens3 = {
        # Set this to false to ensure no DHCP is used for this interface
        #useDHCP = true; # Cloud providers dont give dhcp!!
        # Configure the IPv4 address and subnet mask
        ipv4.addresses = [
          {
            address = "152.53.149.109";
            prefixLength = 22;
          }
        ];
        # Configure the IPv6 address and prefix length
        ipv6.addresses = [
          {
            address = "2a00:11c0:47:195b::10";
            prefixLength = 64;
          }
        ];
      };

      # Set the default gateway
      networking.defaultGateway = {
        address = "152.53.148.1";
        interface = "ens3";
      };
      networking.defaultGateway6 = {
        address = "fe80::1";
        interface = "ens3";
      };
    };
}
