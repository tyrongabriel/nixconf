{ self, ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myHome.zellij;
    in
    with lib;
    {
      imports = [ ];
      options.myHome.zellij = with lib; {
        enable = mkEnableOption "Enable zellij";
      };
      config = mkIf cfg.enable {
        programs.zellij = {
          enable = true;
          enableZshIntegration = true;
          settings = {
            theme = "catppuccin-macchiato";
          };
          extraConfig = ''
            keybinds clear-defaults=true {
                locked {
                    bind "Ctrl g" { SwitchToMode "Normal"; }
                }

                resize {
                    bind "Esc" { SwitchToMode "Normal"; }
                    bind "h" { Resize "Increase Left"; }
                    bind "j" { Resize "Increase Down"; }
                    bind "k" { Resize "Increase Up"; }
                    bind "l" { Resize "Increase Right"; }
                    bind "H" { Resize "Decrease Left"; }
                    bind "J" { Resize "Decrease Down"; }
                    bind "K" { Resize "Decrease Up"; }
                    bind "L" { Resize "Decrease Right"; }
                    bind "=" "+" { Resize "Increase"; }
                    bind "-" { Resize "Decrease"; }
                }

                pane {
                    bind "Esc" { SwitchToMode "Normal"; }
                    bind "p" { SwitchFocus; }
                    bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
                    bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
                    bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
                    bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
                    bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0; }
                    bind "x" { CloseFocus; SwitchToMode "Normal"; }
                    bind "s" { NewPane "stacked"; SwitchToMode "Normal"; }
                    bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
                    bind "r" { NewPane "Right"; SwitchToMode "Normal"; }
                }

                move {
                    bind "Esc" { SwitchToMode "Normal"; }
                    bind "n" "Tab" { MovePane; }
                    bind "p" { MovePaneBackwards; }
                }

                tab {
                    bind "Esc" { SwitchToMode "Normal"; }
                    bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
                    bind "b" { BreakPane; SwitchToMode "Normal"; }
                    bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
                    bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
                    bind "1" { GoToTab 1; SwitchToMode "Normal"; }
                    bind "2" { GoToTab 2; SwitchToMode "Normal"; }
                    bind "3" { GoToTab 3; SwitchToMode "Normal"; }
                    bind "4" { GoToTab 4; SwitchToMode "Normal"; }
                    bind "5" { GoToTab 5; SwitchToMode "Normal"; }
                    bind "Tab" { ToggleTab; }
                    bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
                }

                scroll {
                    bind "Esc" { SwitchToMode "Normal"; }
                    bind "e" { EditScrollback; SwitchToMode "Normal"; }
                    bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
                    bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
                    bind "j" "Down" { ScrollDown; }
                    bind "k" "Up" { ScrollUp; }
                    bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
                    bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
                    bind "d" { HalfPageScrollDown; }
                    bind "u" { HalfPageScrollUp; }
                }

                search {
                    bind "Esc" { SwitchToMode "Normal"; }
                    bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
                    bind "j" "Down" { ScrollDown; }
                    bind "k" "Up" { ScrollUp; }
                    bind "n" { Search "down"; }
                    bind "p" { Search "up"; }
                    bind "c" { SearchToggleOption "CaseSensitivity"; }
                    bind "w" { SearchToggleOption "Wrap"; }
                    bind "o" { SearchToggleOption "WholeWord"; }
                }

                entersearch {
                    bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
                    bind "Enter" { SwitchToMode "Search"; }
                }

                renametab {
                    bind "Ctrl c" { SwitchToMode "Normal"; }
                    bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
                }

                renamepane {
                    bind "Ctrl c" { SwitchToMode "Normal"; }
                    bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
                }

                session {
                    bind "Esc" { SwitchToMode "Normal"; }
                    bind "d" { Detach; }
                    bind "w" {
                        LaunchOrFocusPlugin "session-manager" {
                            floating true
                            move_to_focused_tab true
                        }
                        SwitchToMode "Normal"
                    }
                    bind "c" {
                        LaunchOrFocusPlugin "configuration" {
                            floating true
                            move_to_focused_tab true
                        }
                        SwitchToMode "Normal"
                    }
                    bind "p" {
                        LaunchOrFocusPlugin "plugin-manager" {
                            floating true
                            move_to_focused_tab true
                        }
                        SwitchToMode "Normal"
                    }
                }

                // =========================================================
                // Philosophy-aligned keybinds
                //
                // Ctrl       = View / Pane layer  (structural navigation)
                // Ctrl+Shift = View Displacement  (physically move panes)
                // Alt        = Context / Tab layer (boundary jumping)
                // Alt+Shift  = Context Displacement (move tabs)
                // =========================================================

                shared_except "locked" {
                    // --- Pane focus (Ctrl + vim dirs) ---
                    bind "Ctrl h" { MoveFocus "Left"; }
                    bind "Ctrl l" { MoveFocus "Right"; }
                    bind "Ctrl j" { MoveFocus "Down"; }
                    bind "Ctrl k" { MoveFocus "Up"; }

                    // --- Pane displace (Ctrl + Shift + vim dirs) ---
                    bind "Ctrl Shift h" { MovePane "Left"; }
                    bind "Ctrl Shift l" { MovePane "Right"; }
                    bind "Ctrl Shift j" { MovePane "Down"; }
                    bind "Ctrl Shift k" { MovePane "Up"; }

                    // --- Pane create / destroy ---
                    bind "Ctrl n" { NewPane; }
                    bind "Ctrl w" { CloseFocus; }

                    // --- Tab navigation (Alt + vim h/l) ---
                    bind "Alt h" { GoToPreviousTab; }
                    bind "Alt l" { GoToNextTab; }

                    // --- Tab displace (Alt + Shift + vim h/l) ---
                    bind "Alt Shift h" { MoveTab "Left"; }
                    bind "Alt Shift l" { MoveTab "Right"; }

                    // --- Tab create / destroy ---
                    bind "Alt n" { NewTab; }
                    bind "Alt w" { CloseTab; }

                    // --- Floating panes ---
                    bind "Alt f" { ToggleFloatingPanes; }
                    bind "Alt e" { TogglePaneEmbedOrFloating; }

                    // --- Mode entries (remapped to avoid Ctrl+h/n conflicts) ---
                    bind "Ctrl g" { SwitchToMode "Locked"; }
                    bind "Ctrl p" { SwitchToMode "Pane"; }
                    bind "Ctrl r" { SwitchToMode "Resize"; }
                    bind "Ctrl t" { SwitchToMode "Tab"; }
                    bind "Ctrl s" { SwitchToMode "Scroll"; }
                    bind "Ctrl o" { SwitchToMode "Session"; }
                    bind "Ctrl m" { SwitchToMode "Move"; }

                    // --- Quit ---
                    bind "Ctrl q" { Quit; }
                }

                // Esc / Enter return to Normal from any sub-mode
                shared_except "normal" "locked" {
                    bind "Enter" "Esc" { SwitchToMode "Normal"; }
                }
            }
          '';
        };
      };
    };
}
