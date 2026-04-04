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

If this request is not complete, do it:

I attached 2 buttons and 5 tricks.
Below the achievements button on the right side, add the evolution button, and below that, add the socials button. Look at the pixels in each image to ensure that they are visually matched up (some graphics are located at different points in the trasparent background image so even if theyre the same size it could be different but im pretty sure the socials and evolution buttons are same size as earn button so you can try same size and x location as that). 

Evolution button:
Click it to open a window (similar to all other windows from buttons in game). It will display a list of all future trick unlocks and the respective days you will unlock the trick. When you are able to unlock the trick, you can click the train button when the correct day comes around. After clicking train, you will be in the apartment (just apartment background, no buttons, etc). There will a progress bar for how far youve gotten trick learned at top of screen, an exit button ( to leave). Once he tries to do a trick, a popup will appear and you have the choice to reward him or attempt again. The more u reward after successful tricks, the more likely is to do the trick, and therefore the further progress you have. The trick will be accessible once the progress reaches 100%. Progress can decrease if you reward him after incorrectly doing the trick. 100% progress unlocks each respective trick.

Socials button:
Once again similar to other windows in game. 3 social options: tiktok, instagram, youtube. You can post on each of them and choose a trick and a caption. You can see a log of all your earlier posts on each social and there should be back buttons in every subwindow (when subwindows appear such as past posts, etc, get rid of past window. The visuals should be really cool and look like youre actually on each app with really cool interface for posting and viewing past posts on each. When posting, you can pick a trick, write a caption, and post it. Each post will either flop, do okay, or do great, and this is heavily dependent on how many followers you have (but you can always randomly get a random viral video having no followers, or having a flop even if you have a lot of followers. You can choose from each trick and the later the trick gets unlocked (later day to unlock specific trick evolution), the more chance u have for it to succeed (the post). You will have a fame bar as a new statstic which is soley green. Will start at 0 and based on number of followers will increase left to right. The color of the bar is yellow no matter what (so not green/red/etc.). You can earn money from certain posts and there should also be a part of the socials window where you can collect any money you earned from posts, etc. Feel free to add any more features that you think would be cool. If you have any questions ask me. Feel free to do whatever you want on my computer or anything to help yourself.