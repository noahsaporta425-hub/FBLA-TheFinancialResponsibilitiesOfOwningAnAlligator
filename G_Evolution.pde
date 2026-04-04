// =========================
// G_Evolution.pde
// Trick training system: unlock and teach your alligator 5 tricks.
// Open the Evolution panel to see trick unlock days and training progress.
// Train tricks by attempting/rewarding in the apartment training screen.
// =========================


// =========================
// State
// =========================
boolean isEvolutionOpen   = false;
boolean isTrainingMode    = false;
int     trainingTrickIndex = -1;

// Training state machine:
//   0 = idle  -- show neutral alligator + "ATTEMPT" button
//   1 = animating -- show trick image + float animation for TRAINING_ANIM_FRAMES
//   2 = result popup -- show reward/try-again choice
int     trainingState         = 0;
boolean trainingLastSuccess   = false;
int     trainingAnimTimer     = 0;
final int TRAINING_ANIM_FRAMES = 90;   // ~1.5 sec at 60fps

// Trick definitions
float[]   trickProgress   = {0, 0, 0, 0, 0};     // 0-100 each
boolean[] trickUnlocked   = {false, false, false, false, false};
String[]  trickNames      = {"Wave", "Roar", "Roll Over", "Jump", "Fetch Ball"};
int[]     trickUnlockDays = {3, 6, 10, 15, 20};   // higher day = rarer trick = better social bonus

PImage[]  trickImages     = new PImage[5];        // loaded in fileWork()

// Content bounding boxes inside each 1920x1080 trick PNG (left, top, right, bottom).
// Derived by finding the non-transparent pixel extents of each image.
int[][] trickContentBounds = {
  { 557, 223, 1478,  837 },  // trick_wave.png      content 921x614
  { 715,  75, 1333,  971 },  // trick_roar.png      content 618x896
  { 478, 191, 1567,  841 },  // trick_rollover.png  content 1089x650
  { 193,  56, 1479, 1078 },  // trick_jump.png      content 1286x1022
  { 559, 239, 1489,  841 }   // trick_fetch.png     content 930x602
};

// Evolution panel scroll
float evScrollOffset    = 0;
float evViewportX       = 310;
float evViewportY       = 190;
float evViewportW       = 460;
float evViewportH       = 370;
float evItemH           = 120;   // px per trick row
float evScrollbarX      = 773;
float evScrollbarY      = 190;
float evScrollbarW      = 12;
float evScrollbarH      = 370;
boolean isDraggingEvScrollbar  = false;
float   evScrollThumbOffset    = 0;

// Just-unlocked banner state (shown briefly when trick hits 100%)
int   evUnlockedBannerTrick = -1;
int   evUnlockedBannerTimer = 0;
final int EV_BANNER_FRAMES  = 150;


// =========================
// drawTrickContent(img, bounds, x, y, w, h)
// Like drawImageFit but crops to the non-transparent content region first,
// so the alligator fills the destination box instead of the padded 1920x1080 canvas.
// =========================
void drawTrickContent(PImage img, int[] bounds, float x, float y, float w, float h) {
  int sx = bounds[0], sy = bounds[1], ex = bounds[2], ey = bounds[3];
  float sw = ex - sx, sh = ey - sy;
  float scale = min(w / sw, h / sh);
  float dw = sw * scale;
  float dh = sh * scale;
  imageMode(CORNER);
  image(img, x + (w - dw) * 0.5f, y + (h - dh) * 0.5f, dw, dh, sx, sy, ex, ey);
}


// =========================
// evolutionPanel()
// Main Evolution window: scrollable trick list with progress and train buttons.
// =========================
void evolutionPanel() {
  // --- Outer panel (same bounds as achievements/bank) ---
  rectMode(CORNERS);
  stroke(80, 200, 120);
  strokeWeight(5);
  fill(40, 80, 50, 230);
  rect(310, 122.5f, 790, 572.5f);
  line(310, 182, 790, 182);

  // Title
  textAlign(CENTER, CENTER);
  fill(140, 255, 160);
  textFont(arcade);
  textSize(26);
  text("EVOLUTION", width / 2.0f, 152);

  // "Just unlocked!" banner
  if (evUnlockedBannerTrick >= 0) {
    evUnlockedBannerTimer++;
    fill(255, 230, 50, map(evUnlockedBannerTimer, 0, EV_BANNER_FRAMES, 255, 0));
    noStroke();
    rectMode(CENTER);
    rect(width / 2.0f, 170, 360, 24, 8);
    fill(30, map(evUnlockedBannerTimer, 0, EV_BANNER_FRAMES, 255, 0));
    textFont(arcade);
    textSize(11);
    textAlign(CENTER, CENTER);
    text(trickNames[evUnlockedBannerTrick] + " UNLOCKED! Use it in Socials!", width / 2.0f, 170);
    rectMode(CORNER);
    if (evUnlockedBannerTimer >= EV_BANNER_FRAMES) {
      evUnlockedBannerTrick = -1;
      evUnlockedBannerTimer = 0;
    }
  }

  // --- Scrollable trick list ---
  float contentH = 20 + 5 * evItemH;
  float maxScroll = max(0, contentH - evViewportH);
  evScrollOffset = constrain(evScrollOffset, 0, maxScroll);

  pushMatrix();
  clip((int)evViewportX, (int)evViewportY, (int)evViewportW, (int)evViewportH);
  rectMode(CORNER);

  for (int i = 0; i < 5; i++) {
    float ry = evViewportY + 20 + i * evItemH - evScrollOffset;
    float bx = evViewportX + 10;
    float bw = evViewportW - 28;
    float bh = 106;
    float textX = bx + 106;   // text starts after 90px image + padding
    float btnCX = bx + bw - 52;
    float barY_ref = ry + 50;  // progress bar Y -- TRAIN button aligns to this
    float btnCY = barY_ref + 6;  // vertically centered on the progress bar

    // Row box
    if (trickUnlocked[i]) {
      fill(30, 90, 45, 210);
      stroke(80, 220, 100);
    } else if (day >= trickUnlockDays[i]) {
      fill(60, 75, 65, 210);
      stroke(160, 210, 170);
    } else {
      fill(50, 55, 52, 210);
      stroke(100, 120, 105);
    }
    strokeWeight(2);
    rect(bx, ry, bw, bh, 8);

    // Trick image thumbnail (90x90 -- fills most of the row height)
    if (trickImages[i] != null) {
      drawTrickContent(trickImages[i], trickContentBounds[i], bx + 8, ry + 8, 90, 90);
      // Dim locked tricks
      if (!trickUnlocked[i] && day < trickUnlockDays[i]) {
        noStroke();
        fill(30, 30, 30, 140);
        rectMode(CORNER);
        rect(bx + 8, ry + 8, 90, 90);
      }
    }

    // Trick name
    fill(255);
    textAlign(LEFT, TOP);
    textFont(arcade);
    textSize(14);
    text(trickNames[i], textX, ry + 8);

    // Status line
    textFont(times30);
    textSize(11);
    if (trickUnlocked[i]) {
      fill(100, 255, 140);
      text("UNLOCKED!", textX, ry + 26);
    } else if (day >= trickUnlockDays[i]) {
      fill(255, 230, 80);
      text("Ready! (day " + trickUnlockDays[i] + ")", textX, ry + 26);
    } else {
      fill(160, 190, 210);
      text("Unlocks Day " + trickUnlockDays[i] + "  (Day " + day + " now)", textX, ry + 26);
    }

    // Progress bar
    float barX = textX;
    float barY = barY_ref;
    float barW = btnCX - 42 - textX - 8;
    float barH = 13;
    fill(30, 60);
    stroke(120, 160, 130);
    strokeWeight(1);
    rect(barX, barY, barW, barH, 4);
    noStroke();
    float prog = trickUnlocked[i] ? 100 : trickProgress[i];
    if (prog > 0) {
      if (trickUnlocked[i]) fill(80, 220, 110);
      else                   fill(80, 180, 255);
      rect(barX, barY, barW * (prog / 100.0f), barH, 4);
    }
    // Progress label: centered inside bar so it never overlaps TRAIN button
    fill(220);
    textFont(times30);
    textSize(10);
    textAlign(CENTER, CENTER);
    text((int)prog + "%", barX + barW * 0.5f, barY + barH * 0.5f);

    // TRAIN button
    boolean canTrain = day >= trickUnlockDays[i] && !trickUnlocked[i];
    rectMode(CENTER);
    strokeWeight(2);
    if (canTrain) {
      fill(50, 170, 70);
      stroke(30, 120, 50);
    } else if (trickUnlocked[i]) {
      fill(40, 110, 50);
      stroke(50, 150, 70);
    } else {
      fill(60, 65, 62);
      stroke(80, 90, 82);
    }
    rect(btnCX, btnCY, 84, 32, 6);
    fill(trickUnlocked[i] ? color(80, 255, 120) : (canTrain ? color(255) : color(140)));
    textFont(arcade);
    textSize(10);
    textAlign(CENTER, CENTER);
    text(trickUnlocked[i] ? "DONE" : "TRAIN", btnCX, btnCY);
    rectMode(CORNER);
  }

  noClip();
  popMatrix();

  // Viewport border
  noFill();
  stroke(100, 180, 120);
  strokeWeight(2);
  rectMode(CORNER);
  rect(evViewportX, evViewportY, evViewportW, evViewportH);

  // Scrollbar
  float thumbH;
  float thumbY;
  fill(70, 100, 80);
  stroke(50, 80, 60);
  strokeWeight(1);
  rect(evScrollbarX, evScrollbarY, evScrollbarW, evScrollbarH);

  if (contentH > evViewportH) {
    thumbH = max(40, (evViewportH / contentH) * evScrollbarH);
    thumbY = map(evScrollOffset, 0, maxScroll, evScrollbarY, evScrollbarY + evScrollbarH - thumbH);
    fill(180, 220, 190);
    stroke(120);
    rect(evScrollbarX, thumbY, evScrollbarW, thumbH);
  } else {
    fill(180, 220, 190);
    stroke(120);
    rect(evScrollbarX, evScrollbarY, evScrollbarW, evScrollbarH);
  }

  // X close button (top-right of panel, same position as achievements)
  noFill();
  stroke(80, 200, 120);
  strokeWeight(3);
  rectMode(CORNERS);
  rect(733, 132, 776, 171.5f);
  fill(200, 255, 210);
  textFont(arcade);
  textSize(28);
  textAlign(CENTER, CENTER);
  text("X", 754.5f, 151.75f);

  strokeWeight(2);
  stroke(0);
  rectMode(CORNER);
}


// =========================
// trainingScreen()
// Full-screen training view rendered over the main screen.
// Handles 3-state animation loop: idle -> attempt -> result.
// =========================
void trainingScreen() {
  // --- Apartment background: reuse mainscreen image (no buttons) ---
  imageMode(CORNER);
  image(mainscreen, 0, 0, width, height);

  // Alligator position constants matching neutralmood() exactly
  float aliX = width * 0.33f;
  float aliY = height * 0.45f;
  float aliW = 267 * 1.4f;
  float aliH = 187 * 1.4f;

  // The neutral alligator PNG (1536x1024) has a solid visible body of 887x566 pixels —
  // the remaining area is transparent glow/padding. When drawn at aliW x aliH the
  // actual alligator body appears at aliBodyW x aliBodyH. Tricks must be drawn into
  // this same sized box (centered inside aliW x aliH) so they look the same size.
  float aliBodyW = aliW * (887.0f / 1536.0f);          // ≈ 216 px
  float aliBodyH = aliH * (566.0f / 1024.0f);          // ≈ 145 px
  float aliBodyX = aliX + (aliW - aliBodyW) * 0.5f;    // centred horizontally
  float aliBodyY = aliY + (aliH - aliBodyH) * 0.5f;    // centred vertically

  // --- Progress bar at top (shortened right side to leave gap before EXIT) ---
  float pbX  = 140;
  float pbY  = 18;
  float pbW  = width - 420;
  float pbH  = 26;
  fill(0, 160);
  noStroke();
  rectMode(CORNER);
  rect(pbX - 12, pbY - 6, pbW + 120, pbH + 12, 10);
  fill(200, 240, 255);
  textFont(arcade);
  textSize(11);
  textAlign(LEFT, CENTER);
  text("Training: " + trickNames[trainingTrickIndex], pbX, pbY + pbH * 0.5f);
  float barStartX = pbX + 170;
  float barW      = pbW - 190;
  fill(40);
  rect(barStartX, pbY + 4, barW, pbH - 8, 4);
  float prog = constrain(trickProgress[trainingTrickIndex], 0, 100);
  fill(80, 190, 255);
  if (prog > 0) rect(barStartX, pbY + 4, barW * (prog / 100.0f), pbH - 8, 4);
  fill(255);
  textFont(times30);
  textSize(12);
  textAlign(CENTER, CENTER);
  text((int)prog + "%", barStartX + barW * 0.5f, pbY + pbH * 0.5f);

  // --- EXIT button (top-right, clear of progress bar) ---
  fill(180, 50, 50);
  stroke(220, 80, 80);
  strokeWeight(2);
  rectMode(CENTER);
  rect(width - 52, 33, 84, 32, 7);
  fill(255);
  textFont(arcade);
  textSize(13);
  textAlign(CENTER, CENTER);
  text("EXIT", width - 52, 33);
  rectMode(CORNER);
  noStroke();

  // --- State-based rendering ---
  if (trainingState == 0) {
    // Idle: neutral alligator at its normal main-screen position
    applyAlligatorTint();
    image(alligator.neutralalligator, aliX, aliY, aliW, aliH);
    noTint();

    // ATTEMPT button placed below alligator to match apartment floor layout
    fill(50, 130, 220);
    stroke(30, 80, 160);
    strokeWeight(2);
    rectMode(CENTER);
    rect(width * 0.5f, height * 0.90f, 170, 46, 10);
    fill(255);
    textFont(arcade);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("ATTEMPT", width * 0.5f, height * 0.90f);
    rectMode(CORNER);
    noStroke();

  } else if (trainingState == 1) {
    // Animating: float up/down
    // Success → trick image floats; Fail → neutral alligator floats
    trainingAnimTimer++;
    float floatOff = sin(trainingAnimTimer * 0.09f) * 9;

    if (trainingLastSuccess && trickImages[trainingTrickIndex] != null) {
      // Draw trick into the same pixel footprint as the neutral alligator's solid body
      drawTrickContent(trickImages[trainingTrickIndex], trickContentBounds[trainingTrickIndex],
                       aliBodyX, aliBodyY + floatOff, aliBodyW, aliBodyH);
    } else {
      applyAlligatorTint();
      image(alligator.neutralalligator, aliX, aliY + floatOff, aliW, aliH);
      noTint();
    }

    if (trainingAnimTimer >= TRAINING_ANIM_FRAMES) {
      trainingState     = 2;
      trainingAnimTimer = 0;
    }

  } else if (trainingState == 2) {
    // Result: trick image on success, neutral on fail + result popup
    if (trainingLastSuccess && trickImages[trainingTrickIndex] != null) {
      drawTrickContent(trickImages[trainingTrickIndex], trickContentBounds[trainingTrickIndex],
                       aliBodyX, aliBodyY, aliBodyW, aliBodyH);
    } else {
      applyAlligatorTint();
      image(alligator.neutralalligator, aliX, aliY, aliW, aliH);
      noTint();
    }

    // Popup box
    float cx = width * 0.5f;
    float px = cx - 215;
    float py = height * 0.64f;
    noStroke();
    fill(20, 15, 15, 230);
    rectMode(CORNER);
    rect(px, py, 430, 195, 14);
    stroke(180, 180, 180, 180);
    strokeWeight(2);
    noFill();
    rect(px, py, 430, 195, 14);
    noStroke();

    textFont(arcade);
    textSize(14);
    textAlign(CENTER, CENTER);
    if (trainingLastSuccess) {
      fill(100, 255, 150);
      text("He did it! Great job, " + alligator.petName + "!", cx, py + 38);
      fill(180, 220, 190);
      textFont(times30);
      textSize(12);
      text("Rewarding reinforces this behavior.", cx, py + 62);
    } else {
      fill(255, 110, 100);
      text(alligator.petName + " didn't quite do it...", cx, py + 38);
      fill(220, 180, 180);
      textFont(times30);
      textSize(12);
      text("Rewarding now will hurt training progress!", cx, py + 62);
    }

    fill(255, 195, 45);
    stroke(200, 135, 0);
    strokeWeight(2);
    rectMode(CENTER);
    rect(cx - 100, py + 130, 150, 42, 9);
    fill(30);
    textFont(arcade);
    textSize(11);
    textAlign(CENTER, CENTER);
    text("REWARD", cx - 100, py + 130);

    fill(70, 120, 215);
    stroke(40, 70, 160);
    rect(cx + 100, py + 130, 150, 42, 9);
    fill(255);
    text("TRY AGAIN", cx + 100, py + 130);
    rectMode(CORNER);
    noStroke();
  }

  imageMode(CORNER);
}


// =========================
// startTraining(i)
// Enters training mode for trick i; closes evolution panel.
// =========================
void startTraining(int i) {
  trainingTrickIndex  = i;
  trainingState       = 0;
  trainingAnimTimer   = 0;
  isTrainingMode      = true;
  isEvolutionOpen     = false;
}


// =========================
// attemptTrick()
// Called when the player clicks ATTEMPT. Rolls success probability
// based on current progress, then transitions to the animation state.
// =========================
void attemptTrick() {
  // 75% chance of success every attempt
  trainingLastSuccess = (random(1) < 0.75f);
  trainingState       = 1;
  trainingAnimTimer   = 0;
}


// =========================
// applyTrainingResult(didReward)
// Updates trick progress based on the last attempt result and player choice.
// Correct + reward: big gain. Correct + no reward: small gain.
// Incorrect + reward: big loss (bad reinforcement). Incorrect + no reward: tiny gain.
// =========================
void applyTrainingResult(boolean didReward) {
  float delta;
  if (trainingLastSuccess  &&  didReward) delta =  12.0f;  // correct reward: big gain
  else if (trainingLastSuccess  && !didReward) delta =  0.0f;  // no reward = no progress
  else if (!trainingLastSuccess &&  didReward) delta = -15.0f; // bad reinforcement: loss
  else                                          delta =  0.0f;  // fail + no reward: no change

  trickProgress[trainingTrickIndex] =
    constrain(trickProgress[trainingTrickIndex] + delta, 0, 100);

  // Check for unlock
  if (trickProgress[trainingTrickIndex] >= 100) {
    trickProgress[trainingTrickIndex] = 100;
    if (!trickUnlocked[trainingTrickIndex]) {
      trickUnlocked[trainingTrickIndex] = true;
      evUnlockedBannerTrick = trainingTrickIndex;
      evUnlockedBannerTimer = 0;
    }
    // Return to evolution panel to celebrate
    isTrainingMode   = false;
    isEvolutionOpen  = true;
    return;
  }

  // Otherwise stay in training for another attempt
  trainingState = 0;
}
