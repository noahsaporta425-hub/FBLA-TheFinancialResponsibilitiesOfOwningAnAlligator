// =========================
// G_Services.pde
// Services panel: vet, walker, cleaner, treatment popups, and prescription logic.
// =========================


// =========================
// Services State
// =========================
boolean isServicesOpen = false;
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
// Renders the services panel listing the dog walker and cleaner options with their costs and effects.
// =========================
void services() {
  // Four equal columns across the panel (x: 110-990, width 880 -> 220 each)
  // Column centers: 220, 440, 660, 880
  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(110, 122.5f, 990, 572.5f);
  textAlign(CENTER, CENTER);
  fill(255);
  textSize(35);
  text("SERVICES:", width/2, height*0.235f);
  textSize(22);
  imageMode(CENTER);
  text("Vet:", 220, 200);
  text("Walker:", 440, 200);
  text("Cleaner:", 660, 200);
  text("PetAI:", 880, 200);

  rectMode(CENTER);
  fill(0, 255, 0, 80);
  rect(220, 520, 130, 40);   // vet -- always available
  if (money < 10) fill(169, 80);
  rect(440, 520, 130, 40);   // walker -- greyed if broke
  rect(660, 520, 130, 40);   // cleaner -- greyed if broke
  fill(0, 255, 0, 80);
  rect(880, 520, 130, 40);   // PetAI -- always available
  fill(255);
  textSize(18);
  text("VISIT",      220, 520);
  text("HIRE - $10", 440, 520); // $10/day services model real pet ownership expenses
  text("HIRE - $10", 660, 520);
  text("CHAT",       880, 520);

  image(vet,        220, 325, vet.width/2.0f,        vet.height/2.0f);
  textSize(13);
  text("Prescribes medicine and", 220, 418);
  text("treats injury, sickness,", 220, 433);
  text("and infection.",           220, 448);

  image(walker,     385, 325, walker.width/4.0f,     walker.height/4.0f);
  text("Stabilizes energy while", 440, 418);
  text("boosting health",         440, 433);
  text("and happiness.",          440, 448);

  image(cleaner,    730, 305, cleaner.width/4.5f,    cleaner.height/4.5f);
  text("Tidies the habitat,",    660, 418);
  text("reducing the daily",     660, 433);
  text("sickness risk.",         660, 448);

  image(unemployed, 880, 315, unemployed.width/3.5f, unemployed.height/3.5f);
  text("Ask about your pet,",    880, 418);
  text("finances, strategy,",    880, 433);
  text("and tips.",              880, 448);

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
}


// =========================
// Vet Sub-Panel
// Renders the vet panel with quality tiers, current prescription status, and treatment history.
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
  text("for $5.", 440, 402); // low-quality vet is cheaper but has a 25% fail rate; high-quality always succeeds -- teaches cost vs reliability tradeoff
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

// clearPrescriptionCourse: Resets all prescription flags and progress when a treatment course is completed or cancelled.
void clearPrescriptionCourse() {
  for (int i = 0; i < medicineIsPrescribed.length; i++) {
    medicineIsPrescribed[i] = false;
  }
  prescribedMedicineIndex = -1;
  prescriptionDaysRequired = 0;
  prescriptionDaysCompleted = 0;
  lastDoseTakenDay = -1;
}

// startPrescriptionCourse: Initializes a new prescription course for the given medicine index, preserving any prior partial progress.
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
