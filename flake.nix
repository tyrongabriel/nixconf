{
  description = "NixOS infrastructure";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake Parts to structure stuff
    flake-parts.url = "github:hercules-ci/flake-parts";
    # Import Tree to import modules
    import-tree.url = "github:vic/import-tree";

    ## Automated partitioning of disks ##
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Managing the Machines
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://app.cachix.org/cache/colmena"
    ];
    trusted-public-keys = [
      #"cache.nixos.org-1:AAAAAAAAAAAAAAACHIEDLEFUCEBOOTHI8airomo5ogueM=" # Technically not needed
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (inputs.import-tree ./modules/nixos)
        (inputs.import-tree ./users)
        (inputs.import-tree ./hosts)
        ./colmena.nix
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              (inputs.colmena.packages.${pkgs.system}.colmena)
              sops
              age
              jq
              just
            ];
          };
        };
    };
}
