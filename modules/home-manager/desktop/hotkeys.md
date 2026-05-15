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
