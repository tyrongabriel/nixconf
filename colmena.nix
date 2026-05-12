{
  inputs,
  self,
  lib,
  #withSystem,
  ...
}:
let
  unreadyHosts = [
    "legion"
  ];
  # List all directories in the hosts directory
  hostNames = builtins.attrNames (
    lib.filterAttrs (n: type: type == "directory" && n != "template" && !(lib.elem n unreadyHosts)) (
      builtins.readDir ./hosts
    )
  );
in

{
  flake.colmenaHive = inputs.colmena.lib.makeHive (
    {
      meta = {
        nixpkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        specialArgs = { inherit inputs; };
        allowApplyAll = false; # No deployments without --on flag
      };

      # template = {
      #   imports = with self.modules.nixos; [
      #     host_template
      #   ];
      # };
    }
    // builtins.listToAttrs (
      map (hostName: {
        name = hostName;
        value = {
          imports = [ self.modules.nixos."host_${hostName}" ];
        };
      }) hostNames
    )
  );

  # Links all nodes to nixosConfigurations, so nix flake check does it't thing
  flake.nixosConfigurations = self.colmenaHive.nodes;
}
