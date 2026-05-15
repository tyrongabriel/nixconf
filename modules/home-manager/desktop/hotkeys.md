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
