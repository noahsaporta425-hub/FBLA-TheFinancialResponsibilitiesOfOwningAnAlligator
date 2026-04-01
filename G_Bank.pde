// =========================
// G_Bank.pde
// Bank panel rendering, transaction log display, and financial advice.
// =========================


// =========================
// Bank State
// =========================
boolean isBankOpen = false;

ArrayList<String> bankTransactionLog = new ArrayList<String>();
int bankTransactionsLoggedCount = 0;

// Filter state: "all" shows every entry, "earn" shows +$ only, "spend" shows -$ only
String bankFilter = "all";
// Filtered view rebuilt each frame in bank(); shared with B_Interaction scroll logic
ArrayList<String> filteredBankLog = new ArrayList<String>();

float bankScrollOffset = 0;
float bankScrollContentHeight = 0;
float bankViewportX = 320;
float bankViewportY = 190;
float bankViewportWidth = 450;
float bankViewportHeight = 370;
float bankItemLineHeight = 30; // 30px per transaction row is compact enough to show many entries without a tiny font
float bankScrollbarX = 770;
float bankScrollbarY = 190;
float bankScrollbarWidth = 12;
float bankScrollbarHeight = 370;
boolean isDraggingBankScrollbar = false;
float bankScrollThumbOffsetY = 0;


// =========================
// Bank Panel
// Renders the bank panel: scrollable transaction log on the left, and contextual financial advice on the right based on current game state.
// =========================
void bank() {
  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(310, 122.5f, 790, 572.5f);
  line(310, 182, 790, 182);

  textAlign(CENTER);
  fill(255);
  textSize(35);
  text("BANK:", width/2, height*0.235f);

  // --- Build Filtered Transaction List ---
  // Rebuilt every frame so the summary and scroll stay in sync with the current filter.
  filteredBankLog.clear();
  for (String t : bankTransactionLog) {
    if (bankFilter.equals("all") ||
        (bankFilter.equals("earn")  && t.contains("+$")) ||
        (bankFilter.equals("spend") && t.contains("-$"))) {
      filteredBankLog.add(t);
    }
  }

  // --- Scroll Calculation ---
  // Base height (230) accounts for advice header + separator + filter buttons + summary line; rest scales with row count.
  bankScrollContentHeight = 230 + filteredBankLog.size() * bankItemLineHeight;
  float maxScroll = max(0, bankScrollContentHeight - bankViewportHeight);
  bankScrollOffset = constrain(bankScrollOffset, 0, maxScroll);

  pushMatrix();
  clip((int)bankViewportX, (int)bankViewportY, (int)bankViewportWidth, (int)bankViewportHeight);

  fill(255);
  textAlign(CENTER, TOP);
  textSize(25);
  text("Advice:", bankViewportX + bankViewportWidth/2, bankViewportY + 10 - bankScrollOffset);

  line(bankViewportX, bankViewportY + 92 - bankScrollOffset, bankViewportX + bankViewportWidth, bankViewportY + 92 - bankScrollOffset);

  // --- Filter Buttons (inside scrollable viewport, below advice separator) ---
  // Divides the viewport width into three equal tabs. Active tab is highlighted green.
  String[] filterLabels = {"All", "Earnings", "Spending"};
  String[] filterValues = {"all", "earn", "spend"};
  float bw = (bankViewportWidth - 12) / 3.0f;  // width of each button
  float filterBtnY1 = bankViewportY + 98  - bankScrollOffset;
  float filterBtnY2 = bankViewportY + 127 - bankScrollOffset;
  for (int i = 0; i < 3; i++) {
    float bx1 = bankViewportX + 4 + i * (bw + 2);
    float bx2 = bx1 + bw;
    boolean active = bankFilter.equals(filterValues[i]);
    fill(active ? color(50, 150, 75) : color(20, 60, 35));
    stroke(169);
    strokeWeight(2);
    rectMode(CORNERS);
    rect(bx1, filterBtnY1, bx2, filterBtnY2);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(13);
    text(filterLabels[i], (bx1 + bx2) / 2, (filterBtnY1 + filterBtnY2) / 2);
  }

  textSize(13.75f); // 13.75px is the largest size that fits the full transaction log line without truncation in the panel width
  fill(255);
  // advice panel shows the most relevant tip based on current state; conditions checked in priority order (problems first, encouragement last)
  if (hasNeverBoughtHighQualityCare) {
    drawWrappedTextInBox(
      "You've only used low-quality care. It's cheaper but riskier -- the vet may prescribe the wrong medicine.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (!hasCleanerVisited) {
    drawWrappedTextInBox(
      "Hire a cleaner daily to prevent " + alligator.petName + "'s sickness risk from rising.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (timesFedPet < 5) {
    drawWrappedTextInBox(
      "Feed " + alligator.petName + " regularly to keep hunger down and energy up.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (timesRestedSuccessfully < 3) {
    drawWrappedTextInBox(
      "Rest restores energy -- aim for the green zone each time.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (helpTaskCount < 3) {
    drawWrappedTextInBox(
      "Town tasks earn money, but " + alligator.petName + " may suffer while you're away.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (money < 15) {
    drawWrappedTextInBox(
      "Money is low. Work, run tasks, or play minigames to earn more.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (alligator.sickrisk >= 60) {
    drawWrappedTextInBox(
      alligator.petName + "'s sickness risk is high. Clean regularly to prevent illness.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (alligator.health <= 40) {
    drawWrappedTextInBox(
      alligator.petName + "'s health is low -- focus on recovery now.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (alligator.hunger >= 50) {
    drawWrappedTextInBox(
      alligator.petName + " is hungry. Stock up on food.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else {
    drawWrappedTextInBox(
      "Balance money and care to keep " + alligator.petName + " healthy and alive.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  }

  // --- Transaction Summary Line ---
  // Parses dollar amounts from the filtered list to compute a running total.
  // Format of every entry ends with (+$X.XX) or (-$X.XX), so lastIndexOf(")") is always reliable.
  float total = 0;
  for (String t : filteredBankLog) {
    int plusIdx  = t.indexOf("+$");
    int minusIdx = t.indexOf("-$");
    int closeIdx = t.lastIndexOf(")");
    if (plusIdx >= 0 && closeIdx > plusIdx + 1) {
      total += float(t.substring(plusIdx + 2, closeIdx));
    } else if (minusIdx >= 0 && closeIdx > minusIdx + 1) {
      total -= float(t.substring(minusIdx + 2, closeIdx));
    }
  }
  String summaryText;
  if (bankFilter.equals("earn")) {
    summaryText = filteredBankLog.size() + " of " + bankTransactionLog.size() + " | Earned: +$" + nf(total, 0, 2);
  } else if (bankFilter.equals("spend")) {
    summaryText = filteredBankLog.size() + " of " + bankTransactionLog.size() + " | Spent: -$" + nf(abs(total), 0, 2);
  } else {
    summaryText = filteredBankLog.size() + " transactions | Net: " + (total >= 0 ? "+$" : "-$") + nf(abs(total), 0, 2);
  }
  fill(190);
  textAlign(LEFT, TOP);
  textSize(11.5f);
  text(summaryText, bankViewportX + 10, bankViewportY + 132 - bankScrollOffset);

  // --- Transaction List ---
  textAlign(LEFT, TOP);
  textSize(20);
  for (int i = 0; i < filteredBankLog.size(); i++) {
    float y = bankViewportY + 150 + i * bankItemLineHeight - bankScrollOffset;
    text(filteredBankLog.get(i), bankViewportX + 10, y);
  }

  noClip();
  popMatrix();

  noFill();
  stroke(200);
  strokeWeight(2);
  rectMode(CORNER);
  rect(bankViewportX, bankViewportY, bankViewportWidth, bankViewportHeight);

  fill(120);
  stroke(80);
  rect(bankScrollbarX, bankScrollbarY, bankScrollbarWidth, bankScrollbarHeight);

  if (bankScrollContentHeight > bankViewportHeight) {
    float thumbH = max(40, (bankViewportHeight / bankScrollContentHeight) * bankScrollbarHeight);
    float thumbY = map(bankScrollOffset, 0, maxScroll, bankScrollbarY, bankScrollbarY + bankScrollbarHeight - thumbH);
    fill(220);
    stroke(100);
    rect(bankScrollbarX, thumbY, bankScrollbarWidth, thumbH);
  } else {
    fill(220);
    stroke(100);
    rect(bankScrollbarX, bankScrollbarY, bankScrollbarWidth, bankScrollbarHeight);
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
