// =========================
// H_Play_Screen.pde
// Three minigames: Swamp Hop, Snack Snatch, and Fetch Frenzy.
// Each minigame awards money based on moneyperpt (upgradeable in the Earn panel).
// All three share earnMinigameMoney(), tickMinigameStats(), and drawMinigameModal().
// =========================

Fade minigameFade = new Fade(255);  // starts black on minigame entry; fades to clear as game begins

// =========================
// Minigame helper functions
// =========================

// Adds money earned in a minigame to all relevant counters
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
boolean onchoicescreen = false;   // true while the player is on the minigame selection screen
boolean enterswamphop = false;    // set true when player picks Swamp Hop
PImage minigamechoice;            // background image for the minigame selection screen


// =========================
// Swamp Hop — Assets
// =========================
PImage swamphopbackground;  // Scrolling background image (drawn twice for seamless loop)

// Four-frame walk cycle sprites for the side-scrolling alligator character
PImage alligatorf1;
PImage alligatorf2;
PImage alligatorf3;
PImage alligatorf4;

// Obstacle sprites (randomly spawned, each with unique hitbox tuning)
PImage log;
PImage rock;
PImage vine;
PImage mud;


// =========================
// Swamp Hop — Animation State
// =========================
int frameIndex = 1;    // current walk-cycle frame (1–4)
int frameDelay = 6;    // frames to hold each sprite before advancing
int frameCounter = 0;  // counts up each draw() call; resets at frameDelay


// =========================
// Swamp Hop — Physics
// =========================
float x = 224;          // Alligator's fixed horizontal position on screen
float y = 500;          // Vertical position; changes during jumps
float velocityY = 0;    // Current downward velocity (increases each frame by gravity)
float gravity = 1.2;    // Acceleration applied to velocityY each frame
float jumpStrength = 20; // Upward impulse applied when SPACE is pressed
float groundY;          // Calculated ground threshold (set each frame based on sprite height)


// =========================
// Swamp Hop — Game State
// =========================
boolean isOnGround = true;           // Prevents double-jumping
boolean swamphoplost = true;         // True = showing lose/welcome modal (not actively playing)
boolean retry        = false;        // Set true when player clicks RETRY
boolean exit = false;                // Set true when player clicks EXIT to return to main screen
boolean swamphopinstructions = true; // True on first entry — shows "WELCOME!" modal instead of "YOU LOST!"
boolean enterfetchfrenzy = false;    // Set true when player picks Fetch Frenzy
int retryGraceFrames = 0;            // Prevents immediate collision detection on retry
int retrySpawnDelayFrames = 0;       // Delays first obstacle spawn after a retry
boolean entersnacksnatch = false;    // Set true when player picks Snack Snatch


// =========================
// Swamp Hop — Obstacle Spawning
// =========================
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>(); // Active obstacle list
float obstacleGap = 900;    // Minimum pixel gap between consecutive obstacles
float nextSpawnX = 0;       // X position at which the next obstacle will be spawned


// =========================
// Swamp Hop — Hitbox Multipliers
// Each obstacle type has its own width/height/Y-offset tuning so collision feels fair.
// Values are fractions of the sprite's actual drawn size (1.0 = full size).
// =========================

// Alligator hitbox (slightly inset so near-misses feel forgiving)
float gatorHBW = 0.70;   // 70% of sprite width
float gatorHBH = 0.45;   // 45% of sprite height
float gatorHBY = -8;     // shift upward from sprite center (pixels)

// Vine hitbox (tall but narrow — hangs from above)
float vineHBW = 0.45;
float vineHBH = 0.85;
float vineHBY = -10;

// Rock hitbox (wide and low — sits on ground)
float rockHBW = 0.75;
float rockHBH = 0.55;
float rockHBY = 0;

// Mud hitbox (same as rock — ground obstacle)
float mudHBW = 0.75;
float mudHBH = 0.55;
float mudHBY = 0;

// Log hitbox (full width, slightly reduced height)
float logHBW = 1.0;
float logHBH = 0.7;
float logHBY = 0;

// =========================
// Swamp Hop — Scoring
// =========================
int hopscore = 0;                  // Current run score (increments once per second survived)
int besthopscore = 0;              // All-time best score across all runs (persisted to save)
float hopscoreframecounter = 0;    // Counts frames; every 60 frames = 1 point + moneyperpt earned
float moneyperpt = 0;              // Dollars earned per minigame point (upgradeable in Earn panel)

// =========================
// Snack Snatch — Scoring
// =========================
int snatchscore = 0;               // Current run score for Snack Snatch

// =========================
// Fetch Frenzy — Player Position
// =========================
float alligatorx = 550;            // Horizontal position of the alligator in Fetch Frenzy (top-down)

void resetSwampHop() {
  swamphoplost = false;
  retry = false;
  hopscore = 0;
  hopscoreframecounter = 0;
  
  x = 224;
  y = 500;
  velocityY = 0;
  isOnGround = true;

  swamphopSpeed = 16;
  swamphopBgX = 0;

  obstacles.clear();
  nextSpawnX = width + 600;

  retryGraceFrames = 45;
  retrySpawnDelayFrames = 30;
}

void play() {
  onchoicescreen=true;
  fill(255,0,0);
  rect(0,0,width,height);

  imageMode(CENTER);
  image(minigamechoice, width/2, height*0.52,
        (minigamechoice.width/1.4)*1.01, minigamechoice.height/1.4);
  
  if (enterswamphop) {

    onchoicescreen = false;
    swamphop();
    minigameFade.stepIn(6);  // fade from black to clear as game starts

  } else if (entersnacksnatch) {

    onchoicescreen = false;
    snacksnatch();
    minigameFade.stepIn(6);

  } else if (enterfetchfrenzy) {

    onchoicescreen = false;
    fetchfrenzy();
    minigameFade.stepIn(6);

  } else {

    onchoicescreen = true;
    minigameFade.stepIn(3);  // choice screen fades in slightly slower

  }

  // Draw the fade overlay on top of everything
  rectMode(CORNER);
  minigameFade.draw();
}


float swamphopBgX = 0;
float swamphopSpeed = 16;
float bgW;
float bgH;

void swamphop() {

  bgW = swamphopbackground.width / 1.38;
  bgH = swamphopbackground.height / 1.38;
  
  imageMode(CORNER);
  image(swamphopbackground, swamphopBgX, 0, bgW, bgH);
  image(swamphopbackground, swamphopBgX + bgW, 0, bgW, bgH);
  
  
  strokeWeight(1);
  stroke(0);
  rectMode(CORNER);
  textAlign(LEFT,CENTER);
  textFont(arcade);
  fill(255);
  text("Score: " + hopscore, width*0.015, 54);
  drawMinigameStats();
  
  if (swamphoplost) {
    
    obstacles.clear();
    nextSpawnX = width + 600;
    imageMode(CENTER);

    for (int i = 0; i < obstacles.size(); i++) {
      Obstacle o = obstacles.get(i);
      o.drawObstacle();
    }
    applyAlligatorTint();
    image(alligatorf1, x, y, alligatorf1.width/1.5, alligatorf1.height/1.5);
    noTint();
    if (hopscore > besthopscore) besthopscore = hopscore;
    if (!swamphopinstructions) {
      drawMinigameModal("YOU LOST!", "High Score: " + besthopscore, "", "", "RETRY", "EXIT");
    } else {
      drawMinigameModal("WELCOME!", "Click space to hop!", "", "", "PLAY", "EXIT");
    }

    strokeWeight(1);
    stroke(0);
    rectMode(CORNER);
    return;
  }
  stroke(0);

  hopscoreframecounter++;
  if (hopscoreframecounter % 60 == 0) {
    hopscore++;
    earnMinigameMoney(moneyperpt);
  }
  if (isOnGround && !swamphoplost) {
    swamphopSpeed = 16;
  } else if (!swamphoplost) {
    swamphopSpeed = 22;
  }

  imageMode(CORNER);
  if (!swamphoplost) tickMinigameStats();
  
  swamphopBgX -= swamphopSpeed;
  if (swamphopBgX <= -bgW) swamphopBgX = 0;

  float halfH = (alligatorf1.height/1.5) / 2.0;
  groundY = 500 + halfH;

  velocityY += gravity;
  y += velocityY;

  if (y + halfH >= groundY) {
    y = groundY - halfH;
    velocityY = 0;
    isOnGround = true;
  }
  
  
  imageMode(CENTER);

  frameCounter++;
  if (frameCounter >= frameDelay) {
    frameCounter = 0;
    frameIndex++;
    if (frameIndex > 4) {
      frameIndex = 1;
    }
  }
  
  applyAlligatorTint();
  if (frameIndex == 1) {
    image(alligatorf1, x, y, alligatorf1.width/1.5, alligatorf1.height/1.5);
  } 
  else if (frameIndex == 2) {
    image(alligatorf2, x, y, alligatorf2.width/1.5, alligatorf2.height/1.5);
  } 
  else if (frameIndex == 3) {
    image(alligatorf3, x, y, alligatorf3.width/1.5, alligatorf3.height/1.5);
  } 
  else if (frameIndex == 4) {
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
  if (obstacles.size() == 0) {
    nextSpawnX = width + 200;
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
    oy = groundY - oh/2;
  }

  obstacles.add(new Obstacle(img, nextSpawnX, oy, ow, oh));
  nextSpawnX += obstacleGap;
}

void updateAndDrawObstacles() {
  if (swamphoplost) return;

  if (retryGraceFrames > 0) retryGraceFrames--;

  if (retrySpawnDelayFrames > 0) {
    retrySpawnDelayFrames--;
    return;
  }

  initObstaclesIfNeeded();

  float gatorW = alligatorf1.width/1.5;
  float gatorH = alligatorf1.height/1.5;

  float gHitW = gatorW * 0.760;
  float gHitH = gatorH * 0.300;
  float gCenterX = x - 24.0;
  float gCenterY = y + 12.0;

  for (int i = obstacles.size()-1; i >= 0; i--) {
    Obstacle o = obstacles.get(i);
    o.update(swamphopSpeed);
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

    if (collisionX && collisionY && retryGraceFrames == 0) {
      swamphoplost = true;
    }

    if (o.offscreen()) {
      obstacles.remove(i);
    }
  }

  while (obstacles.size() < 6) {
    spawnObstacle();
  }
}

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

boolean snacksnatchinstructions = true;

void snacksnatch() {
  entersnacksnatch=true;
  if (!snacksnatchlost) {
  if (moveLeft) {
    alligatorx -= 10;
  }

  if (moveRight) {
    alligatorx += 10;
  }
  }
  if (alligatorx < 140) alligatorx = 140;
  if (alligatorx > 960) alligatorx = 960;
  
  if (!snacksnatchlost) tickMinigameStats();
  
  imageMode(CORNER);
  image(mainscreen, 0, 0, width, height);

  imageMode(CENTER);
  applyAlligatorTint();
  image(alligator.energeticalligator, alligatorx, 572,
        alligator.energeticalligator.width/4, alligator.energeticalligator.height/4);
  noTint();

  updateSnackSnatchFalling();

  strokeWeight(1);
  stroke(0);
  rectMode(CORNER);
  textAlign(LEFT, CENTER);
  textFont(arcade);
  fill(255);
  text("Score: " + snatchscore, width*0.015, 54);
  drawMinigameStats();
  
  if (snacksnatchlost) {
    if (snatchscore > bestsnatchscore) bestsnatchscore = snatchscore;
    if (!snacksnatchinstructions) {
      drawMinigameModal("YOU LOST!", "High Score: " + bestsnatchscore, "", "", "RETRY", "EXIT");
    } else {
      drawMinigameModal("WELCOME", "Catch food, dodge veggies!", "Use A/D or the right and", "left arrow keys to move.", "PLAY", "EXIT");
    }
    stroke(0);
  }
}

void updateSnackSnatchFalling() {
  if (snacksnatchlost) return;

  if (fallingFoods.size() == 0) {
    fallingFoods.add(new FallingFood(randomFood()));
  }

  for (int i = fallingFoods.size()-1; i >= 0; i--) {
    FallingFood f = fallingFoods.get(i);
    f.update();
    float gW = alligator.energeticalligator.width/4.0;
    float gH = alligator.energeticalligator.height/4.0;
    
    float gCenterX = alligatorx + gatorOX;
    float gCenterY = 572 + gatorOY;
    
    float gHitW = gW * gatorWMult;
    float gHitH = gH * gatorHMult;
    
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
        snacksnatchlost = true;
      } else {
        snatchscore++;
        earnMinigameMoney(moneyperpt);
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
        snacksnatchlost = true;
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

boolean snacksnatchlost = true;
int bestsnatchscore = 0;

// =========================
// Snack Snatch Hitbox Tuning
// Each variable pair (W/H) scales the hitbox relative to the sprite size.
// Each pair (OX/OY) offsets the hitbox center from the sprite center.
// Values were hand-tuned to match each sprite's visual footprint.
// =========================

// Alligator catcher hitbox (applied to the player character)
float gatorWMult = 0.600; // fraction of sprite width used for collision
float gatorHMult = 0.240; // fraction of sprite height used for collision
float gatorOX = -4.0;     // horizontal center offset in pixels
float gatorOY = -20.0;    // vertical center offset in pixels (shifted up toward mouth)

// Per-food hitbox tuning (W/H = size fraction, OX/OY = center offset)
float bluegillW=0.520, bluegillH=0.380, bluegillOX=-2, bluegillOY=-4;
float bassW=0.560, bassH=0.400, bassOX=4, bassOY=-8;
float perchW=0.580, perchH=0.360, perchOX=0, perchOY=-2;
float goldfishW=0.520, goldfishH=0.380, goldfishOX=-2, goldfishOY=-4;
float crabW=0.600, crabH=0.360, crabOX=0, crabOY=-4;
float lambchopW=0.420, lambchopH=0.340, lambchopOX=-8, lambchopOY=8;
float porkchopW=0.500, porkchopH=0.420, porkchopOX=0, porkchopOY=0;
// Vegetables (touching these causes a loss)
float broccoliW=0.540, broccoliH=0.620, broccoliOX=2, broccoliOY=-4;
float carrotW=0.380, carrotH=0.540, carrotOX=-6, carrotOY=8;
float tomatoW=0.380, tomatoH=0.480, tomatoOX=2, tomatoOY=-2;
float pepperW=0.340, pepperH=0.540, pepperOX=2, pepperOY=-4;

void resetSnackSnatch() {
  snatchscore = 0;
  snacksnatchlost = false;
  snacksnatchinstructions = false;
  fallingFoods.clear();
  fallingFoods.add(new FallingFood(randomFood()));
  alligatorx=width/2;
}

PImage fetchfrenzybackground;
PImage ball;

float ballX = 548, ballY = 618;
float ballVX = 0, ballVY = 0;

float ballZ = 0;
float ballVZ = 0;

boolean ballActive = false;

float gZ = 1.0;
float restitution = 0.55;
float airDrag = 0.995;
float groundFriction = 0.92;

float stopSpeed = 0.15;
float stopBounce = 0.6;

PImage topalligator1, topalligator2;
int topalligatorframecounter = 0;

float topalligatorx = 0;
float topalligatory = 0;

String lastturn = "RIGHT";

boolean ballHitsGator = false;
boolean ballHitsGatorPrev = false;

boolean firstlaunch = false;

int fetchscore=0;
int bestfetchscore=0;
float fetchtimer=3;

RectHB ballHB  = new RectHB(0, -0.50, 36.00, 37.00);
RectHB gatorHB = new RectHB(0, -42.00, 95.00, 144.00);

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
  topalligatorx = width/2;
  topalligatory = height/2;
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

boolean waitingToLaunch = false;
int launchCooldown = 0;
final int LAUNCH_DELAY = 30;
boolean ballExists = true;
boolean fetchfrenzylost = true;
boolean fetchfrenzyinstructions = true;

void fetchfrenzy() {
  imageMode(CENTER);
  image(fetchfrenzybackground, width/2, height/2, width, height);
  
  if (ballExists) updateBall();
  if (ballExists && !fetchfrenzylost) fetchtimer -= 1.0/60.0;
  if (!firstlaunch && !fetchfrenzylost) {
    launchBall();
    firstlaunch = true;
  }
  
  if (!fetchfrenzylost) tickMinigameStats();
  
  walkanimation();

  RectHB gatorHBRot = rotatedGatorHB(gatorHB, lastturn);

  ballHitsGatorPrev = ballHitsGator;
  ballHitsGator = hitRectRectCenter(ballX, ballY - ballZ, ballHB, topalligatorx, topalligatory, gatorHBRot);
  
if (ballHitsGator && !ballHitsGatorPrev && ballExists && !waitingToLaunch) {
  ballExists = false;
  fetchscore++;
  earnMinigameMoney(moneyperpt);
  waitingToLaunch = true;
  launchCooldown = LAUNCH_DELAY;
}

if (waitingToLaunch) {
  launchCooldown--;

  if (launchCooldown <= 0) {
    launchBall();
    fetchtimer=3;
    ballExists = true;
    waitingToLaunch = false;
  }
}

  ballHitsGatorPrev = ballHitsGator;
  
  strokeWeight(1);
  stroke(0);
  rectMode(CORNER);
  textAlign(LEFT,CENTER);
  textFont(arcade);
  fill(255);
  text("Score: " + fetchscore, width*0.015, 30);
  text("Time: " + nf(fetchtimer, 0, 2), width*0.015, 70);
  drawMinigameStats();
  
  if (fetchscore>bestfetchscore) bestfetchscore=fetchscore;
  if (fetchtimer<=0) {
    fetchfrenzylost=true;
    fetchtimer=0;
  }
  if (fetchfrenzylost) {
    if (!fetchfrenzyinstructions) {
      drawMinigameModal("YOU LOST!", "High Score: " + bestfetchscore, "", "", "RETRY", "EXIT");
    } else {
      drawMinigameModal("WELCOME", "Fetch the ball in the", "allotted time using WASD", "or the arrow keys!", "PLAY", "EXIT");
    }
    stroke(0);
  }
}

void walkanimation() {
  if (lastturn.equals("DOWN")  && topalligatory > 395 && topalligatorx > 456 && topalligatorx < 631) topalligatory = 394;
  if (lastturn.equals("RIGHT") && topalligatory > 504 && topalligatorx > 371 && topalligatorx < 500) topalligatorx = 371;
  if (lastturn.equals("LEFT")  && topalligatory > 504 && topalligatorx > 600 && topalligatorx < 746) topalligatorx = 747;

  if (topalligatory < 96) topalligatory = 97;
  if (topalligatorx < 100) topalligatorx = 101;
  if (topalligatorx > 1000) topalligatorx = 999;
  if (topalligatory > (height - 96)) topalligatory = height - 97;
  
  if (!fetchfrenzylost) {
  if (lastturn.equals("LEFT")) {
    topalligatorx -= 5;
  } else if (lastturn.equals("RIGHT")) {
    topalligatorx += 5;
  } else if (lastturn.equals("UP")) {
    topalligatory -= 5;
  } else if (lastturn.equals("DOWN")) {
    topalligatory += 5;
  }
  }

  pushMatrix();
  translate(topalligatorx, topalligatory);

  if (lastturn.equals("DOWN")) {
    rotate(radians(180));
  } else if (lastturn.equals("RIGHT")) {
    rotate(radians(90));
  } else if (lastturn.equals("LEFT")) {
    rotate(radians(270));
  }
  
  if (!fetchfrenzylost) {
  applyAlligatorTint();
  topalligatorframecounter++;
  if (topalligatorframecounter < 7) {
    image(topalligator1, 0, 0, topalligator1.width/4, topalligator1.height/4);
  } else if (topalligatorframecounter < 14) {
    image(topalligator2, 0, 0, topalligator2.width/4, topalligator2.height/4);
  } else {
    topalligatorframecounter = 0;
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

  ballVX = cos(angle) * speed;
  ballVY = sin(angle) * speed;

  ballZ = 0;
  ballVZ = 22;

  ballActive = true;
}

void updateBall() {
  float ballW = ball.width / 10.0;
  float ballH = ball.height / 10.0;
  float halfW = ballW * 0.5;
  float halfH = ballH * 0.5;

  if (ballActive) {
    ballVZ -= gZ;
    ballZ  += ballVZ;

    ballX += ballVX;
    ballY += ballVY;

    ballVX *= airDrag;
    ballVY *= airDrag;

    if (ballZ <= 0) {
      ballZ = 0;

      if (abs(ballVZ) > stopBounce) ballVZ = -ballVZ * restitution;
      else ballVZ = 0;

      ballVX *= groundFriction;
      ballVY *= groundFriction;

      if (ballVZ == 0 && abs(ballVX) < stopSpeed && abs(ballVY) < stopSpeed) {
        ballVX = 0;
        ballVY = 0;
        ballActive = false;
      }
    }

    if (ballX - halfW < 0)        { ballX = halfW;        ballVX *= -0.8; }
    if (ballX + halfW > width)    { ballX = width-halfW;  ballVX *= -0.8; }
    if (ballY - halfH < 0)        { ballY = halfH;        ballVY *= -0.8; }
    if (ballY + halfH > height)   { ballY = height-halfH; ballVY *= -0.8; }
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
  fetchtimer=3; 
  fetchscore=0;
  topalligatorx = width/2;
  topalligatory = height*0.25;
  fetchfrenzylost = false;
  firstlaunch = false;
}
