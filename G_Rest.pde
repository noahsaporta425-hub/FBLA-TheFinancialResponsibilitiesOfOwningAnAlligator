// =========================
// G_Rest.pde
// Rest panel rendering: gradient bar, bouncing marker, and rest button.
// =========================


// =========================
// Rest State
// =========================
boolean isRestOpen = false;
boolean hasUsedRest = false;
boolean hasAlligatorRestedOnce = false;
boolean isShowingRestPopup = false;
boolean hasShownRestPopup = false;

int restAttemptsRemaining = 2;
int restAttempts = 0;
int timesRestedSuccessfully = 0;
float totalEnergyRestoredFromResting = 0;

float restBarCenterX = 439;
float restBarCenterY = 490;
float restBarWidth = 220;
float restBarHeight = 30;
float restBarLeft   = restBarCenterX - restBarWidth  / 2;
float restBarTop    = restBarCenterY - restBarHeight / 2;
float restBarBottom = restBarCenterY + restBarHeight / 2;

int COLOR_RED    = color(255, 0, 0);
int COLOR_ORANGE = color(255, 165, 0);
int COLOR_YELLOW = color(255, 255, 0);
int COLOR_GREEN  = color(0, 255, 0);

float restMarkerProgress  = 0;
float restMarkerDirection = 1;
float restMarkerX         = restBarLeft;


// =========================
// Rest Popup
// =========================
void restpopup() {
  imageMode(CENTER);
  image(popupbackground, width/2, height*0.42f, popupbackground.width*0.6f, popupbackground.height*0.6f);
  fill(0);
  textFont(times50);
  textSize(20);
  drawWrappedTextInBox("Seems like " + alligator.petName + " is tired. Click rest after closing this window to attempt to stabilize his energy.", 338, 271, 761, 400, 6);
}


// =========================
// Rest Panel
// =========================
void rest() {
  rectMode(CENTER);
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(439, 490, 320, 90);

  int pixelSize = 5;
  rectMode(CORNER);
  noStroke();

  for (int px = 0; px < restBarWidth; px += pixelSize) {
    float position = px / restBarWidth;
    int gradientColor;

    if (position < 0.25f) {
      gradientColor = lerpColor(COLOR_RED, COLOR_ORANGE, map(position, 0, 0.25f, 0, 1));
    } else if (position < 0.4f) {
      gradientColor = lerpColor(COLOR_ORANGE, COLOR_YELLOW, map(position, 0.25f, 0.4f, 0, 1));
    } else if (position < 0.5f) {
      gradientColor = lerpColor(COLOR_YELLOW, COLOR_GREEN, map(position, 0.4f, 0.5f, 0, 1));
    } else if (position < 0.6f) {
      gradientColor = lerpColor(COLOR_GREEN, COLOR_YELLOW, map(position, 0.5f, 0.6f, 0, 1));
    } else if (position < 0.75f) {
      gradientColor = lerpColor(COLOR_YELLOW, COLOR_ORANGE, map(position, 0.6f, 0.75f, 0, 1));
    } else {
      gradientColor = lerpColor(COLOR_ORANGE, COLOR_RED, map(position, 0.75f, 1, 0, 1));
    }

    fill(gradientColor);
    rect(restBarLeft + px, restBarTop, pixelSize, restBarHeight);
  }

  float edgeSlowdown = abs(restMarkerProgress - 0.5f) * 2.0f;
  float markerSpeed = map(edgeSlowdown, 0, 1, 0.03f, 0.008f);

  restMarkerProgress += markerSpeed * restMarkerDirection;

  if (restMarkerProgress >= 1) { restMarkerProgress = 1; restMarkerDirection = -1; }
  if (restMarkerProgress <= 0) { restMarkerProgress = 0; restMarkerDirection = 1; }

  restMarkerX = lerp(restBarLeft, restBarLeft + restBarWidth, restMarkerProgress);

  textSize(17);
  rectMode(CENTER);
  if (restAttemptsRemaining > 0) fill(0, 255, 0, 80);
  else fill(80, 220);
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
  rect(restMarkerX, restBarTop - 6, restMarkerX + 2, restBarBottom + 6);
  textSize(12);
  textAlign(CENTER);
  text("Poor", 309, 486);
  text("Rest", 309, 500);
  text("Poor", 569, 486);
  text("Rest", 569, 500);
  text("ATTEMPTS LEFT TODAY: " + restAttemptsRemaining, 439, 462);

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
