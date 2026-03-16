// =========================
// G_Services.pde
// Services panel: vet, walker, cleaner, treatment popups, and prescription logic.
// =========================


// =========================
// Services State
// =========================
boolean isServicesOpen = false;
boolean hasOpenedServices = false;
boolean isVetOpen = false;
boolean isShowingTreatmentPopup = false;
boolean hasShownTreatmentPopup = false;
boolean isShowingVetFailedPopup = false;
boolean hasUsedLowQualityVet = false;
boolean isFirstLowQualityVetAttempt = true;
boolean hasNeverBoughtHighQualityCare = true;
boolean hasCleanerVisited = false;

String vetTreatmentMessage = "";
String currentSicknessName = "";
boolean isPetSick = false;

int prescribedMedicineIndex = -1;
int prescriptionDaysRequired = 0;
int prescriptionDaysCompleted = 0;
int lastDoseTakenDay = -1;

String[] sicknessNames = {
  "infection", "cold", "flu", "vitamin deficiency", "malnutrition",
  "electrolyte deficiency", "severe fatigue", "depression", "anxiety",
  "injury", "calcium deficiency", "food poisoning"
};

int timesUsedVetCare = 0;
int lowQualityCareCount = 0;
int highQualityCareCount = 0;
int cleanersHiredCount = 0;
int walkersHiredCount = 0;
float totalHealthRestored = 0;
float totalHappinessRestored = 0;

PImage vet, walker, cleaner;


// =========================
// Services Panel
// =========================
void services() {
  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(110, 122.5f, 990, 572.5f);
  textAlign(CENTER, CENTER);
  fill(255);
  textSize(35);
  text("SERVICES:", width/2, height*0.235f);
  textSize(25);
  imageMode(CENTER);
  text("Vet:", 256.67f, 200);
  text("Walker:", 550, 200);
  text("Cleaner:", 843.33f, 200);

  rectMode(CENTER);
  fill(0, 255, 0, 80);
  rect(256.67f, 520, 160, 40);
  if (money < 10) fill(169, 80);
  rect(550, 520, 160, 40);
  rect(843.33f, 520, 160, 40);
  fill(255);
  text("VISIT", 256.7f, 520);
  text("HIRE - $10", 550, 520);
  text("HIRE - $10", 843.33f, 520);
  image(vet, 250, 330, vet.width/1.55f, vet.height/1.55f);
  textSize(15);
  text("A veterinarian can prescribe", 256.7f, 418);
  text("your pet medicine and/or", 256.7f, 433);
  text("give advice to you on", 256.7f, 448);
  text("pet care, getting rid of", 256.7f, 463);
  text("injury, sickness, or infection", 256.7f, 478);

  image(walker, 530, 330, walker.width/3.5f, walker.height/3.5f);
  text("A walker will take", 604, 418);
  text("your pet on a walk", 580, 433);
  text("in order to stabilize", 575, 448);
  text("energy while increasing", 575, 463);
  text("health and happiness.", 575, 478);

  image(cleaner, 830, 310, cleaner.width/3.8f, cleaner.height/3.8f);
  text("A cleaner will tidy", 843.33f, 418);
  text("your pet's habitat,", 843.33f, 433);
  text("reducing the daily", 843.33f, 448);
  text("risk of your pet", 843.33f, 463);
  text("getting sick.", 843.33f, 478);

  noFill();
  rectMode(CORNERS);
  rect(933, 132, 976, 171.5f);
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X", 942, 151.75f);
  rectMode(CORNER);
  stroke(0);
  strokeWeight(2);
  if (!hasUsedLowQualityVet) redarrow(122, 520, "right");
}


// =========================
// Vet Sub-Panel
// =========================
void vet() {
  imageMode(CENTER);
  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(330, 222.5f, 770, 472.5f);
  textAlign(CENTER, CENTER);
  fill(255);
  textSize(35);
  text("THE VET:", width/2, height*0.235f+100);
  textSize(25);
  text("3 Star Vet:", 440, 294);
  image(vet, 440, 347, vet.width/3.75f, vet.height/3.75f);
  text("5 Star Vet:", 660, 294);
  image(vet, 660, 347, vet.width/3.75f, vet.height/3.75f);
  textSize(15);
  text("Treat " + alligator.petName + "'s " + currentSicknessName, 440, 389);
  text("for $5.", 440, 402);
  text("Treat " + alligator.petName + "'s " + currentSicknessName, 660, 389);
  text("for $20.", 660, 402);

  if (money >= 5) fill(0, 255, 0, 80);
  else fill(169, 80);
  rectMode(CENTER);
  rect(440, 435, 120, 30);
  if (money < 20) fill(169, 80);
  rect(660, 435, 120, 30);
  fill(255);
  textSize(20);
  text("TREAT", 440, 435);
  text("TREAT", 660, 435);

  noFill();
  rectMode(CORNERS);
  rect(713, 232, 756, 271.5f);
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X", 722, 251.75f);
  rectMode(CORNER);
  stroke(0);
  strokeWeight(2);
  if (!hasUsedLowQualityVet) redarrow(330, 435, "right");
}


// =========================
// Treatment Popup
// =========================
void treatmentpopup() {
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);
  fill(0);
  textFont(times50);
  textSize(20);
  drawWrappedTextInBox(vetTreatmentMessage, 338, 271, 761, 400, 6);
}


// =========================
// Prescription Management
// =========================
void clearPrescriptionCourse() {
  for (int i = 0; i < medicineIsPrescribed.length; i++) {
    medicineIsPrescribed[i] = false;
  }
  prescribedMedicineIndex = -1;
  prescriptionDaysRequired = 0;
  prescriptionDaysCompleted = 0;
  lastDoseTakenDay = -1;
}

void startPrescriptionCourse(int medIndex) {
  int preservedProgress = (prescribedMedicineIndex == medIndex && prescriptionDaysCompleted > 0)
    ? min(prescriptionDaysCompleted, medicineDefaultQuantities[medIndex] - 1)
    : 0;

  clearPrescriptionCourse();

  prescribedMedicineIndex = medIndex;
  prescriptionDaysRequired = medicineDefaultQuantities[medIndex];
  prescriptionDaysCompleted = preservedProgress;
  lastDoseTakenDay = -1;

  medicineIsPrescribed[medIndex] = true;
}
