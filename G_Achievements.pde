// =========================
// G_Achievements.pde
// Achievement data initialization, progress tracking, sorting, and panel rendering.
// =========================


// =========================
// Achievement State
// =========================
boolean isAchievementsOpen = false;

String[] achievementNames        = new String[30];
String[] achievementDescriptions = new String[30];
int[]    achievementRewards      = new int[30];
float[]  achievementGoals        = new float[30];
float[]  achievementProgress     = new float[30];
int[]    achievementTiers        = new int[30];
boolean[] isAchievementCollectable = new boolean[30];
float[]  achievementDisplayPriority = new float[30];
int[]    achievementDrawOrder    = new int[30];
int[]    achievementType         = new int[30];

float achievementScrollOffset = 0;
float achievementScrollContentHeight = 0;
float achievementViewportX = 320;
float achievementViewportY = 190;
float achievementViewportWidth = 450;
float achievementViewportHeight = 370;
float achievementItemLineHeight = 110; // 110px per row fits the icon, progress bar, title, and collect button without overlapping
float achievementScrollbarX = 770;
float achievementScrollbarY = 190;
float achievementScrollbarWidth = 12;
float achievementScrollbarHeight = 370;
boolean isDraggingAchievementScrollbar = false;
float achievementScrollThumbOffsetY = 0;

// Counters used by achievements
// Note: salaryUpgradeCount, taskUpgradeCount, helpTaskCount live in G_Earn.pde
//       timesRestedSuccessfully, restAttempts, totalEnergyRestoredFromResting live in G_Rest.pde
//       timesUsedVetCare, lowQualityCareCount, highQualityCareCount,
//       cleanersHiredCount, walkersHiredCount, totalHealthRestored,
//       totalHappinessRestored live in G_Services.pde
//       bankTransactionsLoggedCount lives in G_Bank.pde
int timesFedPet = 0;
int timesBoughtMedicine = 0;
int playPointUpgradeCount = 0;
int currentDay = 1;
int inventoryFullCount = 0;
int medicineGivenCount = 0;
int itemsBoughtCount = 0;
int inventoryItemsUsedCount = 0;
float totalMoneyEarned = 0;
float totalMoneySpent = 0;
float highestMoneyBalance = 0;
float moneyEarnedFromMinigames = 0;
float currentPlaySessionMoneyEarned = 0;


// =========================
// Achievement Initialization
// =========================
// Populates all 30 achievement definitions (names, goals, rewards, tier scaling). Called once at game start.
void initAchievements() {
  for (int i = 0; i < 30; i++) {
    achievementTiers[i] = 1;
    isAchievementCollectable[i] = false;
    achievementDrawOrder[i] = i;
  }
  refreshAchievementData();
}

// Syncs live game counters into the achievement progress arrays. Called at the start of each draw cycle so progress bars are always current.
void refreshAchievementData() {
  // 30 achievements across 8 categories (minigames, money, care, upgrades, tasks, store, rest, days)
  setHopAchievement(0, "Swamp Hop High Score", 30, 1);
  setSnackAchievement(1, "Snack Snatch High Score", 25, 1);
  setFetchAchievement(2, "Fetch Frenzy High Score", 15, 1);

  setMoneyEarnedAchievement(3, "Total Money Earned", 250, 2, totalMoneyEarned);
  setMoneySpentAchievement(4, "Total Money Spent", 80, 2, totalMoneySpent);
  setHighestMoneyAchievement(5, "Highest Money Balance", 200, 2, highestMoneyBalance);

  setCountAchievement(6,  "Times Pet Fed",                    "Feed your pet",                  8,  4,  timesFedPet);
  setCountAchievement(7,  "Times Medicine Given",             "Give medicine",                  5,  4,  medicineGivenCount);
  setCountAchievement(8,  "Total Vet Visits",                 "Visit the vet",                  5,  5,  timesUsedVetCare);
  setCountAchievement(9,  "Perfect Rests Completed",          "Complete perfect rests",         5,  4,  timesRestedSuccessfully);
  setCountAchievement(10, "Salary Upgrades Purchased",        "Buy salary upgrades",            2,  4,  salaryUpgradeCount);
  setCountAchievement(11, "Task Income Upgrades Purchased",   "Buy task income upgrades",       2,  5,  taskUpgradeCount);
  setCountAchievement(12, "Play Point Upgrades Purchased",    "Buy play point upgrades",        8,  5,  playPointUpgradeCount);
  setCountAchievement(13, "Help Tasks Completed",             "Complete help tasks",            3,  3,  helpTaskCount);

  setMoneyEarnedAchievement(14, "Money Earned From Salary", 60, 5, moneyEarnedFromSalary);
  setMoneyEarnedAchievement(15, "Money Earned From Tasks",  40, 5, moneyEarnedFromTasks);

  setCountAchievement(16, "Items Purchased From Store",  "Buy store items",       5,  5, itemsBoughtCount);
  setCountAchievement(17, "Medicine Purchased",          "Buy medicine",          4,  5, timesBoughtMedicine);
  setCountAchievement(18, "Inventory Items Used",        "Use inventory items",   5,  5, inventoryItemsUsedCount);

  setMoneyEarnedAchievement(19, "Money Earned From Minigames", 50, 5, moneyEarnedFromMinigames);

  setCountAchievement(20, "Rest Attempts",  "Attempt rests",   3, 3, restAttempts);
  setAmountAchievement(21, "Total Energy Restored From Resting", "Restore energy from resting", 100, 5, totalEnergyRestoredFromResting);
  setAmountAchievement(22, "Total Health Restored",    "Restore health",     35, 5, totalHealthRestored);
  setAmountAchievement(23, "Total Happiness Restored", "Restore happiness",  35, 5, totalHappinessRestored);

  setDayAchievement(24, "Days Survived", 8, 7, currentDay);
  setCountAchievement(25, "Cleaners Hired",           "Hire a cleaner",         2,  7, cleanersHiredCount);
  setCountAchievement(26, "Low Quality Care Purchased",  "Buy low quality care",   4,  5,  lowQualityCareCount);
  setCountAchievement(27, "High Quality Care Purchased", "Buy high quality care",  2,  7, highQualityCareCount);
  setCountAchievement(28, "Bank Transactions Logged",  "Do a transaction (buy or earn)", 20, 10, bankTransactionsLoggedCount);
  setCountAchievement(29, "Walkers Hired", "Hire a walker", 2, 7, walkersHiredCount);

  updateAchievementOrder();
}


// =========================
// Achievement Setters
// =========================
// Each achievement tier scales the goal and reward exponentially so progress stays meaningful across the full game arc
void setHopAchievement(int i, String baseName, float baseGoal, int baseReward) {
  int tier = max(1, achievementTiers[i]);
  achievementTiers[i] = tier;
  achievementType[i] = 0;
  achievementNames[i] = baseName + " - Tier " + tier;
  achievementGoals[i] = max(1, round(baseGoal * pow(1.2f, tier - 1)));   // 20% harder each tier -- keeps each achievement a meaningful challenge without becoming impossible
  achievementRewards[i] = max(1, round(baseReward * pow(1.18f, tier - 1))); // rewards grow slightly slower than goals (18% vs 20%) so upgrades remain the better income strategy
  achievementDescriptions[i] = "Highest score reached in Swamp Hop";
  achievementProgress[i] = swampHopBestScore;
  isAchievementCollectable[i] = achievementProgress[i] >= achievementGoals[i];
}

void setSnackAchievement(int i, String baseName, float baseGoal, int baseReward) {
  int tier = max(1, achievementTiers[i]);
  achievementTiers[i] = tier;
  achievementType[i] = 1;
  achievementNames[i] = baseName + " - Tier " + tier;
  achievementGoals[i] = max(1, round(baseGoal * pow(1.2f, tier - 1)));
  achievementRewards[i] = max(1, round(baseReward * pow(1.18f, tier - 1)));
  achievementDescriptions[i] = "Highest score reached in Snack Snatch";
  achievementProgress[i] = snatchBestScore;
  isAchievementCollectable[i] = achievementProgress[i] >= achievementGoals[i];
}

void setFetchAchievement(int i, String baseName, float baseGoal, int baseReward) {
  int tier = max(1, achievementTiers[i]);
  achievementTiers[i] = tier;
  achievementType[i] = 2;
  achievementNames[i] = baseName + " - Tier " + tier;
  achievementGoals[i] = max(1, round(baseGoal * pow(1.2f, tier - 1)));
  achievementRewards[i] = max(1, round(baseReward * pow(1.18f, tier - 1)));
  achievementDescriptions[i] = "Highest score reached in Fetch Frenzy";
  achievementProgress[i] = fetchBestScore;
  isAchievementCollectable[i] = achievementProgress[i] >= achievementGoals[i];
}

void setMoneyEarnedAchievement(int i, String baseName, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementTiers[i]);
  achievementTiers[i] = tier;
  achievementType[i] = 3;
  achievementNames[i] = baseName + " - Tier " + tier;
  // scaling rate varies by category -- rarer actions (vet visits, upgrades) scale faster since they happen less often
  achievementGoals[i] = max(1, round(baseGoal * pow(1.3f, tier - 1)));
  achievementRewards[i] = max(1, round(baseReward * pow(1.2f, tier - 1)));
  achievementDescriptions[i] = baseName;
  achievementProgress[i] = currentValue;
  isAchievementCollectable[i] = achievementProgress[i] >= achievementGoals[i];
}

void setMoneySpentAchievement(int i, String baseName, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementTiers[i]);
  achievementTiers[i] = tier;
  achievementType[i] = 4;
  achievementNames[i] = baseName + " - Tier " + tier;
  // scaling rate varies by category -- rarer actions (vet visits, upgrades) scale faster since they happen less often
  achievementGoals[i] = max(1, round(baseGoal * pow(1.3f, tier - 1)));
  achievementRewards[i] = max(1, round(baseReward * pow(1.2f, tier - 1)));
  achievementDescriptions[i] = baseName;
  achievementProgress[i] = currentValue;
  isAchievementCollectable[i] = achievementProgress[i] >= achievementGoals[i];
}

void setHighestMoneyAchievement(int i, String baseName, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementTiers[i]);
  achievementTiers[i] = tier;
  achievementType[i] = 5;
  achievementNames[i] = baseName + " - Tier " + tier;
  // scaling rate varies by category -- rarer actions (vet visits, upgrades) scale faster since they happen less often
  achievementGoals[i] = max(1, round(baseGoal * pow(1.25f, tier - 1)));
  achievementRewards[i] = max(1, round(baseReward * pow(1.2f, tier - 1)));
  achievementDescriptions[i] = baseName;
  achievementProgress[i] = currentValue;
  isAchievementCollectable[i] = achievementProgress[i] >= achievementGoals[i];
}

void setCountAchievement(int i, String baseName, String actionText, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementTiers[i]);
  achievementTiers[i] = tier;
  achievementType[i] = 6;
  achievementNames[i] = baseName + " - Tier " + tier;
  // scaling rate varies by category -- rarer actions (vet visits, upgrades) scale faster since they happen less often
  achievementGoals[i] = max(1, round(baseGoal * pow(1.5f, tier - 1)));
  achievementRewards[i] = max(1, round(baseReward * pow(1.18f, tier - 1)));
  if (PApplet.parseInt(achievementGoals[i]) == 1)
    achievementDescriptions[i] = actionText + " 1 time";
  else
    achievementDescriptions[i] = actionText + " " + PApplet.parseInt(achievementGoals[i]) + " times";
  achievementProgress[i] = currentValue;
  isAchievementCollectable[i] = achievementProgress[i] >= achievementGoals[i];
}

void setAmountAchievement(int i, String baseName, String actionText, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementTiers[i]);
  achievementTiers[i] = tier;
  achievementType[i] = 7;
  achievementNames[i] = baseName + " - Tier " + tier;
  // scaling rate varies by category -- rarer actions (vet visits, upgrades) scale faster since they happen less often
  achievementGoals[i] = max(1, round(baseGoal * pow(1.35f, tier - 1)));
  achievementRewards[i] = max(1, round(baseReward * pow(1.18f, tier - 1)));
  achievementDescriptions[i] = actionText + " by " + PApplet.parseInt(achievementGoals[i]) + " total points";
  achievementProgress[i] = currentValue;
  isAchievementCollectable[i] = achievementProgress[i] >= achievementGoals[i];
}

void setDayAchievement(int i, String baseName, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementTiers[i]);
  achievementTiers[i] = tier;
  achievementType[i] = 8;
  achievementNames[i] = baseName + " - Tier " + tier;
  // scaling rate varies by category -- rarer actions (vet visits, upgrades) scale faster since they happen less often
  achievementGoals[i] = max(1, round(baseGoal * pow(1.4f, tier - 1)));
  achievementRewards[i] = max(1, round(baseReward * pow(1.2f, tier - 1)));
  achievementDescriptions[i] = "Reach day " + PApplet.parseInt(achievementGoals[i]);
  achievementProgress[i] = currentValue;
  isAchievementCollectable[i] = achievementProgress[i] >= achievementGoals[i];
}


// =========================
// Achievement Order / Progress Update
// =========================
void updateAchievementProgress() {
  refreshAchievementData();
}

void updateAchievementOrder() {
  for (int i = 0; i < 30; i++) {
    float ratio = (achievementGoals[i] > 0) ? achievementProgress[i] / achievementGoals[i] : 0;
    ratio = constrain(ratio, 0, 1);
    achievementDisplayPriority[i] = ratio;
    if (isAchievementCollectable[i]) achievementDisplayPriority[i] += 1000;
    achievementDrawOrder[i] = i;
  }
  for (int a = 0; a < 29; a++) {
    for (int b = a + 1; b < 30; b++) {
      int ia = achievementDrawOrder[a];
      int ib = achievementDrawOrder[b];
      if (achievementDisplayPriority[ib] > achievementDisplayPriority[ia]) {
        int temp = achievementDrawOrder[a];
        achievementDrawOrder[a] = achievementDrawOrder[b];
        achievementDrawOrder[b] = temp;
      }
    }
  }
}


// =========================
// Achievements Panel
// =========================
// Renders the scrollable achievement panel with progress bars and collect buttons.
void achievements() {
  updateAchievementProgress();

  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(310, 122.5f, 790, 572.5f);
  line(310, 182, 790, 182);

  textAlign(CENTER);
  fill(255);
  textSize(35);
  text("ACHIEVEMENTS:", width/2, height*0.235f);

  achievementScrollContentHeight = 20 + 30 * achievementItemLineHeight;
  float maxScroll = max(0, achievementScrollContentHeight - achievementViewportHeight);
  achievementScrollOffset = constrain(achievementScrollOffset, 0, maxScroll);

  pushMatrix();
  clip((int)achievementViewportX, (int)achievementViewportY, (int)achievementViewportWidth, (int)achievementViewportHeight);

  rectMode(CORNER);
  textAlign(LEFT, TOP);

  for (int row = 0; row < 30; row++) {
    int i = achievementDrawOrder[row];
    float y = achievementViewportY + 20 + row * achievementItemLineHeight - achievementScrollOffset;
    float boxX = achievementViewportX + 10;
    float boxW = achievementViewportWidth - 30;
    float boxH = 96;

    float progressRatio = (achievementGoals[i] > 0) ? achievementProgress[i] / achievementGoals[i] : 0;
    progressRatio = constrain(progressRatio, 0, 1);

    fill(120, 180);
    stroke(220);
    strokeWeight(2);
    rect(boxX, y, boxW, boxH, 8);

    fill(255);
    textAlign(LEFT, TOP);
    textSize(16);
    text(achievementNames[i], boxX + 12, y + 7);

    textAlign(RIGHT, TOP);
    textSize(15);
    fill(255, 230, 120);
    text("+$" + achievementRewards[i], boxX + boxW - 12, y + 8);

    textAlign(LEFT, TOP);
    textSize(11);
    fill(215);
    text(achievementDescriptions[i], boxX + 12, y + 28, boxW - 24, 24);

    float barX = boxX + 12;
    float barY = y + 58;
    float barW = boxW - 116;
    float barH = 12;

    fill(55, 160);
    stroke(180);
    strokeWeight(1.5f);
    rect(barX, barY, barW, barH, 4);

    noStroke();
    fill(100, 220, 140);
    rect(barX, barY, barW * progressRatio, barH, 4);

    fill(235);
    textSize(10);
    textAlign(RIGHT, CENTER);
    text(PApplet.parseInt(min(achievementProgress[i], achievementGoals[i])) + "/" + PApplet.parseInt(achievementGoals[i]),
         boxX + boxW - 12, barY + 6);

    rectMode(CENTER);
    stroke(169);
    strokeWeight(2);
    if (isAchievementCollectable[i]) fill(0, 255, 0, 80);
    else fill(80, 220);
    rect(boxX + boxW - 52, y + 38, 80, 20);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(12);
    text("COLLECT", boxX + boxW - 52, y + 38);
    rectMode(CORNER);
  }

  noClip();
  popMatrix();

  noFill();
  stroke(200);
  strokeWeight(2);
  rectMode(CORNER);
  rect(achievementViewportX, achievementViewportY, achievementViewportWidth, achievementViewportHeight);

  fill(120);
  stroke(80);
  rect(achievementScrollbarX, achievementScrollbarY, achievementScrollbarWidth, achievementScrollbarHeight);

  if (achievementScrollContentHeight > achievementViewportHeight) {
    float thumbH = max(40, (achievementViewportHeight / achievementScrollContentHeight) * achievementScrollbarHeight);
    float thumbY = map(achievementScrollOffset, 0, maxScroll, achievementScrollbarY, achievementScrollbarY + achievementScrollbarHeight - thumbH);
    fill(220);
    stroke(100);
    rect(achievementScrollbarX, thumbY, achievementScrollbarWidth, thumbH);
  } else {
    fill(220);
    stroke(100);
    rect(achievementScrollbarX, achievementScrollbarY, achievementScrollbarWidth, achievementScrollbarHeight);
  }

  noFill();
  stroke(169);
  rectMode(CORNERS);
  rect(733, 132, 776, 171.5f);
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X", 742, 151.75f);

  strokeWeight(2);
  stroke(0);
  rectMode(CORNER);
}
