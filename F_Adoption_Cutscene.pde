// =========================
// Cutscene / Story Flow State
// Controls fades, scene transitions, and adoption/naming progression
// =========================

boolean isNamingActive            = false;
boolean isCutsceneActive          = false;
boolean isEnteringAdoptionCenter  = false;
boolean isInsideAdoptionCenter    = false;
boolean isDogSelected             = false;
boolean isCatSelected             = false;
boolean isGameStarted             = false;

// =========================
// Cutscene Fade Instances
// Each covers one transition in the cutscene/naming flow.
// =========================
// cutFade1: phases 1+2 — fades to black, then from black to reveal city street
Fade cutFade1  = new Fade(0);
// cutFade2: phase 3 — fades to black entering adoption center, then from black to reveal interior
Fade cutFade2  = new Fade(0);
// cutFade3: phase 4 — fades to black for naming transition; reused as the naming screen entry fade
Fade cutFade3  = new Fade(0);
// namingFade: naming screen exit — fades to black before starting the main game
Fade namingFade = new Fade(0);


// =========================
// Timing / Animation State
// =========================

int   petSignDisplayTimer = 0;

float cityPanOffset  = 0;
float cityPanPauseTimer    = 0;


// =========================
// Cutscene Assets
// =========================

PImage outsideofadoptioncenter;
PImage adoptioncenterinterior;
PImage pickingcat;
PImage pickingdog;
PImage namingalligatorbackground;

PFont  times50;

// =========================
// Cutscene Main Function
// Handles: fade-in, pan, entering adoption center, choosing pet, transitioning to naming
// =========================
void cutscene() {

  rectMode(CORNER);
  imageMode(CORNER);
  noStroke();

  // ---------------------------------------------------
  // Phase 1: Fade to black (0→255) — screen goes dark before city is revealed
  // ---------------------------------------------------
  if (!cutFade1.outComplete) {
    cutFade1.stepOut(3);  // fade speed 3 gives a ~1.4s transition at 60fps — fast enough to feel snappy, slow enough to read
    cutFade1.draw();
  }

  // ---------------------------------------------------
  // Phase 2: City pan — fade from black (255→0) to reveal the street scene
  // ---------------------------------------------------
  else {

    // Pan the background until the adoption center is reached
    if (cityPanOffset <= 765) {  // pan 765px to show the full city background before pausing on the pet shop
      cityPanOffset += 3;  // 3px/frame pan speed matches the fade duration so they complete together
    } else {

      // Pause briefly before transitioning inside
      cityPanPauseTimer++;

      if (cityPanPauseTimer >= 40) {  // 40-frame pause (~0.7s) lets the player read the scene before advancing
        isEnteringAdoptionCenter = true;
      }
    }

    image(outsideofadoptioncenter, 0 - cityPanOffset, -190, width * 1.75, height * 1.75);

    // Overlay fades away to reveal the street
    cutFade1.stepIn(2);
    cutFade1.draw();
  }

  // ---------------------------------------------------
  // Phase 3: Transition inside the adoption center
  //   — fade to black (cutFade2 outComplete), then reveal the interior
  // ---------------------------------------------------
  if (isEnteringAdoptionCenter) {

    // Fade to black before showing the interior
    if (!cutFade2.outComplete) {
      cutFade2.stepOut(8);  // faster fade (8) for the scene cut to keep the cutscene pacey
      cutFade2.draw();
    }

    // Interior scene
    else {

      isInsideAdoptionCenter = true;

      image(adoptioncenterinterior, 0, 0, width, height);

      // Fade from black into the interior
      cutFade2.stepIn(3);
      cutFade2.draw();

      // Show the pet sign animation based on selection
      if (isDogSelected) signanimation(pickingdog);
      if (isCatSelected) signanimation(pickingcat);

      // After a pet is chosen, wait briefly, then transition to naming
      if (isDogSelected == true || isCatSelected == true) {

        petSignDisplayTimer++;

        if (petSignDisplayTimer > 220) {  // 220 frames (~3.7s) on the pet sign gives the player time to absorb the choices

          // Fade to black (cutFade3) before switching to naming screen
          if (!cutFade3.outComplete) {
            cutFade3.stepOut(4);
            cutFade3.draw();
          }

          // Naming segment begins once cutFade3 is fully black
          else {
            isNamingActive = true;
          }

          // Extra fade step to accelerate cutFade2 completion (preserves original timing)
          cutFade2.stepIn(3);
        }
      }
    }
  }
}


// =========================
// Sign Reveal Animation State
// Shared by dog/cat reveal animations
// =========================

float signRevealProgress = 0;
float signRevealSpeed    = 0.015;  // slow reveal (1.5% per frame) makes the sign dramatically slide down into view

float signBaseX          = width / 2 - 240;  // center the 480px-wide sign on the canvas

float signMaskLineY      = 191;  // top edge of the sign reveal; aligns with the panel header in the background image
float signFinalY         = height / 2 - 200;


// =========================
// Sign Animation
// Reveals the sign upward by slicing the image
// Used for both dog and cat signs — pass the appropriate PImage
// =========================
void signanimation(PImage img) {

  float x      = width / 2.0 - 230;
  float finalY = height / 2.0 - 200;

  float targetW = 480;  // sign image native display size — fits the center panel without crowding the pet options
  float targetH = 350;

  float startY = signMaskLineY - targetH;

  // Reveal increases until full height is shown
  signRevealProgress = min(signRevealProgress + signRevealSpeed, 1);

  float y = lerp(startY, finalY, signRevealProgress);

  int hSrc = constrain(int(img.height * signRevealProgress), 0, img.height);

  int sy = img.height - hSrc;

  float scaleY  = targetH / (float)img.height;
  float hDraw   = hSrc * scaleY;
  float drawTop = y + (targetH - hDraw);

  // Clip to the hide line (prevents drawing above the mask line)
  if (drawTop < signMaskLineY) {

    float cutDraw = signMaskLineY - drawTop;
    int cutSrc    = int(cutDraw / scaleY);

    sy   += cutSrc;
    hSrc -= cutSrc;

    if (hSrc <= 0) return;

    hDraw   = hSrc * scaleY;
    drawTop = signMaskLineY;
  }

  // Draw only the visible slice
  PImage slice = img.get(0, sy, img.width, hSrc);

  imageMode(CORNER);
  image(slice, x, drawTop, targetW, hDraw);
}



// =========================
// Naming Screen
// Shows naming background, pet sprite, and input UI
// =========================

boolean isNamingScreenShown = false;
int selectedAlligatorSkin = 0;

void namingalligatorsegment() {
  isNamingScreenShown = true;
  isInsideAdoptionCenter = false;

  imageMode(CORNER);
  image(namingalligatorbackground, 0, 0, width, height);

  // three pet choices evenly spaced 300px apart, centered slightly left to balance the UI
  image(alligator.neutralalligator, width * 0.27 - 300, height * 0.5, (width / 2) * 0.9, height / 2);

  tint(0,255,0);   // green skin color preview for the alternate pet choice
  image(alligator.neutralalligator, width * 0.27, height * 0.5, (width / 2) * 0.9, height / 2);

  tint(70,130,255);  // blue skin color preview for the alternate pet choice
  image(alligator.neutralalligator, width * 0.27 + 300, height * 0.5, (width / 2) * 0.9, height / 2);
  noTint();

  rectMode(CENTER);
  stroke(255);
  strokeWeight(2);
  textAlign(CENTER, CENTER);
  textSize(16);

  float[] btnXOffsets = {-300, 0, 300};
  for (int i = 0; i < 3; i++) {
    float btnX = (width * 0.27 + btnXOffsets[i]) + ((width / 2) * 0.9) / 2;
    if (selectedAlligatorSkin == i) fill(0, 255, 0, 120);
    else fill(80, 220);
    rect(btnX, 659, 120, 35);  // 120×35 button near the bottom edge of the 700px canvas
    fill(255);
    if (selectedAlligatorSkin == i) text("SELECTED", btnX, 659);
    else text("SELECT", btnX, 659);
  }

  nameField.show();
  confirmBtn.show();

  fill(255);
  textFont(times50);
  text("Customize Your Alligator:", int(width/2), int(height * 0.35));
  textSize(30);
  text("Name: ", 320, 320);
  cp5.draw();

  // Display validation error message in red if the last confirm attempt was invalid.
  // petNameValidationError is set by isValidName() in D_General_Functions.pde and cleared
  // as soon as the user submits a valid name.
  if (petNameValidationError != null && petNameValidationError.length() > 0) {
    fill(255, 80, 80);
    textFont(times30);
    textSize(15);
    textAlign(LEFT, CENTER);
    text(petNameValidationError, width * 0.35, 355);
  }

  noStroke();
  rectMode(CORNER);

  // Entry fade: cutFade3 arrives at 255 from the cutscene transition; step to clear
  // consistent fade speed (4) keeps screen transitions uniform
  cutFade3.stepIn(4);
  cutFade3.draw();

  // Exit fade: once name is confirmed, fade to black then switch to the main game
  if (isNameChosen) {
    // consistent fade speed (4) keeps screen transitions uniform
    if (namingFade.stepOut(4)) {
      isGameStarted = true;
      isOnMainScreen = true;
      isCutsceneActive = false;
      isNamingActive = false;
    }
    namingFade.draw();
  }
}
