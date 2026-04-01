// =========================
// Pet Class
// Represents the player's virtual alligator pet.
// Stores all per-pet state: identity, mood sprites, and the five core stats.
// The eat() method is the primary way stats change from player-initiated feeding.
// =========================

class Pet {

  // --- Identity ---
  String petName;              // Display name chosen by the player on the naming screen

  // --- Mood sprites (loaded in D_General_Functions.pde :: fileWork()) ---
  // Displayed based on which stat threshold is triggered each frame
  PImage neutralalligator;     // Default sprite -- no critical stat triggered
  PImage hungryalligator;      // Shown when hunger > 80
  PImage energeticalligator;   // Shown when energy > 80 (too hyper)
  PImage sickalligator;        // Shown when isPetSick == true

  // --- Core Stats (all 0-100 unless noted) ---
  // health:    Overall well-being. Drops from junk food, unprescribed medicine, or illness.
  // happiness: Mood level. Rises from treats and play; falls from illness/bad food.
  // energy:    Activity level. Best in mid-range (40-70). Too high triggers energetic mood.
  // sickrisk:  Probability of falling ill next day. Clamped min 20 (baseline risk always exists).
  // hunger:    How full the pet is. Rises each day; high hunger triggers the hungry mood.
  // fresh adoption state: pet is healthy and happy but a little hungry and low on energy from the journey
  float health = 100;
  float happiness = 100;
  float energy = 50;
  float sickrisk = 10;
  float hunger = 95;


  // Constructor: create a new pet with a given name
  Pet(String _petName) {
    petName = _petName;
  }

// neutralmood() -- Draws the default alligator sprite when no critical stat threshold is active.
// neutralmood uses a fixed CORNER-mode offset rather than drawMoodSprite's CENTER-mode
// because the neutral sprite is a wider landscape image that needs its own size/position
void neutralmood() {
  applyAlligatorTint();
  image(neutralalligator, width * 0.33, height * 0.45, 267 * 1.4, 187 * 1.4); // scaled up 40% from the source sprite to fill the main screen display area
  noTint();
}

void hungrymood()    { drawMoodSprite(hungryalligator); }
void energeticmood() { drawMoodSprite(energeticalligator); }
void sickmood()      { drawMoodSprite(sickalligator); }

// drawMoodSprite(PImage img) -- Draws any mood sprite centered at the alligator's position on the main screen.
// Shared helper for hungry/energetic/sick sprites -- all square-ish and centered at (550, 452)
void drawMoodSprite(PImage img) {
  applyAlligatorTint();
  imageMode(CENTER);
  image(img, 550, 452, img.width/4.2, img.height/4.2); // center point of the alligator's display area on the main game screen; /4.2 is the scale factor to display mood sprites at consistent size regardless of source image dimensions
  imageMode(CORNER);
  noTint();
}

  // =========================
  // eat(String item) -- Applies food-specific stat changes to the pet. Food is identified by item
  // name string matching. Junk food trades health for quick energy/happiness; meat gives balanced
  // nutrition; medicine only heals when prescribed.
  // Central stat-update method called whenever the player uses an inventory item.
  // Logic flow:
  //   1. Steak (premium meat from adoption center) -- biggest hunger/health boost
  //   2. Medicines -- check medicineIsPrescribed[] first; prescribed = heals, unprescribed = harms
  //   3. Snacks / Meat -- each has unique stat tradeoffs (junk hurts health, fish/meat helps)
  // All stats are clamped at the end to prevent overflow or underflow.
  // =========================
  void eat(String item) {

  // --- Premium Food ---
  // Steak is the player's starting item; best all-around nutrition.
  if (item.equals("Steak")) {
      // steak is the most nutritious food -- filling and energizing, with a health boost; given free on Day 1 to teach feeding
      hunger-=70;
      energy+=40;
      health+=20;
      happiness+=20;
  } else {

    // --- Medicine ---
    // Each medicine maps to an index in medicineItemList[].
    // If the vet prescribed it (prescribedMedicineIndex == i), it heals the pet.
    // If given without a prescription, it harms health and raises sickness risk --
    // teaching the player that self-medicating without a vet is dangerous.
    boolean foundMedicine = false;
    for (int i = 0; i < medicineItemList.length; i++) {
      if (item.equals(medicineItemList[i])) {
        if (prescribedMedicineIndex == i) {
          if (lastDoseTakenDay == day) {
            // second dose on same day -- overdose; penalises stats to discourage double-dosing
            health -= 20;
            energy -= 10;
            happiness -= 10;
          } else {
            // correct prescribed dose timing; stat boosts model recovery
            health += 20;
            energy += 10;
            happiness += 10;
          }
        } else {
          // wrong medicine worsens the condition -- teaches that guessing on medicine is dangerous
          health -= 35;
          energy -= 10;
          happiness -= 10;
          sickrisk += 25;
        }
        foundMedicine = true;
        break;
      }
    }

    if (!foundMedicine) {
    // Junk food trades long-term health for immediate hunger/energy satisfaction -- high hunger reduction but health penalty
    // --- Snacks (junk food) ---
    // Generally reduce hunger and boost happiness/energy in the short term,
    // but damage health -- reflecting real-world junk food consequences.
    if (item.equals("Nachos")) {
      hunger -= 40;
      health -= 15;
      happiness += 5;
      energy += 30;

    } else if (item.equals("Cheesepuffs")) {
      hunger -= 25;
      health -= 5;
      happiness += 20;
      energy += 10;

    } else if (item.equals("Chips")) {
      hunger -= 30;
      health -= 10;
      happiness += 10;
      energy += 10;

    } else if (item.equals("Chocolate Bar")) {
      hunger -= 7;
      health -= 5;
      happiness += 20;
      energy += 5;

    } else if (item.equals("Cookies")) {
      hunger -= 30;
      health -= 5;
      happiness += 10;
      energy += 5;

    } else if (item.equals("Crackers")) {
      hunger -= 5;
      energy += 20;

    } else if (item.equals("Energy Drink")) {
      hunger += 20;
      health -= 35;
      happiness -= 10;
      energy += 70;

    } else if (item.equals("Granola Bar")) {
      hunger -= 15;
      health -= 5;
      happiness += 5;
      energy += 20;

    } else if (item.equals("Popcorn")) {
      hunger -= 10;
      health -= 10;
      happiness += 30;
      energy += 10;

    } else if (item.equals("Pretzels")) {
      hunger -= 10;
      health -= 5;
      happiness += 5;
      energy += 15;

    } else if (item.equals("Soda")) {
      hunger += 30;
      health -= 30;
      happiness += 5;
      energy += 40;

    } else if (item.equals("Trail Mix")) {
      hunger -= 10;
      health -= 5;
      happiness += 5;
      energy += 20;

    // Meat items are nutritionally superior: larger hunger reduction and no health penalty, but cost more
    // --- Meat / Fish (premium foods) ---
    // Natural diet for alligators; improve health and hunger the most.
    // Better nutritional value than snacks -- player learns to invest in quality food.
    } else if (item.equals("Bluegill")) {
      hunger -= 55;
      health += 15;
      happiness += 10;
      energy += 20;

    } else if (item.equals("Bass")) {
      hunger -= 60;
      health += 20;
      happiness += 10;
      energy += 25;

    } else if (item.equals("Perch")) {
      hunger -= 50;
      health += 20;
      happiness += 5;
      energy += 15;

    } else if (item.equals("Goldfish")) {
      hunger -= 30;
      health += 5;
      happiness += 15;
      energy += 10;

    } else if (item.equals("Crab")) {
      hunger -= 50;
      health += 25;
      happiness += 20;
      energy += 15;

    } else if (item.equals("Lamb Chop")) {
      hunger -= 70;
      health += 10;
      happiness += 15;
      energy += 35;

    } else if (item.equals("Pork Chop")) {
      hunger -= 65;
      health += 10;
      happiness += 10;
      energy += 30;

    } else if (item.equals("Chicken")) {
      hunger -= 60;
      health += 20;
      happiness += 10;
      energy += 20;

    } else if (item.equals("Catfish")) {
      hunger -= 60;
      health += 15;
      happiness += 10;
      energy += 25;

    } else if (item.equals("Frog")) {
      hunger -= 45;
      health += 15;
      happiness += 25;
      energy += 20;

    } else if (item.equals("Shrimp")) {
      hunger -= 35;
      health += 25;
      happiness += 15;
      energy += 10;
    }
    } // end !foundMedicine
  } // end else (not Steak)

  // --- Stat Clamping ---
  // After any food effect, constrain every stat to its valid range.
  // sickrisk minimum is 20 (not 0) because a baseline illness risk always exists.
  hunger   = clampStat(hunger,   0,  100);
  health   = clampStat(health,   0,  100);
  energy   = clampStat(energy,   0,  100);
  happiness= clampStat(happiness,0,  100);
  sickrisk = clampStat(sickrisk, 20, 100); // sickrisk never drops below 20; there's always a baseline health risk even with perfect care

  // Close the inventory panel after the player uses an item
  isInventoryVisible = false;
}
}

float clampStat(float val, float lo, float hi) {
  return constrain(val, lo, hi);
}

// =========================
// applyAlligatorTint() -- Applies the chosen skin color tint before drawing alligator sprites.
// Must be paired with noTint() afterward.
// Tint helper -- applies color tint based on selected alligator skin
// Accessible globally from all files
// =========================
void applyAlligatorTint() {
  if (selectedAlligatorSkin == 1) tint(0, 255, 0, 255);
  else if (selectedAlligatorSkin == 2) tint(70, 130, 255, 255);
}
