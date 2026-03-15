# CLAUDE.md — Project Context

## What this project is
An educational pet simulation game built in **Processing 4** (Java mode) for an FBLA competition. The game is called *"The Financial Responsibilities of Owning an Alligator"*. The player adopts a baby alligator and must keep it healthy and financially supported over multiple in-game days.

## Language & Libraries
- **Language**: Processing (Java syntax)
- **Libraries**: `processing.sound`, `ControlP5`, `processing.opengl` (P2D renderer)
- **Window size**: 1100 × 700, P2D renderer

## File Structure
All game logic is split across multiple `.pde` tab files that compile together as one sketch:

| File | Role |
|------|------|
| `A_Main.pde` | `setup()` / `draw()` — screen state switcher |
| `B_Interaction.pde` | All `mousePressed`, `keyPressed`, `mouseDragged`, etc. |
| `C_Music.pde` | Audio setup (SoundFile, ControlP5 volume/toggle) |
| `D_General_Functions.pde` | Utilities, file I/O, achievement data, stat bars |
| `E_Home_Screen.pde` | Home screen render + instructions overlay |
| `F_Adoption_Cutscene.pde` | Cutscene, adoption center, and pet naming screen |
| `G_Main_Screen.pde` | Full main gameplay screen (largest file) |
| `H_Play_Screen.pde` | Three minigames: Swamp Hop, Snack Snatch, Fetch Frenzy |
| `I_Alligator_Class.pde` | `Pet` class with stat tracking and `eat()` method |

## Key Global State
- `homescreenvisible`, `cutscenestart`, `inNaming`, `startrealgame`, `onmainscreen` — screen state flags
- `alligator` — the global `Pet` object
- `money`, `day` — core economy variables
- `sick`, `sickness` — illness system
- `job`, `salary` — employment system
- `inventoryslots[]` — 12-slot string array for inventory
- `medicinestock[]`, `snackstock[]`, `meatstock[]` — store item arrays
- `presc[]` — boolean array tracking which medicines are currently prescribed

## Screen Flow
Home Screen → Cutscene → Naming → Main Screen ↔ Minigames / Store / Services / Bank / Achievements

## Minigames
- **Swamp Hop**: side-scrolling runner, SPACE to jump
- **Snack Snatch**: catch falling food, dodge vegetables, A/D or arrow keys
- **Fetch Frenzy**: top-down ball fetch, WASD or arrow keys, timed

## Economy
- Money earned via: jobs (daily salary), tasks (Help Around Town), minigames (per point), achievement rewards
- Money spent via: store (snacks/medicine/meat), vet, walker, cleaner, salary upgrades, task upgrades
- Bank logs all transactions in `bankTransactions` ArrayList

## Important Conventions
- All mouse hit detection is done with raw coordinate comparisons in `B_Interaction.pde`
- ControlP5 is set to `setAutoDraw(false)` and drawn manually with `cp5.draw()`
- `applyAlligatorTint()` must be called before drawing alligator sprites and `noTint()` after
- Stat clamping uses `clampStat()` defined in `I_Alligator_Class.pde`
- `logSellTransaction()` and `earnMinigameMoney()` are the canonical ways to add money (they update all counters)
