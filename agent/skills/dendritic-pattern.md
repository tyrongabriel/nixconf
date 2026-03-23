This flake uses the dendritic module pattern for nixos, originating from:
https://github.com/mightyiam/dendritic
Leaning heavily on https://flake.parts/index.html

This pattern is based on the concept that each file, instead of being a package, module or anything else, it EXPORTS a flake-parts output, so that they are easily referenced using `self` in any other file. For example, a module:

```
{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.path;
in {
  options.path = with types; {
    enable = mkEnableOption "Enable module";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
     #configuration;
  };
}
```
Would look like this in dendritic:
```nix
{...}: {
  flake.modules.nixos.<name> = {self, ...} {
    imports = [ <other modules, imported via self.modules.nixos.<name>]
    options.path = with types; {
      enable = mkEnableOption "Enable module";
      # Add more options here
    };
  
    config = lib.mkIf cfg.enable {
      #configuration;
    };
  }
  
}
```

Keep in mind, that the typical "enable" option is less useful in dendritic patterns, so you should mostly omit it, as importing a module is akin to enabling it, only if needed add it.

Furthermore, we use flake-parts modules, an optional feature, which groups exported modules into `flake.modules.nixos.<name>` and `flake.modules.homeManager.<name>` etc. Docs here: https://flake.parts/options/flake-parts-modules.html
