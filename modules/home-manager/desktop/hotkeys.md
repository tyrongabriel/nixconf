# Hotkey Philosophy

Taking inspiration from vim, having clear seperation of what modifier is responsible for what, so I can transfer muscle memory between programs.

## Directional Core
* **`h` / `j` / `k` / `l`** => Left / Down / Up / Right (Vim standard)

## Action Modifiers
* **No Modifier / Core Combo** => **Focus / Navigation** (Moves your eyes)
* **`Shift`** => **Displacement / Layout Shift** (Physically moves the focused object)

## Layer Modifiers (The Targets)
* **`Super`** => **The OS / Window Layer**
  * Manages native OS windows, terminal spawns, and system-level tiling.
* **`Ctrl`** => **The View / Tab / Workspace Layer**
  * Manages structural views *within* applications (browser tabs, editor tabs, multiplexer panes) or virtual desktops at the OS level.
* **`Alt`** => **The Context / Boundary Layer**
  * Breaks the immediate boundary to jump across distinct contexts (hardware monitors, vertical sidebar docks, tab groups).

---

## Combined Logic Cheat Sheet
* `Super` + `dir` => Change window/column focus
* `Super` + `Shift` + `dir` => Move window/column position
* `Super` + `Alt` + `dir` => Switch hardware monitors
* `Super` + `Shift` + `Alt` + `Ctrl` + `dir` => Ingest or expel window from column (might one day remove the alt key from this combo as ctrl is not currently bound much in niri)



## Brave
| Action | Hotkey | Philosophy / Rationale |
| :--- | :--- | :--- |
| **Focus Location Bar** | `Ctrl + Space` | Navigate to address bar. |
| **Quick Commands** | `Ctrl + Shift + p` | Open command palette. |
| **Next Tab** | `Ctrl + l` | Move view right. |
| **Previous Tab** | `Ctrl + h` | Move view left. |
| **Move Tab Right** | `Ctrl + Shift + l` | Displace active tab right. |
| **Move Tab Left** | `Ctrl + Shift + h` | Displace active tab left. |
| **Next Tab Group** | `Alt + l` | Jump boundary to next context (group). |
| **Previous Tab Group** | `Alt + h` | Jump boundary to previous context (group). |
| **Add Tab to Group** | `Alt + t` | Add current tab to group context. |
| **Create New Tab Group** | `Alt + n` | Create new group boundary. |
| **Close Tab Group** | `Alt + w` | Close tab group boundary. |
| **New Tab** | `Ctrl + t` | Create new view layer. |
| **Close Tab** | `Ctrl + w` | Destructive action on current view (matches `Super + w`). |
| **Move Tab to New Window** | `Ctrl + Alt + n` | Displace current view into its own OS window. |
| **Extension Autofill** | `Shift + Alt + l` | Trigger extension autofill context. |

## Zed
| Action | Hotkey | Philosophy / Rationale |
| :--- | :--- | :--- |
| **Next Editor Tab** | `Ctrl + l` | Move view right. |
| **Previous Editor Tab** | `Ctrl + h` | Move view left. |
| **Move Editor Tab Right** | `Ctrl + Shift + l` | Displace active tab right. |
| **Move Editor Tab Left** | `Ctrl + Shift + h` | Displace active tab left. |
| **Focus Split Pane Right** | `Ctrl + Alt + l` | Jump boundary into neighboring editor pane. |
| **Focus Split Pane Left** | `Ctrl + Alt + h` | Jump boundary into neighboring editor pane. |
| **Toggle Left Dock (Project)** | `Ctrl + Alt + b` | Jump boundary out of editor to left panel. |
| **Toggle Right Dock (AI)** | `Ctrl + Alt + a` | Jump boundary out of editor to right panel. |
| **Toggle Bottom Dock (Terminal)** | `Ctrl + Alt + t` | Jump boundary out of editor to bottom panel. |
| **Close Active Tab** | `Ctrl + w` | Destructive action on current view (matches `Super + w`). |

## Zellij
| Action | Hotkey | Philosophy / Rationale |
| :--- | :--- | :--- |
| **Focus Pane Left** | `Ctrl + h` | Navigate to left local view pane. |
| **Focus Pane Right** | `Ctrl + l` | Navigate to right local view pane. |
| **Focus Pane Down** | `Ctrl + j` | Navigate to lower local view pane. |
| **Focus Pane Up** | `Ctrl + k` | Navigate to upper local view pane. |
| **Move Pane Left** | `Ctrl + Shift + h` | Displace local view pane position left. |
| **Move Pane Right** | `Ctrl + Shift + l` | Displace local view pane position right. |
| **Move Pane Down** | `Ctrl + Shift + j` | Displace local view pane position down. |
| **Move Pane Up** | `Ctrl + Shift + k` | Displace local view pane position up. |
| **Next Zellij Tab** | `Alt + l` | Jump boundary to next higher container layer (Tab). |
| **Previous Zellij Tab** | `Alt + h` | Jump boundary to previous higher container layer (Tab). |
| **New Pane** | `Ctrl + n` | Create new view layer element. |
| **Close Pane** | `Ctrl + w` | Destructive action on current view (matches `Super + w`). |

## Niri (Tiling Wayland Compositor)

| Action | Hotkey | Action Name | Notes |
| :--- | :--- | :--- | :--- |
| **Show Hotkey Overlay** | `Super + i` | `show-hotkey-overlay` | Direct action |
| **Toggle Overview** | `Super + Tab` | `toggle-overview` | Direct action |
| **Close Window** | `Super + w` | `close-window` | Direct action |
| **Fullscreen Window** | `Super + Shift + s` | `fullscreen-window` | Direct action |
| **Maximize Column** | `Super + f` | `maximize-column` | Direct action |
| **Toggle Window Floating** | `Super + t` | `toggle-window-floating` | Direct action |
| **Screenshot** | `Super + Shift + s` | `screenshot` | Captures selected region |
| **Screenshot Window** | `Super + Shift + Control + s` | `screenshot-window` | Captures focused window |
| **Focus Workspace Main** | `Super + 1` | `focus-workspace "main"` | Direct action |
| **Focus Workspace Browser** | `Super + 2` | `focus-workspace "browser"` | Direct action |
| **Focus Workspace Discord** | `Super + 3` | `focus-workspace "discord"` | Direct action |
| **Focus Workspace Music** | `Super + 4` | `focus-workspace "music"` | Direct action |
| **Focus Window Up/Column Left** | `Super + h` | `focus-window-up-or-column-left` | Vim-style |
| **Focus Window Down/Column Right** | `Super + l` | `focus-window-down-or-column-right` | Vim-style |
| **Focus Workspace Down** | `Super + j` | `focus-workspace-down` | Vim-style |
| **Focus Workspace Up** | `Super + k` | `focus-workspace-up` | Vim-style |
| **Move Column Left** | `Super + Shift + h` | `move-column-left` | Displacement |
| **Move Column Right** | `Super + Shift + l` | `move-column-right` | Displacement |
| **Move Window Down/Workspace Down** | `Super + Shift + j` | `move-window-down-or-to-workspace-down` | Displacement |
| **Move Window Up/Workspace Up** | `Super + Shift + k` | `move-window-up-or-to-workspace-up` | Displacement |
| **Focus Monitor Left** | `Super + Alt + h` | `focus-monitor-left` | Boundary jump |
| **Focus Monitor Right** | `Super + Alt + l` | `focus-monitor-right` | Boundary jump |
| **Focus Monitor Down** | `Super + Alt + j` | `focus-monitor-down` | Boundary jump |
| **Focus Monitor Up** | `Super + Alt + k` | `focus-monitor-up` | Boundary jump |
| **Move Column to Monitor Left** | `Super + Shift + Alt + h` | `move-column-to-monitor-left` | Displacement + boundary |
| **Move Column to Monitor Right** | `Super + Shift + Alt + l` | `move-column-to-monitor-right` | Displacement + boundary |
| **Move Column to Monitor Down** | `Super + Shift + Alt + j` | `move-column-to-monitor-down` | Displacement + boundary |
| **Move Column to Monitor Up** | `Super + Shift + Alt + k` | `move-column-to-monitor-up` | Displacement + boundary |
| **Consume/Expel Window Left** | `Super + Shift + Alt + Ctrl + h` | `consume-or-expel-window-left` | Special boundary |
| **Consume/Expel Window Right** | `Super + Shift + Alt + Ctrl + l` | `consume-or-expel-window-right` | Special boundary |
| **Resize Column Width −5%** | `Super + minus` | `set-column-width "-5%"` | Resizing |
| **Resize Column Width +5%** | `Super + plus` | `set-column-width "+5%"` | Resizing |
| **Resize Window Height −5%** | `Super + Ctrl + minus` | `set-window-height "-5%"` | Resizing |
| **Resize Window Height +5%** | `Super + Ctrl + plus` | `set-window-height "+5%"` | Resizing |
| **Spawn Terminal** | `Super + Return` | `spawn alacritty` | App spawn |
| **Spawn Browser** | `Super + b` | `spawn brave` | App spawn |
| **Spawn Browser (Incognito)** | `Super + Ctrl + B` | `spawn brave --incognito` | App spawn |
| **Spawn File Manager** | `Super + Shift + E` | `spawn cosmic-files` | App spawn |
| **Spawn Editor** | `Super + E` | `spawn zeditor` | App spawn |
| **Spawn Bitwarden** | `Super + p` | `spawn bitwarden-desktop` | App spawn |
| **Toggle Launcher** | `Super + Space` | `spawn noctalia "launcher toggle"` | Noctalia IPC |
| **Lock Screen** | `Super + Escape` | `spawn noctalia "lockScreen lock"` | Noctalia IPC |
| **Volume Increase** | `XF86AudioRaiseVolume` | `spawn noctalia "volume increase"` | Noctalia IPC |
| **Volume Decrease** | `XF86AudioLowerVolume` | `spawn noctalia "volume decrease"` | Noctalia IPC |
| **Volume Mute Output** | `XF86AudioMute` | `spawn noctalia "volume muteOutput"` | Noctalia IPC |
| **Input Volume Increase** | `Shift + XF86AudioRaiseVolume` | `spawn noctalia "volume increaseInput"` | Noctalia IPC |
| **Input Volume Decrease** | `Shift + XF86AudioLowerVolume` | `spawn noctalia "volume decreaseInput"` | Noctalia IPC |
| **Volume Mute Input** | `Shift + XF86AudioMute` | `spawn noctalia "volume muteInput"` | Noctalia IPC |
| **Toggle Volume Panel** | `Ctrl + XF86AudioMute` | `spawn noctalia "volume togglePanel"` | Noctalia IPC |
| **Media Play/Pause** | `XF86AudioPlay` | `spawn noctalia "media playPause"` | Noctalia IPC |
| **Media Next** | `XF86AudioNext` | `spawn noctalia "media next"` | Noctalia IPC |
| **Media Previous** | `XF86AudioPrev` | `spawn noctalia "media previous"` | Noctalia IPC |
