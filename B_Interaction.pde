// =========================
// B_Interaction.pde
// All user input: mousePressed, keyPressed, keyReleased, mouseDragged,
// mouseWheel, mouseReleased, plus shared input utility helpers.
//
// Convention: all hit-detection uses raw coordinate comparisons.
// Booleans prevent multiple screens from activating simultaneously.
// =========================

// Temporary item category flags used during inventory/store sell logic
boolean isMedicine = false;
boolean isMeat = false;
boolean isMoveLeft = false;
boolean isMoveRight = false;


// =========================
// Function: findItemIndex
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
// Function: removeInventorySlot
// Marks a slot as EMPTY and left-shifts all remaining items to compact the list.
// Ensures the selected slot index stays within valid bounds after removal.
// =========================
void removeInventorySlot(int slotIndex) {
  inventorySlots[slotIndex] = "EMPTY";
  for (int i = slotIndex; i < inventorySlots.length - 1; i++) {
    inventorySlots[i] = inventorySlots[i + 1];
  }
  inventorySlots[inventorySlots.length - 1] = "EMPTY";
  if (selectedInventorySlot >= inventorySlots.length) selectedInventorySlot = inventorySlots.length - 1;
}


// =========================
// Function: logSellTransaction
// Way to add sell income -- updates money, lifetime earnings,
// transaction count, and the bank log in one call.
// =========================

void logSellTransaction(String itemName, float sellPrice) {
  money += sellPrice;
  totalMoneyEarned += sellPrice;
  bankTransactionsLoggedCount++;
  bankTransactionLog.add("Transaction: Sold " + itemName + " (+$" + nf(sellPrice, 0, 2) + ")");
}


// =========================
// Function: setMinigameEntry
// Ensures exactly one minigame active flag is true at a time.
// Centralizes the logic so callers never accidentally set conflicting flags.
// =========================
void setMinigameEntry(boolean swamp, boolean snatch, boolean fetch) {
  isEnterSwampHop    = swamp;
  isEnterSnackSnatch = snatch;
  isEnterFetchFrenzy = fetch;
  isOnChoiceScreen   = false;
}

// Handles all mouse click interactions. Organized by screen state (homescreen -> cutscene ->
// main game panels). Raw coordinate comparisons are used throughout.

void mousePressed() {
  // Capture current screen states at the moment of click to ensure proper mouse input is on the proper screen
  boolean wasOnChoiceScreen = isOnChoiceScreen;
  boolean wasEnteringSwamp = isEnterSwampHop;
  boolean wasEnteringSnack = isEnterSnackSnatch;
  boolean wasEnteringFetch = isEnterFetchFrenzy;

  // Pre-compute the "no popup blocking" guard shared by all main-screen buttons.
  // All interactive buttons are disabled while any popup or dialog is covering the screen.
  // Computing this once avoids repeating 12+ identical checks on every button test below.
  // consolidated guard: most click actions are blocked while any popup is open to prevent state conflicts
  boolean noPopupOpen = !isShowingCantSell && !isShowingFirstHelpPopup
      && !isShowingTreatmentPopup
      && !isShowingStoreClosedPopup && !isNextDayPopupOpen && !isShowingQuitDialog;

  // =========================
  // Training Screen -- CHECKED FIRST.
  // Training is a full-screen overlay; handle only its own buttons and block everything else.
  // =========================
  if (isTrainingMode) {
    // EXIT button: center (width-52, 33), 84x32
    if (mouseX >= width - 94 && mouseX <= width - 10 &&
        mouseY >= 17 && mouseY <= 49) {
      isTrainingMode  = false;
      isEvolutionOpen = true;
    }
    // ATTEMPT button (state 0): center (width/2, height*0.90), 170x46
    if (trainingState == 0 &&
        mouseX >= width / 2 - 85 && mouseX <= width / 2 + 85 &&
        mouseY >= (int)(height * 0.90f) - 23 && mouseY <= (int)(height * 0.90f) + 23) {
      attemptTrick();
    }
    // REWARD / TRY AGAIN buttons (state 2)
    if (trainingState == 2) {
      float py = height * 0.64f;
      float cx2 = width / 2.0f;
      if (mouseX >= cx2 - 175 && mouseX <= cx2 - 25 &&
          mouseY >= py + 109 && mouseY <= py + 151) {
        applyTrainingResult(true);
      }
      if (mouseX >= cx2 + 25 && mouseX <= cx2 + 175 &&
          mouseY >= py + 109 && mouseY <= py + 151) {
        applyTrainingResult(false);
      }
    }
    return;  // block every other button in the entire mousePressed function
  }

  // =========================
  // Home Screen: Button Clicks
  // Handles Instructions, Play, and Music Settings buttons
  // =========================
  if (isHomeScreenVisible) {
    // "Instructions" button (left button) -- only when music settings is closed
    if (mouseX > width * 0.13f && mouseX < width * 0.37f &&
        mouseY > height * 0.67f && mouseY < height * 0.8f &&
        isShowingMusicSettings == false) {
      isShowingInstructions = true;
    }

    // "Play" button (center) -- only when neither overlay is open
    if (mouseX > width * 0.38f && mouseX < width * 0.61f &&
        mouseY > height * 0.67f && mouseY < height * 0.8f &&
        isShowingMusicSettings == false && isShowingInstructions == false) {
      isFadingToNaming = true;
    }

    // "Music Settings" button (right) -- only when instructions overlay is closed
    if (mouseX > width * 0.615f && mouseX < width * 0.85f &&
        mouseY > height * 0.67f && mouseY < height * 0.8f &&
        isShowingInstructions == false) {
      isShowingMusicSettings = true;
    }

    // Close button on the instructions overlay
    if (mouseX > width * 0.785f && mouseX < width * 0.84f &&
        mouseY > height * 0.11f && mouseY < height * 0.185f) {
      isShowingInstructions = false;
    }

    // Close button on the music settings overlay
    if (mouseX > width * 0.68f && mouseX < width * 0.73f &&
        mouseY > height * 0.41f && mouseY < height * 0.48f) {
      isShowingMusicSettings = false;
    }
  }

  // =========================
  // Naming Screen: Alligator Color Selection
  // Three "SELECT" buttons are evenly spaced 300px apart from the base X position.
  // selectedAlligatorSkin controls which skin tint is applied in I_Alligator_Class.pde
  // =========================
  if (isNamingActive) {
    // button hitbox mirrors the drawing code in F_Adoption_Cutscene.pde -- keep both in sync if layout changes
    // Left alligator (default / no tint) -- index 0
    if (mouseX > ((width * 0.27 - 300) + ((width / 2) * 0.9) / 2) - 60 &&
        mouseX < ((width * 0.27 - 300) + ((width / 2) * 0.9) / 2) + 60 &&
        mouseY > 659 - 17.5 &&
        mouseY < 659 + 17.5) {
      selectedAlligatorSkin = 0;
    }
    // Center alligator (green tint) -- index 1
    else if (mouseX > ((width * 0.27) + ((width / 2) * 0.9) / 2) - 60 &&
             mouseX < ((width * 0.27) + ((width / 2) * 0.9) / 2) + 60 &&
             mouseY > 659 - 17.5 &&
             mouseY < 659 + 17.5) {
      selectedAlligatorSkin = 1;
    }
    // Right alligator (blue tint) -- index 2
    else if (mouseX > ((width * 0.27 + 300) + ((width / 2) * 0.9) / 2) - 60 &&
             mouseX < ((width * 0.27 + 300) + ((width / 2) * 0.9) / 2) + 60 &&
             mouseY > 659 - 17.5 &&
             mouseY < 659 + 17.5) {
      selectedAlligatorSkin = 2;
    }
  }

  // =========================
  // Main Screen: Top-Level Click Routing
  // Checks the main gameplay screen actions only when isOnMainScreen is active.
  // Popup guards prevent multiple overlays from opening simultaneously.
  // =========================
  if (isOnMainScreen == true) {

    // Game over screen -- "QUIT" button (centered, y = height/2 + 155 +/- 21)
    if (isGameOver) {
      if (mouseX > width/2 - 90 && mouseX < width/2 + 90 &&
          mouseY > height/2 + 134 && mouseY < height/2 + 176) {
        exit();
      }
      return;  // block all other main-screen clicks while game over is shown
    }

    // "Confirm Quit" button inside the quit confirmation dialog
    if (mouseX>482 && mouseX<617 && mouseY>307 && mouseY<344 && isShowingQuitDialog) {
      quit();
    }

    // --- Popup Dismiss (the shared X / close button used by all main screen popups) ---
    // A single hit region at the top-right of every popup closes whichever is active.
    if (isShowingCantSell || isShowingFirstHelpPopup || isShowingTreatmentPopup || isShowingStoreClosedPopup || isNextDayPopupOpen || isShowingQuitDialog) {
      if (mouseX > 730 && mouseX < 777 &&
          mouseY > 215 && mouseY < 254) {

        if (isShowingCantSell) isShowingCantSell = false;
        if (isShowingFirstHelpPopup) {
          isShowingFirstHelpPopup = false;
          hasShownFirstHelpPopup = true;
          isHelpTaskPending = false;
        }
        if (isShowingTreatmentPopup) {
          isShowingTreatmentPopup = false;
          if (!isShowingVetFailedPopup) {
            hasShownTreatmentPopup = true;
          }
          isShowingVetFailedPopup = false;
          vetTreatmentMessage = "";
        }
        if (isShowingStoreClosedPopup) {
          isShowingStoreClosedPopup=false;
        }
        if (isNextDayPopupOpen) {
          isNextDayPopupOpen=false;
        }
        if (isShowingQuitDialog) {
          isShowingQuitDialog=false;
        }
      }
    }
    
    
    // --- Bank Scrollbar: Begin Drag ---
    // Calculates the current thumb position and starts a drag if the user clicks it.
    float bankMaxScroll = max(0, bankScrollContentHeight - bankViewportHeight);
    float bankThumbH;
    float bankThumbY;

    if (bankScrollContentHeight > bankViewportHeight) {
      bankThumbH = max(40, (bankViewportHeight / bankScrollContentHeight) * bankScrollbarHeight);
      bankThumbY = bankScrollbarY + (bankScrollOffset / bankMaxScroll) * (bankScrollbarHeight - bankThumbH);
    } else {
      bankThumbH = bankScrollbarHeight;
      bankThumbY = bankScrollbarY;
    }

    if (mouseX >= bankScrollbarX && mouseX <= bankScrollbarX + bankScrollbarWidth &&
        mouseY >= bankThumbY && mouseY <= bankThumbY + bankThumbH &&
        bankScrollContentHeight > bankViewportHeight) {
      isDraggingBankScrollbar = true;
      bankScrollThumbOffsetY = mouseY - bankThumbY;
    }

    // --- Inventory Button (bottom-left action circle) ---
    // circular hitbox radius matches the circular inventory button sprite
    if (dist(mouseX, mouseY, 239.5f, 602) <= 49.5f &&
        noPopupOpen && !isPetAIOpen &&
        !isRestOpen && !isStoreOpen && !isServicesOpen && !isEarnPanelOpen && !isBankOpen &&
        isOnMainScreen) {
      isInventoryVisible = true;
    }

    // --- Rest Button ---
    if (dist(mouseX, mouseY, 439, 602) <= 50 &&
        noPopupOpen && !isPetAIOpen &&
        !isRestOpen && !isServicesOpen && !isEarnPanelOpen && !isStoreOpen && !isBankOpen &&
        isOnMainScreen) {
      isRestOpen = true;
    }

    // --- Bank Button (bottom-right action circle) ---
    if (dist(mouseX, mouseY, 861, 602) <= 50 &&
        noPopupOpen && !isPetAIOpen &&
        !isRestOpen && !isStoreOpen && !isServicesOpen && !isEarnPanelOpen && !isBankOpen &&
        isOnMainScreen) {
      isBankOpen = true;
    }

    // --- Close Inventory (X button in top-right of inventory panel) ---
    if (isInventoryVisible && mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
      isInventoryVisible = false;
    }

    // --- Play / Minigame Button ---
    if (noPopupOpen && !isPetAIOpen &&
        dist(mouseX, mouseY, 656, 602) <= 49.5f &&
        !isRestOpen && !isBankOpen && !isServicesOpen && !isEarnPanelOpen &&
        !isInventoryVisible && !isStoreOpen && isOnMainScreen) {
      isPlayClicked = true;
      isExitingMinigame = false;
      currentPlaySessionMoneyEarned = 0;
      minigameFade.setBlack();
      isEnterSwampHop = false;
      isEnterSnackSnatch = false;
      isEnterFetchFrenzy = false;
      isOnChoiceScreen = true;
    }
  }

  // =========================
  // Inventory / Store: Slot Selection
  // A 3x4 grid of slots; determines which slot index was clicked.
  // xs[] and ys[] define column and row boundaries respectively.
  // =========================
  boolean medicinegiven;

  if (isInventoryVisible || isViewingMedicineTab || isViewingSnacksTab || isViewingMeatTab) {
    float[] xs = {110, 256.66f, 403.32f, width/2};
    float[] ys = {182, 279.625f, 377.25f, 474.875f, 572.5f};
    int slotIndex = 0;

    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 3; c++) {
        if (mouseX > xs[c] && mouseX < xs[c+1] &&
            mouseY > ys[r] && mouseY < ys[r+1]) {
          selectedInventorySlot = slotIndex;
        }
        slotIndex++;
      }
    }
  }

  // =========================
  // Inventory: Use (Feed) Selected Item
  // "FEED" button -- applies the item's stat effects to the alligator via eat().
  // The first use always consumes the tutorial steak; subsequent uses check stock.
  // =========================
  if (isInventoryVisible == true && selectedInventorySlot != -1) {
    if (mouseX >= 585.125f && mouseX <= 760 &&
        mouseY >= 474.875f && mouseY <= 546) {

      inventoryItemsUsedCount++;

      if (hasFedSteak == false) {
        hasFedSteak = true;
        selectedItemName = "Steak";
        isInventoryVisible = false;
        alligator.eat(selectedItemName);
        inventorySlots[0] = "EMPTY";
        timesFedPet++;

      } else {
        selectedItemName = inventorySlots[selectedInventorySlot];
        isInventoryVisible = false;

        alligator.eat(selectedItemName);

        int medIndex   = findItemIndex(selectedItemName, medicineItemList);
        int snackIndex = findItemIndex(selectedItemName, snackItemList);
        int meatIndex  = findItemIndex(selectedItemName, meatItemList);

  if (medIndex != -1) {
    if (medicineQuantities[medIndex] == 1) {
      medicineQuantities[medIndex] = 0;
      removeInventorySlot(selectedInventorySlot);
    } else {
      medicineQuantities[medIndex] = medicineQuantities[medIndex] - 1;
    }
  
    if (isPetSick && medIndex == prescribedMedicineIndex) {
      if (lastDoseTakenDay != day) {
        prescriptionDaysCompleted++;
        lastDoseTakenDay = day;
      }
  
      if (prescriptionDaysCompleted >= prescriptionDaysRequired) {
        isPetSick = false;
        currentSicknessName = "";
        clearPrescriptionCourse();
      }
    }
  
    medicineGivenCount++;
    medicinegiven = true;
  
        } else if (snackIndex != -1) {
          if (snackQuantities[snackIndex] == 1) {
            snackQuantities[snackIndex] = 0;
            removeInventorySlot(selectedInventorySlot);
          } else {
            snackQuantities[snackIndex] = snackQuantities[snackIndex] - 1;
          }
          timesFedPet++;
          medicinegiven = false;

        } else if (meatIndex != -1) {
          if (meatQuantities[meatIndex] == 1) {
            meatQuantities[meatIndex] = 0;
            removeInventorySlot(selectedInventorySlot);
          } else {
            meatQuantities[meatIndex] = meatQuantities[meatIndex] - 1;
          }
          timesFedPet++;
          medicinegiven = false;

        } else {
          inventorySlots[selectedInventorySlot] = "EMPTY";
          timesFedPet++;
          medicinegiven = false;
        }
      }
    }
  }

  // =========================
  // Inventory: Sell Selected Item
  // "SELL" button -- returns 75% of the item's purchase price and removes it from inventory.
  // Blocked until the initial tutorial steak has been fed (hasFedSteak guard).
  // =========================
  if (mouseX >= 780 && mouseX <= 954.875f &&
      mouseY >= 474.875f && mouseY <= 546 && isInventoryVisible) {

    if (!hasFedSteak) {
      cantsell();
      isShowingCantSell = true;

    } else {
      boolean isMedicine = false;
      boolean isSnack = false;
      boolean isMeat = false;

      isMedicine = findItemIndex(inventorySlots[selectedInventorySlot], medicineItemList) != -1;
      isSnack    = findItemIndex(inventorySlots[selectedInventorySlot], snackItemList)    != -1;
      isMeat     = findItemIndex(inventorySlots[selectedInventorySlot], meatItemList)     != -1;

      if (isMedicine) {
        int medIndex = findItemIndex(inventorySlots[selectedInventorySlot], medicineItemList);
        if (medIndex != -1) {
          // sell price scales per-dose: $3.75 total value per medicine package, prorated by how many doses remain
          float sellPrice = (1.0f / medicineDefaultQuantities[medIndex]) * 3.75f;
          logSellTransaction(medicineItemList[medIndex], sellPrice);
          medicineQuantities[medIndex] -= 1;
          if (medicineQuantities[medIndex] <= 0) {
            medicineQuantities[medIndex] = 0;
            removeInventorySlot(selectedInventorySlot);
          }
        }

      } else if (isSnack) {
        int snackIndex = findItemIndex(inventorySlots[selectedInventorySlot], snackItemList);
        if (snackIndex != -1) {
          // items resell at 75% of purchase price -- discourages buying just to immediately resell
          float sellPrice = snackPrices[snackIndex] * 0.75f;
          logSellTransaction(snackItemList[snackIndex], sellPrice);
          snackQuantities[snackIndex] -= 1;
          if (snackQuantities[snackIndex] <= 0) {
            snackQuantities[snackIndex] = 0;
            removeInventorySlot(selectedInventorySlot);
          }
        }

      } else if (isMeat) {
        int meatIndex = findItemIndex(inventorySlots[selectedInventorySlot], meatItemList);
        if (meatIndex != -1) {
          // items resell at 75% of purchase price -- discourages buying just to immediately resell
          float sellPrice = meatPrices[meatIndex] * 0.75f;
          logSellTransaction(meatItemList[meatIndex], sellPrice);
          meatQuantities[meatIndex] -= 1;
          if (meatQuantities[meatIndex] <= 0) {
            meatQuantities[meatIndex] = 0;
            removeInventorySlot(selectedInventorySlot);
          }
        }

      } else {
        removeInventorySlot(selectedInventorySlot);
      }
    }
  }

  // =========================
  // Minigame Choice Screen: Select Which Game to Play
  // Three clickable panel regions on the choice screen.
  // setMinigameEntry() ensures only one flag is true at a time.
  // =========================
  if (wasOnChoiceScreen && isFadingOut && !isOnMainScreen) {
    if (mouseX > 88 && mouseX < 373 && mouseY > 258 && mouseY < 658) {
      setMinigameEntry(true, false, false);   // Swamp Hop
    } else if (mouseX > 403 && mouseX < 695 && mouseY > 257 && mouseY < 664) {
      setMinigameEntry(false, true, false);   // Snack Snatch
    } else if (mouseX > 731 && mouseY > 263 && mouseX < 1013 && mouseY < 661) {
      setMinigameEntry(false, false, true);   // Fetch Frenzy
    }
  }

  // =========================
  // Minigame: X exit button (top-right corner, always visible during active minigame)
  // =========================
  if ((isEnterSwampHop || isEnterSnackSnatch || isEnterFetchFrenzy) &&
      mouseX >= 1042 && mouseX <= 1092 && mouseY >= 8 && mouseY <= 46) {
    isExitingMinigame = true;
    isOnMainScreen = true;
    isPlayClicked = false;
    isFadingOut = false;
    mainFade.setClear();
    isEnterSwampHop = false;
    isEnterFetchFrenzy = false;
    isEnterSnackSnatch = false;
    isSwampHopFirstPlay = true;
    isFetchFirstPlay = true;
    isSnatchFirstPlay = true;
    if (currentPlaySessionMoneyEarned > 0) {
      bankTransactionsLoggedCount++;
      bankTransactionLog.add("Transaction: Minigames (+$" + nf(currentPlaySessionMoneyEarned, 0, 2) + ")");
      currentPlaySessionMoneyEarned = 0;
    }
    return;
  }

  // =========================
  // Minigame: "PLAY" / "RETRY" Button (left modal button)
  // Shared hit region used by all three games when the modal is showing
  // =========================
  if (mouseX >= 427 &&
      mouseX <= 533 &&
      mouseY >= 410 &&
      mouseY <= 463) {
    if (isSnatchLost && isEnterSnackSnatch) {
      isSnatchFirstPlay = false;
      resetSnackSnatch();
    }

    if (isSwampHopLost && isEnterSwampHop) {
      isSwampHopFirstPlay = false;
      resetSwampHop();
    }

    if (isFetchLost && isEnterFetchFrenzy) {
      isFetchFirstPlay = false;
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
      ((wasEnteringSwamp && isSwampHopLost) ||
       (wasEnteringSnack && isSnatchLost) ||
       (wasEnteringFetch && isFetchLost))) {
    isExitingMinigame = true;
    isOnMainScreen = true;
    isPlayClicked = false;
    isFadingOut = false;
    mainFade.setClear();   // resume on main screen without a fade-in
    isEnterSwampHop = false;
    isEnterFetchFrenzy = false;
    isEnterSnackSnatch = false;
    isSwampHopFirstPlay = true;
    isFetchFirstPlay = true;
    isSnatchFirstPlay = true;
    if (currentPlaySessionMoneyEarned > 0) {
      bankTransactionsLoggedCount++;
      bankTransactionLog.add("Transaction: Minigames (+$" + nf(currentPlaySessionMoneyEarned, 0, 2) + ")");
      currentPlaySessionMoneyEarned = 0;
    }
  }

  // =========================
  // Quit Button (gear icon, top-right corner of main screen)
  // Opens a confirmation dialog before quitting
  // =========================
  if (dist(mouseX, mouseY, 1044, 43) <= 36 &&
      noPopupOpen && !isPetAIOpen &&
      !isBankOpen && !isInventoryVisible && !isServicesOpen && !isStoreOpen && !isEarnPanelOpen) {
    isShowingQuitDialog = true;
  }

  // =========================
  // Earn Button (top-right earn icon)
  // Opens the earn screen (jobs + tasks)
  // =========================
  if (dist(mouseX, mouseY, 1045, 134) <= 43 &&
      noPopupOpen && !isShowingMusicSettings && !isPetAIOpen &&
      !isBankOpen && !isInventoryVisible && !isServicesOpen && !isStoreOpen) {
    isEarnPanelOpen = true;
    isJobFinderOpen = false;
    isTasksPanelOpen = false;
  }

  // =========================
  // Earn Screen: Navigation and Actions
  // Handles the earn hub, job finder, and tasks/upgrades sub-panels
  // =========================
  if (isEarnPanelOpen == true) {

    // Close earn screen (shared X button)
    if (!isJobFinderOpen && !isTasksPanelOpen &&
        mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
      isEarnPanelOpen = false;
    }

    // Quit current job -- resets salary and upgrade cost
    if (!isJobFinderOpen && !isTasksPanelOpen &&
        mouseX > 766 && mouseX < 866 && mouseY > 156 && mouseY < 256) {
      job = "unemployed";
      salary = 0;
      hasCashierMaxedSalary = false;
      salaryUpgradeCost = 3;
    }

    // Navigate to Job Finder sub-panel
    if (!isJobFinderOpen && !isTasksPanelOpen &&
        mouseX > 205 && mouseX < 455 && mouseY > 410 && mouseY < 500) {
      isJobFinderOpen = true;
      isTasksPanelOpen = false;
      return;
    }

    // Navigate to Tasks & Upgrades sub-panel
    if (!isJobFinderOpen && !isTasksPanelOpen &&
        mouseX > 610 && mouseX < 930 && mouseY > 410 && mouseY < 500) {
      isTasksPanelOpen = true;
      isJobFinderOpen = false;
      return;
    }

    // Back button inside Job Finder
    if (isJobFinderOpen &&
        mouseX > 863 && mouseX < 906 && mouseY > 155 && mouseY < 194.5f) {
      isJobFinderOpen = false;
    }

    // Back button inside Tasks screen
    if (isTasksPanelOpen &&
        mouseX > 833 && mouseX < 876 && mouseY > 155 && mouseY < 194.5f) {
      isTasksPanelOpen = false;
    }

    // Apply for cashier job (always available, starting salary $15)
    if (isJobFinderOpen && job.equals("unemployed") &&
        mouseX > 260 && mouseX < 339 && mouseY > 478 && mouseY < 498) {
      job = "cashier";
      salary = 15;
    }

    // Apply for barista job (unlocks on day 10, starting salary $35)
    if (isJobFinderOpen && job.equals("unemployed") && day >= 10 &&
        mouseX > 510 && mouseX < 590 && mouseY > 478 && mouseY < 498) {
      job = "barista";
      salary = 35;
    }

    // Apply for manager job (unlocks on day 25, starting salary $75)
    if (isJobFinderOpen && job.equals("unemployed") && day >= 25 &&
        mouseX > 760 && mouseX < 840 && mouseY > 478 && mouseY < 498) {
      job = "manager";
      salary = 75;
    }

    // "Help Around Town" task button (tasks tab)
    // Earns task money, triggers currentSicknessName risk, and logs to bank
if (isTasksPanelOpen &&
    mouseX > 340 && mouseX < 420 && mouseY > 420 && mouseY < 441) {
  isHelpTaskPending = true;
  helpTaskCount++;
  money += taskRewardAmount;
  moneyEarnedFromTasks += taskRewardAmount;
  totalMoneyEarned += taskRewardAmount;
  bankTransactionsLoggedCount++;
  bankTransactionLog.add("Transaction: Help Around Town (+$" + nf(taskRewardAmount,0,2) + ")");
  isEarnPanelOpen = false;
  isTasksPanelOpen = false;
  isJobFinderOpen = false;

  if (!hasShownFirstHelpPopup) {
    isPetSick = true;
    currentSicknessName = sicknessNames[0];
    helpPopupMessage = "You earned $" + nf(taskRewardAmount,0,2) + "! " + alligator.petName + " developed an infection during the Help Around Town task. Close this window and click Services to visit the vet.";
    isShowingFirstHelpPopup = true;
  } else if (random(1) < 0.40f) { // 40% chance that leaving for a task stresses the pet enough to worsen a stat -- risk/reward tradeoff

      if (!isPetSick) {
        int randomSicknessIndex = int(random(sicknessNames.length));
        isPetSick = true;
        currentSicknessName = sicknessNames[randomSicknessIndex];
    
        helpPopupMessage = "Uh oh! While you were off helping, " + alligator.petName + " was left unattended and I have bad news: " + currentSicknessName + ".";
      } 
      else {
        // minor 10 HP penalty for the stress of being left alone -- survivable, but worth noting
        alligator.health -= 10;

        helpPopupMessage = "While you were helping around town, your already sick alligator  became weaker and lost 10 health.";
      }
    
      isShowingFirstHelpPopup = true;
    }
}

    // Salary upgrade -- increases salary by 12% each purchase, capped per job tier
    if (isTasksPanelOpen && !job.equals("unemployed") && money >= salaryUpgradeCost &&
        mouseX > 680 && mouseX < 760 && mouseY > 410 && mouseY < 430 &&
        !(job.equals("cashier") && salary >= 32) &&
        !(job.equals("barista") && salary >= 70)) {
    
      float cost = salaryUpgradeCost;
      money -= cost;
      totalMoneySpent += cost;
      bankTransactionsLoggedCount++;
      bankTransactionLog.add("Transaction: Salary Upgrade (-$" + nf(cost,0,2) + ")");
    
      if (job.equals("cashier") && salary * 1.12f >= 32) {
        salary = 32;
        hasCashierMaxedSalary = true;
    
      } else if (job.equals("barista") && salary * 1.12f >= 70) {
        salary = 70;
    
      } else {
        salary = salary * 1.12f;
      }
    
      salaryUpgradeCost = salaryUpgradeCost * 1.4f;
      salaryUpgradeCount++;
    }
    
    // Task reward upgrade -- increases the "Help Around Town" payout by 12% each purchase
    if (isTasksPanelOpen && money >= taskUpgradeCost &&
        mouseX > 775 && mouseX < 855 && mouseY > 410 && mouseY < 430) {
      float cost = taskUpgradeCost;
      money -= cost;
      totalMoneySpent += cost;
      bankTransactionsLoggedCount++;
      bankTransactionLog.add("Transaction: Task Upgrade (-$" + nf(cost,0,2) + ")");
      taskUpgradeCost = taskUpgradeCost * 1.3f;
      taskRewardAmount = taskRewardAmount * 1.12f;
      taskUpgradeCount++;
    }

    // $ Per Point upgrade -- increases minigame money earned per score point
    if (isTasksPanelOpen &&
        mouseX > 575 && mouseX < 656 &&
        mouseY > 411 && mouseY < 431 && money>=pointUpgradeCost) {

        money -= pointUpgradeCost;
        totalMoneySpent += pointUpgradeCost;
        bankTransactionsLoggedCount++;
        bankTransactionLog.add("Transaction: Bought $ Per Point Upgrade (-$" + nf(pointUpgradeCost, 0, 2) + ")");
        playPointUpgradeCount++;

        if (moneyPerMinigamePoint == 0) {
          moneyPerMinigamePoint = 0.10f;
        } else {
          moneyPerMinigamePoint *= 1.2f;
        }

        pointUpgradeCost *= 1.2f;
    }
  }

if (isEarnPanelOpen == true &&
    mouseX > 804 && mouseX < 884 && mouseY > 388 && mouseY < 408) {
  isHelpTaskPending = true;
  helpTaskCount++;
  money += taskRewardAmount;
  moneyEarnedFromTasks += taskRewardAmount;
  totalMoneyEarned += taskRewardAmount;
  bankTransactionsLoggedCount++;
  bankTransactionLog.add("Transaction: Help Around Town (+$" + nf(taskRewardAmount, 0, 2) + ")");
  isEarnPanelOpen = false;

  if (!hasShownFirstHelpPopup) {
    isPetSick = true;
    currentSicknessName = sicknessNames[0];
    alligator.health -= 30;
    helpPopupMessage = "You earned $" + nf(taskRewardAmount,0,2) + "! " + alligator.petName + " developed an infection during the Help Around Town task. Close this window and click Services to visit the vet.";
    isShowingFirstHelpPopup = true;
  } else if (!isPetSick && random(1) < 0.15f) { // 15% baseline daily sickness chance even for a healthy pet -- models real-world unpredictability
    int randomSicknessIndex = int(random(sicknessNames.length));
    isPetSick = true;
    currentSicknessName = sicknessNames[randomSicknessIndex];
    // 30 HP for an unexpected illness -- significant enough to require immediate vet attention
    alligator.health -= 30;
    helpPopupMessage = "Uh oh! While you were off helping, your " + alligator.petName + " was left unattended and developed " + currentSicknessName + ".";
    isShowingFirstHelpPopup = true;
  }
}

  // =========================
  // Services Button (bottom action circle)
  // Unlocked after the first illness popup -- opens vet / walker / cleaner panel
  // =========================
  if (dist(mouseX, mouseY, 760, 602) < 50 &&
      noPopupOpen && !isShowingMusicSettings && !isPetAIOpen &&
      !isBankOpen && !isInventoryVisible && !isStoreOpen && !isEarnPanelOpen) {
    isServicesOpen = true;
  }

  // =========================
  // Vet Button inside Services Panel
  // Transitions from the services overview to the vet quality selection screen
  // Column center moved to 220 (4-column layout); button rect(220,520,130,40) -> x:155-285, y:500-540
  // =========================
  if (isServicesOpen &&
      mouseX > 155 && mouseX < 285 &&
      mouseY > 500 && mouseY < 540) {
    isVetOpen = true;
    isServicesOpen = false;
  }

  // =========================
  // PetAI Button inside Services Panel
  // Column center 880; button rect(880,520,130,40) -> x:815-945, y:500-540
  // =========================
  if (isServicesOpen &&
      mouseX > 815 && mouseX < 945 &&
      mouseY > 500 && mouseY < 540) {
    isServicesOpen = false;
    isPetAIOpen = true;
    aiSelectedSession = -1;
  }

  // =========================
  // Vet Care: 3-Star (Low Quality) -- $5
  // 25% chance of failing on sick pets (first use always succeeds).
  // If isPetSick and untreated, prescribes a medicine course the player must fulfill.
  // =========================
if (money >= 5 && isVetOpen &&
    mouseX > 380 && mouseX < 500 &&
    mouseY > 405 && mouseY < 465) {

  hasUsedLowQualityVet = true;
  money -= 5;
  totalMoneySpent += 5;
  bankTransactionsLoggedCount++;
  bankTransactionLog.add("Transaction: 3 Star Vet (-$5.00)");
  isVetOpen = false;
  timesUsedVetCare++;
  lowQualityCareCount++;

  boolean alreadyPrescribed = false;
  for (int _pi = 0; _pi < medicineIsPrescribed.length; _pi++) { if (medicineIsPrescribed[_pi]) { alreadyPrescribed = true; break; } }

  if (!isPetSick || alreadyPrescribed) {
    alligator.health = min(100, alligator.health + 30);
    vetTreatmentMessage = "The vet restored 30 health for " + alligator.petName + ".";
    isShowingTreatmentPopup = true;
  } else {
    boolean lowQualityCareFails = false;

    if (isFirstLowQualityVetAttempt) {
      isFirstLowQualityVetAttempt = false;
      lowQualityCareFails = false;
    } else if (random(1) < 0.25f) {
      lowQualityCareFails = true;
    }

    if (lowQualityCareFails) {
      isShowingVetFailedPopup = true;
      vetTreatmentMessage = "Sorry, the vet wasn't able to help. A high quality doctor will provide care 100% of the time.";
      isShowingTreatmentPopup = true;
    } else {
      isShowingVetFailedPopup = false;

      for (int i = 0; i < sicknessNames.length; i++) {
        if (currentSicknessName.equals(sicknessNames[i])) {
          startPrescriptionCourse(i);

          vetTreatmentMessage = "The vet has prescribed " + alligator.petName + " " + medicineItemList[i] + ". Head to the store after closing this window to buy it free of charge!";
          isShowingTreatmentPopup = true;
          break;
        }
      }
    }
  }
}
    
  if (isVetOpen && mouseX > 711 && mouseY > 231 && mouseX < 758 && mouseY < 275) {
    isVetOpen = false;
  }

  // =========================
  // Store Button (bottom action circle)
  // Unlocked after the treatment popup is shown. Blocked on day % 7 == 0 (store closed Sundays).
  // =========================
  if (dist(mouseX, mouseY, 337, 602) < 50 &&
      noPopupOpen && !isPetAIOpen && !isBankOpen && !isStoreOpen &&
      !isStoreMainScreenFading && day % 7 != 0) {
    isStoreMainScreenFading = true;
    return;
  } else if (dist(mouseX, mouseY, 337, 602) < 50 &&
      noPopupOpen && !isPetAIOpen && !isBankOpen && !isStoreOpen &&
      day % 7 == 0) {
    isShowingStoreClosedPopup = true;
  }

  // =========================
  // Store Tab Navigation
  // Three tabs at the top of the store: Snacks, Medicine, Meat
  // =========================
  if (mouseX > 627 && mouseX < 1070 && mouseY > 39 && mouseY < 88 && isStoreOpen && !isViewingSnacksTab && !isViewingMeatTab) {
    isViewingMedicineTab = true;
  }

  if (mouseX > 28 && mouseX < 485 && mouseY > 33 && mouseY < 88 && isStoreOpen && !isViewingMeatTab && !isViewingMedicineTab) {
    isViewingSnacksTab = true;
  }

  // =========================
  // Store: Purchase Medicine
  // Prescribed medicines are free (medicineIsPrescribed[] flag set by vet); non-prescribed cost $5 each.
  // Adds to inventory slot matching the item name (or any EMPTY slot).
  // =========================
  if (isViewingMedicineTab == true &&
      mouseX > 682.5625f && mouseX < 857.4375f &&
      mouseY > 474.875f && mouseY < 546 &&
      selectedInventorySlot != -1 &&
      inventoryHasRoomFor(medicineItemList[selectedInventorySlot]) &&
      (((!medicineIsPrescribed[selectedInventorySlot] && money >= 5) || medicineIsPrescribed[selectedInventorySlot]))) {

    int medIndex = selectedInventorySlot;
    boolean boughtMed = false;

    for (int slot = 0; slot < 12; slot++) {
      if (inventorySlots[slot].equals("EMPTY") || inventorySlots[slot].equals(medicineItemList[medIndex])) {

        inventorySlots[slot] = medicineItemList[medIndex];

        itemsBoughtCount++;
        timesBoughtMedicine++;

        medicineQuantities[medIndex] += medicineDefaultQuantities[medIndex];
        boughtMed = true;
        break;
      }
    }

    if (boughtMed && medicineIsPrescribed[medIndex] == false) {
      money -= 5;
      totalMoneySpent += 5;
      bankTransactionsLoggedCount++;
      bankTransactionLog.add("Transaction: Bought " + medicineItemList[medIndex] + " (-$5.00)");
    } else if (boughtMed && medicineIsPrescribed[medIndex] == true) {
      bankTransactionsLoggedCount++;
      bankTransactionLog.add("Transaction: Bought " + medicineItemList[medIndex] + " (-$0.00)");
    }

  if (boughtMed) {
    isViewingMedicineTab = false;
    medicineIsPrescribed[medIndex] = false;
  }
  }

  // =========================
  // Store: Purchase Snack
  // =========================
  if (isViewingSnacksTab == true &&
      mouseX > 682.5625f && mouseX < 857.4375f &&
      mouseY > 474.875f && mouseY < 546 &&
      selectedInventorySlot != -1 &&
      inventoryHasRoomFor(snackItemList[selectedInventorySlot]) &&
      money >= snackPrices[selectedInventorySlot]) {

    int snackIndex = selectedInventorySlot;
    boolean boughtSnack = false;

    for (int slot = 0; slot < 12; slot++) {
      if (inventorySlots[slot].equals("EMPTY") || inventorySlots[slot].equals(snackItemList[snackIndex])) {

        inventorySlots[slot] = snackItemList[snackIndex];

        itemsBoughtCount++;
        snackQuantities[snackIndex] += 1;

        money -= snackPrices[snackIndex];
        totalMoneySpent += snackPrices[snackIndex];
        bankTransactionsLoggedCount++;
        bankTransactionLog.add("Transaction: Bought " + snackItemList[snackIndex] + " (-$" + nf(snackPrices[snackIndex], 0, 2) + ")");
        boughtSnack = true;
        break;
      }
    }

    if (boughtSnack) {
      isViewingSnacksTab = false;
    }
  }

  // =========================
  // Store: Purchase Meat
  // =========================
  if (isViewingMeatTab == true &&
      mouseX > 682.5625f && mouseX < 857.4375f &&
      mouseY > 474.875f && mouseY < 546 &&
      selectedInventorySlot != -1 &&
      inventoryHasRoomFor(meatItemList[selectedInventorySlot]) &&
      money >= meatPrices[selectedInventorySlot]) {

    int meatIndex = selectedInventorySlot;
    boolean boughtMeat = false;

    for (int slot = 0; slot < 12; slot++) {
      if (inventorySlots[slot].equals("EMPTY") || inventorySlots[slot].equals(meatItemList[meatIndex])) {

        inventorySlots[slot] = meatItemList[meatIndex];

        itemsBoughtCount++;
        meatQuantities[meatIndex] += 1;

        money -= meatPrices[meatIndex];
        totalMoneySpent += meatPrices[meatIndex];
        bankTransactionsLoggedCount++;
        bankTransactionLog.add("Transaction: Bought " + meatItemList[meatIndex] + " (-$" + nf(meatPrices[meatIndex], 0, 2) + ")");
        boughtMeat = true;
        break;
      }
    }

    if (boughtMeat) {
      isViewingMeatTab = false;
    }
  }

  if (isViewingMedicineTab && mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
    isViewingMedicineTab = false;
  }

  if (isViewingSnacksTab && mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
    isViewingSnacksTab = false;
  }

  if (isViewingMeatTab && mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
    isViewingMeatTab = false;
  }

  // Trigger fade-out instead of closing immediately; store() closes itself when black
  if (mouseX > 1000 && mouseX < 1100 && mouseY > 631 && mouseY < 684 && isStoreOpen && !isViewingMedicineTab && !isViewingSnacksTab && !isViewingMeatTab && !isStoreFadingOut) {
    isStoreFadingOut = true;
    hasClickedStoreExit = true;
  }

  // =========================
  // Vet Care: 5-Star (High Quality) -- $20
  // Always succeeds; prescribes medicine or restores 30 health if already treated
  // =========================
  if (money >= 20 && mouseX > 599 && mouseY > 418 && mouseX < 720 && mouseY < 452 && isVetOpen) {
    hasNeverBoughtHighQualityCare = false;
    money -= 20;
    totalMoneySpent += 20;
    bankTransactionsLoggedCount++;
    bankTransactionLog.add("Transaction: 5 Star Vet (-$20.00)");
    timesUsedVetCare++;
    highQualityCareCount++;
    isVetOpen = false;
  
    boolean alreadyPrescribed = false;
    for (int _pi = 0; _pi < medicineIsPrescribed.length; _pi++) { if (medicineIsPrescribed[_pi]) { alreadyPrescribed = true; break; } }
  
    if (!isPetSick || alreadyPrescribed) {
      alligator.health = min(100, alligator.health + 30);
      vetTreatmentMessage = "The vet restored 30 health for " + alligator.petName + ".";
      isShowingTreatmentPopup = true;
    } else {
      for (int i = 0; i < sicknessNames.length; i++) {
        if (currentSicknessName.equals(sicknessNames[i])) {
          startPrescriptionCourse(i);
  
          vetTreatmentMessage = "The vet has prescribed " + alligator.petName + " " + medicineItemList[i] + ". Head to the store after closing this window to buy it free of charge!";
          isShowingTreatmentPopup = true;
          break;
        }
      }
    }
  }

  // =========================
  // Bank Screen: Scrollbar Drag Start
  // Separate from the main-screen scrollbar check above; handles when isBankOpen is active
  // =========================
  if (isBankOpen) {
    float bankMaxScroll2 = max(0, bankScrollContentHeight - bankViewportHeight);

    if (bankScrollContentHeight > bankViewportHeight) {
      float bankThumbH2 = max(40, (bankViewportHeight / bankScrollContentHeight) * bankScrollbarHeight);
      float bankThumbY2 = map(bankScrollOffset, 0, bankMaxScroll2, bankScrollbarY, bankScrollbarY + bankScrollbarHeight - bankThumbH2);

      if (mouseX >= bankScrollbarX && mouseX <= bankScrollbarX + bankScrollbarWidth &&
          mouseY >= bankThumbY2 && mouseY <= bankThumbY2 + bankThumbH2) {
        isDraggingBankScrollbar = true;
        bankScrollThumbOffsetY = mouseY - bankThumbY2;
      }
    }
  }

  // --- Bank Filter Buttons ---
  // Buttons are inside the scrollable viewport (below the advice separator).
  // Convert screen Y to content Y using bankScrollOffset, then check against the fixed content-space row (98-127).
  if (isBankOpen &&
      mouseX >= bankViewportX && mouseX < bankViewportX + bankViewportWidth &&
      mouseY >= bankViewportY && mouseY < bankViewportY + bankViewportHeight) {
    float relContentY = (mouseY - bankViewportY) + bankScrollOffset;
    if (relContentY >= 98 && relContentY <= 127) {
      float bw = (bankViewportWidth - 12) / 3.0f;
      String[] filterValues = {"all", "earn", "spend"};
      for (int i = 0; i < 3; i++) {
        float bx1 = bankViewportX + 4 + i * (bw + 2);
        float bx2 = bx1 + bw;
        if (mouseX >= bx1 && mouseX <= bx2) {
          bankFilter = filterValues[i];
          bankScrollOffset = 0;
        }
      }
    }
  }

  if (mouseX > 733 && mouseY > 132 && mouseX < 776 && mouseY < 171.5f && isBankOpen) {
    isBankOpen = false;
  }

  // =========================
  // Rest Screen: Stop Bar Action
  // Player stops an oscillating marker; position determines energy gain or loss.
  // Perfect zone: +30 energy. Near zone: +10. Miss: -10.
  // =========================
  if (isRestOpen && restAttemptsRemaining > 0 &&
      mouseX > 398 && mouseX < 479 && mouseY > 511 && mouseY < 530) {
    restAttemptsRemaining--;
    isRestOpen = false;
    hasAlligatorRestedOnce = true;
    if (restMarkerX > 425 && restMarkerX < 456) {
      alligator.energy += 30;
      totalEnergyRestoredFromResting += 30;
      timesRestedSuccessfully++;
    } else if ((restMarkerX > 383 && restMarkerX <= 425) || (restMarkerX < 513 && restMarkerX >= 456)) {
      alligator.energy += 10;
      totalEnergyRestoredFromResting += 10;
    } else {
      alligator.energy -= 10;
    }
    alligator.energy = clampStat(alligator.energy, 0, 100);
    restAttempts++;
  }

  if (isRestOpen && mouseX > 567 && mouseX < 583 && mouseY > 454 && mouseY < 470) {
    isRestOpen = false;
  }

  // =========================
  // Achievements Button (top-right, star icon)
  // Opens the scrollable achievement progress and reward claim panel
  // =========================
  if (dist(mouseX, mouseY, 1045, 232) <= 43 &&
      noPopupOpen && !isPetAIOpen &&
      !isRestOpen && !isServicesOpen && !isEarnPanelOpen && !isBankOpen &&
      !isInventoryVisible && !isStoreOpen && !isEvolutionOpen && !isSocialsOpen &&
      isOnMainScreen) {
    isAchievementsOpen = true;
  }

  // =========================
  // Evolution Button (below achievements)
  // Opens the trick training / evolution panel
  // =========================
  if (dist(mouseX, mouseY, 1045, 330) <= 43 &&
      noPopupOpen && !isPetAIOpen &&
      !isRestOpen && !isServicesOpen && !isEarnPanelOpen && !isBankOpen &&
      !isInventoryVisible && !isStoreOpen && !isAchievementsOpen && !isSocialsOpen &&
      isOnMainScreen) {
    isEvolutionOpen = true;
  }

  // =========================
  // Socials Button (below evolution)
  // Opens the social media panel
  // =========================
  if (dist(mouseX, mouseY, 1045, 428) <= 43 &&
      noPopupOpen && !isPetAIOpen &&
      !isRestOpen && !isServicesOpen && !isEarnPanelOpen && !isBankOpen &&
      !isInventoryVisible && !isStoreOpen && !isAchievementsOpen && !isEvolutionOpen &&
      isOnMainScreen) {
    isSocialsOpen     = true;
    socialsPlatform   = -1;
    isSocialsPostView = false;
    isSocialsPastView = false;
  }
  
  // =========================
  // Next Day Button (center bottom circle)
  // Advances the in-game day, applies salary, and decays pet stats
  // =========================
  if (dist(mouseX, mouseY, width/2, 602) <= 50 &&
      noPopupOpen && !isPetAIOpen &&
      !isRestOpen && !isServicesOpen && !isEarnPanelOpen && !isAchievementsOpen && !isBankOpen &&
      !isInventoryVisible && !isStoreOpen && !isEvolutionOpen && !isSocialsOpen &&
      !isTrainingMode && isOnMainScreen) {
    isNextDayPopupOpen=true;
    isDayEdited=false;
  }

  // =========================
  // Evolution Panel Clicks
  // =========================
  if (isEvolutionOpen) {
    // X close button (same region as achievements close)
    if (mouseX > 733 && mouseY > 132 && mouseX < 776 && mouseY < 172) {
      isEvolutionOpen = false;
    }

    // Scrollbar drag start
    float evContentH = 20 + 5 * evItemH;
    float evMaxScroll = max(0, evContentH - evViewportH);
    if (evContentH > evViewportH) {
      float evThumbH = max(40, (evViewportH / evContentH) * evScrollbarH);
      float evThumbY = map(evScrollOffset, 0, evMaxScroll, evScrollbarY, evScrollbarY + evScrollbarH - evThumbH);
      if (mouseX >= evScrollbarX && mouseX <= evScrollbarX + evScrollbarW &&
          mouseY >= evThumbY && mouseY <= evThumbY + evThumbH) {
        isDraggingEvScrollbar = true;
        evScrollThumbOffset = mouseY - evThumbY;
      }
    }

    // TRAIN button hit detection (per-row)
    for (int i = 0; i < 5; i++) {
      float rowY = evViewportY + 20 + i * evItemH - evScrollOffset;
      float bx   = evViewportX + 10;
      float bw   = evViewportW - 28;
      float btnCX = bx + bw - 52;
      float btnCY = rowY + 56;   // aligned with progress bar (barY=rowY+50 + barH/2)
      boolean canTrain = day >= trickUnlockDays[i] && !trickUnlocked[i];
      if (canTrain &&
          mouseX >= btnCX - 42 && mouseX <= btnCX + 42 &&
          mouseY >= btnCY - 16 && mouseY <= btnCY + 16 &&
          mouseX >= evViewportX && mouseX <= evViewportX + evViewportW &&
          mouseY >= evViewportY && mouseY <= evViewportY + evViewportH) {
        startTraining(i);
        break;
      }
    }
  }


  // =========================
  // Socials Panel Clicks
  // =========================
  if (isSocialsOpen && !isTrainingMode) {

    // Post result dismiss
    if (isShowingPostResult) {
      float px = 380, py = 230, pw = 340, ph = 220;
      if (mouseX >= px + pw / 2 - 60 && mouseX <= px + pw / 2 + 60 &&
          mouseY >= py + 159 && mouseY <= py + 197) {
        isShowingPostResult = false;
      }
      return;
    }

    if (socialsPlatform < 0) {
      // --- Hub ---
      // X close
      if (mouseX > 733 && mouseY > 132 && mouseX < 776 && mouseY < 172) {
        isSocialsOpen = false;
      }
      // Platform cards: OPEN and COLLECT buttons
      for (int i = 0; i < 3; i++) {
        float cx = 385 + i * 165;
        float cy = 355;
        // OPEN: center (cx, cy+52), 108x30
        if (mouseX >= cx - 54 && mouseX <= cx + 54 &&
            mouseY >= cy + 37 && mouseY <= cy + 67) {
          socialsPlatform   = i;
          isSocialsPostView = false;
          isSocialsPastView = false;
        }
        // COLLECT: center (cx, cy+88), 108x30
        if (mouseX >= cx - 54 && mouseX <= cx + 54 &&
            mouseY >= cy + 73 && mouseY <= cy + 103 &&
            platformPendingEarnings[i] > 0) {
          collectPlatformEarnings(i);
        }
      }

    } else if (isSocialsPostView) {
      // --- New Post View ---
      // Back button: center (345, 151), 56x28
      if (mouseX >= 317 && mouseX <= 373 && mouseY >= 137 && mouseY <= 165) {
        isSocialsPostView = false;
        isSocialsTyping   = false;
        selectedPostTrick = -1;
        postCaptionText   = "";
      }

      // Trick tiles
      float startY  = 200;
      float tileW   = 120, tileH = 90, tileGap = 8;
      float tilesX  = 330;
      float tilesY  = startY + 20;
      int col = 0;
      for (int i = 0; i < 5; i++) {
        if (!trickUnlocked[i]) continue;
        float tx = tilesX + col * (tileW + tileGap);
        float ty = tilesY;
        if (mouseX >= tx && mouseX <= tx + tileW &&
            mouseY >= ty && mouseY <= ty + tileH) {
          selectedPostTrick = (selectedPostTrick == i) ? -1 : i;
        }
        col++;
      }

      // Caption input box click
      float capY = startY + 130;
      float boxX = 330, boxY = capY + 16, boxW = 440, boxH = 52;
      if (mouseX >= boxX && mouseX <= boxX + boxW &&
          mouseY >= boxY && mouseY <= boxY + boxH) {
        isSocialsTyping = true;
      } else {
        isSocialsTyping = false;
      }

      // POST button: center (width/2, capY + 110), 180x46
      float postBtnY = capY + 110;
      if (selectedPostTrick >= 0 &&
          mouseX >= width / 2 - 90 && mouseX <= width / 2 + 90 &&
          mouseY >= postBtnY - 23 && mouseY <= postBtnY + 23) {
        handlePost(socialsPlatform);
      }

    } else if (isSocialsPastView) {
      // --- Past Posts View ---
      // Back button
      if (mouseX >= 317 && mouseX <= 373 && mouseY >= 137 && mouseY <= 165) {
        isSocialsPastView = false;
      }
      // Scroll handled in mouseWheel

    } else {
      // --- Platform Home ---
      // Back button: center (345, 151), 56x28
      if (mouseX >= 317 && mouseX <= 373 && mouseY >= 137 && mouseY <= 165) {
        socialsPlatform = -1;
      }

      // Guard: back button may have just set socialsPlatform to -1
      if (socialsPlatform >= 0) {
        int p = socialsPlatform;
        float panelTop = 195;

        // Collect button: center (width/2, panelTop+125), 160x34
        if (platformPendingEarnings[p] > 0 &&
            mouseX >= width / 2 - 80 && mouseX <= width / 2 + 80 &&
            mouseY >= panelTop + 108 && mouseY <= panelTop + 142) {
          collectPlatformEarnings(p);
        }

        // NEW POST button: center (width/2 - 90, panelTop+200), 155x48
        if (mouseX >= width / 2 - 167 && mouseX <= width / 2 - 13 &&
            mouseY >= panelTop + 176 && mouseY <= panelTop + 224) {
          isSocialsPostView = true;
          selectedPostTrick = -1;
          postCaptionText   = "";
          isSocialsTyping   = false;
        }

        // PAST POSTS button: center (width/2 + 90, panelTop+200), 155x48
        if (mouseX >= width / 2 + 13 && mouseX <= width / 2 + 167 &&
            mouseY >= panelTop + 176 && mouseY <= panelTop + 224) {
          isSocialsPastView  = true;
          pastPostsScroll[p] = 0;
        }
      }
    }
  }

  if (isAchievementsOpen) {
    updateAchievementProgress();

    float achvMaxScroll = max(0, achievementScrollContentHeight - achievementViewportHeight);

    if (mouseX > 733 && mouseY > 134 && mouseX < 776 && mouseY < 172) {
      isAchievementsOpen = false;
    }

    if (achievementScrollContentHeight > achievementViewportHeight) {
      float achvThumbH = max(40, (achievementViewportHeight / achievementScrollContentHeight) * achievementScrollbarHeight);
      float achvThumbY = map(achievementScrollOffset, 0, achvMaxScroll, achievementScrollbarY, achievementScrollbarY + achievementScrollbarHeight - achvThumbH);

      if (mouseX >= achievementScrollbarX && mouseX <= achievementScrollbarX + achievementScrollbarWidth &&
          mouseY >= achvThumbY && mouseY <= achvThumbY + achvThumbH) {
        isDraggingAchievementScrollbar = true;
        achievementScrollThumbOffsetY = mouseY - achvThumbY;
      }
    }

    float boxX = achievementViewportX + 10;
    float boxW = achievementViewportWidth - 30;

    for (int row = 0; row < 30; row++) {
      int i = achievementDrawOrder[row];
      float y = achievementViewportY + 20 + row * achievementItemLineHeight - achievementScrollOffset;

      float buttonCX = boxX + boxW - 52;
      float buttonCY = y + 38;
      float buttonW = 80;
      float buttonH = 20;

      if (mouseX >= buttonCX - buttonW/2 && mouseX <= buttonCX + buttonW/2 &&
          mouseY >= buttonCY - buttonH/2 && mouseY <= buttonCY + buttonH/2 &&
          mouseX >= achievementViewportX && mouseX <= achievementViewportX + achievementViewportWidth &&
          mouseY >= achievementViewportY && mouseY <= achievementViewportY + achievementViewportHeight) {
        if (i >= 0 && i < 30 && isAchievementCollectable[i]) {
          money += achievementRewards[i];
          totalMoneyEarned += achievementRewards[i];
          bankTransactionsLoggedCount++;
          bankTransactionLog.add("Transaction: Achievement Reward (+$" + nf(achievementRewards[i], 0, 2) + ")");
          achievementTiers[i]++;
          refreshAchievementData();
        }
        break;
      }
    }
  }
  
  // Store: Meat tab button (at the bottom of the store screen)
  if (isStoreOpen && !isViewingMedicineTab && !isViewingSnacksTab && mouseX>304 && mouseY>591 && mouseX<777 && mouseY<654) {
    isViewingMeatTab=true;
  }

  // =========================
  // Services: Walker and Cleaner
  // Walker costs $10: drains energy, boosts happiness/health (takes alligator on a walk)
  // Cleaner costs $10: reduces sick risk, boosts happiness/health (cleans the habitat)
  // =========================
  // Walker column center 455; button rect(455,520,130,40) -> x:390-520, y:500-540
  if (isServicesOpen && money>=10 && mouseX>390 && mouseY>500 && mouseX<520 && mouseY<540) {
    isServicesOpen=false;
    alligator.energy-=25;
    alligator.happiness+=15;
    alligator.health+=5;
    walkersHiredCount++;
    money-=10;
    totalMoneySpent+=10;
    bankTransactionsLoggedCount++;
    bankTransactionLog.add("Transaction: Hired Walker (-$10.00)");
    alligator.energy    = clampStat(alligator.energy,    0, 100);
    alligator.happiness = clampStat(alligator.happiness, 0, 100);
    alligator.health    = clampStat(alligator.health,    0, 100);
  }

  // Cleaner column center 660; button rect(660,520,130,40) -> x:595-725, y:500-540
  if (isServicesOpen && money>=10 && mouseX>595 && mouseY>500 && mouseX<725 && mouseY<540) {
    isServicesOpen=false;
    alligator.sickrisk-=15;
    alligator.happiness+=10;
    alligator.health+=5;
    cleanersHiredCount++;
    hasCleanerVisited = true;
    money-=10;
    totalMoneySpent+=10;
    bankTransactionsLoggedCount++;
    bankTransactionLog.add("Transaction: Hired Cleaner (-$10.00)");
    alligator.sickrisk  = clampStat(alligator.sickrisk,  20, 100);
    alligator.happiness = clampStat(alligator.happiness, 0, 100);
    alligator.health    = clampStat(alligator.health,    0, 100);
  }

  // Close services panel (X button)
  if (mouseX>931 && mouseX<979 && mouseY>132 && mouseY<174 && isServicesOpen) {
    isServicesOpen=false;
  }

  // =========================
  // PetAI Panel Clicks
  // =========================
  if (isPetAIOpen) {
    // Close X -- rect(AI_X2-47, AI_Y1+3, AI_X2-5, AI_Y1+37) = (973, 75, 1015, 109)
    if (mouseX > 973 && mouseX < 1015 && mouseY > 75 && mouseY < 109) {
      closePetAIPanel();
      return;
    }

    // Send button -- rect(AI_X2-100, AI_INPUT_Y+6, AI_X2-6, AI_Y2-6) = (920, 581, 1014, 642)
    if (mouseX > 920 && mouseX < 1014 && mouseY > 581 && mouseY < 642 && aiSelectedSession < 0) {
      sendPetAIMessage();
      return;
    }

    // Back / Resume buttons (visible when viewing a saved session)
    // Panel input area: x 266-1014, y 581-642. Split at midX = 260 + (1020-260)/2 = 640
    if (mouseY > 581 && mouseY < 642 && aiSelectedSession >= 0) {
      float midX = AI_SIDEBAR_X + (AI_X2 - AI_SIDEBAR_X) / 2.0f; // = 640
      if (mouseX > AI_SIDEBAR_X + 6 && mouseX < midX - 3) {
        // Back -- return to current chat
        aiSelectedSession = -1;
        return;
      }
      if (mouseX > midX + 3 && mouseX < AI_X2 - 6) {
        // Resume -- load this saved session into currentChat
        if (currentChat.size() > 0) {
          // Archive the current chat first
          String sessionName = "Session " + (savedSessions.size() + 1);
          for (String[] m : currentChat) {
            if (m[0].equals("user")) {
              sessionName = m[1].length() > 28 ? m[1].substring(0, 28) + "..." : m[1];
              break;
            }
          }
          String[] packed = new String[1 + currentChat.size() * 2];
          packed[0] = sessionName;
          for (int i = 0; i < currentChat.size(); i++) {
            packed[1 + i * 2]     = currentChat.get(i)[0];
            packed[1 + i * 2 + 1] = currentChat.get(i)[1];
          }
          savedSessions.add(packed);
        }
        // Load selected session as current chat
        currentChat = extractSessionMessages(savedSessions.get(aiSelectedSession));
        savedSessions.remove(aiSelectedSession);
        aiSelectedSession = -1;
        aiChatScroll = Float.MAX_VALUE;
        return;
      }
    }

    // Sidebar session entries -- click to view a saved session or return to current
    if (mouseX > AI_X1 && mouseX < AI_SIDEBAR_X && mouseY > AI_Y1 + 48) {
      float entryH      = 44;
      float entryStartY = AI_Y1 + 48;

      // Current chat tab (first slot if active chat has messages)
      if (currentChat.size() > 0) {
        float ey = entryStartY - aiSidebarScroll;
        if (mouseY > ey && mouseY < ey + entryH) {
          aiSelectedSession = -1;
          aiChatScroll = Float.MAX_VALUE;
          return;
        }
        entryStartY += entryH;
      }

      int   count = savedSessions.size();
      for (int i = count - 1; i >= 0; i--) {
        int   dispIdx = count - 1 - i;
        float ey      = entryStartY + dispIdx * entryH - aiSidebarScroll;
        if (mouseY > ey && mouseY < ey + entryH) {
          aiSelectedSession = (aiSelectedSession == i) ? -1 : i;
          aiChatScroll = Float.MAX_VALUE;
          return;
        }
      }
    }
  }
}



// =========================
// Key Press Handler
// Routes key events to the active minigame.
// State is cached at the top so each flag is read once per event instead of
// once per key-check -- keeps the conditionals short and avoids repeated lookups.
// =========================
void keyPressed() {
  // Socials caption typing
  if (isSocialsTyping) {
    if (key == ENTER || key == RETURN) {
      isSocialsTyping = false;
    } else if (key == BACKSPACE) {
      if (postCaptionText.length() > 0)
        postCaptionText = postCaptionText.substring(0, postCaptionText.length() - 1);
    } else if (key != CODED && postCaptionText.length() < 120) {
      postCaptionText += key;
    }
    return;
  }

  // PetAI chat input -- intercept all keypresses when the panel is open and not viewing history
  if (isPetAIOpen && aiSelectedSession < 0) {
    if (key == ENTER || key == RETURN) {
      sendPetAIMessage();
    } else if (key == BACKSPACE) {
      if (aiInputText.length() > 0) aiInputText = aiInputText.substring(0, aiInputText.length() - 1);
    } else if (key != CODED) {
      aiInputText += key;
    }
    return; // don't let keypress bleed into minigame controls
  }

  // Cache which minigame is currently active (evaluated once, used by every binding below)
  boolean inSnatch = isEnterSnackSnatch;
  boolean inFetch  = isEnterFetchFrenzy;

  // Swamp Hop: SPACE to jump (only when the alligator is on the ground)
  if (key == ' ' && isSwampHopOnGround) {
    hopVelocityY = -hopJumpStrength;
    isSwampHopOnGround = false;
  }

  // Snack Snatch: A/D or left/right arrows set horizontal movement flags
  if (inSnatch) {
    if (key == 'a' || key == 'A' || keyCode == LEFT)  isMoveLeft  = true;
    if (key == 'd' || key == 'D' || keyCode == RIGHT) isMoveRight = true;
  }

  // Fetch Frenzy: WASD or arrow keys set the alligator's facing direction
  if (inFetch) {
    if (key == 'a' || key == 'A' || keyCode == LEFT)  fetchFacingDirection = "LEFT";
    if (key == 'd' || key == 'D' || keyCode == RIGHT) fetchFacingDirection = "RIGHT";
    if (key == 'w' || key == 'W' || keyCode == UP)    fetchFacingDirection = "UP";
    if (key == 's' || key == 'S' || keyCode == DOWN)  fetchFacingDirection = "DOWN";
  }
}

// =========================
// Key Release Handler
// Clears Snack Snatch movement flags when directional keys are released,
// stopping continuous horizontal movement.
// =========================
void keyReleased() {
  if (isEnterSnackSnatch) {
    if (key == 'a' || key == 'A' || keyCode == LEFT)  isMoveLeft  = false;
    if (key == 'd' || key == 'D' || keyCode == RIGHT) isMoveRight = false;
  }
}

// =========================
// Mouse Drag Handler
// Handles dragging the bank and achievements scrollbar thumbs
// =========================
void mouseDragged() {
  if (cp5.isMouseOver()) return;

  if (isDraggingEvScrollbar) {
    float evContentH  = 20 + 5 * evItemH;
    float evMaxScroll = max(0, evContentH - evViewportH);
    if (evMaxScroll > 0) {
      float evThumbH   = max(40, (evViewportH / evContentH) * evScrollbarH);
      float newThumbY  = constrain(mouseY - evScrollThumbOffset,
                                   evScrollbarY, evScrollbarY + evScrollbarH - evThumbH);
      evScrollOffset = map(newThumbY, evScrollbarY, evScrollbarY + evScrollbarH - evThumbH,
                           0, evMaxScroll);
    }
  }

  if (isDraggingBankScrollbar) {
    float bankmaxScroll = max(0, bankScrollContentHeight - bankViewportHeight);
    if (bankmaxScroll > 0) {
      float bankthumbH = max(40, (bankViewportHeight / bankScrollContentHeight) * bankScrollbarHeight);

      float banknewThumbY = mouseY - bankScrollThumbOffsetY;
      banknewThumbY = constrain(banknewThumbY, bankScrollbarY, bankScrollbarY + bankScrollbarHeight - bankthumbH);

      bankScrollOffset = map(banknewThumbY, bankScrollbarY, bankScrollbarY + bankScrollbarHeight - bankthumbH, 0, bankmaxScroll);
    }
  }

  if (isDraggingAchievementScrollbar) {
    float achvmaxScroll = max(0, achievementScrollContentHeight - achievementViewportHeight);
    if (achvmaxScroll > 0) {
      float achvthumbH = max(40, (achievementViewportHeight / achievementScrollContentHeight) * achievementScrollbarHeight);

      float achvnewThumbY = mouseY - achievementScrollThumbOffsetY;
      achvnewThumbY = constrain(achvnewThumbY, achievementScrollbarY, achievementScrollbarY + achievementScrollbarHeight - achvthumbH);

      achievementScrollOffset = map(achvnewThumbY, achievementScrollbarY, achievementScrollbarY + achievementScrollbarHeight - achvthumbH, 0, achvmaxScroll);
    }
  }
}

// =========================
// Mouse Wheel Handler
// Scrolls the bank transaction list or achievements panel when the cursor is over them
// =========================
void mouseWheel(MouseEvent event) {
  float e = event.getCount();

  if (mouseX >= bankViewportX && mouseX <= bankViewportX + bankViewportWidth &&
      mouseY >= bankViewportY && mouseY <= bankViewportY + bankViewportHeight && isBankOpen) {
    bankScrollContentHeight = 190 + filteredBankLog.size() * bankItemLineHeight;
    float bankMaxScroll = max(0, bankScrollContentHeight - bankViewportHeight);

    bankScrollOffset += e * 20;
    bankScrollOffset = constrain(bankScrollOffset, 0, bankMaxScroll);
  }

  if (mouseX >= achievementViewportX && mouseX <= achievementViewportX + achievementViewportWidth &&
      mouseY >= achievementViewportY && mouseY <= achievementViewportY + achievementViewportHeight && isAchievementsOpen) {
    achievementScrollContentHeight = 20 + 30 * achievementItemLineHeight;
    float achvMaxScroll = max(0, achievementScrollContentHeight - achievementViewportHeight);

    achievementScrollOffset += e * 20;
    achievementScrollOffset = constrain(achievementScrollOffset, 0, achvMaxScroll);
  }

  // Evolution panel scroll
  if (isEvolutionOpen &&
      mouseX >= evViewportX && mouseX <= evViewportX + evViewportW &&
      mouseY >= evViewportY && mouseY <= evViewportY + evViewportH) {
    float evContentH  = 20 + 5 * evItemH;
    float evMaxScroll = max(0, evContentH - evViewportH);
    evScrollOffset = constrain(evScrollOffset + e * 20, 0, evMaxScroll);
  }

  // Socials past posts scroll
  if (isSocialsOpen && isSocialsPastView && socialsPlatform >= 0) {
    int p = socialsPlatform;
    ArrayList<String[]> log = getPlatformPostLog(p);
    float contentH = log.size() * 96 + 10;
    float maxScroll = max(0, contentH - 370);
    pastPostsScroll[p] = constrain(pastPostsScroll[p] + e * 20, 0, maxScroll);
  }

  // PetAI chat scroll (main chat area: x 260-1020, y 116-575)
  if (isPetAIOpen && mouseX > 260 && mouseX < 1020 && mouseY > 116 && mouseY < 575) {
    aiChatScroll += e * 25;
    aiChatScroll = max(0, aiChatScroll);
  }

  // PetAI sidebar scroll (x 80-260)
  if (isPetAIOpen && mouseX > 80 && mouseX < 260) {
    aiSidebarScroll += e * 20;
    aiSidebarScroll = max(0, aiSidebarScroll);
  }
}

// =========================
// Mouse Release Handler
// Ends any active scrollbar drag when the mouse button is released
// =========================
void mouseReleased() {
  isDraggingBankScrollbar        = false;
  isDraggingAchievementScrollbar = false;
  isDraggingEvScrollbar          = false;
}
