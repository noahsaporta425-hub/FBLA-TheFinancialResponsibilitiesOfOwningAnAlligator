// =========================
// Cutscene / Story Flow State
// Controls fades, scene transitions, and adoption/naming progression
// =========================

boolean inNaming            = false;
boolean cutscenestart       = false;
boolean enteradoptioncenter = false;
boolean insideadoptioncenter= false;
boolean dogadopted          = false;
boolean catadopted          = false;
boolean startrealgame       = false;

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

int   signreadingtimer = 0;

float cityblockmoving  = 0;
float movementpause    = 0;


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
    cutFade1.stepOut(3);
    cutFade1.draw();
  }

  // ---------------------------------------------------
  // Phase 2: City pan — fade from black (255→0) to reveal the street scene
  // ---------------------------------------------------
  else {

    // Pan the background until the adoption center is reached
    if (cityblockmoving <= 765) {
      cityblockmoving += 3;
    } else {

      // Pause briefly before transitioning inside
      movementpause++;

      if (movementpause >= 40) {
        enteradoptioncenter = true;
      }
    }

    image(outsideofadoptioncenter, 0 - cityblockmoving, -190, width * 1.75, height * 1.75);

    // Overlay fades away to reveal the street
    cutFade1.stepIn(2);
    cutFade1.draw();
  }

  // ---------------------------------------------------
  // Phase 3: Transition inside the adoption center
  //   — fade to black (cutFade2 outComplete), then reveal the interior
  // ---------------------------------------------------
  if (enteradoptioncenter) {

    // Fade to black before showing the interior
    if (!cutFade2.outComplete) {
      cutFade2.stepOut(8);
      cutFade2.draw();
    }

    // Interior scene
    else {

      insideadoptioncenter = true;

      image(adoptioncenterinterior, 0, 0, width, height);

      // Fade from black into the interior
      cutFade2.stepIn(3);
      cutFade2.draw();

      // Show the pet sign animation based on selection
      if (dogadopted) signanimation(pickingdog);
      if (catadopted) signanimation(pickingcat);

      // After a pet is chosen, wait briefly, then transition to naming
      if (dogadopted == true || catadopted == true) {

        signreadingtimer++;

        if (signreadingtimer > 220) {

          // Fade to black (cutFade3) before switching to naming screen
          if (!cutFade3.outComplete) {
            cutFade3.stepOut(4);
            cutFade3.draw();
          }

          // Naming segment begins once cutFade3 is fully black
          else {
            inNaming = true;
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

float revealProgress = 0;
float revealSpeed    = 0.015;

float signX          = width / 2 - 240;

float hideLineY      = 191;
float finalSignY     = height / 2 - 200;


// =========================
// Sign Animation
// Reveals the sign upward by slicing the image
// Used for both dog and cat signs — pass the appropriate PImage
// =========================
void signanimation(PImage img) {

  float x      = width / 2.0 - 230;
  float finalY = height / 2.0 - 200;

  float targetW = 480;
  float targetH = 350;

  float startY = hideLineY - targetH;

  // Reveal increases until full height is shown
  revealProgress = min(revealProgress + revealSpeed, 1);

  float y = lerp(startY, finalY, revealProgress);

  int hSrc = constrain(int(img.height * revealProgress), 0, img.height);

  int sy = img.height - hSrc;

  float scaleY  = targetH / (float)img.height;
  float hDraw   = hSrc * scaleY;
  float drawTop = y + (targetH - hDraw);

  // Clip to the hide line (prevents drawing above the mask line)
  if (drawTop < hideLineY) {

    float cutDraw = hideLineY - drawTop;
    int cutSrc    = int(cutDraw / scaleY);

    sy   += cutSrc;
    hSrc -= cutSrc;

    if (hSrc <= 0) return;

    hDraw   = hSrc * scaleY;
    drawTop = hideLineY;
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

boolean alligatornamingshown = false;
int selectedAlligator = 0;

void namingalligatorsegment() {
  alligatornamingshown = true;
  insideadoptioncenter = false;

  imageMode(CORNER);
  image(namingalligatorbackground, 0, 0, width, height);

  image(alligator.neutralalligator, width * 0.27 - 300, height * 0.5, (width / 2) * 0.9, height / 2);

  tint(0,255,0);
  image(alligator.neutralalligator, width * 0.27, height * 0.5, (width / 2) * 0.9, height / 2);

  tint(70,130,255);
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
    if (selectedAlligator == i) fill(0, 255, 0, 120);
    else fill(80, 220);
    rect(btnX, 659, 120, 35);
    fill(255);
    if (selectedAlligator == i) text("SELECTED", btnX, 659);
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
  // nameValidationError is set by isValidName() in D_General_Functions.pde and cleared
  // as soon as the user submits a valid name.
  if (nameValidationError != null && nameValidationError.length() > 0) {
    fill(255, 80, 80);
    textFont(times30);
    textSize(15);
    textAlign(LEFT, CENTER);
    text(nameValidationError, width * 0.35, 355);
  }

  noStroke();
  rectMode(CORNER);

  // Entry fade: cutFade3 arrives at 255 from the cutscene transition; step to clear
  cutFade3.stepIn(4);
  cutFade3.draw();

  // Exit fade: once name is confirmed, fade to black then switch to the main game
  if (namechosen) {
    if (namingFade.stepOut(4)) {
      startrealgame = true;
      onmainscreen = true;
      cutscenestart = false;
      inNaming = false;
    }
    namingFade.draw();
  }
}
