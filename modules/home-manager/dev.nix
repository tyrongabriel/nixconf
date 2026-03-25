{ ... }:
{
  # Module aggregation for dev modules
  flake.modules.homeManager.dev =
    { ... }:
    {
      # import all dev-modules
      imports = [ ];
      config = {
        # Dev configuration aggregation
        #programs.zed-editor.enable = true;
      };
    };
}
