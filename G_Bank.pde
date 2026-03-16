// =========================
// G_Bank.pde
// Bank panel rendering, transaction log display, and financial advice.
// =========================


// =========================
// Bank State
// =========================
boolean isBankOpen = false;
boolean hasViewedBank = false;
boolean hasShownBankPopup = false;
boolean isShowingBankPopup = false;
boolean hasViewedBankFirstTime = false;

ArrayList<String> bankTransactionLog = new ArrayList<String>();
int bankTransactionsLoggedCount = 0;

float bankScrollOffset = 0;
float bankScrollContentHeight = 0;
float bankViewportX = 320;
float bankViewportY = 190;
float bankViewportWidth = 450;
float bankViewportHeight = 370;
float bankItemLineHeight = 30;
float bankScrollbarX = 770;
float bankScrollbarY = 190;
float bankScrollbarWidth = 12;
float bankScrollbarHeight = 370;
boolean isDraggingBankScrollbar = false;
float bankScrollThumbOffsetY = 0;


// =========================
// Bank Popup
// =========================
void bankpopup() {
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);
  fill(0);
  textFont(times50);
  textSize(20);
  drawWrappedTextInBox("Don't forget to give " + alligator.petName + " another dose tomorrow (see prescription description). Click Bank after closing this window to view your transactions and get personalized financial advice.", 338, 271, 761, 400, 6);
}


// =========================
// Bank Panel
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

  bankScrollContentHeight = 170 + bankTransactionLog.size() * bankItemLineHeight;
  float maxScroll = max(0, bankScrollContentHeight - bankViewportHeight);
  bankScrollOffset = constrain(bankScrollOffset, 0, maxScroll);

  pushMatrix();
  clip((int)bankViewportX, (int)bankViewportY, (int)bankViewportWidth, (int)bankViewportHeight);

  fill(255);
  textAlign(CENTER, TOP);
  textSize(25);
  text("Advice:", bankViewportX + bankViewportWidth/2, bankViewportY + 10 - bankScrollOffset);

  line(bankViewportX, bankViewportY + 92 - bankScrollOffset, bankViewportX + bankViewportWidth, bankViewportY + 92 - bankScrollOffset);

  textSize(13.75f);
  fill(255);
  if (hasNeverBoughtHighQualityCare) {
    drawWrappedTextInBox(
      "You have only purchased low quality care. While it's cheaper, the vet can prescribe an incorrect medication or refuse to help even after you pay.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (!hasCleanerVisited) {
    drawWrappedTextInBox(
      "Hiring a cleaner daily will ensure that " + alligator.petName + "'s risk of sickness won't increase daily.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (timesFedPet < 5) {
    drawWrappedTextInBox(
      "Keep an eye on hunger and energy. Feeding " + alligator.petName + " regularly will help keep hunger from getting to high and energy from getting too low.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (timesRestedSuccessfully < 3) {
    drawWrappedTextInBox(
      "Resting is a good way to restore energy, but make sure these rests are successful and the line lands in the COLOR_GREEN zone.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (helpTaskCount < 3) {
    drawWrappedTextInBox(
      "Helping around town is a good way to earn money, but leaving " + alligator.petName + " alone can have consequences.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (money < 15) {
    drawWrappedTextInBox(
      "Your money is getting low. Consider working, helping around town, or playing minigames to earn more.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (alligator.sickrisk >= 60) {
    drawWrappedTextInBox(
      alligator.petName + "'s sickness risk is pretty high. Cleaning and careful care can help prevent future problems.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (alligator.health <= 40) {
    drawWrappedTextInBox(
      alligator.petName + "'s health is getting low. You should focus on recovery before it becomes dangerous.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else if (alligator.hunger >= 50) {
    drawWrappedTextInBox(
      alligator.petName + " is getting hungry. Make sure to keep food stocked in your inventory.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  } else {
    drawWrappedTextInBox(
      "Keep balancing money and care to keep " + alligator.petName + " healthy, happy, and alive.",
      bankViewportX + 10, bankViewportY + 38 - bankScrollOffset,
      bankViewportX + bankViewportWidth - 10, bankViewportY + 86 - bankScrollOffset, 2);
  }

  textAlign(LEFT, TOP);
  textSize(20);
  for (int i = 0; i < bankTransactionLog.size(); i++) {
    float y = bankViewportY + 110 + i * bankItemLineHeight - bankScrollOffset;
    text(bankTransactionLog.get(i), bankViewportX + 10, y);
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
