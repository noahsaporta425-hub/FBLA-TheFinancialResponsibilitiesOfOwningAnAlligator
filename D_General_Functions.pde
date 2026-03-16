// =========================
// Fade
// A reusable screen-transition overlay that fades the display to/from black.
// Each distinct transition owns one Fade instance with its own opacity.
//
// opacity: 0 = fully transparent (screen visible), 255 = fully black
// outComplete: one-way latch — stays true once opacity first reaches 255.
//   Use this to detect "done fading to black" in multi-phase sequences
//   without re-checking opacity (which would flip back as we fade in again).
//
// Usage:
//   Fade myFade = new Fade(255);          // start black (e.g. screen entry)
//   myFade.stepIn(speed);                 // move toward clear each frame
//   myFade.stepOut(speed);                // move toward black each frame
//   myFade.draw();                        // draw the overlay on top of everything
//   myFade.isBlack() / myFade.isClear()  // check completion states
// =========================
class Fade {
  float opacity;
  boolean outComplete;   // latches true the first time opacity reaches 255

  Fade(float startOpacity) {
    opacity = startOpacity;
    outComplete = (startOpacity >= 255);
  }

  // Step opacity toward 255 (to black); sets outComplete when fully black
  boolean stepOut(float speed) {
    opacity = min(255, opacity + speed);
    if (opacity >= 255) outComplete = true;
    return outComplete;
  }

  // Step opacity toward 0 (to clear); returns true when fully transparent
  boolean stepIn(float speed) {
    opacity = max(0, opacity - speed);
    return opacity <= 0;
  }

  // Draw a full-screen black rectangle at the current opacity level.
  // Call after all other draw calls so the overlay sits on top.
  void draw() {
    noStroke();
    fill(0, opacity);
    rectMode(CORNER);
    rect(0, 0, width, height);
  }

  boolean isBlack() { return opacity >= 255; }
  boolean isClear()  { return opacity <= 0;  }
  void setBlack() { opacity = 255; outComplete = true; }
  void setClear()  { opacity = 0; }
}


// =========================
// Naming UI + File Loading / Initialization
// Loads assets (images/fonts/audio) and builds ControlP5 UI (music + naming)
// =========================

Textfield nameField;         // Text input for naming the pet
Button    confirmBtn;        // Button to confirm name entry
boolean   isNameInputVisible = false; // Tracks whether naming UI should currently be visible


// =========================
// Alligator placeholder name
// =========================

String defaultPetName = "Moss";

// =========================
// Naming / Input-Related Variables
// =========================

String typedInput = "";  // Placeholder string for typed input

PFont fontTimesReference;        // Font reference

// Holds the current validation error message shown on the naming screen
// Empty string means no error (input is valid or not yet submitted)
String petNameValidationError = "";

boolean isNameChosen = false;


// =========================
// Asset Loading + Audio + Fonts
// Called once during setup() to load everything the game needs
// =========================
void fileWork() {
  //Creating the alligator pet
    alligator = new Pet(defaultPetName);

  // --- Images / Screens ---
  homescreen                = loadImage("gametitlescreen.png");
  instructions              = loadImage("instructions.png");
  musicscreen               = loadImage("musicscreen.png");
  outsideofadoptioncenter   = loadImage("outsideofadoptioncenter.png");
  adoptioncenterinterior    = loadImage("adoptioncenterinterior.png");
  pickingcat                = loadImage("pickingcat.png");
  pickingdog                = loadImage("pickingdog.png");
  namingalligatorbackground = loadImage("namingalligatorbackground.png");
  alligator.neutralalligator= loadImage("neutralalligator.png");
  alligator.hungryalligator = loadImage("hungryalligator.png");
  alligator.energeticalligator = loadImage("energeticalligator.png");
  alligator.sickalligator   = loadImage("sickalligator.png");
  mainscreen                = loadImage("mainscreen.png");
  mainscreenbuttons         = loadImage("mainscreenbuttons.png");
  achievementsbutton        = loadImage("achievementsbutton.png");
  settingsbutton            = loadImage("settingsbutton.png");
  earnbutton                = loadImage("earnbutton.png");
  popupbackground           = loadImage("popupbackground.png");
  cloudframe1               = loadImage("cloudframe1.png");
  cloudframe2               = loadImage("cloudframe2.png");
  cloudframe3               = loadImage("cloudframe3.png");
  steak                     = loadImage("steak.png");
  redarrow                  = loadImage("redarrow.png");
  minigamechoice            = loadImage("minigamechoice.png");
  swamphopbackground        = loadImage("swamphopbackground.png");
  alligatorf1               = loadImage("alligatorf1.png");
  alligatorf2               = loadImage("alligatorf2.png");
  alligatorf3               = loadImage("alligatorf3.png");
  alligatorf4               = loadImage("alligatorf4.png");
  log                       = loadImage("log.png");
  vine                      = loadImage("vine.png");
  rock                      = loadImage("rocks.png");
  mud                       = loadImage("mud.png");
  bluegill                  = loadImage("bluegill.png");
  bass                      = loadImage("bass.png");
  perch                     = loadImage("perch.png");
  goldfish                  = loadImage("goldfish.png");
  crab                      = loadImage("crab.png");
  lambchop                  = loadImage("lambchop.png");
  porkchop                  = loadImage("porkchop.png");
  broccoli                  = loadImage("broccoli.png");
  carrot                    = loadImage("carrot.png");
  tomato                    = loadImage("tomato.png");
  pepper                    = loadImage("pepper.png");
  fetchfrenzybackground     = loadImage("fetchfrenzybackground.png");
  ball                      = loadImage("ball.png");
  topalligator1             = loadImage("topalligator1.png");
  topalligator2             = loadImage("topalligator2.png");
  unemployed                = loadImage("unemployed.png");
  cashier                   = loadImage("cashier.png");
  barista                   = loadImage("barista.png");
  manager                   = loadImage("manager.png");
  town                      = loadImage("town.png");
  cash                      = loadImage("cash.png");
  house                     = loadImage("house.png");
  lock                      = loadImage("lock.png");
  vet                       = loadImage("vet.png");
  walker                    = loadImage("walker.png");
  cleaner                   = loadImage("cleaner.png");
  storebackground           = loadImage("storebackground.png");
  medicine                  = loadImage("medicine.png");
  nachos                    = loadImage("nachos.png");
  cheesepuffs   = loadImage("cheesepuffs.png");
  chips         = loadImage("chips.png");
  chocolatebar  = loadImage("chocolatebar.png");
  cookies       = loadImage("cookies.png");
  crackers      = loadImage("crackers.png");
  energydrink   = loadImage("energydrink.png");
  granolabar    = loadImage("granolabar.png");
  popcorn       = loadImage("popcorn.png");
  pretzels      = loadImage("pretzels.png");
  soda          = loadImage("soda.png");
  trailmix      = loadImage("trailmix.png");
  chicken = loadImage("chicken.png");
  catfish = loadImage("catfish.png");
  frog = loadImage("frog.png");
  shrimp = loadImage("shrimp.png");

  // Initialize image arrays for store/inventory grid drawing
  snackImages = new PImage[]{nachos, cheesepuffs, chips, chocolatebar, cookies, crackers,
                              energydrink, granolabar, popcorn, pretzels, soda, trailmix};
  meatImages  = new PImage[]{bluegill, bass, perch, goldfish, crab, lambchop,
                              porkchop, steak, chicken, catfish, frog, shrimp};

  // --- Background Music ---
  music = new SoundFile(this, "music.mp3");
  music.loop();
  music.amp(0.2);

  // --- Fonts ---
  times15 = createFont("timesnewroman.ttf", 15);
  times50 = createFont("timesnewroman.ttf", 50);
  times30 = createFont("timesnewroman.ttf", 30);
  arcade  = createFont("arcade.otf", 40);
}


// =========================
// Music Settings UI
// Builds a volume slider + on/off toggle (hidden by default)
// Keeps UI + audio state synchronized via callbacks
// =========================
void musicAdjusters() {

  // Create ControlP5 UI manager (needed for sliders, toggles, textfields, buttons)
  cp5 = new ControlP5(this);

  // Temporarily stop ControlP5 from broadcasting events while building components
  // (prevents callbacks firing during setup)
  cp5.setBroadcast(false);

  // -------------------------
  // Volume Slider ("volume")
  // -------------------------
  cp5.addSlider("volume")
    .setFont(times15)
    .setPosition(width * 0.26, height * 0.53)
    .setSize(300, 28)
    .setRange(0, 100)
    .setValue(50)
    .setLabel("VOLUME")
    .setColorCaptionLabel(color(0))
    .setColorValueLabel(color(0))
    .setColorBackground(color(40))
    .setColorForeground(color(227, 139, 7))
    .setColorActive(color(227, 139, 7))
    .setDecimalPrecision(0)
    .setVisible(false); // hidden until user opens music settings screen

  // Ensure the slider's numeric value label uses the correct font
  ((controlP5.Controller) cp5.getController("volume"))
    .getValueLabel()
    .setFont(times15);

  // -------------------------
  // Music Toggle ("musicOn")
  // -------------------------
  Toggle t = cp5.addToggle("musicOn")
    .setPosition(width * 0.63, height * 0.53)
    .setSize(50, 25)
    .setValue(true)
    .setFont(times15)
    .setLabel("ON / OFF")
    .setColorCaptionLabel(color(0))
    .setColorBackground(color(40))
    .setColorActive(color(227, 139, 7))
    .setColorForeground(color(227, 139, 7))
    .setVisible(false); // hidden until user opens music settings screen

  // Turn broadcasting back on now that UI elements exist
  cp5.setBroadcast(true);

  // -------------------------
  // Toggle Change Callback
  // When user flips ON/OFF, update slider + actual audio safely
  // -------------------------
  t.onChange(new CallbackListener() {
    public void controlEvent(CallbackEvent e) {

      // Toggle controller gives 1 (on) or 0 (off)
      float v = e.getController().getValue();
      boolean on = (v == 1);

      if (on) {
        // Restore last non-zero volume when turning back on
        float target = (lastNonZeroVolume > 0 ? lastNonZeroVolume : 0);
        setSliderValueNoEvent(target);
        applyVolume(target);
      } else {
        // Mute when off
        setSliderValueNoEvent(0);
        applyVolume(0);
      }
    }
  });
}


// =========================
// Name Input UI Builder
// Creates a hidden Textfield + Confirm button for naming the pet
// =========================
void nameinput() {

  // ControlP5 font wrapper for text rendering in UI components
  ControlFont cf = new ControlFont(times15, 20);

  // -------------------------
  // Name Textfield ("nameInput")
  // -------------------------
  nameField = cp5.addTextfield("nameInput")
    .setPosition(width * 0.35, 300)
    .setSize(220, 40)
    .setAutoClear(false)  // keep text after pressing enter/clicking away
    .hide()               // hidden until naming screen is shown
    .setLabel("");        // no label text (clean UI)

  // Hide the caption label and style the displayed text
  nameField.getCaptionLabel().setVisible(false);
  nameField.getValueLabel().setFont(cf);

  // Textfield color theme
  nameField.setColorBackground(color(20, 80, 50));
  nameField.setColorForeground(color(140, 255, 170));
  nameField.setColorActive(color(140, 255, 170));
  nameField.setColorValueLabel(color(255));

  // Light padding so the caret/text doesn't start at the border
  nameField.setText("  ");

  // -------------------------
  // Confirm Button ("confirm")
  // ControlP5 will automatically call void confirm() when pressed
  // -------------------------
  confirmBtn = cp5.addButton("confirm")
    .setPosition(width * 0.35 + 230, 300)
    .setSize(110, 40)
    .hide()               // hidden until naming screen is shown
    .setLabel("CONFIRM");

  // Button label styling + colors
  confirmBtn.getCaptionLabel().setFont(cf).setColor(color(255));
  confirmBtn.setColorBackground(color(10, 50, 35));
  confirmBtn.setColorForeground(color(140, 255, 170));
  confirmBtn.setColorActive(color(30, 100, 70));
}


// =========================
// Input Validation
// Validates the pet name on two levels before accepting it:
//   - Syntactical: checks format rules (non-empty, max length, allowed characters)
//   - Semantic:    checks that the value makes sense as a name (at least one letter)
// Sets petNameValidationError to a human-readable message on failure.
// Returns true if the name is acceptable, false otherwise.
// =========================

boolean isValidName(String raw) {

  // Syntactical check: cannot be null or entirely whitespace
  if (raw == null || raw.trim().length() == 0) {
    petNameValidationError = "Name cannot be empty. Please enter a name.";
    return false;
  }

  String trimmed = raw.trim();

  // Syntactical check: enforce a maximum of 20 characters for display fit
  if (trimmed.length() > 20) {
    petNameValidationError = "Name is too long (max 20 characters).";
    return false;
  }

  // Semantic check: name must include at least one actual letter — not just symbols/spaces
  boolean hasLetter = false;
  for (int i = 0; i < trimmed.length(); i++) {
    if (Character.isLetter(trimmed.charAt(i))) {
      hasLetter = true;
      break;
    }
  }
  if (!hasLetter) {
    petNameValidationError = "Name must contain at least one letter.";
    return false;
  }

  // Syntactical check: only letters, spaces, hyphens, and apostrophes are valid
  // (covers names like "Al" or "Snap-jaw" or "O'Scales" but blocks digits/symbols)
  for (int i = 0; i < trimmed.length(); i++) {
    char c = trimmed.charAt(i);
    if (!Character.isLetter(c) && c != ' ' && c != '-' && c != '\'') {
      petNameValidationError = "Only letters, spaces, hyphens, and apostrophes are allowed.";
      return false;
    }
  }

  // All checks passed — clear any leftover error message
  petNameValidationError = "";
  return true;
}


// =========================
// Naming Confirmation
// Triggered by the ControlP5 button named "confirm"
// Validates the name first; only proceeds if it passes both syntactical and semantic checks.
// =========================

void confirm() {

  String rawInput = nameField.getText();

  // Validate before accepting — if invalid, show error and block the transition
  if (!isValidName(rawInput)) return;

  // Mark name selection complete and assign the formatted name to the pet
  isNameChosen = true;
  alligator.petName = formatName(rawInput);
}


// =========================
// Name Formatting Helper
// Normalizes user input for display consistency:
// - trims ends
// - collapses multiple spaces
// - converts to lowercase
// - capitalizes first character
// =========================
String formatName(String raw) {

  raw = raw.trim();                   // remove leading/trailing spaces
  raw = raw.replaceAll("\\s+", " ");  // collapse multiple spaces into single spaces
  raw = raw.toLowerCase();            // normalize to lowercase

  // If user entered nothing meaningful, return empty string
  if (raw.length() == 0) return raw;

  // Capitalize first letter only
  return raw.substring(0, 1).toUpperCase() + raw.substring(1);
}


// =========================
// saveGame / loadGame
// Persist and restore the entire game state to/from "save.json" in the sketch's data folder.
// Every global variable that affects gameplay is saved so the player can quit and resume.
// Arrays (inventory, prescriptions, achievements) are serialized via helper functions below.
// Transient UI flags (popup visibility, selected slot, etc.) are reset on load so the
// resume experience starts from a clean visual state even if the player quit mid-popup.
// =========================

void saveGame() {
  JSONObject save = new JSONObject();

  // cutscene / setup progress
  save.setBoolean("homescreenvisible", isHomeScreenVisible);
  save.setBoolean("cutscenestart", isCutsceneActive);
  save.setBoolean("inNaming", isNamingActive);
  save.setBoolean("startrealgame", isGameStarted);
  save.setBoolean("dogadopted", isDogSelected);
  save.setBoolean("catadopted", isCatSelected);
  save.setInt("selectedAlligator", selectedAlligatorSkin);
  save.setBoolean("namechosen", isNameChosen);
  save.setString("alligatorname", defaultPetName == null ? "" : defaultPetName);
  save.setString("userInput", typedInput == null ? "" : typedInput);

  // main progression
  save.setBoolean("onmainscreen", isOnMainScreen);
  save.setInt("day", day);
  save.setFloat("money", money);
  save.setString("job", job == null ? "" : job);
  save.setFloat("salary", salary);
  save.setFloat("totalJobEarnings", totalJobEarnings);
  save.setFloat("taskmoney", taskRewardAmount);
  save.setFloat("moneyperpt", moneyPerMinigamePoint);
  save.setFloat("ptupgcost", pointUpgradeCost);
  save.setFloat("salupgcost", salaryUpgradeCost);
  save.setFloat("taskupgcost", taskUpgradeCost);

  // pet state
  save.setString("petName", alligator.petName == null ? "" : alligator.petName);
  save.setFloat("health", alligator.health);
  save.setFloat("happiness", alligator.happiness);
  save.setFloat("energy", alligator.energy);
  save.setFloat("hunger", alligator.hunger);
  save.setFloat("sickrisk", alligator.sickrisk);

  // sickness / treatment
  save.setBoolean("sick", isPetSick);
  save.setString("sickness", currentSicknessName == null ? "" : currentSicknessName);
  save.setBoolean("cleanerVisited", hasCleanerVisited);
  save.setInt("activePrescriptionIndex", prescribedMedicineIndex);
  save.setInt("treatmentDaysNeeded", prescriptionDaysRequired);
  save.setInt("treatmentDaysCompleted", prescriptionDaysCompleted);
  save.setInt("lastTreatmentDay", lastDoseTakenDay);

  // tutorial / important progression flags
  save.setBoolean("welcomepopupvisible", isWelcomePopupVisible);
  save.setBoolean("firstinventoryclick", hasOpenedInventory);
  save.setBoolean("fedsteak", hasFedSteak);
  save.setBoolean("firstearnclick", hasOpenedEarnPanel);
  save.setBoolean("firsthelpclick", hasUsedHelpTask);
  save.setBoolean("firsttasktabclick", hasClickedTaskTab);
  save.setBoolean("firstservicesclick", hasOpenedServices);
  save.setBoolean("firstbuymedicine", hasFirstBoughtMedicine);
  save.setBoolean("firstmedicinegiven", hasGivenFirstMedicine);
  save.setBoolean("firstbankclick", hasViewedBank);
  save.setBoolean("firstrestclick", hasUsedRest);
  save.setBoolean("firstalligatorrest", hasAlligatorRestedOnce);
  save.setBoolean("firstachievementsclick", hasOpenedAchievements);
  save.setBoolean("firstachievementsclosed", hasClosedAchievements);
  save.setBoolean("firstnextdayclick", hasAdvancedDay);
  save.setBoolean("firsthelppopupshown", hasShownFirstHelpPopup);
  save.setBoolean("firstLowQualityCareAlwaysSucceeds", isFirstLowQualityVetAttempt);
  save.setBoolean("neverboughthighqualitycare", hasNeverBoughtHighQualityCare);
  save.setBoolean("lowqualitycaregiven", hasUsedLowQualityVet);
  save.setBoolean("bankpopupshown", hasShownBankPopup);
  save.setBoolean("showplayarrow", isShowingPlayArrow);

  // tutorial popup "already shown" flags — saved so they don't replay on resume
  save.setBoolean("earnpopupshown", hasShownEarnPopup);
  save.setBoolean("playpopupShown", hasShownPlayPopup);
  save.setBoolean("jobpopupshown", hasShownJobPopup);
  save.setBoolean("treatmentpopupshown", hasShownTreatmentPopup);
  save.setBoolean("restpopupshown", hasShownRestPopup);
  save.setBoolean("firstbankview", hasViewedBankFirstTime);
  save.setBoolean("firstenergystabalized", hasEnergyStabilized);

  // prescriptions — save both named fields (for backward compat) and array
  String[] prescNames = {"enrofloxacinPresc","doxycyclinePresc","oseltamivirPresc","vitaminBComplexPresc",
    "cyproheptadinePresc","potassiumChloridePresc","coenzymeQ10Presc","fluoxetinePresc",
    "trazodonePresc","meloxicamPresc","calciumCarbonatePresc","activatedCharcoalPresc"};
  for (int i = 0; i < prescNames.length; i++) save.setBoolean(prescNames[i], medicineIsPrescribed[i]);
  save.setJSONArray("presc", booleanArrayToJson(medicineIsPrescribed));

  // inventory
  save.setJSONArray("inventoryslots", stringArrayToJson(inventorySlots));
  save.setJSONArray("medQtys", intArrayToJson(medicineQuantities));
  save.setJSONArray("snackQtys", intArrayToJson(snackQuantities));
  save.setJSONArray("meatQtys", intArrayToJson(meatQuantities));

  // bank
  JSONArray bankArr = new JSONArray();
  for (int i = 0; i < bankTransactionLog.size(); i++) {
    bankArr.append(bankTransactionLog.get(i));
  }
  save.setJSONArray("bankTransactions", bankArr);

  // counters / stats / achievements
  save.setInt("timesRestedSuccessfully", timesRestedSuccessfully);
  save.setInt("timesFedPet", timesFedPet);
  save.setInt("timesUsedVetCare", timesUsedVetCare);
  save.setInt("timesBoughtMedicine", timesBoughtMedicine);
  save.setInt("salaryUpgradeCount", salaryUpgradeCount);
  save.setInt("taskUpgradeCount", taskUpgradeCount);
  save.setInt("playPointUpgradeCount", playPointUpgradeCount);
  save.setInt("currentDay", currentDay);
  save.setInt("inventoryFullCount", inventoryFullCount);
  save.setInt("helpTaskCount", helpTaskCount);
  save.setInt("medicineGivenCount", medicineGivenCount);
  save.setInt("lowQualityCareCount", lowQualityCareCount);
  save.setInt("highQualityCareCount", highQualityCareCount);
  save.setInt("itemsBoughtCount", itemsBoughtCount);
  save.setInt("inventoryItemsUsedCount", inventoryItemsUsedCount);
  save.setFloat("totalMoneyEarned", totalMoneyEarned);
  save.setFloat("totalMoneySpent", totalMoneySpent);
  save.setFloat("highestMoneyBalance", highestMoneyBalance);
  save.setFloat("moneyEarnedFromSalary", moneyEarnedFromSalary);
  save.setFloat("moneyEarnedFromTasks", moneyEarnedFromTasks);
  save.setFloat("moneyEarnedFromMinigames", moneyEarnedFromMinigames);
  save.setInt("restAttempts", restAttempts);
  save.setFloat("totalEnergyRestoredFromResting", totalEnergyRestoredFromResting);
  save.setFloat("totalHealthRestored", totalHealthRestored);
  save.setFloat("totalHappinessRestored", totalHappinessRestored);
  save.setInt("cleanersHiredCount", cleanersHiredCount);
  save.setInt("bankTransactionsLoggedCount", bankTransactionsLoggedCount);
  save.setInt("walkersHiredCount", walkersHiredCount);
  save.setFloat("currentPlaySessionMoneyEarned", currentPlaySessionMoneyEarned);

  save.setInt("besthopscore", swampHopBestScore);
  save.setInt("bestsnatchscore", snatchBestScore);
  save.setInt("bestfetchscore", fetchBestScore);

  save.setJSONArray("achievementtiers", intArrayToJson(achievementTiers));

  saveJSONObject(save, "save.json");
}


void loadGame() {
  File saveFile = new File(sketchPath("data/save.json"));
  if (!saveFile.exists()) return;
  JSONObject save = loadJSONObject("save.json");
  if (save == null) return;

  // cutscene / setup progress
  isHomeScreenVisible = save.getBoolean("homescreenvisible", isHomeScreenVisible);
  isCutsceneActive = save.getBoolean("cutscenestart", isCutsceneActive);
  isNamingActive = save.getBoolean("inNaming", isNamingActive);
  isGameStarted = save.getBoolean("startrealgame", isGameStarted);
  isDogSelected = save.getBoolean("dogadopted", isDogSelected);
  isCatSelected = save.getBoolean("catadopted", isCatSelected);
  selectedAlligatorSkin = save.getInt("selectedAlligator", selectedAlligatorSkin);
  isNameChosen = save.getBoolean("namechosen", isNameChosen);
  defaultPetName = save.getString("alligatorname", defaultPetName);
  typedInput = save.getString("userInput", typedInput);

  // main progression
  isOnMainScreen = save.getBoolean("onmainscreen", isOnMainScreen);
  day = save.getInt("day", day);
  money = save.getFloat("money", money);
  job = save.getString("job", job);
  salary = save.getFloat("salary", salary);
  totalJobEarnings = save.getFloat("totalJobEarnings", totalJobEarnings);
  taskRewardAmount = save.getFloat("taskmoney", taskRewardAmount);
  moneyPerMinigamePoint = save.getFloat("moneyperpt", moneyPerMinigamePoint);
  pointUpgradeCost = save.getFloat("ptupgcost", pointUpgradeCost);
  salaryUpgradeCost = save.getFloat("salupgcost", salaryUpgradeCost);
  taskUpgradeCost = save.getFloat("taskupgcost", taskUpgradeCost);

  // pet state
  alligator.petName = save.getString("petName", alligator.petName);
  alligator.health = save.getFloat("health", alligator.health);
  alligator.happiness = save.getFloat("happiness", alligator.happiness);
  alligator.energy = save.getFloat("energy", alligator.energy);
  alligator.hunger = save.getFloat("hunger", alligator.hunger);
  alligator.sickrisk = save.getFloat("sickrisk", alligator.sickrisk);

  // sickness / treatment
  isPetSick = save.getBoolean("sick", isPetSick);
  currentSicknessName = save.getString("sickness", currentSicknessName);
  hasCleanerVisited = save.getBoolean("cleanerVisited", hasCleanerVisited);
  prescribedMedicineIndex = save.getInt("activePrescriptionIndex", prescribedMedicineIndex);
  prescriptionDaysRequired = save.getInt("treatmentDaysNeeded", prescriptionDaysRequired);
  prescriptionDaysCompleted = save.getInt("treatmentDaysCompleted", prescriptionDaysCompleted);
  lastDoseTakenDay = save.getInt("lastTreatmentDay", lastDoseTakenDay);

  // tutorial / progression flags
  isWelcomePopupVisible = save.getBoolean("welcomepopupvisible", isWelcomePopupVisible);
  hasOpenedInventory = save.getBoolean("firstinventoryclick", hasOpenedInventory);
  hasFedSteak = save.getBoolean("fedsteak", hasFedSteak);
  hasOpenedEarnPanel = save.getBoolean("firstearnclick", hasOpenedEarnPanel);
  hasUsedHelpTask = save.getBoolean("firsthelpclick", hasUsedHelpTask);
  hasClickedTaskTab = save.getBoolean("firsttasktabclick", hasClickedTaskTab);
  hasOpenedServices = save.getBoolean("firstservicesclick", hasOpenedServices);
  hasFirstBoughtMedicine = save.getBoolean("firstbuymedicine", hasFirstBoughtMedicine);
  hasGivenFirstMedicine = save.getBoolean("firstmedicinegiven", hasGivenFirstMedicine);
  hasViewedBank = save.getBoolean("firstbankclick", hasViewedBank);
  hasUsedRest = save.getBoolean("firstrestclick", hasUsedRest);
  hasAlligatorRestedOnce = save.getBoolean("firstalligatorrest", hasAlligatorRestedOnce);
  hasOpenedAchievements = save.getBoolean("firstachievementsclick", hasOpenedAchievements);
  hasClosedAchievements = save.getBoolean("firstachievementsclosed", hasClosedAchievements);
  hasAdvancedDay = save.getBoolean("firstnextdayclick", hasAdvancedDay);
  hasShownFirstHelpPopup = save.getBoolean("firsthelppopupshown", hasShownFirstHelpPopup);
  isFirstLowQualityVetAttempt = save.getBoolean("firstLowQualityCareAlwaysSucceeds", isFirstLowQualityVetAttempt);
  hasNeverBoughtHighQualityCare = save.getBoolean("neverboughthighqualitycare", hasNeverBoughtHighQualityCare);
  hasUsedLowQualityVet = save.getBoolean("lowqualitycaregiven", hasUsedLowQualityVet);
  hasShownBankPopup = save.getBoolean("bankpopupshown", hasShownBankPopup);
  isShowingPlayArrow = save.getBoolean("showplayarrow", isShowingPlayArrow);

  // tutorial popup "already shown" flags
  hasShownEarnPopup = save.getBoolean("earnpopupshown", hasShownEarnPopup);
  hasShownPlayPopup = save.getBoolean("playpopupShown", hasShownPlayPopup);
  hasShownJobPopup = save.getBoolean("jobpopupshown", hasShownJobPopup);
  hasShownTreatmentPopup = save.getBoolean("treatmentpopupshown", hasShownTreatmentPopup);
  hasShownRestPopup = save.getBoolean("restpopupshown", hasShownRestPopup);
  hasViewedBankFirstTime = save.getBoolean("firstbankview", hasViewedBankFirstTime);
  hasEnergyStabilized = save.getBoolean("firstenergystabalized", hasEnergyStabilized);

  // prescriptions — load from named fields first, then override with medicineIsPrescribed[] array if present
  String[] prescNames = {"enrofloxacinPresc","doxycyclinePresc","oseltamivirPresc","vitaminBComplexPresc",
    "cyproheptadinePresc","potassiumChloridePresc","coenzymeQ10Presc","fluoxetinePresc",
    "trazodonePresc","meloxicamPresc","calciumCarbonatePresc","activatedCharcoalPresc"};
  for (int i = 0; i < prescNames.length; i++) medicineIsPrescribed[i] = save.getBoolean(prescNames[i], medicineIsPrescribed[i]);
  JSONArray prescArr = save.getJSONArray("presc");
  if (prescArr != null) {
    for (int i = 0; i < min(medicineIsPrescribed.length, prescArr.size()); i++) {
      medicineIsPrescribed[i] = prescArr.getBoolean(i);
    }
  }

  // inventory
  JSONArray invArr = save.getJSONArray("inventoryslots");
  if (invArr != null) {
    for (int i = 0; i < min(inventorySlots.length, invArr.size()); i++) {
      inventorySlots[i] = invArr.getString(i);
    }
  }

  JSONArray medQtyArr = save.getJSONArray("medQtys");
  if (medQtyArr != null) {
    for (int i = 0; i < min(medicineQuantities.length, medQtyArr.size()); i++) {
      medicineQuantities[i] = medQtyArr.getInt(i);
    }
  }

  JSONArray snackQtyArr = save.getJSONArray("snackQtys");
  if (snackQtyArr != null) {
    for (int i = 0; i < min(snackQuantities.length, snackQtyArr.size()); i++) {
      snackQuantities[i] = snackQtyArr.getInt(i);
    }
  }

  JSONArray meatQtyArr = save.getJSONArray("meatQtys");
  if (meatQtyArr != null) {
    for (int i = 0; i < min(meatQuantities.length, meatQtyArr.size()); i++) {
      meatQuantities[i] = meatQtyArr.getInt(i);
    }
  }

  // bank
  bankTransactionLog.clear();
  JSONArray bankArr = save.getJSONArray("bankTransactions");
  if (bankArr != null) {
    for (int i = 0; i < bankArr.size(); i++) {
      bankTransactionLog.add(bankArr.getString(i));
    }
  }

  // counters / stats / achievements
  timesRestedSuccessfully = save.getInt("timesRestedSuccessfully", timesRestedSuccessfully);
  timesFedPet = save.getInt("timesFedPet", timesFedPet);
  timesUsedVetCare = save.getInt("timesUsedVetCare", timesUsedVetCare);
  timesBoughtMedicine = save.getInt("timesBoughtMedicine", timesBoughtMedicine);
  salaryUpgradeCount = save.getInt("salaryUpgradeCount", salaryUpgradeCount);
  taskUpgradeCount = save.getInt("taskUpgradeCount", taskUpgradeCount);
  playPointUpgradeCount = save.getInt("playPointUpgradeCount", playPointUpgradeCount);
  currentDay = save.getInt("currentDay", currentDay);
  inventoryFullCount = save.getInt("inventoryFullCount", inventoryFullCount);
  helpTaskCount = save.getInt("helpTaskCount", helpTaskCount);
  medicineGivenCount = save.getInt("medicineGivenCount", medicineGivenCount);
  lowQualityCareCount = save.getInt("lowQualityCareCount", lowQualityCareCount);
  highQualityCareCount = save.getInt("highQualityCareCount", highQualityCareCount);
  itemsBoughtCount = save.getInt("itemsBoughtCount", itemsBoughtCount);
  inventoryItemsUsedCount = save.getInt("inventoryItemsUsedCount", inventoryItemsUsedCount);
  totalMoneyEarned = save.getFloat("totalMoneyEarned", totalMoneyEarned);
  totalMoneySpent = save.getFloat("totalMoneySpent", totalMoneySpent);
  highestMoneyBalance = save.getFloat("highestMoneyBalance", highestMoneyBalance);
  moneyEarnedFromSalary = save.getFloat("moneyEarnedFromSalary", moneyEarnedFromSalary);
  moneyEarnedFromTasks = save.getFloat("moneyEarnedFromTasks", moneyEarnedFromTasks);
  moneyEarnedFromMinigames = save.getFloat("moneyEarnedFromMinigames", moneyEarnedFromMinigames);
  restAttempts = save.getInt("restAttempts", restAttempts);
  totalEnergyRestoredFromResting = save.getFloat("totalEnergyRestoredFromResting", totalEnergyRestoredFromResting);
  totalHealthRestored = save.getFloat("totalHealthRestored", totalHealthRestored);
  totalHappinessRestored = save.getFloat("totalHappinessRestored", totalHappinessRestored);
  cleanersHiredCount = save.getInt("cleanersHiredCount", cleanersHiredCount);
  bankTransactionsLoggedCount = save.getInt("bankTransactionsLoggedCount", bankTransactionsLoggedCount);
  walkersHiredCount = save.getInt("walkersHiredCount", walkersHiredCount);
  currentPlaySessionMoneyEarned = save.getFloat("currentPlaySessionMoneyEarned", currentPlaySessionMoneyEarned);

  swampHopBestScore = save.getInt("besthopscore", swampHopBestScore);
  snatchBestScore = save.getInt("bestsnatchscore", snatchBestScore);
  fetchBestScore = save.getInt("bestfetchscore", fetchBestScore);

  JSONArray achievementtiersArr = save.getJSONArray("achievementtiers");
  if (achievementtiersArr != null) {
    for (int i = 0; i < min(achievementTiers.length, achievementtiersArr.size()); i++) {
      achievementTiers[i] = achievementtiersArr.getInt(i);
    }
  }

  // reset temporary UI/runtime stuff so resume is clean
  isShowingInstructions = false;
  isShowingMusicSettings = false;
  isInventoryVisible = false;
  isShowingCantSell = false;
  isShowingPlayPopup = false;
  isShowingPlayArrow = false;
  isShowingEarnPopup = false;
  isEarnPanelOpen = false;
  isHelpTaskPending = false;
  isShowingFirstHelpPopup = false;
  isServicesOpen = false;
  isVetOpen = false;
  isShowingTreatmentPopup = false;
  isShowingVetFailedPopup = false;
  isStoreOpen = false;
  isViewingMedicineTab = false;
  isViewingSnacksTab = false;
  isViewingMeatTab = false;
  isBankOpen = false;
  isShowingBankPopup = false;
  isShowingRestPopup = false;
  isRestOpen = false;
  isAchievementsOpen = false;
  isShowingStoreClosedPopup = false;
  isNextDayPopupOpen = false;
  isDayEdited = false;
  isDayChangeConfirmed = false;
  isPlayClicked = false;
  isFadingOut = false;
  isOnChoiceScreen = false;
  isEnterSwampHop = false;
  isEnterSnackSnatch = false;
  isEnterFetchFrenzy = false;
  isExitingMinigame = false;
  selectedInventorySlot = -1;

  refreshAchievementData();
}

// =========================
// JSON Serialization Helpers
// Convert native arrays to JSONArray objects for use in saveGame().
// Processing's saveJSONObject() only accepts JSONArray/JSONObject children,
// so primitive arrays must be converted before they can be written to disk.
// =========================

// Converts a boolean[] to a JSONArray of boolean values
JSONArray booleanArrayToJson(boolean[] arr) {
  JSONArray j = new JSONArray();
  for (int i = 0; i < arr.length; i++) {
    j.setBoolean(i, arr[i]);
  }
  return j;
}

// Converts a String[] to a JSONArray; null entries become empty strings to avoid JSON errors
JSONArray stringArrayToJson(String[] arr) {
  JSONArray j = new JSONArray();
  for (int i = 0; i < arr.length; i++) {
    j.setString(i, arr[i] == null ? "" : arr[i]);
  }
  return j;
}

// Converts an int[] to a JSONArray of integer values
JSONArray intArrayToJson(int[] arr) {
  JSONArray j = new JSONArray();
  for (int i = 0; i < arr.length; i++) {
    j.setInt(i, arr[i]);
  }
  return j;
}
