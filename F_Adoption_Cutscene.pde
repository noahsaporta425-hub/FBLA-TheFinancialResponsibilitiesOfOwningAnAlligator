// =========================
// Cutscene / Story Flow State
// Controls fades, scene transitions, and adoption/naming progression
// =========================

boolean fadein              = false;
boolean fade2in             = false;
boolean fade3in             = false;
boolean inNaming            = false;
boolean cutscenestart       = false;
boolean enteradoptioncenter = false;
boolean insideadoptioncenter= false;
boolean dogadopted          = false;
boolean catadopted          = false;
boolean startrealgame       = false;

// =========================
// Fade Opacity Values (0–255)
// =========================

int fadeOutOpacity  = 0;
int fadeOutOpacity2 = 0;
int fadeOutOpacity3 = 0;
int fadeOutOpacity4 = 0;


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
  // Phase 1: Initial fade-in (screen starts black -> reveals city scene)
  // ---------------------------------------------------
  if (!fadein) {

    fill(0, fadeOutOpacity);
    rect(0, 0, width, height);

    fadeOutOpacity += 3;

    if (fadeOutOpacity >= 255) {
      fadeOutOpacity = 255;
      fadein = true;
    }
  }

  // ---------------------------------------------------
  // Phase 2: City pan + fade-out overlay
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

    // Overlay fades away to reveal the scene
    fill(0, fadeOutOpacity);
    rect(0, 0, width, height);

    if (fadeOutOpacity > 0) {
      fadeOutOpacity -= 2;
    }
  }

  // ---------------------------------------------------
  // Phase 3: Transition inside adoption center (fade to black, then reveal interior)
  // ---------------------------------------------------
  if (enteradoptioncenter) {

    // Fade to black before showing the new interior scene
    if (!fade2in) {

      fill(0, fadeOutOpacity2);
      rect(0, 0, width, height);

      fadeOutOpacity2 += 8;

      if (fadeOutOpacity2 >= 255) {
        fadeOutOpacity2 = 255;
        fade2in = true;
      }
    }

    // Interior scene
    else {

      insideadoptioncenter = true;

      image(adoptioncenterinterior, 0, 0, width, height);

      // Fade from black into the interior
      if (fadeOutOpacity2 > 0) {
        fill(0, fadeOutOpacity2);
        rect(0, 0, width, height);

        fadeOutOpacity2 -= 3;
        if (fadeOutOpacity2 < 0) fadeOutOpacity2 = 0;
      }

      // Show the pet sign animation based on selection
      if (dogadopted) signanimation(pickingdog);
      if (catadopted) signanimation(pickingcat);

      // After a pet is chosen, wait briefly, then transition to naming
      if (dogadopted == true || catadopted == true) {

        signreadingtimer++;

        if (signreadingtimer > 220) {

          // Fade to black before switching to naming screen
          if (!fade3in) {

            fill(0, fadeOutOpacity3);
            rect(0, 0, width, height);

            fadeOutOpacity3 += 4;

            if (fadeOutOpacity3 >= 255) {
              fadeOutOpacity3 = 255;
              fade3in = true;
            }
          }

          // Naming segment begins once fade is complete
          else {
            inNaming = true;
          }

          // Extra fade decrement (kept as-is)
          if (fadeOutOpacity2 > 0) {
            fadeOutOpacity2 -= 3;
          }
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

  noStroke();
  rectMode(CORNER);
  fill(0, fadeOutOpacity3);
  rect(0, 0, width, height);

  fadeOutOpacity3 -= 4;
  if (fadeOutOpacity3 <= 0) fadeOutOpacity3 = 0;

  if (namechosen) {
    fadeOutOpacity4 += 4;

    if (fadeOutOpacity4 >= 255) {
      fadeOutOpacity4 = 255;
      startrealgame = true;
      onmainscreen = true;
      cutscenestart = false;
      inNaming = false;
    }
    noStroke();
    fill(0, fadeOutOpacity4);
    rect(0, 0, width, height);
  }
}
