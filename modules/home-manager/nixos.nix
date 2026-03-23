{
  inputs,
  ...
}:
{
  # Home-manager settings, in nixos, enables home manager module
  # Individual homes/users are managed in the users dir
  flake.modules.nixos.core =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      config = {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs.hasGlobalPkgs = true;
          # https://github.com/nix-community/home-manager/issues/6770
          useUserPackages = true;
        };
      };
    };

}
