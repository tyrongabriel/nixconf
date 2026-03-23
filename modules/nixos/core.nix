{
  ...
}:

{
  flake.modules.nixos.core =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
      ];

      config = {
        environment.systemPackages = with pkgs; [
          vim
          git
          htop
          curl
          wget
        ];
      };
    };
}
