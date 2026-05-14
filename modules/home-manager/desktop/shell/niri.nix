{ self, ... }:
{
  flake.modules.homeManager.niri =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.desktop.niri;
      apps = {
        browser = "brave";
        browser-incognito = [
          "brave"
          "--incognito"
        ];
        terminal = "alacritty";
        fileManager = "cosmic-files";
        editor = "zeditor";
        #appLauncher = "${pkgs.walker}/bin/walker";
        #wayscrollshot = "${pkgs.waysc}/bin/wayscrollshot";

        screenshotArea = "${pkgs.bash}/bin/bash -c '${pkgs.grim}/bin/grim -g \"\\\$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy'";
        screenshotWindow = "${pkgs.bash}/bin/bash -c '${pkgs.grim}/bin/grim -g \"\\\$(${pkgs.slurp}/bin/slurp -w)\" - | ${pkgs.wl-clipboard}/bin/wl-copy'";
        screenshotOutput = "${pkgs.bash}/bin/bash -c '${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy'";
      };

      noctalia =
        cmd:
        [
          "noctalia-shell"
          "ipc"
          "call"
        ]
        ++ (pkgs.lib.splitString " " cmd);
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
        # Your configuration here
        programs.niri.settings = {
          input.mouse.accel-profile = "flat";
          input.mouse.accel-speed = 0.0;
          prefer-no-csd = true;
        };
        #programs.niri.package = pkgs.niri;
        programs.niri.settings.spawn-at-startup = [
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
          { command = [ "noctalia-shell" ]; }
          { command = [ "xwayland-satellite" ]; }
        ]
        ++ cfg.startupCommands;

        # https://github.com/ctknightdev/nixos/blob/main/home/niri/keybinds.nix
        programs.niri.settings.binds = with config.lib.niri.actions; {
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

          "super+Space".action.spawn = noctalia "launcher toggle";
          "super+q".action = close-window;
          "super+b".action = spawn apps.browser;
          "super+Control+B".action = spawn apps.browser-incognito;
          "super+Return".action = spawn apps.terminal;
          #    "super+Space".action = spawn apps.appLauncher;
          "super+Shift+E".action = spawn apps.fileManager;
          "super+E".action = spawn apps.editor;
          "super+L".action.spawn = noctalia "lockScreen lock";

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

          "super+f".action = fullscreen-window;
          "super+shift+f".action = maximize-column;
          "super+t".action = toggle-window-floating;

          "super+shift+w".action.screenshot = [ ];
          "super+shift+s".action.screenshot-window = [ ];
          # The "Infinite Canvas" Screenshot
          #"super+shift+control+s".action.spawn = [
          #  "${apps.wayscrollshot}"
          #  "-c"
          #]; # -c copies to clipboard

          "super+Left".action = focus-column-left;
          "super+Right".action = focus-column-right;
          "super+Down".action = focus-workspace-down;
          "super+Up".action = focus-workspace-up;

          "super+Shift+Left".action = move-column-left;
          "super+Shift+Right".action = move-column-right;
          "super+Shift+Down".action = move-column-to-workspace-down;
          "super+Shift+Up".action = move-column-to-workspace-up;

          "super+Alt+Left".action = move-window-to-monitor-left;
          "super+Alt+Right".action = move-window-to-monitor-right;
          "super+Alt+Down".action = move-window-to-monitor-down;
          "super+Alt+Up".action = move-window-to-monitor-up;

          "super+Minus".action = set-column-width "-10%";
          "super+Plus".action = set-column-width "+10%";

          "super+Control+Left".action = focus-monitor-left;
          "super+Control+Right".action = focus-monitor-right;
          "super+Control+Down".action = focus-monitor-down;
          "super+Control+Up".action = focus-monitor-up;

          "super+1".action = focus-workspace "main";
          "super+2".action = focus-workspace "browser";
          "super+3".action = focus-workspace "discord";
          "super+4".action = focus-workspace "music";
        };

      };
    };

}
