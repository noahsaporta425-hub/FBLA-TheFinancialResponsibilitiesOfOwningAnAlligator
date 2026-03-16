# The Financial Responsibilities of Owning an Alligator

An educational pet simulation game built in Processing for FBLA. You adopt a baby alligator and must keep it healthy, happy, and financially supported over time by making smart spending and earning decisions.

---

## Requirements

- [Processing 4](https://processing.org/download) (Java mode)
- Libraries (install via **Sketch > Import Library > Manage Libraries**):
  - `Sound` (processing.sound)
  - `ControlP5`

---

## How to Run

1. Open Processing.
2. Open the `A_Main` folder as a sketch (`File > Open` → select `A_Main.pde`).
3. Click the **Run** button (▶).

---

## How to Play

### Home Screen
- **Instructions** — view in-game guidance before starting.
- **Play** — begin a new game.
- **Music** — adjust volume or toggle background music on/off.

### Adoption & Setup
- Watch the adoption cutscene as your alligator is rescued.
- **Name your alligator** and choose one of three skin colors.

### Main Screen
The main screen is your daily hub. Each day you can take the following actions before pressing **+** to advance to the next day:

| Button | Action |
|--------|--------|
| Bag (Inventory) | Feed or sell items from your inventory |
| Rest | Play a timing mini-game to restore energy |
| Store | Buy snacks, medicine, or meat |
| Play | Choose and play a minigame to earn money |
| Services | Hire a vet, dog walker, or cleaner |
| Earn (💰) | Get a job, do tasks, or upgrade your income |
| Bank | View your full transaction history |
| Achievements (🏆) | Track progress and collect reward money |
| **+** | Advance to the next day |
| **X** | Quit the game |

### Pet Stats
Keep an eye on all five stats — they decay over time and with neglect:

| Stat | Notes |
|------|-------|
| **Health** | Drops if your pet is sick or eats junk food |
| **Happiness** | Increases from play and good food |
| **Energy** | Drained by play; restored by rest |
| **Hunger** | Increases over time; reduce by feeding |
| **Sickness Risk** | Higher risk = more likely to fall ill |

### Feeding (Inventory)
- Open the **Inventory** (bag button) to select an item and **Use** it to feed your alligator.
- You can also **Sell** items for 75% of purchase price.
- Your first meal is always a free steak.
- Food effects vary — fish and meat are the healthiest; junk food may boost energy but hurt health.

### Medicine
- When your alligator gets sick, visit the **Vet** to get a prescription.
- Prescribed medicine is **free** at the store.
- Giving non-prescribed medicine **harms** your alligator.
- 3-star vet ($5) has a 25% chance to fail; 5-star vet ($20) always works.

### Earning Money

**Jobs** (via the Earn → Job Finder menu):
- Cashier: available immediately, starts at $15/day
- Barista: unlocks on Day 10, starts at $35/day
- Manager: unlocks on Day 25, starts at $75/day
- Upgrade salary by spending money to boost daily pay (up to a cap per job)

**Help Around Town** (task):
- Earn money instantly, but your alligator is left unattended — there's a chance it gets sick.

**Minigames** (via the Play button):
- Earn money per point scored. Upgrade your $/point multiplier in the Earn → Tasks tab.

### Minigames

#### Swamp Hop
Side-scrolling runner. Press **SPACE** to jump over obstacles (logs, rocks, mud, vines). Score increases over time. Don't get hit!

#### Snack Snatch
Food falls from the sky. Move with **A/D** or **← →** arrow keys to catch fish and meat. **Dodge vegetables** — touching one ends the game!

#### Fetch Frenzy
Top-down ball fetch. Use **WASD** or **arrow keys** to move your alligator toward the ball. Fetch as many times as you can within the time limit.

### Services
- **Vet**: Diagnose and treat illness ($5 low-quality, $20 high-quality).
- **Dog Walker** ($10): Reduces energy, boosts happiness and health.
- **Cleaner** ($10): Reduces sickness risk, boosts happiness and health.

### Resting
Click the **Rest** button to do a timing mini-game:
- Land the marker in the **center zone** → +30 energy
- Land in the **middle zone** → +10 energy
- Miss → -10 energy
- Each rest attempt costs one rest token (recharged daily).

### Achievements
30 achievements track your play stats (feeding, spending, minigames, etc.). Complete them to unlock cash rewards. Scroll through the achievements panel to claim rewards.

### Store
- Closed on **Day 7** (and every 7th day).
- **Snacks tab**: Junk food — affordable but often bad for health.
- **Medicine tab**: Prescription meds are free; non-prescription costs $5 each.
- **Meat tab**: Healthier food options (fish, cuts of meat).

---

## File Structure

| File | Purpose |
|------|---------|
| `A_Main.pde` | Entry point — `setup()` and `draw()` |
| `B_Interaction.pde` | All mouse/keyboard input handling |
| `C_Music.pde` | Music and audio setup |
| `D_General_Functions.pde` | Shared utilities, file I/O, stat bars |
| `E_Home_Screen.pde` | Home screen rendering and instructions |
| `F_Adoption_Cutscene.pde` | Intro cutscene and naming screen |
| `G_Main_Screen.pde` | Main gameplay screen, all panel rendering |
| `H_Play_Screen.pde` | All three minigames |
| `I_Alligator_Class.pde` | `Pet` class and food/medicine effects |
| `data/` | All images, fonts, and audio assets |

---

## Libraries & Attribution

### Processing Libraries

| Library | Purpose | Author | Source | License |
|---------|---------|--------|--------|---------|
| `processing.sound` | Background music playback | Processing Foundation | https://processing.org/reference/libraries/sound/ | LGPL v2.1 |
| `ControlP5` | Volume slider, music toggle, pet name text input | Andreas Schlegel | https://sojamo.de/libraries/controlP5/ | LGPL v2.1 |

### Runtime / IDE

| Resource | Source | License |
|----------|--------|---------|
| Processing 4 IDE and runtime | https://processing.org | GPL v2 / LGPL v2.1 |

### Audio

| Asset | Details |
|-------|---------|
| **Title** | Leisure Simulation Game |
| **Artist/Composer** | Sylvain Ott |
| **Label** | AXS Music / BMG Production Music |
| **Released** | 2017-12-23 |
| **Source** | https://www.youtube.com/watch?v=SlBiaepD0Ys |
| **Usage** | Used as ambient background music in an educational, non-commercial FBLA competition project. No modifications made. |

### Visual Assets
- All game artwork (alligator sprites, backgrounds, UI elements, item images) was created originally for this project.
