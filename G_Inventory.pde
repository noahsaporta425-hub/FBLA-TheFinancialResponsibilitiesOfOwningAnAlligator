// =========================
// G_Inventory.pde
// Inventory panel rendering, item detail display helpers, and inventory utility functions.
// =========================


// =========================
// Inventory Data
// =========================
// 12 slots (3×4 grid) give enough space to hold several food types and medicines without overwhelming the UI
String[] inventorySlots = {
  "Steak", "EMPTY", "EMPTY", "EMPTY", // the tutorial steak is pre-placed so new players immediately see how inventory works
  "EMPTY", "EMPTY", "EMPTY", "EMPTY",
  "EMPTY", "EMPTY", "EMPTY", "EMPTY"
};
int filledSlotCount = 0;

// each medicine has a different dose count based on treatment length; shorter courses for mild illnesses, longer for severe ones
int[] medicineDefaultQuantities = {
  2, // Enrofloxacin
  3, // Doxycycline
  3, // Oseltamivir
  3, // Vitamin B-Complex
  2, // Cyproheptadine
  2, // Potassium Chloride
  2, // Coenzyme Q10
  4, // Fluoxetine
  3, // Trazodone
  2, // Meloxicam
  3, // Calcium Carbonate
  1  // Activated Charcoal
};
int[] medicineQuantities = { 0,0,0,0,0,0,0,0,0,0,0,0 };
int[] snackQuantities    = { 0,0,0,0,0,0,0,0,0,0,0,0 };
int[] meatQuantities     = { 0,0,0,0,0,0,0,0,0,0,0,0 };


// =========================
// Item Name / Description Arrays
// =========================
// medicineItemList: canonical medicine name list shared by store, inventory, and eat() logic
String[] medicineItemList = {
  "Enrofloxacin","Doxycycline","Oseltamivir","Vitamin B-Complex",
  "Cyproheptadine","Potassium Chloride","Coenzyme Q10","Fluoxetine",
  "Trazodone","Meloxicam","Calcium Carbonate","Activated Charcoal"
};
boolean[] medicineIsPrescribed = new boolean[12];
String[] medicineDesc1 = {
  "Pet with an infection? Give 1 pill daily",
  "Pet with a cold? Give 1 pill daily",
  "Pet with a flu? Give 1 pill daily",
  "Pet malnourished? Give 1 pill daily",
  "Pet is starving? Give 1 pill daily",
  "Pet has low energy? Give 1 pill daily",
  "Pet exhausted? Give 1 pill daily",
  "Pet depressed? Give 1 pill daily",
  "Pet stressed? Give 1 pill daily",
  "Pet injured? Give 1 pill daily",
  "Pet has weak bones? Give 1 pill daily",
  "Pet is food poisoned? Give 1 pill"
};
String[] medicineDesc2 = {
  "for 2 days. Or your pet dies.",
  "for 3 days. Or your pet dies.",
  "for 3 days.",
  "for 3 days.",
  "for 2 days.",
  "for 2 days.",
  "for 2 days.",
  "for 4 days.",
  "for 3 days.",
  "for 2 days.",
  "for 3 days.",
  "immediately to remove toxins."
};

// snackItemList: canonical snack name list shared by store, inventory, and eat() logic
String[] snackItemList = {
  "Nachos","Cheesepuffs","Chips","Chocolate Bar","Cookies","Crackers",
  "Energy Drink","Granola Bar","Popcorn","Pretzels","Soda","Trail Mix"
};
String[] snackDesc1 = {
  "Messy cheesy chips with heavy seasoning.",
  "Crunchy cheese puffs packed with salt",
  "Crispy potato chips loaded with oil",
  "Sugary chocolate bar with lots of",
  "Sweet baked cookies full of sugar",
  "Light crunchy crackers that are",
  "Very high caffeine and sugar.",
  "A packaged granola bar that seems",
  "Buttery popcorn with lots of salt",
  "Twisty salty pretzels with lots of",
  "Pure sugar and fizz.",
  "A snack mix with salty and sweet"
};
String[] snackDesc2 = {
  "Tasty, but definitely not healthy.",
  "and artificial flavoring.",
  "and sodium.",
  "processed sweeteners.",
  "and refined carbs.",
  "salty and not very filling.",
  "A terrible choice for a pet.",
  "healthy, but still processed.",
  "and flavor dust.",
  "sodium.",
  "Not suitable for an alligator.",
  "bits all combined together."
};
String[] snackStats = {
  "-40 Hunger   -15 Health   +5 Happiness   +30 Energy",
  "-25 Hunger   -5 Health   +20 Happiness   +10 Energy",
  "-30 Hunger   -10 Health   +10 Happiness   +10 Energy",
  "-7 Hunger   -5 Health   +20 Happiness   +5 Energy",
  "-30 Hunger   -5 Health   +10 Happiness   +5 Energy",
  "-5 Hunger   +20 Energy",
  "+20 Hunger   -35 Health   -10 Happiness   +70 Energy",
  "-15 Hunger   -5 Health   +5 Happiness   +20 Energy",
  "-10 Hunger   -10 Health   +30 Happiness   +10 Energy",
  "-10 Hunger   -5 Health   +5 Happiness   +15 Energy",
  "+30 Hunger   -30 Health   +5 Happiness   +40 Energy",
  "-10 Hunger   -5 Health   +5 Happiness   +20 Energy"
};

// meatItemList: canonical meat/fish name list shared by store, inventory, and eat() logic
String[] meatItemList = {
  "Bluegill","Bass","Perch","Goldfish","Crab","Lamb Chop",
  "Pork Chop","Steak","Chicken","Catfish","Frog","Shrimp"
};
String[] meatDesc1 = {
  "A nutritious freshwater fish with",
  "A filling fish meal packed with",
  "A lean fish choice that's healthy",
  "A small prey-sized bite that gives",
  "Rich shellfish meat with minerals",
  "A heavy red meat meal that is very",
  "A hearty cut of pork with lots of",
  "A premium meat cut that gives huge",
  "Lean poultry meat that's balanced,",
  "A dense fish meal with strong",
  "A natural prey option that feels",
  "A light seafood bite that boosts"
};
String[] meatDesc2 = {
  "solid protein and moderate fat.",
  "protein and natural oils.",
  "and easy to digest.",
  "a quick little meal.",
  "and lots of flavor.",
  "filling and energy dense.",
  "protein and fat.",
  "nutrition and energy.",
  "healthy, and reliable.",
  "protein and rich flavor.",
  "especially satisfying to eat.",
  "health more than fullness."
};
String[] meatStats = {
  "-55 Hunger   +15 Health   +10 Happiness   +20 Energy",
  "-60 Hunger   +20 Health   +10 Happiness   +25 Energy",
  "-50 Hunger   +20 Health   +5 Happiness   +15 Energy",
  "-30 Hunger   +5 Health   +15 Happiness   +10 Energy",
  "-50 Hunger   +25 Health   +20 Happiness   +15 Energy",
  "-70 Hunger   +10 Health   +15 Happiness   +35 Energy",
  "-65 Hunger   +10 Health   +10 Happiness   +30 Energy",
  "-70 Hunger   +20 Health   +20 Happiness   +40 Energy",
  "-60 Hunger   +20 Health   +10 Happiness   +20 Energy",
  "-60 Hunger   +15 Health   +10 Happiness   +25 Energy",
  "-45 Hunger   +15 Health   +25 Happiness   +20 Energy",
  "-35 Hunger   +25 Health   +15 Happiness   +10 Energy"
};

float[] snackPrices = {
  4.50f, // Nachos
  3.25f, // Cheesepuffs
  2.75f, // Chips
  2.50f, // Chocolatebar
  3.00f, // Cookies
  2.25f, // Crackers
  3.75f, // Energydrink
  2.50f, // Granolabar
  2.75f, // Popcorn
  2.25f, // Pretzels
  2.00f, // Soda
  3.50f  // Trailmix
};
float[] meatPrices = {
  6.00f, // Bluegill
  7.00f, // Bass
  6.50f, // Perch
  4.50f, // Goldfish
  8.00f, // Crab
  10.00f, // Lamb Chop
  9.00f, // Pork Chop
  11.00f, // Steak
  7.50f, // Chicken
  8.50f, // Catfish
  7.00f, // Frog
  6.50f  // Shrimp
};

// Image arrays for snack/meat grid display (initialized in fileWork())
PImage[] snackImages;
PImage[] meatImages;

// per-item display tweaks to center each sprite correctly in its slot; values determined visually since each sprite has different whitespace
float[] snackDisplayScales  = {9, 8, 8, 12, 6.5f, 7, 11.5f, 7, 8, 6, 14, 8};
float[] snackDisplayOffsetY = {0, 5, 10, 0, -2, 2, 0, 10, 1.5f, 3, 0, 6};


// =========================
// indexOf(String[] arr, String val) — Returns the first index where val appears in arr,
// or -1 if not found. Used to locate items by name.
// =========================
int indexOf(String[] arr, String val) {
  for (int i = 0; i < arr.length; i++) if (arr[i].equals(val)) return i;
  return -1;
}


// =========================
// inventoryHasRoomFor(String item) — Returns true if the item already exists in inventory
// (stackable) or if there is an empty slot available.
// =========================
boolean inventoryHasRoomFor(String item) {
  for (int i = 0; i < inventorySlots.length; i++) {
    if (inventorySlots[i].equals("EMPTY") || inventorySlots[i].equals(item)) {
      return true;
    }
  }
  return false;
}


// =========================
// Item Detail Display Helpers
// =========================
// drawItemDetail(...) — Renders the item detail side panel when a slot is selected, showing
// the item image, description, stat effects, and use/sell buttons.
void drawItemDetail(String name, String desc1, String desc2, String statLine, PImage img, float scale) {
  textAlign(CENTER);
  textSize(30);
  text(name, 770, 233);
  textSize(20);
  text(desc1, 770, 406);
  text(desc2, 770, 436);
  textSize(15);
  text(statLine, 770, 258);
  imageMode(CENTER);
  image(img, 770, 333, img.width/scale, img.height/scale);
  imageMode(CORNER);
}

void drawMedicineDetail(int idx) {
  textAlign(CENTER);
  textSize(30);
  text(medicineItemList[idx], 770, 233);
  textSize(20);
  text(medicineDesc1[idx], 770, 406);
  text(medicineDesc2[idx], 770, 436);
  if (medicineIsPrescribed[idx]) text("Prescribed: Yes", 770, 258);
  else text("Prescribed: No", 770, 258);
  imageMode(CENTER);
  image(medicine, 770, 333, medicine.width/9, medicine.height/9);
  imageMode(CORNER);
}

void drawSnackDetail(int idx) {
  drawItemDetail(snackItemList[idx], snackDesc1[idx], snackDesc2[idx], snackStats[idx], snackImages[idx], snackDisplayScales[idx]);
}

void drawMeatDetail(int idx) {
  drawItemDetail(meatItemList[idx], meatDesc1[idx], meatDesc2[idx], meatStats[idx], meatImages[idx], 7);
}


// =========================
// Inventory Panel
// =========================
// inventory() — Renders the full inventory panel: 3×4 slot grid on the left, item detail panel on the right.
void inventory() {
  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(110, 122.5f, 990, 572.5f);
  noFill();
  rect(933, 132, 976, 171.5f);
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X", 942, 151.75f);
  fill(169);
  line(width/2, 182, width/2, 572.5f);
  line(110, 182, 990, 182);

  float[] xs = {110, 256.66f, 403.32f, width/2};
  float[] ys = {182, 279.625f, 377.25f, 474.875f, 572.5f};

  noFill();
  stroke(169);
  strokeWeight(5);
  strokeCap(SQUARE);

  for (int i = 0; i < xs.length; i++) {
    line(xs[i], ys[0], xs[i], ys[ys.length-1]);
  }
  for (int j = 0; j < ys.length; j++) {
    line(xs[0], ys[j], xs[xs.length-1], ys[j]);
  }

  filledSlotCount = 0;
  for (String slots : inventorySlots) {
    if (!slots.equals("EMPTY")) filledSlotCount++;
  }

  if (selectedInventorySlot >= 0 && selectedInventorySlot < inventorySlots.length) {
    if (!inventorySlots[selectedInventorySlot].equals("EMPTY")) {
      fill(0, 255, 0, 65);
      rect(585.125f, 474.875f, 760, 546);
      textAlign(CENTER);
      fill(255);
      textSize(40);
      text("FEED", 672.5625f, 522.5f);

      fill(255, 0, 0, 65);
      rect(780, 474.875f, 954.875f, 546);
      fill(255);
      text("SELL", 867.4375f, 522.5f); // items resell at 75% of their buy price — same as the sell logic in B_Interaction.pde
    } else {
      textAlign(CENTER);
      fill(255);
      textSize(30);
      text("No Item Selected", 770, 335);
      textSize(20);
      text("Select an item or head to ", 770, 370);
      text("the store to buy one!", 770, 390);
    }
  } else {
    textAlign(CENTER);
    fill(255);
    textSize(30);
    text("No Item Selected", 770, 335);
    textSize(20);
    text("Select an item or head to ", 770, 370);
    text("the store to buy one!", 770, 390);
  }

  if (selectedInventorySlot >= 0 && selectedInventorySlot < inventorySlots.length) {
    int r = selectedInventorySlot / 3; // convert flat slot index to row/column in the 3-column grid
    int c = selectedInventorySlot % 3;

    float x1 = xs[c], x2 = xs[c+1];
    float y1 = ys[r], y2 = ys[r+1];

    float o = 1;
    stroke(255);

    line(x1 - o, y1,     x2 + o, y1);
    line(x1 - o, y2,     x2 + o, y2);
    line(x1,     y1 - o, x1,     y2 + o);
    line(x2,     y1 - o, x2,     y2 + o);
  }

  rectMode(CORNER);
  strokeWeight(1);
  textAlign(CENTER);
  fill(255);
  textSize(35);
  text("INVENTORY:", width/2, height*0.235f);

  imageMode(CENTER);

  for (int i = 0; i < inventorySlots.length; i++) {
    if (!inventorySlots[i].equals("EMPTY")) {
      int row = i / 3;
      int col = i % 3;

      float slotX1 = xs[col];
      float slotX2 = xs[col + 1];
      float slotY1 = ys[row];
      float slotY2 = ys[row + 1];

      float steakX = slotX1 + 70;
      float steakY = slotY1 + 51;
      float qtyX   = slotX1 + 110;
      float qtyY   = slotY1 + 86;

      float medX = (slotX1 + slotX2) / 2;
      float medY = (slotY1 + slotY2) / 2;

      String slotItem = inventorySlots[i];
      int medIdx   = indexOf(medicineItemList, slotItem);
      int snackIdx = indexOf(snackItemList, slotItem);
      int meatIdx  = indexOf(meatItemList, slotItem);

      if (slotItem.equals("Steak") && !hasFedSteak) {
        image(steak, steakX, steakY, steak.width/7, steak.height/7);
        textSize(30);
        fill(255);
        text("x1", qtyX, qtyY);

      } else if (medIdx >= 0) {
        image(medicine, medX, medY, medicine.width/14, medicine.height/14);
        fill(255);
        textSize(30);
        text("x" + medicineQuantities[medIdx], qtyX, qtyY);

      } else if (snackIdx >= 0) {
        image(snackImages[snackIdx], medX, medY + snackDisplayOffsetY[snackIdx],
              snackImages[snackIdx].width/snackDisplayScales[snackIdx],
              snackImages[snackIdx].height/snackDisplayScales[snackIdx]);
        fill(255);
        textSize(30);
        text("x" + snackQuantities[snackIdx], qtyX, qtyY);

      } else if (meatIdx >= 0) {
        image(meatImages[meatIdx], medX, medY,
              meatImages[meatIdx].width/8, meatImages[meatIdx].height/8);
        fill(255);
        textSize(30);
        text("x" + meatQuantities[meatIdx], qtyX, qtyY);
      }
    }
  }

  if (selectedInventorySlot != -1 && selectedInventorySlot < inventorySlots.length) {
    String selectedItem = inventorySlots[selectedInventorySlot];

    textAlign(CENTER);
    fill(255);

    if (selectedItem.equals("Steak") && !hasFedSteak) {
      textSize(30);
      text("Steak", 770, 233);
      textSize(20);
      text("The dream of any pet, having", 770, 406);
      text("no potential negative effects.", 770, 436);
      textSize(14);
      text("-70 Hunger   +40 Energy   +20 Health   +20 Happiness", 770, 258);
      textSize(20);
      imageMode(CENTER);
      image(steak, 770, 333, steak.width/4, steak.height/4);
      imageMode(CORNER);

    } else {
      int selMedIdx   = indexOf(medicineItemList, selectedItem);
      int selSnackIdx = indexOf(snackItemList, selectedItem);
      int selMeatIdx  = indexOf(meatItemList, selectedItem);

      if (selMedIdx >= 0) {
        drawMedicineDetail(selMedIdx);
      } else if (selSnackIdx >= 0) {
        drawSnackDetail(selSnackIdx);
      } else if (selMeatIdx >= 0) {
        drawMeatDetail(selMeatIdx);
      }
    }
  }

  if (isShowingCantSell == true) cantsell();
  stroke(0);
}

// cantsell() — Shows the popup that blocks selling the tutorial steak (Day 1 starting item),
// so beginners always have a first meal.
void cantsell() {
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);
  fill(0);
  textFont(times50);
  textSize(20);
  drawWrappedTextInBox("Selling your steak could leave " + alligator.petName + " starving. Financial decisions are now yours — choose wisely.", 338, 271, 761, 400, 6);
}
