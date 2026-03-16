

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
// Runs once at program start
// =========================
void setup() {

  // Set window size and use P2D renderer
  size(1100, 700, P2D);

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
}


// =========================
// Draw Function
// Runs every frame
// Handles screen/state switching
// =========================
void draw() {
  // Home screen (main menu)
  if (isHomeScreenVisible == true) {
    homescreen();
    cp5.draw();
  }

  // Intro cutscene
  else if (isCutsceneActive == true) {
    cutscene();
  }

  // Pet naming screen
  if (isNamingActive == true) {
    namingalligatorsegment();
  }

  // Main gameplay screen
  if (isGameStarted == true) {
    mainscreen();
  }
}
