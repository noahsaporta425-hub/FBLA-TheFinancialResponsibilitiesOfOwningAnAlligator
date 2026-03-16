// ╔══════════════════════════════════════════════════════════════════════════════════╗
// ║         FBLA INTRODUCTION TO PROGRAMMING — 2025-2026 NATIONAL EVENT             ║
// ║                                                                                  ║
// ║  Program Title:  The Financial Responsibilities of Owning an Alligator           ║
// ║  Topic:          Build a Virtual Pet                                              ║
// ║  Event:          Introduction to Programming (High School)                       ║
// ║  Organization:   Future Business Leaders of America (FBLA)                       ║
// ╠══════════════════════════════════════════════════════════════════════════════════╣
// ║  PROGRAM DESCRIPTION                                                             ║
// ║  ─────────────────────────────────────────────────────────────────────────────   ║
// ║  An educational pet simulation game where the player adopts a baby alligator    ║
// ║  and must keep it healthy, happy, and financially supported over multiple        ║
// ║  in-game days. The game teaches real-world financial responsibility by           ║
// ║  requiring the player to budget for food, vet care, medicine, and services       ║
// ║  while earning money through jobs and minigames.                                 ║
// ║                                                                                  ║
// ║  TOPIC REQUIREMENTS ADDRESSED                                                    ║
// ║  ─────────────────────────────────────────────────────────────────────────────   ║
// ║  ✓ Customization      — Player names the pet and chooses its color               ║
// ║  ✓ Pet Care           — Feed, play, rest, clean, health check                   ║
// ║  ✓ Emotional Reactions— Sprite changes based on hunger/energy/sickness           ║
// ║  ✓ Cost Tracking      — Bank logs every transaction; running total displayed     ║
// ║  ✓ Earning Systems    — Jobs, Help Around Town tasks, and three minigames        ║
// ║  ✓ Growth & Badges    — Achievement system with tiered unlockable rewards        ║
// ╠══════════════════════════════════════════════════════════════════════════════════╣
// ║  TECHNICAL DETAILS                                                               ║
// ║  ─────────────────────────────────────────────────────────────────────────────   ║
// ║  Language:    Processing 4 (Java mode)                                           ║
// ║  Renderer:    P2D (processing.opengl) — 1100 × 700 window                       ║
// ║  Libraries:   processing.sound  — background music and audio playback            ║
// ║               ControlP5         — volume slider, music toggle, name input        ║
// ║               processing.opengl — hardware-accelerated 2D rendering              ║
// ║                                                                                  ║
// ║  HOW TO RUN                                                                      ║
// ║  ─────────────────────────────────────────────────────────────────────────────   ║
// ║  1. Install Processing 4 from https://processing.org                             ║
// ║  2. Install libraries via Sketch → Import Library → Manage Libraries:            ║
// ║       • Sound (by The Processing Foundation)                                     ║
// ║       • ControlP5 (by Andreas Schlegel)                                          ║
// ║  3. Open A_Main.pde — all .pde tabs compile as one sketch automatically          ║
// ║  4. Press the Run button (▶) in the Processing IDE                               ║
// ╠══════════════════════════════════════════════════════════════════════════════════╣
// ║  FILE STRUCTURE (9 tabs, each with a dedicated role)                             ║
// ║  ─────────────────────────────────────────────────────────────────────────────   ║
// ║  A_Main.pde            setup() / draw() — screen state switcher (this file)     ║
// ║  B_Interaction.pde     All user input: mouse, keyboard, drag, scroll            ║
// ║  C_Music.pde           Audio setup — ControlP5 volume slider and toggle         ║
// ║  D_General_Functions.pde  File I/O, name validation, save/load, utilities       ║
// ║  E_Home_Screen.pde     Home/title screen render + instructions overlay          ║
// ║  F_Adoption_Cutscene.pde  Cutscene, adoption center, and naming screen          ║
// ║  G_Main_Screen.pde     Full main gameplay screen with all subsystems            ║
// ║  H_Play_Screen.pde     Three minigames: Swamp Hop, Snack Snatch, Fetch Frenzy  ║
// ║  I_Alligator_Class.pde Pet class with stat fields, mood sprites, eat() logic   ║
// ╠══════════════════════════════════════════════════════════════════════════════════╣
// ║  EXTERNAL RESOURCES & ATTRIBUTION                                                ║
// ║  ─────────────────────────────────────────────────────────────────────────────   ║
// ║  • All artwork and audio assets are original or used under license               ║
// ║  • Music: "music.mp3" — original composition                                    ║
// ║  • Fonts: "timesnewroman.ttf" (system font), "arcade.otf" (custom)              ║
// ║  • ControlP5 library by Andreas Schlegel — lgpl.org open-source license         ║
// ║  • Processing Sound library by The Processing Foundation — LGPL license         ║
// ╚══════════════════════════════════════════════════════════════════════════════════╝

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
  if (homescreenvisible == true) {
    homescreen();
    cp5.draw();
  } 
  
  // Intro cutscene
  else if (cutscenestart == true) {
    cutscene();
  }
  
  // Pet naming screen
  if (inNaming == true) {
    namingalligatorsegment();
  }
  
  // Main gameplay screen
  if (startrealgame == true) {
    mainscreen();
  }
}
