// =========================
// G_Socials.pde
// Social media system: post trick videos to TikTok, Instagram, and YouTube.
// Build followers, earn money, and track your alligator's fame!
// =========================

// =========================
// State
// =========================
boolean isSocialsOpen      = false;
int     socialsPlatform    = -1;   // -1=hub, 0=TikTok, 1=Instagram, 2=YouTube
boolean isSocialsPostView  = false;
boolean isSocialsPastView  = false;

// Platform data (index: 0=TikTok, 1=Instagram, 2=YouTube)
int[]   platformFollowers       = {0, 0, 0};
float[] platformPendingEarnings = {0.0f, 0.0f, 0.0f};

ArrayList<String[]> tikTokPostLog   = new ArrayList<String[]>();
ArrayList<String[]> instaPostLog    = new ArrayList<String[]>();
ArrayList<String[]> ytPostLog       = new ArrayList<String[]>();

// Thumbnail images stored alongside each post (parallel lists, same index)
ArrayList<PImage> tikTokPostImages = new ArrayList<PImage>();
ArrayList<PImage> instaPostImages  = new ArrayList<PImage>();
ArrayList<PImage> ytPostImages     = new ArrayList<PImage>();

// Fame (0-100), driven by total followers across all platforms
float fame = 0;
final float FAME_MAX_FOLLOWERS = 3000.0f; // total followers for 100% fame

// Post creation state
int    selectedPostTrick  = -1;
String postCaptionText    = "";
boolean isSocialsTyping   = false;
boolean isShowingPostResult = false;
String  postResultType    = "";   // "Flop" "Okay" "Great" "Viral"
float   postResultEarnings = 0;
int     postResultFollowerChange = 0;

// Scroll offsets for past posts lists
float[] pastPostsScroll = {0, 0, 0};

// Platform colors / names
String[] platformNames = {"TikTok", "Instagram", "YouTube"};

// Trick selector scroll
float trickSelectorScroll = 0;


// =========================
// computeFame()
// Recalculates fame from total follower count.
// =========================
void computeFame() {
  int total = platformFollowers[0] + platformFollowers[1] + platformFollowers[2];
  fame = min(100, (total / FAME_MAX_FOLLOWERS) * 100.0f);
}


// =========================
// getFollowerLabel(n)
// Returns "1.2K" style short label for follower counts.
// =========================
String getFollowerLabel(int n) {
  if (n >= 1000000) return nf(n / 1000000.0f, 0, 1) + "M";
  if (n >= 1000)    return nf(n / 1000.0f, 0, 1) + "K";
  return str(n);
}


// =========================
// getPlatformPostLog(p)
// Returns the correct post log for platform index p.
// =========================
ArrayList<String[]> getPlatformPostLog(int p) {
  if (p == 0) return tikTokPostLog;
  if (p == 1) return instaPostLog;
  return ytPostLog;
}


// =========================
// getPlatformPostImages(p)
// Returns the correct post image list for platform index p.
// =========================
ArrayList<PImage> getPlatformPostImages(int p) {
  if (p == 0) return tikTokPostImages;
  if (p == 1) return instaPostImages;
  return ytPostImages;
}


// =========================
// handlePost(platform)
// Processes a new post: calculates result, updates followers/earnings/log.
// =========================
void handlePost(int p) {
  if (selectedPostTrick < 0) return;

  // --- Determine result ---
  float baseRoll     = random(0, 100);
  float trickBonus   = trickUnlockDays[selectedPostTrick] * 2.5f;  // later trick = higher bonus
  float followerBonus = min(20, log(platformFollowers[p] + 2) * 3.5f);
  float totalScore   = baseRoll + trickBonus + followerBonus;

  boolean isViral = random(1) < 0.04f;    // 4% chance regardless
  boolean isFlop  = !isViral && random(1) < 0.06f && platformFollowers[p] > 30;

  String result;
  if (isViral)          result = "Viral";
  else if (isFlop)      result = "Flop";
  else if (totalScore > 80) result = "Great";
  else if (totalScore > 42) result = "Okay";
  else                   result = "Flop";

  // --- Follower change ---
  int followerDelta = 0;
  switch (result) {
    case "Flop":  followerDelta = -max(1, (int)(platformFollowers[p] * 0.04f)); break;
    case "Okay":  followerDelta = 5  + (int)(platformFollowers[p] * 0.08f);    break;
    case "Great": followerDelta = 12 + (int)(platformFollowers[p] * 0.22f);    break;
    case "Viral": followerDelta = 80 + (int)(platformFollowers[p] * 0.80f)
                                     + (int)random(50, 200);                   break;
  }
  platformFollowers[p] = max(0, platformFollowers[p] + followerDelta);
  computeFame();

  // --- Earnings ---
  float earnings = 0;
  switch (result) {
    case "Flop":  earnings = 0;                                                             break;
    case "Okay":  earnings = 1.5f + log(platformFollowers[p] + 2) * 1.8f;                  break;
    case "Great": earnings = 4.0f + log(platformFollowers[p] + 2) * 5.0f;                  break;
    case "Viral": earnings = 30.0f + log(platformFollowers[p] + 2) * 12.0f + random(20, 80); break;
  }
  earnings = (float)Math.round(earnings * 100) / 100.0f;
  platformPendingEarnings[p] += earnings;

  // --- Log the post ---
  String caption = postCaptionText.length() > 50
    ? postCaptionText.substring(0, 47) + "..."
    : postCaptionText;
  String follStr = (followerDelta >= 0 ? "+" : "") + followerDelta;
  getPlatformPostLog(p).add(0, new String[]{
    "Day " + day,
    trickNames[selectedPostTrick],
    caption.length() == 0 ? "(no caption)" : caption,
    result,
    follStr,
    "$" + nf(earnings, 0, 2)
  });

  // --- Create post thumbnail at platform-specific aspect ratio (center-crop, never stretch) ---
  // mainscreen source is 1536x1024.
  int thumbW, thumbH;
  int bgSX, bgSY, bgEX, bgEY;
  if (p == 0) {          // TikTok: portrait 9:16  (576x1024 center crop)
    thumbW = 90;  thumbH = 160;
    bgSX = 480; bgSY = 0; bgEX = 1056; bgEY = 1024;
  } else if (p == 1) {   // Instagram: square 1:1  (1024x1024 center crop)
    thumbW = 200; thumbH = 200;
    bgSX = 256; bgSY = 0; bgEX = 1280; bgEY = 1024;
  } else {               // YouTube: landscape 16:9  (1536x864 center crop)
    thumbW = 288; thumbH = 162;
    bgSX = 0; bgSY = 80; bgEX = 1536; bgEY = 944;
  }
  PGraphics thumb = createGraphics(thumbW, thumbH);
  thumb.beginDraw();
  thumb.imageMode(CORNER);
  thumb.image(mainscreen, 0, 0, thumbW, thumbH, bgSX, bgSY, bgEX, bgEY);
  if (trickImages[selectedPostTrick] != null) {
    int[] cb = trickContentBounds[selectedPostTrick];
    int sx = cb[0], sy = cb[1], ex = cb[2], ey = cb[3];
    float sw = ex - sx, sh = ey - sy;
    float scale = min(thumbW / sw, thumbH / sh);
    float dw = sw * scale;
    float dh = sh * scale;
    thumb.imageMode(CORNER);
    thumb.image(trickImages[selectedPostTrick],
                (thumbW - dw) * 0.5f, (thumbH - dh) * 0.5f, dw, dh,
                sx, sy, ex, ey);
  }
  thumb.endDraw();
  getPlatformPostImages(p).add(0, thumb);

  // --- Show result popup ---
  postResultType            = result;
  postResultEarnings        = earnings;
  postResultFollowerChange  = followerDelta;
  isShowingPostResult       = true;

  // Reset post state
  selectedPostTrick = -1;
  postCaptionText   = "";
  isSocialsTyping   = false;
  isSocialsPostView = false;
}


// =========================
// collectPlatformEarnings(p)
// Moves pending platform earnings into the player's money.
// =========================
void collectPlatformEarnings(int p) {
  if (platformPendingEarnings[p] <= 0) return;
  float amt = platformPendingEarnings[p];
  platformPendingEarnings[p] = 0;
  money                     += amt;
  totalMoneyEarned          += amt;
  bankTransactionsLoggedCount++;
  bankTransactionLog.add("Transaction: " + platformNames[p] + " Earnings (+$" + nf(amt, 0, 2) + ")");
}


// =========================
// socialsPanel()
// Top-level router: hub, platform view, post view, or past posts.
// =========================
void socialsPanel() {
  computeFame();

  if (isShowingPostResult) {
    drawPostResultPopup();
    return;
  }

  if (socialsPlatform < 0) {
    drawSocialsHub();
  } else if (isSocialsPostView) {
    drawNewPostView();
  } else if (isSocialsPastView) {
    drawPastPostsView();
  } else {
    drawPlatformHome();
  }
}


// =========================
// drawSocialsHub()
// Main hub: fame bar, three platform cards, close button.
// =========================
void drawSocialsHub() {
  // --- Outer panel ---
  rectMode(CORNERS);
  stroke(180, 100, 255);
  strokeWeight(5);
  fill(20, 15, 35, 235);
  rect(310, 122.5f, 790, 572.5f);
  line(310, 182, 790, 182);

  // Title
  textAlign(CENTER, CENTER);
  fill(220, 170, 255);
  textFont(arcade);
  textSize(26);
  text("SOCIALS", width / 2.0f, 152);

  // X close button (centered in its box)
  noFill();
  stroke(180, 100, 255);
  strokeWeight(3);
  rectMode(CORNERS);
  rect(733, 132, 776, 171.5f);
  fill(210, 170, 255);
  textFont(arcade);
  textSize(28);
  textAlign(CENTER, CENTER);
  text("X", 754.5f, 151.75f);

  // --- Fame bar ---
  rectMode(CORNER);
  noStroke();
  float fbX = 330;
  float fbY = 192;
  float fbW = 400;
  float fbH = 22;
  float fameLabelW = 65;

  // FAME: label right-aligned immediately before the bar
  fill(255);
  textFont(arcade);
  textSize(12);
  textAlign(RIGHT, CENTER);
  text("FAME:", fbX + fameLabelW, fbY + fbH / 2);

  // Bar track
  float barStartX = fbX + fameLabelW + 8;
  float barTrackW = fbW - fameLabelW - 8;
  fill(40, 30, 55);
  rect(barStartX, fbY, barTrackW, fbH, 5);
  if (fame > 0) {
    fill(255, 220, 50);
    rect(barStartX, fbY, barTrackW * (fame / 100.0f), fbH, 5);
  }
  fill(255);
  textFont(times30);
  textSize(11);
  textAlign(CENTER, CENTER);
  text((int)fame + "%", barStartX + barTrackW / 2, fbY + fbH / 2);

  // Total followers directly below bar, white, left-aligned at bar start
  int totalFollowers = platformFollowers[0] + platformFollowers[1] + platformFollowers[2];
  fill(255);
  textFont(times30);
  textSize(11);
  textAlign(LEFT, CENTER);
  text("Total followers: " + getFollowerLabel(totalFollowers), barStartX, fbY + fbH + 14);

  // --- Platform cards ---
  // Centered: 3 cards of width 130 with 35px gaps and 10px margins within the 480px panel
  int[] cardColors   = {0xff12062a, 0xff2a0818, 0xff1a0800};
  int[] accentColors = {0xff8B5CF6, 0xffE91E63, 0xffFF0000};
  String[] platformIcons = {"TT", "IG", "YT"};

  for (int i = 0; i < 3; i++) {
    float cx = 385 + i * 165;
    float cy = 355;
    float cw = 130;
    float ch = 240;   // increased from 200 for better internal margins

    // Card
    fill(cardColors[i]);
    stroke(accentColors[i]);
    strokeWeight(3);
    rectMode(CENTER);
    rect(cx, cy, cw, ch, 12);

    // Platform badge
    fill(accentColors[i]);
    noStroke();
    ellipse(cx, cy - 82, 52, 52);
    fill(255);
    textFont(arcade);
    textSize(13);
    textAlign(CENTER, CENTER);
    text(platformIcons[i], cx, cy - 82);

    // Platform name
    fill(255);
    textFont(arcade);
    textSize(11);
    text(platformNames[i].toUpperCase(), cx, cy - 50);

    // Followers
    fill(180, 200, 220);
    textFont(times30);
    textSize(10);
    text("Followers", cx, cy - 30);
    fill(255);
    textFont(arcade);
    textSize(14);
    text(getFollowerLabel(platformFollowers[i]), cx, cy - 12);

    // Pending earnings
    fill(180, 220, 180);
    textFont(times30);
    textSize(10);
    text("Pending", cx, cy + 10);
    fill(platformPendingEarnings[i] > 0 ? color(100, 255, 140) : color(140));
    textFont(arcade);
    textSize(11);
    text("$" + nf(platformPendingEarnings[i], 0, 2), cx, cy + 28);

    // OPEN button
    fill(accentColors[i]);
    stroke(255, 50);
    strokeWeight(1);
    rectMode(CENTER);
    rect(cx, cy + 52, 108, 30, 6);
    fill(255);
    textFont(arcade);
    textSize(9);
    textAlign(CENTER, CENTER);
    text("OPEN", cx, cy + 52);

    // COLLECT button (spaced well below OPEN)
    if (platformPendingEarnings[i] > 0) {
      fill(50, 160, 80);
      stroke(30, 120, 50);
    } else {
      fill(50, 50, 55);
      stroke(70, 70, 75);
    }
    rect(cx, cy + 88, 108, 30, 6);
    fill(255);  // always white text
    textFont(arcade);
    textSize(9);
    text(platformPendingEarnings[i] > 0 ? "$ COLLECT" : "COLLECT", cx, cy + 88);
    rectMode(CORNER);
  }

  strokeWeight(2);
  stroke(0);
  noFill();
}


// =========================
// drawPlatformHome()
// Per-platform home: shows followers, nav buttons, styled to each platform.
// =========================
void drawPlatformHome() {
  int p = socialsPlatform;
  setPlatformStyle(p);
  drawPlatformPanel(p);

  // Back button
  drawBackButton();

  // Platform name / header
  fill(getPlatformAccentColor(p));
  textFont(arcade);
  textSize(22);
  textAlign(CENTER, CENTER);
  text(platformNames[p].toUpperCase(), width / 2.0f, 152);

  float panelTop = 195;

  // Follower count display
  fill(getPlatformTextColor(p));
  textFont(times30);
  textSize(12);
  textAlign(CENTER, CENTER);
  text("FOLLOWERS", width / 2.0f, panelTop + 30);
  fill(getPlatformAccentColor(p));
  textFont(arcade);
  textSize(36);
  text(getFollowerLabel(platformFollowers[p]), width / 2.0f, panelTop + 65);

  // Pending earnings
  if (platformPendingEarnings[p] > 0) {
    fill(80, 220, 110);
    textFont(arcade);
    textSize(12);
    text("$" + nf(platformPendingEarnings[p], 0, 2) + " ready to collect!", width / 2.0f, panelTop + 100);

    // Collect button
    fill(50, 180, 80);
    stroke(30, 130, 55);
    strokeWeight(2);
    rectMode(CENTER);
    rect(width / 2.0f, panelTop + 125, 160, 34, 8);
    fill(255);
    textFont(arcade);
    textSize(11);
    textAlign(CENTER, CENTER);
    text("COLLECT $" + nf(platformPendingEarnings[p], 0, 2), width / 2.0f, panelTop + 125);
    rectMode(CORNER);
    noStroke();
  } else {
    fill(getPlatformSubtextColor(p));
    textFont(times30);
    textSize(11);
    textAlign(CENTER, CENTER);
    text("No earnings pending", width / 2.0f, panelTop + 105);
  }

  // Divider
  stroke(getPlatformAccentColor(p), 80);
  strokeWeight(1);
  line(335, panelTop + 155, 765, panelTop + 155);
  noStroke();

  // NEW POST button
  fill(getPlatformAccentColor(p));
  stroke(255, 40);
  strokeWeight(1);
  rectMode(CENTER);
  rect(width / 2.0f - 90, panelTop + 200, 155, 48, 10);
  fill(255);
  textFont(arcade);
  textSize(12);
  textAlign(CENTER, CENTER);
  text("NEW POST", width / 2.0f - 90, panelTop + 200);

  // PAST POSTS button
  fill(30, 40);
  stroke(getPlatformAccentColor(p), 120);
  strokeWeight(2);
  rect(width / 2.0f + 90, panelTop + 200, 155, 48, 10);
  fill(getPlatformTextColor(p));
  textFont(arcade);
  textSize(11);
  textAlign(CENTER, CENTER);
  int postCount = getPlatformPostLog(p).size();
  text("PAST POSTS (" + postCount + ")", width / 2.0f + 90, panelTop + 200);

  // Post tip
  fill(getPlatformSubtextColor(p));
  textFont(times30);
  textSize(10);
  text("Tip: Rarer tricks get bigger boosts!", width / 2.0f, panelTop + 260);

  rectMode(CORNER);
  noStroke();
}


// =========================
// drawNewPostView()
// Post creation UI: pick a trick, write caption, post.
// =========================
void drawNewPostView() {
  int p = socialsPlatform;
  setPlatformStyle(p);
  drawPlatformPanel(p);
  drawBackButton();

  // Title
  fill(getPlatformAccentColor(p));
  textFont(arcade);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("NEW POST", width / 2.0f, 152);

  float startY = 200;

  // --- Trick selector ---
  fill(getPlatformTextColor(p));
  textFont(arcade);
  textSize(11);
  textAlign(LEFT, CENTER);
  text("CHOOSE TRICK:", 330, startY);

  // Count unlocked tricks
  int unlockedCount = 0;
  for (boolean u : trickUnlocked) if (u) unlockedCount++;

  if (unlockedCount == 0) {
    fill(getPlatformSubtextColor(p));
    textFont(times30);
    textSize(12);
    textAlign(CENTER, CENTER);
    text("No tricks unlocked yet!", width / 2.0f, startY + 30);
    text("Train tricks in the Evolution panel.", width / 2.0f, startY + 48);
  } else {
    float tileW = 120;
    float tileH = 90;
    float tileGap = 8;
    float tilesStartX = 330;
    float tilesY = startY + 20;
    int col = 0;
    for (int i = 0; i < 5; i++) {
      if (!trickUnlocked[i]) continue;
      float tx = tilesStartX + col * (tileW + tileGap);
      float ty = tilesY;
      boolean sel = (selectedPostTrick == i);

      if (sel) {
        fill(getPlatformAccentColor(p));
        stroke(255);
        strokeWeight(3);
      } else {
        fill(40, 50);
        stroke(getPlatformAccentColor(p), 120);
        strokeWeight(1);
      }
      rect(tx, ty, tileW, tileH, 8);

      if (trickImages[i] != null) {
        drawTrickContent(trickImages[i], trickContentBounds[i], tx + 4, ty + 4, tileW - 8, tileH - 28);
      }
      fill(sel ? color(255) : getPlatformTextColor(p));
      textFont(arcade);
      textSize(9);
      textAlign(CENTER, CENTER);
      text(trickNames[i], tx + tileW / 2, ty + tileH - 10);

      col++;
    }
  }

  // --- Caption input ---
  float capY = startY + 130;
  fill(getPlatformTextColor(p));
  textFont(arcade);
  textSize(11);
  textAlign(LEFT, CENTER);
  text("CAPTION:", 330, capY);

  // Input box
  float boxX = 330;
  float boxY = capY + 16;
  float boxW = 440;
  float boxH = 52;
  if (isSocialsTyping) {
    fill(255, 255, 255, 25);
    stroke(getPlatformAccentColor(p));
    strokeWeight(2);
  } else {
    fill(0, 0, 0, 60);
    stroke(getPlatformAccentColor(p), 100);
    strokeWeight(1);
  }
  rect(boxX, boxY, boxW, boxH, 6);

  String displayText = postCaptionText + (isSocialsTyping && (frameCount % 60 < 30) ? "|" : "");
  fill(getPlatformTextColor(p));
  textFont(times30);
  textSize(12);
  textAlign(LEFT, TOP);
  text(displayText, boxX + 8, boxY + 6, boxW - 16, boxH - 12);

  if (!isSocialsTyping && postCaptionText.length() == 0) {
    fill(getPlatformSubtextColor(p));
    textFont(times30);
    textSize(12);
    textAlign(LEFT, TOP);
    text("Click here to type a caption...", boxX + 8, boxY + 8);
  }

  // Char count
  fill(getPlatformSubtextColor(p));
  textFont(times30);
  textSize(9);
  textAlign(RIGHT, CENTER);
  text(postCaptionText.length() + "/120", boxX + boxW, boxY + boxH + 10);

  // --- POST button ---
  boolean canPost = selectedPostTrick >= 0;
  float postBtnY = capY + 110;
  if (canPost) {
    fill(getPlatformAccentColor(p));
    stroke(255, 60);
    strokeWeight(1);
  } else {
    fill(60, 65, 68);
    stroke(80, 85, 88);
    strokeWeight(1);
  }
  rectMode(CENTER);
  rect(width / 2.0f, postBtnY, 180, 46, 10);
  fill(canPost ? color(255) : color(120));
  textFont(arcade);
  textSize(15);
  textAlign(CENTER, CENTER);
  text("POST", width / 2.0f, postBtnY);
  rectMode(CORNER);
  noStroke();
}


// =========================
// drawPastPostsView()
// Routes to platform-specific feed renderer.
// =========================
void drawPastPostsView() {
  int p = socialsPlatform;
  setPlatformStyle(p);
  drawPlatformPanel(p);
  drawBackButton();

  fill(getPlatformAccentColor(p));
  textFont(arcade);
  textSize(18);
  textAlign(CENTER, CENTER);
  text("PAST POSTS", width / 2.0f, 152);

  ArrayList<String[]> log  = getPlatformPostLog(p);
  ArrayList<PImage>   imgs = getPlatformPostImages(p);

  if (log.size() == 0) {
    fill(getPlatformSubtextColor(p));
    textFont(times30);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("No posts yet.", width / 2.0f, 380);
    text("Create your first post!", width / 2.0f, 402);
    return;
  }

  if      (p == 0) drawTikTokFeed(log, imgs);
  else if (p == 1) drawInstagramFeed(log, imgs);
  else             drawYouTubeFeed(log, imgs);
}


// =========================
// drawTikTokFeed()
// Dark vertical card list. Portrait 9:16 thumbnail on the left;
// trick name, caption, result on the right; heart/comment/share
// icons stacked on the far right edge — like TikTok's list view.
// =========================
void drawTikTokFeed(ArrayList<String[]> log, ArrayList<PImage> imgs) {
  int   p       = 0;
  float vpX     = 318, vpY = 188, vpW = 464, vpH = 370;
  float cardH   = 168;
  float cardGap = 6;
  float contentH  = log.size() * (cardH + cardGap) + 8;
  float maxScroll = max(0, contentH - vpH);
  pastPostsScroll[p] = constrain(pastPostsScroll[p], 0, maxScroll);

  pushMatrix();
  clip((int)vpX, (int)vpY, (int)vpW, (int)vpH);
  rectMode(CORNER);

  String uname = "@" + alligator.petName.toLowerCase() + "_tv";

  for (int i = 0; i < log.size(); i++) {
    String[] post = log.get(i);
    float ry = vpY + 8 + i * (cardH + cardGap) - pastPostsScroll[p];
    float rx = vpX + 6;
    float rw = vpW - 18;   // 446px card width

    // Card background
    fill(12, 12, 18);
    noStroke();
    rect(rx, ry, rw, cardH, 6);

    // Portrait thumbnail (9:16): stored 90x160, fill card height with correct AR
    float tW = 94, tH = cardH;
    if (i < imgs.size() && imgs.get(i) != null) {
      PImage img = imgs.get(i);
      float sc = min(tW / img.width, tH / img.height);
      float dw = img.width * sc, dh = img.height * sc;
      imageMode(CORNER);
      image(img, rx + (tW - dw) * 0.5f, ry + (tH - dh) * 0.5f, dw, dh);
    } else {
      fill(28, 28, 34);
      rect(rx, ry, tW, tH, 6);
    }

    // Bottom-left caption overlay on thumbnail
    noStroke();
    fill(0, 0, 0, 140);
    rect(rx, ry + tH - 34, tW, 34);
    fill(220, 220, 230);
    textFont(times30);
    textSize(8);
    textAlign(LEFT, TOP);
    text(uname, rx + 4, ry + tH - 28);
    fill(180, 180, 190);
    textSize(8);
    text(post[0], rx + 4, ry + tH - 16);

    // Right-side content area
    float cx = rx + tW + 10;
    float cw = rw - tW - 50;   // 50px reserved for interaction column

    // Trick name
    fill(getPlatformAccentColor(p));
    textFont(arcade);
    textSize(9);
    textAlign(LEFT, TOP);
    text(post[1].toUpperCase(), cx, ry + 10);

    // Caption text
    fill(210, 210, 220);
    textFont(times30);
    textSize(10);
    text(post[2], cx, ry + 28, cw, 46);

    // Result badge
    color bc = getPostBadgeColor(post[3]);
    fill(bc);
    noStroke();
    rectMode(CORNER);
    rect(cx, ry + cardH - 32, 54, 17, 4);
    fill(post[3].equals("Viral") ? color(20) : color(255));
    textFont(arcade);
    textSize(7);
    textAlign(CENTER, CENTER);
    text(post[3].toUpperCase(), cx + 27, ry + cardH - 23);

    // Follower / earnings line
    boolean follDown = post[4].startsWith("-");
    fill(follDown ? color(220, 80, 80) : color(100, 220, 140));
    textFont(times30);
    textSize(9);
    textAlign(LEFT, TOP);
    text(post[4] + " followers  " + post[5], cx, ry + cardH - 14);

    // TikTok right-side interaction column
    float bx = rx + rw - 26;
    int likes    = getEngagement(post, i, 0);
    int comments = getEngagement(post, i, 1);
    int shares   = getEngagement(post, i, 2);
    boolean good = post[3].equals("Viral") || post[3].equals("Great");

    // Heart
    drawHeart(bx, ry + 34, 20, good ? color(255, 48, 90) : color(190, 190, 200));
    fill(220, 220, 230);
    textFont(times30);
    textSize(8);
    textAlign(CENTER, CENTER);
    text(getFollowerLabel(likes), bx, ry + 52);

    // Comment bubble
    drawCommentIcon(bx, ry + 82, 18, color(210, 210, 225));
    fill(220, 220, 230);
    textFont(times30);
    textSize(8);
    textAlign(CENTER, CENTER);
    text(getFollowerLabel(comments), bx, ry + 98);

    // Share arrow
    drawShareIcon(bx, ry + 122, 16, color(210, 210, 225));
    fill(220, 220, 230);
    textFont(times30);
    textSize(8);
    textAlign(CENTER, CENTER);
    text(getFollowerLabel(shares), bx, ry + 138);
  }

  noClip();
  popMatrix();
  drawFeedScrollbar(p, vpX, vpY, vpW, vpH, contentH, maxScroll);
}


// =========================
// drawInstagramFeed()
// Full-width cards styled like Instagram posts:
// avatar header → square image → action row → likes → caption → comments.
// =========================
void drawInstagramFeed(ArrayList<String[]> log, ArrayList<PImage> imgs) {
  int   p       = 1;
  float vpX     = 318, vpY = 188, vpW = 464, vpH = 370;
  float cardW   = vpW - 12;      // 452px
  float headerH = 50;
  float imgSize = cardW;          // square image fills full card width
  float actionH = 40;
  float footerH = 104;
  float cardH   = headerH + imgSize + actionH + footerH;
  float cardGap = 0;
  float contentH  = log.size() * (cardH + cardGap) + 4;
  float maxScroll = max(0, contentH - vpH);
  pastPostsScroll[p] = constrain(pastPostsScroll[p], 0, maxScroll);

  pushMatrix();
  clip((int)vpX, (int)vpY, (int)vpW, (int)vpH);
  rectMode(CORNER);

  String uname = alligator.petName.toLowerCase() + "_official";

  for (int i = 0; i < log.size(); i++) {
    String[] post = log.get(i);
    float ry = vpY + 4 + i * (cardH + cardGap) - pastPostsScroll[p];
    float rx = vpX + 6;

    // Card background
    fill(18, 18, 18);
    noStroke();
    rect(rx, ry, cardW, cardH);

    // ---- HEADER (avatar + username + "...") ----
    float hCY = ry + headerH * 0.5f;

    // Avatar circle with Instagram gradient feel
    noStroke();
    fill(getPlatformAccentColor(p));
    ellipse(rx + 26, hCY, 34, 34);
    // Inner white circle cutout
    fill(18, 18, 18);
    ellipse(rx + 26, hCY, 26, 26);
    // Profile image placeholder initials
    fill(getPlatformAccentColor(p));
    textFont(arcade);
    textSize(8);
    textAlign(CENTER, CENTER);
    text("AL", rx + 26, hCY);

    // Username
    fill(255, 252, 255);
    textFont(arcade);
    textSize(10);
    textAlign(LEFT, CENTER);
    text(uname, rx + 46, hCY - 6);

    // Subtext: trick + day
    fill(160, 155, 170);
    textFont(times30);
    textSize(9);
    textAlign(LEFT, CENTER);
    text(post[1] + "  ·  " + post[0], rx + 46, hCY + 8);

    // "..." menu dots
    fill(200, 200, 210);
    textFont(arcade);
    textSize(13);
    textAlign(RIGHT, CENTER);
    text("...", rx + cardW - 10, hCY);

    // Divider below header
    stroke(35, 35, 42);
    strokeWeight(1);
    line(rx, ry + headerH, rx + cardW, ry + headerH);
    noStroke();

    // ---- IMAGE (square, uniform scale, never stretch) ----
    float imgY = ry + headerH;
    if (i < imgs.size() && imgs.get(i) != null) {
      PImage img = imgs.get(i);
      // img is 200x200 (square); scale uniformly to imgSize x imgSize
      float sc = min(imgSize / img.width, imgSize / img.height);
      float dw = img.width * sc, dh = img.height * sc;
      imageMode(CORNER);
      image(img, rx + (imgSize - dw) * 0.5f, imgY + (imgSize - dh) * 0.5f, dw, dh);
    } else {
      fill(28, 28, 34);
      rect(rx, imgY, imgSize, imgSize);
    }

    // ---- ACTION ROW ----
    float ar = imgY + imgSize;

    // Left icons: heart, comment, share
    boolean liked = post[3].equals("Viral") || post[3].equals("Great");
    drawHeart(rx + 18, ar + actionH * 0.5f, 20,
              liked ? color(237, 73, 86) : color(230, 228, 235));
    drawCommentIcon(rx + 50, ar + actionH * 0.5f, 18, color(230, 228, 235));
    drawShareIcon(rx + 80, ar + actionH * 0.5f, 16, color(230, 228, 235));

    // Right icon: bookmark
    drawBookmarkIcon(rx + cardW - 16, ar + actionH * 0.5f, 18, color(230, 228, 235));

    // Divider below actions
    stroke(35, 35, 42);
    strokeWeight(1);
    line(rx, ar + actionH, rx + cardW, ar + actionH);
    noStroke();

    // ---- FOOTER (likes, caption, result, comments) ----
    float fy = ar + actionH + 10;
    int likes    = getEngagement(post, i, 0);
    int comments = getEngagement(post, i, 1);

    // Likes count
    fill(255, 252, 255);
    textFont(arcade);
    textSize(10);
    textAlign(LEFT, TOP);
    text(getFollowerLabel(likes) + " likes", rx + 10, fy);
    fy += 18;

    // Caption line: "username caption"
    textFont(arcade);
    textSize(9);
    textAlign(LEFT, TOP);
    fill(255, 252, 255);
    text(uname + " ", rx + 10, fy);
    float unameW = textWidth(uname + " ");
    fill(200, 198, 210);
    textFont(times30);
    textSize(10);
    text(post[2], rx + 10 + unameW, fy, cardW - 20 - unameW, 22);
    fy += 24;

    // Result badge
    color bc = getPostBadgeColor(post[3]);
    fill(bc, 210);
    noStroke();
    rect(rx + 10, fy, 54, 17, 4);
    fill(post[3].equals("Viral") ? color(20) : color(255));
    textFont(arcade);
    textSize(7);
    textAlign(CENTER, CENTER);
    text(post[3].toUpperCase(), rx + 37, fy + 8);

    // Comments count (right of badge)
    fill(150, 148, 162);
    textFont(times30);
    textSize(10);
    textAlign(LEFT, TOP);
    text("View all " + getFollowerLabel(comments) + " comments", rx + 74, fy + 3);
    fy += 22;

    // Earnings / follower change
    boolean follDown = post[4].startsWith("-");
    fill(follDown ? color(220, 80, 80) : color(100, 210, 140));
    textFont(times30);
    textSize(9);
    textAlign(LEFT, TOP);
    text(post[4] + " followers  " + post[5] + " earned", rx + 10, fy);
  }

  noClip();
  popMatrix();
  drawFeedScrollbar(p, vpX, vpY, vpW, vpH, contentH, maxScroll);
}


// =========================
// drawYouTubeFeed()
// YouTube-style feed: full-width 16:9 thumbnail with duration badge,
// then channel icon + title + views + likes below.
// =========================
void drawYouTubeFeed(ArrayList<String[]> log, ArrayList<PImage> imgs) {
  int   p       = 2;
  float vpX     = 318, vpY = 188, vpW = 464, vpH = 370;
  float cardW   = vpW - 12;                    // 452px
  float thumbH  = cardW * 9.0f / 16.0f;        // 254px  (16:9)
  float infoH   = 76;
  float cardH   = thumbH + infoH;
  float cardGap = 10;
  float contentH  = log.size() * (cardH + cardGap) + 8;
  float maxScroll = max(0, contentH - vpH);
  pastPostsScroll[p] = constrain(pastPostsScroll[p], 0, maxScroll);

  pushMatrix();
  clip((int)vpX, (int)vpY, (int)vpW, (int)vpH);
  rectMode(CORNER);

  for (int i = 0; i < log.size(); i++) {
    String[] post = log.get(i);
    float ry = vpY + 8 + i * (cardH + cardGap) - pastPostsScroll[p];
    float rx = vpX + 6;

    // ---- THUMBNAIL (16:9, uniform scale, never stretch) ----
    fill(18, 18, 22);
    noStroke();
    rect(rx, ry, cardW, thumbH);

    if (i < imgs.size() && imgs.get(i) != null) {
      PImage img = imgs.get(i);
      // img is 288x162 (16:9); scale uniformly to fill cardW x thumbH
      float sc = min(cardW / img.width, thumbH / img.height);
      float dw = img.width * sc, dh = img.height * sc;
      imageMode(CORNER);
      image(img, rx + (cardW - dw) * 0.5f, ry + (thumbH - dh) * 0.5f, dw, dh);
    }

    // Duration badge (bottom-right of thumbnail)
    String dur = generateDuration(post, i);
    float durW = 36, durH = 16;
    fill(0, 0, 0, 210);
    noStroke();
    rect(rx + cardW - durW - 5, ry + thumbH - durH - 5, durW, durH, 3);
    fill(255);
    textFont(times30);
    textSize(10);
    textAlign(CENTER, CENTER);
    text(dur, rx + cardW - durW * 0.5f - 5, ry + thumbH - durH * 0.5f - 5);

    // Viral/Great badge overlay (top-left corner of thumbnail)
    if (post[3].equals("Viral") || post[3].equals("Great")) {
      color bc = getPostBadgeColor(post[3]);
      fill(bc, 220);
      noStroke();
      rect(rx + 6, ry + 6, 54, 17, 4);
      fill(post[3].equals("Viral") ? color(20) : color(255));
      textFont(arcade);
      textSize(7);
      textAlign(CENTER, CENTER);
      text(post[3].toUpperCase(), rx + 33, ry + 14);
    }

    // ---- INFO ROW below thumbnail ----
    float infoY = ry + thumbH;
    fill(22, 22, 26);
    noStroke();
    rect(rx, infoY, cardW, infoH);

    // Channel icon
    float iconCX = rx + 22, iconCY = infoY + infoH * 0.5f;
    fill(getPlatformAccentColor(p));
    noStroke();
    ellipse(iconCX, iconCY, 36, 36);
    fill(255);
    textFont(arcade);
    textSize(8);
    textAlign(CENTER, CENTER);
    text("AL", iconCX, iconCY);

    // Title (two lines available)
    float tx = rx + 46, tw = cardW - 54;
    fill(235, 235, 240);
    textFont(arcade);
    textSize(10);
    textAlign(LEFT, TOP);
    text(post[1] + " Tutorial  -  " + post[0], tx, infoY + 8, tw, 26);

    // Metadata: channel · views · likes
    int views = getEngagement(post, i, 3);
    int likes = getEngagement(post, i, 0);
    fill(140, 140, 150);
    textFont(times30);
    textSize(10);
    textAlign(LEFT, TOP);
    text("Gator TV  ·  " + getFollowerLabel(views) + " views  ·  "
         + getFollowerLabel(likes) + " likes", tx, infoY + 40);

    // Earnings
    boolean earned = !post[5].equals("$0.00");
    fill(earned ? color(80, 210, 120) : color(110, 110, 120));
    text(post[5] + " earned", tx, infoY + 56);

    // Three-dot menu
    fill(180, 180, 190);
    textFont(arcade);
    textSize(13);
    textAlign(RIGHT, CENTER);
    text("...", rx + cardW - 8, infoY + infoH * 0.5f);
  }

  noClip();
  popMatrix();
  drawFeedScrollbar(p, vpX, vpY, vpW, vpH, contentH, maxScroll);
}


// =========================
// getEngagement(post, idx, type)
// Generates consistent engagement numbers.
// type: 0=likes, 1=comments, 2=shares, 3=views
// =========================
int getEngagement(String[] post, int idx, int type) {
  int base;
  switch (post[3]) {
    case "Viral": base = (type==3) ? 190000 : (type==0) ? 9400 : (type==1) ? 1500 : 3200; break;
    case "Great": base = (type==3) ?  17000 : (type==0) ? 1150 : (type==1) ?  170 :  430; break;
    case "Okay":  base = (type==3) ?   3100 : (type==0) ?  270 : (type==1) ?   40 :   90; break;
    default:      base = (type==3) ?    290 : (type==0) ?   12 : (type==1) ?    3 :    5; break;
  }
  float v = ((idx * 7 + type * 13 + post[1].length() * 3) % 31) / 31.0f;
  return max(0, (int)(base * (0.85f + v * 0.3f)));
}


// =========================
// generateDuration(post, idx)
// Produces a deterministic mm:ss duration string for YouTube thumbnails.
// =========================
String generateDuration(String[] post, int idx) {
  int secs = 18 + ((idx * 11 + post[3].length() * 7) % 42);
  int mins  = secs / 60;
  secs     %= 60;
  return mins + ":" + nf(secs, 2);
}


// =========================
// getPostBadgeColor(result)
// Shared badge color across all platform renderers.
// =========================
color getPostBadgeColor(String result) {
  switch (result) {
    case "Viral": return color(255, 215, 0);
    case "Great": return color(80,  200, 100);
    case "Okay":  return color(80,  150, 220);
    default:      return color(200,  70,  70);
  }
}


// =========================
// drawFeedScrollbar(p, ...)
// Platform-accented scrollbar for the feed viewports.
// =========================
void drawFeedScrollbar(int p, float vpX, float vpY, float vpW, float vpH,
                       float contentH, float maxScroll) {
  if (contentH <= vpH) return;
  float sbX    = vpX + vpW - 6;
  float tH     = max(28, (vpH / contentH) * vpH);
  float tY     = map(pastPostsScroll[p], 0, maxScroll, vpY, vpY + vpH - tH);
  fill(36, 36, 44);
  noStroke();
  rectMode(CORNER);
  rect(sbX, vpY, 6, vpH, 3);
  fill(getPlatformAccentColor(p));
  rect(sbX, tY, 6, tH, 3);
}


// =========================
// Icon drawing helpers (used across all platform renderers)
// =========================

void drawHeart(float cx, float cy, float s, color c) {
  fill(c);
  noStroke();
  float r = s * 0.3f;
  ellipse(cx - r * 0.72f, cy - r * 0.25f, r * 2, r * 2);
  ellipse(cx + r * 0.72f, cy - r * 0.25f, r * 2, r * 2);
  triangle(cx - s * 0.52f, cy + r * 0.2f,
           cx + s * 0.52f, cy + r * 0.2f,
           cx,             cy + s * 0.48f);
}

void drawCommentIcon(float cx, float cy, float s, color c) {
  fill(c);
  noStroke();
  float bw = s * 0.95f, bh = s * 0.72f;
  rectMode(CENTER);
  rect(cx, cy - s * 0.08f, bw, bh, bh * 0.32f);
  // tail
  triangle(cx - bw * 0.28f, cy + bh * 0.28f,
           cx + bw * 0.02f, cy + bh * 0.28f,
           cx - bw * 0.14f, cy + s * 0.52f);
  rectMode(CORNER);
}

void drawShareIcon(float cx, float cy, float s, color c) {
  fill(c);
  noStroke();
  // Right-pointing solid arrow
  triangle(cx - s * 0.5f, cy - s * 0.32f,
           cx + s * 0.5f, cy,
           cx - s * 0.5f, cy + s * 0.32f);
}

void drawBookmarkIcon(float cx, float cy, float s, color c) {
  fill(c);
  noStroke();
  float bw = s * 0.58f, bh = s * 0.78f;
  rectMode(CENTER);
  rect(cx, cy - bh * 0.08f, bw, bh, 2);
  // V-notch at bottom (cutout in card background color)
  fill(18, 18, 18);
  triangle(cx - bw * 0.5f, cy + bh * 0.42f,
           cx + bw * 0.5f, cy + bh * 0.42f,
           cx,             cy + bh * 0.14f);
  rectMode(CORNER);
}


// =========================
// drawPostResultPopup()
// Full-panel overlay showing post result info.
// =========================
void drawPostResultPopup() {
  // Dim background
  fill(0, 180);
  noStroke();
  rectMode(CORNERS);
  rect(310, 122.5f, 790, 572.5f);

  // Popup box
  float px = 380;
  float py = 230;
  float pw = 340;
  float ph = 220;

  color resultColor;
  String emoji;
  switch (postResultType) {
    case "Viral": resultColor = color(255, 215, 0);  emoji = "VIRAL!";  break;
    case "Great": resultColor = color(80, 200, 100); emoji = "GREAT!";  break;
    case "Okay":  resultColor = color(80, 150, 220); emoji = "OKAY";    break;
    default:      resultColor = color(200, 70, 70);  emoji = "FLOP";    break;
  }

  fill(20, 18, 28);
  stroke(resultColor);
  strokeWeight(4);
  rectMode(CORNER);
  rect(px, py, pw, ph, 14);
  noStroke();

  textFont(arcade);
  textSize(28);
  fill(resultColor);
  textAlign(CENTER, CENTER);
  text(emoji, px + pw / 2, py + 42);

  fill(255);
  textFont(times30);
  textSize(13);
  if (postResultFollowerChange >= 0) {
    text("+" + postResultFollowerChange + " followers", px + pw / 2, py + 80);
  } else {
    fill(220, 80, 80);
    text(postResultFollowerChange + " followers", px + pw / 2, py + 80);
  }

  if (postResultEarnings > 0) {
    fill(100, 240, 140);
    text("+$" + nf(postResultEarnings, 0, 2) + " pending!", px + pw / 2, py + 105);
  }

  if (postResultType.equals("Viral")) {
    fill(255, 230, 100);
    textFont(arcade);
    textSize(10);
    text("IT WENT VIRAL! Check back for earnings!", px + pw / 2, py + 132);
  } else if (postResultType.equals("Flop")) {
    fill(180, 130, 130);
    textFont(times30);
    textSize(11);
    text("Better luck next time...", px + pw / 2, py + 132);
  }

  // OK button
  fill(resultColor);
  stroke(255, 80);
  strokeWeight(1);
  rectMode(CENTER);
  rect(px + pw / 2, py + 178, 120, 38, 8);
  fill(postResultType.equals("Viral") ? color(30) : color(255));
  textFont(arcade);
  textSize(13);
  textAlign(CENTER, CENTER);
  text("AWESOME!", px + pw / 2, py + 178);
  rectMode(CORNER);
  noStroke();
}


// =========================
// Style helpers
// =========================
void setPlatformStyle(int p) {
  // Nothing to set globally -- panel background is drawn per platform
}

void drawPlatformPanel(int p) {
  rectMode(CORNERS);
  stroke(getPlatformAccentColor(p));
  strokeWeight(5);
  fill(getPlatformBgColor(p), 240);
  rect(310, 122.5f, 790, 572.5f);
  line(310, 182, 790, 182);
  rectMode(CORNER);
}

void drawBackButton() {
  fill(60, 55, 80);
  stroke(140, 130, 180);
  strokeWeight(2);
  rectMode(CENTER);
  rect(345, 151, 56, 28, 6);
  fill(220, 210, 255);
  textFont(arcade);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("< BACK", 345, 151);
  rectMode(CORNER);
  noStroke();
}

color getPlatformBgColor(int p) {
  switch (p) {
    case 0: return color(8, 8, 12);         // TikTok: near black
    case 1: return color(18, 12, 28);       // Instagram: dark purple
    case 2: return color(12, 12, 18);       // YouTube: very dark
    default: return color(20, 20, 25);
  }
}

color getPlatformAccentColor(int p) {
  switch (p) {
    case 0: return color(0x8B, 0x5C, 0xF6); // TikTok purple (matches hub badge)
    case 1: return color(0xE9, 0x1E, 0x63); // Instagram pink (matches hub badge)
    case 2: return color(255, 0, 0);         // YouTube red
    default: return color(200, 100, 200);
  }
}

color getPlatformTextColor(int p) {
  return color(245, 245, 250);   // near white for all dark platforms
}

color getPlatformSubtextColor(int p) {
  switch (p) {
    case 0: return color(160, 155, 170);
    case 1: return color(155, 140, 175);
    case 2: return color(160, 160, 165);
    default: return color(160, 160, 165);
  }
}

color getPlatformCardColor(int p) {
  switch (p) {
    case 0: return color(22, 22, 30);
    case 1: return color(28, 20, 38);
    case 2: return color(22, 22, 28);
    default: return color(25, 25, 30);
  }
}
