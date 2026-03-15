// =========================
// Pet Class
// Represents the player's virtual pet
// =========================

class Pet {

  // Pet identity
  String petName;
  PImage neutralalligator;
  PImage hungryalligator;
  PImage energeticalligator;
  PImage sickalligator;

  //Pet statistics
  float health = 100;
  float happiness = 100;
  float energy = 50;
  float sickrisk = 10;
  float hunger = 95;


  // Constructor: create a new pet with a given name
  Pet(String _petName) {
    petName = _petName;
  }

void neutralmood() {
  applyAlligatorTint();
  image(neutralalligator, width * 0.33, height * 0.45, 267 * 1.4, 187 * 1.4);
  noTint();
}

void hungrymood() {
  drawMoodSprite(hungryalligator);
}

void energeticmood() {
  drawMoodSprite(energeticalligator);
}

void sickmood() {
  drawMoodSprite(sickalligator);
}

void drawMoodSprite(PImage img) {
  applyAlligatorTint();
  imageMode(CENTER);
  image(img, 550, 452, img.width/4.2, img.height/4.2);
  imageMode(CORNER);
  noTint();
}

  void eat(String item) {
  if (item.equals("Steak")) {
      hunger-=70;
      energy+=40;
      health+=20;
      happiness+=20;
  } else {
    // Check medicine by index
    boolean foundMedicine = false;
    for (int i = 0; i < medicinestock.length; i++) {
      if (item.equals(medicinestock[i])) {
        if (presc[i]) {
          health += 20;
          energy += 10;
          happiness += 10;
          if (i == 0) firstmedicinegiven = true;
        } else {
          health -= 35;
          energy -= 10;
          happiness -= 10;
          sickrisk += 25;
        }
        foundMedicine = true;
        break;
      }
    }

    if (!foundMedicine) {
    if (item.equals("Nachos")) {
      hunger -= 40;
      health -= 15;
      happiness += 5;
      energy += 30;

    } else if (item.equals("Cheesepuffs")) {
      hunger -= 25;
      health -= 5;
      happiness += 20;
      energy += 10;

    } else if (item.equals("Chips")) {
      hunger -= 30;
      health -= 10;
      happiness += 10;
      energy += 10;

    } else if (item.equals("Chocolate Bar")) {
      hunger -= 7;
      health -= 5;
      happiness += 20;
      energy += 5;

    } else if (item.equals("Cookies")) {
      hunger -= 30;
      health -= 5;
      happiness += 10;
      energy += 5;

    } else if (item.equals("Crackers")) {
      hunger -= 5;
      energy += 20;

    } else if (item.equals("Energy Drink")) {
      hunger += 20;
      health -= 35;
      happiness -= 10;
      energy += 70;

    } else if (item.equals("Granola Bar")) {
      hunger -= 15;
      health -= 5;
      happiness += 5;
      energy += 20;

    } else if (item.equals("Popcorn")) {
      hunger -= 10;
      health -= 10;
      happiness += 30;
      energy += 10;

    } else if (item.equals("Pretzels")) {
      hunger -= 10;
      health -= 5;
      happiness += 5;
      energy += 15;

    } else if (item.equals("Soda")) {
      hunger += 30;
      health -= 30;
      happiness += 5;
      energy += 40;

    } else if (item.equals("Trail Mix")) {
      hunger -= 10;
      health -= 5;
      happiness += 5;
      energy += 20;

    } else if (item.equals("Bluegill")) {
      hunger -= 55;
      health += 15;
      happiness += 10;
      energy += 20;

    } else if (item.equals("Bass")) {
      hunger -= 60;
      health += 20;
      happiness += 10;
      energy += 25;

    } else if (item.equals("Perch")) {
      hunger -= 50;
      health += 20;
      happiness += 5;
      energy += 15;

    } else if (item.equals("Goldfish")) {
      hunger -= 30;
      health += 5;
      happiness += 15;
      energy += 10;

    } else if (item.equals("Crab")) {
      hunger -= 50;
      health += 25;
      happiness += 20;
      energy += 15;

    } else if (item.equals("Lamb Chop")) {
      hunger -= 70;
      health += 10;
      happiness += 15;
      energy += 35;

    } else if (item.equals("Pork Chop")) {
      hunger -= 65;
      health += 10;
      happiness += 10;
      energy += 30;

    } else if (item.equals("Chicken")) {
      hunger -= 60;
      health += 20;
      happiness += 10;
      energy += 20;

    } else if (item.equals("Catfish")) {
      hunger -= 60;
      health += 15;
      happiness += 10;
      energy += 25;

    } else if (item.equals("Frog")) {
      hunger -= 45;
      health += 15;
      happiness += 25;
      energy += 20;

    } else if (item.equals("Shrimp")) {
      hunger -= 35;
      health += 25;
      happiness += 15;
      energy += 10;
    }
    } // end !foundMedicine
  } // end else (not Steak)

  if (hunger < 0) hunger = 0;
  if (hunger > 100) hunger = 100;

  if (health < 0) health = 0;
  if (health > 100) health = 100;

  if (energy < 0) energy = 0;
  if (energy > 100) energy = 100;

  if (happiness < 0) happiness = 0;
  if (happiness > 100) happiness = 100;

  if (sickrisk < 20) sickrisk = 20;
  if (sickrisk > 100) sickrisk = 100;

  inventoryvisible = false;
}
}

// =========================
// Tint helper — applies color tint based on selected alligator skin
// Accessible globally from all files
// =========================
void applyAlligatorTint() {
  if (selectedAlligator == 1) tint(0, 255, 0, 255);
  else if (selectedAlligator == 2) tint(70, 130, 255, 255);
}
