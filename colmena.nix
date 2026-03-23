{
  inputs,
  self,
  #withSystem,
  ...
}:

{
  flake.colmenaHive = inputs.colmena.lib.makeHive {
    meta = {
      nixpkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      specialArgs = { inherit inputs; };
    };

    yoga =
      { ... }:
      {
        imports = with self.modules.nixos; [
          host_yoga
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
