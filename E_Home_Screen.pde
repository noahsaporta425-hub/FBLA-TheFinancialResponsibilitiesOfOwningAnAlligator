// =========================
// Home Screen State & Assets
// =========================

Fade homeFade = new Fade(255);  // home screen entry: starts black, fades to clear

PImage homescreen;
PImage instructions;
PImage musicscreen;

PFont times15;


// =========================
// Home Screen Flags
// =========================

boolean isHomeScreenVisible   = true;
boolean isShowingInstructions   = false;
boolean isShowingMusicSettings  = false;


// =========================
// Home Screen Rendering
// Handles fade-in, overlays, and UI visibility
// =========================
void homescreen() {

  imageMode(CORNER);
  rectMode(CORNER);

  // Fade in from black on initial load
  homeFade.stepIn(2); // fade speed 2 gives a ~2s fade-in on first launch — slow enough to feel welcoming

  // Draw background slightly oversized to avoid edge gaps
  image(homescreen, -25, 0, width + 25, height + 100); // slight overflow on right and bottom hides background image seams at the canvas edge

  // Draw fade overlay on top of the background
  homeFade.draw();

  // -------------------------
  // Instructions Overlay
  // -------------------------
  if (isShowingInstructions == true) {
    image(instructions, 0, -50, 1100, 700);
    instructionstext();
  }

  // -------------------------
  // Music Settings Overlay
  // -------------------------
  if (isShowingMusicSettings == true) {

    image(musicscreen, width * 0.08, height * 0.05, 900, 650);

    // Show ControlP5 audio controls
    cp5.getController("volume").setVisible(true);
    cp5.getController("musicOn").setVisible(true);

  } else {

    // Hide audio controls when music menu is closed
    cp5.getController("volume").setVisible(false);
    cp5.getController("musicOn").setVisible(false);
  }
}


// =========================
// Instructions Text Rendering
// Displays gameplay explanation and player guidance
// =========================
void instructionstext() {

  textMode(SHAPE);
  textAlign(LEFT, TOP);
  textFont(times15);
  textSize(20);
  fill(0);
  smooth(8);

  text("You have adopted a baby alligator.", 200, 150);
  text("Your goal is to keep it healthy, safe, and financially supported over time.", 200, 175);
  text("Each day, you will make decisions about:", 200, 200);

  text("• feeding", 200, 230);
  text("• resting", 200, 270);
  text("• playing", 200, 310);
  text("• medical care", 200, 350);
  text("• spending and earning money", 200, 390);

  text("Press + to move forward one day in time", 200, 430);
  text("Your choices affect your alligator's health, mood, and future expenses.", 200, 470);
  text("Watch your money and stats carefully.", 200, 495);
  text("Cheap choices may save money now but can cause problems later.", 200, 520);
  text("Features and responsibilities will be taught as you play.", 200, 545);
  text("There is no single \u201cright\u201d way to play. Learn from the consequences of your decisions.", 200, 570);
}
