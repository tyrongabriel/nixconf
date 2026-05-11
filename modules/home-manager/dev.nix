{ ... }:
{
  # Module aggregation for dev modules
  flake.modules.homeManager.dev =
    { config, self, ... }:
    {
      # import all dev-modules
      imports = [
        #self.modules.homeManager.git
      ];
      config = {
        # Dev configuration aggregation
        #programs.zed-editor.enable = true;
      };
    };
}
