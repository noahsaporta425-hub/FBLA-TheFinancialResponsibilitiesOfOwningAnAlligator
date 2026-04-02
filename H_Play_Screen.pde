// =========================
// H_Play_Screen.pde
// Three minigames: Swamp Hop, Snack Snatch, and Fetch Frenzy.
// Each minigame awards money based on moneyPerMinigamePoint (upgradeable in the Earn panel).
// All three share earnMinigameMoney(), tickMinigameStats(), and drawMinigameModal().
// =========================

Fade minigameFade = new Fade(255);  // starts black on minigame entry; fades to clear as game begins

// =========================
// Minigame Shared Helpers
// earnMinigameMoney(), tickMinigameStats(), drawMinigameModal(), drawMinigameStats()
// are defined below and used by all three minigames.
// =========================

// =========================
// Minigame Choice Screen
// =========================
boolean isOnChoiceScreen = false;   // true while the player is on the game selection screen

// =========================
// Swamp Hop -- Assets & Sprites
// =========================
PImage minigamechoice;              // background image for the minigame selection screen
PImage alligatorf1;                 // walk-cycle frame 1
PImage alligatorf2;                 // walk-cycle frame 2
PImage alligatorf3;                 // walk-cycle frame 3
PImage alligatorf4;                 // walk-cycle frame 4
PImage log, rock, vine, mud;        // obstacle sprites (each has unique hitbox tuning below)

// =========================
// Swamp Hop -- Physics & Game State
// =========================
boolean isEnterSwampHop    = false;   // true when Swamp Hop is the active minigame
boolean isSwampHopRetry    = false;   // true when player clicked RETRY (grace frames prevent instant death)
boolean isExitingMinigame  = false;   // true when player clicked EXIT to return to main screen
boolean isSwampHopFirstPlay = true;   // shows WELCOME modal instead of YOU LOST on first entry
boolean isSwampHopOnGround = true;    // prevents double-jumping

int   walkAnimFrameDelay = 6;         // 6 frames per walk animation cell at 60fps gives a natural-looking gait
float x = 224;                        // alligator's fixed horizontal screen position
float y = 500;                        // vertical position -- changes during jumps
float hopGravity      = 1.2f;         // tuned so the jump arc feels responsive but not floaty
float hopJumpStrength = 20;           // peak upward velocity; matched to gravity so player can clear one obstacle height
float hopVelocityY    = 0;            // current vertical velocity (positive = falling)
float hopGroundY;                     // ground threshold -- recalculated each frame

int swampHopGraceFrames = 0;          // frames of invincibility after RETRY (prevents instant re-death)
int swampHopSpawnDelay  = 0;          // extra delay before first obstacle spawns after RETRY

float swampHopScoreTimer  = 0;        // counts frames; every 60 frames = +1 point
float swampHopBgScrollX   = 0;        // current horizontal scroll offset for the background
float swampHopScrollSpeed = 16;       // horizontal scroll rate; fast enough to feel urgent, slow enough to be fair
float swampHopBgWidth;                // cached background image width (set each frame)
float swampHopBgHeight;               // cached background image height (set each frame)

// =========================
// Swamp Hop -- Obstacle Spawning
// =========================
ArrayList<Obstacle> swampHopObstacles = new ArrayList<Obstacle>(); // active obstacle instances
float obstacleSpawnGap = 900;   // minimum pixel gap between obstacles so the player always has time to react
float nextObstacleX    = 0;     // x-position at which the next obstacle will be placed

// =========================
// Swamp Hop -- Hitbox Tuning
// Each value is a fraction of the sprite's drawn size (1.0 = full size).
// Offsets shift the hitbox center from the sprite center in pixels.
// Hand-tuned so near-misses feel fair and collisions feel accurate.
// Hitbox fractions are intentionally forgiving (smaller than the sprite) to keep gameplay fair; values tuned by playtesting
// =========================
// Alligator catcher hitbox (slightly inset so near-misses feel forgiving)
float hopGatorHitboxWidth   = 0.70f;   // 70% of sprite width
float hopGatorHitboxHeight  = 0.45f;   // 45% of sprite height
float hopGatorHitboxOffsetY = -8;      // shift upward from sprite center

// Vine hitbox (tall and narrow -- hangs down from above)
float vineHitboxWidth   = 0.45f;
float vineHitboxHeight  = 0.85f;
float vineHitboxOffsetY = -10;

// Rock hitbox (wide and low -- sits on the ground)
float rockHitboxWidth   = 0.75f;
float rockHitboxHeight  = 0.55f;
float rockHitboxOffsetY = 0;

// Mud hitbox (same shape as rock)
float mudHitboxWidth   = 0.75f;
float mudHitboxHeight  = 0.55f;
float mudHitboxOffsetY = 0;

// Log hitbox (full width, slightly reduced height)
float logHitboxWidth   = 1.0f;
float logHitboxHeight  = 0.7f;
float logHitboxOffsetY = 0;

// =========================
// Swamp Hop -- Scoring & Animation
// =========================
int swampHopScore     = 0;   // current run score (increments once per second survived)
int swampHopBestScore = 0;   // all-time best score (persisted to save file)
int walkAnimFrameIndex = 1;  // current walk-cycle sprite (1-4)
int walkAnimFrameTimer = 0;  // counts up each draw(); resets at walkAnimFrameDelay

float moneyPerMinigamePoint = 0;  // dollars earned per minigame point (upgradeable in Earn panel)


// =========================
// Snack Snatch -- Assets & Game State
// =========================
boolean isEnterSnackSnatch = false;   // true when Snack Snatch is the active minigame
boolean isSnatchFirstPlay  = true;    // shows WELCOME modal on first entry
boolean isSnatchLost       = true;    // true when showing lose/welcome modal (not actively playing)

int   snatchScore     = 0;    // current run score
int   snatchBestScore = 0;    // all-time best score

// Player position (horizontal only -- vertical is fixed)
float snatchPlayerX = 550;

// Player hitbox fractions (applied to energeticalligator sprite size)
float snatchGatorWidthMult  = 0.600f;  // fraction of sprite width used for collision
float snatchGatorHeightMult = 0.240f;  // fraction of sprite height used for collision
float snatchGatorOffsetX    = -4.0f;   // horizontal center offset in pixels
float snatchGatorOffsetY    = -20.0f;  // vertical center offset (shifted up toward mouth)

ArrayList<FallingFood> fallingFoods = new ArrayList<FallingFood>(); // active falling items

// Food sprite references (loaded in D_General_Functions :: fileWork)
PImage bluegill, bass, perch, goldfish, crab, lambchop, porkchop;
PImage broccoli, carrot, tomato, pepper;

// =========================
// Snack Snatch -- Per-Food Hitbox Tuning
// W/H = size fraction relative to sprite dimensions, OX/OY = center offset in pixels.
// Vegetables touching the player cause a loss; all other food scores a point.
// =========================
float bluegillW=0.520f, bluegillH=0.380f, bluegillOX=-2,  bluegillOY=-4;
float bassW    =0.560f, bassH    =0.400f, bassOX   = 4,   bassOY   =-8;
float perchW   =0.580f, perchH   =0.360f, perchOX  = 0,   perchOY  =-2;
float goldfishW=0.520f, goldfishH=0.380f, goldfishOX=-2,  goldfishOY=-4;
float crabW    =0.600f, crabH    =0.360f, crabOX   = 0,   crabOY   =-4;
float lambchopW=0.420f, lambchopH=0.340f, lambchopOX=-8,  lambchopOY= 8;
float porkchopW=0.500f, porkchopH=0.420f, porkchopOX= 0,  porkchopOY= 0;
float broccoliW=0.540f, broccoliH=0.620f, broccoliOX= 2,  broccoliOY=-4;
float carrotW  =0.380f, carrotH  =0.540f, carrotOX =-6,   carrotOY  = 8;
float tomatoW  =0.380f, tomatoH  =0.480f, tomatoOX = 2,   tomatoOY  =-2;
float pepperW  =0.340f, pepperH  =0.540f, pepperOX = 2,   pepperOY  =-4;


// =========================
// Fetch Frenzy -- Assets & Game State
// =========================
boolean isEnterFetchFrenzy = false;   // true when Fetch Frenzy is the active minigame
boolean isFetchFirstPlay   = true;    // shows WELCOME modal on first entry
boolean isFetchLost        = true;    // true when showing lose/welcome modal

int   fetchScore     = 0;
int   fetchBestScore = 0;
float fetchTimer     = 3;             // 3-minute fetch session; long enough to earn meaningful rewards, short enough to stay engaging

PImage fetchfrenzybackground;
PImage ball;
PImage topalligator1, topalligator2;  // two-frame top-down walk animation

// Player position and facing direction (WASD/arrow key controlled)
float  fetchPlayerX       = 0;
float  fetchPlayerY       = 0;
String fetchFacingDirection = "RIGHT";
int    fetchWalkFrameTimer  = 0;       // tracks which walk frame to show

// =========================
// Fetch Frenzy -- Ball Physics
// Fetch Frenzy physics constants -- tuned for a bouncy but controllable feel; drag/friction slow the ball to prevent infinite sliding
// =========================
float   ballX = 548, ballY = 618;           // current ball position
float   ballVelocityX = 0, ballVelocityY = 0; // horizontal/vertical ground-plane velocity
float   ballZ = 0;                           // height above the ground (for shadow + arc)
float   ballVerticalVelocity = 0;            // vertical (arc) velocity component
boolean isBallMoving = false;

float ballGravity            = 1.0f;   // downward pull on ballVerticalVelocity each frame
float ballBounceFactor       = 0.55f;  // fraction of vertical speed kept on each bounce
float ballAirDrag            = 0.995f; // per-frame drag applied while ball is airborne
float ballGroundFriction     = 0.92f;  // per-frame friction applied when ball is on ground
float ballStopSpeedThreshold = 0.15f;  // ground speed below which the ball is considered stopped
float ballStopBounceThreshold = 0.6f;  // bounce speed below which the ball stops bouncing

// =========================
// Fetch Frenzy -- Hitboxes and Launch Logic
// =========================
RectHB ballHB  = new RectHB(0, -0.50f, 36.00f, 37.00f);    // ball collision box (center-relative)
RectHB gatorHB = new RectHB(0, -42.00f, 95.00f, 144.00f);  // alligator collision box (UP orientation)

boolean isBallWaitingToLaunch = false;  // true while countdown before next launch is running
int     ballLaunchCountdown   = 0;      // frames remaining until next launch
final int LAUNCH_DELAY        = 30;     // 30 frames (~0.5s at 60fps) between catches so the player has time to reposition
boolean isBallOnField         = true;   // false briefly while waiting to re-launch

boolean ballHitsPlayer      = false;    // true this frame if ball overlaps alligator hitbox
boolean wasBallHittingPlayer = false;   // true last frame (used to detect the moment of contact)
boolean hasBallBeenLaunched  = false;   // prevents double-launch on round start
// Canonical way to add money from minigame play; updates money, totalMoneyEarned, and relevant achievement counters.
// amount: dollars to add (derived from moneyPerMinigamePoint, which the player can upgrade).
void earnMinigameMoney(float amount) {
  money += amount;
  currentPlaySessionMoneyEarned += amount;
  totalMoneyEarned += amount;
  moneyEarnedFromMinigames += amount;
}

// Called every frame during minigames; slowly drains energy and hunger to simulate effort,
// while boosting happiness because the alligator enjoys playing.
void tickMinigameStats() {
  alligator.energy    -= 0.01;
  alligator.happiness += 0.01;
  totalHappinessRestored += 0.01;
}

// Draws a small X exit button in the top-right corner of any active minigame.
void drawMinigameExitButton() {
  noStroke();
  fill(180, 30, 30);
  rectMode(CORNER);
  rect(1042, 8, 50, 38, 6);
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(arcade);
  textSize(18);
  text("X", 1067, 27);
  strokeWeight(1);
  stroke(0);
}

// Draws the pre-game info popup with controls and description before a minigame starts,
// and re-uses the same layout for the YOU LOST screen after a run ends.
// title: large header text (e.g., "WELCOME!" or "YOU LOST!")
// sub1/sub2/sub3: up to three instruction/info lines; pass an empty string to skip a line.
// leftBtn / rightBtn: labels for the two action buttons (e.g., "RETRY" / "EXIT").
void drawMinigameModal(String title, String sub1, String sub2, String sub3,
                       String leftBtn, String rightBtn) {
  stroke(255);
  strokeWeight(5);
  fill(80, 150);
  rectMode(CENTER);
  rect(width/2, height*0.4, 300, 400);
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(arcade);
  text(title, width/2, 131);
  textSize(sub2.isEmpty() ? 30 : 18);
  if (!sub1.isEmpty()) text(sub1, width/2, 160);
  if (!sub2.isEmpty()) text(sub2, width/2, 180);
  if (!sub3.isEmpty()) text(sub3, width/2, 200);
  textSize(30);
  applyAlligatorTint();
  image(alligator.energeticalligator, width/2, 300,
        alligator.energeticalligator.width/4, alligator.energeticalligator.height/4);
  noTint();
  text(leftBtn,  width/2 - 70, 436);
  text(rightBtn, width/2 + 70, 436);
  noFill();
  rect(width/2 - 70, 436, 105, 50);
  rect(width/2 + 70, 436, 105, 50);
}

// Renders the in-game HUD overlay (energy and happiness bars) during any minigame,
// giving the player visibility into how the activity is affecting their alligator.
void drawMinigameStats() {
  strokeWeight(1);
  stroke(0);
  rectMode(CORNER);
  textAlign(LEFT, CENTER);
  textFont(arcade);
  textSize(20);
  fill(255);
  text("Energy:", width * 0.015, height * 0.2);
  energybar.setValue(alligator.energy);
  energybar.drawenergyscale();
  fill(255);
  text("Happiness:", width * 0.015, height * 0.15);
  happinessbar.setValue(alligator.happiness);
  happinessbar.drawpositive();
}

// =========================
// Minigame Choice Screen State
// =========================

// =========================
// Swamp Hop -- Assets
// =========================
PImage swamphopbackground;  // Scrolling background image (drawn twice for seamless loop)

// Four-frame walk cycle sprites for the side-scrolling alligator character
// Obstacle sprites (randomly spawned, each with unique hitbox tuning)

// =========================
// Swamp Hop -- Animation State
// =========================


// =========================
// Swamp Hop -- Physics
// =========================


// =========================
// Swamp Hop -- Game State
// =========================
boolean isSwampHopLost = true;         // True = showing lose/welcome modal (not actively playing)

// =========================
// Swamp Hop -- Obstacle Spawning
// =========================

// =========================
// Swamp Hop -- Hitbox Multipliers
// Each obstacle type has its own width/height/Y-offset tuning so collision feels fair.
// Values are fractions of the sprite's actual drawn size (1.0 = full size).
// =========================

// Alligator hitbox (slightly inset so near-misses feel forgiving)

// Vine hitbox (tall but narrow -- hangs from above)
// Rock hitbox (wide and low -- sits on ground)
// Mud hitbox (same as rock -- ground obstacle)
// Log hitbox (full width, slightly reduced height)
// =========================
// Swamp Hop -- Scoring
// =========================

// =========================
// Snack Snatch -- Scoring
// =========================
// =========================
// Fetch Frenzy -- Player Position
// =========================

void resetSwampHop() {
  isSwampHopLost = false;
  isSwampHopRetry = false;
  swampHopScore = 0;
  swampHopScoreTimer = 0;
  
  x = 224;
  y = 500;
  hopVelocityY = 0;
  isSwampHopOnGround = true;

  swampHopScrollSpeed = 16;
  swampHopBgScrollX = 0;

  swampHopObstacles.clear();
  nextObstacleX = width + 600;

  swampHopGraceFrames = 45;
  swampHopSpawnDelay = 30;
}

void play() {
  isOnChoiceScreen=true;
  fill(255,0,0);
  rect(0,0,width,height);

  imageMode(CENTER);
  image(minigamechoice, width/2, height*0.52,
        (minigamechoice.width/1.4)*1.01, minigamechoice.height/1.4);
  
  if (isEnterSwampHop) {

    isOnChoiceScreen = false;
    swamphop();
    minigameFade.stepIn(6);  // fade from black to clear as game starts

  } else if (isEnterSnackSnatch) {

    isOnChoiceScreen = false;
    snacksnatch();
    minigameFade.stepIn(6);

  } else if (isEnterFetchFrenzy) {

    isOnChoiceScreen = false;
    fetchfrenzy();
    minigameFade.stepIn(6);

  } else {

    isOnChoiceScreen = true;
    minigameFade.stepIn(3);  // choice screen fades in slightly slower

  }

  // Draw the fade overlay on top of everything
  rectMode(CORNER);
  minigameFade.draw();
}


void swamphop() {

  swampHopBgWidth = swamphopbackground.width / 1.38;
  swampHopBgHeight = swamphopbackground.height / 1.38;
  
  imageMode(CORNER);
  image(swamphopbackground, swampHopBgScrollX, 0, swampHopBgWidth, swampHopBgHeight);
  image(swamphopbackground, swampHopBgScrollX + swampHopBgWidth, 0, swampHopBgWidth, swampHopBgHeight);
  
  
  strokeWeight(1);
  stroke(0);
  rectMode(CORNER);
  textAlign(LEFT,CENTER);
  textFont(arcade);
  fill(255);
  text("Score: " + swampHopScore, width*0.015, 54);
  drawMinigameStats();
  drawMinigameExitButton();

  if (isSwampHopLost) {
    
    swampHopObstacles.clear();
    nextObstacleX = width + 600;
    imageMode(CENTER);

    applyAlligatorTint();
    image(alligatorf1, x, y, alligatorf1.width/1.5, alligatorf1.height/1.5);
    noTint();
    if (swampHopScore > swampHopBestScore) swampHopBestScore = swampHopScore;
    if (!isSwampHopFirstPlay) {
      drawMinigameModal("YOU LOST!", "High Score: " + swampHopBestScore, "", "", "RETRY", "EXIT");
    } else {
      drawMinigameModal("WELCOME!", "Click space to hop!", "", "", "PLAY", "EXIT");
    }

    strokeWeight(1);
    stroke(0);
    rectMode(CORNER);
    return;
  }
  stroke(0);

  swampHopScoreTimer++;
  if (swampHopScoreTimer % 60 == 0) {
    swampHopScore++;
    earnMinigameMoney(moneyPerMinigamePoint);
  }
  if (isSwampHopOnGround && !isSwampHopLost) {
    swampHopScrollSpeed = 16;
  } else if (!isSwampHopLost) {
    swampHopScrollSpeed = 22;
  }

  imageMode(CORNER);
  if (!isSwampHopLost) tickMinigameStats();
  
  swampHopBgScrollX -= swampHopScrollSpeed;
  if (swampHopBgScrollX <= -swampHopBgWidth) swampHopBgScrollX = 0;

  float halfH = (alligatorf1.height/1.5) / 2.0;
  hopGroundY = 500 + halfH;

  hopVelocityY += hopGravity;
  y += hopVelocityY;

  if (y + halfH >= hopGroundY) {
    y = hopGroundY - halfH;
    hopVelocityY = 0;
    isSwampHopOnGround = true;
  }
  
  
  imageMode(CENTER);

  walkAnimFrameTimer++;
  if (walkAnimFrameTimer >= walkAnimFrameDelay) {
    walkAnimFrameTimer = 0;
    walkAnimFrameIndex++;
    if (walkAnimFrameIndex > 4) {
      walkAnimFrameIndex = 1;
    }
  }
  
  applyAlligatorTint();
  if (walkAnimFrameIndex == 1) {
    image(alligatorf1, x, y, alligatorf1.width/1.5, alligatorf1.height/1.5);
  } 
  else if (walkAnimFrameIndex == 2) {
    image(alligatorf2, x, y, alligatorf2.width/1.5, alligatorf2.height/1.5);
  } 
  else if (walkAnimFrameIndex == 3) {
    image(alligatorf3, x, y, alligatorf3.width/1.5, alligatorf3.height/1.5);
  } 
  else if (walkAnimFrameIndex == 4) {
    image(alligatorf4, x, y, alligatorf4.width/1.5, alligatorf4.height/1.5);
  }
  noTint();
  updateAndDrawObstacles();

}


class Obstacle {
  PImage img;
  float ox, oy;
  float w, h;

  Obstacle(PImage img, float ox, float oy, float w, float h) {
    this.img = img;
    this.ox = ox;
    this.oy = oy;
    this.w = w;
    this.h = h;
  }

  void update(float speed) {
    ox -= speed;
  }

  void drawObstacle() {
    image(img, ox, oy, w, h);
  }

  boolean offscreen() {
    return ox + w/2 < 0;
  }
}

void initObstaclesIfNeeded() {
  if (swampHopObstacles.size() == 0) {
    nextObstacleX = width + 200;  // start off-screen right so the first obstacle slides in naturally
    // pre-populate 4 obstacles spaced across the visible+buffer zone
    for (int i = 0; i < 4; i++) spawnObstacle();
  }
}

void spawnObstacle() {
  int t = int(random(4));
  PImage img = log;
  if (t == 1) img = rock;
  if (t == 2) img = mud;
  if (t == 3) img = vine;

  float scale = 5.0;
  if (img == vine) {
    scale = 3.0;  
  }
  float ow = img.width / scale;
  float oh = img.height / scale;

  float oy;
  if (img == vine) {
    oy = oh/2;
  } else {
    oy = hopGroundY - oh/2;
  }

  swampHopObstacles.add(new Obstacle(img, nextObstacleX, oy, ow, oh));
  nextObstacleX += obstacleSpawnGap;
}

void updateAndDrawObstacles() {
  if (isSwampHopLost) return;

  if (swampHopGraceFrames > 0) swampHopGraceFrames--;  // brief invincibility after retry so the player isn't instantly killed on spawn

  if (swampHopSpawnDelay > 0) {
    swampHopSpawnDelay--;
    return;
  }

  initObstaclesIfNeeded();

  float gatorW = alligatorf1.width/1.5;
  float gatorH = alligatorf1.height/1.5;

  float gHitW = gatorW * 0.760;
  float gHitH = gatorH * 0.300;
  float gCenterX = x - 24.0;
  float gCenterY = y + 12.0;

  for (int i = swampHopObstacles.size()-1; i >= 0; i--) {
    Obstacle o = swampHopObstacles.get(i);
    o.update(swampHopScrollSpeed);
    o.drawObstacle();

    float oHitW = o.w;
    float oHitH = o.h;
    float oCenterX = o.ox;
    float oCenterY = o.oy;

    if (o.img == vine) {
      oHitW = o.w * 0.160;
      oHitH = o.h * 0.680;
      oCenterX += 3.0;
      oCenterY += 15.0;
    }
    else if (o.img == rock) {
      oHitW = o.w * 0.500;
      oHitH = o.h * 0.220;
      oCenterX += 6.0;
      oCenterY += 3.0;
    }
    else if (o.img == mud) {
      oHitW = o.w * 0.560;
      oHitH = o.h * 0.200;
      oCenterX += 6.0;
    }
    else if (o.img == log) {
      oHitW = o.w * 0.8;
      oHitH = o.h * 0.240;
      oCenterX += 6.0;
      oCenterY -= 6.0;
    }

    boolean collisionX = abs(gCenterX - oCenterX) < (gHitW/2 + oHitW/2);
    boolean collisionY = abs(gCenterY - oCenterY) < (gHitH/2 + oHitH/2);

    if (collisionX && collisionY && swampHopGraceFrames == 0) {
      isSwampHopLost = true;
    }

    if (o.offscreen()) {
      swampHopObstacles.remove(i);
    }
  }

  while (swampHopObstacles.size() < 6) {  // keep 6 obstacles pooled off-screen to avoid mid-game allocation
    spawnObstacle();
  }
}

void snacksnatch() {
  isEnterSnackSnatch=true;
  if (!isSnatchLost) {
  if (isMoveLeft) {
    snatchPlayerX -= 10;
  }

  if (isMoveRight) {
    snatchPlayerX += 10;
  }
  }
  if (snatchPlayerX < 140) snatchPlayerX = 140;
  if (snatchPlayerX > 960) snatchPlayerX = 960;
  
  if (!isSnatchLost) tickMinigameStats();
  
  imageMode(CORNER);
  image(mainscreen, 0, 0, width, height);

  imageMode(CENTER);
  applyAlligatorTint();
  image(alligator.energeticalligator, snatchPlayerX, 572,
        alligator.energeticalligator.width/4, alligator.energeticalligator.height/4);
  noTint();

  updateSnackSnatchFalling();

  strokeWeight(1);
  stroke(0);
  rectMode(CORNER);
  textAlign(LEFT, CENTER);
  textFont(arcade);
  fill(255);
  text("Score: " + snatchScore, width*0.015, 54);
  drawMinigameStats();
  drawMinigameExitButton();

  if (isSnatchLost) {
    if (snatchScore > snatchBestScore) snatchBestScore = snatchScore;
    if (!isSnatchFirstPlay) {
      drawMinigameModal("YOU LOST!", "High Score: " + snatchBestScore, "", "", "RETRY", "EXIT");
    } else {
      drawMinigameModal("WELCOME", "Catch food, dodge veggies!", "Use A/D or the right and", "left arrow keys to move.", "PLAY", "EXIT");
    }
    stroke(0);
  }
}

void updateSnackSnatchFalling() {
  if (isSnatchLost) return;

  if (fallingFoods.size() == 0) {
    fallingFoods.add(new FallingFood(randomFood()));
  }

  for (int i = fallingFoods.size()-1; i >= 0; i--) {
    FallingFood f = fallingFoods.get(i);
    f.update();
    float gW = alligator.energeticalligator.width/4.0;
    float gH = alligator.energeticalligator.height/4.0;
    
    float gCenterX = snatchPlayerX + snatchGatorOffsetX;
    float gCenterY = 572 + snatchGatorOffsetY;
    
    float gHitW = gW * snatchGatorWidthMult;
    float gHitH = gH * snatchGatorHeightMult;
    
    float wMult=0.5, hMult=0.5, ox=0, oy=0;
    
    if (f.img == bluegill) { wMult=bluegillW; hMult=bluegillH; ox=bluegillOX; oy=bluegillOY; }
    else if (f.img == bass) { wMult=bassW; hMult=bassH; ox=bassOX; oy=bassOY; }
    else if (f.img == perch) { wMult=perchW; hMult=perchH; ox=perchOX; oy=perchOY; }
    else if (f.img == goldfish) { wMult=goldfishW; hMult=goldfishH; ox=goldfishOX; oy=goldfishOY; }
    else if (f.img == crab) { wMult=crabW; hMult=crabH; ox=crabOX; oy=crabOY; }
    else if (f.img == lambchop) { wMult=lambchopW; hMult=lambchopH; ox=lambchopOX; oy=lambchopOY; }
    else if (f.img == porkchop) { wMult=porkchopW; hMult=porkchopH; ox=porkchopOX; oy=porkchopOY; }
    else if (f.img == broccoli) { wMult=broccoliW; hMult=broccoliH; ox=broccoliOX; oy=broccoliOY; }
    else if (f.img == carrot) { wMult=carrotW; hMult=carrotH; ox=carrotOX; oy=carrotOY; }
    else if (f.img == tomato) { wMult=tomatoW; hMult=tomatoH; ox=tomatoOX; oy=tomatoOY; }
    else if (f.img == pepper) { wMult=pepperW; hMult=pepperH; ox=pepperOX; oy=pepperOY; }
    
    float fHitW = (f.img.width/6.0) * wMult;
    float fHitH = (f.img.height/6.0) * hMult;
    
    float fCenterX = f.x + ox;
    float fCenterY = f.y + oy;
    
    boolean hit = abs(gCenterX - fCenterX) < (gHitW/2 + fHitW/2) &&
                  abs(gCenterY - fCenterY) < (gHitH/2 + fHitH/2);
    
    if (hit) {
    
      boolean isVeggie = (f.img == broccoli || 
                          f.img == carrot || 
                          f.img == tomato || 
                          f.img == pepper);
    
      if (isVeggie) {
        isSnatchLost = true;
      } else {
        snatchScore++;
        earnMinigameMoney(moneyPerMinigamePoint);
      }
    
      fallingFoods.remove(i);
      continue;
    }
    f.drawFood();

    // spawn the next food when the current one is 70% down the screen, keeping at most 2 active
    if (!f.spawnedNext && f.y > height * 0.7 && fallingFoods.size() < 2) {
      fallingFoods.add(new FallingFood(randomFood()));
      f.spawnedNext = true;
    }

    if (f.y > height + 80) {
    
      boolean isVeggie = (f.img == broccoli || 
                          f.img == carrot || 
                          f.img == tomato || 
                          f.img == pepper);
    
      if (!isVeggie) {
        isSnatchLost = true;
      }
    
      fallingFoods.remove(i);
      continue;
    }
  }
}

PImage randomFood() {
  PImage[] weightedFood = {
    bluegill, bluegill,
    bass, bass,
    perch, perch,
    goldfish, goldfish,
    crab, crab,
    lambchop, lambchop,
    porkchop, porkchop,
    broccoli,
    carrot,
    tomato,
    pepper
  };
  return weightedFood[int(random(weightedFood.length))];
}

class FallingFood {
  PImage img;
  float x, y;
  float fallSpeed;
  float angle, rotationSpeed;
  boolean spawnedNext = false;

  FallingFood(PImage img) {
    this.img = img;
    x = random(50, width - 50);
    y = -60;
    fallSpeed = random(4, 8);               // randomize fall speed so each food item feels different to catch
    angle = random(TWO_PI);
    rotationSpeed = random(-0.1, 0.1);      // gentle spin in either direction for visual variety
    if (abs(rotationSpeed) < 0.03) rotationSpeed = (rotationSpeed < 0 ? -0.05 : 0.05);  // ensure minimum spin is visible; values near 0 look like no rotation
  }

  void update() {
    y += fallSpeed;
    angle += rotationSpeed;
  }

  void drawFood() {
    pushMatrix();
    translate(x, y);
    rotate(angle);
    image(img, 0, 0, img.width/6.0, img.height/6.0);
    popMatrix();
  }
}

// =========================
// Snack Snatch Hitbox Tuning
// Each variable pair (W/H) scales the hitbox relative to the sprite size.
// Each pair (OX/OY) offsets the hitbox center from the sprite center.
// Values were hand-tuned to match each sprite's visual footprint.
// =========================

// Alligator catcher hitbox (applied to the player character)

// Per-food hitbox tuning (W/H = size fraction, OX/OY = center offset)
// Vegetables (touching these causes a loss)
void resetSnackSnatch() {
  snatchScore = 0;
  isSnatchLost = false;
  isSnatchFirstPlay = false;
  fallingFoods.clear();
  fallingFoods.add(new FallingFood(randomFood()));
  snatchPlayerX=width/2;
}

class RectHB {
  float offX, offY, w, h;
  RectHB(float offX, float offY, float w, float h) {
    this.offX = offX;
    this.offY = offY;
    this.w = w;
    this.h = h;
  }
}

void initFetchFrenzyPositions() {
  fetchPlayerX = width/2;
  fetchPlayerY = height/2;
}

RectHB rotatedGatorHB(RectHB hb, String dir) {
  float ox = hb.offX, oy = hb.offY;
  float w = hb.w, h = hb.h;

  if (dir.equals("UP")) {
    return new RectHB(ox, oy, w, h);
  } else if (dir.equals("RIGHT")) {
    return new RectHB(-oy, ox, h, w);
  } else if (dir.equals("DOWN")) {
    return new RectHB(-ox, -oy, w, h);
  } else if (dir.equals("LEFT")) {
    return new RectHB(oy, -ox, h, w);
  }
  return new RectHB(ox, oy, w, h);
}

void fetchfrenzy() {
  imageMode(CENTER);
  image(fetchfrenzybackground, width/2, height/2, width, height);
  
  if (isBallOnField) updateBall();
  if (isBallOnField && !isFetchLost) fetchTimer -= 1.0/60.0;
  if (!hasBallBeenLaunched && !isFetchLost) {
    launchBall();
    hasBallBeenLaunched = true;
  }
  
  if (!isFetchLost) tickMinigameStats();
  
  walkanimation();

  RectHB gatorHBRot = rotatedGatorHB(gatorHB, fetchFacingDirection);

  wasBallHittingPlayer = ballHitsPlayer;
  ballHitsPlayer = hitRectRectCenter(ballX, ballY - ballZ, ballHB, fetchPlayerX, fetchPlayerY, gatorHBRot);
  
if (ballHitsPlayer && !wasBallHittingPlayer && isBallOnField && !isBallWaitingToLaunch) {
  isBallOnField = false;
  fetchScore++;
  earnMinigameMoney(moneyPerMinigamePoint);
  isBallWaitingToLaunch = true;
  ballLaunchCountdown = LAUNCH_DELAY;
}

if (isBallWaitingToLaunch) {
  ballLaunchCountdown--;

  if (ballLaunchCountdown <= 0) {
    launchBall();
    fetchTimer=3;
    isBallOnField = true;
    isBallWaitingToLaunch = false;
  }
}

  strokeWeight(1);
  stroke(0);
  rectMode(CORNER);
  textAlign(LEFT,CENTER);
  textFont(arcade);
  fill(255);
  text("Score: " + fetchScore, width*0.015, 30);
  text("Time: " + nf(fetchTimer, 0, 2), width*0.015, 70);
  drawMinigameStats();
  drawMinigameExitButton();
  
  if (fetchScore>fetchBestScore) fetchBestScore=fetchScore;
  if (fetchTimer<=0) {
    isFetchLost=true;
    fetchTimer=0;
  }
  if (isFetchLost) {
    if (!isFetchFirstPlay) {
      drawMinigameModal("YOU LOST!", "High Score: " + fetchBestScore, "", "", "RETRY", "EXIT");
    } else {
      drawMinigameModal("WELCOME", "Fetch the ball in the", "allotted time using WASD", "or the arrow keys!", "PLAY", "EXIT");
    }
    stroke(0);
  }
}

void walkanimation() {
  if (!isFetchLost) {
    if (fetchFacingDirection.equals("LEFT")) {
      fetchPlayerX -= 5;
    } else if (fetchFacingDirection.equals("RIGHT")) {
      fetchPlayerX += 5;
    } else if (fetchFacingDirection.equals("UP")) {
      fetchPlayerY -= 5;
    } else if (fetchFacingDirection.equals("DOWN")) {
      fetchPlayerY += 5;
    }
  }

  if (fetchFacingDirection.equals("DOWN")  && fetchPlayerY > 395 && fetchPlayerX > 456 && fetchPlayerX < 631) fetchPlayerY = 394;
  if (fetchFacingDirection.equals("RIGHT") && fetchPlayerY > 504 && fetchPlayerX > 371 && fetchPlayerX < 500) fetchPlayerX = 371;
  if (fetchFacingDirection.equals("LEFT")  && fetchPlayerY > 504 && fetchPlayerX > 600 && fetchPlayerX < 746) fetchPlayerX = 747;

  // boundary margins match the sprite edge so the alligator never walks off-screen
  if (fetchPlayerY < 96) fetchPlayerY = 97;
  if (fetchPlayerX < 100) fetchPlayerX = 101;
  if (fetchPlayerX > 1000) fetchPlayerX = 999;
  if (fetchPlayerY > (height - 96)) fetchPlayerY = height - 97;

  pushMatrix();
  translate(fetchPlayerX, fetchPlayerY);

  if (fetchFacingDirection.equals("DOWN")) {
    rotate(radians(180));
  } else if (fetchFacingDirection.equals("RIGHT")) {
    rotate(radians(90));
  } else if (fetchFacingDirection.equals("LEFT")) {
    rotate(radians(270));
  }
  
  if (!isFetchLost) {
  applyAlligatorTint();
  fetchWalkFrameTimer++;
  // 7-frame animation cycle gives natural walking cadence: frames 0-6 show pose 1, frames 7-13 show pose 2, then reset
  if (fetchWalkFrameTimer < 7) {
    image(topalligator1, 0, 0, topalligator1.width/4, topalligator1.height/4);
  } else if (fetchWalkFrameTimer < 14) {
    image(topalligator2, 0, 0, topalligator2.width/4, topalligator2.height/4);
  } else {
    fetchWalkFrameTimer = 0;
    image(topalligator1, 0, 0, topalligator1.width/4, topalligator1.height/4);
  }
  noTint();
  }
  
  popMatrix();
}

void launchBall() {
  ballX = 548;
  ballY = 618;

  float speed = 11;                  // launch speed that gives a satisfying arc across the play field
  float baseAngle = -HALF_PI;        // launch straight up with 180 deg spread so the ball always lands somewhere in the play area
  float spread = radians(180);       // 180 deg total spread means the ball can go anywhere in the upper half of the field
  float angle = baseAngle + random(-spread, spread);

  ballVelocityX = cos(angle) * speed;
  ballVelocityY = sin(angle) * speed;

  ballZ = 0;
  ballVerticalVelocity = 22;

  isBallMoving = true;
}

void updateBall() {
  float ballW = ball.width / 10.0;
  float ballH = ball.height / 10.0;
  float halfW = ballW * 0.5;
  float halfH = ballH * 0.5;

  if (isBallMoving) {
    ballVerticalVelocity -= ballGravity;
    ballZ  += ballVerticalVelocity;

    ballX += ballVelocityX;
    ballY += ballVelocityY;

    ballVelocityX *= ballAirDrag;
    ballVelocityY *= ballAirDrag;

    if (ballZ <= 0) {
      ballZ = 0;

      if (abs(ballVerticalVelocity) > ballStopBounceThreshold) ballVerticalVelocity = -ballVerticalVelocity * ballBounceFactor;
      else ballVerticalVelocity = 0;

      ballVelocityX *= ballGroundFriction;
      ballVelocityY *= ballGroundFriction;

      if (ballVerticalVelocity == 0 && abs(ballVelocityX) < ballStopSpeedThreshold && abs(ballVelocityY) < ballStopSpeedThreshold) {
        ballVelocityX = 0;
        ballVelocityY = 0;
        isBallMoving = false;
      }
    }

    if (ballX - halfW < 0)        { ballX = halfW;        ballVelocityX *= -0.8; }
    if (ballX + halfW > width)    { ballX = width-halfW;  ballVelocityX *= -0.8; }
    if (ballY - halfH < 0)        { ballY = halfH;        ballVelocityY *= -0.8; }
    if (ballY + halfH > height)   { ballY = height-halfH; ballVelocityY *= -0.8; }
  }

  float maxHeight = 70.0;
  float zN = constrain(ballZ / maxHeight, 0, 1);

  float baseShadow = ballW * 0.45;
  float shadowGrow = ballW * 0.15;
  float shadowSize = baseShadow + shadowGrow * zN;

  float shadowAlpha = 120 - (60 * zN);

  noStroke();
  fill(0, shadowAlpha);
  ellipse(ballX, ballY, shadowSize, shadowSize);

  image(ball, ballX, ballY - ballZ, ballW, ballH);
}

boolean hitRectRectCenter(float aCx, float aCy, RectHB a, float bCx, float bCy, RectHB b) {
  float aX = aCx + a.offX;
  float aY = aCy + a.offY;
  float bX = bCx + b.offX;
  float bY = bCy + b.offY;

  float aHalfW = a.w * 0.5;
  float aHalfH = a.h * 0.5;
  float bHalfW = b.w * 0.5;
  float bHalfH = b.h * 0.5;

  return (abs(aX - bX) < (aHalfW + bHalfW) &&
          abs(aY - bY) < (aHalfH + bHalfH));
}

void resetFetchFrenzy() {
  fetchTimer=3; 
  fetchScore=0;
  fetchPlayerX = width/2;
  fetchPlayerY = height*0.25;
  isFetchLost = false;
  hasBallBeenLaunched = false;
}
