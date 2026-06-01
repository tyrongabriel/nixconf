{ ... }:
{
  flake.modules.nixos.core =
    {
      pkgs,
      lib,
      ...
    }:
    with lib;
    {
      imports = [ ];
      options.myNixos.core.yubico = with lib; {
        #enable = mkEnableOption "Enable yubico";
      };
      config = {
        # for nice extra stuff: https://www.youtube.com/watch?v=3CeXbONjIgE
        environment.systemPackages = with pkgs; [
          yubikey-manager # ykman
          yubikey-touch-detector
          gnupg
          age-plugin-yubikey
          #pam_u2f
        ];
        services.pcscd.enable = true; # Yubikey smartcard stuff
        services.udev.packages = [ pkgs.yubikey-personalization ]; # Enhances the yubioath tool with customizations
        services.yubikey-agent.enable = true; # creates a yubikey ssh agent

        programs.gnupg.agent = {
          enable = true;
          enableSSHSupport = false;
        };

        # yubikey login / sudo
        # security.pam = lib.optionalAttrs pkgs.stdenv.isLinux {
        #   u2f = {
        #     enable = true;
        #     settings = {
        #       cue = true; # Tells user they need to press the button
        #       authFile = "${homeDirectory}/.config/Yubico/u2f_keys";
        #     };
        #   };
        #   services = {
        #     login.u2fAuth = true;
        #     sudo = {
        #       u2fAuth = true;
        #     };
        #   };
        # };
      };
    };
}
