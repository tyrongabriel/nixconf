{ ... }:
{
  flake.modules.nixos.k3s =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myNixos.k3s;
      agentCfg = cfg.agent;
    in
    with lib;
    {
      options.myNixos.k3s.agent = {
        serverAddr = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Address of the K3s server (or load balancer) to connect to. Format: https://[ip]:port";
          example = "https://[fd00::1]:6443";
        };

        extraFlags = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Extra flags to pass to k3s agent.";
        };
      };

      config = mkIf (cfg.enable && builtins.elem "agent" cfg.node.roles) {
        assertions = [
          {
            assertion = agentCfg.serverAddr != null || builtins.elem "server" cfg.node.roles;
            message = "myNixos.k3s.agent.serverAddr must be set for agent-only nodes.";
          }
        ];

        services.k3s = {
          role = mkDefault "agent";
          disableAgent = mkDefault false;
          serverAddr = mkIf (agentCfg.serverAddr != null) (mkDefault agentCfg.serverAddr);
          extraFlags = agentCfg.extraFlags;
        };
      };
    };
}
