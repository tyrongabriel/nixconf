{
  inputs,
  self,
  withSystem,
  ...
}:

{
  flake.colmenaHive = inputs.colmena.lib.makeHive {
    meta = {
      nixpkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      specialArgs = { inherit inputs; };
    };

    yoga =
      { name, ... }:
      {
        imports = [
          self.nixosModules.host_yoga
        ];

        networking.hostName = "yoga";

        deployment = {
          targetHost = "localhost";
          targetUser = "deploy";
          allowLocalDeployment = true;
        };
      };
  };
}
