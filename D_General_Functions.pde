// =========================
// Naming UI + File Loading / Initialization
// Loads assets (images/fonts/audio) and builds ControlP5 UI (music + naming)
// =========================

Textfield nameField;         // Text input for naming the pet
Button    confirmBtn;        // Button to confirm name entry
boolean   nameUIShown = false; // Tracks whether naming UI should currently be visible


// =========================
// Alligator placeholder name
// =========================

String alligatorname = "Moss";

// =========================
// Asset Loading + Audio + Fonts
// Called once during setup() to load everything the game needs
// =========================
void fileWork() {
  //Creating the alligator pet
    alligator = new Pet(alligatorname);

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
        float target = (lastVolume > 0 ? lastVolume : 0);
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
// Naming / Input-Related Variables
// =========================

String userInput = "";  // Placeholder string for typed input

PFont timesFont;        // Font reference

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
// Naming Confirmation
// Triggered by the ControlP5 button named "confirm"
// Creates the Pet using a cleaned-up, nicely formatted name
// =========================
boolean namechosen = false;

void confirm() {

  // Mark name selection complete
  namechosen = true;
  
  // Create the pet with formatted name pulled from textfield
  alligator.petName = formatName(nameField.getText());
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


void saveGame() {
  JSONObject save = new JSONObject();

  // cutscene / setup progress
  save.setBoolean("homescreenvisible", homescreenvisible);
  save.setBoolean("cutscenestart", cutscenestart);
  save.setBoolean("inNaming", inNaming);
  save.setBoolean("startrealgame", startrealgame);
  save.setBoolean("dogadopted", dogadopted);
  save.setBoolean("catadopted", catadopted);
  save.setInt("selectedAlligator", selectedAlligator);
  save.setBoolean("namechosen", namechosen);
  save.setString("alligatorname", alligatorname == null ? "" : alligatorname);
  save.setString("userInput", userInput == null ? "" : userInput);

  // main progression
  save.setBoolean("onmainscreen", onmainscreen);
  save.setInt("day", day);
  save.setFloat("money", money);
  save.setString("job", job == null ? "" : job);
  save.setFloat("salary", salary);
  save.setFloat("taskmoney", taskmoney);
  save.setFloat("moneyperpt", moneyperpt);
  save.setFloat("ptupgcost", ptupgcost);
  save.setFloat("salupgcost", salupgcost);
  save.setFloat("taskupgcost", taskupgcost);

  // pet state
  save.setString("petName", alligator.petName == null ? "" : alligator.petName);
  save.setFloat("health", alligator.health);
  save.setFloat("happiness", alligator.happiness);
  save.setFloat("energy", alligator.energy);
  save.setFloat("hunger", alligator.hunger);
  save.setFloat("sickrisk", alligator.sickrisk);

  // sickness / treatment
  save.setBoolean("sick", sick);
  save.setString("sickness", sickness == null ? "" : sickness);
  save.setBoolean("cleanerVisited", cleanerVisited);
  save.setInt("activePrescriptionIndex", activePrescriptionIndex);
  save.setInt("treatmentDaysNeeded", treatmentDaysNeeded);
  save.setInt("treatmentDaysCompleted", treatmentDaysCompleted);
  save.setInt("lastTreatmentDay", lastTreatmentDay);

  // tutorial / important progression flags
  save.setBoolean("welcomepopupvisible", welcomepopupvisible);
  save.setBoolean("firstinventoryclick", firstinventoryclick);
  save.setBoolean("fedsteak", fedsteak);
  save.setBoolean("firstearnclick", firstearnclick);
  save.setBoolean("firsthelpclick", firsthelpclick);
  save.setBoolean("firsttasktabclick", firsttasktabclick);
  save.setBoolean("firstservicesclick", firstservicesclick);
  save.setBoolean("firstbuymedicine", firstbuymedicine);
  save.setBoolean("firstmedicinegiven", firstmedicinegiven);
  save.setBoolean("firstbankclick", firstbankclick);
  save.setBoolean("firstrestclick", firstrestclick);
  save.setBoolean("firstalligatorrest", firstalligatorrest);
  save.setBoolean("firstachievementsclick", firstachievementsclick);
  save.setBoolean("firstachievementsclosed", firstachievementsclosed);
  save.setBoolean("firstnextdayclick", firstnextdayclick);
  save.setBoolean("firsthelppopupshown", firsthelppopupshown);
  save.setBoolean("firstLowQualityCareAlwaysSucceeds", firstLowQualityCareAlwaysSucceeds);
  save.setBoolean("neverboughthighqualitycare", neverboughthighqualitycare);
  save.setBoolean("lowqualitycaregiven", lowqualitycaregiven);
  save.setBoolean("bankpopupshown", bankpopupshown);
  save.setBoolean("showplayarrow", showplayarrow);

  // prescriptions — save both named fields (for backward compat) and array
  String[] prescNames = {"enrofloxacinPresc","doxycyclinePresc","oseltamivirPresc","vitaminBComplexPresc",
    "cyproheptadinePresc","potassiumChloridePresc","coenzymeQ10Presc","fluoxetinePresc",
    "trazodonePresc","meloxicamPresc","calciumCarbonatePresc","activatedCharcoalPresc"};
  for (int i = 0; i < prescNames.length; i++) save.setBoolean(prescNames[i], presc[i]);
  save.setJSONArray("presc", booleanArrayToJson(presc));

  // inventory
  save.setJSONArray("inventoryslots", stringArrayToJson(inventoryslots));
  save.setJSONArray("medQtys", intArrayToJson(medQtys));
  save.setJSONArray("snackQtys", intArrayToJson(snackQtys));
  save.setJSONArray("meatQtys", intArrayToJson(meatQtys));

  // bank
  JSONArray bankArr = new JSONArray();
  for (int i = 0; i < bankTransactions.size(); i++) {
    bankArr.append(bankTransactions.get(i));
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

  save.setInt("besthopscore", besthopscore);
  save.setInt("bestsnatchscore", bestsnatchscore);
  save.setInt("bestfetchscore", bestfetchscore);

  save.setJSONArray("achievementtiers", intArrayToJson(achievementtiers));

  saveJSONObject(save, "save.json");
}


void loadGame() {
  JSONObject save = loadJSONObject("save.json");
  if (save == null) return;

  // cutscene / setup progress
  homescreenvisible = save.getBoolean("homescreenvisible", homescreenvisible);
  cutscenestart = save.getBoolean("cutscenestart", cutscenestart);
  inNaming = save.getBoolean("inNaming", inNaming);
  startrealgame = save.getBoolean("startrealgame", startrealgame);
  dogadopted = save.getBoolean("dogadopted", dogadopted);
  catadopted = save.getBoolean("catadopted", catadopted);
  selectedAlligator = save.getInt("selectedAlligator", selectedAlligator);
  namechosen = save.getBoolean("namechosen", namechosen);
  alligatorname = save.getString("alligatorname", alligatorname);
  userInput = save.getString("userInput", userInput);

  // main progression
  onmainscreen = save.getBoolean("onmainscreen", onmainscreen);
  day = save.getInt("day", day);
  money = save.getFloat("money", money);
  job = save.getString("job", job);
  salary = save.getFloat("salary", salary);
  taskmoney = save.getFloat("taskmoney", taskmoney);
  moneyperpt = save.getFloat("moneyperpt", moneyperpt);
  ptupgcost = save.getFloat("ptupgcost", ptupgcost);
  salupgcost = save.getFloat("salupgcost", salupgcost);
  taskupgcost = save.getFloat("taskupgcost", taskupgcost);

  // pet state
  alligator.petName = save.getString("petName", alligator.petName);
  alligator.health = save.getFloat("health", alligator.health);
  alligator.happiness = save.getFloat("happiness", alligator.happiness);
  alligator.energy = save.getFloat("energy", alligator.energy);
  alligator.hunger = save.getFloat("hunger", alligator.hunger);
  alligator.sickrisk = save.getFloat("sickrisk", alligator.sickrisk);

  // sickness / treatment
  sick = save.getBoolean("sick", sick);
  sickness = save.getString("sickness", sickness);
  cleanerVisited = save.getBoolean("cleanerVisited", cleanerVisited);
  activePrescriptionIndex = save.getInt("activePrescriptionIndex", activePrescriptionIndex);
  treatmentDaysNeeded = save.getInt("treatmentDaysNeeded", treatmentDaysNeeded);
  treatmentDaysCompleted = save.getInt("treatmentDaysCompleted", treatmentDaysCompleted);
  lastTreatmentDay = save.getInt("lastTreatmentDay", lastTreatmentDay);

  // tutorial / progression flags
  welcomepopupvisible = save.getBoolean("welcomepopupvisible", welcomepopupvisible);
  firstinventoryclick = save.getBoolean("firstinventoryclick", firstinventoryclick);
  fedsteak = save.getBoolean("fedsteak", fedsteak);
  firstearnclick = save.getBoolean("firstearnclick", firstearnclick);
  firsthelpclick = save.getBoolean("firsthelpclick", firsthelpclick);
  firsttasktabclick = save.getBoolean("firsttasktabclick", firsttasktabclick);
  firstservicesclick = save.getBoolean("firstservicesclick", firstservicesclick);
  firstbuymedicine = save.getBoolean("firstbuymedicine", firstbuymedicine);
  firstmedicinegiven = save.getBoolean("firstmedicinegiven", firstmedicinegiven);
  firstbankclick = save.getBoolean("firstbankclick", firstbankclick);
  firstrestclick = save.getBoolean("firstrestclick", firstrestclick);
  firstalligatorrest = save.getBoolean("firstalligatorrest", firstalligatorrest);
  firstachievementsclick = save.getBoolean("firstachievementsclick", firstachievementsclick);
  firstachievementsclosed = save.getBoolean("firstachievementsclosed", firstachievementsclosed);
  firstnextdayclick = save.getBoolean("firstnextdayclick", firstnextdayclick);
  firsthelppopupshown = save.getBoolean("firsthelppopupshown", firsthelppopupshown);
  firstLowQualityCareAlwaysSucceeds = save.getBoolean("firstLowQualityCareAlwaysSucceeds", firstLowQualityCareAlwaysSucceeds);
  neverboughthighqualitycare = save.getBoolean("neverboughthighqualitycare", neverboughthighqualitycare);
  lowqualitycaregiven = save.getBoolean("lowqualitycaregiven", lowqualitycaregiven);
  bankpopupshown = save.getBoolean("bankpopupshown", bankpopupshown);
  showplayarrow = save.getBoolean("showplayarrow", showplayarrow);

  // prescriptions — load from named fields first, then override with presc[] array if present
  String[] prescNames = {"enrofloxacinPresc","doxycyclinePresc","oseltamivirPresc","vitaminBComplexPresc",
    "cyproheptadinePresc","potassiumChloridePresc","coenzymeQ10Presc","fluoxetinePresc",
    "trazodonePresc","meloxicamPresc","calciumCarbonatePresc","activatedCharcoalPresc"};
  for (int i = 0; i < prescNames.length; i++) presc[i] = save.getBoolean(prescNames[i], presc[i]);
  JSONArray prescArr = save.getJSONArray("presc");
  if (prescArr != null) {
    for (int i = 0; i < min(presc.length, prescArr.size()); i++) {
      presc[i] = prescArr.getBoolean(i);
    }
  }

  // inventory
  JSONArray invArr = save.getJSONArray("inventoryslots");
  if (invArr != null) {
    for (int i = 0; i < min(inventoryslots.length, invArr.size()); i++) {
      inventoryslots[i] = invArr.getString(i);
    }
  }

  JSONArray medQtyArr = save.getJSONArray("medQtys");
  if (medQtyArr != null) {
    for (int i = 0; i < min(medQtys.length, medQtyArr.size()); i++) {
      medQtys[i] = medQtyArr.getInt(i);
    }
  }

  JSONArray snackQtyArr = save.getJSONArray("snackQtys");
  if (snackQtyArr != null) {
    for (int i = 0; i < min(snackQtys.length, snackQtyArr.size()); i++) {
      snackQtys[i] = snackQtyArr.getInt(i);
    }
  }

  JSONArray meatQtyArr = save.getJSONArray("meatQtys");
  if (meatQtyArr != null) {
    for (int i = 0; i < min(meatQtys.length, meatQtyArr.size()); i++) {
      meatQtys[i] = meatQtyArr.getInt(i);
    }
  }

  // bank
  bankTransactions.clear();
  JSONArray bankArr = save.getJSONArray("bankTransactions");
  if (bankArr != null) {
    for (int i = 0; i < bankArr.size(); i++) {
      bankTransactions.add(bankArr.getString(i));
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

  besthopscore = save.getInt("besthopscore", besthopscore);
  bestsnatchscore = save.getInt("bestsnatchscore", bestsnatchscore);
  bestfetchscore = save.getInt("bestfetchscore", bestfetchscore);

  JSONArray achievementtiersArr = save.getJSONArray("achievementtiers");
  if (achievementtiersArr != null) {
    for (int i = 0; i < min(achievementtiers.length, achievementtiersArr.size()); i++) {
      achievementtiers[i] = achievementtiersArr.getInt(i);
    }
  }

  // reset temporary UI/runtime stuff so resume is clean
  showinstructions = false;
  showmusicsettings = false;
  inventoryvisible = false;
  showcantsell = false;
  showplaypopup = false;
  showplayarrow = false;
  showearnpopup = false;
  earnpopupshown = false;
  earnclicked = false;
  helpclicked = false;
  showfirsthelppopup = false;
  servicesclicked = false;
  vetclicked = false;
  showtreatmentpopup = false;
  treatmentpopupshown = false;
  lowQualityVetFailedPopup = false;
  storeclicked = false;
  buymedicine = false;
  buysnacks = false;
  buymeat = false;
  bankclicked = false;
  bankpopupshown = false;
  showbankpopup = false;
  showrestpopup = false;
  restpopupshown = false;
  restclicked = false;
  achievementsclicked = false;
  showstoreclosedpopup = false;
  nextdayclicked = false;
  dayedited = false;
  changeday = false;
  playclicked = false;
  fadingout = false;
  onchoicescreen = false;
  enterswamphop = false;
  entersnacksnatch = false;
  enterfetchfrenzy = false;
  exit = false;
  selectedSlot = -1;

  refreshAchievementData();
}

JSONArray booleanArrayToJson(boolean[] arr) {
  JSONArray j = new JSONArray();
  for (int i = 0; i < arr.length; i++) {
    j.setBoolean(i, arr[i]);
  }
  return j;
}

JSONArray stringArrayToJson(String[] arr) {
  JSONArray j = new JSONArray();
  for (int i = 0; i < arr.length; i++) {
    j.setString(i, arr[i] == null ? "" : arr[i]);
  }
  return j;
}

JSONArray intArrayToJson(int[] arr) {
  JSONArray j = new JSONArray();
  for (int i = 0; i < arr.length; i++) {
    j.setInt(i, arr[i]);
  }
  return j;
}
