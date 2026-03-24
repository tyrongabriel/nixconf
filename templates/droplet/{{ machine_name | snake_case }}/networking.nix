{ self, ... }:
{
  flake.modules.nixos.host_{{ machine_name | snake_case }} =
    { ... }:
    {
      imports = [
        {% if enable_tailscale -%}
        self.modules.nixos.tailscale
        {% endif %}
      ];

      networking.useDHCP = true;
      #networking.useNetworkd = true;

      # systemd.network.networks."10-wan" = {
      #   matchConfig.Name = "{{ wan_interface | trim }}";
      #   address = [
      #     # v4
      #     {% if public_ipv4 -%}
      #     "{{ public_ipv4 | trim }}"
      #     {% endif -%}
      #     # v6
      #     {% if public_ipv6 -%}
      #     "{{ public_ipv6 | trim }}"
      #     {% endif -%}
      #   ];
      #   routes = [
      #     # v4
      #     {% if ipv4_gateway -%}
      #     { Gateway = "{{ ipv4_gateway | trim }}"; }
      #     {% endif -%}
      #     # v6
      #     {% if ipv6_gateway -%}
      #     { Gateway = "{{ ipv6_gateway | trim }}"; }
      #     {% endif -%}
      #   ];
      #   networkConfig.DNS = [
      #     {% for dns in dns_servers | split(pat=",") -%}
      #     "{{ dns | trim }}"
      #     {% endfor -%}
      #   ];
      # };

      networking.nameservers = [
          {% for dns in dns_servers | split(pat=",") -%}
          "{{ dns | trim }}"
          {% endfor %}
        ];
      networking.interfaces.eth0 = {
      # Set this to false to ensure no DHCP is used for this interface
      #useDHCP = true; # Cloud providers dont give dhcp!!
        # Configure the IPv4 address and subnet mask
        ipv4.addresses = [
          {% if public_ipv4 -%}
          {
            address = "{{ public_ipv4 | split(pat="/") | first }}";
            prefixLength = {{ public_ipv4 | split(pat="/") | last}};
          }
          {% endif %}
        ];
        # Configure the IPv6 address and prefix length
        ipv6.addresses = [
          {% if public_ipv6 -%}
          {
            address = "{{ public_ipv6 | split(pat="/") | first }}";
            prefixLength = {{ public_ipv6 | split(pat="/") | last }};
          }
          {% endif %}
        ];
      };

      # Set the default gateway
      networking.defaultGateway = {
        address = "{{ ipv4_gateway | trim }}";
        interface = "{{ wan_interface | trim }}";
      };
      networking.defaultGateway6 = {
        address = "{{ ipv6_gateway | trim }}";
        interface = "{{ wan_interface | trim }}";
      };
    };
}
