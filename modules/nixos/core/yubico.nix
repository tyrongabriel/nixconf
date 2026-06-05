{ ... }:
{
  flake.modules.nixos.core =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.myNixos.core.yubico;
    in
    with lib;
    {
      imports = [ ];
      options.myNixos.core.yubico = with lib; {
        enable = mkEnableOption "Enable yubico";
        identifiers = lib.mkOption {
          default = { };
          type = lib.types.attrsOf (lib.types.either lib.types.int lib.types.str);
          description = "Attrset of Yubikey serial numbers. NOTE: Yubico's 'Security Key' products do not use unique serial number therefore, the scripts in this module are unable to distinguish between multiple 'Security Key' devices and instead will detect a Security Key serial number as the string \"[FIDO]\". This means you can only use a single Security Key but can still mix it with YubiKey 4 and 5 devices.";
          example = lib.literalExample ''
            {
              foo = 12345678;
              bar = 87654321;
              baz = "[FIDO]";
            }
          '';
        };
      };
      config =
        let
          homeDirectory = config.users.users.tyron.home;
          yubikey-up =
            let
              yubikeyIds = lib.concatStringsSep " " (
                lib.mapAttrsToList (name: id: "[${name}]=\"${toString id}\"") cfg.identifiers
              );
            in
            pkgs.writeShellApplication {
              name = "yubikey-up";
              runtimeInputs = lib.attrValues { inherit (pkgs) gawk yubikey-manager; };
              text = ''
                #!/usr/bin/env bash
                set -euo pipefail

                serial=$(ykman list | awk '{print $NF}')
                # If it got unplugged before we ran, just don't bother
                if [ -z "$serial" ]; then
                  # FIXME(yubikey): Warn probably
                  exit 0
                fi

                declare -A serials=(${yubikeyIds})

                key_name=""
                for key in "''${!serials[@]}"; do
                  if [[ $serial == "''${serials[$key]}" ]]; then
                    key_name="$key"
                  fi
                done

                if [ -z "$key_name" ]; then
                  echo WARNING: Unidentified yubikey with serial "$serial" . Won\'t link an SSH key.
                  exit 0
                fi

                echo "Creating links to ${homeDirectory}/id_$key_name"
                ln -sf "${homeDirectory}/.ssh/id_$key_name" ${homeDirectory}/.ssh/id_yubikey
                ln -sf "${homeDirectory}/.ssh/id_$key_name.pub" ${homeDirectory}/.ssh/id_yubikey.pub
              '';
            };
          yubikey-down = pkgs.writeShellApplication {
            name = "yubikey-down";
            text = ''
              #!/usr/bin/env bash
              set -euo pipefail

              rm ${homeDirectory}/.ssh/id_yubikey
              rm ${homeDirectory}/.ssh/id_yubikey.pub
            '';
          };
        in
        mkIf cfg.enable {
          # for nice extra stuff: https://www.youtube.com/watch?v=3CeXbONjIgE
          environment.systemPackages = with pkgs; [
            yubikey-manager # ykman
            yubikey-touch-detector
            gnupg
            age-plugin-yubikey
            #pam_u2f
            #
            yubikey-up
            yubikey-down
          ];

          #https://github.com/EmergentMind/nix-config/blob/de52df51b3deff6b88a44a2662d8db7664447dd5/modules/hosts/common/yubikey.nix#L54
          services.pcscd.enable = true; # Yubikey smartcard stuff
          services.udev.packages = [ pkgs.yubikey-personalization ]; # Enhances the yubioath tool with customizations
          services.udev.extraRules = lib.optionalString pkgs.stdenv.isLinux ''
            # Link/unlink ssh key on yubikey add/remove
            SUBSYSTEM=="usb", ACTION=="add", ATTR{idVendor}=="1050", RUN+="${lib.getBin yubikey-up}/bin/yubikey-up"
            # NOTE: Yubikey 4 has a ID_VENDOR_ID on remove, but not Yubikey 5 BIO, whereas both have a HID_NAME.
            # Yubikey 5 HID_NAME uses "YubiKey" whereas Yubikey 4 uses "Yubikey", so matching on "Yubi" works for both
            SUBSYSTEM=="hid", ACTION=="remove", ENV{HID_NAME}=="Yubico Yubi*", RUN+="${lib.getBin yubikey-down}/bin/yubikey-down"
          '';
          # + lib.optionalString config.yubikey.autoScreenLock ''
          #   ##
          #   # Yubikey 4
          #   ##

          #   # Lock the device if you remove the yubikey (use udevadm monitor -p to debug)
          #   SUBSYSTEM=="hid", ACTION=="remove", ENV{HID_NAME}=="Yubico Yubi*", RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
          # ''
          # + lib.optionalString config.yubikey.autoScreenUnlock ''
          #   # FIXME: Change this so it only wakes up the screen to the login screen, xset cmd doesn't work
          #   SUBSYSTEM=="hid",\
          #    ACTION=="add",\
          #    ENV{HID_NAME}=="Yubico YubiKey FIDO",\
          #    RUN+="${pkgs.systemd}/bin/loginctl activate 1"
          #    #RUN+="${lib.getBin pkgs.xorg.xset}/bin/xset dpms force on"
          # '';

          #services.yubikey-agent.enable = true; # creates a yubikey ssh agent # doesnt seem to work

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
