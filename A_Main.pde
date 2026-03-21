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
  size(1100, 700, P2D); // 1100×700 canvas with P2D (OpenGL) renderer for hardware-accelerated 2D graphics

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
// Main game loop called every frame. Routes rendering to the correct screen based on global state flags (homescreen, cutscene, naming, main game, minigames).
// Runs every frame — routes rendering to the active screen.
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

  // Pet naming screen — active after Begin is clicked
  if (isNamingActive == true) {
    namingalligatorsegment();
  }

  // Main gameplay screen — active for the rest of the game session
  if (isGameStarted == true) {
    mainscreen();
  }
}
