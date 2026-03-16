// =========================
// H_Play_Screen.pde
// Three minigames: Swamp Hop, Snack Snatch, and Fetch Frenzy.
// Each minigame awards money based on moneyPerMinigamePoint (upgradeable in the Earn panel).
// All three share earnMinigameMoney(), tickMinigameStats(), and drawMinigameModal().
// =========================

Fade minigameFade = new Fade(255);  // starts black on minigame entry; fades to clear as game begins

// =========================
// Minigame helper functions
// =========================

// Adds money earned in a minigame to all relevant counters

// =========================
// Additional Global State (moved to top for clarity)
// =========================
boolean isOnChoiceScreen = false;   // true while the player is on the minigame selection screen
boolean isEnterSwampHop = false;    // set true when player picks Swamp Hop
PImage minigamechoice;            // background image for the minigame selection screen
PImage alligatorf1;
PImage alligatorf2;
PImage alligatorf3;
PImage alligatorf4;
PImage log;
PImage rock;
PImage vine;
PImage mud;
int walkAnimFrameDelay = 6;    // frames to hold each sprite before advancing
float x = 224;          // Alligator's fixed horizontal position on screen
float y = 500;          // Vertical position; changes during jumps
float hopGravity = 1.2;    // Acceleration applied to hopVelocityY each frame
float hopJumpStrength = 20; // Upward impulse applied when SPACE is pressed
boolean isSwampHopOnGround = true;           // Prevents double-jumping
boolean isSwampHopRetry        = false;        // Set true when player clicks RETRY
boolean isExitingMinigame = false;                // Set true when player clicks EXIT to return to main screen
boolean isSwampHopFirstPlay = true; // True on first entry — shows "WELCOME!" modal instead of "YOU LOST!"
boolean isEnterFetchFrenzy = false;    // Set true when player picks Fetch Frenzy
int swampHopGraceFrames = 0;            // Prevents immediate collision detection on isSwampHopRetry
int swampHopSpawnDelay = 0;       // Delays first obstacle spawn after a isSwampHopRetry
boolean isEnterSnackSnatch = false;    // Set true when player picks Snack Snatch
ArrayList<Obstacle> swampHopObstacles = new ArrayList<Obstacle>(); // Active obstacle list
float obstacleSpawnGap = 900;    // Minimum pixel gap between consecutive swampHopObstacles
float nextObstacleX = 0;       // X position at which the next obstacle will be spawned
float hopGatorHitboxWidth = 0.70;   // 70% of sprite width
float hopGatorHitboxHeight = 0.45;   // 45% of sprite height
float vineHitboxWidth = 0.45;
float vineHitboxHeight = 0.85;
float vineHitboxOffsetY = -10;
float rockHitboxWidth = 0.75;
float rockHitboxHeight = 0.55;
float rockHitboxOffsetY = 0;
float mudHitboxWidth = 0.75;
float mudHitboxHeight = 0.55;
float mudHitboxOffsetY = 0;
float logHitboxWidth = 1.0;
float logHitboxHeight = 0.7;
float logHitboxOffsetY = 0;
float swampHopScoreTimer = 0;    // Counts frames; every 60 frames = 1 point + moneyPerMinigamePoint earned
int snatchScore = 0;               // Current run score for Snack Snatch
float swampHopBgScrollX = 0;
float swampHopScrollSpeed = 16;
float swampHopBgWidth;
float swampHopBgHeight;
PImage bluegill;
PImage bass;
PImage perch;
PImage goldfish;
PImage crab;
PImage lambchop;
PImage porkchop;
PImage broccoli;
PImage carrot;
PImage tomato;
PImage pepper;
ArrayList<FallingFood> fallingFoods = new ArrayList<FallingFood>();
boolean isSnatchFirstPlay = true;
boolean isSnatchLost = true;
int snatchBestScore = 0;
float snatchGatorWidthMult = 0.600; // fraction of sprite width used for collision
float snatchGatorHeightMult = 0.240; // fraction of sprite height used for collision
float snatchGatorOffsetX = -4.0;     // horizontal center offset in pixels
float bluegillW=0.520, bluegillH=0.380, bluegillOX=-2, bluegillOY=-4;
float bassW=0.560, bassH=0.400, bassOX=4, bassOY=-8;
float perchW=0.580, perchH=0.360, perchOX=0, perchOY=-2;
float goldfishW=0.520, goldfishH=0.380, goldfishOX=-2, goldfishOY=-4;
float crabW=0.600, crabH=0.360, crabOX=0, crabOY=-4;
float lambchopW=0.420, lambchopH=0.340, lambchopOX=-8, lambchopOY=8;
float porkchopW=0.500, porkchopH=0.420, porkchopOX=0, porkchopOY=0;
float broccoliW=0.540, broccoliH=0.620, broccoliOX=2, broccoliOY=-4;
float carrotW=0.380, carrotH=0.540, carrotOX=-6, carrotOY=8;
float tomatoW=0.380, tomatoH=0.480, tomatoOX=2, tomatoOY=-2;
float pepperW=0.340, pepperH=0.540, pepperOX=2, pepperOY=-4;
PImage fetchfrenzybackground;
PImage ball;
float ballX = 548, ballY = 618;
float ballVelocityX = 0, ballVelocityY = 0;
float ballZ = 0;
float ballVerticalVelocity = 0;
boolean isBallMoving = false;
float ballGravity = 1.0;
float ballBounceFactor = 0.55;
float ballAirDrag = 0.995;
float ballGroundFriction = 0.92;
float ballStopSpeedThreshold = 0.15;
float ballStopBounceThreshold = 0.6;
PImage topalligator1, topalligator2;
int fetchWalkFrameTimer = 0;
float fetchPlayerX = 0;
float fetchPlayerY = 0;
String fetchFacingDirection = "RIGHT";
boolean ballHitsPlayer = false;
boolean wasBallHittingPlayer = false;
boolean hasBallBeenLaunched = false;
int fetchScore=0;
int fetchBestScore=0;
float fetchTimer=3;
RectHB ballHB  = new RectHB(0, -0.50, 36.00, 37.00);
RectHB gatorHB = new RectHB(0, -42.00, 95.00, 144.00);
boolean isBallWaitingToLaunch = false;
int ballLaunchCountdown = 0;
final int LAUNCH_DELAY = 30;
boolean isBallOnField = true;
boolean isFetchLost = true;
boolean isFetchFirstPlay = true;
void earnMinigameMoney(float amount) {
  money += amount;
  currentPlaySessionMoneyEarned += amount;
  totalMoneyEarned += amount;
  moneyEarnedFromMinigames += amount;
}

// Drains energy, boosts happiness each frame during active gameplay
void tickMinigameStats() {
  alligator.energy    -= 0.01;
  alligator.happiness += 0.01;
  totalHappinessRestored += 0.01;
}

// Draws the lose/welcome modal shared by all three minigames.
// title/sub1/sub2/sub3 are the header and instruction lines (empty string = skip).
// leftBtn / rightBtn are the button labels.
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

// Draws the stat bars overlay shown during all three minigames
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
// Swamp Hop — Assets
// =========================
PImage swamphopbackground;  // Scrolling background image (drawn twice for seamless loop)

// Four-frame walk cycle sprites for the side-scrolling alligator character
// Obstacle sprites (randomly spawned, each with unique hitbox tuning)

// =========================
// Swamp Hop — Animation State
// =========================
int walkAnimFrameIndex = 1;    // current walk-cycle frame (1–4)
int walkAnimFrameTimer = 0;  // counts up each draw() call; resets at walkAnimFrameDelay


// =========================
// Swamp Hop — Physics
// =========================
float hopVelocityY = 0;    // Current downward velocity (increases each frame by hopGravity)
float hopGroundY;          // Calculated ground threshold (set each frame based on sprite height)


// =========================
// Swamp Hop — Game State
// =========================
boolean isSwampHopLost = true;         // True = showing lose/welcome modal (not actively playing)

// =========================
// Swamp Hop — Obstacle Spawning
// =========================

// =========================
// Swamp Hop — Hitbox Multipliers
// Each obstacle type has its own width/height/Y-offset tuning so collision feels fair.
// Values are fractions of the sprite's actual drawn size (1.0 = full size).
// =========================

// Alligator hitbox (slightly inset so near-misses feel forgiving)
float hopGatorHitboxOffsetY = -8;     // shift upward from sprite center (pixels)

// Vine hitbox (tall but narrow — hangs from above)
// Rock hitbox (wide and low — sits on ground)
// Mud hitbox (same as rock — ground obstacle)
// Log hitbox (full width, slightly reduced height)
// =========================
// Swamp Hop — Scoring
// =========================
int swampHopScore = 0;                  // Current run score (increments once per second survived)
int swampHopBestScore = 0;              // All-time best score across all runs (persisted to save)
float moneyPerMinigamePoint = 0;              // Dollars earned per minigame point (upgradeable in Earn panel)

// =========================
// Snack Snatch — Scoring
// =========================
// =========================
// Fetch Frenzy — Player Position
// =========================
float snatchPlayerX = 550;            // Horizontal position of the alligator in Fetch Frenzy (top-down)

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
    nextObstacleX = width + 200;
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

  if (swampHopGraceFrames > 0) swampHopGraceFrames--;

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

  while (swampHopObstacles.size() < 6) {
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
    fallSpeed = random(4, 8);
    angle = random(TWO_PI);
    rotationSpeed = random(-0.1, 0.1);
    if (abs(rotationSpeed) < 0.03) rotationSpeed = (rotationSpeed < 0 ? -0.05 : 0.05);
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
float snatchGatorOffsetY = -20.0;    // vertical center offset in pixels (shifted up toward mouth)

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

  wasBallHittingPlayer = ballHitsPlayer;
  
  strokeWeight(1);
  stroke(0);
  rectMode(CORNER);
  textAlign(LEFT,CENTER);
  textFont(arcade);
  fill(255);
  text("Score: " + fetchScore, width*0.015, 30);
  text("Time: " + nf(fetchTimer, 0, 2), width*0.015, 70);
  drawMinigameStats();
  
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
  if (fetchFacingDirection.equals("DOWN")  && fetchPlayerY > 395 && fetchPlayerX > 456 && fetchPlayerX < 631) fetchPlayerY = 394;
  if (fetchFacingDirection.equals("RIGHT") && fetchPlayerY > 504 && fetchPlayerX > 371 && fetchPlayerX < 500) fetchPlayerX = 371;
  if (fetchFacingDirection.equals("LEFT")  && fetchPlayerY > 504 && fetchPlayerX > 600 && fetchPlayerX < 746) fetchPlayerX = 747;

  if (fetchPlayerY < 96) fetchPlayerY = 97;
  if (fetchPlayerX < 100) fetchPlayerX = 101;
  if (fetchPlayerX > 1000) fetchPlayerX = 999;
  if (fetchPlayerY > (height - 96)) fetchPlayerY = height - 97;
  
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

  float speed = 11;
  float baseAngle = -HALF_PI;
  float spread = radians(180);
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
