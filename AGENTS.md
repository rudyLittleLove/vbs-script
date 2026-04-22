# Project Overview

This is a **game automation script project** for the classic RPG game *Metal Max* (重装机兵). It uses image recognition to automate in-game actions such as battling enemies, repairing armor, healing, and handling loot drops.

The scripts are written in **Q Language** (按键精灵/QMacro), a scripting language designed for Windows automation. It runs inside the **按键精灵 (QMacro/KeyWizard)** runtime environment, which provides screen capture, image matching (`FindPic`), and keyboard simulation APIs.

---

## Technology Stack

| Component | Description |
|-----------|-------------|
| **Language** | Q Language (按键精灵脚本语言) — VBScript-like syntax |
| **Runtime** | 按键精灵 (QMacro / KeyWizard) |
| **IDE** | 按键精灵编辑器 (produces `.Q` files) |
| **Image Matching** | `FindPic` API — screen region screenshot comparison |
| **Input Simulation** | `KeyPress`, `KeyDown`/`KeyUp`, `Delay` APIs |

---

## Project Structure

```
vbs-script/
├── AGENTS.md          # This file — agent guidance
├── images/            # Reference BMP images for screen recognition
│   ├── 闪光1.bmp ~ 闪光6.bmp      # Flash effect frames (rare enemy indicator)
│   ├── 战斗中战车.bmp ~ 战斗中战车3.bmp  # Battle state indicators
│   ├── 战车上.bmp, 战车下.bmp, ...     # Player tank on world map (8 directions/variants)
│   ├── 主炮.bmp, 副炮.bmp             # Weapon UI indicators
│   ├── 手指_*.bmp                     # Cursor/finger UI elements
│   ├── 寻找怪.bmp, 诱饵.bmp            # Menu options
│   ├── 血量少.bmp, 装甲少.bmp, 无装甲.bmp  # Low HP / low armor / no armor alerts
│   └── ... (46 total BMP files)
└── metal-tra/
    ├── 自动战斗.Q                              # Basic auto-battle script
    └── 自动战斗(识别闪光，修车，补甲).Q          # Enhanced auto-battle with flash detection, repair & armor refill
```

---

## Key Scripts

### 1. `metal-tra/自动战斗.Q` — Basic Auto-Battle

A lightweight script that handles:
- **Loot/drop handling**: Automatically presses confirm/cancel on post-battle dialogs
- **Enemy selection**: Confirms target selection during encounters
- **World map menu**: Opens the menu when on the world map
- **Bait usage**: Uses bait items to attract enemies

**Core pattern**: A `Do...Loop` calling `run()` every 5ms. Each `run()` call checks a priority-ordered list of UI states via `FindAndPress()`, exiting early on the first match.

### 2. `metal-tra/自动战斗(识别闪光，修车，补甲).Q` — Enhanced Auto-Battle

The full-featured script extending the basic version with:

| Feature | Description |
|---------|-------------|
| **Flash Detection** | Detects rare enemy encounters via 6-frame flash animation (`闪光1~6.bmp`). Switches to main cannon for rare enemies, sub-cannon for normal ones. |
| **Battle State Machine** | Tracks `inBattle`, `hasFlashDetected`, `hasWeaponSwitched` to avoid redundant actions. |
| **Auto-Repair** (`repair()`) | When armor is low (`装甲少.bmp`) or gone (`无装甲.bmp`), navigates to the repair shop in town via scripted movement keys. |
| **Auto-Heal** (`jiaxue()`) | When HP is low (`血量少.bmp`), executes a healing item sequence. |
| **Weapon Switching** (`switchWeaponInBattle()`) | Intelligently switches between main cannon (主炮) and sub-cannon (副炮) based on enemy rarity. |

---

## Coding Conventions

1. **Constants**: All configuration is at the top — `IMAGE_PATH`, `DELAY_SHORT`, `DELAY_NORMAL`.
2. **Functions**:
   - `FindAndPress(img, x1, y1, x2, y2, sim, key, delay)` — Find image in region, press key if found, return boolean.
   - `FindImage(img, x1, y1, x2, y2, sim)` — Pure check, no side effects.
3. **State Management**: Global `Dim` variables for battle state (Q Language does not have block-scoped variables).
4. **Priority Ordering**: Inside `run()`, checks are ordered from most specific/urgent to least urgent. Early `Exit Function` prevents lower-priority actions from firing.
5. **Image Naming**: All reference images use Chinese descriptive names with `.bmp` extension.
6. **Coordinates**: Hardcoded screen coordinates assume a fixed game resolution (likely 1280x768 or similar based on max x=1300, y=780).

---

## How to Modify

- **Add new enemy types**: Add `FindAndPress("新敌人.bmp", ...)` in the "确定诱敌" section.
- **Adjust coordinates**: Use 按键精灵's built-in抓图工具 (capture tool) to get new `(x1, y1, x2, y2)` regions.
- **Change delays**: Modify `DELAY_SHORT` / `DELAY_NORMAL` constants at the top of the file.
- **Add new UI handling**: Insert a new `FindAndPress` call in `run()` at the appropriate priority level.

---

## Important Notes

- **Resolution-dependent**: All coordinates are absolute screen positions. Changing game/window resolution will break recognition.
- **Image path is absolute**: `IMAGE_PATH = "D:\workspace\vbs-script\images\"` — if the project is moved, this must be updated.
- **No version control for `.Q` files**: These are binary-ish script files. Consider keeping backups or documenting changes in Git commit messages.
- **按键精灵 runtime required**: These scripts cannot run standalone; they need the QMacro environment.
