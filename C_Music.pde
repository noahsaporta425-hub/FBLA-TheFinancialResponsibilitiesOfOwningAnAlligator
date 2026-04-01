// =========================
// Music / Volume Controls (ControlP5)
// Keeps slider + toggle in sync without triggering recursive events
// =========================

float lastNonZeroVolume = 50;             // Remembers the last non-zero slider value (used when turning music back on)
boolean isSuppressingVolumeCallback = false;    // Flag for suppressing event loops (declared here; use when needed)
ControlP5 cp5;                     // Main ControlP5 instance


// =========================
// Slider Callback: volume(float v)
// Automatically called by ControlP5 when the "volume" slider changes
// =========================
void volume(float v) {

  // Apply audio change immediately
  applyVolume(v);

  // If volume is basically 0, force toggle OFF (but without triggering its callback)
  if (v <= 0.001) { // floating-point comparison: treat any volume below 0.001 as effectively silent to fully mute the track
    setToggleValueNoEvent(0);
  }
  // Otherwise, remember volume and force toggle ON
  else {
    lastNonZeroVolume = v;
    setToggleValueNoEvent(1);
  }
}


// =========================
// Audio Application Helper
// Converts slider percent (0-100) to amp value and updates the music volume
// =========================
void applyVolume(float v) {

  // Map 0-100 slider range to a safe amp range
  float ampValue = map(v, 0, 100, 0.0, 0.25); // map slider range 0-100 to amplitude 0.0-0.25; capped at 0.25 to prevent audio distortion
  music.amp(ampValue);
}


// =========================
// UI Helper: Set Slider Without Firing Events
// Temporarily disables broadcasting so ControlP5 doesn't call volume() again
// =========================
void setSliderValueNoEvent(float v) {

  Controller c = cp5.getController("volume");
  c.setBroadcast(false);
  c.setValue(v);
  c.setBroadcast(true);
}


// =========================
// UI Helper: Set Toggle Without Firing Events
// Temporarily disables broadcasting so toggle callbacks don't chain
// =========================
void setToggleValueNoEvent(float v) {

  Controller c = cp5.getController("musicOn");
  c.setBroadcast(false);
  c.setValue(v);
  c.setBroadcast(true);
}
