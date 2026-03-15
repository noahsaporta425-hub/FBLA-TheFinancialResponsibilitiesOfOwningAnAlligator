// =========================
// Main Screen Assets / Globals
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

boolean onmainscreen = false;
boolean welcomepopupvisible = true;
boolean inventoryvisible = false;
boolean firstinventoryclick = false;
boolean fedsteak = false;
boolean showcantsell = false;
boolean showplaypopup = false;
boolean playpopupShown = false;
boolean showplayarrow = false;
boolean playclicked = false;
boolean fadingout = false;
boolean firstenergystabalized = false;
boolean showearnpopup = false;
boolean earnpopupshown = false;
boolean earnclicked = false;
boolean firstearnclick = false;
boolean firsthelpclick = false;
boolean firsttasktabclick = false;
boolean firstservicesclick = false;
boolean firstbuymedicine = false;
boolean firstmedicinegiven = false;
boolean firstbankclick = false;
boolean bankclicked = false;
boolean neverboughthighqualitycare=true;
boolean firstrestclick = false;
boolean firstalligatorrest = false;
boolean firstachievementsclick=false;
boolean achievementsclicked = false;
boolean firstachievementsclosed = false;
boolean showstoreclosedpopup=false;
boolean nextdayclicked = false;
boolean firstnextdayclick = false;
boolean showquit = false;

int selectedSlot = -1;
int playpopuptimer = 0;
int earnpopuptimer = 0;

String item;

StatBar healthbar       = new StatBar(99,   66.15f,  180, 14);
StatBar happinessbar    = new StatBar(129.25f, 101.5f, 180, 14);
StatBar energybar       = new StatBar(99,   136.15f, 180, 14);
StatBar sicknessriskbar = new StatBar(189.2f,170.555f,180, 14);
StatBar hungerbar       = new StatBar(99,   206.15f, 180, 14);

// Fade for the main screen
int fadeInOpacity2 = 255;

// Game progression + economy
int   day   = 1;
float money = 0;

//Thinking of food animation
PImage cloudframe1, cloudframe2, cloudframe3;
int cloudframecounter=0;

// Main pet object
Pet alligator;


// =========================
// Main Screen Rendering
// Draws background, pet sprite, UI buttons, HUD text, stat bars, and fade-in overlay
// =========================
void mainscreen() {
  imageMode(CORNER);
  // Once we reach the main screen, naming flow is no longer active
  inNaming = false;
  if (!onchoicescreen) onmainscreen = true;
  // Background + character
  image(mainscreen, 0, 0, width, height);
  if (sick) {
    alligator.sickmood();
  } else if (alligator.hunger>80) {
    alligator.hungrymood();
  } else if (alligator.energy>80) {
    alligator.energeticmood();
  } else {
    alligator.neutralmood();
  }
  
  // UI layer (buttons + panels)
  image(mainscreenbuttons, 0, height * 0.52f, 1000, 600);
  image(achievementsbutton, width * 0.806f, height * 0.21f, 320, 190);
  image(settingsbutton, width * 0.83655f, -35, 248, 168);
  image(earnbutton, width * 0.845f, height * 0.075f, 231, 177);

  // HUD (money + day counter)
  textFont(arcade);
  textAlign(RIGHT, CENTER);
  fill(255);
  text("$" + String.format("%03.2f", money) + "   " + "Day " + day, width * 0.9f, height * 0.061f);

  // Stat bar display
  stroke(0);
  statbars();
  imageMode(CORNER);
  
  if (fedsteak==false) {
    cloudframecounter++;
    if (cloudframecounter >= 30) cloudframecounter = 0;
    if (cloudframecounter < 10) {
      image(cloudframe1, width*0.48f, height*0.35f);
    } else if (cloudframecounter < 20) {
      image(cloudframe2, width*0.48f, height*0.35f);
    } else {
      image(cloudframe3, width*0.48f, height*0.35f);
    }
      imageMode(CENTER);
      image(steak,632,326,steak.width/8,steak.height/8);
  }
  
    if (welcomepopupvisible) {
    image(popupbackground,width/2,height*0.42f,popupbackground.width*0.6f,popupbackground.height*0.6f);
    fill(0);
    textFont(times50);
    textSize(20);
    drawWrappedTextInBox("Welcome to your first day of alligator pet care! It seems like " + alligator.petName + " is already hungry! Head to your inventory after closing this window to feed him the food you were given at the adoption center!", 338, 271, 761, 400,6);
  }
  if (firstinventoryclick==false || (storeclicked==false && firstbuymedicine && !inventoryvisible && !firstmedicinegiven)) {
    redarrow(239.5f, 500, "down");
  }
  if (showplayarrow) {
      redarrow(656, 500, "down");
    }
     if ((earnpopupshown || showearnpopup) && earnclicked==false && !firstearnclick) {
      redarrow(940, 134, "right");
    }
    
     if (bankpopupshown && !firstbankclick) {
      redarrow(861, 500, "down");
    }
    if (treatmentpopupshown && !storeclicked && !firstbuymedicine) redarrow(337, 500, "down");

    
  if (inventoryvisible==true) inventory();
  

    
    if (fedsteak && !playpopupShown && !showplaypopup) {
    playpopuptimer++;
    if (playpopuptimer > 60 && alligator.energy>80) {
      showplaypopup = true;
      showplayarrow = true;
    }
  }
    
    if (alligator.energy<80 && playpopupShown) {
      firstenergystabalized=true;
    }
    
    if (alligator.energy<80 && firstenergystabalized) {
      showplayarrow=false;
    }
    
    if (showplaypopup) {
      playpopup();
    }
    
  
    if (firstenergystabalized && exit && !earnpopupshown) {
      earnpopuptimer++;
      if (earnpopuptimer>60) {
        showearnpopup=true;
      }
    }
    
    if (showearnpopup && !inventoryvisible ) earnpopup();
    

  
    if (earnclicked) earn();
    
    if (job.equals("cashier") && !jobpopupshown && !showjobpopup && !earnJobFinderOpen && !earnTasksOpen) {
      showjobpopup = true;
    }

   if (earnclicked && !earnJobFinderOpen && !earnTasksOpen && job.equals("unemployed")) {
      redarrow(155, 455, "right");
    }
    
    if (showfirsthelppopup) {
      help();
    }
    if (firsthelppopupshown && !servicesclicked && !firstservicesclick) redarrow(760, 502, "down");
    if (servicesclicked && !vetclicked) {
       services();
    }
    
    if (!earnJobFinderOpen && job.equals("cashier") && !jobpopupshown) {
      jobpopup();
    } 
    
    if (jobpopupshown && !firsttasktabclick && !earnJobFinderOpen && !job.equals("unemployed")) {
        redarrow(529, 455, "right");
    }
      
    
    if (vetclicked) vet();
    
    if (showtreatmentpopup) treatmentpopup();
    
    if (storeclicked) store();
    
    if (firstmedicinegiven && !bankpopupshown) {
      bankpopup();
      showbankpopup=true;
    }

    
    if (bankclicked) bank();
    
    if (firstbankview && !restpopupshown) {
      showrestpopup = true;
      restpopup();
    }
    
    if (restpopupshown && !restclicked && !firstalligatorrest) {
      redarrow(439,500,"down");
    }
    
    if (restclicked) rest();
    
    if (firstalligatorrest && !firstachievementsclick) redarrow(940, 231, "right");
    
    if (achievementsclicked) achievements();
    
    if (money>=highestMoneyBalance) highestMoneyBalance = money;
    
    if (showstoreclosedpopup) storeclosedpopup();
    
    if (firstachievementsclosed && !firstnextdayclick) redarrow(width/2, 500, "down");
    
  if (nextdayclicked) {
    nextday();
  }
  
  if (showquit) {
    quitpopup();
  }
    
  // Fade-in overlay (starts black, fades away)
  fill(0, fadeInOpacity2);

  if (fadeInOpacity2 > 0 && fadingout==false) {
    fadeInOpacity2--;
  } else if (playclicked==true) {
    fadingout=true;
    fadeInOpacity2+=2;
    if (fadeInOpacity2>=255 && !exit) {
      play();
      onmainscreen=false;
    } else if (exit) {
      fadeInOpacity2=0;
    }
  } else {
    fadeInOpacity2 = 0;
  }

  rect(0, 0, width, height);
}


// =========================
// Stat Bar Display
// Draws labels and bar visuals for each pet stat
// =========================
void statbars() {

  textAlign(LEFT, CENTER);
  strokeWeight(2);
  // Section title
  textSize(27);
  text("Pet Statistics:", width * 0.015f, height * 0.05f);
  
  // -------------------------
  // Health (positive scale)
  // -------------------------
  textSize(20);
  text("Health:", width * 0.015f, height * 0.1f);

  StatBar healthbar = new StatBar(width * 0.09f, height * 0.0945f, 180, 14);
  healthbar.setValue(alligator.health);
  healthbar.drawpositive();

  // -------------------------
  // Happiness (positive scale)
  // -------------------------
  fill(255);
  text("Happiness:", width * 0.015f, height * 0.15f);

  StatBar happinessbar = new StatBar(width * 0.1175f, height * 0.145f, 180, 14);
  happinessbar.setValue(alligator.happiness);
  happinessbar.drawpositive();

  // -------------------------
  // Energy (peaks midrange)
  // -------------------------
  fill(255);
  text("Energy:", width * 0.015f, height * 0.2f);

  StatBar energybar = new StatBar(width * 0.09f, height * 0.1945f, 180, 14);
  energybar.setValue(alligator.energy);
  energybar.drawenergyscale();

  // -------------------------
  // Risk of Sickness (negative scale)
  // -------------------------
  fill(255);
  text("Risk of Sickness:", width * 0.015f, height * 0.25f);

  StatBar sicknessriskbar = new StatBar(width * 0.172f, height * 0.24365f, 180, 14);
  sicknessriskbar.setValue(alligator.sickrisk);
  sicknessriskbar.drawnegative();

  // -------------------------
  // Hunger (negative scale)
  // -------------------------
  fill(255);
  text("Hunger:", width * 0.015f, height * 0.3f);

  StatBar hungerbar = new StatBar(width * 0.09f, height * 0.2945f, 180, 14);
  hungerbar.setValue(alligator.hunger);
  hungerbar.drawnegative();
}


// =========================
// StatBar Class
// Draws a filled bar based on a 0–100 value with different color schemes
// =========================
class StatBar {
  
  float x, y, w, h;
  float value = 100;
  
  StatBar(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  // Clamp stat values to the expected range
  void setValue(float v) {
    value = constrain(v, 0, 100);
  }

  // -------------------------
  // Positive Scale:
  // High value = green, low value = red
  // -------------------------
  void drawpositive() {

    fill(50);
    rect(x, y, w, h, 4);

    if (value >= 90) {
      fill(0, 200, 100);
    } else if (value >= 70) {
      fill(182, 232, 35);
    } else if (value >= 50) {
      fill(227, 220, 0);
    } else if (value >= 40) {
      fill(227, 155, 0);
    } else {
      fill(201, 8, 8);
    }

    rect(x, y, map(value, 0, 100, 0, w), h, 4);
  }

  // -------------------------
  // Negative Scale:
  // High value = red (bad), low value = green (good)
  // -------------------------
  void drawnegative() {

    fill(50);
    rect(x, y, w, h, 4);

    if (value >= 90) {
      fill(201, 8, 8);
    } else if (value >= 70) {
      fill(227, 155, 0);
    } else if (value >= 50) {
      fill(227, 220, 0);
    } else if (value >= 40) {
      fill(182, 232, 35);
    } else {
      fill(0, 200, 100);
    }
    rect(x, y, map(value, 0, 100, 0, w), h, 4);
  }

  // -------------------------
  // Energy Scale:
  // Mid-range = good, extremes = bad
  // -------------------------
  void drawenergyscale() {

    fill(50);
    rect(x, y, w, h, 4);

    if (value >= 80) {
      fill(201, 8, 8);
    } else if (value >= 70) {
      fill(182, 232, 35);
    } else if (value >= 40) {
      fill(0, 200, 100);
    } else if (value >= 20) {
      fill(182, 232, 35);
    } else {
      fill(201, 8, 8);
    }

    rect(x, y, map(value, 0, 100, 0, w), h, 4);
  }
}

void drawWrappedTextInBox(String sentence,
                          float leftX, float topY,
                          float rightX, float bottomY,
                          float extraSpacing) {

  float maxW = rightX - leftX;

  // Real font height (works with pixel fonts too)
  float lineH = textAscent() + textDescent() + extraSpacing;

  float y = topY;
  String[] words = splitTokens(sentence, " ");
  String line = "";

  textAlign(LEFT, TOP);

  for (int i = 0; i < words.length; i++) {
    String testLine = (line.length() == 0) ? words[i] : line + " " + words[i];

    if (textWidth(testLine) <= maxW) {
      line = testLine;
    } else {
      // Draw current line if it fits
      if (y + (textAscent() + textDescent()) > bottomY) return;
      text(line, leftX, y);

      y += lineH;
      line = words[i];
    }
  }

  // Draw last line if it fits
  if (line.length() > 0) {
    if (y + (textAscent() + textDescent()) > bottomY) return;
    text(line, leftX, y);
  }
}

String[] inventoryslots = {
  "Steak", "EMPTY", "EMPTY", "EMPTY",
  "EMPTY", "EMPTY", "EMPTY", "EMPTY",
  "EMPTY", "EMPTY", "EMPTY", "EMPTY"
};

int slotsfilled = 0;

boolean inventoryHasRoomFor(String item) {
  for (int i = 0; i < inventoryslots.length; i++) {
    if (inventoryslots[i].equals("EMPTY") || inventoryslots[i].equals(item)) {
      return true;
    }
  }
  return false;
}

int[] defaultQtys = {
  2, // Enrofloxacin
  3, // Doxycycline
  3, // Oseltamivir
  3, // Vitamin B-Complex
  2, // Cyproheptadine
  2, // Potassium Chloride
  2, // Coenzyme Q10
  4, // Fluoxetine
  3, // Trazodone
  2, // Meloxicam
  3, // Calcium Carbonate
  1  // Activated Charcoal
};

int[] medQtys = {
  0,0,0,0,0,0,0,0,0,0,0,0
};

int[] snackQtys = {
  0,0,0,0,0,0,0,0,0,0,0,0
};

 void inventory() {
  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80,220);
  rect(110, 122.5f, 990, 572.5f); // Box
  noFill();
  rect(933,132,976,171.5f); // X box
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X",942,151.75f);
  fill(169);
  line(width/2,182,width/2,572.5f); // Middle of box
  line(110,182,990,182); // Line enclosing text

  float[] xs = {110, 256.66f, 403.32f, width/2};
  float[] ys = {182, 279.625f, 377.25f, 474.875f, 572.5f};

  noFill();
  stroke(169);
  strokeWeight(5);
  strokeCap(SQUARE);

  for (int i = 0; i < xs.length; i++) {
    line(xs[i], ys[0], xs[i], ys[ys.length-1]);
  }
  for (int j = 0; j < ys.length; j++) {
    line(xs[0], ys[j], xs[xs.length-1], ys[j]);
  }

  slotsfilled = 0;
  for (String slots : inventoryslots) {
    if (!slots.equals("EMPTY")) {
      slotsfilled++;
    }
  }

  if (selectedSlot >= 0 && selectedSlot < inventoryslots.length) {
    if (!inventoryslots[selectedSlot].equals("EMPTY")) {
      fill(0,255,0,65);
      rect(585.125f,474.875f,760,546);
      textAlign(CENTER);
      fill(255);
      textSize(40);
      text("FEED",672.5625f,522.5f);
      

      fill(255,0,0,65);
      rect(780,474.875f,954.875f,546);
      fill(255);
      text("SELL",867.4375f,522.5f);
    } else {
      textAlign(CENTER);
      fill(255);
      textSize(30);
      text("No Item Selected",770,335);
      textSize(20);
      text("Select an item or head to ",770,370);
      text("the store to buy one!",770,390);
    } 
} else {
    textAlign(CENTER);
    fill(255);
    textSize(30);
    text("No Item Selected",770,335);
    textSize(20);
    text("Select an item or head to ",770,370);
    text("the store to buy one!",770,390);
  }

  if (selectedSlot >= 0 && selectedSlot < inventoryslots.length) {
    int r = selectedSlot / 3;
    int c = selectedSlot % 3;

    float x1 = xs[c], x2 = xs[c+1];
    float y1 = ys[r], y2 = ys[r+1];

    float o = 1;
    stroke(255);

    line(x1 - o, y1,     x2 + o, y1);
    line(x1 - o, y2,     x2 + o, y2);
    line(x1,     y1 - o, x1,     y2 + o);
    line(x2,     y1 - o, x2,     y2 + o);
  }

  rectMode(CORNER);
  strokeWeight(1);
  textAlign(CENTER);
  fill(255);
  textSize(35);
  text("INVENTORY:", width/2, height*0.235f);

  imageMode(CENTER);

  // draw items in their slot
  for (int i = 0; i < inventoryslots.length; i++) {
    if (!inventoryslots[i].equals("EMPTY")) {
      int row = i / 3;
      int col = i % 3;

      float slotX1 = xs[col];
      float slotX2 = xs[col + 1];
      float slotY1 = ys[row];
      float slotY2 = ys[row + 1];

      float steakX = slotX1 + 70;
      float steakY = slotY1 + 51;
      float qtyX   = slotX1 + 110;
      float qtyY   = slotY1 + 86;

      float medX = (slotX1 + slotX2) / 2;
      float medY = (slotY1 + slotY2) / 2;

      String slotItem = inventoryslots[i];
      int medIdx   = indexOf(medicinestock, slotItem);
      int snackIdx = indexOf(snackstock, slotItem);
      int meatIdx  = indexOf(meatstock, slotItem);

      if (slotItem.equals("Steak") && !fedsteak) {
        image(steak, steakX, steakY, steak.width/7, steak.height/7);
        textSize(30);
        fill(255);
        text("x1", qtyX, qtyY);

      } else if (medIdx >= 0) {
        image(medicine, medX, medY, medicine.width/14, medicine.height/14);
        fill(255);
        textSize(30);
        text("x" + medQtys[medIdx], qtyX, qtyY);

      } else if (snackIdx >= 0) {
        image(snackImages[snackIdx], medX, medY + snackOffsetY[snackIdx],
              snackImages[snackIdx].width/snackScales[snackIdx],
              snackImages[snackIdx].height/snackScales[snackIdx]);
        fill(255);
        textSize(30);
        text("x" + snackQtys[snackIdx], qtyX, qtyY);

      } else if (meatIdx >= 0) {
        image(meatImages[meatIdx], medX, medY,
              meatImages[meatIdx].width/8, meatImages[meatIdx].height/8);
        fill(255);
        textSize(30);
        text("x" + meatQtys[meatIdx], qtyX, qtyY);
      }
    }
  }

  if (selectedSlot != -1 && selectedSlot < inventoryslots.length) {
    String selectedItem = inventoryslots[selectedSlot];

    textAlign(CENTER);
    fill(255);

    if (selectedItem.equals("Steak") && !fedsteak) {
      textSize(30);
      text("Steak",770,233);
      textSize(20);
      text("The dream of any pet, having",770,406);
      text("no potential negative effects.",770,436);
      text("-70 Hunger     +40 Energy",770,258);
      imageMode(CENTER);
      image(steak,770,333,steak.width/4,steak.height/4);
      imageMode(CORNER);

    } else if (selectedItem.equals("Enrofloxacin")) {
      textSize(30);
      text("Enrofloxacin",770,233);
      textSize(20);
      text("Pet with an infection? Give 1 pill daily",770,406);
      text("for 2 days. Or your pet dies.",770,436);
      if (enrofloxacinPresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Doxycycline")) {
      textSize(30);
      text("Doxycycline",770,233);
      textSize(20);
      text("Pet with a cold? Give 1 pill daily",770,406);
      text("for 3 days. Or your pet dies.",770,436);
      if (doxycyclinePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Oseltamivir")) {
      textSize(30);
      text("Oseltamivir",770,233);
      textSize(20);
      text("Pet with a flu? Give 1 pill daily",770,406);
      text("for 3 days.",770,436);
      if (oseltamivirPresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Vitamin B-Complex")) {
      textSize(30);
      text("Vitamin B-Complex",770,233);
      textSize(20);
      text("Pet malnourished? Give 1 pill daily",770,406);
      text("for 3 days.",770,436);
      if (vitaminBComplexPresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Cyproheptadine")) {
      textSize(30);
      text("Cyproheptadine",770,233);
      textSize(20);
      text("Pet is starving? Give 1 pill daily",770,406);
      text("for 2 days.",770,436);
      if (cyproheptadinePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Potassium Chloride")) {
      textSize(30);
      text("Potassium Chloride",770,233);
      textSize(20);
      text("Pet has low energy? Give 1 pill daily",770,406);
      text("for 2 days.",770,436);
      if (potassiumChloridePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Coenzyme Q10")) {
      textSize(30);
      text("Coenzyme Q10",770,233);
      textSize(20);
      text("Pet exhausted? Give 1 pill daily",770,406);
      text("for 2 days.",770,436);
      if (coenzymeQ10Presc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Fluoxetine")) {
      textSize(30);
      text("Fluoxetine",770,233);
      textSize(20);
      text("Pet depressed? Give 1 pill daily",770,406);
      text("for 4 days.",770,436);
      if (fluoxetinePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Trazodone")) {
      textSize(30);
      text("Trazodone",770,233);
      textSize(20);
      text("Pet stressed? Give 1 pill daily",770,406);
      text("for 3 days.",770,436);
      if (trazodonePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Meloxicam")) {
      textSize(30);
      text("Meloxicam",770,233);
      textSize(20);
      text("Pet injured? Give 1 pill daily",770,406);
      text("for 2 days.",770,436);
      if (meloxicamPresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Calcium Carbonate")) {
      textSize(30);
      text("Calcium Carbonate",770,233);
      textSize(20);
      text("Pet has weak bones? Give 1 pill daily",770,406);
      text("for 3 days.",770,436);
      if (calciumCarbonatePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Activated Charcoal")) {
      textSize(30);
      text("Activated Charcoal",770,233);
      textSize(20);
      text("Pet is food poisoned? Give 1 pill",770,406);
      text("immediately to remove toxins.",770,436);
      if (activatedCharcoalPresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Nachos")) {
      textSize(30);
      text("Nachos",770,233);
      textSize(20);
      text("Messy cheesy chips with heavy seasoning.",770,406);
      text("Tasty, but definitely not healthy.",770,436);
      textSize(15);
      text("-40 Hunger   -15 Health   +5 Happiness   +30 Energy",770,258);
      image(nachos,770,333,nachos.width/6,nachos.height/6);
      imageMode(CORNER);

    } else if (selectedItem.equals("Cheesepuffs")) {
      textSize(30);
      text("Cheesepuffs",770,233);
      textSize(20);
      text("Crunchy cheese puffs packed with salt",770,406);
      text("and artificial flavoring.",770,436);
      textSize(15);
      text("-25 Hunger   -5 Health   +20 Happiness   +10 Energy",770,258);
      image(cheesepuffs,770,333,cheesepuffs.width/6,cheesepuffs.height/6);
      imageMode(CORNER);

    } else if (selectedItem.equals("Chips")) {
      textSize(30);
      text("Chips",770,233);
      textSize(20);
      text("Crispy potato chips loaded with oil",770,406);
      text("and sodium.",770,436);
      textSize(15);
      text("-30 Hunger   -10 Health   +10 Happiness   +10 Energy",770,258);
      image(chips,770,333,chips.width/5,chips.height/5);
      imageMode(CORNER);

    } else if (selectedItem.equals("Chocolate Bar")) {
      textSize(30);
      text("Chocolate Bar",770,233);
      textSize(20);
      text("Sugary chocolate bar with lots of",770,406);
      text("processed sweeteners.",770,436);
      textSize(15);
      text("-7 Hunger   -5 Health   +20 Happiness   +5 Energy",770,258);
      image(chocolatebar,770,333,chocolatebar.width/9,chocolatebar.height/9);
      imageMode(CORNER);

    } else if (selectedItem.equals("Cookies")) {
      textSize(30);
      text("Cookies",770,233);
      textSize(20);
      text("Sweet baked cookies full of sugar",770,406);
      text("and refined carbs.",770,436);
      textSize(15);
      text("-30 Hunger   -5 Health   +10 Happiness   +5 Energy",770,258);
      image(cookies,770,333,cookies.width/5,cookies.height/5);
      imageMode(CORNER);

    } else if (selectedItem.equals("Crackers")) {
      textSize(30);
      text("Crackers",770,233);
      textSize(20);
      text("Light crunchy crackers that are",770,406);
      text("salty and not very filling.",770,436);
      textSize(15);
      text("-5 Hunger   +20 Energy",770,258);
      image(crackers,770,333,crackers.width/5,crackers.height/5);
      imageMode(CORNER);

    } else if (selectedItem.equals("Energy Drink")) {
      textSize(30);
      text("Energy Drink",770,233);
      textSize(20);
      text("Very high caffeine and sugar.",770,406);
      text("A terrible choice for a pet.",770,436);
      textSize(15);
      text("+20 Hunger   -35 Health   -10 Happiness   +70 Energy",770,258);
      image(energydrink,770,333,energydrink.width/9.5f,energydrink.height/9.5f);
      imageMode(CORNER);

    } else if (selectedItem.equals("Granola Bar")) {
      textSize(30);
      text("Granola Bar",770,233);
      textSize(20);
      text("A packaged granola bar that seems",770,406);
      text("healthy, but still processed.",770,436);
      textSize(15);
      text("-15 Hunger   -5 Health   +5 Happiness   +20 Energy",770,258);
      image(granolabar,770,333,granolabar.width/5,granolabar.height/5);
      imageMode(CORNER);

    } else if (selectedItem.equals("Popcorn")) {
      textSize(30);
      text("Popcorn",770,233);
      textSize(20);
      text("Buttery popcorn with lots of salt",770,406);
      text("and flavor dust.",770,436);
      textSize(15);
      text("-10 Hunger   -10 Health   +30 Happiness   +10 Energy",770,258);
      image(popcorn,770,333,popcorn.width/6,popcorn.height/6);
      imageMode(CORNER);

    } else if (selectedItem.equals("Pretzels")) {
      textSize(30);
      text("Pretzels",770,233);
      textSize(20);
      text("Twisty salty pretzels with lots of",770,406);
      text("sodium.",770,436);
      textSize(15);
      text("-10 Hunger   -5 Health   +5 Happiness   +15 Energy",770,258);
      image(pretzels,770,333,pretzels.width/4,pretzels.height/4);
      imageMode(CORNER);

    } else if (selectedItem.equals("Soda")) {
      textSize(30);
      text("Soda",770,233);
      textSize(20);
      text("Pure sugar and fizz.",770,406);
      text("Not suitable for an alligator.",770,436);
      textSize(15);
      text("+30 Hunger   -30 Health   +5 Happiness   +40 Energy",770,258);
      image(soda,770,333,soda.width/11,soda.height/11);
      imageMode(CORNER);

    } else if (selectedItem.equals("Trail Mix")) {
      textSize(30);
      text("Trail Mix",770,233);
      textSize(20);
      text("A snack mix with salty and sweet",770,406);
      text("bits all combined together.",770,436);
      textSize(15);
      text("-10 Hunger   -5 Health   +5 Happiness   +20 Energy",770,258);
      image(trailmix,770,333,trailmix.width/6.5f,trailmix.height/6.5f);
      imageMode(CORNER);

    } else if (selectedItem.equals("Bluegill")) {
      textSize(30);
      text("Bluegill",770,233);
      textSize(20);
      text("A nutritious freshwater fish with",770,406);
      text("solid protein and moderate fat.",770,436);
      textSize(15);
      text("-55 Hunger   +15 Health   +10 Happiness   +20 Energy",770,258);
      image(bluegill,770,333,bluegill.width/7,bluegill.height/7);
      imageMode(CORNER);

    } else if (selectedItem.equals("Bass")) {
      textSize(30);
      text("Bass",770,233);
      textSize(20);
      text("A filling fish meal packed with",770,406);
      text("protein and natural oils.",770,436);
      textSize(15);
      text("-60 Hunger   +20 Health   +10 Happiness   +25 Energy",770,258);
      image(bass,770,333,bass.width/7,bass.height/7);
      imageMode(CORNER);

    } else if (selectedItem.equals("Perch")) {
      textSize(30);
      text("Perch",770,233);
      textSize(20);
      text("A lean fish choice that's healthy",770,406);
      text("and easy to digest.",770,436);
      textSize(15);
      text("-50 Hunger   +20 Health   +5 Happiness   +15 Energy",770,258);
      image(perch,770,333,perch.width/7,perch.height/7);
      imageMode(CORNER);

    } else if (selectedItem.equals("Goldfish")) {
      textSize(30);
      text("Goldfish",770,233);
      textSize(20);
      text("A small prey-sized bite that gives",770,406);
      text("a quick little meal.",770,436);
      textSize(15);
      text("-30 Hunger   +5 Health   +15 Happiness   +10 Energy",770,258);
      image(goldfish,770,333,goldfish.width/7,goldfish.height/7);
      imageMode(CORNER);

    } else if (selectedItem.equals("Crab")) {
      textSize(30);
      text("Crab",770,233);
      textSize(20);
      text("Rich shellfish meat with minerals",770,406);
      text("and lots of flavor.",770,436);
      textSize(15);
      text("-50 Hunger   +25 Health   +20 Happiness   +15 Energy",770,258);
      image(crab,770,333,crab.width/7,crab.height/7);
      imageMode(CORNER);

    } else if (selectedItem.equals("Lamb Chop")) {
      textSize(30);
      text("Lamb Chop",770,233);
      textSize(20);
      text("A heavy red meat meal that is very",770,406);
      text("filling and energy dense.",770,436);
      textSize(15);
      text("-70 Hunger   +10 Health   +15 Happiness   +35 Energy",770,258);
      image(lambchop,770,333,lambchop.width/7,lambchop.height/7);
      imageMode(CORNER);

    } else if (selectedItem.equals("Pork Chop")) {
      textSize(30);
      text("Pork Chop",770,233);
      textSize(20);
      text("A hearty cut of pork with lots of",770,406);
      text("protein and fat.",770,436);
      textSize(15);
      text("-65 Hunger   +10 Health   +10 Happiness   +30 Energy",770,258);
      image(porkchop,770,333,porkchop.width/7,porkchop.height/7);
      imageMode(CORNER);

    } else if (selectedItem.equals("Steak")) {
      textSize(30);
      text("Steak",770,233);
      textSize(20);
      text("A premium meat cut that gives huge",770,406);
      text("nutrition and energy.",770,436);
      textSize(15);
      text("-80 Hunger   +20 Health   +20 Happiness   +40 Energy",770,258);
      image(steak,770,333,steak.width/7,steak.height/7);
      imageMode(CORNER);

    } else if (selectedItem.equals("Chicken")) {
      textSize(30);
      text("Chicken",770,233);
      textSize(20);
      text("Lean poultry meat that's balanced,",770,406);
      text("healthy, and reliable.",770,436);
      textSize(15);
      text("-60 Hunger   +20 Health   +10 Happiness   +20 Energy",770,258);
      image(chicken,770,333,chicken.width/7,chicken.height/7);
      imageMode(CORNER);

    } else if (selectedItem.equals("Catfish")) {
      textSize(30);
      text("Catfish",770,233);
      textSize(20);
      text("A dense fish meal with strong",770,406);
      text("protein and rich flavor.",770,436);
      textSize(15);
      text("-60 Hunger   +15 Health   +10 Happiness   +25 Energy",770,258);
      image(catfish,770,333,catfish.width/7,catfish.height/7);
      imageMode(CORNER);

    } else if (selectedItem.equals("Frog")) {
      textSize(30);
      text("Frog",770,233);
      textSize(20);
      text("A natural prey option that feels",770,406);
      text("especially satisfying to eat.",770,436);
      textSize(15);
      text("-45 Hunger   +15 Health   +25 Happiness   +20 Energy",770,258);
      image(frog,770,333,frog.width/7,frog.height/7);
      imageMode(CORNER);

    } else if (selectedItem.equals("Shrimp")) {
      textSize(30);
      text("Shrimp",770,233);
      textSize(20);
      text("A light seafood bite that boosts",770,406);
      text("health more than fullness.",770,436);
      textSize(15);
      text("-35 Hunger   +25 Health   +15 Happiness   +10 Energy",770,258);
      image(shrimp,770,333,shrimp.width/7,shrimp.height/7);
      imageMode(CORNER);
    }
  }

  if (showcantsell == true) cantsell();
  stroke(0);
}

 void cantsell() {
    imageMode(CENTER);
    image(popupbackground,width/2,height*0.42f,popupbackground.width*0.6f,popupbackground.height*0.6f);
    fill(0);
    textFont(times50);
    textSize(20);
  drawWrappedTextInBox("Careful! Selling your steak could leave " + alligator.petName + " starving, and that can be deadly. From here on out, financial decisions are yours. Choose wisely!", 338, 271, 761, 400, 6);
  }
  
 void playpopup() {
    imageMode(CENTER);
    image(popupbackground,width/2,height*0.42f,popupbackground.width*0.6f,popupbackground.height*0.6f);
    fill(0);
    textFont(times50);
    textSize(20);
    drawWrappedTextInBox("Uh oh! Feeding the steak to " + alligator.petName + " gave them too much energy. An alligator with too much energy is very dangerous! Let " + alligator.petName + " play after closing this window to stabalize their energy!", 338, 271, 761, 400, 6);
  }
  
float arrowOffset = 0;
boolean goingup = true;

 void redarrow(float arrowx, float arrowy, String direction) {
  imageMode(CENTER);

  float drawX = arrowx;
  float drawY = arrowy;

  if (direction.equals("right")) {
    drawX = arrowx + arrowOffset;
  } else {
    drawY = arrowy + arrowOffset;
  }

  pushMatrix();
  translate(drawX, drawY);

  if (direction.equals("right")) {
    rotate(-HALF_PI);
  }

  image(redarrow, 0, 0, redarrow.width/3, redarrow.height/3);
  popMatrix();

  if (goingup) {
    arrowOffset--;
    if (arrowOffset <= -25) {
      goingup = false;
    }
  } else {
    arrowOffset++;
    if (arrowOffset >= 0) {
      goingup = true;
    }
  }
}

 void earnpopup() {
    imageMode(CENTER);
    image(popupbackground,width/2,height*0.42f,popupbackground.width*0.6f,popupbackground.height*0.6f);
    fill(0);
    textFont(times50);
    textSize(20);
    drawWrappedTextInBox("Nice job stabilizing " + alligator.petName + "'s energy. As an owner, playing can get annoying, so you can use services to help with their needs! But services cost money. Click the earn button after closing this window!", 338, 271, 761, 400, 6);  
  }

PImage unemployed;
PImage cashier;
PImage barista;
PImage manager;
PImage town;
PImage cash;
PImage house;
PImage lock;

String job = "unemployed";

float salary = 0;
float taskmoney = 5;
float ptupgcost = 3;
float salupgcost = 3;
float taskupgcost = 3;

boolean maxcashiersalary=false;
boolean jobpopupshown = false;
boolean showjobpopup = false;
boolean helpclicked = false;

boolean earnJobFinderOpen = false;
boolean earnTasksOpen = false;

 void earn() {
  if (earnJobFinderOpen) {
    earnJobFinder();
    return;
  }

  if (earnTasksOpen) {
    earnTasksUpgrades();
    return;
  }

  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80,220);
  rect(110, 122.5f, 990, 572.5f);

  if (!job.equals("unemployed")) {
    fill(255,0,0,65);
  }

  rectMode(CENTER);
  rect(816,206,100,100);

  textAlign(CENTER);
  fill(255);
  line(110,275,990,275);

  textSize(40);
  text("QUIT", 816, 200);
  text("JOB", 816, 240);

  textSize(25);
  text("CURRENT JOB:", width/2,164.5f);

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
    if (day>=25) {
    text("Next Job: Manager is available!", 129, 253);
    } else if (day>=10) {
    text("Next Job: Barista is available!", 129, 253);
    } else {
    text("Next Job: Cashier is available!", 129, 253);
    }
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
    text("Total Job Earnings: Later", 129, 231);
    if (day<10) {
    text("Next Job: Barista on Day 10", 129, 253);
    } else if (day<25){
    text("Next Job: Barista is avalible!", 129, 253);
    } else {
    text("Next Job: Cafe Manager is avalible!", 129, 253);
    }
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
    text("Total Job Earnings: Later", 129, 231);
    if (day<25) {
    text("Next Job: Cafe Manager on Day 25", 129, 253);
    } else {
    text("Next Job: Cafe Manager is avalible!", 129, 253);
    }
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
    text("Total Job Earnings: Later", 129, 231);
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

  fill(80,220);
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
  rect(933,132,976,171.5f);
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X",942,151.75f);



  rectMode(CORNER);
  stroke(0);
}

 void earnJobFinder() {
  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80,220);
  rect(180, 145, 920, 518);

  line(180, 205, 920, 205);

  textAlign(CENTER, CENTER);
  fill(255);
  textSize(35);
  text("JOB FINDER:", 550, 175);

  noFill();
  rect(863,155,906,194.5f);
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X",872,174.75f);

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
  text("Unlocks on day 10", 550, 447);
  
  text("Run the cafe,", 800, 347);
  text("manage staff,", 800, 360);
  text("ensure efficiency.", 800, 373);
  text("Base Salary:", 800, 397);
  text("$75/day", 800, 410);
  text("Status:", 800, 434);
  text("Unlocks on day 25", 800, 447);
  
  rectMode(CENTER);
  stroke(255);
  strokeWeight(2);
  textSize(17);
  
  if (job.equals("unemployed")) fill(0,255,0,80);
  else fill(80,220);
  rect(300, 487, 80, 20);
  fill(255);
  text("APPLY", 300, 487);
  
  if (job.equals("unemployed") && day >= 10) {
    fill(0,255,0,80);
  } else {
    fill(80,220);
    if (day<10) image(lock,550,287,lock.width/12, lock.height/12);
  }
  rect(550, 487, 80, 20);
  fill(255);
  text("APPLY", 550, 487);
  
  if (job.equals("unemployed") && day >= 25) {
    fill(0,255,0,80);
  } else {
    fill(80,220);
    if (day<25) image(lock,800,287,lock.width/12, lock.height/12);
  }
  rect(800, 487, 80, 20);
  fill(255);
  text("APPLY", 800, 487);
  
  if (job.equals("unemployed")) {
    redarrow(216, 482, "right");
  }

  rectMode(CORNER);
  stroke(0);
}

void earnTasksUpgrades() {
  rectMode(CORNERS);
  stroke(169);
  strokeWeight(5);
  fill(80,220);
  rect(210, 145, 890, 470);

  line(210, 205, 890, 205);
  line(550, 205, 550, 470);

  textAlign(CENTER, CENTER);
  fill(255);
  textSize(35);
  text("TASKS & UPGRADES:", 550, 175);

  noFill();
  rect(833,155,876,194.5f);
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X",842,174.75f);

  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(25);
  text("Help Around Town:", 380, 240);
  text("Upgrades:", 720, 240);

  image(town,380,320,town.width/6,town.height/6);

  textSize(12);
  text("Run community errands for", 380, 362);
  text("quick cash with the risk", 380, 375);
  text("of your alligator's stats", 380, 388);
  text("changing due to your absence.", 380, 401);

  rectMode(CENTER);
  fill(255,127,0);
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
  text("Current:" , 615, 320);
  text("Current:" , 720, 320);
  text("Current:", 825, 320);
  text("$" + nf(moneyperpt,0,2) + "/pt", 615, 333);
  text("$" + nf(salary,0,2) + "/day", 720, 333);
  text("$" + nf(taskmoney,0,2) + "/task", 825, 333);
  
  text("Upgrade:", 615, 359);
  if (moneyperpt == 0) {
    text("$0.10/pt", 615, 372);
  } else {
    text("$" + nf(moneyperpt*1.2f,0,2) + "/pt", 615, 372);
  }

  text("Upgrade:", 720, 359);
  if (job.equals("cashier")) {
    if (salary >= 32 || salary * 1.12f >= 32) {
      text("MAXED", 720, 372);
    } else {
      text("$" + nf(salary * 1.12f, 0, 2) + "/day", 720, 372);
    }
  } else if (job.equals("barista")) {
    if (salary >= 70 || salary * 1.12f >= 70) {
      text("MAXED", 720, 372);
    } else {
      text("$" + nf(salary * 1.12f, 0, 2) + "/day", 720, 372);
    }
  } else {
    text("$" + nf(salary * 1.12f, 0, 2) + "/day", 720, 372);
  }
  
  text("BUY:", 615, 402);
  text("BUY:", 720, 402);
  text("BUY:", 825, 402);
  
  text("Upgrade:", 825, 359);
  text("$" + nf(taskmoney*1.12f,0,2) + "/task", 825, 372);

  textSize(13);
  if (money >= ptupgcost) fill(0,255,0,80);
  else fill(80,220);
  rect(615, 420, 80, 20);
  fill(255);
  text("$" + nf(ptupgcost,0,2), 615, 420);

  if (!job.equals("unemployed") && money >= salupgcost &&
      !(job.equals("cashier") && (salary >= 32 || salary * 1.12f >= 32)) &&
      !(job.equals("barista") && (salary >= 70 || salary * 1.12f >= 70))) {
    fill(0,255,0,80);
  } else {
    fill(80, 220);
  }
  rect(720, 420, 80, 20);
  fill(255);
  if (job.equals("cashier") && (salary >= 32 || salary * 1.12f >= 32)) {
    text("MAXED", 720, 420);
  } else if (job.equals("barista") && (salary >= 70 || salary * 1.12f >= 70)) {
    text("MAXED", 720, 420);
  } else if (job.equals("unemployed")) {
    text("N/A", 720, 420);
  } else {
    text("$" + nf(salupgcost,0,2), 720, 420);
  }

  if (money >= taskupgcost) fill(0,255,0,80);
  else fill(80,220);
  rect(825, 420, 80, 20);
  fill(255);
  text("$" + nf(taskupgcost,0,2), 825, 420);

  if (jobpopupshown && !helpclicked && earnTasksOpen) {
    redarrow(261, 429, "right");
  }

  rectMode(CORNER);
  stroke(0);
}

void jobpopup() {
    imageMode(CENTER);
    image(popupbackground,width/2,height*0.42f,popupbackground.width*0.6f,popupbackground.height*0.6f);
    fill(0);
    textFont(times50);
    textSize(20);
    drawWrappedTextInBox("Congrats on becoming a cashier! You now earn a daily salary. In this tab you can upgrade it, earn money when " + alligator.petName + " plays, or help around town for extra cash. Close this window and try helping out!", 338, 271, 761, 400, 6);
}

boolean firsthelppopupshown = false;
boolean showfirsthelppopup = false;
String helppopuptext = "";
boolean firstLowQualityCareAlwaysSucceeds = true;

void help() {
    imageMode(CENTER);
    image(popupbackground,width/2,height*0.42f,popupbackground.width*0.6f,popupbackground.height*0.6f);
    fill(0);
    textFont(times50);
    textSize(20);
    drawWrappedTextInBox(helppopuptext, 338, 271, 761, 400, 6);
}

boolean servicesclicked = false;
boolean vetclicked = false;

PImage vet;
PImage walker;
PImage cleaner;

void services() {
 rectMode(CORNERS);
 stroke(169);
 strokeWeight(5);
 fill(80,220);
 rect(110, 122.5f, 990, 572.5f); 
 textAlign(CENTER, CENTER);
 fill(255);
 textSize(35);
 text("SERVICES:", width/2,height*0.235f);
 textSize(25);
 imageMode(CENTER);
 text("Vet:", 256.67f, 200);
 text("Walker:", 550, 200);
 text("Cleaner:", 843.33f, 200);
 
 rectMode(CENTER);
 fill(0,255,0,80);
 rect(256.67f, 520, 160, 40);
 if (money<10) fill(169,80);
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
 text("in order to stabalize", 575, 448);
 text("energy while increasing", 575, 463);
 text("health and happiness.", 575, 478);
 
 image(cleaner, 830, 310, cleaner.width/3.8f, cleaner.height/3.8f);
 text("A walker will take", 843.33f, 418);
 text("your pet on a walk", 843.33f, 433);
 text("in order to stabalize", 843.33f, 448);
 text("energy while increasing", 843.33f, 463);
 text("health and happiness.", 843.33f, 478);
 noFill();
 rectMode(CORNERS);
 rect(933,132,976,171.5f); //X box
 textAlign(LEFT, CENTER);
 textSize(40);
 fill(255);
 text("X",942,151.75f);
 rectMode(CORNER);
 stroke(0);
 strokeWeight(2);
 if (!lowqualitycaregiven) redarrow(122,520, "right");
}

boolean lowqualitycaregiven=false;

void vet() {
 imageMode(CENTER);
 rectMode(CORNERS);
 stroke(169);
 strokeWeight(5);
 fill(80,220);
 rect(330, 222.5f, 770, 472.5f); 
 textAlign(CENTER, CENTER);
 fill(255);
 textSize(35);
 text("THE VET:", width/2,height*0.235f+100);
 textSize(25);
 text("3 Star Vet:", 440, 294);
 image(vet, 440, 347, vet.width/3.75f, vet.height/3.75f);
 text("5 Star Vet:", 660, 294);
 image(vet, 660, 347, vet.width/3.75f, vet.height/3.75f);
 textSize(15);
 text("Treat " + alligator.petName + "'s " + sickness, 440, 389);
 text("for $5.", 440, 402);
 text("Treat " + alligator.petName + "'s " + sickness, 660, 389);
 text("for $20.", 660, 402);
 if (money>=5) {
   fill(0,255,0,80);
 } else {
   fill(169, 80);
 }
 rectMode(CENTER);
 rect(440, 435, 120, 30);
 if (money<20) fill(169, 80);
 rect(660, 435, 120, 30);
 fill(255);
 textSize(20);
 text("TREAT", 440, 435);
 text("TREAT", 660, 435);
 noFill();
 rectMode(CORNERS);
 rect(713,232,756,271.5f); //X box
 textAlign(LEFT, CENTER);
 textSize(40);
 fill(255);
 text("X",722,251.75f);
 rectMode(CORNER);
 stroke(0);
 strokeWeight(2);
 if (!lowqualitycaregiven) redarrow(330, 435, "right");
}

boolean showtreatmentpopup=false;
boolean treatmentpopupshown=false;
boolean lowQualityVetFailedPopup = false;
String treatmentPopupMessage = "";

void treatmentpopup() {
  imageMode(CENTER);
    image(popupbackground,width/2,height*0.42f,popupbackground.width*0.6f,popupbackground.height*0.6f);
    fill(0);
    textFont(times50);
    textSize(20);
    drawWrappedTextInBox(treatmentPopupMessage, 338, 271, 761, 400, 6);
}

boolean storeclicked = false;
boolean buymedicine = false;

String[] medicinestock = {
  "Enrofloxacin",
  "Doxycycline",
  "Oseltamivir",
  "Vitamin B-Complex",
  "Cyproheptadine",
  "Potassium Chloride",
  "Coenzyme Q10",
  "Fluoxetine",
  "Trazodone",
  "Meloxicam",
  "Calcium Carbonate",
  "Activated Charcoal"
};

boolean[] presc = new boolean[12];

void clearPrescriptionCourse() {
  for (int i = 0; i < presc.length; i++) {
    presc[i] = false;
  }

  activePrescriptionIndex = -1;
  treatmentDaysNeeded = 0;
  treatmentDaysCompleted = 0;
  lastTreatmentDay = -1;
}

void startPrescriptionCourse(int medIndex) {
  clearPrescriptionCourse();

  activePrescriptionIndex = medIndex;
  treatmentDaysNeeded = defaultQtys[medIndex];
  treatmentDaysCompleted = 0;
  lastTreatmentDay = -1;

  presc[medIndex] = true;
}


PImage storebackground;
PImage medicine;

boolean medicinebought=false;
boolean firstexitclick = false;

boolean buysnacks = false;

PImage nachos;
PImage cheesepuffs;
PImage chips;
PImage chocolatebar;
PImage cookies;
PImage crackers;
PImage energydrink;
PImage granolabar;
PImage popcorn;
PImage pretzels;
PImage soda;
PImage trailmix;

String[] snackstock = {
  "Nachos",
  "Cheesepuffs",
  "Chips",
  "Chocolate Bar",
  "Cookies",
  "Crackers",
  "Energy Drink",
  "Granola Bar",
  "Popcorn",
  "Pretzels",
  "Soda",
  "Trail Mix"
};

float[] snackCosts = {
  4.50f, // Nachos
  3.25f, // Cheesepuffs
  2.75f, // Chips
  2.50f, // Chocolatebar
  3.00f, // Cookies
  2.25f, // Crackers
  3.75f, // Energydrink
  2.50f, // Granolabar
  2.75f, // Popcorn
  2.25f, // Pretzels
  2.00f, // Soda
  3.50f  // Trailmix
};

boolean buymeat = false;

PImage chicken;
PImage catfish;
PImage frog;
PImage shrimp;

String[] meatstock = {
  "Bluegill",
  "Bass",
  "Perch",
  "Goldfish",
  "Crab",
  "Lamb Chop",
  "Pork Chop",
  "Steak",
  "Chicken",
  "Catfish",
  "Frog",
  "Shrimp"
};

float[] meatCosts = {
  6.00f, // Bluegill
  7.00f, // Bass
  6.50f, // Perch
  4.50f, // Goldfish
  8.00f, // Crab
  10.00f, // Lamb Chop
  9.00f, // Pork Chop
  11.00f, // Steak
  7.50f, // Chicken
  8.50f, // Catfish
  7.00f, // Frog
  6.50f  // Shrimp
};

int[] meatQtys = {
  0,0,0,0,0,0,0,0,0,0,0,0
};

// =========================
// Image arrays for snack/meat items (initialized in fileWork())
// =========================
PImage[] snackImages;
PImage[] meatImages;

// Scales and Y-offsets for snack grid display
float[] snackScales  = {9, 8, 8, 12, 6.5f, 7, 11.5f, 7, 8, 6, 14, 8};
float[] snackOffsetY = {0, 5, 10, 0, -2, 2, 0, 10, 1.5f, 3, 0, 6};

// =========================
// Item name/description arrays — used in both inventory and store detail panels
// =========================
String[] medicineNames = {
  "Enrofloxacin","Doxycycline","Oseltamivir","Vitamin B-Complex",
  "Cyproheptadine","Potassium Chloride","Coenzyme Q10","Fluoxetine",
  "Trazodone","Meloxicam","Calcium Carbonate","Activated Charcoal"
};
String[] medicineDesc1 = {
  "Pet with an infection? Give 1 pill daily",
  "Pet with a cold? Give 1 pill daily",
  "Pet with a flu? Give 1 pill daily",
  "Pet malnourished? Give 1 pill daily",
  "Pet is starving? Give 1 pill daily",
  "Pet has low energy? Give 1 pill daily",
  "Pet exhausted? Give 1 pill daily",
  "Pet depressed? Give 1 pill daily",
  "Pet stressed? Give 1 pill daily",
  "Pet injured? Give 1 pill daily",
  "Pet has weak bones? Give 1 pill daily",
  "Pet is food poisoned? Give 1 pill"
};
String[] medicineDesc2 = {
  "for 2 days. Or your pet dies.",
  "for 3 days. Or your pet dies.",
  "for 3 days.",
  "for 3 days.",
  "for 2 days.",
  "for 2 days.",
  "for 2 days.",
  "for 4 days.",
  "for 3 days.",
  "for 2 days.",
  "for 3 days.",
  "immediately to remove toxins."
};

String[] snackNames = {
  "Nachos","Cheesepuffs","Chips","Chocolate Bar","Cookies","Crackers",
  "Energy Drink","Granola Bar","Popcorn","Pretzels","Soda","Trail Mix"
};
String[] snackDesc1 = {
  "Messy cheesy chips with heavy seasoning.",
  "Crunchy cheese puffs packed with salt",
  "Crispy potato chips loaded with oil",
  "Sugary chocolate bar with lots of",
  "Sweet baked cookies full of sugar",
  "Light crunchy crackers that are",
  "Very high caffeine and sugar.",
  "A packaged granola bar that seems",
  "Buttery popcorn with lots of salt",
  "Twisty salty pretzels with lots of",
  "Pure sugar and fizz.",
  "A snack mix with salty and sweet"
};
String[] snackDesc2 = {
  "Tasty, but definitely not healthy.",
  "and artificial flavoring.",
  "and sodium.",
  "processed sweeteners.",
  "and refined carbs.",
  "salty and not very filling.",
  "A terrible choice for a pet.",
  "healthy, but still processed.",
  "and flavor dust.",
  "sodium.",
  "Not suitable for an alligator.",
  "bits all combined together."
};
String[] snackStats = {
  "-40 Hunger   -15 Health   +5 Happiness   +30 Energy",
  "-25 Hunger   -5 Health   +20 Happiness   +10 Energy",
  "-30 Hunger   -10 Health   +10 Happiness   +10 Energy",
  "-7 Hunger   -5 Health   +20 Happiness   +5 Energy",
  "-30 Hunger   -5 Health   +10 Happiness   +5 Energy",
  "-5 Hunger   +20 Energy",
  "+20 Hunger   -35 Health   -10 Happiness   +70 Energy",
  "-15 Hunger   -5 Health   +5 Happiness   +20 Energy",
  "-10 Hunger   -10 Health   +30 Happiness   +10 Energy",
  "-10 Hunger   -5 Health   +5 Happiness   +15 Energy",
  "+30 Hunger   -30 Health   +5 Happiness   +40 Energy",
  "-10 Hunger   -5 Health   +5 Happiness   +20 Energy"
};

String[] meatNames = {
  "Bluegill","Bass","Perch","Goldfish","Crab","Lamb Chop",
  "Pork Chop","Steak","Chicken","Catfish","Frog","Shrimp"
};
String[] meatDesc1 = {
  "A nutritious freshwater fish with",
  "A filling fish meal packed with",
  "A lean fish choice that's healthy",
  "A small prey-sized bite that gives",
  "Rich shellfish meat with minerals",
  "A heavy red meat meal that is very",
  "A hearty cut of pork with lots of",
  "A premium meat cut that gives huge",
  "Lean poultry meat that's balanced,",
  "A dense fish meal with strong",
  "A natural prey option that feels",
  "A light seafood bite that boosts"
};
String[] meatDesc2 = {
  "solid protein and moderate fat.",
  "protein and natural oils.",
  "and easy to digest.",
  "a quick little meal.",
  "and lots of flavor.",
  "filling and energy dense.",
  "protein and fat.",
  "nutrition and energy.",
  "healthy, and reliable.",
  "protein and rich flavor.",
  "especially satisfying to eat.",
  "health more than fullness."
};
String[] meatStats = {
  "-55 Hunger   +15 Health   +10 Happiness   +20 Energy",
  "-60 Hunger   +20 Health   +10 Happiness   +25 Energy",
  "-50 Hunger   +20 Health   +5 Happiness   +15 Energy",
  "-30 Hunger   +5 Health   +15 Happiness   +10 Energy",
  "-50 Hunger   +25 Health   +20 Happiness   +15 Energy",
  "-70 Hunger   +10 Health   +15 Happiness   +35 Energy",
  "-65 Hunger   +10 Health   +10 Happiness   +30 Energy",
  "-80 Hunger   +20 Health   +20 Happiness   +40 Energy",
  "-60 Hunger   +20 Health   +10 Happiness   +20 Energy",
  "-60 Hunger   +15 Health   +10 Happiness   +25 Energy",
  "-45 Hunger   +15 Health   +25 Happiness   +20 Energy",
  "-35 Hunger   +25 Health   +15 Happiness   +10 Energy"
};

// =========================
// indexOf helper — finds index of val in arr, returns -1 if not found
// =========================
int indexOf(String[] arr, String val) {
  for (int i = 0; i < arr.length; i++) if (arr[i].equals(val)) return i;
  return -1;
}

// =========================
// Store panel shared helpers
// =========================
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
// Item detail display helpers
// =========================
void drawItemDetail(String name, String desc1, String desc2, String statLine, PImage img, float scale) {
  textAlign(CENTER);
  textSize(30);
  text(name, 770, 233);
  textSize(20);
  text(desc1, 770, 406);
  text(desc2, 770, 436);
  textSize(15);
  text(statLine, 770, 258);
  imageMode(CENTER);
  image(img, 770, 333, img.width/scale, img.height/scale);
  imageMode(CORNER);
}

void drawMedicineDetail(int idx) {
  textAlign(CENTER);
  textSize(30);
  text(medicineNames[idx], 770, 233);
  textSize(20);
  text(medicineDesc1[idx], 770, 406);
  text(medicineDesc2[idx], 770, 436);
  if (presc[idx]) text("Prescribed: Yes", 770, 258);
  else text("Prescribed: No", 770, 258);
  imageMode(CENTER);
  image(medicine, 770, 333, medicine.width/9, medicine.height/9);
  imageMode(CORNER);
}

void drawSnackDetail(int idx) {
  drawItemDetail(snackNames[idx], snackDesc1[idx], snackDesc2[idx], snackStats[idx], snackImages[idx], snackScales[idx]);
}

void drawMeatDetail(int idx) {
  drawItemDetail(meatNames[idx], meatDesc1[idx], meatDesc2[idx], meatStats[idx], meatImages[idx], 7);
}

boolean canBuyMedicine;

void store(){
  
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
  fill(129,86,0);
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
  if (!firstbuymedicine && !buymedicine && !buysnacks && !buymeat) redarrow(545, 59, "right");
  
  if (buymedicine == true) {
    rectMode(CORNERS);
    stroke(169);
    strokeWeight(5);
    fill(80,220);
    rect(110, 122.5f, 990, 572.5f); //Box
    noFill();
    rect(933,132,976,171.5f); //X box
    textAlign(LEFT, CENTER);
    textSize(40);
    fill(255);
    text("X",942,151.75f);
    fill(169);
    line(width/2,182,width/2,572.5f); //Middle of box
    line(110,182,990,182); //Line enclosing text

    float[] xs = {110, 256.66f, 403.32f, width/2};
    float[] ys = {182, 279.625f, 377.25f, 474.875f, 572.5f};

    noFill();
    stroke(169);
    strokeWeight(5);
    strokeCap(SQUARE);

    for (int i = 0; i < xs.length; i++) line(xs[i], ys[0], xs[i], ys[ys.length-1]);
    for (int j = 0; j < ys.length; j++) line(xs[0], ys[j], xs[xs.length-1], ys[j]);
    canBuyMedicine = inventoryHasRoomFor(medicinestock[selectedSlot]) && (((!presc[selectedSlot] && money>=5) || presc[selectedSlot]));

    if (selectedSlot != -1) {
      if (((!presc[selectedSlot] && money>=5) || presc[selectedSlot]) && canBuyMedicine) {
        fill(0,255,0,65);
      } else {
        fill(169,80);
      }
      rect(682.5625f, 474.875f, 857.4375f, 546);
      textAlign(CENTER);
      fill(255);
      textSize(25);

      if (selectedSlot >= 0 && selectedSlot < presc.length && presc[selectedSlot]) {
        text("$5.00   $0.00",770,522.5f);
        stroke(255,0,0);
        line(692,514,769,514);
      } else {
        text("$5.00",770,522.5f);
      }

      int r = selectedSlot / 3;
      int c = selectedSlot % 3;

      float x1 = xs[c],   x2 = xs[c+1];
      float y1 = ys[r],   y2 = ys[r+1];

      float o = 1;
      stroke(255);

      line(x1 - o, y1,     x2 + o, y1);
      line(x1 - o, y2,     x2 + o, y2);
      line(x1,     y1 - o, x1,     y2 + o);
      line(x2,     y1 - o, x2,     y2 + o);

    } else {
      textAlign(CENTER);
      fill(255);
      textSize(30);
      text("No Item Selected",770,335);
      textSize(20);
      text("Select an item",770,370);
      text("and purchase it!",770,390);
    }

    rectMode(CORNER);
    strokeWeight(1);
    textAlign(CENTER);
    fill(255);
    textSize(35);
    text("MEDICINE:", width/2,height*0.235f);
    imageMode(CENTER);

    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 3; col++) {
        float x1 = xs[col];
        float x2 = xs[col + 1];
        float y1 = ys[row];
        float y2 = ys[row + 1];

        float cx = (x1 + x2) / 2;
        float cy = (y1 + y2) / 2;

        image(medicine, cx, cy, medicine.width/14, medicine.height/14);
      }
    }

    textSize(30);
    if (selectedSlot==0) {
      text("Enrofloxacin",770,233);
      textSize(20);
      text("Pet with an infection? Give 1 pill daily",770,406);
      text("for 2 days. Or your pet dies.",770,436);
      if (enrofloxacinPresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);

    } else if (selectedSlot==1) {
      text("Doxycycline",770,233);
      textSize(20);
      text("Pet with a cold? Give 1 pill daily",770,406);
      text("for 3 days. Or your pet dies.",770,436);
      if (doxycyclinePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);

    } else if (selectedSlot==2) {
      text("Oseltamivir",770,233);
      textSize(20);
      text("Pet with a flu? Give 1 pill daily",770,406);
      text("for 3 days.",770,436);
      if (oseltamivirPresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);

    } else if (selectedSlot==3) {
      text("Vitamin B-Complex",770,233);
      textSize(20);
      text("Pet malnourished? Give 1 pill daily",770,406);
      text("for 3 days.",770,436);
      if (vitaminBComplexPresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);

    } else if (selectedSlot==4) {
      text("Cyproheptadine",770,233);
      textSize(20);
      text("Pet is starving? Give 1 pill daily",770,406);
      text("for 2 days.",770,436);
      if (cyproheptadinePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);

    } else if (selectedSlot==5) {
      text("Potassium Chloride",770,233);
      textSize(20);
      text("Pet has low energy? Give 1 pill daily",770,406);
      text("for 2 days.",770,436);
      if (potassiumChloridePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);

    } else if (selectedSlot==6) {
      text("Coenzyme Q10",770,233);
      textSize(20);
      text("Pet exhausted? Give 1 pill daily",770,406);
      text("for 2 days.",770,436);
      if (coenzymeQ10Presc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);

    } else if (selectedSlot==7) {
      text("Fluoxetine",770,233);
      textSize(20);
      text("Pet depressed? Give 1 pill daily",770,406);
      text("for 4 days.",770,436);
      if (fluoxetinePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);

    } else if (selectedSlot==8) {
      text("Trazodone",770,233);
      textSize(20);
      text("Pet stressed? Give 1 pill daily",770,406);
      text("for 3 days.",770,436);
      if (trazodonePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);

    } else if (selectedSlot==9) {
      text("Meloxicam",770,233);
      textSize(20);
      text("Pet injured? Give 1 pill daily",770,406);
      text("for 2 days.",770,436);
      if (meloxicamPresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);

    } else if (selectedSlot==10) {
      text("Calcium Carbonate",770,233);
      textSize(20);
      text("Pet has weak bones? Give 1 pill daily",770,406);
      text("for 3 days.",770,436);
      if (calciumCarbonatePresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);

    } else if (selectedSlot==11) {
      text("Activated Charcoal",770,233);
      textSize(20);
      text("Pet is food poisoned? Give 1 pill",770,406);
      text("immediately to remove toxins.",770,436);
      if (activatedCharcoalPresc) text("Prescribed: Yes",770,258);
      else text("Prescribed: No",770,258);
    }

    if (selectedSlot!=-1) {
      image(medicine,770,333,medicine.width/9,medicine.height/9);
      imageMode(CORNER);
    }
  }

  if (buysnacks == true) {
    rectMode(CORNERS);
    stroke(169);
    strokeWeight(5);
    fill(80,220);
    rect(110, 122.5f, 990, 572.5f); //Box
    noFill();
    rect(933,132,976,171.5f); //X box
    textAlign(LEFT, CENTER);
    textSize(40);
    fill(255);
    text("X",942,151.75f);
    fill(169);
    line(width/2,182,width/2,572.5f); //Middle of box
    line(110,182,990,182); //Line enclosing text

    float[] xs = {110, 256.66f, 403.32f, width/2};
    float[] ys = {182, 279.625f, 377.25f, 474.875f, 572.5f};

    noFill();
    stroke(169);
    strokeWeight(5);
    strokeCap(SQUARE);

    for (int i = 0; i < xs.length; i++) line(xs[i], ys[0], xs[i], ys[ys.length-1]);
    for (int j = 0; j < ys.length; j++) line(xs[0], ys[j], xs[xs.length-1], ys[j]);

    if (selectedSlot != -1) {
      if (inventoryHasRoomFor(snackstock[selectedSlot]) && money >= snackCosts[selectedSlot]) fill(0,255,0,65);
      else fill(169,80);

      rect(682.5625f, 474.875f, 857.4375f, 546);
      textAlign(CENTER);
      fill(255);
      textSize(25);
      text("$" + String.format("%03.2f", snackCosts[selectedSlot]), 770, 522.5f);

      int r = selectedSlot / 3;
      int c = selectedSlot % 3;

      float x1 = xs[c],   x2 = xs[c+1];
      float y1 = ys[r],   y2 = ys[r+1];

      float o = 1;
      stroke(255);

      line(x1 - o, y1,     x2 + o, y1);
      line(x1 - o, y2,     x2 + o, y2);
      line(x1,     y1 - o, x1,     y2 + o);
      line(x2,     y1 - o, x2,     y2 + o);

    } else {
      textAlign(CENTER);
      fill(255);
      textSize(30);
      text("No Item Selected",770,335);
      textSize(20);
      text("Select an item",770,370);
      text("and purchase it!",770,390);
    }

    rectMode(CORNER);
    strokeWeight(1);
    textAlign(CENTER);
    fill(255);
    textSize(35);
    text("SNACKS:", width/2,height*0.235f);
    imageMode(CENTER);

    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 3; col++) {
        int snackIndex = row * 3 + col;

        float x1 = xs[col];
        float x2 = xs[col + 1];
        float y1 = ys[row];
        float y2 = ys[row + 1];

        float cx = (x1 + x2) / 2;
        float cy = (y1 + y2) / 2;

        if (snackIndex == 0) image(nachos, cx, cy, nachos.width/9, nachos.height/9);
        else if (snackIndex == 1) image(cheesepuffs, cx, cy+5, cheesepuffs.width/8, cheesepuffs.height/8);
        else if (snackIndex == 2) image(chips, cx, cy+10, chips.width/8, chips.height/8);
        else if (snackIndex == 3) image(chocolatebar, cx, cy, chocolatebar.width/12, chocolatebar.height/12);
        else if (snackIndex == 4) image(cookies, cx, cy-2, cookies.width/6.5f, cookies.height/6.5f);
        else if (snackIndex == 5) image(crackers, cx, cy+2, crackers.width/7, crackers.height/7);
        else if (snackIndex == 6) image(energydrink, cx, cy, energydrink.width/11.5f, energydrink.height/11.5f);
        else if (snackIndex == 7) image(granolabar, cx, cy+10, granolabar.width/7, granolabar.height/7);
        else if (snackIndex == 8) image(popcorn, cx, cy+1.5f, popcorn.width/8, popcorn.height/8);
        else if (snackIndex == 9) image(pretzels, cx, cy+3, pretzels.width/6, pretzels.height/6);
        else if (snackIndex == 10) image(soda, cx, cy, soda.width/14, soda.height/14);
        else if (snackIndex == 11) image(trailmix, cx, cy+6, trailmix.width/8, trailmix.height/8);
      }
    }

    textSize(30);
    if (selectedSlot==0) {
        text("Nachos",770,233);
        textSize(20);
        text("Messy cheesy chips with heavy seasoning.",770,406);
        text("Tasty, but definitely not healthy.",770,436);
        textSize(15);
        text("-40 Hunger   -15 Health   +5 Happiness   +30 Energy",770,258);
      
      } else if (selectedSlot==1) {
        text("Cheesepuffs",770,233);
        textSize(20);
        text("Crunchy cheese puffs packed with salt",770,406);
        text("and artificial flavoring.",770,436);
        textSize(15);
        text("-25 Hunger   -5 Health   +20 Happiness   +10 Energy",770,258);
      
      } else if (selectedSlot==2) {
        text("Chips",770,233);
        textSize(20);
        text("Crispy potato chips loaded with oil",770,406);
        text("and sodium.",770,436);
        textSize(15);
        text("-30 Hunger   -10 Health   +10 Happiness   +10 Energy",770,258);
      
      } else if (selectedSlot==3) {
        text("Chocolate Bar",770,233);
        textSize(20);
        text("Sugary chocolate bar with lots of",770,406);
        text("processed sweeteners.",770,436);
        textSize(15);
        text("-7 Hunger   -5 Health   +20 Happiness   +5 Energy",770,258);
      
      } else if (selectedSlot==4) {
        text("Cookies",770,233);
        textSize(20);
        text("Sweet baked cookies full of sugar",770,406);
        text("and refined carbs.",770,436);
        textSize(15);
        text("-30 Hunger   -5 Health   +10 Happiness   +5 Energy",770,258);
      
      } else if (selectedSlot==5) {
        text("Crackers",770,233);
        textSize(20);
        text("Light crunchy crackers that are",770,406);
        text("salty and not very filling.",770,436);
        textSize(15);
        text("-5 Hunger   +20 Energy",770,258);
      
      } else if (selectedSlot==6) {
        text("Energy Drink",770,233);
        textSize(20);
        text("Very high caffeine and sugar.",770,406);
        text("A terrible choice for a pet.",770,436);
        textSize(15);
        text("+20 Hunger   -35 Health   -10 Happiness   +70 Energy",770,258);
      
      } else if (selectedSlot==7) {
        text("Granola Bar",770,233);
        textSize(20);
        text("A packaged granola bar that seems",770,406);
        text("healthy, but still processed.",770,436);
        textSize(15);
        text("-15 Hunger   -5 Health   +5 Happiness   +20 Energy",770,258);
      
      } else if (selectedSlot==8) {
        text("Popcorn",770,233);
        textSize(20);
        text("Buttery popcorn with lots of salt",770,406);
        text("and flavor dust.",770,436);
        textSize(15);
        text("-10 Hunger   -10 Health   +30 Happiness   +10 Energy",770,258);
      
      } else if (selectedSlot==9) {
        text("Pretzels",770,233);
        textSize(20);
        text("Twisty salty pretzels with lots of",770,406);
        text("sodium.",770,436);
        textSize(15);
        text("-10 Hunger   -5 Health   +5 Happiness   +15 Energy",770,258);
      
      } else if (selectedSlot==10) {
        text("Soda",770,233);
        textSize(20);
        text("Pure sugar and fizz.",770,406);
        text("Not suitable for an alligator.",770,436);
        textSize(15);
        text("+30 Hunger   -30 Health   +5 Happiness   +40 Energy",770,258);
      
      } else if (selectedSlot==11) {
        text("Trail Mix",770,233);
        textSize(20);
        text("A snack mix with salty and sweet",770,406);
        text("bits all combined together.",770,436);
        textSize(15);
        text("-10 Hunger   -5 Health   +5 Happiness   +20 Energy",770,258);
      }

    if (selectedSlot!=-1) {
      if (selectedSlot == 0) image(nachos,770,329,nachos.width/6,nachos.height/6);
      else if (selectedSlot == 1) image(cheesepuffs,770,333,cheesepuffs.width/6,cheesepuffs.height/6);
      else if (selectedSlot == 2) image(chips,770,333,chips.width/5,chips.height/5);
      else if (selectedSlot == 3) image(chocolatebar,770,327,chocolatebar.width/9,chocolatebar.height/9);
      else if (selectedSlot == 4) image(cookies,770,333,cookies.width/5,cookies.height/5);
      else if (selectedSlot == 5) image(crackers,770,333,crackers.width/5,crackers.height/5);
      else if (selectedSlot == 6) image(energydrink,770,333,energydrink.width/9.5f,energydrink.height/9.5f);
      else if (selectedSlot == 7) image(granolabar,770,333,granolabar.width/5,granolabar.height/5);
      else if (selectedSlot == 8) image(popcorn,770,333,popcorn.width/6,popcorn.height/6);
      else if (selectedSlot == 9) image(pretzels,770,333,pretzels.width/4,pretzels.height/4);
      else if (selectedSlot == 10) image(soda,770,333,soda.width/11,soda.height/11);
      else if (selectedSlot == 11) image(trailmix,770,336,trailmix.width/6.5f,trailmix.height/6.5f);
      imageMode(CORNER);
    }
  }
  
    if (buymeat == true) {
    rectMode(CORNERS);
    stroke(169);
    strokeWeight(5);
    fill(80,220);
    rect(110, 122.5f, 990, 572.5f); //Box
    noFill();
    rect(933,132,976,171.5f); //X box
    textAlign(LEFT, CENTER);
    textSize(40);
    fill(255);
    text("X",942,151.75f);
    fill(169);
    line(width/2,182,width/2,572.5f); //Middle of box
    line(110,182,990,182); //Line enclosing text

    float[] xs = {110, 256.66f, 403.32f, width/2};
    float[] ys = {182, 279.625f, 377.25f, 474.875f, 572.5f};

    noFill();
    stroke(169);
    strokeWeight(5);
    strokeCap(SQUARE);

    for (int i = 0; i < xs.length; i++) line(xs[i], ys[0], xs[i], ys[ys.length-1]);
    for (int j = 0; j < ys.length; j++) line(xs[0], ys[j], xs[xs.length-1], ys[j]);

    if (selectedSlot != -1) {
    if (inventoryHasRoomFor(meatstock[selectedSlot]) && money >= meatCosts[selectedSlot]) fill(0,255,0,65);
    else fill(169,80);

      rect(682.5625f, 474.875f, 857.4375f, 546);
      textAlign(CENTER);
      fill(255);
      textSize(25);
      text("$" + String.format("%03.2f", meatCosts[selectedSlot]), 770, 522.5f);

      int r = selectedSlot / 3;
      int c = selectedSlot % 3;

      float x1 = xs[c],   x2 = xs[c+1];
      float y1 = ys[r],   y2 = ys[r+1];

      float o = 1;
      stroke(255);

      line(x1 - o, y1,     x2 + o, y1);
      line(x1 - o, y2,     x2 + o, y2);
      line(x1,     y1 - o, x1,     y2 + o);
      line(x2,     y1 - o, x2,     y2 + o);

    } else {
      textAlign(CENTER);
      fill(255);
      textSize(30);
      text("No Item Selected",770,335);
      textSize(20);
      text("Select an item",770,370);
      text("and purchase it!",770,390);
    }

    rectMode(CORNER);
    strokeWeight(1);
    textAlign(CENTER);
    fill(255);
    textSize(35);
    text("MEAT:", width/2,height*0.235f);
    imageMode(CENTER);

    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 3; col++) {
        int meatIndex = row * 3 + col;

        float x1 = xs[col];
        float x2 = xs[col + 1];
        float y1 = ys[row];
        float y2 = ys[row + 1];

        float cx = (x1 + x2) / 2;
        float cy = (y1 + y2) / 2;

        if (meatIndex == 0) image(bluegill, cx, cy, bluegill.width/8, bluegill.height/8);
        else if (meatIndex == 1) image(bass, cx, cy, bass.width/8, bass.height/8);
        else if (meatIndex == 2) image(perch, cx, cy, perch.width/8, perch.height/8);
        else if (meatIndex == 3) image(goldfish, cx, cy, goldfish.width/8, goldfish.height/8);
        else if (meatIndex == 4) image(crab, cx, cy, crab.width/8, crab.height/8);
        else if (meatIndex == 5) image(lambchop, cx, cy, lambchop.width/8, lambchop.height/8);
        else if (meatIndex == 6) image(porkchop, cx, cy, porkchop.width/8, porkchop.height/8);
        else if (meatIndex == 7) image(steak, cx, cy, steak.width/8, steak.height/8);
        else if (meatIndex == 8) image(chicken, cx, cy, chicken.width/8, chicken.height/8);
        else if (meatIndex == 9) image(catfish, cx, cy, catfish.width/8, catfish.height/8);
        else if (meatIndex == 10) image(frog, cx, cy, frog.width/8, frog.height/8);
        else if (meatIndex == 11) image(shrimp, cx, cy, shrimp.width/8, shrimp.height/8);
      }
    }

    textSize(30);
    if (selectedSlot==0) {
      text("Bluegill",770,233);
      textSize(20);
      text("A nutritious freshwater fish with",770,406);
      text("solid protein and moderate fat.",770,436);
      textSize(15);
      text("-55 Hunger   +15 Health   +10 Happiness   +20 Energy",770,258);

    } else if (selectedSlot==1) {
      text("Bass",770,233);
      textSize(20);
      text("A filling fish meal packed with",770,406);
      text("protein and natural oils.",770,436);
      textSize(15);
      text("-60 Hunger   +20 Health   +10 Happiness   +25 Energy",770,258);

    } else if (selectedSlot==2) {
      text("Perch",770,233);
      textSize(20);
      text("A lean fish choice that's healthy",770,406);
      text("and easy to digest.",770,436);
      textSize(15);
      text("-50 Hunger   +20 Health   +5 Happiness   +15 Energy",770,258);

    } else if (selectedSlot==3) {
      text("Goldfish",770,233);
      textSize(20);
      text("A small prey-sized bite that gives",770,406);
      text("a quick little meal.",770,436);
      textSize(15);
      text("-30 Hunger   +5 Health   +15 Happiness   +10 Energy",770,258);

    } else if (selectedSlot==4) {
      text("Crab",770,233);
      textSize(20);
      text("Rich shellfish meat with minerals",770,406);
      text("and lots of flavor.",770,436);
      textSize(15);
      text("-50 Hunger   +25 Health   +20 Happiness   +15 Energy",770,258);

    } else if (selectedSlot==5) {
      text("Lamb Chop",770,233);
      textSize(20);
      text("A heavy red meat meal that is very",770,406);
      text("filling and energy dense.",770,436);
      textSize(15);
      text("-70 Hunger   +10 Health   +15 Happiness   +35 Energy",770,258);

    } else if (selectedSlot==6) {
      text("Pork Chop",770,233);
      textSize(20);
      text("A hearty cut of pork with lots of",770,406);
      text("protein and fat.",770,436);
      textSize(15);
      text("-65 Hunger   +10 Health   +10 Happiness   +30 Energy",770,258);

    } else if (selectedSlot==7) {
      text("Steak",770,233);
      textSize(20);
      text("A premium meat cut that gives huge",770,406);
      text("nutrition and energy.",770,436);
      textSize(15);
      text("-70 Hunger   +20 Health   +20 Happiness   +40 Energy",770,258);

    } else if (selectedSlot==8) {
      text("Chicken",770,233);
      textSize(20);
      text("Lean poultry meat that's balanced,",770,406);
      text("healthy, and reliable.",770,436);
      textSize(15);
      text("-60 Hunger   +20 Health   +10 Happiness   +20 Energy",770,258);

    } else if (selectedSlot==9) {
      text("Catfish",770,233);
      textSize(20);
      text("A dense fish meal with strong",770,406);
      text("protein and rich flavor.",770,436);
      textSize(15);
      text("-60 Hunger   +15 Health   +10 Happiness   +25 Energy",770,258);

    } else if (selectedSlot==10) {
      text("Frog",770,233);
      textSize(20);
      text("A natural prey option that feels",770,406);
      text("especially satisfying to eat.",770,436);
      textSize(15);
      text("-45 Hunger   +15 Health   +25 Happiness   +20 Energy",770,258);

    } else if (selectedSlot==11) {
      text("Shrimp",770,233);
      textSize(20);
      text("A light seafood bite that boosts",770,406);
      text("health more than fullness.",770,436);
      textSize(15);
      text("-35 Hunger   +25 Health   +15 Happiness   +10 Energy",770,258);
    }

    if (selectedSlot!=-1) {
      if (selectedSlot == 0) image(bluegill,770,333,bluegill.width/6,bluegill.height/6);
      else if (selectedSlot == 1) image(bass,770,333,bass.width/6,bass.height/6);
      else if (selectedSlot == 2) image(perch,770,333,perch.width/6,perch.height/6);
      else if (selectedSlot == 3) image(goldfish,770,333,goldfish.width/6,goldfish.height/6);
      else if (selectedSlot == 4) image(crab,770,333,crab.width/6,crab.height/6);
      else if (selectedSlot == 5) image(lambchop,770,333,lambchop.width/6,lambchop.height/6);
      else if (selectedSlot == 6) image(porkchop,770,333,porkchop.width/6,porkchop.height/6);
      else if (selectedSlot == 7) image(steak,770,333,steak.width/6,steak.height/6);
      else if (selectedSlot == 8) image(chicken,770,333,chicken.width/6,chicken.height/6);
      else if (selectedSlot == 9) image(catfish,770,333,catfish.width/6,catfish.height/6);
      else if (selectedSlot == 10) image(frog,770,333,frog.width/6,frog.height/6);
      else if (selectedSlot == 11) image(shrimp,770,333,shrimp.width/6,shrimp.height/6);
      imageMode(CORNER);
    }
  }

  if (firstbuymedicine && inventoryslots[0].equals("Enrofloxacin") && !firstexitclick) redarrow(919, 657, "right");
  rectMode(CORNER);
}

boolean bankpopupshown=false;
boolean showbankpopup=false;

void bankpopup () {
  imageMode(CENTER);
   image(popupbackground,width/2,height*0.42f,popupbackground.width*0.6f,popupbackground.height*0.6f);
   fill(0);
   textFont(times50);
   textSize(20);
  drawWrappedTextInBox("Don't forget to give " + alligator.petName + " another dose tomorrow (see prescription description). Click Bank after closing this window to view your transactions and get personalized financial advice.", 338, 271, 761, 400, 6);
}
ArrayList<String> bankTransactions = new ArrayList<String>();

float bankScroll = 0;
float bankContentHeight = 0;

float bankViewX = 320;
float bankViewY = 190;
float bankViewW = 450;
float bankViewH = 370;

float bankLineHeight = 30;

float bankScrollbarX = 770;
float bankScrollbarY = 190;
float bankScrollbarW = 12;
float bankScrollbarH = 370;

boolean draggingBankScrollbar = false;
float bankThumbOffsetY = 0;

boolean firstbankview=false;

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

  bankContentHeight = 170 + bankTransactions.size() * bankLineHeight;
  float maxScroll = max(0, bankContentHeight - bankViewH);
  bankScroll = constrain(bankScroll, 0, maxScroll);

  pushMatrix();
  clip((int)bankViewX, (int)bankViewY, (int)bankViewW, (int)bankViewH);

  fill(255);
  textAlign(CENTER, TOP);
  textSize(25);
  text("Advice:", bankViewX + bankViewW/2, bankViewY + 10 - bankScroll);

  line(bankViewX, bankViewY + 92 - bankScroll, bankViewX + bankViewW, bankViewY + 92 - bankScroll);

  textSize(13.75f);
  fill(255);
  if (neverboughthighqualitycare) {
    drawWrappedTextInBox(
      "You have only purchased low quality care. While it's cheaper, the vet can prescribe an incorrect medication or refuse to help even after you pay.",
      bankViewX + 10,
      bankViewY + 38 - bankScroll,
      bankViewX + bankViewW - 10,
      bankViewY + 86 - bankScroll,
      2
    );
  
  } else if (!cleanerVisited) {
    drawWrappedTextInBox(
      "Hiring a cleaner daily will ensure that " + alligator.petName + "'s risk of sickness won't increase daily.",
      bankViewX + 10,
      bankViewY + 38 - bankScroll,
      bankViewX + bankViewW - 10,
      bankViewY + 86 - bankScroll,
      2
    );
  
  }  else if (timesFedPet < 5) {
    drawWrappedTextInBox(
      "Keep an eye on hunger and energy. Feeding " + alligator.petName + " regularly will help keep hunger from getting to high and energy from getting too low.",
      bankViewX + 10,
      bankViewY + 38 - bankScroll,
      bankViewX + bankViewW - 10,
      bankViewY + 86 - bankScroll,
      2
    );
  
  } else if (timesRestedSuccessfully < 3) {
    drawWrappedTextInBox(
      "Resting is a good way to restore energy, but make sure these rests are successful and the line lands in the green zone.",
      bankViewX + 10,
      bankViewY + 38 - bankScroll,
      bankViewX + bankViewW - 10,
      bankViewY + 86 - bankScroll,
      2
    );
  
  } else if (helpTaskCount < 3) {
    drawWrappedTextInBox(
      "Helping around town is a good way to earn money, but leaving " + alligator.petName + " alone can have consequences.",
      bankViewX + 10,
      bankViewY + 38 - bankScroll,
      bankViewX + bankViewW - 10,
      bankViewY + 86 - bankScroll,
      2
    );
  
  } else if (money < 15) {
    drawWrappedTextInBox(
      "Your money is getting low. Consider working, helping around town, or playing minigames to earn more.",
      bankViewX + 10,
      bankViewY + 38 - bankScroll,
      bankViewX + bankViewW - 10,
      bankViewY + 86 - bankScroll,
      2
    );
  
  } else if (alligator.sickrisk >= 60) {
    drawWrappedTextInBox(
      alligator.petName + "'s sickness risk is pretty high. Cleaning and careful care can help prevent future problems.",
      bankViewX + 10,
      bankViewY + 38 - bankScroll,
      bankViewX + bankViewW - 10,
      bankViewY + 86 - bankScroll,
      2
    );
  
  } else if (alligator.health <= 40) {
    drawWrappedTextInBox(
      alligator.petName + "'s health is getting low. You should focus on recovery before it becomes dangerous.",
      bankViewX + 10,
      bankViewY + 38 - bankScroll,
      bankViewX + bankViewW - 10,
      bankViewY + 86 - bankScroll,
      2
    );
  
  } else if (alligator.hunger >= 50) {
    drawWrappedTextInBox(
      alligator.petName + " is getting hungry. Make sure to keep food stocked in your inventory.",
      bankViewX + 10,
      bankViewY + 38 - bankScroll,
      bankViewX + bankViewW - 10,
      bankViewY + 86 - bankScroll,
      2
    );
  
  } else {
    drawWrappedTextInBox(
      "Keep balancing money and care to keep " + alligator.petName + " healthy, happy, and alive.",
      bankViewX + 10,
      bankViewY + 38 - bankScroll,
      bankViewX + bankViewW - 10,
      bankViewY + 86 - bankScroll,
      2
    );
  }

  textAlign(LEFT, TOP);
  textSize(20);

  for (int i = 0; i < bankTransactions.size(); i++) {
    float y = bankViewY + 110 + i * bankLineHeight - bankScroll;
    text(bankTransactions.get(i), bankViewX + 10, y);
  }

  noClip();
  popMatrix();

  noFill();
  stroke(200);
  strokeWeight(2);
  rectMode(CORNER);
  rect(bankViewX, bankViewY, bankViewW, bankViewH);

  fill(120);
  stroke(80);
  rect(bankScrollbarX, bankScrollbarY, bankScrollbarW, bankScrollbarH);

  if (bankContentHeight > bankViewH) {
    float thumbH = max(40, (bankViewH / bankContentHeight) * bankScrollbarH);
    float thumbY = map(bankScroll, 0, maxScroll, bankScrollbarY, bankScrollbarY + bankScrollbarH - thumbH);

    fill(220);
    stroke(100);
    rect(bankScrollbarX, thumbY, bankScrollbarW, thumbH);
  } else {
    fill(220);
    stroke(100);
    rect(bankScrollbarX, bankScrollbarY, bankScrollbarW, bankScrollbarH);
  }
  
  noFill();
  stroke(169);
  rectMode(CORNERS);
  rect(733,132,776,171.5f); // X box
  textAlign(LEFT, CENTER);
  textSize(40);
  fill(255);
  text("X",742,151.75f);
  
  strokeWeight(2);
  stroke(0);
  rectMode(CORNER);
}

boolean showrestpopup = false;
boolean restpopupshown = false;

int restattnum = 2;
void restpopup() {
    imageMode(CENTER);
    image(popupbackground,width/2,height*0.42f,popupbackground.width*0.6f,popupbackground.height*0.6f);
    fill(0);
    textFont(times50);
    textSize(20);
    drawWrappedTextInBox("Seems like Moss is tired. Click rest after closing this window to attempt to stabalize his energy.", 338, 271, 761, 400, 6);
  }

boolean restclicked = false;

float rectX = 439;
float rectY = 490;
float rectW = 220;
float rectH = 30;

float rectLeft = rectX - rectW/2;
float rectTop = rectY - rectH/2;
float rectBottom = rectY + rectH/2;

int red = color(255,0,0);
int orange = color(255,165,0);
int yellow = color(255,255,0);
int green = color(0,255,0);

float markerT = 0;
float markerDir = 1;
float markerX = rectLeft;


void rest() {
  rectMode(CENTER);
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(439, 490, 320, 90);

  int pixelSize = 5;

  rectMode(CORNER);
  noStroke();

  for (int px = 0; px < rectW; px += pixelSize) {
    float position = px / rectW;
    int gradientColor;

    if (position < 0.25f) {
      float localT = map(position, 0, 0.25f, 0, 1);
      gradientColor = lerpColor(red, orange, localT);
    } 
    else if (position < 0.4f) {
      float localT = map(position, 0.25f, 0.4f, 0, 1);
      gradientColor = lerpColor(orange, yellow, localT);
    } 
    else if (position < 0.5f) {
      float localT = map(position, 0.4f, 0.5f, 0, 1);
      gradientColor = lerpColor(yellow, green, localT);
    } 
    else if (position < 0.6f) {
      float localT = map(position, 0.5f, 0.6f, 0, 1);
      gradientColor = lerpColor(green, yellow, localT);
    } 
    else if (position < 0.75f) {
      float localT = map(position, 0.6f, 0.75f, 0, 1);
      gradientColor = lerpColor(yellow, orange, localT);
    } 
    else {
      float localT = map(position, 0.75f, 1, 0, 1);
      gradientColor = lerpColor(orange, red, localT);
    }

    fill(gradientColor);
    rect(rectLeft + px, rectTop, pixelSize, rectH);
  }

  float edgeSlowdown = abs(markerT - 0.5f) * 2.0f;
  float markerSpeed = map(edgeSlowdown, 0, 1, 0.03f, 0.008f);

  markerT += markerSpeed * markerDir;

  if (markerT >= 1) {
    markerT = 1;
    markerDir = -1;
  }
  
  if (markerT <= 0) {
    markerT = 0;
    markerDir = 1;
  }

  markerX = lerp(rectLeft, rectLeft + rectW, markerT);
  
  textSize(17);
  rectMode(CENTER);
  if (restattnum>0) {
    fill(0,255,0,80);
  } else {
    fill(80, 220);
  }
  stroke(255);
  strokeWeight(2);
  rect(439, 520, 80, 20);
  textAlign(CENTER, CENTER);
  fill(255);
  text("REST", 439, 520);
  stroke(0);
  strokeWeight(1);
  fill(255);
  rectMode(CORNERS);
  rect(markerX, rectTop - 6, markerX+2, rectBottom + 6);
  textSize(12);
  textAlign(CENTER);
  text("Poor", 309, 486);
  text("Rest", 309, 500);
  text("Poor", 569, 486);
  text("Rest", 569, 500);
  textSize(12);
  text("ATTEMPTS LEFT TODAY: " + restattnum, 439, 462);
  
  noFill();
  stroke(255);
  strokeWeight(1);
  rect(567, 454, 583, 470);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("X", 575, 462);
  rectMode(CORNER);
  stroke(0);
  strokeWeight(2);
}

float achvScroll = 0;
float achvContentHeight = 0;

float achvViewX = 320;
float achvViewY = 190;
float achvViewW = 450;
float achvViewH = 370;

float achvLineHeight = 110;

float achvScrollbarX = 770;
float achvScrollbarY = 190;
float achvScrollbarW = 12;
float achvScrollbarH = 370;

boolean draggingAchvScrollbar = false;
float achvThumbOffsetY = 0;

String[] achievementnames = new String[30];
String[] achievementdescriptions = new String[30];
int[] achievementrewards = new int[30];
float[] achievementgoals = new float[30];
float[] achievementprogress = new float[30];
int[] achievementtiers = new int[30];
boolean[] achievementcollectable = new boolean[30];
float[] achievementdisplaypriority = new float[30];
int[] achievementdraworder = new int[30];
int[] achievementtype = new int[30];

int timesRestedSuccessfully = 0;
int timesFedPet = 0;
int timesUsedVetCare = 0;
int timesBoughtMedicine = 0;
int salaryUpgradeCount = 0;
int taskUpgradeCount = 0;
int playPointUpgradeCount = 0;
int currentDay = 1;
int inventoryFullCount = 0;
int helpTaskCount = 0;
int medicineGivenCount = 0;
int lowQualityCareCount = 0;
int highQualityCareCount = 0;
int itemsBoughtCount = 0;
int inventoryItemsUsedCount = 0;
float totalMoneyEarned = 0;
float totalMoneySpent = 0;
float highestMoneyBalance = 0;
float moneyEarnedFromSalary = 0;
float moneyEarnedFromTasks = 0;
float moneyEarnedFromMinigames = 0;
int restAttempts = 0;
float totalEnergyRestoredFromResting = 0;
float totalHealthRestored = 0;
float totalHappinessRestored = 0;
int cleanersHiredCount = 0;
int bankTransactionsLoggedCount = 0;
int walkersHiredCount = 0;

float currentPlaySessionMoneyEarned = 0;

void initAchievements() {
  for (int i = 0; i < 30; i++) {
    achievementtiers[i] = 1;
    achievementcollectable[i] = false;
    achievementdraworder[i] = i;
  }
  refreshAchievementData();
}

void refreshAchievementData() {
  setHopAchievement(0, "Swamp Hop High Score", 20, 2);
  setSnackAchievement(1, "Snack Snatch High Score", 15, 2);
  setFetchAchievement(2, "Fetch Frenzy High Score", 10, 2);

  setMoneyEarnedAchievement(3, "Total Money Earned", 160, 3, totalMoneyEarned);
  setMoneySpentAchievement(4, "Total Money Spent", 55, 3, totalMoneySpent);
  setHighestMoneyAchievement(5, "Highest Money Balance", 125, 3, highestMoneyBalance);

  setCountAchievement(6, "Times Pet Fed", "Feed your pet", 5, 6, timesFedPet);
  setCountAchievement(7, "Times Medicine Given", "Give medicine", 3, 6, medicineGivenCount);
  setCountAchievement(8, "Total Vet Visits", "Visit the vet", 3, 8, timesUsedVetCare);
  setCountAchievement(9, "Perfect Rests Completed", "Complete perfect rests", 3, 6, timesRestedSuccessfully);

  setCountAchievement(10, "Salary Upgrades Purchased", "Buy salary upgrades", 1, 6, salaryUpgradeCount);
  setCountAchievement(11, "Task Income Upgrades Purchased", "Buy task income upgrades", 1, 7, taskUpgradeCount);
  setCountAchievement(12, "Play Point Upgrades Purchased", "Buy play point upgrades", 5, 7, playPointUpgradeCount);
  setCountAchievement(13, "Help Tasks Completed", "Complete help tasks", 1, 5, helpTaskCount);
  setMoneyEarnedAchievement(14, "Money Earned From Salary", 30, 8, moneyEarnedFromSalary);
  setMoneyEarnedAchievement(15, "Money Earned From Tasks", 20, 8, moneyEarnedFromTasks);

  setCountAchievement(16, "Items Purchased From Store", "Buy store items", 3, 7, itemsBoughtCount);
  setCountAchievement(17, "Medicine Purchased", "Buy medicine", 2, 7, timesBoughtMedicine);
  setCountAchievement(18, "Inventory Items Used", "Use inventory items", 3, 7, inventoryItemsUsedCount);
  setMoneyEarnedAchievement(19, "Money Earned From Minigames", 25, 7, moneyEarnedFromMinigames);

  setCountAchievement(20, "Rest Attempts", "Attempt rests", 1, 5, restAttempts);
  setAmountAchievement(21, "Total Energy Restored From Resting", "Restore energy from resting", 70, 7, totalEnergyRestoredFromResting);

  setAmountAchievement(22, "Total Health Restored", "Restore health", 20, 7, totalHealthRestored);
  setAmountAchievement(23, "Total Happiness Restored", "Restore happiness", 20, 7, totalHappinessRestored);

  setDayAchievement(24, "Days Survived", 5, 10, currentDay);
  setCountAchievement(25, "Cleaners Hired", "Hire a cleaner", 1, 10, cleanersHiredCount);

  setCountAchievement(26, "Low Quality Care Purchased", "Buy low quality care", 2, 7, lowQualityCareCount);
  setCountAchievement(27, "High Quality Care Purchased", "Buy high quality care", 1, 10, highQualityCareCount);

  setCountAchievement(28, "Bank Transactions Logged", "Do a transaction (buy or earn)", 10, 15, bankTransactionsLoggedCount);
  setCountAchievement(29, "Walkers Hired", "Hire a walker", 1, 10, walkersHiredCount);

  updateAchievementOrder();
}

void setHopAchievement(int i, String baseName, float baseGoal, int baseReward) {
  int tier = max(1, achievementtiers[i]);
  achievementtiers[i] = tier;
  achievementtype[i] = 0;
  achievementnames[i] = baseName + " - Tier " + tier;
  achievementgoals[i] = max(1, round(baseGoal * pow(1.2f, tier - 1)));
  achievementrewards[i] = max(1, round(baseReward * pow(1.18f, tier - 1)));
  achievementdescriptions[i] = "Highest score reached in Swamp Hop";
  achievementprogress[i] = besthopscore;
  achievementcollectable[i] = achievementprogress[i] >= achievementgoals[i];
}

void setSnackAchievement(int i, String baseName, float baseGoal, int baseReward) {
  int tier = max(1, achievementtiers[i]);
  achievementtiers[i] = tier;
  achievementtype[i] = 1;
  achievementnames[i] = baseName + " - Tier " + tier;
  achievementgoals[i] = max(1, round(baseGoal * pow(1.2f, tier - 1)));
  achievementrewards[i] = max(1, round(baseReward * pow(1.18f, tier - 1)));
  achievementdescriptions[i] = "Highest score reached in Snack Snatch";
  achievementprogress[i] = bestsnatchscore;
  achievementcollectable[i] = achievementprogress[i] >= achievementgoals[i];
}

void setFetchAchievement(int i, String baseName, float baseGoal, int baseReward) {
  int tier = max(1, achievementtiers[i]);
  achievementtiers[i] = tier;
  achievementtype[i] = 2;
  achievementnames[i] = baseName + " - Tier " + tier;
  achievementgoals[i] = max(1, round(baseGoal * pow(1.2f, tier - 1)));
  achievementrewards[i] = max(1, round(baseReward * pow(1.18f, tier - 1)));
  achievementdescriptions[i] = "Highest score reached in Fetch Frenzy";
  achievementprogress[i] = bestfetchscore;
  achievementcollectable[i] = achievementprogress[i] >= achievementgoals[i];
}

void setMoneyEarnedAchievement(int i, String baseName, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementtiers[i]);
  achievementtiers[i] = tier;
  achievementtype[i] = 3;
  achievementnames[i] = baseName + " - Tier " + tier;
  achievementgoals[i] = max(1, round(baseGoal * pow(1.3f, tier - 1)));
  achievementrewards[i] = max(1, round(baseReward * pow(1.2f, tier - 1)));
  achievementdescriptions[i] = baseName;
  achievementprogress[i] = currentValue;
  achievementcollectable[i] = achievementprogress[i] >= achievementgoals[i];
}

void setMoneySpentAchievement(int i, String baseName, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementtiers[i]);
  achievementtiers[i] = tier;
  achievementtype[i] = 4;
  achievementnames[i] = baseName + " - Tier " + tier;
  achievementgoals[i] = max(1, round(baseGoal * pow(1.3f, tier - 1)));
  achievementrewards[i] = max(1, round(baseReward * pow(1.2f, tier - 1)));
  achievementdescriptions[i] = baseName;
  achievementprogress[i] = currentValue;
  achievementcollectable[i] = achievementprogress[i] >= achievementgoals[i];
}

void setHighestMoneyAchievement(int i, String baseName, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementtiers[i]);
  achievementtiers[i] = tier;
  achievementtype[i] = 5;
  achievementnames[i] = baseName + " - Tier " + tier;
  achievementgoals[i] = max(1, round(baseGoal * pow(1.25f, tier - 1)));
  achievementrewards[i] = max(1, round(baseReward * pow(1.2f, tier - 1)));
  achievementdescriptions[i] = baseName;
  achievementprogress[i] = currentValue;
  achievementcollectable[i] = achievementprogress[i] >= achievementgoals[i];
}

void setCountAchievement(int i, String baseName, String actionText, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementtiers[i]);
  achievementtiers[i] = tier;
  achievementtype[i] = 6;
  achievementnames[i] = baseName + " - Tier " + tier;
  achievementgoals[i] = max(1, round(baseGoal * pow(1.5f, tier - 1)));
  achievementrewards[i] = max(1, round(baseReward * pow(1.18f, tier - 1)));
  if (PApplet.parseInt(achievementgoals[i]) == 1) {
    achievementdescriptions[i] = actionText + " 1 time";
  } else {
    achievementdescriptions[i] = actionText + " " + PApplet.parseInt(achievementgoals[i]) + " times";
  }
  achievementprogress[i] = currentValue;
  achievementcollectable[i] = achievementprogress[i] >= achievementgoals[i];
}

void setAmountAchievement(int i, String baseName, String actionText, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementtiers[i]);
  achievementtiers[i] = tier;
  achievementtype[i] = 7;
  achievementnames[i] = baseName + " - Tier " + tier;
  achievementgoals[i] = max(1, round(baseGoal * pow(1.35f, tier - 1)));
  achievementrewards[i] = max(1, round(baseReward * pow(1.18f, tier - 1)));
  achievementdescriptions[i] = actionText + " by " + PApplet.parseInt(achievementgoals[i]) + " total points";
  achievementprogress[i] = currentValue;
  achievementcollectable[i] = achievementprogress[i] >= achievementgoals[i];
}

void setDayAchievement(int i, String baseName, float baseGoal, int baseReward, float currentValue) {
  int tier = max(1, achievementtiers[i]);
  achievementtiers[i] = tier;
  achievementtype[i] = 8;
  achievementnames[i] = baseName + " - Tier " + tier;
  achievementgoals[i] = max(1, round(baseGoal * pow(1.4f, tier - 1)));
  achievementrewards[i] = max(1, round(baseReward * pow(1.2f, tier - 1)));
  achievementdescriptions[i] = "Reach day " + PApplet.parseInt(achievementgoals[i]);
  achievementprogress[i] = currentValue;
  achievementcollectable[i] = achievementprogress[i] >= achievementgoals[i];
}

void updateAchievementProgress() {
  refreshAchievementData();
}

void updateAchievementOrder() {
  for (int i = 0; i < 30; i++) {
    float ratio = 0;
    if (achievementgoals[i] > 0) {
      ratio = achievementprogress[i] / achievementgoals[i];
    }
    ratio = constrain(ratio, 0, 1);
    achievementdisplaypriority[i] = ratio;
    if (achievementcollectable[i]) {
      achievementdisplaypriority[i] += 1000;
    }
    achievementdraworder[i] = i;
  }

  for (int a = 0; a < 29; a++) {
    for (int b = a + 1; b < 30; b++) {
      int ia = achievementdraworder[a];
      int ib = achievementdraworder[b];
      if (achievementdisplaypriority[ib] > achievementdisplaypriority[ia]) {
        int temp = achievementdraworder[a];
        achievementdraworder[a] = achievementdraworder[b];
        achievementdraworder[b] = temp;
      }
    }
  }
}

void collectAchievement(int i) {
  updateAchievementProgress();
  if (i < 0 || i >= 30) return;
  if (!achievementcollectable[i]) return;
  money += achievementrewards[i];
  bankTransactions.add("Achievement: (+$" + achievementrewards[i] + ")");
  bankTransactionsLoggedCount++;
  achievementtiers[i] = max(1, achievementtiers[i]) + 1;
  refreshAchievementData();
}

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

  float boxH = 96;
  achvContentHeight = 20 + 30 * achvLineHeight;
  float maxScroll = max(0, achvContentHeight - achvViewH);
  achvScroll = constrain(achvScroll, 0, maxScroll);

  pushMatrix();
  clip((int)achvViewX, (int)achvViewY, (int)achvViewW, (int)achvViewH);

  rectMode(CORNER);
  textAlign(LEFT, TOP);

  for (int row = 0; row < 30; row++) {
    int i = achievementdraworder[row];
    float y = achvViewY + 20 + row * achvLineHeight - achvScroll;
    float boxX = achvViewX + 10;
    float boxW = achvViewW - 30;

    float progressRatio = 0;
    if (achievementgoals[i] > 0) {
      progressRatio = achievementprogress[i] / achievementgoals[i];
    }
    progressRatio = constrain(progressRatio, 0, 1);

    fill(120, 180);
    stroke(220);
    strokeWeight(2);
    rect(boxX, y, boxW, boxH, 8);

    fill(255);
    textAlign(LEFT, TOP);
    textSize(16);
    text(achievementnames[i], boxX + 12, y + 7);

    textAlign(RIGHT, TOP);
    textSize(15);
    fill(255, 230, 120);
    text("+$" + achievementrewards[i], boxX + boxW - 12, y + 8);

    textAlign(LEFT, TOP);
    textSize(11);
    fill(215);
    text(achievementdescriptions[i], boxX + 12, y + 28, boxW - 24, 24);

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
    text(PApplet.parseInt(min(achievementprogress[i], achievementgoals[i])) + "/" + PApplet.parseInt(achievementgoals[i]), boxX + boxW - 12, barY + 6);

    rectMode(CENTER);
    stroke(169);
    strokeWeight(2);
    if (achievementcollectable[i]) {
      fill(0, 255, 0, 80);
    } else {
      fill(80, 220);
    }
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
  rect(achvViewX, achvViewY, achvViewW, achvViewH);

  fill(120);
  stroke(80);
  rect(achvScrollbarX, achvScrollbarY, achvScrollbarW, achvScrollbarH);

  if (achvContentHeight > achvViewH) {
    float thumbH = max(40, (achvViewH / achvContentHeight) * achvScrollbarH);
    float thumbY = map(achvScroll, 0, maxScroll, achvScrollbarY, achvScrollbarY + achvScrollbarH - thumbH);

    fill(220);
    stroke(100);
    rect(achvScrollbarX, thumbY, achvScrollbarW, thumbH);
  } else {
    fill(220);
    stroke(100);
    rect(achvScrollbarX, achvScrollbarY, achvScrollbarW, achvScrollbarH);
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

void storeclosedpopup() {
    imageMode(CENTER);
    image(popupbackground,width/2,height*0.42f,popupbackground.width*0.6f,popupbackground.height*0.6f);
    fill(0);
    textFont(times50);
    textSize(20);
    drawWrappedTextInBox("The store is closed on Sundays (days that are multiples of 7). Come back tomorrow!", 338, 271, 761, 400, 6);
  }
  

int sickdecider;

boolean changeday = false;
boolean sick = false;
boolean dayedited = false;
boolean cleanerVisited = false;

String sickstatus = "";
String sickness = "";
String salaryinfo = "";

int activePrescriptionIndex = -1;
int treatmentDaysNeeded = 0;
int treatmentDaysCompleted = 0;
int lastTreatmentDay = -1;

String[] sicknesses = {
  "infection",
  "cold",
  "flu",
  "vitamin deficiency",
  "malnutrition",
  "electrolyte deficiency",
  "severe fatigue",
  "depression",
  "anxiety",
  "injury",
  "calcium deficiency",
  "food poisoning"
};

void nextday() {
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);

  fill(0);
  textFont(times50);
  textSize(20);

  if (!dayedited) {
    decideSicknessForNewDay();   // uses OLD stats
    daychanges();                // changes stats + builds text after
    day++;
    dayedited = true;
  }

  drawWrappedTextInBox(
    "Welcome to day " + day + "! " + sickstatus + salaryinfo + " Check " + alligator.petName + "'s stats to guide your care!",
    338, 271, 761, 400, 6
  );
}

void decideSicknessForNewDay() {
  sickdecider = int(random(0, 101));

  if (sickdecider <= alligator.sickrisk && !sick) {
    sick = true;

    int sicknessIndex = 0;

    if (alligator.hunger <= 15) {
      sicknessIndex = 4;   // malnutrition
    } else if (alligator.energy <= 10) {
      sicknessIndex = 6;   // severe fatigue
    } else if (alligator.happiness <= 15 || alligator.energy >= 90) {
      sicknessIndex = 8;   // anxiety
    } else if (alligator.hunger <= 30) {
      sicknessIndex = 3;   // vitamin deficiency
    } else if (alligator.energy <= 20) {
      sicknessIndex = 5;   // electrolyte deficiency
    } else if (alligator.happiness <= 25) {
      sicknessIndex = 7;   // depression
    } else if (random(1) < 0.20) {
      sicknessIndex = 9;   // injury
    } else if (random(1) < 0.20) {
      sicknessIndex = 11;  // food poisoning
    } else if (random(1) < 0.35) {
      sicknessIndex = 1;   // cold
    } else if (random(1) < 0.20) {
      sicknessIndex = 2;   // flu
    } else {
      sicknessIndex = 0;   // infection
    }

    sickness = sicknesses[sicknessIndex];
  } else if (!sick) {
    sickness = "";
  }
}

void daychanges() {
  alligator.happiness -= 10;
  alligator.hunger += 40;
  alligator.energy += 40;

  if (!cleanerVisited) {
    alligator.sickrisk += 15;
  }
  cleanerVisited = false;

  if (sick && sickness != null && !sickness.equals("")) {
    alligator.health -= 20;

    if (sickness.equals(sicknesses[2])) {   // flu
      sickstatus = alligator.petName + " currently has the flu.";
    } else if (
      sickness.equals(sicknesses[6]) ||     // severe fatigue
      sickness.equals(sicknesses[7]) ||     // depression
      sickness.equals(sicknesses[8]) ||     // anxiety
      sickness.equals(sicknesses[11]) ||    // food poisoning
      sickness.equals(sicknesses[4])        // malnutrition
    ) {
      sickstatus = alligator.petName + " has been diagnosed with " + sickness + ".";
    } else {
      String article = "a";
      char first = sickness.toLowerCase().charAt(0);

      if (first == 'a' || first == 'e' || first == 'i' || first == 'o' || first == 'u') {
        article = "an";
      }

      sickstatus = alligator.petName + " currently has " + article + " " + sickness + ".";
    }
  } else {
    sickstatus = alligator.petName + " is not currently sick.";
  }

  if (!job.equals("unemployed")) {
    salaryinfo = " You have earned $" + nf(salary, 0, 2) + " (salary).";
    money += salary;
    bankTransactionsLoggedCount++;
    bankTransactions.add("Transaction: Salary " + "(+$" + nf(salary, 0, 2) + ")");
  } else {
    salaryinfo = "";
  }
}

void quitpopup() {
    imageMode(CENTER);
    image(popupbackground,width/2,height*0.42f,popupbackground.width*0.6f,popupbackground.height*0.6f);
    rectMode(CENTER);
    strokeWeight(3);
    fill(255,0,0);
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
