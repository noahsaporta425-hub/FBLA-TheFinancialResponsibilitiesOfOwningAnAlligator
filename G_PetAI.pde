// =========================
// G_PetAI.pde
// In-game AI assistant powered by Google Gemini.
// Accessible from the Services panel -- answers any question about the game,
// gives strategy tips, vet advice, and financial guidance using live game state.
// =========================


// =========================
// State
// =========================
boolean isPetAIOpen         = false;
boolean isWaitingForAI      = false;
int     aiSelectedSession   = -1;  // -1 = current session, >=0 = viewing a saved session

// Current active chat: each entry is String[]{"user"/"model", "message text"}
ArrayList<String[]> currentChat   = new ArrayList<String[]>();

// Saved past sessions: each entry is String[]{sessionName, role0, text0, role1, text1, ...}
ArrayList<String[]> savedSessions = new ArrayList<String[]>();

// Scroll offsets
float aiChatScroll    = 0;
float aiSidebarScroll = 0;

// Text input state
String aiInputText = "";

// Pending message for the background thread (thread() passes no args)
String aiPendingMessage = "";

// Loaded API key
String geminiAPIKey = "";


// =========================
// Layout constants
// =========================
final int AI_X1        = 80;
final int AI_X2        = 1020;
final int AI_Y1        = 72;
final int AI_Y2        = 648;
final int AI_SIDEBAR_X = 260;   // right edge of sidebar
final int AI_INPUT_Y   = 575;   // top of input bar


// =========================
// Load API Key from file
// =========================
void loadPetAIKey() {
  try {
    String[] lines = loadStrings("petai_key.txt");
    if (lines != null && lines.length > 0) geminiAPIKey = lines[0].trim();
  } catch (Exception e) {
    geminiAPIKey = "";
    println("PetAI: could not load petai_key.txt");
  }
}


// =========================
// Main Render Function
// =========================
void petAIPanel() {
  ArrayList<String[]> displayChat = (aiSelectedSession >= 0 && aiSelectedSession < savedSessions.size())
    ? extractSessionMessages(savedSessions.get(aiSelectedSession))
    : currentChat;

  rectMode(CORNERS);

  // --- Outer panel ---
  stroke(169);
  strokeWeight(5);
  fill(80, 220);
  rect(AI_X1, AI_Y1, AI_X2, AI_Y2);

  // --- Sidebar background ---
  fill(45, 220);
  noStroke();
  rect(AI_X1, AI_Y1, AI_SIDEBAR_X, AI_Y2);

  // --- Sidebar title ---
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(times50);
  textSize(15);
  text("CHAT HISTORY", AI_X1 + (AI_SIDEBAR_X - AI_X1) / 2.0f, AI_Y1 + 22);

  // --- Sidebar divider ---
  stroke(169);
  strokeWeight(2);
  line(AI_SIDEBAR_X, AI_Y1, AI_SIDEBAR_X, AI_Y2);
  line(AI_X1, AI_Y1 + 40, AI_SIDEBAR_X, AI_Y1 + 40);

  // --- Sidebar entries (current chat tab + saved sessions, newest first) ---
  float entryH      = 44;
  float entryStartY = AI_Y1 + 48;

  // Current chat tab -- shown whenever the active chat has messages
  if (currentChat.size() > 0) {
    float ey = entryStartY - aiSidebarScroll;
    if (ey + entryH >= AI_Y1 + 40 && ey < AI_Y2) {
      boolean selected = (aiSelectedSession == -1);
      rectMode(CORNERS);
      if (selected) {
        noStroke();
        fill(100, 160, 255, 100);
        rect(AI_X1 + 4, ey, AI_SIDEBAR_X - 4, ey + entryH - 2);
      }
      strokeWeight(1);
      stroke(selected ? color(140, 190, 255) : color(120));
      noFill();
      rect(AI_X1 + 4, ey, AI_SIDEBAR_X - 4, ey + entryH - 2);
      noStroke();

      fill(selected ? color(180, 210, 255) : color(210));
      textAlign(LEFT, TOP);
      textFont(times50);
      textSize(12);
      text("Current Chat", AI_X1 + 8, ey + 6);
      int curMsgCount = currentChat.size();
      fill(selected ? color(150, 190, 240) : color(160));
      textSize(11);
      text(curMsgCount + " message" + (curMsgCount == 1 ? "" : "s"), AI_X1 + 8, ey + 22);
    }
    entryStartY += entryH;
  }

  int count = savedSessions.size();
  for (int i = count - 1; i >= 0; i--) {
    int   dispIdx = count - 1 - i;
    float ey      = entryStartY + dispIdx * entryH - aiSidebarScroll;
    if (ey + entryH < AI_Y1 + 40 || ey > AI_Y2) continue;

    boolean selected = (aiSelectedSession == i);
    rectMode(CORNERS);
    if (selected) {
      noStroke();
      fill(100, 160, 255, 100);
      rect(AI_X1 + 4, ey, AI_SIDEBAR_X - 4, ey + entryH - 2);
    }
    strokeWeight(1);
    stroke(selected ? color(140, 190, 255) : color(120));
    noFill();
    rect(AI_X1 + 4, ey, AI_SIDEBAR_X - 4, ey + entryH - 2);
    noStroke();

    fill(selected ? color(180, 210, 255) : color(210));
    textAlign(LEFT, TOP);
    textFont(times50);
    textSize(12);
    String name = savedSessions.get(i)[0];
    if (name.length() > 21) name = name.substring(0, 21) + "...";
    text(name, AI_X1 + 8, ey + 6);

    // message count subtitle
    int msgCount = (savedSessions.get(i).length - 1) / 2;
    fill(selected ? color(150, 190, 240) : color(160));
    textSize(11);
    text(msgCount + " message" + (msgCount == 1 ? "" : "s"), AI_X1 + 8, ey + 22);
  }

  // --- Panel title ---
  stroke(169);
  strokeWeight(5);
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(times50);
  textSize(20);
  text("PetAI: Your Game Assistant", AI_SIDEBAR_X + (AI_X2 - AI_SIDEBAR_X) / 2.0f, AI_Y1 + 22);

  // --- Horizontal divider above input ---
  stroke(169);
  strokeWeight(2);
  line(AI_SIDEBAR_X, AI_INPUT_Y, AI_X2, AI_INPUT_Y);
  line(AI_SIDEBAR_X, AI_Y1 + 40, AI_X2, AI_Y1 + 40);

  // --- Chat message area ---
  drawAIChatMessages(displayChat);

  // --- Input bar ---
  if (aiSelectedSession < 0) {
    // Input box
    fill(30, 210);
    noStroke();
    rectMode(CORNERS);
    rect(AI_SIDEBAR_X + 6, AI_INPUT_Y + 6, AI_X2 - 108, AI_Y2 - 6);

    // Send button
    fill(0, 180, 90, 200);
    rect(AI_X2 - 100, AI_INPUT_Y + 6, AI_X2 - 6, AI_Y2 - 6);

    // Input text
    fill(255);
    textAlign(LEFT, CENTER);
    textFont(times50);
    textSize(14);
    float inputCY = (AI_INPUT_Y + 6 + AI_Y2 - 6) / 2.0f;
    int   maxChars = 70;
    String displayInput = aiInputText.length() > maxChars
      ? aiInputText.substring(aiInputText.length() - maxChars)
      : aiInputText;
    text(displayInput + (frameCount % 60 < 30 ? "|" : ""), AI_SIDEBAR_X + 12, inputCY);

    // Send label
    textAlign(CENTER, CENTER);
    textFont(arcade);
    textSize(16);
    fill(255);
    text("SEND", AI_X2 - 53, inputCY);

    // Thinking indicator
    if (isWaitingForAI) {
      fill(255, 220, 60, 210);
      textFont(times50);
      textSize(13);
      int dots = (frameCount / 18) % 4;
      String dotStr = dots == 0 ? "" : dots == 1 ? "." : dots == 2 ? ".." : "...";
      text("PetAI is thinking" + dotStr, AI_SIDEBAR_X + (AI_X2 - 108 - AI_SIDEBAR_X) / 2.0f + AI_SIDEBAR_X + 6, inputCY - 16);
    }
  } else {
    // Viewing saved session -- Back button (left) + Resume button (right)
    float midX = AI_SIDEBAR_X + (AI_X2 - AI_SIDEBAR_X) / 2.0f;
    noStroke();
    rectMode(CORNERS);

    fill(70, 110, 200, 190);
    rect(AI_SIDEBAR_X + 6, AI_INPUT_Y + 6, midX - 3, AI_Y2 - 6);

    fill(0, 155, 80, 190);
    rect(midX + 3, AI_INPUT_Y + 6, AI_X2 - 6, AI_Y2 - 6);

    fill(255);
    textAlign(CENTER, CENTER);
    textFont(times50);
    textSize(15);
    float btnCY = (AI_INPUT_Y + AI_Y2) / 2.0f;
    text("Back to current", (AI_SIDEBAR_X + 6 + midX - 3) / 2.0f, btnCY);
    text("Resume this chat", (midX + 3 + AI_X2 - 6) / 2.0f, btnCY);
  }

  // --- Close X ---
  noFill();
  stroke(169);
  strokeWeight(5);
  rectMode(CORNERS);
  rect(AI_X2 - 47, AI_Y1 + 3, AI_X2 - 5, AI_Y1 + 37);
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(arcade);
  textSize(24);
  text("X", AI_X2 - 26f, AI_Y1 + 20f);

  stroke(0);
  strokeWeight(2);
  rectMode(CORNER);
}


// =========================
// Draw Scrollable Chat Bubbles
// =========================
void drawAIChatMessages(ArrayList<String[]> chat) {
  float cx1 = AI_SIDEBAR_X + 8;
  float cx2 = AI_X2 - 30;   // leave room for scrollbar
  float cy1 = AI_Y1 + 44;
  float cy2 = AI_INPUT_Y - 4;
  float chatW = cx2 - cx1;

  float lineH        = 17;
  float bubblePad    = 10;  // internal text padding inside bubble
  float bubbleGap    = 8;
  float bubbleMargin = 22;  // gap between bubble edge and chat panel edge
  // Fixed bubble width -- always the same so text can never overflow the right edge
  float bw           = chatW * 0.70f;
  // Wrap text conservatively inside that fixed width
  float wrapW        = bw - bubblePad * 2 - 14;

  // --- Calculate total content height ---
  float totalH = 18;
  for (int i = 0; i < chat.size(); i++) {
    String[] wrapped = aiWrapText(chat.get(i)[1], wrapW, 13);
    totalH += wrapped.length * lineH + bubblePad * 2 + bubbleGap;
  }

  // Clamp and auto-scroll to bottom when new content added
  float maxScroll = max(0, totalH - (cy2 - cy1));
  if (aiChatScroll > maxScroll) aiChatScroll = maxScroll;
  aiChatScroll = constrain(aiChatScroll, 0, maxScroll);

  // --- Draw bubbles ---
  float y = cy1 + 18 - aiChatScroll;
  for (int i = 0; i < chat.size(); i++) {
    String[] msg     = chat.get(i);
    boolean  isUser  = msg[0].equals("user");
    String[] wrapped = aiWrapText(msg[1], wrapW, 13);
    float    bh      = wrapped.length * lineH + bubblePad * 2;

    // Fixed bubble position: AI left-aligned, user right-aligned, both with margin
    float bx = isUser ? cx2 - bw - bubbleMargin : cx1 + bubbleMargin;

    if (y + bh > cy1 && y < cy2) {
      // Bubble background
      noStroke();
      if (isUser) fill(35, 145, 75, 210);
      else        fill(55, 55, 105, 210);
      rectMode(CORNER);
      rect(bx, y, bw, bh, 8);

      // Role label
      textFont(times50);
      textSize(13);
      fill(isUser ? color(160, 230, 160) : color(160, 160, 220));
      textAlign(isUser ? RIGHT : LEFT, TOP);
      text(isUser ? "You" : "PetAI", isUser ? bx + bw - bubblePad : bx + bubblePad, y - 15);

      // Message text -- explicitly set font+size to guard against bleed from role label
      fill(255, 255, 255, 255);
      textAlign(LEFT, TOP);
      textFont(times50);
      textSize(13);
      for (int l = 0; l < wrapped.length; l++) {
        float ty = y + bubblePad + l * lineH;
        if (ty < cy2 && ty + lineH > cy1) {
          text(wrapped[l], bx + bubblePad, ty);
        }
      }
    }
    y += bh + bubbleGap;
  }

  // --- Empty state hint ---
  if (chat.size() == 0) {
    fill(255);
    textAlign(CENTER, CENTER);
    textFont(times50);
    textSize(15);
    text("Ask PetAI anything about your game!", cx1 + chatW / 2, (cy1 + cy2) / 2 - 10);
    textSize(13);
    fill(210);
    text("Tips, vet advice, finances, strategy - it knows everything.", cx1 + chatW / 2, (cy1 + cy2) / 2 + 14);
  }

  // --- Scrollbar (pinned to right of outer panel, outside bubble area) ---
  if (maxScroll > 0) {
    float sbX    = AI_X2 - 18;
    float sbH    = cy2 - cy1;
    float thumbH = max(28, (sbH / totalH) * sbH);
    float thumbY = cy1 + (aiChatScroll / maxScroll) * (sbH - thumbH);
    noStroke();
    fill(169, 60);
    rectMode(CORNER);
    rect(sbX, cy1, 5, sbH);
    fill(200, 150);
    rect(sbX, thumbY, 5, thumbH, 3);
  }
}


// =========================
// Word-wrap helper
// Returns lines of text that each fit within maxWidth at the given font size.
// =========================
String[] aiWrapText(String input, float maxWidth, int fontSize) {
  textFont(times50);
  textSize(fontSize);
  ArrayList<String> lines = new ArrayList<String>();
  // Handle explicit newlines first
  String[] paragraphs = input.split("\n");
  for (String para : paragraphs) {
    String[] words = para.split(" ");
    String   cur   = "";
    for (String word : words) {
      if (word.length() == 0) continue;
      String test = cur.length() == 0 ? word : cur + " " + word;
      if (textWidth(test) <= maxWidth) {
        cur = test;
      } else {
        if (cur.length() > 0) lines.add(cur);
        cur = word;
      }
    }
    if (cur.length() > 0) lines.add(cur);
  }
  if (lines.size() == 0) lines.add("");
  return lines.toArray(new String[0]);
}


// =========================
// Send a message to PetAI
// =========================
void sendPetAIMessage() {
  if (isWaitingForAI || aiInputText.trim().length() == 0) return;
  aiPendingMessage = aiInputText.trim();
  aiInputText = "";
  currentChat.add(new String[]{"user", aiPendingMessage});
  isWaitingForAI = true;
  aiChatScroll = Float.MAX_VALUE; // will be clamped to bottom next frame
  thread("callGeminiAPI");
}


// =========================
// Close PetAI Panel
// Saves current session to history if it has messages.
// =========================
void closePetAIPanel() {
  if (currentChat.size() > 0) {
    // Name session after first user message
    String sessionName = "Session " + (savedSessions.size() + 1);
    for (String[] msg : currentChat) {
      if (msg[0].equals("user")) {
        sessionName = msg[1].length() > 28 ? msg[1].substring(0, 28) + "..." : msg[1];
        break;
      }
    }
    // Pack into flat array: [name, role0, text0, role1, text1, ...]
    String[] packed = new String[1 + currentChat.size() * 2];
    packed[0] = sessionName;
    for (int i = 0; i < currentChat.size(); i++) {
      packed[1 + i * 2]     = currentChat.get(i)[0];
      packed[1 + i * 2 + 1] = currentChat.get(i)[1];
    }
    savedSessions.add(packed);
    currentChat.clear();
    aiChatScroll = 0;
  }
  aiSelectedSession = -1;
  isPetAIOpen = false;
}


// =========================
// Extract messages from a packed session array
// =========================
ArrayList<String[]> extractSessionMessages(String[] session) {
  ArrayList<String[]> msgs = new ArrayList<String[]>();
  for (int i = 1; i + 1 < session.length; i += 2) {
    msgs.add(new String[]{session[i], session[i + 1]});
  }
  return msgs;
}


// =========================
// Groq API Call -- runs in a background thread
// Uses OpenAI-compatible format with llama-3.1-8b-instant (free tier)
// =========================
void callGeminiAPI() {
  try {
    if (geminiAPIKey.length() == 0) {
      currentChat.add(new String[]{"model", "API key not found. Check data/petai_key.txt."});
      isWaitingForAI = false;
      aiChatScroll = Float.MAX_VALUE;
      return;
    }

    String endpoint = "https://api.groq.com/openai/v1/chat/completions";

    // Build OpenAI-compatible JSON body
    StringBuilder body = new StringBuilder();
    body.append("{");
    body.append("\"model\":\"llama-3.3-70b-versatile\",");
    body.append("\"max_tokens\":400,");
    body.append("\"messages\":[");

    // System prompt as dedicated system role message
    body.append("{\"role\":\"system\",\"content\":");
    body.append(aiJsonStr(buildPetAIPrompt()));
    body.append("}");

    // Conversation history -- map "model" role to "assistant" for OpenAI format
    for (int i = 0; i < currentChat.size(); i++) {
      String[] msg = currentChat.get(i);
      String role = msg[0].equals("user") ? "user" : "assistant";
      body.append(",{\"role\":");
      body.append(aiJsonStr(role));
      body.append(",\"content\":");
      body.append(aiJsonStr(msg[1]));
      body.append("}");
    }

    body.append("]}");

    byte[] bodyBytes = body.toString().getBytes("UTF-8");

    java.net.URL              url  = new java.net.URL(endpoint);
    java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
    conn.setRequestMethod("POST");
    conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
    conn.setRequestProperty("Authorization", "Bearer " + geminiAPIKey);
    conn.setDoOutput(true);
    conn.setConnectTimeout(10000);
    conn.setReadTimeout(30000);
    conn.getOutputStream().write(bodyBytes);

    int status = conn.getResponseCode();
    java.io.InputStream stream = (status >= 200 && status < 300)
      ? conn.getInputStream()
      : conn.getErrorStream();

    java.io.BufferedReader br = new java.io.BufferedReader(
      new java.io.InputStreamReader(stream, "UTF-8"));
    StringBuilder resp = new StringBuilder();
    String line;
    while ((line = br.readLine()) != null) resp.append(line);
    br.close();

    String responseText = extractGroqText(resp.toString());
    currentChat.add(new String[]{"model", responseText});

  } catch (Exception e) {
    currentChat.add(new String[]{"model", "Connection error: " + e.getMessage()});
    println("PetAI error: " + e);
  }

  isWaitingForAI = false;
  aiChatScroll = Float.MAX_VALUE;
}


// =========================
// Extract content from a Groq/OpenAI-format JSON response
// {"choices":[{"message":{"role":"assistant","content":"text here"}}]}
// =========================
String extractGroqText(String json) {
  // Find "content" inside the first choice's message object
  int msgIdx = json.indexOf("\"message\"");
  if (msgIdx < 0) {
    // Surface any error message from the API
    int errIdx = json.indexOf("\"error\"");
    if (errIdx >= 0) {
      int mIdx = json.indexOf("\"message\"", errIdx);
      if (mIdx >= 0) {
        int s = json.indexOf("\"", mIdx + 10) + 1;
        int e = json.indexOf("\"", s);
        if (s > 0 && e > s) return "API error: " + json.substring(s, e);
      }
    }
    return "No response received.";
  }

  int contentIdx = json.indexOf("\"content\"", msgIdx);
  if (contentIdx < 0) return "Parse error.";

  int start = json.indexOf("\"", contentIdx + 9) + 1;
  if (start <= 0) return "Parse error.";

  StringBuilder result = new StringBuilder();
  int i = start;
  while (i < json.length()) {
    char c = json.charAt(i);
    if (c == '\\' && i + 1 < json.length()) {
      char next = json.charAt(i + 1);
      // Handle 4-digit hex Unicode escapes in JSON (e.g. u003e becomes >)
      if (next == 'u' && i + 5 < json.length()) {
        try {
          int cp = Integer.parseInt(json.substring(i + 2, i + 6), 16);
          result.append((char) cp);
          i += 6;
          continue;
        } catch (NumberFormatException ex) { /* fall through */ }
      }
      switch (next) {
        case '"':  result.append('"');  break;
        case '\\': result.append('\\'); break;
        case 'n':  result.append('\n'); break;
        case 'r':  result.append('\r'); break;
        case 't':  result.append('\t'); break;
        default:   result.append(next); break;
      }
      i += 2;
    } else if (c == '"') {
      break;
    } else {
      result.append(c);
      i++;
    }
  }
  return result.length() > 0 ? result.toString() : "Empty response.";
}


// =========================
// JSON string escape utility
// =========================
String aiJsonStr(String s) {
  StringBuilder sb = new StringBuilder("\"");
  for (int i = 0; i < s.length(); i++) {
    char c = s.charAt(i);
    if      (c == '"')  sb.append("\\\"");
    else if (c == '\\') sb.append("\\\\");
    else if (c == '\n') sb.append("\\n");
    else if (c == '\r') sb.append("\\r");
    else if (c == '\t') sb.append("\\t");
    else                sb.append(c);
  }
  sb.append("\"");
  return sb.toString();
}


// =========================
// System Prompt -- injected with live game state every message
// =========================
String buildPetAIPrompt() {
  // Inventory summary
  StringBuilder inv = new StringBuilder();
  boolean hasItems = false;
  for (String slot : inventorySlots) {
    if (!slot.equals("EMPTY")) { inv.append(slot).append(", "); hasItems = true; }
  }
  String invStr = hasItems ? inv.toString().replaceAll(", $", "") : "empty";

  // Prescription status
  String rxStr = "none";
  if (prescribedMedicineIndex >= 0) {
    rxStr = medicineItemList[prescribedMedicineIndex]
      + " (" + prescriptionDaysCompleted + "/" + prescriptionDaysRequired + " days completed)";
  }

  // === Dynamic priority analysis ===
  StringBuilder priorities = new StringBuilder();

  if (isPetSick) {
    priorities.append("- PET IS SICK with " + currentSicknessName + ". This is the #1 priority. ");
    if (money >= 20) priorities.append("Player has $" + nf(money,0,2) + " -- RECOMMEND 5-STAR VET ($20). Never recommend 3-star when player can afford 5-star.");
    else if (money >= 5) priorities.append("Player only has $" + nf(money,0,2) + " -- only 3-star vet ($5) is affordable. Warn about 25% fail risk on 2nd+ visit.");
    else priorities.append("Player has $" + nf(money,0,2) + " -- cannot afford any vet. Suggest Help Around Town task to earn cash first.");
    if (prescribedMedicineIndex >= 0) priorities.append(" Prescription active: " + rxStr + " -- remind them to take medicine once per day (NOT twice -- overdose harms the pet).");
    priorities.append("\n");
  }

  if (alligator.health < 30) priorities.append("- HEALTH CRITICAL (" + nf(alligator.health,0,0) + "/100). Risk of game over. Avoid risky Help tasks. Visit vet.\n");
  else if (alligator.health < 60) priorities.append("- Health low (" + nf(alligator.health,0,0) + "/100). Consider vet or feeding healthy meat.\n");
  else priorities.append("- Health OK (" + nf(alligator.health,0,0) + "/100).\n");

  if (alligator.hunger >= 90) priorities.append("- HUNGER CRITICAL (" + nf(alligator.hunger,0,0) + "/100). Draining 7 extra HP/day. Feed immediately -- meat is best (no health penalty).\n");
  else if (alligator.hunger > 80) priorities.append("- HUNGER HIGH (" + nf(alligator.hunger,0,0) + "/100). Pet is in hungry mood. Feed soon.\n");
  else if (alligator.hunger > 60) priorities.append("- Hunger elevated (" + nf(alligator.hunger,0,0) + "/100). Feed today.\n");
  else priorities.append("- Hunger OK (" + nf(alligator.hunger,0,0) + "/100).\n");

  if (alligator.energy >= 80) priorities.append("- ENERGY TOO HIGH (" + nf(alligator.energy,0,0) + "/100). Draining 7 extra HP/day. Do NOT hire walker (drains energy further). Play a minigame to burn energy.\n");
  else if (alligator.energy < 20) priorities.append("- ENERGY CRITICAL (" + nf(alligator.energy,0,0) + "/100). Draining 7 extra HP/day. Use Rest mini-game (2 attempts/day, aim for green center zone).\n");
  else if (alligator.energy < 30) priorities.append("- Energy low (" + nf(alligator.energy,0,0) + "/100). Consider resting soon.\n");
  else if (alligator.energy > 70) priorities.append("- Energy slightly high (" + nf(alligator.energy,0,0) + "/100). Do NOT hire walker. Let it drift down naturally or play a minigame.\n");
  else priorities.append("- Energy ideal (" + nf(alligator.energy,0,0) + "/100, target 40-70).\n");

  if (alligator.sickrisk >= 90) priorities.append("- SICKNESS RISK CRITICAL (" + nf(alligator.sickrisk,0,0) + "/100). Draining 7 extra HP/day AND very likely to get sick tomorrow. Hire Cleaner ($10) immediately.\n");
  else if (alligator.sickrisk > 70) priorities.append("- Sickness risk very high (" + nf(alligator.sickrisk,0,0) + "/100). Hire Cleaner ($10) to reduce by 15.\n");
  else if (alligator.sickrisk > 50) priorities.append("- Sickness risk elevated (" + nf(alligator.sickrisk,0,0) + "/100). Consider Cleaner.\n");
  else priorities.append("- Sickness risk OK (" + nf(alligator.sickrisk,0,0) + "/100).\n");

  if (alligator.happiness < 40) priorities.append("- HAPPINESS CRITICAL (" + nf(alligator.happiness,0,0) + "/100). Draining 7 extra HP/day. Hire walker or feed high-happiness snacks like Cheesepuffs or Popcorn.\n");
  else if (alligator.happiness < 60) priorities.append("- Happiness low (" + nf(alligator.happiness,0,0) + "/100). Feed treats or hire walker.\n");
  else priorities.append("- Happiness OK (" + nf(alligator.happiness,0,0) + "/100).\n");

  if (money < 5) {
    if (moneyPerMinigamePoint == 0)
      priorities.append("- MONEY VERY LOW ($" + nf(money,0,2) + "). Minigames earn $0 -- buy '$ Per Point' upgrade in Earn > Tasks ($" + nf(pointUpgradeCost,0,2) + ") first. Until then, try Help Around Town (earns $" + nf(taskRewardAmount,0,2) + " but 40% sick risk).\n");
    else
      priorities.append("- MONEY VERY LOW ($" + nf(money,0,2) + "). Play minigames ($" + nf(moneyPerMinigamePoint,0,2) + "/point) or Help Around Town ($" + nf(taskRewardAmount,0,2) + "/task).\n");
  } else if (money < 20 && isPetSick) {
    priorities.append("- Money ($" + nf(money,0,2) + ") is not enough for 5-star vet ($20). Need to earn more. Consider Help tasks.\n");
  }

  if (job.equals("unemployed")) {
    if (day < 10) priorities.append("- No job yet. Cashier unlocks Day 10 (currently Day " + day + "). Earn via minigames or tasks.\n");
    else if (day < 25) priorities.append("- Unemployed. Cashier ($15/day) and Barista ($35/day) are both available -- apply in Earn > Job Finder.\n");
    else priorities.append("- Unemployed. Cashier ($15/day), Barista ($35/day), and Manager ($75/day) all available -- apply in Earn > Job Finder.\n");
  } else {
    priorities.append("- Job: " + job + " | Salary: $" + nf(salary,0,2) + "/day.\n");
    if (job.equals("cashier") && day >= 10) priorities.append("- Barista ($35/day base) is available -- consider switching in Earn > Job Finder.\n");
    if (job.equals("barista") && day >= 25) priorities.append("- Cafe Manager ($75/day base) is available -- consider switching in Earn > Job Finder.\n");
  }

  if (day % 7 == 0) priorities.append("- Store is CLOSED today (every 7th day). Cannot buy food or medicine.\n");
  else if ((7 - (day % 7)) == 1) priorities.append("- Store closes TOMORROW. Stock up on food and medicine today!\n");

  return
    "You are PetAI, an expert assistant for 'The Financial Responsibilities of Owning an Alligator' " +
    "-- an educational pet simulation game (Processing/Java, FBLA competition). " +
    "You know every mechanic exactly. Give specific, accurate advice based on the live game state below.\n\n" +

    "=== STATS (all 0-100) ===\n" +
    "Health: Higher = better. Game over at 0. Vet and meat raise it.\n" +
    "Happiness: Higher = better. Walker (+15), Cleaner (+10), treats raise it. Falls -10 overnight.\n" +
    "Energy: Ideal range is 40-70. Too high (>80) = hyper mood + 7 HP penalty/day. Too low (<20) = exhausted + 7 HP penalty/day. Energy rises +40 overnight. Walker costs energy -25. Rest recovers energy.\n" +
    "Hunger: HIGHER = MORE HUNGRY = WORSE. Hunger rises +40 overnight. Above 80 = hungry mood. Above 90 = 7 HP penalty/day. Feed meat for best results (no health penalty).\n" +
    "Sickness Risk: Lower = better. Minimum is 20 (irreducible). Rises +15/day if no cleaner hired. Above 50 = risky. Above 90 = 7 HP penalty/day.\n\n" +

    "=== DAILY STAT CHANGES (every new day) ===\n" +
    "Overnight drift: happiness -10, hunger +40, energy +40.\n" +
    "If no Cleaner hired that day: sickrisk +15.\n" +
    "If sick: health -20.\n" +
    "Red zone penalty (each costs -7 health/day): health<40, happiness<40, hunger>=90, sickrisk>=90, energy>=80 OR energy<20.\n" +
    "Salary paid daily if employed.\n" +
    "Rest attempts reset to 2 each morning.\n\n" +

    "=== SICKNESS TRIGGER ===\n" +
    "At each new day: roll random 0-100. If roll <= sickrisk AND pet not already sick -> pet gets sick.\n" +
    "Sickness type is based on worst stat: hunger>=85->dehydration, energy<=10->weakness, happiness<=15 or energy>=90->anxiety, hunger>=70->fatigue, energy<=20->exhaustion, happiness<=25->depression, else random (infection/parasite/fever/cold/flu).\n" +
    "Sickness costs 20 HP/day until cured by completing the full prescription course.\n\n" +

    "=== VET -- CRITICAL RULES ===\n" +
    "3-Star Vet ($5): 25% failure chance on 2nd+ visit. Only recommend if player has <$20.\n" +
    "5-Star Vet ($20): ALWAYS succeeds. ALWAYS recommend if player has $20+. NEVER recommend 3-star when player can afford 5-star.\n" +
    "When sick: vet prescribes medicine. Player picks it up FREE from store, then uses it once per day.\n" +
    "Overdose (using prescribed medicine twice same day): health-20, energy-10, happiness-10.\n" +
    "Wrong medicine (not prescribed): health-35, energy-10, happiness-10, sickrisk+25. Very dangerous.\n" +
    "When NOT sick: vet restores +30 health.\n\n" +

    "=== SERVICES ===\n" +
    "Walker ($10): energy-25, happiness+15, health+5. NEVER recommend if energy < 30 (would make things worse).\n" +
    "Cleaner ($10): sickrisk-15, happiness+10, health+5. Hire daily to prevent the +15 sickrisk drift.\n\n" +

    "=== FOOD STAT EFFECTS ===\n" +
    "PREMIUM: Steak (starting item) hunger-70, energy+40, health+20, happiness+20. Best food in game.\n" +
    "MEAT (good -- no health penalty): Lamb Chop hunger-70 energy+35 health+10 happy+15 | Bass hunger-60 energy+25 health+20 happy+10 | Chicken hunger-60 energy+20 health+20 happy+10 | Catfish hunger-60 energy+25 health+15 happy+10 | Pork Chop hunger-65 energy+30 health+10 happy+10 | Crab hunger-50 energy+15 health+25 happy+20 | Perch hunger-50 energy+15 health+20 happy+5 | Frog hunger-45 energy+20 health+15 happy+25 | Bluegill hunger-55 energy+20 health+15 happy+10 | Shrimp hunger-35 energy+10 health+25 happy+15 | Goldfish hunger-30 energy+10 health+5 happy+15.\n" +
    "SNACKS (junk food -- all damage health): Nachos hunger-40 energy+30 health-15 happy+5 | Chips hunger-30 energy+10 health-10 happy+10 | Popcorn hunger-10 energy+10 health-10 happy+30 | Cheesepuffs hunger-25 energy+10 health-5 happy+20 | Chocolate Bar hunger-7 energy+5 health-5 happy+20 | Cookies hunger-30 energy+5 health-5 happy+10 | Granola Bar hunger-15 energy+20 health-5 happy+5 | Trail Mix hunger-10 energy+20 health-5 happy+5 | Pretzels hunger-10 energy+15 health-5 happy+5 | Crackers hunger-5 energy+20 (no health hit).\n" +
    "DANGEROUS SNACKS: Energy Drink hunger+20 energy+70 health-35 happy-10 -- massive energy spike, serious health damage. Soda hunger+30 energy+40 health-30 happy+5 -- increases hunger, hurts health badly. Avoid both unless desperate.\n\n" +

    "=== JOBS & INCOME ===\n" +
    "Cashier: base $15/day. Always available. Max salary ~$32 via upgrades.\n" +
    "Barista: base $35/day. Unlocks Day 10. Max salary ~$70 via upgrades.\n" +
    "Cafe Manager: base $75/day. Unlocks Day 25. No salary cap.\n" +
    "Salary upgrade: +12% per upgrade. Cost grows +40% each purchase. Buy in Earn > Tasks.\n" +
    "Quit a job in the Earn panel main screen (red QUIT button). Can switch jobs anytime.\n\n" +

    "=== MINIGAMES ===\n" +
    "Three games: Swamp Hop (side-scroller, SPACE to jump over logs/vines/rocks/mud), Snack Snatch (catch falling food with A/D or arrow keys, dodge vegetables), Fetch Frenzy (top-down, WASD/arrows, timed ball fetch).\n" +
    "By default minigames earn $0. Player must buy '$ Per Point' upgrade in Earn > Tasks ($" + nf(pointUpgradeCost,0,2) + ").\n" +
    "First upgrade sets earnings to $0.10/point. Each subsequent upgrade multiplies by 1.2x.\n" +
    "NEVER recommend minigames for income if moneyPerMinigamePoint is 0.\n\n" +

    "=== TASKS & UPGRADES (Earn > Tasks panel) ===\n" +
    "Help Around Town: one-time errand that pays $" + nf(taskRewardAmount,0,2) + " per task. 40% chance of making pet sick -- risky when health/stats are low.\n" +
    "Task reward upgrade: +12% per upgrade, costs grow each time.\n" +
    "$ Per Point upgrade: activates minigame earnings. Cost: $" + nf(pointUpgradeCost,0,2) + " currently.\n" +
    "Salary upgrade: +12% per upgrade, costs grow, requires active job.\n\n" +

    "=== REST MINI-GAME ===\n" +
    "Access via the REST button on the main screen. Opens a gradient timing bar.\n" +
    "2 attempts per day (resets each morning). Click REST when the moving marker is in the GREEN CENTER zone for best energy recovery. Edges of bar (red zones) give poor recovery.\n" +
    "Use when energy is below 30.\n\n" +

    "=== STORE ===\n" +
    "3 tabs: Medicine, Snacks, Meat. Medicine $5 normally, FREE if prescribed by vet.\n" +
    "Snack prices vary. Meat items cost more but are nutritionally superior.\n" +
    "Store CLOSED every 7th day (Sunday). Plan ahead -- stock up the day before.\n" +
    "Inventory is 12 slots. Items bought go to inventory; use them from inventory on main screen.\n\n" +

    "=== BANK ===\n" +
    "Logs every transaction (income and purchases). View in the Bank panel.\n\n" +

    "=== ACHIEVEMENTS (30 total, tiered) ===\n" +
    "8 categories: minigame high scores, money milestones, care actions (feed/medicine/vet/rest/walker/cleaner), upgrades, tasks, store purchases, bank transactions, days survived.\n" +
    "Each achievement has tiers -- completing one tier unlocks the next with a higher goal and reward.\n" +
    "Collect completed achievements in the Achievements panel to receive bonus money ($).\n" +
    "Always remind players to check achievements -- they may have uncollected rewards waiting.\n\n" +

    "=== MOOD SPRITES ===\n" +
    "Sick sprite shows when isPetSick. Hungry sprite when hunger>80. Energetic/hyper sprite when energy>80. Neutral otherwise.\n\n" +

    "=== SCREEN NAVIGATION ===\n" +
    "Main Screen -> PLAY (minigames) | REST (energy mini-game) | STORE (buy food/medicine) | SERVICES (vet/walker/cleaner/PetAI) | EARN (jobs/tasks/upgrades) | BANK (transactions) | Achievements panel.\n" +
    "Next Day button advances time -- all overnight stat changes apply.\n\n" +

    "=== CURRENT GAME STATE ===\n" +
    "Pet name: "         + alligator.petName + "\n" +
    "Day: "              + day + "\n" +
    "Money: $"           + nf(money, 0, 2) + "\n" +
    "Health: "           + nf(alligator.health,    0, 1) + "/100\n" +
    "Happiness: "        + nf(alligator.happiness, 0, 1) + "/100\n" +
    "Energy: "           + nf(alligator.energy,    0, 1) + "/100 (ideal 40-70)\n" +
    "Hunger: "           + nf(alligator.hunger,    0, 1) + "/100 (higher=more hungry)\n" +
    "Sickness Risk: "    + nf(alligator.sickrisk,  0, 1) + "/100 (lower=better, min 20)\n" +
    "Sick: "             + (isPetSick ? "YES -- " + currentSicknessName : "No") + "\n" +
    "Job: "              + job + " | Salary: $" + nf(salary, 0, 2) + "/day\n" +
    "Rest attempts left: " + restAttemptsRemaining + "/2\n" +
    "Inventory: "        + invStr + "\n" +
    "Prescription: "     + rxStr + "\n" +
    "Minigame $/point: " + (moneyPerMinigamePoint == 0
      ? "$0 -- upgrade not bought yet (costs $" + nf(pointUpgradeCost,0,2) + " in Earn > Tasks)"
      : "$" + nf(moneyPerMinigamePoint,0,2) + "/point") + "\n" +
    "Task reward: $"     + nf(taskRewardAmount, 0, 2) + "/task (40% sick risk)\n\n" +

    "=== WHAT NEEDS ATTENTION RIGHT NOW ===\n" +
    priorities.toString() + "\n" +

    "RESPONSE RULES: Keep replies concise (2-5 sentences max). Always reference actual stat values. " +
    "Never contradict the priority analysis above. Never recommend 3-star vet if player has $20+. " +
    "Never recommend minigames for income if $/point is $0. Never recommend walker if energy < 30. " +
    "Be friendly, knowledgeable, and encouraging. You are always PetAI.";
}
