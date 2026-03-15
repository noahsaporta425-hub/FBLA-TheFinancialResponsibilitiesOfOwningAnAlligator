boolean swampBox;
boolean isMedicine = false;
boolean isMeat = false;
void mousePressed() {
  boolean wasOnChoiceScreen = onchoicescreen;
  boolean wasEnteringSwamp = enterswamphop;
  boolean wasEnteringSnack = entersnacksnatch;
  boolean wasEnteringFetch = enterfetchfrenzy;

  println("---- CLICK ----");

  swampBox = (mouseX > 88 && mouseX < 373 && mouseY > 258 && mouseY < 658);

  if (homescreenvisible) {
    if (mouseX > width * 0.13f && mouseX < width * 0.37f &&
        mouseY > height * 0.67f && mouseY < height * 0.8f &&
        showmusicsettings == false) {
      showinstructions = true;
    }

    if (mouseX > width * 0.38f && mouseX < width * 0.61f &&
        mouseY > height * 0.67f && mouseY < height * 0.8f &&
        showmusicsettings == false && showinstructions == false) {
      homescreenvisible = false;
      cutscenestart = true;
    }

    if (mouseX > width * 0.615f && mouseX < width * 0.85f &&
        mouseY > height * 0.67f && mouseY < height * 0.8f &&
        showinstructions == false) {
      showmusicsettings = true;
    }

    if (mouseX > width * 0.785f && mouseX < width * 0.84f &&
        mouseY > height * 0.11f && mouseY < height * 0.185f) {
      showinstructions = false;
    }

    if (mouseX > width * 0.68f && mouseX < width * 0.73f &&
        mouseY > height * 0.41f && mouseY < height * 0.48f) {
      showmusicsettings = false;
    }
  }

  if (insideadoptioncenter == true) {
    if ((mouseX > 223 && mouseX < 350 &&
         mouseY > 450 && mouseY < 484) ||
        (mouseX > 229 && mouseX < 367 &&
         mouseY > 189 && mouseY < 426)) {
      dogadopted = true;
    }

    if ((mouseX > 768 && mouseX < 891 &&
         mouseY > 450 && mouseY < 482) ||
        (mouseX > 757 && mouseX < 871 &&
         mouseY > 227 && mouseY < 415)) {
      catadopted = true;
    }
  }
  
  if (inNaming) {
  
    if (mouseX > ((width * 0.27 - 300) + ((width / 2) * 0.9) / 2) - 60 &&
        mouseX < ((width * 0.27 - 300) + ((width / 2) * 0.9) / 2) + 60 &&
        mouseY > 659 - 17.5 &&
        mouseY < 659 + 17.5) {
      selectedAlligator = 0;
    }
  
    else if (mouseX > ((width * 0.27) + ((width / 2) * 0.9) / 2) - 60 &&
             mouseX < ((width * 0.27) + ((width / 2) * 0.9) / 2) + 60 &&
             mouseY > 659 - 17.5 &&
             mouseY < 659 + 17.5) {
      selectedAlligator = 1;
    }
  
    else if (mouseX > ((width * 0.27 + 300) + ((width / 2) * 0.9) / 2) - 60 &&
             mouseX < ((width * 0.27 + 300) + ((width / 2) * 0.9) / 2) + 60 &&
             mouseY > 659 - 17.5 &&
             mouseY < 659 + 17.5) {
      selectedAlligator = 2;
    }
  
  }

  if (onmainscreen == true) {
    
    if (mouseX>482 && mouseX<617 && mouseY>307 && mouseY<344 && showquit) {
      quit();
    }
    
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

    if (dist(mouseX, mouseY, 239.5f, 602) <= 49.5f &&
        !showrestpopup && !restclicked && welcomepopupvisible == false && !storeclicked &&
        !servicesclicked && !earnclicked && !bankclicked && onmainscreen &&
        !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup &&
        !showfirsthelppopup && !showtreatmentpopup && !showbankpopup && !showstoreclosedpopup && !nextdayclicked  && !showquit) {
      inventoryvisible = true;
      firstinventoryclick = true;
    }

    if (dist(mouseX, mouseY, 439, 602) <= 50 &&
        !restclicked && restpopupshown && !servicesclicked && !earnclicked && !storeclicked &&
        !bankclicked && onmainscreen && !showcantsell && !showplaypopup &&
        !showearnpopup && !showjobpopup && !showfirsthelppopup && !welcomepopupvisible &&
        !showtreatmentpopup && !showbankpopup && !showstoreclosedpopup && !nextdayclicked  && !showquit) {
      restclicked = true;
      firstrestclick = true;
    }

    if (dist(mouseX, mouseY, 861, 602) <= 50 &&
        !restclicked && welcomepopupvisible == false && !storeclicked &&
        !servicesclicked && !earnclicked && !bankclicked && onmainscreen &&
        !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup && !welcomepopupvisible &&
        !showfirsthelppopup && !showtreatmentpopup && !showbankpopup && !showstoreclosedpopup  && !nextdayclicked  && !showquit) {
      bankclicked = true;
      firstbankclick = true;
    }

    if (inventoryvisible && mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
      inventoryvisible = false;
    }

    if (playpopupShown == true && !restclicked && !bankclicked && showplaypopup == false &&
        dist(mouseX, mouseY, 656, 602) <= 49.5f && !servicesclicked && !earnclicked &&
        !inventoryvisible && onmainscreen && !showcantsell && !showplaypopup && !storeclicked &&
        !showearnpopup && !showjobpopup && !showfirsthelppopup && !welcomepopupvisible &&
        !showtreatmentpopup && !showbankpopup && !showstoreclosedpopup  && !nextdayclicked  && !showquit) {
      playclicked = true;
      exit = false;
      currentPlaySessionMoneyEarned = 0;
      enterswamphop = false;
      entersnacksnatch = false;
      enterfetchfrenzy = false;
      onchoicescreen = true;
    }
  }

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

        int medIndex = -1;
        for (int i = 0; i < medicinestock.length; i++) {
          if (medicinestock[i].equals(item)) {
            medIndex = i;
            break;
          }
        }

        int snackIndex = -1;
        for (int i = 0; i < snackstock.length; i++) {
          if (snackstock[i].equals(item)) {
            snackIndex = i;
            break;
          }
        }

        int meatIndex = -1;
        for (int i = 0; i < meatstock.length; i++) {
          if (meatstock[i].equals(item)) {
            meatIndex = i;
            break;
          }
        }

  if (medIndex != -1) {
    if (medQtys[medIndex] == 1) {
      inventoryslots[selectedSlot] = "EMPTY";
      medQtys[medIndex] = 0;
  
      for (int i = selectedSlot; i < inventoryslots.length - 1; i++) {
        inventoryslots[i] = inventoryslots[i + 1];
      }
      inventoryslots[inventoryslots.length - 1] = "EMPTY";
  
      if (selectedSlot >= inventoryslots.length) {
        selectedSlot = inventoryslots.length - 1;
      }
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
            inventoryslots[selectedSlot] = "EMPTY";
            snackQtys[snackIndex] = 0;

            for (int i = selectedSlot; i < inventoryslots.length - 1; i++) {
              inventoryslots[i] = inventoryslots[i + 1];
            }
            inventoryslots[inventoryslots.length - 1] = "EMPTY";

            if (selectedSlot >= inventoryslots.length) {
              selectedSlot = inventoryslots.length - 1;
            }
          } else {
            snackQtys[snackIndex] = snackQtys[snackIndex] - 1;
          }

          timesFedPet++;
          medicinegiven = false;

        } else if (meatIndex != -1) {
          if (meatQtys[meatIndex] == 1) {
            inventoryslots[selectedSlot] = "EMPTY";
            meatQtys[meatIndex] = 0;

            for (int i = selectedSlot; i < inventoryslots.length - 1; i++) {
              inventoryslots[i] = inventoryslots[i + 1];
            }
            inventoryslots[inventoryslots.length - 1] = "EMPTY";

            if (selectedSlot >= inventoryslots.length) {
              selectedSlot = inventoryslots.length - 1;
            }
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

  if (mouseX >= 780 && mouseX <= 954.875f &&
      mouseY >= 474.875f && mouseY <= 546 && inventoryvisible) {

    if (!fedsteak) {
      cantsell();
      showcantsell = true;

    } else {
      boolean isMedicine = false;
      boolean isSnack = false;
      boolean isMeat = false;

      for (int i = 0; i < 12; i++) {
        if (inventoryslots[selectedSlot].equals(medicinestock[i])) {
          isMedicine = true;
          break;
        }
      }

      for (int i = 0; i < 12; i++) {
        if (inventoryslots[selectedSlot].equals(snackstock[i])) {
          isSnack = true;
          break;
        }
      }

      for (int i = 0; i < 12; i++) {
        if (inventoryslots[selectedSlot].equals(meatstock[i])) {
          isMeat = true;
          break;
        }
      }

      if (isMedicine) {
        int medIndex = -1;

        for (int i = 0; i < medicinestock.length; i++) {
          if (inventoryslots[selectedSlot].equals(medicinestock[i])) {
            medIndex = i;
            break;
          }
        }

        if (medIndex != -1) {
          float sellPrice = 5 * 0.75f;

          money += sellPrice;
          totalMoneyEarned += sellPrice;
          bankTransactionsLoggedCount++;
          bankTransactions.add("Transaction: Sold " + medicinestock[medIndex] + " (+$" + nf(sellPrice, 0, 2) + ")");

          medQtys[medIndex] -= defaultQtys[medIndex];

          if (medQtys[medIndex] <= 0) {
            medQtys[medIndex] = 0;
            inventoryslots[selectedSlot] = "EMPTY";

            for (int i = selectedSlot; i < inventoryslots.length - 1; i++) {
              inventoryslots[i] = inventoryslots[i + 1];
            }
            inventoryslots[inventoryslots.length - 1] = "EMPTY";

            if (selectedSlot >= inventoryslots.length) {
              selectedSlot = inventoryslots.length - 1;
            }
          }
        }

      } else if (isSnack) {
        int snackIndex = -1;

        for (int i = 0; i < snackstock.length; i++) {
          if (inventoryslots[selectedSlot].equals(snackstock[i])) {
            snackIndex = i;
            break;
          }
        }

        if (snackIndex != -1) {
          float sellPrice = snackCosts[snackIndex] * 0.75f;

          money += sellPrice;
          totalMoneyEarned += sellPrice;
          bankTransactionsLoggedCount++;
          bankTransactions.add("Transaction: Sold " + snackstock[snackIndex] + " (+" + nf(sellPrice, 0, 2) + ")");

          snackQtys[snackIndex] -= 1;

          if (snackQtys[snackIndex] <= 0) {
            snackQtys[snackIndex] = 0;
            inventoryslots[selectedSlot] = "EMPTY";

            for (int i = selectedSlot; i < inventoryslots.length - 1; i++) {
              inventoryslots[i] = inventoryslots[i + 1];
            }
            inventoryslots[inventoryslots.length - 1] = "EMPTY";

            if (selectedSlot >= inventoryslots.length) {
              selectedSlot = inventoryslots.length - 1;
            }
          }
        }

      } else if (isMeat) {
        int meatIndex = -1;

        for (int i = 0; i < meatstock.length; i++) {
          if (inventoryslots[selectedSlot].equals(meatstock[i])) {
            meatIndex = i;
            break;
          }
        }

        if (meatIndex != -1) {
          float sellPrice = meatCosts[meatIndex] * 0.75f;

          money += sellPrice;
          totalMoneyEarned += sellPrice;
          bankTransactionsLoggedCount++;
          bankTransactions.add("Transaction: Sold " + meatstock[meatIndex] + " (+" + nf(sellPrice, 0, 2) + ")");

          meatQtys[meatIndex] -= 1;

          if (meatQtys[meatIndex] <= 0) {
            meatQtys[meatIndex] = 0;
            inventoryslots[selectedSlot] = "EMPTY";

            for (int i = selectedSlot; i < inventoryslots.length - 1; i++) {
              inventoryslots[i] = inventoryslots[i + 1];
            }
            inventoryslots[inventoryslots.length - 1] = "EMPTY";

            if (selectedSlot >= inventoryslots.length) {
              selectedSlot = inventoryslots.length - 1;
            }
          }
        }

      } else {
        inventoryslots[selectedSlot] = "EMPTY";

        for (int i = selectedSlot; i < inventoryslots.length - 1; i++) {
          inventoryslots[i] = inventoryslots[i + 1];
        }
        inventoryslots[inventoryslots.length - 1] = "EMPTY";

        if (selectedSlot >= inventoryslots.length) {
          selectedSlot = inventoryslots.length - 1;
        }
      }
    }
  }

  if (wasOnChoiceScreen && fadingout && !onmainscreen) {
    if (mouseX > 88 && mouseX < 373 && mouseY > 258 && mouseY < 658) {
      enterswamphop = true;
      entersnacksnatch = false;
      enterfetchfrenzy = false;
      onchoicescreen = false;
    } else if (mouseX > 403 && mouseX < 695 && mouseY > 257 && mouseY < 664) {
      entersnacksnatch = true;
      enterswamphop = false;
      enterfetchfrenzy = false;
      onchoicescreen = false;
    } else if (mouseX > 731 && mouseY > 263 && mouseX < 1013 && mouseY < 661) {
      enterfetchfrenzy = true;
      enterswamphop = false;
      entersnacksnatch = false;
      onchoicescreen = false;
    }
  }

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
    fadeInOpacity2 = 0;
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

  if (dist(mouseX, mouseY, 1044, 43) <= 36 &&
      !bankclicked  && !inventoryvisible && !servicesclicked && !storeclicked &&
      !showcantsell && !showplaypopup && !showearnpopup && !welcomepopupvisible && !showjobpopup &&
      !showfirsthelppopup && !showtreatmentpopup && !showrestpopup &&
      !showbankpopup && !showstoreclosedpopup  && !nextdayclicked && !earnclicked  && !showquit) {
    showquit=true;
  }

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
  
  println("x:", mouseX, "y:", mouseY);

  if (earnclicked == true) {

    // Main earn screen close
    if (!earnJobFinderOpen && !earnTasksOpen &&
        mouseX > 933 && mouseY < 171 && mouseX < 977 && mouseY > 132) {
      earnclicked = false;
    }

    // Main earn screen quit job
    if (!earnJobFinderOpen && !earnTasksOpen &&
        mouseX > 766 && mouseX < 866 && mouseY > 156 && mouseY < 256) {
      job = "unemployed";
      salary = 0;
      maxcashiersalary = false;
      salupgcost = 3;
    }

    // Main earn screen -> job finder
    if (!earnJobFinderOpen && !earnTasksOpen &&
        mouseX > 205 && mouseX < 455 && mouseY > 410 && mouseY < 500) {
      earnJobFinderOpen = true;
      earnTasksOpen = false;
      return;
    }

    // Main earn screen -> tasks and upgrades
    if (!earnJobFinderOpen && !earnTasksOpen &&
        mouseX > 610 && mouseX < 930 && mouseY > 410 && mouseY < 500) {
      earnTasksOpen = true;
      earnJobFinderOpen = false;
      firsttasktabclick=true;
      return;
    }

    // Job finder back
    if (earnJobFinderOpen &&
        mouseX > 863 && mouseX < 906 && mouseY > 155 && mouseY < 194.5f) {
      earnJobFinderOpen = false;
    }

    // Tasks screen back
    if (earnTasksOpen &&
        mouseX > 833 && mouseX < 876 && mouseY > 155 && mouseY < 194.5f) {
      earnTasksOpen = false;
    }

    // Apply cashier
    if (earnJobFinderOpen && job.equals("unemployed") &&
        mouseX > 260 && mouseX < 339 && mouseY > 478 && mouseY < 498) {
      job = "cashier";
      salary = 15;
    }

// Help button
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
    
        helppopuptext = "Uh oh! While you were off helping, " + alligator.petName + " was left unattended and I have bad news:" + sickness + ".";
      } 
      else {
        alligator.health -= 10;
    
        helppopuptext = "While you were helping around town, your already sick alligator  became weaker and lost 10 health.";
      }
    
      showfirsthelppopup = true;
    }
}

    // Salary upgrade
    
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
    
    // Task upgrade
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

  if (dist(mouseX, mouseY, 760, 602) < 50 &&
      !bankclicked && firsthelppopupshown == true && !inventoryvisible && !storeclicked &&
      !earnclicked && !showcantsell && !showplaypopup && !showearnpopup && !welcomepopupvisible &&
      !showjobpopup && !showfirsthelppopup && !showtreatmentpopup &&
      !showbankpopup && !showstoreclosedpopup  && !nextdayclicked && !showmusicsettings  && !showquit) {
    servicesclicked = true;
    firstservicesclick = true;
  }

  if (servicesclicked &&
      mouseX > 256.67f - 80 && mouseX < 256.67f + 80 &&
      mouseY > 480 && mouseY < 560) {
    vetclicked = true;
    servicesclicked = false;
  }

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

  boolean alreadyPrescribed =
    enrofloxacinPresc ||
    doxycyclinePresc ||
    oseltamivirPresc ||
    vitaminBComplexPresc ||
    cyproheptadinePresc ||
    potassiumChloridePresc ||
    coenzymeQ10Presc ||
    fluoxetinePresc ||
    trazodonePresc ||
    meloxicamPresc ||
    calciumCarbonatePresc ||
    activatedCharcoalPresc;

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

  if (dist(mouseX, mouseY, 337, 602) < 50 &&
      !bankclicked && treatmentpopupshown && !storeclicked &&
      !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup && !welcomepopupvisible &&
      !showfirsthelppopup && !showtreatmentpopup && !showbankpopup && (day%7!=0) && !showstoreclosedpopup  && !nextdayclicked  && !showquit) {
    storeclicked = true;
    onmainscreen = false;
    return;
  } else if (dist(mouseX, mouseY, 337, 602) < 50 &&
      !bankclicked && treatmentpopupshown && !storeclicked &&
      !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup && !welcomepopupvisible &&
      !showfirsthelppopup && !showtreatmentpopup && !showbankpopup && !showstoreclosedpopup  && !nextdayclicked  && !showquit) {
        showstoreclosedpopup=true;
  }

  if (mouseX > 627 && mouseX < 1070 && mouseY > 39 && mouseY < 88 && storeclicked && !buysnacks && !buymeat) {
    buymedicine = true;
  }

  if (mouseX > 28 && mouseX < 485 && mouseY > 33 && mouseY < 88 && storeclicked && !buymeat && !buymedicine) {
    buysnacks = true;
  }

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

  if (mouseX > 1000 && mouseX < 1100 && mouseY > 631 && mouseY < 684 && storeclicked && !buymedicine && !buysnacks && !buymeat) {
    storeclicked = false;
    onmainscreen = true;
    firstexitclick = true;
  }

  if (money >= 20 && mouseX > 599 && mouseY > 418 && mouseX < 720 && mouseY < 452 && vetclicked) {
    neverboughthighqualitycare = false;
    money -= 20;
    totalMoneySpent += 20;
    bankTransactionsLoggedCount++;
    bankTransactions.add("Transaction: 5 Star Vet (-$20.00)");
    timesUsedVetCare++;
    highQualityCareCount++;
    vetclicked = false;
  
    boolean alreadyPrescribed =
      enrofloxacinPresc ||
      doxycyclinePresc ||
      oseltamivirPresc ||
      vitaminBComplexPresc ||
      cyproheptadinePresc ||
      potassiumChloridePresc ||
      coenzymeQ10Presc ||
      fluoxetinePresc ||
      trazodonePresc ||
      meloxicamPresc ||
      calciumCarbonatePresc ||
      activatedCharcoalPresc;
  
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

  if (dist(mouseX, mouseY, 1045, 232) <= 43 &&
      !showrestpopup && !restclicked && welcomepopupvisible == false &&
      !servicesclicked && !earnclicked && !bankclicked && onmainscreen &&
      !showcantsell && !showplaypopup && !showearnpopup && !showjobpopup &&
      !showfirsthelppopup && !showtreatmentpopup && !showbankpopup && !welcomepopupvisible &&
      !inventoryvisible && !storeclicked && !showstoreclosedpopup  && !nextdayclicked  && !showquit) {
    achievementsclicked = true;
    firstachievementsclick = true;
  }
  
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
  
  if (storeclicked && !buymedicine && !buysnacks && mouseX>304 && mouseY>591 && mouseX<777 && mouseY<654) {
    buymeat=true;
  }
  
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
    // changes stats + builds text after
  }
  
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

  if (mouseX>931 && mouseX<979 && mouseY>132 && mouseY<174 && servicesclicked) {
    servicesclicked=false;
  }
}


boolean moveLeft = false;
boolean moveRight = false;

 void keyPressed() {
  if (key == ' ' && isOnGround) {
    velocityY = -jumpStrength;
    isOnGround = false;
  }

  if ((key == 'a' || key == 'A' || keyCode == LEFT) && entersnacksnatch) {
    moveLeft = true;
  }

  if ((key == 'd' || key == 'D' || keyCode == RIGHT) && entersnacksnatch) {
    moveRight = true;
  }

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

  if (key == 'y') {
    money += 1000;
  }

  if (key == 'z') {
    alligator.energy -= 50;
  }

  if (key == 'x') {
    println("selectedSlot = " + selectedSlot);
println("presc length = " + presc.length);

if (selectedSlot >= 0 && selectedSlot < presc.length) {
  println("medicinestock[selectedSlot] = " + medicinestock[selectedSlot]);
  println("presc[selectedSlot] = " + presc[selectedSlot]);
}
  }
}

 void keyReleased() {
  if ((key == 'a' || key == 'A' || keyCode == LEFT) && entersnacksnatch) {
    moveLeft = false;
  }

  if ((key == 'd' || key == 'D' || keyCode == RIGHT) && entersnacksnatch) {
    moveRight = false;
  }
}

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

 void mouseReleased() {
  draggingBankScrollbar = false;
  draggingAchvScrollbar = false;
}
