// =========================
// Naming / Setup Flow State
// =========================

boolean isNamingActive = false;
boolean isGameStarted  = false;

// transitionFade: home -> naming transition (fade out then fade in)
Fade transitionFade = new Fade(0);
boolean isFadingToNaming = false;

// namingFade: exit fade -- fades to black before starting the main game
Fade namingFade = new Fade(0);

// =========================
// Naming Screen Assets
// =========================

PImage namingalligatorbackground;
PFont  times50;

// =========================
// Naming Screen
// Shows naming background, pet sprite, and input UI
// =========================

int selectedAlligatorSkin = 0;

void namingalligatorsegment() {
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
    rect(btnX, 659, 120, 35);  // 120x35 button near the bottom edge of the 700px canvas
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
  if (petNameValidationError != null && petNameValidationError.length() > 0) {
    fill(255, 80, 80);
    textFont(times30);
    textSize(15);
    textAlign(LEFT, CENTER);
    text(petNameValidationError, width * 0.35, 355);
  }

  noStroke();
  rectMode(CORNER);

  // Entry fade-in from black
  transitionFade.stepIn(4);
  transitionFade.draw();

  // Exit fade: once name is confirmed, fade to black then switch to the main game
  if (isNameChosen) {
    if (namingFade.stepOut(4)) {
      isGameStarted = true;
      isOnMainScreen = true;
      isNamingActive = false;
    }
    namingFade.draw();
  }
}
