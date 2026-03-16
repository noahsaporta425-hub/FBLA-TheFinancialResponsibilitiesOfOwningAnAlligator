// =========================
// B_Interaction.pde
// All user input: mousePressed, keyPressed, keyReleased, mouseDragged,
// mouseWheel, mouseReleased, plus shared input utility helpers.
//
// Convention: all hit-detection uses raw coordinate comparisons.
// Popup guard booleans prevent multiple screens from activating simultaneously.
// =========================

boolean swampBox; // true when the mouse is inside the Swamp Hop minigame panel

// Temporary item category flags used during inventory/store sell logic
boolean isMedicine = false;
boolean isMeat = false;


// =========================
// Utility: findItemIndex
// Linear search through an item name array.
// Returns the matching index, or -1 if the item is not in the array.
// Used to categorize inventory items into medicine / snack / meat buckets.
// =========================
int findItemIndex(String item, String[] arr) {
  for (int i = 0; i < arr.length; i++) {
    if (arr[i].equals(item)) return i;
  }
  return -1;
}


// =========================
// Utility: removeInventorySlot
// Marks a slot as EMPTY and left-shifts all remaining items to compact the list.
// Ensures the selected slot index stays within valid bounds after removal.
// =========================
void removeInventorySlot(int slotIndex) {
  inventoryslots[slotIndex] = "EMPTY";
  for (int i = slotIndex; i < inventoryslots.length - 1; i++) {
    inventoryslots[i] = inventoryslots[i + 1];
  }
  inventoryslots[inventoryslots.length - 1] = "EMPTY";
  if (selectedSlot >= inventoryslots.length) selectedSlot = inventoryslots.length - 1;
}


// =========================
// Utility: logSellTransaction
// Canonical way to add sell income — updates money, lifetime earnings,
// transaction count, and the bank log in one call.
// =========================
void logSellTransaction(String itemName, float sellPrice) {
  money += sellPrice;
  totalMoneyEarned += sellPrice;
  bankTransactionsLoggedCount++;
  bankTransactions.add("Transaction: Sold " + itemName + " (+$" + nf(sellPrice, 0, 2) + ")");
}


// =========================
// Utility: setMinigameEntry
// Ensures exactly one minigame active flag is true at a time.
// Centralizes the logic so callers never accidentally set conflicting flags.
// =========================
void setMinigameEntry(boolean swamp, boolean snatch, boolean fetch) {
  enterswamphop    = swamp;
  entersnacksnatch = snatch;
  enterfetchfrenzy = fetch;
  onchoicescreen   = false;
}

void mousePressed() {
  // Capture current screen states at the moment of click to avoid mid-handler transitions
  // causing incorrect branching (e.g., a click that changes onchoicescreen mid-frame)
  boolean wasOnChoiceScreen = onchoicescreen;
  boolean wasEnteringSwamp = enterswamphop;
  boolean wasEnteringSnack = entersnacksnatch;
  boolean wasEnteringFetch = enterfetchfrenzy;

  // Pre-compute whether the click is inside the Swamp Hop panel area
  swampBox = (mouseX > 88 && mouseX < 373 && mouseY > 258 && mouseY < 658);

  // =========================
  // Home Screen: Button Clicks
  // Handles Instructions, Play, and Music Settings buttons
  // =========================
  if (homescreenvisible) {
    // "Instructions" button (left button) — only when music settings is closed
    if (mouseX > width * 0.13f && mouseX < width * 0.37f &&
        mouseY > height * 0.67f && mouseY < height * 0.8f &&
        showmusicsettings == false) {
      showinstructions = true;
    }

    // "Play" button (center) — only when neither overlay is open
    if (mouseX > width * 0.38f && mouseX < width * 0.61f &&
        mouseY > height * 0.67f && mouseY < height * 0.8f &&
        showmusicsettings == false && showinstructions == false) {
      homescreenvisible = false;
      cutscenestart = true;
    }

    // "Music Settings" button (right) — only when instructions overlay is closed
    if (mouseX > width * 0.615f && mouseX < width * 0.85f &&
        mouseY > height * 0.67f && mouseY < height * 0.8f &&
        showinstructions == false) {
      showmusicsettings = true;
    }

    // Close button on the instructions overlay
    if (mouseX > width * 0.785f && mouseX < width * 0.84f &&
        mouseY > height * 0.11f && mouseY < height * 0.185f) {
      showinstructions = false;
    }

    // Close button on the music settings overlay
    if (mouseX > width * 0.68f && mouseX < width * 0.73f &&
        mouseY > height * 0.41f && mouseY < height * 0.48f) {
      showmusicsettings = false;
    }
  }

  // =========================
  // Adoption Center: Pet Selection
  // Clicking either the sign or the animal portrait chooses that pet type
  // =========================
  if (insideadoptioncenter == true) {
    // Dog sign (button label area) OR dog portrait (larger clickable sprite region)
    if ((mouseX > 223 && mouseX < 350 &&
         mouseY > 450 && mouseY < 484) ||
        (mouseX > 229 && mouseX < 367 &&
         mouseY > 189 && mouseY < 426)) {
      dogadopted = true;
    }

    // Cat sign OR cat portrait
    if ((mouseX > 768 && mouseX < 891 &&
         mouseY > 450 && mouseY < 482) ||
        (mouseX > 757 && mouseX < 871 &&
         mouseY > 227 && mouseY < 415)) {
      catadopted = true;
    }
  }
  
  // =========================
  // Naming Screen: Alligator Color Selection
  // Three "SELECT" buttons are evenly spaced 300px apart from the base X position.
  // selectedAlligator controls which skin tint is applied in I_Alligator_Class.pde
  // =========================
  if (inNaming) {
    // Left alligator (default / no tint) — index 0
    if (mouseX > ((width * 0.27 - 300) + ((width / 2) * 0.9) / 2) - 60 &&
        mouseX < ((width * 0.27 - 300) + ((width / 2) * 0.9) / 2) + 60 &&
        mouseY > 659 - 17.5 &&
        mouseY < 659 + 17.5) {
      selectedAlligator = 0;
    }
    // Center alligator (green tint) — index 1
    else if (mouseX > ((width * 0.27) + ((width / 2) * 0.9) / 2) - 60 &&
             mouseX < ((width * 0.27) + ((width / 2) * 0.9) / 2) + 60 &&
             mouseY > 659 - 17.5 &&
             mouseY < 659 + 17.5) {
      selectedAlligator = 1;
    }
    // Right alligator (blue tint) — index 2
    else if (mouseX > ((width * 0.27 + 300) + ((width / 2) * 0.9) / 2) - 60 &&
             mouseX < ((width * 0.27 + 300) + ((width / 2) * 0.9) / 2) + 60 &&
             mouseY > 659 - 17.5 &&
             mouseY < 659 + 17.5) {
      selectedAlligator = 2;
    }
  }

  // =========================
  // Main Screen: Top-Level Click Routing
  // Checks the main gameplay screen actions only when onmainscreen is active.
  // Popup guards prevent multiple overlays from opening simultaneously.
  // =========================
  if (onmainscreen == true) {

    // Game over screen — "QUIT" button (centered, y = height/2 + 155 ± 21)
    if (gameOver) {
      if (mouseX > width/2 - 90 && mouseX < width/2 + 90 &&
          mouseY > height/2 + 134 && mouseY < height/2 + 176) {
        exit();
      }
      return;  // block all other main-screen clicks while game over is shown
    }

    // "Confirm Quit" button inside the quit confirmation dialog
    if (mouseX>482 && mouseX<617 && mouseY>307 && mouseY<344 && showquit) {
      quit();
    }

    // --- Popup Dismiss (the shared X / close button used by all main screen popups) ---
    // A single hit region at the top-right of every popup closes whichever is active.
    if (welcomepopupvisible || showcantsell || showplaypopup || showearnpopup || showjobpopup || showfirsthelppopup || showtreatmentpopup || showbankpopup || showrestpopup || showstoreclosedpopup || nextdayclicked || showquit) {
      if (mouseX > 730 && mouseX < 777 &&
          mouseY > 215 && mouseY < 254) {

        if (welcomepopupvisible) welcomepopupvisible = false;
        if (showcantsell) showcantsell = false;
        if (showearnpopup) {
          showearnpopup = false;
          earnpopupshown = true;
          earnpopuptimer = 0;
        }
        if (showplaypopup) {
          showplaypopup = false;
          playpopupShown = true;
          playpopuptimer = 0;
        }
        if (showjobpopup) {
          showjobpopup = false;
          jobpopupshown = true;
        }
        if (showfirsthelppopup) {
          showfirsthelppopup = false;
          firsthelppopupshown = true;
          helpclicked = false;
        }
        if (showtreatmentpopup) {
          showtreatmentpopup = false;
          if (!lowQualityVetFailedPopup) {
            treatmentpopupshown = true;
          }
          lowQualityVetFailedPopup = false;
          treatmentPopupMessage = "";
        }
        if (showbankpopup) {
          showbankpopup = false;
          bankpopupshown = true;
        }
        if (showrestpopup) {
          showrestpopup = false;
          restpopupshown = true;
        }
        
        if (showstoreclosedpopup) {
          showstoreclosedpopup=false;
        }
        if (nextdayclicked) {
          nextdayclicked=false;
        }
        if (showquit) {
          showquit=false;
        }
      }
    }
    
    
    // --- Bank Scrollbar: Begin Drag ---
    // Calculates the current thumb position and starts a drag if the user clicks it.
    float bankMaxScroll = max(0, bankContentHeight - bankViewH);
    float bankThumbH;
    float bankThumbY;

    if (bankContentHeight > bankViewH) {
      bankThumbH = max(40, (bankViewH / bankContentHeight) * bankScrollbarH);
      bankThumbY = bankScrollbarY + (bankScroll / bankMaxScroll) * (bankScrollbarH - bankThumbH);
    } else {
      bankThumbH = bankScrollbarH;
      bankThumbY = bankScrollbarY;
    }

    if (mouseX >= bankScrollbarX && mouseX <= bankScrollbarX + bankScrollbarW &&
        mouseY >= bankThumbY && mouseY <= bankThumbY + bankThumbH &&
        bankContentHeight > bankViewH) {
      draggingBankScrollbar = true;
      bankThumbOffsetY = mouseY - bankThumbY;
    }

    // --- Inventory Button (bottom-left action circle) ---
    if (dist(mouseX, mouseY, 239.5f, 602) <= 49.5f &&
        !showrestpopup && !restclicked && welcomepopupvisible == false && !storeclicked &&
        !servicesclicked && !earnclicked && !bankclicked && onmainscreen &&
        !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup &&
        !showfirsthelppopup && !showtreatmentpopup && !showbankpopup && !showstoreclosedpopup && !nextdayclicked  && !showquit) {
      inventoryvisible = true;
      firstinventoryclick = true;
    }

    // --- Rest Button — only available after the rest popup has been shown once ---
    if (dist(mouseX, mouseY, 439, 602) <= 50 &&
        !restclicked && restpopupshown && !servicesclicked && !earnclicked && !storeclicked &&
        !bankclicked && onmainscreen && !showcantsell && !showplaypopup &&
        !showearnpopup && !showjobpopup && !showfirsthelppopup && !welcomepopupvisible &&
        !showtreatmentpopup && !showbankpopup && !showstoreclosedpopup && !nextdayclicked  && !showquit) {
      restclicked = true;
      firstrestclick = true;
    }

    // --- Bank Button (bottom-right action circle) ---
    if (dist(mouseX, mouseY, 861, 602) <= 50 &&
        !restclicked && welcomepopupvisible == false && !storeclicked &&
        !servicesclicked && !earnclicked && !bankclicked && onmainscreen &&
        !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup && !welcomepopupvisible &&
        !showfirsthelppopup && !showtreatmentpopup && !showbankpopup && !showstoreclosedpopup  && !nextdayclicked  && !showquit) {
      bankclicked = true;
      firstbankclick = true;
    }

    // --- Close Inventory (X button in top-right of inventory panel) ---
    if (inventoryvisible && mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
      inventoryvisible = false;
    }

    // --- Play / Minigame Button — unlocked only after the play popup has been shown ---
    if (playpopupShown == true && !restclicked && !bankclicked && showplaypopup == false &&
        dist(mouseX, mouseY, 656, 602) <= 49.5f && !servicesclicked && !earnclicked &&
        !inventoryvisible && onmainscreen && !showcantsell && !showplaypopup && !storeclicked &&
        !showearnpopup && !showjobpopup && !showfirsthelppopup && !welcomepopupvisible &&
        !showtreatmentpopup && !showbankpopup && !showstoreclosedpopup  && !nextdayclicked  && !showquit) {
      playclicked = true;
      exit = false;
      currentPlaySessionMoneyEarned = 0;  // reset per-session earnings tracker
      minigameFade.setBlack();            // reset minigame fade to black for fresh entry
      enterswamphop = false;
      entersnacksnatch = false;
      enterfetchfrenzy = false;
      onchoicescreen = true;
    }
  }

  // =========================
  // Inventory / Store: Slot Selection
  // A 3x4 grid of slots; determines which slot index was clicked.
  // xs[] and ys[] define column and row boundaries respectively.
  // =========================
  boolean medicinegiven;

  if (inventoryvisible || buymedicine || buysnacks || buymeat) {
    float[] xs = {110, 256.66f, 403.32f, width/2};
    float[] ys = {182, 279.625f, 377.25f, 474.875f, 572.5f};
    int slotIndex = 0;

    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 3; c++) {
        if (mouseX > xs[c] && mouseX < xs[c+1] &&
            mouseY > ys[r] && mouseY < ys[r+1]) {
          selectedSlot = slotIndex;
        }
        slotIndex++;
      }
    }
  }

  // =========================
  // Inventory: Use (Feed) Selected Item
  // "FEED" button — applies the item's stat effects to the alligator via eat().
  // The first use always consumes the tutorial steak; subsequent uses check stock.
  // =========================
  if (inventoryvisible == true && selectedSlot != -1) {
    if (mouseX >= 585.125f && mouseX <= 760 &&
        mouseY >= 474.875f && mouseY <= 546) {

      inventoryItemsUsedCount++;

      if (fedsteak == false) {
        fedsteak = true;
        item = "Steak";
        inventoryvisible = false;
        alligator.eat(item);
        inventoryslots[0] = "EMPTY";
        timesFedPet++;

      } else {
        item = inventoryslots[selectedSlot];
        inventoryvisible = false;

        if (item.equals("Enrofloxacin")) {
          firstmedicinegiven = true;
        }

        alligator.eat(item);

        int medIndex   = findItemIndex(item, medicinestock);
        int snackIndex = findItemIndex(item, snackstock);
        int meatIndex  = findItemIndex(item, meatstock);

  if (medIndex != -1) {
    if (medQtys[medIndex] == 1) {
      medQtys[medIndex] = 0;
      removeInventorySlot(selectedSlot);
    } else {
      medQtys[medIndex] = medQtys[medIndex] - 1;
    }
  
    if (sick && medIndex == activePrescriptionIndex) {
      if (lastTreatmentDay != day) {
        treatmentDaysCompleted++;
        lastTreatmentDay = day;
      }
  
      if (treatmentDaysCompleted >= treatmentDaysNeeded) {
        sick = false;
        sickness = "";
        clearPrescriptionCourse();
      }
    }
  
    medicineGivenCount++;
    medicinegiven = true;
  
        } else if (snackIndex != -1) {
          if (snackQtys[snackIndex] == 1) {
            snackQtys[snackIndex] = 0;
            removeInventorySlot(selectedSlot);
          } else {
            snackQtys[snackIndex] = snackQtys[snackIndex] - 1;
          }
          timesFedPet++;
          medicinegiven = false;

        } else if (meatIndex != -1) {
          if (meatQtys[meatIndex] == 1) {
            meatQtys[meatIndex] = 0;
            removeInventorySlot(selectedSlot);
          } else {
            meatQtys[meatIndex] = meatQtys[meatIndex] - 1;
          }
          timesFedPet++;
          medicinegiven = false;

        } else {
          inventoryslots[selectedSlot] = "EMPTY";
          timesFedPet++;
          medicinegiven = false;
        }
      }
    }
  }

  // =========================
  // Inventory: Sell Selected Item
  // "SELL" button — returns 75% of the item's purchase price and removes it from inventory.
  // Blocked until the initial tutorial steak has been fed (fedsteak guard).
  // =========================
  if (mouseX >= 780 && mouseX <= 954.875f &&
      mouseY >= 474.875f && mouseY <= 546 && inventoryvisible) {

    if (!fedsteak) {
      cantsell();
      showcantsell = true;

    } else {
      boolean isMedicine = false;
      boolean isSnack = false;
      boolean isMeat = false;

      isMedicine = findItemIndex(inventoryslots[selectedSlot], medicinestock) != -1;
      isSnack    = findItemIndex(inventoryslots[selectedSlot], snackstock)    != -1;
      isMeat     = findItemIndex(inventoryslots[selectedSlot], meatstock)     != -1;

      if (isMedicine) {
        int medIndex = findItemIndex(inventoryslots[selectedSlot], medicinestock);
        if (medIndex != -1) {
          float sellPrice = 5 * 0.75f;
          logSellTransaction(medicinestock[medIndex], sellPrice);
          medQtys[medIndex] -= defaultQtys[medIndex];
          if (medQtys[medIndex] <= 0) {
            medQtys[medIndex] = 0;
            removeInventorySlot(selectedSlot);
          }
        }

      } else if (isSnack) {
        int snackIndex = findItemIndex(inventoryslots[selectedSlot], snackstock);
        if (snackIndex != -1) {
          float sellPrice = snackCosts[snackIndex] * 0.75f;
          logSellTransaction(snackstock[snackIndex], sellPrice);
          snackQtys[snackIndex] -= 1;
          if (snackQtys[snackIndex] <= 0) {
            snackQtys[snackIndex] = 0;
            removeInventorySlot(selectedSlot);
          }
        }

      } else if (isMeat) {
        int meatIndex = findItemIndex(inventoryslots[selectedSlot], meatstock);
        if (meatIndex != -1) {
          float sellPrice = meatCosts[meatIndex] * 0.75f;
          logSellTransaction(meatstock[meatIndex], sellPrice);
          meatQtys[meatIndex] -= 1;
          if (meatQtys[meatIndex] <= 0) {
            meatQtys[meatIndex] = 0;
            removeInventorySlot(selectedSlot);
          }
        }

      } else {
        removeInventorySlot(selectedSlot);
      }
    }
  }

  // =========================
  // Minigame Choice Screen: Select Which Game to Play
  // Three clickable panel regions on the choice screen.
  // setMinigameEntry() ensures only one flag is true at a time.
  // =========================
  if (wasOnChoiceScreen && fadingout && !onmainscreen) {
    if (mouseX > 88 && mouseX < 373 && mouseY > 258 && mouseY < 658) {
      setMinigameEntry(true, false, false);   // Swamp Hop
    } else if (mouseX > 403 && mouseX < 695 && mouseY > 257 && mouseY < 664) {
      setMinigameEntry(false, true, false);   // Snack Snatch
    } else if (mouseX > 731 && mouseY > 263 && mouseX < 1013 && mouseY < 661) {
      setMinigameEntry(false, false, true);   // Fetch Frenzy
    }
  }

  // =========================
  // Minigame: "PLAY" / "RETRY" Button (left modal button)
  // Shared hit region used by all three games when the modal is showing
  // =========================
  if (mouseX >= 427 &&
      mouseX <= 533 &&
      mouseY >= 410 &&
      mouseY <= 463) {
    if (snacksnatchlost && entersnacksnatch) {
      snacksnatchinstructions = false;
      resetSnackSnatch();
    }

    if (swamphoplost && enterswamphop) {
      swamphopinstructions = false;
      resetSwampHop();
    }

    if (fetchfrenzylost && enterfetchfrenzy) {
      fetchfrenzyinstructions = false;
      resetFetchFrenzy();
    }
  }

  // =========================
  // Minigame: "EXIT" Button (right modal button)
  // Returns to the main screen and logs any earnings from the session to the bank
  // =========================
  if (mouseX >= width/2 + 70 - 52.5f &&
      mouseX <= width/2 + 70 + 52.5f &&
      mouseY >= 436 - 25 &&
      mouseY <= 436 + 25 &&
      !wasOnChoiceScreen &&
      ((wasEnteringSwamp && swamphoplost) ||
       (wasEnteringSnack && snacksnatchlost) ||
       (wasEnteringFetch && fetchfrenzylost))) {
    exit = true;
    onmainscreen = true;
    playclicked = false;
    fadingout = false;
    mainFade.setClear();   // resume on main screen without a fade-in
    enterswamphop = false;
    enterfetchfrenzy = false;
    entersnacksnatch = false;
    swamphopinstructions = true;
    fetchfrenzyinstructions = true;
    snacksnatchinstructions = true;
    exit = true;
    onmainscreen = true;
    playclicked = false;
    if (currentPlaySessionMoneyEarned > 0) {
      bankTransactionsLoggedCount++;
      bankTransactions.add("Transaction: Minigames (+$" + nf(currentPlaySessionMoneyEarned, 0, 2) + ")");
      currentPlaySessionMoneyEarned = 0;
    }
  }

  // =========================
  // Quit Button (gear icon, top-right corner of main screen)
  // Opens a confirmation dialog before quitting
  // =========================
  if (dist(mouseX, mouseY, 1044, 43) <= 36 &&
      !bankclicked  && !inventoryvisible && !servicesclicked && !storeclicked &&
      !showcantsell && !showplaypopup && !showearnpopup && !welcomepopupvisible && !showjobpopup &&
      !showfirsthelppopup && !showtreatmentpopup && !showrestpopup &&
      !showbankpopup && !showstoreclosedpopup  && !nextdayclicked && !earnclicked  && !showquit) {
    showquit=true;
  }

  // =========================
  // Earn Button (top-right earn icon, unlocked after earnpopupshown)
  // Opens the earn screen (jobs + tasks)
  // =========================
  if (dist(mouseX, mouseY, 1045, 134) <= 43 &&
      !bankclicked && earnpopupshown && !inventoryvisible && !servicesclicked && !storeclicked &&
      !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup && !welcomepopupvisible &&
      !showfirsthelppopup && !showtreatmentpopup && !showrestpopup &&
      !showbankpopup && !showstoreclosedpopup  && !nextdayclicked && !showmusicsettings  && !showquit) {
    earnclicked = true;
    earnJobFinderOpen = false;
    earnTasksOpen = false;
    firstearnclick = true;
  }

  // =========================
  // Earn Screen: Navigation and Actions
  // Handles the earn hub, job finder, and tasks/upgrades sub-panels
  // =========================
  if (earnclicked == true) {

    // Close earn screen (shared X button)
    if (!earnJobFinderOpen && !earnTasksOpen &&
        mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
      earnclicked = false;
    }

    // Quit current job — resets salary and upgrade cost
    if (!earnJobFinderOpen && !earnTasksOpen &&
        mouseX > 766 && mouseX < 866 && mouseY > 156 && mouseY < 256) {
      job = "unemployed";
      salary = 0;
      maxcashiersalary = false;
      salupgcost = 3;
    }

    // Navigate to Job Finder sub-panel
    if (!earnJobFinderOpen && !earnTasksOpen &&
        mouseX > 205 && mouseX < 455 && mouseY > 410 && mouseY < 500) {
      earnJobFinderOpen = true;
      earnTasksOpen = false;
      return;
    }

    // Navigate to Tasks & Upgrades sub-panel
    if (!earnJobFinderOpen && !earnTasksOpen &&
        mouseX > 610 && mouseX < 930 && mouseY > 410 && mouseY < 500) {
      earnTasksOpen = true;
      earnJobFinderOpen = false;
      firsttasktabclick=true;
      return;
    }

    // Back button inside Job Finder
    if (earnJobFinderOpen &&
        mouseX > 863 && mouseX < 906 && mouseY > 155 && mouseY < 194.5f) {
      earnJobFinderOpen = false;
    }

    // Back button inside Tasks screen
    if (earnTasksOpen &&
        mouseX > 833 && mouseX < 876 && mouseY > 155 && mouseY < 194.5f) {
      earnTasksOpen = false;
    }

    // Apply for cashier job (always available, starting salary $15)
    if (earnJobFinderOpen && job.equals("unemployed") &&
        mouseX > 260 && mouseX < 339 && mouseY > 478 && mouseY < 498) {
      job = "cashier";
      salary = 15;
    }

    // "Help Around Town" task button (tasks tab)
    // Earns task money, triggers sickness risk, and logs to bank
if (earnTasksOpen && jobpopupshown &&
    mouseX > 340 && mouseX < 420 && mouseY > 420 && mouseY < 441) {
  helpclicked = true;
  firsthelpclick = true;
  helpTaskCount++;
  money += taskmoney;
  moneyEarnedFromTasks += taskmoney;
  totalMoneyEarned += taskmoney;
  bankTransactionsLoggedCount++;
  bankTransactions.add("Transaction: Help Around Town (+$" + nf(taskmoney,0,2) + ")");
  earnclicked = false;
  earnTasksOpen = false;
  earnJobFinderOpen = false;

  if (!firsthelppopupshown) {
    sick = true;
    sickness = sicknesses[0];
    helppopuptext = "Congrats on earning $" + nf(taskmoney,0,2) + "! While helping around town, " + alligator.petName + " was left unattended and developed an infection. Close this window and click the services button to visit the vet.";
    showfirsthelppopup = true;
  } else if (random(1) < 0.40f) {
    
      if (!sick) {
        int randomSicknessIndex = int(random(sicknesses.length));
        sick = true;
        sickness = sicknesses[randomSicknessIndex];
    
        helppopuptext = "Uh oh! While you were off helping, " + alligator.petName + " was left unattended and I have bad news: " + sickness + ".";
      } 
      else {
        alligator.health -= 10;
    
        helppopuptext = "While you were helping around town, your already sick alligator  became weaker and lost 10 health.";
      }
    
      showfirsthelppopup = true;
    }
}

    // Salary upgrade — increases salary by 12% each purchase, capped per job tier
    if (earnTasksOpen && !job.equals("unemployed") && money >= salupgcost &&
        mouseX > 680 && mouseX < 760 && mouseY > 410 && mouseY < 430 &&
        !(job.equals("cashier") && salary >= 32) &&
        !(job.equals("barista") && salary >= 70)) {
    
      float cost = salupgcost;
      money -= cost;
      totalMoneySpent += cost;
      bankTransactionsLoggedCount++;
      bankTransactions.add("Transaction: Salary Upgrade (-$" + nf(cost,0,2) + ")");
    
      if (job.equals("cashier") && salary * 1.12f >= 32) {
        salary = 32;
        maxcashiersalary = true;
    
      } else if (job.equals("barista") && salary * 1.12f >= 70) {
        salary = 70;
    
      } else {
        salary = salary * 1.12f;
      }
    
      salupgcost = salupgcost * 1.4f;
      salaryUpgradeCount++;
    }
    
    // Task reward upgrade — increases the "Help Around Town" payout by 12% each purchase
    if (earnTasksOpen && money >= taskupgcost &&
        mouseX > 775 && mouseX < 855 && mouseY > 410 && mouseY < 430) {
      float cost = taskupgcost;
      money -= cost;
      totalMoneySpent += cost;
      bankTransactionsLoggedCount++;
      bankTransactions.add("Transaction: Task Upgrade (-$" + nf(cost,0,2) + ")");
      taskupgcost = taskupgcost * 1.3f;
      taskmoney = taskmoney * 1.12f;
      taskUpgradeCount++;
    }
  }

  // $ Per Point upgrade — increases minigame money earned per score point
  if (earnTasksOpen &&
      mouseX > 575 && mouseX < 656 &&
      mouseY > 411 && mouseY < 431 && money>=ptupgcost) {
  
      money -= ptupgcost;
      totalMoneySpent += ptupgcost;
      bankTransactionsLoggedCount++;
      bankTransactions.add("Transaction: Bought $ Per Point Upgrade (-$" + nf(ptupgcost, 0, 2) + ")");
      playPointUpgradeCount++;
  
      if (moneyperpt == 0) {
        moneyperpt = 0.10f;
      } else {
        moneyperpt *= 1.2f;
      }
  
      ptupgcost *= 1.2f;
  }

  if (earnclicked == true && mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
    earnclicked = false;
  }

if (earnclicked == true && jobpopupshown &&
    mouseX > 804 && mouseX < 884 && mouseY > 388 && mouseY < 408) {
  helpclicked = true;
  helpTaskCount++;
  money += taskmoney;
  moneyEarnedFromTasks += taskmoney;
  totalMoneyEarned += taskmoney;
  bankTransactionsLoggedCount++;
  bankTransactions.add("Transaction: Help Around Town (+$" + nf(taskmoney, 0, 2) + ")");
  alligator.health -= 50;
  earnclicked = false;

  if (!firsthelppopupshown) {
    sick = true;
    sickness = sicknesses[0];
    helppopuptext = "Congrats on earning $" + nf(taskmoney,0,2) + "! While helping around town, " + alligator.petName + " was left unattended and developed an infection. Close this window and click the services button to visit the vet.";
    showfirsthelppopup = true;
  } else if (!sick && random(1) < 0.15f) {
    int randomSicknessIndex = int(random(sicknesses.length));
    sick = true;
    sickness = sicknesses[randomSicknessIndex];
    helppopuptext = "Uh oh! While you were off helping, your " + alligator.petName + " was left unattended and developed " + sickness + ".";
    showfirsthelppopup = true;
  }
}

  // =========================
  // Services Button (bottom action circle)
  // Unlocked after the first illness popup — opens vet / walker / cleaner panel
  // =========================
  if (dist(mouseX, mouseY, 760, 602) < 50 &&
      !bankclicked && firsthelppopupshown == true && !inventoryvisible && !storeclicked &&
      !earnclicked && !showcantsell && !showplaypopup && !showearnpopup && !welcomepopupvisible &&
      !showjobpopup && !showfirsthelppopup && !showtreatmentpopup &&
      !showbankpopup && !showstoreclosedpopup  && !nextdayclicked && !showmusicsettings  && !showquit) {
    servicesclicked = true;
    firstservicesclick = true;
  }

  // =========================
  // Vet Button inside Services Panel
  // Transitions from the services overview to the vet quality selection screen
  // =========================
  if (servicesclicked &&
      mouseX > 256.67f - 80 && mouseX < 256.67f + 80 &&
      mouseY > 480 && mouseY < 560) {
    vetclicked = true;
    servicesclicked = false;
  }

  // =========================
  // Vet Care: 3-Star (Low Quality) — $5
  // 25% chance of failing on sick pets (first use always succeeds).
  // If sick and untreated, prescribes a medicine course the player must fulfill.
  // =========================
if (money >= 5 && vetclicked &&
    mouseX > 380 && mouseX < 500 &&
    mouseY > 405 && mouseY < 465) {

  lowqualitycaregiven = true;
  money -= 5;
  totalMoneySpent += 5;
  bankTransactionsLoggedCount++;
  bankTransactions.add("Transaction: 3 Star Vet (-$5.00)");
  vetclicked = false;
  timesUsedVetCare++;
  lowQualityCareCount++;

  boolean alreadyPrescribed = false;
  for (int _pi = 0; _pi < presc.length; _pi++) { if (presc[_pi]) { alreadyPrescribed = true; break; } }

  if (!sick || alreadyPrescribed) {
    alligator.health = min(100, alligator.health + 30);
    treatmentPopupMessage = "The vet treated " + alligator.petName + "'s health and restored 30 health.";
    showtreatmentpopup = true;
  } else {
    boolean lowQualityCareFails = false;

    if (firstLowQualityCareAlwaysSucceeds) {
      firstLowQualityCareAlwaysSucceeds = false;
      lowQualityCareFails = false;
    } else if (random(1) < 0.25f) {
      lowQualityCareFails = true;
    }

    if (lowQualityCareFails) {
      lowQualityVetFailedPopup = true;
      treatmentPopupMessage = "Sorry, the vet wasn't able to help. A high quality doctor will provide care 100% of the time.";
      showtreatmentpopup = true;
    } else {
      lowQualityVetFailedPopup = false;

      for (int i = 0; i < sicknesses.length; i++) {
        if (sickness.equals(sicknesses[i])) {
          startPrescriptionCourse(i);

          treatmentPopupMessage = "The vet has prescribed " + alligator.petName + " " + medicinestock[i] + ". Head to the store after closing this window to buy it free of charge!";
          showtreatmentpopup = true;
          break;
        }
      }
    }
  }
}
    
  if (vetclicked && mouseX > 711 && mouseY > 231 && mouseX < 758 && mouseY < 275) {
    vetclicked = false;
  }

  // =========================
  // Store Button (bottom action circle)
  // Unlocked after the treatment popup is shown. Blocked on day % 7 == 0 (store closed).
  // =========================
  if (dist(mouseX, mouseY, 337, 602) < 50 &&
      !bankclicked && treatmentpopupshown && !storeclicked && !storemainscreenfading &&
      !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup && !welcomepopupvisible &&
      !showfirsthelppopup && !showtreatmentpopup && !showbankpopup && (day%7!=0) && !showstoreclosedpopup  && !nextdayclicked  && !showquit) {
    storemainscreenfading = true;  // begin fade-to-black before entering the store
    return;
  } else if (dist(mouseX, mouseY, 337, 602) < 50 &&
      !bankclicked && treatmentpopupshown && !storeclicked &&
      !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup && !welcomepopupvisible &&
      !showfirsthelppopup && !showtreatmentpopup && !showbankpopup && !showstoreclosedpopup  && !nextdayclicked  && !showquit) {
    // Store is closed today — show a message instead of opening the store
    showstoreclosedpopup=true;
  }

  // =========================
  // Store Tab Navigation
  // Three tabs at the top of the store: Snacks, Medicine, Meat
  // =========================
  if (mouseX > 627 && mouseX < 1070 && mouseY > 39 && mouseY < 88 && storeclicked && !buysnacks && !buymeat) {
    buymedicine = true;
  }

  if (mouseX > 28 && mouseX < 485 && mouseY > 33 && mouseY < 88 && storeclicked && !buymeat && !buymedicine) {
    buysnacks = true;
  }

  // =========================
  // Store: Purchase Medicine
  // Prescribed medicines are free (presc[] flag set by vet); non-prescribed cost $5 each.
  // Adds to inventory slot matching the item name (or any EMPTY slot).
  // =========================
  if (buymedicine == true &&
      mouseX > 682.5625f && mouseX < 857.4375f &&
      mouseY > 474.875f && mouseY < 546 &&
      selectedSlot != -1 &&
      inventoryHasRoomFor(medicinestock[selectedSlot]) &&
      (((!presc[selectedSlot] && money >= 5) || presc[selectedSlot]))) {

    int medIndex = selectedSlot;
    boolean boughtMed = false;

    for (int slot = 0; slot < 12; slot++) {
      if (inventoryslots[slot].equals("EMPTY") || inventoryslots[slot].equals(medicinestock[medIndex])) {

        inventoryslots[slot] = medicinestock[medIndex];

        if (medicinestock[medIndex].equals("Enrofloxacin")) {
          firstbuymedicine = true;
        }

        itemsBoughtCount++;
        timesBoughtMedicine++;

        medQtys[medIndex] += defaultQtys[medIndex];
        boughtMed = true;
        break;
      }
    }

    if (boughtMed && presc[medIndex] == false) {
      money -= 5;
      totalMoneySpent += 5;
      bankTransactionsLoggedCount++;
      bankTransactions.add("Transaction: Bought " + medicinestock[medIndex] + " (-$5.00)");
    } else if (boughtMed && presc[medIndex] == true) {
      bankTransactionsLoggedCount++;
      bankTransactions.add("Transaction: Bought " + medicinestock[medIndex] + " (-$0.00)");
    }

  if (boughtMed) {
    buymedicine = false;
    presc[medIndex] = false;
  }
  }

  // =========================
  // Store: Purchase Snack
  // =========================
  if (buysnacks == true &&
      mouseX > 682.5625f && mouseX < 857.4375f &&
      mouseY > 474.875f && mouseY < 546 &&
      selectedSlot != -1 &&
      inventoryHasRoomFor(snackstock[selectedSlot]) &&
      money >= snackCosts[selectedSlot]) {

    int snackIndex = selectedSlot;
    boolean boughtSnack = false;

    for (int slot = 0; slot < 12; slot++) {
      if (inventoryslots[slot].equals("EMPTY") || inventoryslots[slot].equals(snackstock[snackIndex])) {

        inventoryslots[slot] = snackstock[snackIndex];

        itemsBoughtCount++;
        snackQtys[snackIndex] += 1;

        money -= snackCosts[snackIndex];
        totalMoneySpent += snackCosts[snackIndex];
        bankTransactionsLoggedCount++;
        bankTransactions.add("Transaction: Bought " + snackstock[snackIndex] + " (-$" + nf(snackCosts[snackIndex], 0, 2) + ")");
        boughtSnack = true;
        break;
      }
    }

    if (boughtSnack) {
      buysnacks = false;
    }
  }

  // =========================
  // Store: Purchase Meat
  // =========================
  if (buymeat == true &&
      mouseX > 682.5625f && mouseX < 857.4375f &&
      mouseY > 474.875f && mouseY < 546 &&
      selectedSlot != -1 &&
      inventoryHasRoomFor(meatstock[selectedSlot]) &&
      money >= meatCosts[selectedSlot]) {

    int meatIndex = selectedSlot;
    boolean boughtMeat = false;

    for (int slot = 0; slot < 12; slot++) {
      if (inventoryslots[slot].equals("EMPTY") || inventoryslots[slot].equals(meatstock[meatIndex])) {

        inventoryslots[slot] = meatstock[meatIndex];

        itemsBoughtCount++;
        meatQtys[meatIndex] += 1;

        money -= meatCosts[meatIndex];
        totalMoneySpent += meatCosts[meatIndex];
        bankTransactionsLoggedCount++;
        bankTransactions.add("Transaction: Bought " + meatstock[meatIndex] + " (-$" + nf(meatCosts[meatIndex], 0, 2) + ")");
        boughtMeat = true;
        break;
      }
    }

    if (boughtMeat) {
      buymeat = false;
    }
  }

  if (buymedicine && mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
    buymedicine = false;
  }

  if (buysnacks && mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
    buysnacks = false;
  }

  if (buymeat && mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
    buymeat = false;
  }

  // Trigger fade-out instead of closing immediately; store() closes itself when black
  if (mouseX > 1000 && mouseX < 1100 && mouseY > 631 && mouseY < 684 && storeclicked && !buymedicine && !buysnacks && !buymeat && !storefadingout) {
    storefadingout = true;
    firstexitclick = true;
  }

  // =========================
  // Vet Care: 5-Star (High Quality) — $20
  // Always succeeds; prescribes medicine or restores 30 health if already treated
  // =========================
  if (money >= 20 && mouseX > 599 && mouseY > 418 && mouseX < 720 && mouseY < 452 && vetclicked) {
    neverboughthighqualitycare = false;
    money -= 20;
    totalMoneySpent += 20;
    bankTransactionsLoggedCount++;
    bankTransactions.add("Transaction: 5 Star Vet (-$20.00)");
    timesUsedVetCare++;
    highQualityCareCount++;
    vetclicked = false;
  
    boolean alreadyPrescribed = false;
    for (int _pi = 0; _pi < presc.length; _pi++) { if (presc[_pi]) { alreadyPrescribed = true; break; } }
  
    if (!sick || alreadyPrescribed) {
      alligator.health = min(100, alligator.health + 30);
      treatmentPopupMessage = "The vet treated " + alligator.petName + "'s health and restored 30 health.";
      showtreatmentpopup = true;
    } else {
      for (int i = 0; i < sicknesses.length; i++) {
        if (sickness.equals(sicknesses[i])) {
          startPrescriptionCourse(i);
  
          treatmentPopupMessage = "The vet has prescribed " + alligator.petName + " " + medicinestock[i] + ". Head to the store after closing this window to buy it free of charge!";
          showtreatmentpopup = true;
          break;
        }
      }
    }
  }

  // =========================
  // Bank Screen: Scrollbar Drag Start
  // Separate from the main-screen scrollbar check above; handles when bankclicked is active
  // =========================
  if (bankclicked) {
    float bankMaxScroll2 = max(0, bankContentHeight - bankViewH);

    if (bankContentHeight > bankViewH) {
      float bankThumbH2 = max(40, (bankViewH / bankContentHeight) * bankScrollbarH);
      float bankThumbY2 = map(bankScroll, 0, bankMaxScroll2, bankScrollbarY, bankScrollbarY + bankScrollbarH - bankThumbH2);

      if (mouseX >= bankScrollbarX && mouseX <= bankScrollbarX + bankScrollbarW &&
          mouseY >= bankThumbY2 && mouseY <= bankThumbY2 + bankThumbH2) {
        draggingBankScrollbar = true;
        bankThumbOffsetY = mouseY - bankThumbY2;
      }
    }
  }

  if (mouseX > 733 && mouseY > 132 && mouseX < 776 && mouseY < 171.5f && bankclicked) {
    bankclicked = false;
    if (!firstbankview) {
      alligator.energy = 15;
      firstbankview = true;
    }
  }

  // =========================
  // Rest Screen: Stop Bar Action
  // Player stops an oscillating marker; position determines energy gain or loss.
  // Perfect zone: +30 energy. Near zone: +10. Miss: -10.
  // =========================
  if (restclicked && restattnum > 0 &&
      mouseX > 398 && mouseX < 479 && mouseY > 511 && mouseY < 530) {
    restattnum--;
    restclicked = false;
    firstalligatorrest = true;
    if (markerX > 425 && markerX < 456) {
      alligator.energy += 30;
      totalEnergyRestoredFromResting += 30;
      timesRestedSuccessfully++;
    } else if ((markerX > 383 && markerX <= 425) || (markerX < 513 && markerX >= 456)) {
      alligator.energy += 10;
      totalEnergyRestoredFromResting += 10;
    } else {
      alligator.energy -= 10;
    }
    restAttempts++;
  }

  if (restclicked && mouseX > 567 && mouseX < 583 && mouseY > 454 && mouseY < 470) {
    restclicked = false;
  }

  // =========================
  // Achievements Button (top-right, star icon)
  // Opens the scrollable achievement progress and reward claim panel
  // =========================
  if (dist(mouseX, mouseY, 1045, 232) <= 43 &&
      !showrestpopup && !restclicked && welcomepopupvisible == false &&
      !servicesclicked && !earnclicked && !bankclicked && onmainscreen &&
      !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup &&
      !showfirsthelppopup && !showtreatmentpopup && !showbankpopup && !welcomepopupvisible &&
      !inventoryvisible && !storeclicked && !showstoreclosedpopup  && !nextdayclicked  && !showquit) {
    achievementsclicked = true;
    firstachievementsclick = true;
  }
  
  // =========================
  // Next Day Button (center bottom circle)
  // Advances the in-game day, applies salary, and decays pet stats
  // =========================
  if (dist(mouseX, mouseY, width/2, 602) <= 50  &&
      !showrestpopup && !restclicked && welcomepopupvisible == false &&
      !servicesclicked && !earnclicked && !achievementsclicked && !bankclicked && onmainscreen &&
      !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup &&
      !showfirsthelppopup && !showtreatmentpopup && !showbankpopup &&
      !inventoryvisible && !storeclicked && !showstoreclosedpopup  && !nextdayclicked  && !showquit) {
    nextdayclicked=true;
    firstnextdayclick=true;
    dayedited=false;
  }

  if (achievementsclicked) {
    updateAchievementProgress();

    float achvMaxScroll = max(0, achvContentHeight - achvViewH);

    if (mouseX > 733 && mouseY > 134 && mouseX < 776 && mouseY < 172) {
      achievementsclicked = false;
      firstachievementsclosed = true;
    }

    if (achvContentHeight > achvViewH) {
      float achvThumbH = max(40, (achvViewH / achvContentHeight) * achvScrollbarH);
      float achvThumbY = map(achvScroll, 0, achvMaxScroll, achvScrollbarY, achvScrollbarY + achvScrollbarH - achvThumbH);

      if (mouseX >= achvScrollbarX && mouseX <= achvScrollbarX + achvScrollbarW &&
          mouseY >= achvThumbY && mouseY <= achvThumbY + achvThumbH) {
        draggingAchvScrollbar = true;
        achvThumbOffsetY = mouseY - achvThumbY;
      }
    }

    float boxX = achvViewX + 10;
    float boxW = achvViewW - 30;

    for (int row = 0; row < 30; row++) {
      int i = achievementdraworder[row];
      float y = achvViewY + 20 + row * achvLineHeight - achvScroll;

      float buttonCX = boxX + boxW - 52;
      float buttonCY = y + 38;
      float buttonW = 80;
      float buttonH = 20;

      if (mouseX >= buttonCX - buttonW/2 && mouseX <= buttonCX + buttonW/2 &&
          mouseY >= buttonCY - buttonH/2 && mouseY <= buttonCY + buttonH/2 &&
          mouseX >= achvViewX && mouseX <= achvViewX + achvViewW &&
          mouseY >= achvViewY && mouseY <= achvViewY + achvViewH) {
        if (i >= 0 && i < 30 && achievementcollectable[i]) {
          money += achievementrewards[i];
          totalMoneyEarned += achievementrewards[i];
          bankTransactionsLoggedCount++;
          bankTransactions.add("Transaction: Achievement Reward (+$" + nf(achievementrewards[i], 0, 2) + ")");
          achievementtiers[i]++;
          refreshAchievementData();
        }
        break;
      }
    }
  }
  
  // Store: Meat tab button (at the bottom of the store screen)
  if (storeclicked && !buymedicine && !buysnacks && mouseX>304 && mouseY>591 && mouseX<777 && mouseY<654) {
    buymeat=true;
  }

  // =========================
  // Services: Walker and Cleaner
  // Walker costs $10: drains energy, boosts happiness/health (takes alligator on a walk)
  // Cleaner costs $10: reduces sick risk, boosts happiness/health (cleans the habitat)
  // =========================
  if (servicesclicked && money>=10 && mouseX>468 && mouseY>499 && mouseX<631 && mouseY<543) {
    servicesclicked=false;
    alligator.energy-=25;
    alligator.happiness+=15;
    alligator.health+=5;
    walkersHiredCount++;
    money-=10;
    totalMoneySpent+=10;
  }

  if (servicesclicked && money>=10 && mouseX>762 && mouseY>499 && mouseX<925 && mouseY<544) {
    servicesclicked=false;
    alligator.sickrisk-=15;
    alligator.happiness+=10;
    alligator.health+=5;
    cleanersHiredCount++;
    money-=10;
    totalMoneySpent+=10;
  }

  // =========================
  // Job Finder: Apply for Locked Jobs
  // Barista unlocks on day 10, Manager on day 25 (progression gates)
  // =========================
  if (job.equals("unemployed") && day >= 10 && earnJobFinderOpen &&
      mouseX>510 && mouseX<590 && mouseY>477 && mouseY<497) {
    job = "barista";
    salary = 35;
  }

  if (job.equals("unemployed") && day >= 25 && earnJobFinderOpen &&
      mouseX>760 && mouseX<840 && mouseY>477 && mouseY<497) {
    job = "manager";
    salary = 75;
  }

  // Close services panel (X button)
  if (mouseX>931 && mouseX<979 && mouseY>132 && mouseY<174 && servicesclicked) {
    servicesclicked=false;
  }
}


boolean moveLeft = false;
boolean moveRight = false;

// =========================
// Key Press Handler
// Handles minigame controls and developer test keys
// =========================
void keyPressed() {
  // Swamp Hop: SPACE to jump (only when alligator is on the ground)
  if (key == ' ' && isOnGround) {
    velocityY = -jumpStrength;
    isOnGround = false;
  }

  // Snack Snatch: A/D or arrow keys to move left/right
  if ((key == 'a' || key == 'A' || keyCode == LEFT) && entersnacksnatch) {
    moveLeft = true;
  }

  if ((key == 'd' || key == 'D' || keyCode == RIGHT) && entersnacksnatch) {
    moveRight = true;
  }

  // Fetch Frenzy: WASD or arrow keys to set movement direction
  if ((key == 'a' || key == 'A' || keyCode == LEFT) && enterfetchfrenzy) {
    lastturn = "LEFT";
  }

  if ((key == 'd' || key == 'D' || keyCode == RIGHT) && enterfetchfrenzy) {
    lastturn = "RIGHT";
  }

  if ((key == 'w' || key == 'W' || keyCode == UP) && enterfetchfrenzy) {
    lastturn = "UP";
  }

  if ((key == 's' || key == 'S' || keyCode == DOWN) && enterfetchfrenzy) {
    lastturn = "DOWN";
  }

  // --- Developer Test Keys ---
  // These shortcuts exist for rapid testing during development.
  if (key == 'y') money += 1000;           // Add $1000 for testing economy features
  if (key == 'z') alligator.energy -= 50;  // Drain energy to test rest/minigame logic
}

// =========================
// Key Release Handler
// Stops continuous movement in Snack Snatch when A/D or arrow keys are released
// =========================
void keyReleased() {
  if ((key == 'a' || key == 'A' || keyCode == LEFT) && entersnacksnatch) {
    moveLeft = false;
  }

  if ((key == 'd' || key == 'D' || keyCode == RIGHT) && entersnacksnatch) {
    moveRight = false;
  }
}

// =========================
// Mouse Drag Handler
// Handles dragging the bank and achievements scrollbar thumbs
// =========================
void mouseDragged() {
  if (cp5.isMouseOver()) return;

  if (draggingBankScrollbar) {
    float bankmaxScroll = max(0, bankContentHeight - bankViewH);
    if (bankmaxScroll > 0) {
      float bankthumbH = max(40, (bankViewH / bankContentHeight) * bankScrollbarH);

      float banknewThumbY = mouseY - bankThumbOffsetY;
      banknewThumbY = constrain(banknewThumbY, bankScrollbarY, bankScrollbarY + bankScrollbarH - bankthumbH);

      bankScroll = map(banknewThumbY, bankScrollbarY, bankScrollbarY + bankScrollbarH - bankthumbH, 0, bankmaxScroll);
    }
  }

  if (draggingAchvScrollbar) {
    float achvmaxScroll = max(0, achvContentHeight - achvViewH);
    if (achvmaxScroll > 0) {
      float achvthumbH = max(40, (achvViewH / achvContentHeight) * achvScrollbarH);

      float achvnewThumbY = mouseY - achvThumbOffsetY;
      achvnewThumbY = constrain(achvnewThumbY, achvScrollbarY, achvScrollbarY + achvScrollbarH - achvthumbH);

      achvScroll = map(achvnewThumbY, achvScrollbarY, achvScrollbarY + achvScrollbarH - achvthumbH, 0, achvmaxScroll);
    }
  }
}

// =========================
// Mouse Wheel Handler
// Scrolls the bank transaction list or achievements panel when the cursor is over them
// =========================
void mouseWheel(MouseEvent event) {
  float e = event.getCount();

  if (mouseX >= bankViewX && mouseX <= bankViewX + bankViewW &&
      mouseY >= bankViewY && mouseY <= bankViewY + bankViewH && bankclicked) {
    bankContentHeight = 140 + bankTransactions.size() * bankLineHeight;
    float bankMaxScroll = max(0, bankContentHeight - bankViewH);

    bankScroll += e * 20;
    bankScroll = constrain(bankScroll, 0, bankMaxScroll);
  }

  if (mouseX >= achvViewX && mouseX <= achvViewX + achvViewW &&
      mouseY >= achvViewY && mouseY <= achvViewY + achvViewH && achievementsclicked) {
    achvContentHeight = 20 + 30 * achvLineHeight;
    float achvMaxScroll = max(0, achvContentHeight - achvViewH);

    achvScroll += e * 20;
    achvScroll = constrain(achvScroll, 0, achvMaxScroll);
  }
}

// =========================
// Mouse Release Handler
// Ends any active scrollbar drag when the mouse button is released
// =========================
void mouseReleased() {
  draggingBankScrollbar = false;
  draggingAchvScrollbar = false;
}
