// =========================
// G_Earn.pde
// Earn panel: job display, Job Finder, Tasks & Upgrades, job/help popups.
// =========================


// =========================
// Earn / Job State
// =========================
String job = "unemployed";
float salary = 0;
float totalJobEarnings = 0;
float taskRewardAmount = 5;
float pointUpgradeCost = 3;
float salaryUpgradeCost = 3;
float taskUpgradeCost = 3;
boolean hasCashierMaxedSalary = false;

boolean isEarnPanelOpen = false;
boolean hasOpenedEarnPanel = false;
boolean isShowingEarnPopup = false;
boolean hasShownEarnPopup = false;
int earnPopupDelayTimer = 0;

boolean isJobFinderOpen = false;
boolean isTasksPanelOpen = false;
boolean hasShownJobPopup = false;
boolean isShowingJobPopup = false;
boolean isHelpTaskPending = false;
boolean hasUsedHelpTask = false;
boolean hasClickedTaskTab = false;
boolean hasShownFirstHelpPopup = false;
boolean isShowingFirstHelpPopup = false;
String helpPopupMessage = "";

float moneyEarnedFromSalary = 0;
float moneyEarnedFromTasks = 0;
int salaryUpgradeCount = 0;
int taskUpgradeCount = 0;
int helpTaskCount = 0;

PImage unemployed, cashier, barista, manager;
PImage town, cash, house, lock;


// =========================
// Earn Popup
// =========================
void earnpopup() {
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);
  fill(0);
  textFont(times50);
  textSize(20);
  drawWrappedTextInBox("Nice job stabilizing " + alligator.petName + "'s energy. As an owner, playing can get annoying, so you can use services to help with their needs! But services cost money. Click the earn button after closing this window!", 338, 271, 761, 400, 6);
}

void jobpopup() {
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);
  fill(0);
  textFont(times50);
  textSize(20);
  drawWrappedTextInBox("Congrats on becoming a cashier! You now earn a daily salary. In this tab you can upgrade it, earn money when " + alligator.petName + " plays, or help around town for extra cash. Close this window and try helping out!", 338, 271, 761, 400, 6);
}

void help() {
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);
  fill(0);
  textFont(times50);
  textSize(20);
  drawWrappedTextInBox(helpPopupMessage, 338, 271, 761, 400, 6);
}


// =========================
// Earn Panel (main view)
// Routes to the correct earn sub-panel (Jobs, Tasks, or Upgrades) based on the active tab.
// =========================
void earn() {
  if (isJobFinderOpen) {
    earnJobFinder();
    return;
  }
  if (isTasksPanelOpen) {
    earnTasksUpgrades();
    return;
  }

  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(110, 122.5f, 990, 572.5f);

  if (!job.equals("unemployed")) fill(255, 0, 0, 65);

  rectMode(CENTER);
  rect(816, 206, 100, 100);

  textAlign(CENTER);
  fill(255);
  line(110, 275, 990, 275);

  textSize(40);
  text("QUIT", 816, 200);
  text("JOB", 816, 240);

  textSize(25);
  text("CURRENT JOB:", width/2, 164.5f);

  imageMode(CENTER);

  if (job.equals("unemployed")) {
    image(unemployed, 466, 230, unemployed.width/7, unemployed.height/7);
    textSize(25);
    text("Unemployed", 580, 193);
    textAlign(CORNER);
    text("Job Info:", 129, 165);
    textSize(15);
    text("Current Salary: $0/day", 129, 187);
    text("Next Paycheck: N/A", 129, 209);
    text("Total Job Earnings: N/A", 129, 231);
    if (day >= 25)      text("Next Job: Manager is available!", 129, 253);
    else if (day >= 10) text("Next Job: Barista is available!", 129, 253);
    else                text("Next Job: Cashier is available!", 129, 253);
    textAlign(CENTER);
    text("There's not much to", 580, 223);
    text("this job's description.", 580, 238);
    text("Get a job below.", 580, 253);

  } else if (job.equals("cashier")) {
    image(cashier, 466, 230, unemployed.width/7, unemployed.height/7);
    textSize(25);
    text("Cashier", 580, 193);
    textAlign(CORNER);
    text("Job Info:", 129, 165);
    textSize(15);
    text("Current Salary: $" + nf(salary, 0, 2) + "/day", 129, 187);
    text("Next Paycheck: Day " + (day+1), 129, 209);
    text("Total Job Earnings: $" + nf(totalJobEarnings, 0, 2), 129, 231);
    if (day < 10)      text("Next Job: Barista on Day 10", 129, 253);
    else if (day < 25) text("Next Job: Barista is available!", 129, 253);
    else               text("Next Job: Cafe Manager is available!", 129, 253);
    textAlign(CENTER);
    text("Work the", 580, 223);
    text("register for", 580, 238);
    text(alligator.petName + "!", 580, 253);

  } else if (job.equals("barista")) {
    image(barista, 466, 230, barista.width/3, barista.height/3);
    textSize(25);
    text("Barista", 580, 193);
    textAlign(CORNER);
    text("Job Info:", 129, 165);
    textSize(15);
    text("Current Salary: $" + nf(salary, 0, 2) + "/day", 129, 187);
    text("Next Paycheck: Day " + (day+1), 129, 209);
    text("Total Job Earnings: $" + nf(totalJobEarnings, 0, 2), 129, 231);
    if (day < 25) text("Next Job: Cafe Manager on Day 25", 129, 253);
    else          text("Next Job: Cafe Manager is available!", 129, 253);
    textAlign(CENTER);
    text("Make coffee", 580, 223);
    text("and earn $ for", 580, 238);
    text(alligator.petName + "!", 580, 253);

  } else {
    image(manager, 466, 230, barista.width/3, barista.height/3);
    textSize(25);
    text("Cafe Manager", 580, 193);
    textAlign(CORNER);
    text("Job Info:", 129, 165);
    textSize(15);
    text("Current Salary: $" + nf(salary, 0, 2) + "/day", 129, 187);
    text("Next Paycheck: Day " + (day+1), 129, 209);
    text("Total Job Earnings: $" + nf(totalJobEarnings, 0, 2), 129, 231);
    text("Next Job: N/A", 129, 253);
    textAlign(CENTER);
    text("Make coffee", 580, 223);
    text("and earn $ for", 580, 238);
    text(alligator.petName + "!", 580, 253);
  }

  textAlign(CENTER, CENTER);
  textSize(28);
  text("Choose a section:", width/2, 345);

  stroke(255);
  strokeWeight(2);
  fill(80, 220);
  rect(330, 455, 250, 90);
  rect(770, 455, 320, 90);

  fill(255);
  textSize(26);
  text("JOB FINDER", 330, 448);
  text("TASKS & UPGRADES", 770, 448);

  textSize(14);
  text("Apply for jobs and view unlocks", 330, 482);
  text("Help around town and buy upgrades", 770, 482);

  noFill();
  rectMode(CORNERS);
  stroke(169);
  rect(933, 132, 976, 171.5f);
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X", 942, 151.75f);

  rectMode(CORNER);
  stroke(0);
}


// =========================
// Job Finder Sub-Panel
// Renders the job listings panel where the player can hire or quit jobs by day milestone.
// =========================
void earnJobFinder() {
  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(180, 145, 920, 518);
  line(180, 205, 920, 205);

  textAlign(CENTER, CENTER);
  fill(255);
  textSize(35);
  text("JOB FINDER:", 550, 175);

  noFill();
  rect(863, 155, 906, 194.5f);
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X", 872, 174.75f);

  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(22);
  text("Jobs:", 550, 235);

  image(cashier, 300, 287, cashier.width/4, cashier.height/4);
  image(barista, 550, 287, barista.width/4, barista.height/4);
  image(manager, 800, 287, manager.width/4, manager.height/4);

  textSize(17.5f);
  text("Cashier", 300, 330);
  text("Barista", 550, 330);
  text("Cafe Manager", 800, 330);

  textSize(12);
  text("Work the register", 300, 347);
  text("and help customers", 300, 360);
  text("check out.", 300, 373);
  text("Base Salary:", 300, 397);
  text("$15/day", 300, 410);
  text("Status:", 300, 434);
  text("Unlocked", 300, 447);

  text("Prepare coffee", 550, 347);
  text("and drinks for", 550, 360);
  text("cafe customers.", 550, 373);
  text("Base Salary:", 550, 397);
  text("$35/day", 550, 410);
  text("Status:", 550, 434);
  text("Unlocks on day 10", 550, 447); // Barista unlocks Day 10 and Cafe Manager Day 25 — paced so the player must plan their income growth

  text("Run the cafe,", 800, 347);
  text("manage staff,", 800, 360);
  text("ensure efficiency.", 800, 373);
  text("Base Salary:", 800, 397);
  text("$75/day", 800, 410); // salaries roughly triple each tier: Cashier $15 → Barista $35 → Manager $75; balanced against store and service costs
  text("Status:", 800, 434);
  text("Unlocks on day 25", 800, 447);

  rectMode(CENTER);
  stroke(255);
  strokeWeight(2);
  textSize(17);

  if (job.equals("unemployed")) fill(0, 255, 0, 80);
  else fill(80, 220);
  rect(300, 487, 80, 20);
  fill(255);
  text("APPLY", 300, 487);

  if (job.equals("unemployed") && day >= 10) fill(0, 255, 0, 80);
  else {
    fill(80, 220);
    if (day < 10) image(lock, 550, 287, lock.width/12, lock.height/12);
  }
  rect(550, 487, 80, 20);
  fill(255);
  text("APPLY", 550, 487);

  if (job.equals("unemployed") && day >= 25) fill(0, 255, 0, 80);
  else {
    fill(80, 220);
    if (day < 25) image(lock, 800, 287, lock.width/12, lock.height/12);
  }
  rect(800, 487, 80, 20);
  fill(255);
  text("APPLY", 800, 487);

  if (job.equals("unemployed")) redarrow(216, 482, "right");

  rectMode(CORNER);
  stroke(0);
}


// =========================
// Tasks & Upgrades Sub-Panel
// Renders the tasks and upgrades panel showing one-time tasks and purchasable multiplier upgrades.
// =========================
void earnTasksUpgrades() {
  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(210, 145, 890, 470);
  line(210, 205, 890, 205);
  line(550, 205, 550, 470);

  textAlign(CENTER, CENTER);
  fill(255);
  textSize(35);
  text("TASKS & UPGRADES:", 550, 175);

  noFill();
  rect(833, 155, 876, 194.5f);
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X", 842, 174.75f);

  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(25);
  text("Help Around Town:", 380, 240);
  text("Upgrades:", 720, 240);

  image(town, 380, 320, town.width/6, town.height/6);

  textSize(12);
  text("Run community errands for", 380, 362);
  text("quick cash with the risk", 380, 375);
  text("of your alligator's stats", 380, 388);
  text("changing due to your absence.", 380, 401);

  rectMode(CENTER);
  fill(255, 127, 0);
  stroke(255);
  strokeWeight(2);
  rect(380, 430, 80, 20);
  fill(255);
  textSize(17);
  text("HELP", 380, 430);

  pushMatrix();
  translate(485, 277);
  rotate(HALF_PI);
  image(topalligator1, 0, -topalligator1.width/12, topalligator1.width/12, topalligator1.height/12);
  popMatrix();

  image(cash, 720, 277, cash.width/13, cash.height/13);
  image(house, 825, 272, house.width/17, house.height/17);

  textSize(14);
  text("$ per Point", 615, 307);
  text("Salary", 720, 307);
  text("$ Per Town Task", 825, 307);

  textSize(10);
  text("Current:", 615, 320);
  text("Current:", 720, 320);
  text("Current:", 825, 320);
  text("$" + nf(moneyPerMinigamePoint, 0, 2) + "/pt", 615, 333);
  text("$" + nf(salary, 0, 2) + "/day", 720, 333);
  text("$" + nf(taskRewardAmount, 0, 2) + "/task", 825, 333);

  text("Upgrade:", 615, 359);
  if (moneyPerMinigamePoint == 0) text("$0.10/pt", 615, 372);
  else text("$" + nf(moneyPerMinigamePoint*1.2f, 0, 2) + "/pt", 615, 372); // tasks scale at 12% (same as salary) while minigame point value scales at 20% — play rewards grow faster to encourage engagement

  text("Upgrade:", 720, 359);
  if (job.equals("cashier")) {
    if (salary >= 32 || salary * 1.12f >= 32) text("MAXED", 720, 372);
    else text("$" + nf(salary * 1.12f, 0, 2) + "/day", 720, 372); // 12% salary increase per upgrade — meaningful but not game-breaking; encourages regular reinvestment
  } else if (job.equals("barista")) {
    if (salary >= 70 || salary * 1.12f >= 70) text("MAXED", 720, 372);
    else text("$" + nf(salary * 1.12f, 0, 2) + "/day", 720, 372);
  } else {
    text("$" + nf(salary * 1.12f, 0, 2) + "/day", 720, 372);
  }

  text("BUY:", 615, 402);
  text("BUY:", 720, 402);
  text("BUY:", 825, 402);

  text("Upgrade:", 825, 359);
  text("$" + nf(taskRewardAmount*1.12f, 0, 2) + "/task", 825, 372); // task reward grows 12% per upgrade, same rate as salary upgrades

  textSize(13);
  if (money >= pointUpgradeCost) fill(0, 255, 0, 80);
  else fill(80, 220);
  rect(615, 420, 80, 20);
  fill(255);
  text("$" + nf(pointUpgradeCost, 0, 2), 615, 420);

  if (!job.equals("unemployed") && money >= salaryUpgradeCost &&
      !(job.equals("cashier") && (salary >= 32 || salary * 1.12f >= 32)) &&
      !(job.equals("barista") && (salary >= 70 || salary * 1.12f >= 70))) {
    fill(0, 255, 0, 80);
  } else {
    fill(80, 220);
  }
  rect(720, 420, 80, 20);
  fill(255);
  if (job.equals("cashier") && (salary >= 32 || salary * 1.12f >= 32)) text("MAXED", 720, 420);
  else if (job.equals("barista") && (salary >= 70 || salary * 1.12f >= 70)) text("MAXED", 720, 420);
  else if (job.equals("unemployed")) text("N/A", 720, 420);
  else text("$" + nf(salaryUpgradeCost, 0, 2), 720, 420); // upgrade cost grows 40% each time, faster than the salary gain, so the benefit diminishes over time

  if (money >= taskUpgradeCost) fill(0, 255, 0, 80);
  else fill(80, 220);
  rect(825, 420, 80, 20);
  fill(255);
  text("$" + nf(taskUpgradeCost, 0, 2), 825, 420);

  if (hasShownJobPopup && !isHelpTaskPending && isTasksPanelOpen && !hasUsedHelpTask) {
    redarrow(261, 429, "right");
  }

  rectMode(CORNER);
  stroke(0);
}
