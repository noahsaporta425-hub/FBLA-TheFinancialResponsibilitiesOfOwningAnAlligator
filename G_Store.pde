// =========================
// G_Store.pde
// Store panel rendering, tab display (medicine / snacks / meat), and store fade logic.
// =========================


// =========================
// Store State
// =========================
boolean isStoreOpen = false;
boolean isStoreMainScreenFading = false;  // Phase 1: main screen fades to black before store opens
boolean isStoreEntryFading = false;       // Phase 2: fade from black to reveal store
boolean isStoreFadingOut = false;         // True while store fades to black on exit
boolean isViewingMedicineTab = false;
boolean isViewingSnacksTab = false;
boolean isViewingMeatTab = false;
boolean isMedicineBought = false;
boolean hasClickedStoreExit = false;
boolean canAffordMedicine;
boolean isShowingStoreClosedPopup = false;

PImage storebackground;
PImage medicine;
PImage nachos, cheesepuffs, chips, chocolatebar, cookies, crackers;
PImage energydrink, granolabar, popcorn, pretzels, soda, trailmix;
PImage chicken, catfish, frog, shrimp;

Fade storeFade = new Fade(255);


// =========================
// Store Panel Shared Helpers
// =========================

// drawStorePanelFrame(String title) — Draws the shared store panel background, border, title, and
// close button. Called by each store tab (medicine, snacks, meat) before drawing its items.
void drawStorePanelFrame(String title) {
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
  rectMode(CORNER);
  strokeWeight(1);
  textAlign(CENTER);
  fill(255);
  textSize(35);
  text(title, width/2, height*0.235f);
}

void drawStoreGrid(float[] xs, float[] ys) {
  noFill();
  stroke(169);
  strokeWeight(5);
  strokeCap(SQUARE);
  for (int i = 0; i < xs.length; i++) line(xs[i], ys[0], xs[i], ys[ys.length-1]);
  for (int j = 0; j < ys.length; j++) line(xs[0], ys[j], xs[xs.length-1], ys[j]);
}


// =========================
// Store Panel
// =========================
void store() {
  textSize(30);

  String moneyText = "$" + String.format("%03.2f", money);
  float padding = 20;
  float boxW = textWidth(moneyText) + padding * 2;
  float boxH = 53;
  float boxLeft = 0;
  float boxTop = 631;
  float boxRight = boxLeft + boxW;
  float boxBottom = boxTop + boxH;

  float exitPadding = 20;
  float exitW = textWidth("EXIT") + exitPadding * 2;
  float exitRight = width;
  float exitLeft = exitRight - exitW;
  float exitTop = 631;
  float exitBottom = exitTop + boxH;

  imageMode(CENTER);
  image(storebackground, width/2, height/2, width, height);

  rectMode(CORNERS);
  fill(129, 86, 0);
  stroke(201, 178, 2);
  strokeWeight(5);
  rect(boxLeft, boxTop, boxRight, boxBottom);
  rect(exitLeft, exitTop, exitRight, exitBottom);

  fill(255);
  textAlign(LEFT, CENTER);
  text(moneyText, boxLeft + padding, height * 0.939f);

  textAlign(RIGHT, CENTER);
  text("EXIT", exitRight - exitPadding, height * 0.939f);

  stroke(0);
  strokeWeight(2);
  if (!hasFirstBoughtMedicine && !isViewingMedicineTab && !isViewingSnacksTab && !isViewingMeatTab)
    redarrow(545, 59, "right");

  if (isViewingMedicineTab) {
    drawStorePanelFrame("MEDICINE:");
    // 4-column × 5-row grid divides the left half of the store panel into equal item slots
    float[] xs = {110, 256.66f, 403.32f, width/2};
    float[] ys = {182, 279.625f, 377.25f, 474.875f, 572.5f};
    drawStoreGrid(xs, ys);
    fill(169);
    line(width/2, 182, width/2, 572.5f);
    line(110, 182, 990, 182);
    canAffordMedicine = inventoryHasRoomFor(medicineItemList[selectedInventorySlot]) &&
      (((!medicineIsPrescribed[selectedInventorySlot] && money >= 5) || medicineIsPrescribed[selectedInventorySlot]));
    rectMode(CORNERS);

    if (selectedInventorySlot != -1) {
      if (((!medicineIsPrescribed[selectedInventorySlot] && money >= 5) || medicineIsPrescribed[selectedInventorySlot]) && canAffordMedicine) {
        fill(0, 255, 0, 65);
      } else {
        fill(169, 80);
      }
      rect(682.5625f, 474.875f, 857.4375f, 546);
      textAlign(CENTER);
      fill(255);
      textSize(25);

      if (selectedInventorySlot >= 0 && selectedInventorySlot < medicineIsPrescribed.length && medicineIsPrescribed[selectedInventorySlot]) {
        // prescribed medicines are free; the strikethrough shows the normal $5 price for context
        text("$5.00   $0.00", 770, 522.5f);
        stroke(255, 0, 0);
        line(692, 514, 769, 514);
      } else {
        text("$5.00", 770, 522.5f);
      }

      int r = selectedInventorySlot / 3;
      int c = selectedInventorySlot % 3;
      float x1 = xs[c], x2 = xs[c+1];
      float y1 = ys[r], y2 = ys[r+1];
      float o = 1;
      stroke(255);
      line(x1 - o, y1, x2 + o, y1);
      line(x1 - o, y2, x2 + o, y2);
      line(x1, y1 - o, x1, y2 + o);
      line(x2, y1 - o, x2, y2 + o);

    } else {
      textAlign(CENTER);
      fill(255);
      textSize(30);
      text("No Item Selected", 770, 335);
      textSize(20);
      text("Select an item", 770, 370);
      text("and purchase it!", 770, 390);
    }

    imageMode(CENTER);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 3; col++) {
        float x1 = xs[col], x2 = xs[col + 1];
        float y1 = ys[row], y2 = ys[row + 1];
        image(medicine, (x1+x2)/2, (y1+y2)/2, medicine.width/14, medicine.height/14);
      }
    }

    if (selectedInventorySlot >= 0 && selectedInventorySlot < medicineItemList.length) {
      drawMedicineDetail(selectedInventorySlot);
    }
  }

  if (isViewingSnacksTab) {
    drawStorePanelFrame("SNACKS:");
    float[] xs = {110, 256.66f, 403.32f, width/2};
    float[] ys = {182, 279.625f, 377.25f, 474.875f, 572.5f};
    drawStoreGrid(xs, ys);
    fill(169);
    line(width/2, 182, width/2, 572.5f);
    line(110, 182, 990, 182);
    rectMode(CORNERS);

    if (selectedInventorySlot != -1) {
      if (inventoryHasRoomFor(snackItemList[selectedInventorySlot]) && money >= snackPrices[selectedInventorySlot])
        fill(0, 255, 0, 65);
      else fill(169, 80);
      rect(682.5625f, 474.875f, 857.4375f, 546);
      textAlign(CENTER);
      fill(255);
      textSize(25);
      text("$" + String.format("%03.2f", snackPrices[selectedInventorySlot]), 770, 522.5f);

      int r = selectedInventorySlot / 3;
      int c = selectedInventorySlot % 3;
      float x1 = xs[c], x2 = xs[c+1];
      float y1 = ys[r], y2 = ys[r+1];
      float o = 1;
      stroke(255);
      line(x1 - o, y1, x2 + o, y1);
      line(x1 - o, y2, x2 + o, y2);
      line(x1, y1 - o, x1, y2 + o);
      line(x2, y1 - o, x2, y2 + o);

    } else {
      textAlign(CENTER);
      fill(255);
      textSize(30);
      text("No Item Selected", 770, 335);
      textSize(20);
      text("Select an item", 770, 370);
      text("and purchase it!", 770, 390);
    }

    imageMode(CENTER);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 3; col++) {
        int snackIndex = row * 3 + col;
        float x1 = xs[col], x2 = xs[col + 1];
        float y1 = ys[row], y2 = ys[row + 1];
        image(snackImages[snackIndex], (x1+x2)/2, (y1+y2)/2 + snackDisplayOffsetY[snackIndex],
              snackImages[snackIndex].width/snackDisplayScales[snackIndex],
              snackImages[snackIndex].height/snackDisplayScales[snackIndex]);
      }
    }

    if (selectedInventorySlot >= 0 && selectedInventorySlot < snackItemList.length) {
      drawSnackDetail(selectedInventorySlot);
    }
  }

  if (isViewingMeatTab) {
    drawStorePanelFrame("MEAT:");
    float[] xs = {110, 256.66f, 403.32f, width/2};
    float[] ys = {182, 279.625f, 377.25f, 474.875f, 572.5f};
    drawStoreGrid(xs, ys);
    fill(169);
    line(width/2, 182, width/2, 572.5f);
    line(110, 182, 990, 182);
    rectMode(CORNERS);

    if (selectedInventorySlot != -1) {
      if (inventoryHasRoomFor(meatItemList[selectedInventorySlot]) && money >= meatPrices[selectedInventorySlot])
        fill(0, 255, 0, 65);
      else fill(169, 80);
      rect(682.5625f, 474.875f, 857.4375f, 546);
      textAlign(CENTER);
      fill(255);
      textSize(25);
      text("$" + String.format("%03.2f", meatPrices[selectedInventorySlot]), 770, 522.5f);

      int r = selectedInventorySlot / 3;
      int c = selectedInventorySlot % 3;
      float x1 = xs[c], x2 = xs[c+1];
      float y1 = ys[r], y2 = ys[r+1];
      float o = 1;
      stroke(255);
      line(x1 - o, y1, x2 + o, y1);
      line(x1 - o, y2, x2 + o, y2);
      line(x1, y1 - o, x1, y2 + o);
      line(x2, y1 - o, x2, y2 + o);

    } else {
      textAlign(CENTER);
      fill(255);
      textSize(30);
      text("No Item Selected", 770, 335);
      textSize(20);
      text("Select an item", 770, 370);
      text("and purchase it!", 770, 390);
    }

    imageMode(CENTER);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 3; col++) {
        int meatIndex = row * 3 + col;
        float x1 = xs[col], x2 = xs[col + 1];
        float y1 = ys[row], y2 = ys[row + 1];
        image(meatImages[meatIndex], (x1+x2)/2, (y1+y2)/2,
              meatImages[meatIndex].width/8, meatImages[meatIndex].height/8);
      }
    }

    if (selectedInventorySlot >= 0 && selectedInventorySlot < meatItemList.length) {
      drawMeatDetail(selectedInventorySlot);
    }
  }

  if (hasFirstBoughtMedicine && !hasClickedStoreExit) redarrow(919, 657, "right");
  rectMode(CORNER);

  // Store fade overlay
  if (isStoreFadingOut) {
    if (storeFade.stepOut(8)) {
      isStoreOpen = false;
      isStoreFadingOut = false;
      isOnMainScreen = true;
      storeFade.setClear();
    }
  } else {
    storeFade.stepIn(8);
  }
  storeFade.draw();
}

// storeclosedpopup() — Renders the 'store is closed' notice that appears on every 7th day
// (Sunday), modeling real-world business hours.
void storeclosedpopup() {
  // store closes every 7th day (modeled as Sunday) to teach budgeting ahead
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);
  fill(0);
  textFont(times50);
  textSize(20);
  drawWrappedTextInBox("The store is closed on Sundays (days that are multiples of 7). Come back tomorrow!", 338, 271, 761, 400, 6);
}
