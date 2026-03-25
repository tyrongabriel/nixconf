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
      networking.interfaces.{{ wan_interface | trim }} = {
        # Set this to false to ensure no DHCP is used for this interface
        useDHCP = true;

        wakeOnLan = {
          enable = true;
          policy = [ "magic" ];
        };
      };

      networking.nameservers = [
          {% for dns in dns_servers | split(pat=",") -%}
          "{{ dns | trim }}"
          {% endfor %}
      ];
    };
}
