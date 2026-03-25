{ self, ... }:
{
  flake.modules.nixos.host_{{ machine_name | snake_case }} =
    { lib, config, ... }:
    {
      imports = with self.modules.nixos; [
        core
        user_tyron
        user_deploy
      ];
      config = {
        networking.hostName = "{{ machine_name }}";
        deployment = {
          {% if enable_tailscale -%}
          targetHost = "{{ machine_name }}.tail1c2108.ts.net";
          {% elif public_ipv6 -%}
          targetHost = "{{ public_ipv6 | trim }}";
          {% else -%}
          targetHost = "{{ public_ipv4 | trim }}";
          {% endif -%}
          targetUser = "deploy";
        };
        time.timeZone = lib.mkDefault "{{ timezone }}";

        myNixos.users.tyron.homeManager = {
          enable = true;
          tags = [ ];
        };

        hardware.facter.reportPath = ./facter.json;
        nixpkgs.system = "{{ system_architecture }}";
        system.stateVersion = "{{ system_state_version }}";
      };
    };
}
