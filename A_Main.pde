// =========================
// Imports & Libraries
// =========================


// Sound playback for music and effects
import processing.sound.*;

// ControlP5 for UI elements (buttons, inputs, sliders)
import controlP5.*;

// OpenGL / P2D renderer for performance and graphics
import processing.opengl.*;

import processing.event.MouseEvent;
// =========================
// Global Objects
// =========================

// Background music file
SoundFile music;


// =========================
// Setup Function
// Initializes the Processing window, loads assets, sets up ControlP5, and seeds the random number generator. Runs once at program start.
// =========================
void setup() {

  // Set window size and use P2D renderer
  size(1100, 700, P2D); // 1100x700 canvas with P2D (OpenGL) renderer for hardware-accelerated 2D graphics

  // Enable smoother edges
  smooth(4);

  // Lock pixel density for consistent UI scaling
  pixelDensity(1);


  // Runs all essential code required in the setup function
  fileWork();


  // Initialize music volume, playback, and settings
  musicAdjusters();

  // Set up pet naming input screen
  nameinput();

  // Allows for layering of ControlP5 elements
  cp5.setAutoDraw(false);

  // Restore previous session if a save file exists
  loadGame();

  // ===== TEMP DEBUG: populate 5 past posts of each trick on every platform =====
  for (int i = 0; i < 5; i++) trickUnlocked[i] = true;
  day = 25;
  String[] results = {"Viral", "Great", "Okay", "Great", "Flop"};
  String[] captions = {
    "Watch this!! #alligator #viral",
    "Training hard every day",
    "He almost got it lol",
    "So proud of my gator!!",
    "Bad day at training :("
  };
  for (int p = 0; p < 3; p++) {
    for (int t = 0; t < 5; t++) {
      String res = results[t];
      String caption = captions[t];
      String tName = trickNames[t];
      int fDelta = res.equals("Viral") ? 450 : res.equals("Great") ? 80 : res.equals("Okay") ? 12 : -5;
      float earn = res.equals("Viral") ? 42.50f : res.equals("Great") ? 8.20f : res.equals("Okay") ? 2.10f : 0;
      String follStr = (fDelta >= 0 ? "+" : "") + fDelta;
      getPlatformPostLog(p).add(new String[]{
        "Day " + (t + 1),
        tName,
        caption,
        res,
        follStr,
        "$" + nf(earn, 0, 2)
      });
      // Thumbnail
      int thumbW, thumbH, bgSX, bgSY, bgEX, bgEY;
      if (p == 0)      { thumbW=90;  thumbH=160; bgSX=480; bgSY=0;  bgEX=1056; bgEY=1024; }
      else if (p == 1) { thumbW=200; thumbH=200; bgSX=256; bgSY=0;  bgEX=1280; bgEY=1024; }
      else             { thumbW=288; thumbH=162; bgSX=0;   bgSY=80; bgEX=1536; bgEY=944;  }
      PGraphics thumb = createGraphics(thumbW, thumbH);
      thumb.beginDraw();
      thumb.imageMode(CORNER);
      thumb.image(mainscreen, 0, 0, thumbW, thumbH, bgSX, bgSY, bgEX, bgEY);
      if (trickImages[t] != null) {
        int[] cb = trickContentBounds[t];
        int sx=cb[0], sy=cb[1], ex=cb[2], ey=cb[3];
        float sw=ex-sx, sh=ey-sy;
        float sc = min(thumbW/sw, thumbH/sh);
        float dw=sw*sc, dh=sh*sc;
        thumb.imageMode(CORNER);
        thumb.image(trickImages[t], (thumbW-dw)*0.5f, (thumbH-dh)*0.5f, dw, dh, sx, sy, ex, ey);
      }
      thumb.endDraw();
      getPlatformPostImages(p).add(thumb);
    }
  }
  // ===== END TEMP DEBUG =====
}


// =========================
// Draw Function
// Main game loop called every frame. Routes rendering to the correct screen based on global state flags (homescreen, cutscene, naming, main game, minigames).
// Runs every frame -- routes rendering to the active screen.
// =========================

void draw() {
  // Home screen (main menu)
  if (isHomeScreenVisible == true) {
    homescreen();
    cp5.draw();
    if (isFadingToNaming) {
      if (transitionFade.stepOut(4)) {
        isHomeScreenVisible = false;
        isNamingActive = true;
      }
      transitionFade.draw();
    }
  }

  // Pet naming screen -- active after Begin is clicked
  if (isNamingActive == true) {
    namingalligatorsegment();
  }

  // Main gameplay screen -- active for the rest of the game session
  if (isGameStarted == true) {
    mainscreen();
  }
}
