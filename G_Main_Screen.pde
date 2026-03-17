// =========================
// G_Main_Screen.pde
// Core main gameplay screen: state flags, HUD rendering, mainscreen() orchestrator,
// stat bars, day progression, tutorial popups, quit/game-over overlays.
//
// Sub-systems live in their own files:
//   G_Inventory.pde   — inventory panel + item data
//   G_Store.pde       — store panel + fade logic
//   G_Bank.pde        — bank panel + transaction log
//   G_Earn.pde        — earn panel, job finder, tasks/upgrades
//   G_Services.pde    — vet, walker, cleaner, prescriptions
//   G_Rest.pde        — rest bar mini-game
//   G_Achievements.pde — achievement system + panel
// =========================


// =========================
// UI Image Assets
// =========================
PImage mainscreen;
PImage mainscreenbuttons;
PImage achievementsbutton;
PImage settingsbutton;
PImage earnbutton;
PImage popupbackground;
PImage steak;
PImage redarrow;

PFont arcade;
PFont times30;


// =========================
// Screen State Flags
// =========================
boolean isOnMainScreen = false;

// Tutorial progression flags
boolean isWelcomePopupVisible  = true;
boolean isInventoryVisible     = false;
boolean hasOpenedInventory     = false;
boolean hasFedSteak            = false;
boolean isShowingCantSell      = false;
boolean isShowingPlayPopup     = false;
boolean hasShownPlayPopup      = false;
boolean isShowingPlayArrow     = false;
boolean isPlayClicked          = false;
boolean isFadingOut            = false;
boolean hasEnergyStabilized    = false;
boolean isNextDayPopupOpen     = false;
boolean hasAdvancedDay         = false;
boolean isShowingQuitDialog    = false;
boolean isGameOver             = false;
boolean hasFirstBoughtMedicine = false;
boolean hasGivenFirstMedicine  = false;


// =========================
// UI Runtime State
// =========================
int selectedInventorySlot = -1;
int playPopupDelayTimer   = 0;

String selectedItemName;


// =========================
// HUD Stat Bars (minigame overlay — main screen creates them locally each frame)
// =========================
StatBar healthbar       = new StatBar(99,      66.15f,   180, 14);
StatBar happinessbar    = new StatBar(129.25f, 101.5f,   180, 14);
StatBar energybar       = new StatBar(99,      136.15f,  180, 14);
StatBar sicknessriskbar = new StatBar(189.2f,  170.555f, 180, 14);
StatBar hungerbar       = new StatBar(99,      206.15f,  180, 14);


// =========================
// Main Screen Entry/Exit Fades
// =========================
Fade mainFade = new Fade(255);   // starts black; fades to clear on entry


// =========================
// Core Economy & Progression
// =========================
int   day   = 1;
float money = 0;


// =========================
// Food Thought Bubble Animation
// =========================
PImage cloudframe1, cloudframe2, cloudframe3;
int cloudFrameTimer = 0;


// =========================
// Global Pet Reference
// Instantiated in D_General_Functions.pde :: fileWork()
// =========================
Pet alligator;


// =========================
// Guide Arrow Animation
// =========================
float guideArrowOffset    = 0;
boolean isGuideArrowMovingUp = true;


// =========================
// Day / Sickness State
// =========================
int     sickRoll           = 0;
boolean isDayEdited        = false;
boolean isDayChangeConfirmed = false;
String  sicknessStatusText = "";
String  salaryInfoText     = "";


// =========================
// mainscreen()
// Central render function — draws background, pet, HUD, and delegates to sub-panels.
// =========================
void mainscreen() {
  imageMode(CORNER);
  isNamingActive = false;
  if (!isOnChoiceScreen) isOnMainScreen = true;

  if (alligator.health <= 0 && !isGameOver) {
    isGameOver = true;
  }

  image(mainscreen, 0, 0, width, height);
  // Mood display priority: sick > hungry > energetic > neutral. Only one mood shows at a time.
  if (isPetSick) {
    alligator.sickmood();
  } else if (alligator.hunger > 80) {
    // 80+ triggers a visible mood change to warn the player before stats become critical
    alligator.hungrymood();
  } else if (alligator.energy > 80) {
    // 80+ triggers a visible mood change to warn the player before stats become critical
    alligator.energeticmood();
  } else {
    alligator.neutralmood();
  }

  image(mainscreenbuttons, 0, height * 0.52f, 1000, 600);
  image(achievementsbutton, width * 0.806f, height * 0.21f, 320, 190);
  image(settingsbutton, width * 0.83655f, -35, 248, 168);
  image(earnbutton, width * 0.845f, height * 0.075f, 231, 177);

  textFont(arcade);
  textAlign(RIGHT, CENTER);
  fill(255);
  text("$" + String.format("%03.2f", money) + "   " + "Day " + day, width * 0.9f, height * 0.061f);

  stroke(0);
  statbars();
  imageMode(CORNER);

  // Food thought bubble (Day 1 until fed)
  if (!hasFedSteak) {
    cloudFrameTimer++;
    if (cloudFrameTimer >= 30) cloudFrameTimer = 0;  // cycle cloud sprite every 30 frames (~0.5s) for a gentle animated sky effect
    if      (cloudFrameTimer < 10) image(cloudframe1, width*0.48f, height*0.35f);
    else if (cloudFrameTimer < 20) image(cloudframe2, width*0.48f, height*0.35f);
    else                           image(cloudframe3, width*0.48f, height*0.35f);
    imageMode(CENTER);
    image(steak, 632, 326, steak.width/8, steak.height/8);
  }

  if (isWelcomePopupVisible) {
    image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);
    fill(0);
    textFont(times50);
    textSize(20);
    drawWrappedTextInBox("Welcome to your first day of alligator pet care! It seems like " + alligator.petName + " is already hungry! Head to your inventory after closing this window to feed him the food you were given at the adoption center!", 338, 271, 761, 400, 6);
  }

  // Tutorial guide arrows
  if (hasOpenedInventory == false || (isStoreOpen == false && hasFirstBoughtMedicine && !isInventoryVisible && !hasGivenFirstMedicine)) {
    redarrow(239.5f, 500, "down");
  }
  if (isShowingPlayArrow) redarrow(656, 500, "down");
  if ((hasShownEarnPopup || isShowingEarnPopup) && isEarnPanelOpen == false && !hasOpenedEarnPanel) redarrow(940, 134, "right");
  if (hasShownBankPopup && !hasViewedBank) redarrow(861, 500, "down");
  if (hasShownTreatmentPopup && !isStoreOpen && !hasFirstBoughtMedicine) redarrow(337, 500, "down");

  if (isInventoryVisible) inventory();

  // Play popup logic
  if (hasFedSteak && !hasShownPlayPopup && !isShowingPlayPopup) {
    playPopupDelayTimer++;
    if (playPopupDelayTimer > 60 && alligator.energy > 80) {
      isShowingPlayPopup = true;
      isShowingPlayArrow = true;
    }
  }
  if (alligator.energy < 80 && hasShownPlayPopup) hasEnergyStabilized = true;
  if (alligator.energy < 80 && hasEnergyStabilized) isShowingPlayArrow = false;
  if (isShowingPlayPopup) playpopup();

  // Earn popup logic
  if (hasEnergyStabilized && isExitingMinigame && !hasShownEarnPopup) {
    earnPopupDelayTimer++;
    if (earnPopupDelayTimer > 60) isShowingEarnPopup = true;
  }
  if (isShowingEarnPopup && !isInventoryVisible) earnpopup();

  if (isEarnPanelOpen) earn();

  if (job.equals("cashier") && !hasShownJobPopup && !isShowingJobPopup && !isJobFinderOpen && !isTasksPanelOpen) {
    isShowingJobPopup = true;
  }
  if (isEarnPanelOpen && !isJobFinderOpen && !isTasksPanelOpen && job.equals("unemployed")) redarrow(155, 455, "right");
  if (isShowingFirstHelpPopup) help();
  if (hasShownFirstHelpPopup && !isServicesOpen && !hasOpenedServices) redarrow(760, 502, "down");
  if (isServicesOpen && !isVetOpen) services();
  if (!isJobFinderOpen && job.equals("cashier") && !hasShownJobPopup) jobpopup();
  if (hasShownJobPopup && !hasClickedTaskTab && !isJobFinderOpen && !job.equals("unemployed")) redarrow(529, 455, "right");

  if (isVetOpen) vet();
  if (isShowingTreatmentPopup) treatmentpopup();
  if (isStoreOpen) store();

  if (hasGivenFirstMedicine && !hasShownBankPopup) {
    bankpopup();
    isShowingBankPopup = true;
  }
  if (isBankOpen) bank();

  if (hasViewedBankFirstTime && !hasShownRestPopup) {
    isShowingRestPopup = true;
    restpopup();
  }
  if (hasShownRestPopup && !isRestOpen && !hasAlligatorRestedOnce) redarrow(439, 500, "down");
  if (isRestOpen) rest();

  if (hasAlligatorRestedOnce && !hasOpenedAchievements) redarrow(940, 231, "right");
  if (isAchievementsOpen) achievements();

  if (money >= highestMoneyBalance) highestMoneyBalance = money;

  if (isShowingStoreClosedPopup) storeclosedpopup();
  if (hasClosedAchievements && !hasAdvancedDay) redarrow(width/2, 500, "down");
  if (isNextDayPopupOpen) nextday();
  if (isShowingQuitDialog) quitpopup();

  // Fade overlays
  noStroke();
  if (isPlayClicked) {
    isFadingOut = true;
    if (mainFade.isBlack()) {
      if (!isExitingMinigame) play();
      isOnMainScreen = false;
    } else {
      mainFade.stepOut(2);
      mainFade.draw();
    }
  } else if (isStoreMainScreenFading) {
    if (mainFade.isBlack()) {
      isStoreOpen = true;
      isStoreMainScreenFading = false;
      isStoreEntryFading = true;
      storeFade.setClear();
      isStoreFadingOut = false;
    } else {
      mainFade.stepOut(2);
    }
    mainFade.draw();
  } else if (isStoreEntryFading) {
    if (mainFade.stepIn(2)) isStoreEntryFading = false;
    mainFade.draw();
  } else if (!isStoreOpen) {
    mainFade.stepIn(1);
    mainFade.draw();
  }

  if (isGameOver) gameOverScreen();
}


// =========================
// Stat Bar Display (HUD)
// Renders all four stat bars (health, sickness risk, energy, hunger) in the HUD along with their labels
// =========================
void statbars() {
  textAlign(LEFT, CENTER);
  strokeWeight(2);
  textSize(27);
  text("Pet Statistics:", width * 0.015f, height * 0.05f);

  textSize(20);
  text("Health:", width * 0.015f, height * 0.1f);
  StatBar healthbar = new StatBar(width * 0.09f, height * 0.0945f, 180, 14);
  healthbar.setValue(alligator.health);
  healthbar.drawpositive();

  fill(255);
  text("Happiness:", width * 0.015f, height * 0.15f);
  StatBar happinessbar = new StatBar(width * 0.1175f, height * 0.145f, 180, 14);
  happinessbar.setValue(alligator.happiness);
  happinessbar.drawpositive();

  fill(255);
  text("Energy:", width * 0.015f, height * 0.2f);
  StatBar energybar = new StatBar(width * 0.09f, height * 0.1945f, 180, 14);
  energybar.setValue(alligator.energy);
  energybar.drawenergyscale();

  fill(255);
  text("Risk of Sickness:", width * 0.015f, height * 0.25f);
  StatBar sicknessriskbar = new StatBar(width * 0.172f, height * 0.24365f, 180, 14);
  sicknessriskbar.setValue(alligator.sickrisk);
  sicknessriskbar.drawnegative();

  fill(255);
  text("Hunger:", width * 0.015f, height * 0.3f);
  StatBar hungerbar = new StatBar(width * 0.09f, height * 0.2945f, 180, 14);
  hungerbar.setValue(alligator.hunger);
  hungerbar.drawnegative();
}


// =========================
// StatBar Class
// Renders a horizontal fill bar for a 0–100 stat value.
// Three draw modes reflect different desired directions:
//   drawpositive()    — high value = green (health, happiness)
//   drawnegative()    — high value = red   (sickness risk, hunger)
//   drawenergyscale() — mid-range = green, extremes = red (energy)
// =========================
class StatBar {
  float x, y, w, h;
  float value = 100;

  StatBar(float x, float y, float w, float h) {
    this.x = x; this.y = y; this.w = w; this.h = h;
  }

  void setValue(float v) { value = constrain(v, 0, 100); }

  // High is good: green → yellow → orange → red as value falls
  void drawpositive() {
    fill(50); rect(x, y, w, h, 4);
    // color shifts from green→yellow→orange→red as the stat deteriorates, giving clear visual urgency
    if      (value >= 90) fill(0, 200, 100);   // great
    else if (value >= 70) fill(182, 232, 35);  // good
    else if (value >= 50) fill(227, 220, 0);   // fair
    else if (value >= 40) fill(227, 155, 0);   // low
    else                  fill(201, 8, 8);     // critical
    rect(x, y, map(value, 0, 100, 0, w), h, 4);
  }

  // High is bad: red → orange → yellow → green as value falls
  void drawnegative() {
    fill(50); rect(x, y, w, h, 4);
    // color shifts from green→yellow→orange→red as the stat deteriorates, giving clear visual urgency
    if      (value >= 90) fill(201, 8, 8);     // critical
    else if (value >= 70) fill(227, 155, 0);   // high
    else if (value >= 50) fill(227, 220, 0);   // moderate
    else if (value >= 40) fill(182, 232, 35);  // low
    else                  fill(0, 200, 100);   // safe
    rect(x, y, map(value, 0, 100, 0, w), h, 4);
  }

  // Mid-range (40–70) is ideal: both extremes turn red
  void drawenergyscale() {
    fill(50); rect(x, y, w, h, 4);
    if      (value >= 80) fill(201, 8, 8);     // too hyper — dangerous
    else if (value >= 70) fill(182, 232, 35);  // slightly high but ok
    else if (value >= 40) fill(0, 200, 100);   // ideal range
    else if (value >= 20) fill(182, 232, 35);  // slightly low
    else                  fill(201, 8, 8);     // exhausted — dangerous
    rect(x, y, map(value, 0, 100, 0, w), h, 4);
  }
}


// =========================
// drawWrappedTextInBox
// Word-wraps text inside a rounded rectangle popup box; used for all tutorial and advice popups.
// Params: x/y = center, w/h = box size, text = message to display, textSz = font size
// =========================
void drawWrappedTextInBox(String sentence, float leftX, float topY, float rightX, float bottomY, float extraSpacing) {
  float maxW  = rightX - leftX;
  float lineH = textAscent() + textDescent() + extraSpacing;
  float y     = topY;
  String[] words = splitTokens(sentence, " ");
  String line = "";

  textAlign(LEFT, TOP);

  for (int i = 0; i < words.length; i++) {
    String testLine = (line.length() == 0) ? words[i] : line + " " + words[i];
    if (textWidth(testLine) <= maxW) {
      line = testLine;
    } else {
      if (y + (textAscent() + textDescent()) > bottomY) return;
      text(line, leftX, y);
      y += lineH;
      line = words[i];
    }
  }
  if (line.length() > 0) {
    if (y + (textAscent() + textDescent()) > bottomY) return;
    text(line, leftX, y);
  }
}


// =========================
// redarrow — animated bouncing guide arrow
// =========================
void redarrow(float arrowx, float arrowy, String direction) {
  imageMode(CENTER);

  float drawX = arrowx;
  float drawY = arrowy;

  if (direction.equals("right")) drawX = arrowx + guideArrowOffset;
  else                           drawY = arrowy + guideArrowOffset;

  pushMatrix();
  translate(drawX, drawY);
  if (direction.equals("right")) rotate(-HALF_PI);
  image(redarrow, 0, 0, redarrow.width/3, redarrow.height/3);
  popMatrix();

  // arrow bobs 25px downward to draw the player's eye without being distracting
  if (isGuideArrowMovingUp) {
    guideArrowOffset--;
    if (guideArrowOffset <= -25) isGuideArrowMovingUp = false;  // -25 to 0 bounce range
  } else {
    guideArrowOffset++;
    if (guideArrowOffset >= 0) isGuideArrowMovingUp = true;
  }
}


// =========================
// Tutorial Popups (main-screen level)
// =========================
void playpopup() {
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);
  fill(0);
  textFont(times50);
  textSize(20);
  drawWrappedTextInBox("Uh oh! Feeding the steak to " + alligator.petName + " gave them too much energy. An alligator with too much energy is very dangerous! Let " + alligator.petName + " play after closing this window to stabilize their energy!", 338, 271, 761, 400, 6);
}


// =========================
// Next Day Logic
// =========================
void nextday() {
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);

  fill(0);
  textFont(times50);
  textSize(20);

  if (!isDayEdited) {
    decideSicknessForNewDay();
    daychanges();
    day++;
    currentDay++;
    isDayEdited = true;
  }

  drawWrappedTextInBox(
    "Welcome to day " + day + "! " + sicknessStatusText + salaryInfoText + " Check " + alligator.petName + "'s stats to guide your care!",
    338, 271, 761, 400, 6
  );
}

// =========================
// decideSicknessForNewDay()
// Rolls against the pet's current sickrisk to determine if illness triggers.
// The sickness type is chosen based on whichever stat is most critically out of range —
// giving the player a meaningful signal that their stat neglect caused the illness.
// sicknessNames[] indices (defined in D_General_Functions.pde):
//   0=default, 1=cold, 2=flu, 3=fatigue, 4=dehydration,
//   5=exhaustion, 6=weakness, 7=depression, 8=anxiety, 9=infection, 10=fever, 11=parasite
// =========================
void decideSicknessForNewDay() {
  sickRoll = int(random(0, 101));

  if (sickRoll <= alligator.sickrisk && !isPetSick) {
    isPetSick = true;

    // Priority order: most severe stat violations assigned first
    int sicknessIndex = 0;
    if      (alligator.hunger >= 85)                              sicknessIndex = 4;  // dehydration sets in above 85% hunger — the body can't maintain health when severely underfed
    else if (alligator.energy <= 10)                              sicknessIndex = 6;  // no energy → weakness
    else if (alligator.happiness <= 15 || alligator.energy >= 90) sicknessIndex = 8;  // miserable/over-excited → anxiety
    else if (alligator.hunger >= 70)                              sicknessIndex = 3;  // moderately hungry → fatigue
    else if (alligator.energy <= 20)                              sicknessIndex = 5;  // low energy → exhaustion
    else if (alligator.happiness <= 25)                           sicknessIndex = 7;  // unhappy → depression
    // No dominant stat culprit — random chance for minor illnesses
    // probability weights tuned so the player usually has one day of warning before getting sick
    else if (random(1) < 0.20)                                    sicknessIndex = 9;  // infection
    else if (random(1) < 0.20)                                    sicknessIndex = 11; // parasite
    else if (random(1) < 0.20)                                    sicknessIndex = 10; // fever
    else if (random(1) < 0.35)                                    sicknessIndex = 1;  // cold
    else if (random(1) < 0.20)                                    sicknessIndex = 2;  // flu

    currentSicknessName = sicknessNames[sicknessIndex];
  } else if (!isPetSick) {
    currentSicknessName = "";
  }
}

// =========================
// daychanges()
// Applies all stat and economy changes that happen at the start of every new day.
// Called once per day transition inside nextday(), guarded by isDayEdited.
// =========================
void daychanges() {
  restAttemptsRemaining = 2;  // reset rest opportunities for the new day

  // Natural daily stat drift: pet gets hungrier and more energetic overnight,
  // and happiness declines without active player care
  alligator.happiness -= 10;  // overnight: pet gets hungry and restless (hunger/energy rise) and loses a little happiness from being alone
  alligator.hunger    += 40;
  alligator.energy    += 40;

  // Skipping the cleaner raises sickness risk (dirty habitat spreads bacteria)
  if (!hasCleanerVisited) alligator.sickrisk += 15;  // uncleaned environment raises sickness risk 15 points per day — hire a cleaner to prevent this
  hasCleanerVisited = false;

  if (isPetSick && currentSicknessName != null && !currentSicknessName.equals("")) {
    alligator.health -= 20;  // sickness costs 20 HP per day — serious but survivable if treated promptly

    if (currentSicknessName.equals(sicknessNames[2])) {
      sicknessStatusText = alligator.petName + " currently has the flu.";
    } else if (
      currentSicknessName.equals(sicknessNames[6]) ||
      currentSicknessName.equals(sicknessNames[7]) ||
      currentSicknessName.equals(sicknessNames[8]) ||
      currentSicknessName.equals(sicknessNames[11]) ||
      currentSicknessName.equals(sicknessNames[4])
    ) {
      sicknessStatusText = alligator.petName + " has been diagnosed with " + currentSicknessName + ".";
    } else {
      String article = "a";
      char first = currentSicknessName.toLowerCase().charAt(0);
      if (first == 'a' || first == 'e' || first == 'i' || first == 'o' || first == 'u') article = "an";
      sicknessStatusText = alligator.petName + " currently has " + article + " " + currentSicknessName + ".";
    }
  } else {
    sicknessStatusText = alligator.petName + " is not currently sick.";
  }

  // Red-zone health penalty: each stat in the danger range costs 7 extra health per day
  if (alligator.health    <  40)                                        alligator.health -= 7;
  if (alligator.happiness <  40)                                        alligator.health -= 7;
  if (alligator.hunger    >= 90)                                        alligator.health -= 7;
  if (alligator.sickrisk  >= 90)                                        alligator.health -= 7;
  if (alligator.energy    >= 80 || alligator.energy < 20)               alligator.health -= 7;
  alligator.health = clampStat(alligator.health, 0, 100);

  if (!job.equals("unemployed")) {
    salaryInfoText = " You have earned $" + nf(salary, 0, 2) + " (salary).";
    money                 += salary;
    totalJobEarnings      += salary;
    totalMoneyEarned      += salary;
    moneyEarnedFromSalary += salary;
    bankTransactionsLoggedCount++;
    bankTransactionLog.add("Transaction: Salary " + "(+$" + nf(salary, 0, 2) + ")");
  } else {
    salaryInfoText = "";
  }
}


// =========================
// Quit Dialog
// =========================
void quitpopup() {
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);
  rectMode(CENTER);
  strokeWeight(3);
  fill(255, 0, 0);
  rect(width/2, 325, 135, 35);
  textAlign(CENTER, CENTER);
  fill(255);
  text("SAVE & QUIT", width/2, 325);
  rectMode(CORNER);
  noStroke();
}

void quit() {
  saveGame();
  exit();
}


// =========================
// Game Over Screen
// Renders the full-screen game-over overlay when the pet's health reaches 0
// =========================
void gameOverScreen() {
  float cx     = width  / 2.0;
  float panelW = 700;  // panel sized to fit all end-of-game stats without crowding on the 1100×700 canvas
  float panelH = 430;
  float panelTop = height / 2.0 - panelH / 2.0;

  noStroke();
  fill(0, 200);
  rectMode(CORNER);
  rect(0, 0, width, height);

  fill(30, 15, 10);
  stroke(180, 50, 50);
  strokeWeight(4);
  rectMode(CENTER);
  rect(cx, height / 2.0, panelW, panelH, 18);
  noStroke();

  textFont(arcade);
  textAlign(CENTER, CENTER);
  String petName = (alligator != null) ? alligator.petName : "Your alligator";

  float y = panelTop + 60;
  textSize(52);
  fill(200, 50, 50);
  text("GAME OVER", cx, y);

  y += 70;
  textSize(20);
  fill(230, 210, 200);
  text(petName + " has passed away.", cx, y);

  y += 38;
  textSize(15);
  fill(210, 190, 180);
  float innerLeft  = cx - 290;
  float innerRight = cx + 290;
  drawWrappedTextInBox(
    "Without enough food, medicine, or care, " + petName +
    "'s health slowly fell to zero. Alligators need consistent " +
    "nutrition and regular checkups to stay strong. " + petName +
    " lived for " + (day - 1) + " day" + (day - 1 == 1 ? "" : "s") +
    " under your care.",
    innerLeft, y, innerRight, y + 115, 5
  );

  y += 120;
  stroke(180, 50, 50, 120);
  strokeWeight(1);
  line(cx - 300, y, cx + 300, y);
  noStroke();

  y += 28;
  textFont(arcade);
  textSize(13);
  fill(160, 140, 130);
  textAlign(CENTER, CENTER);
  text("Tip: Visit the vet and feed " + petName + " nutritious meat to keep his health up.", cx, y);

  y += 52;
  fill(180, 40, 40);
  stroke(220, 80, 80);
  strokeWeight(2);
  rectMode(CENTER);
  rect(cx, y, 200, 50, 8);
  noStroke();
  textSize(26);
  fill(255);
  textAlign(CENTER, CENTER);
  text("QUIT", cx, y);
  rectMode(CORNER);
}
