{ inputs, ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myHome.cli.nixvim;
    in
    with lib;
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];
      options.myHome.cli.nixvim = with lib; {
        enable = mkEnableOption "Enable nixvim";
      };
      config = mkIf cfg.enable {
        stylix.targets.neovim.enable = false;
        # Your configuration here
        programs.nixvim = {
          enable = true;

          # Stylix generates `require("mini.base16").setup(...)` in init.lua,
          # so we must ensure the mini.base16 module is available.
          plugins.mini = {
            enable = true;
            modules = {
              base16 = { };
            };
          };
        };
      };
    };
}
