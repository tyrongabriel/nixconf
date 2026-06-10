{
  inputs,
  ...
}:
{
  flake.modules.homeManager.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.niri;
      desktopCfg = config.myHome.desktop;
      apps = {
        browser = "brave";
        browser-incognito = [
          "brave"
          "--incognito"
        ];
        terminal = "ghostty";
        fileManager = "nautilus";
        editor = "zeditor";
        discord = "discord";
        appLauncher = "fuzzel";
        #wayscrollshot = "${pkgs.waysc}/bin/wayscrollshot";

        screenshotArea = "${pkgs.bash}/bin/bash -c '${pkgs.grim}/bin/grim -g \"\\\$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy'";
        screenshotWindow = "${pkgs.bash}/bin/bash -c '${pkgs.grim}/bin/grim -g \"\\\$(${pkgs.slurp}/bin/slurp -w)\" - | ${pkgs.wl-clipboard}/bin/wl-copy'";
        screenshotOutput = "${pkgs.bash}/bin/bash -c '${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy'";
      };

      noctalia =
        cmd:
        [
          "noctali"
          "ipc"
          "call"
        ]
        ++ (pkgs.lib.splitString " " cmd);

      #https://github.com/DataLabTechTV/dltos/blob/main/system_files/usr/bin/tray-launch
      tray-launch = pkgs.writeShellScriptBin "tray-launch" ''
        #!/usr/bin/env bash

        usage() {
            echo "Usage: tray-launch PROGRAM [ARGS...]"
            echo "Launch a program after the system tray interface is ready."
            echo
            echo "Options:"
            echo "  -h, --help    Show this help message and exit"
        }

        if [[ $# -lt 1 ]]; then
            echo "Error: Insufficient arguments."
            usage
            exit 1
        fi

        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
            usage
            exit 0
        fi

        ${pkgs.glib.bin}/bin/gdbus wait --session org.kde.StatusNotifierWatcher
        exec "$@"
      '';

    in
    with lib;
    {
      imports = [ ];
      options.myHome.desktop.niri = with lib.types; {
        enable = mkEnableOption "Enable niri";
        startupCommands = mkOption {
          type = listOf (submodule {
            options = {
              command = mkOption {
                type = listOf str;
                description = "Command to run at startup, as a list of strings (e.g. [ \"discord\" \"--start-minimized\" ])";
              };
            };
          });
          default = [ ];
          example = [
            {
              command = [
                "discord"
                "--start-minimized"
              ];
            }
          ];
          description = "List of commands to run at startup, each command is a list of strings";
        };
      };
      config = mkIf cfg.enable {

        home.packages = with pkgs; [
          inputs.nirimod.packages.${pkgs.stdenv.hostPlatform.system}.default
          tray-launch
          glib.bin
        ];
        # Bad workaround til the niri-flake dev finally merges https://github.com/sodiboo/niri-flake/pull/1548
        home.activation.niri-include-monitors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          echo "Adding include to niri config.kdl"
          if [ -f ~/.config/niri/config.kdl ]; then
            run cp ~/.config/niri/config.kdl ~/.config/niri/config.kdl.tmp
            run rm ~/.config/niri/config.kdl -f
            run cp ~/.config/niri/config.kdl.tmp ~/.config/niri/config.kdl
            run rm ~/.config/niri/config.kdl.tmp -f
            run rm ~/.config/niri/config.kdl.hm-bak -f
            run chmod +w ~/.config/niri/config.kdl
            run sed -i '1i\' ~/.config/niri/config.kdl
            run sed -i '1i include optional=true "./monitors.kdl"' ~/.config/niri/config.kdl
            echo "Done, include prepended to config.kdl"
          else
            echo "config.kdl not found, skipping"
          fi
        '';

        programs.niri.settings = {
          input.mouse.accel-profile = "flat";
          input.mouse.accel-speed = 0.0;
          layout = {
            gaps = 8;
            background-color = "#${config.lib.stylix.colors.base00}";
          };

          prefer-no-csd = true;
          # Define a global window rule for the geometry
          window-rules = [
            {
              # Omitting the 'match' block entirely makes this apply globally to all windows
              geometry-corner-radius = {
                top-left = 12.0;
                top-right = 12.0;
                bottom-right = 12.0;
                bottom-left = 12.0;
              }; # Adjust this number to perfectly match your window radius
              clip-to-geometry = true;
            }
          ];

          spawn-at-startup = [
            {
              command = [
                "systemctl"
                "--user"
                "start"
                "hyprpolkitagent"
              ];
            }
            # 1. Sync DBus/Systemd environment (Fixes most Wayland-related crashes/hangs)
            {
              command = [
                "dbus-update-activation-environment"
                "--systemd"
                "WAYLAND_DISPLAY"
                "XDG_CURRENT_DESKTOP"
                "DISPLAY"
              ];
            }

            # 2. Start the Keyring (with --start to output the vars to the session)
            {
              command = [
                "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon"
                "--start"
                "--components=secrets"
              ];
            }
            { command = [ "xwayland-satellite" ]; }
            # {
            #   # waits for services to be fully ready before starting apps
            #   command = [
            #     "${pkgs.bash}/bin/bash"
            #     "-c"
            #     ''
            #       # Wait for keyring to be active
            #       systemctl --user wait-active gnome-keyring 2>/dev/null || true
            #       # Wait for dbus session to be ready
            #       while ! dbus-send --session --dest=org.freedesktop.DBus --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null; do
            #         sleep 0.2
            #       done
            #     ''
            #   ];
            # }
            {
              command = [
                "noctalia"
              ];
            }

          ]
          ++ cfg.startupCommands;

          hotkey-overlay.skip-at-startup = true;

          # https://github.com/ctknightdev/nixos/blob/main/home/niri/keybinds.nix
          binds = with config.lib.niri.actions; {
            "super+i".action.show-hotkey-overlay = [ ];
            # Volume
            "XF86AudioRaiseVolume".action.spawn = noctalia "volume increase"; # output increase
            "XF86AudioLowerVolume".action.spawn = noctalia "volume decrease"; # output decrease
            "XF86AudioMute".action.spawn = noctalia "volume muteOutput"; # output mute
            "shift+XF86AudioRaiseVolume".action.spawn = noctalia "volume increaseInput"; # input increase
            "shift+XF86AudioLowerVolume".action.spawn = noctalia "volume decreaseInput"; # input decrease
            "shift+XF86AudioMute".action.spawn = noctalia "volume muteInput"; # input mute
            "control+XF86AudioMute".action.spawn = noctalia "volume togglePanel"; # open volume panel

            # Media
            "XF86AudioPlay".action.spawn = noctalia "media playPause";
            "XF86AudioNext".action.spawn = noctalia "media next";
            "XF86AudioPrev".action.spawn = noctalia "media previous";

            "super+Space".action.spawn = apps.appLauncher;
            "super+w".action = close-window;
            "super+b".action = spawn apps.browser;
            "super+d".action = spawn apps.discord;
            "super+Control+B".action = spawn apps.browser-incognito;
            "super+Return".action = spawn apps.terminal;
            #    "super+Space".action = spawn apps.appLauncher;
            "super+Shift+E".action = spawn apps.fileManager;
            "super+E".action = spawn apps.editor;
            "super+Escape".action.spawn = noctalia "lockScreen lock";

            # Tested with ghostty and kitty
            # "super+m".action = spawn apps.terminal [
            #   "--title=spotify_player"
            #   "-e"
            #   "spotify_player"
            # ];

            # Bitwarden quick access
            "super+p".action = spawn [
              "${pkgs.bitwarden-desktop}/bin/bitwarden"
              #"--quick-access"
            ];

            "super+shift+f".action = fullscreen-window;
            "super+ctrl+f".action = expand-column-to-available-width;
            "super+f".action = maximize-column;
            "super+t".action = toggle-window-floating;

            "super+shift+s".action.screenshot = [ ];
            "super+shift+control+s".action.screenshot-window = [ ];
            # The "Infinite Canvas" Screenshot
            #"super+shift+control+s".action.spawn = [
            #  "${apps.wayscrollshot}"
            #  "-c"
            #]; # -c copies to clipboard
            #
            "super+shift+C".action.spawn-sh =
              "niri msg pick-color | wl-copy && notify-send 'Color Picked' '$(wl-paste)' -i color-picker";
            # binds {
            #     // Triggers the color picker. Click anywhere on screen to grab the hex code.
            #     Mod+Shift+C {
            #         spawn "sh" "-c" "niri msg pick-color | wl-copy && notify-send 'Color Picked' '$(wl-paste)' -i color-picker"
            #     }
            # }

            # Vim-style navigation
            "super+h".action = focus-window-up-or-column-left;
            "super+l".action = focus-window-down-or-column-right;
            #"super+j".action = focus-window-down;
            #"super+k".action = focus-window-up;

            "super+Shift+h".action = move-column-left;
            "super+Shift+l".action = move-column-right;
            "super+Shift+j".action = move-window-down-or-to-workspace-down;
            "super+Shift+k".action = move-window-up-or-to-workspace-up;

            # Monitor navigation
            "super+Alt+h".action = focus-monitor-left;
            "super+Alt+l".action = focus-monitor-right;
            "super+Alt+j".action = focus-monitor-down;
            "super+Alt+k".action = focus-monitor-up;

            # Move column to monitor
            "super+Shift+Alt+h".action = move-column-to-monitor-left;
            "super+Shift+Alt+l".action = move-column-to-monitor-right;
            "super+Shift+Alt+j".action = move-column-to-monitor-down;
            "super+Shift+Alt+k".action = move-column-to-monitor-up;

            # Consume/expel windows
            "super+Shift+Alt+Ctrl+h".action = consume-or-expel-window-left;
            "super+Shift+Alt+Ctrl+l".action = consume-or-expel-window-right;

            # Workspace navigation
            "super+j".action = focus-workspace-down;
            "super+k".action = focus-workspace-up;

            # Move column to workspace
            #"super+Shift+j".action = move-column-to-workspace-down;
            #"super+Shift+k".action = move-column-to-workspace-up;

            # Resize
            "super+minus".action = set-column-width "-5%";
            "super+plus".action = set-column-width "+5%";
            "super+Control+minus".action = set-window-height "-5%";
            "super+Control+plus".action = set-window-height "+5%";

            # Overview
            "super+Tab".action = toggle-overview;

            "super+1".action = focus-workspace "main";
            "super+2".action = focus-workspace "browser";
            "super+3".action = focus-workspace "discord";
            "super+4".action = focus-workspace "music";
          };
        }
        // lib.optionalAttrs (desktopCfg.monitors != [ ]) {
          outputs = lib.foldl' (
            acc: monitor:
            acc
            // {
              ${monitor.name} = {
                name = monitor.id;
                focus-at-startup = monitor.primary;
                variable-refresh-rate = if monitor.vrr then true else false;
                scale = monitor.scale;
              }
              // lib.optionalAttrs (monitor.mode.height != null && monitor.mode.width != null) {
                mode = {
                  height = monitor.mode.height;
                  width = monitor.mode.width;
                }
                // lib.optionalAttrs (monitor.mode.refresh != null) {
                  refresh = monitor.mode.refresh;
                };
              };
            }
          ) { } desktopCfg.monitors;
        };
      };
    };

}
