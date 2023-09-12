// Graphical User Interface components
// Uses G4P contributed Processing library (only runs with Windows Java)

import g4p_controls.*;
import java.awt.Font;

static final String TITLE = "Processing Sketch Chatbot";
static final String INITIAL_PROMPT = "Enter prompt here. Select New Chat: General or Sketch. Use ESC key to exit. ";

GButton generateButton;
GButton clearButton;
GButton runButton;
GButton runJButton;
GButton loadChatLogButton;
GButton reviewChatButton;
GButton saveFolderButton;
GButton chat1Button;
GButton chat2Button;
GButton chat3Button;
GButton chat4Button;
GButton chat5Button;
GButton chat6Button;
GTextArea promptArea;
GTextArea responseArea;

int WIDTH;
int HEIGHT;
int PROMPT_X;
int PROMPT_Y;
int RESPONSE_X;
int RESPONSE_Y;
int PROMPT_WIDTH;
int PROMPT_HEIGHT;
int RESPONSE_WIDTH;
int RESPONSE_HEIGHT;
int GENERATE_BUTTON_X;
int GENERATE_BUTTON_Y;
int GENERATE_BUTTON_WIDTH;
int GENERATE_BUTTON_HEIGHT;
int CLEAR_BUTTON_X;
int CLEAR_BUTTON_Y;
int CLEAR_BUTTON_WIDTH;
int CLEAR_BUTTON_HEIGHT;
int RUN_BUTTON_X;
int RUN_BUTTON_Y;
int RUN_BUTTON_WIDTH;
int RUN_BUTTON_HEIGHT;
int RUNJ_BUTTON_X;
int RUNJ_BUTTON_Y;
int RUNJ_BUTTON_WIDTH;
int RUNJ_BUTTON_HEIGHT;
int LOAD_CHATLOG_BUTTON_X;
int LOAD_CHATLOG_BUTTON_Y;
int LOAD_CHATLOG_BUTTON_WIDTH;
int LOAD_CHATLOG_BUTTON_HEIGHT;
int REVIEW_CHAT_BUTTON_X;
int REVIEW_CHAT_BUTTON_Y;
int REVIEW_CHAT_BUTTON_WIDTH;
int REVIEW_CHAT_BUTTON_HEIGHT;
int SAVE_FOLDER_BUTTON_X;
int SAVE_FOLDER_BUTTON_Y;
int SAVE_FOLDER_BUTTON_WIDTH;
int SAVE_FOLDER_BUTTON_HEIGHT;

int CHAT1_BUTTON_X;
int CHAT1_BUTTON_Y;
int CHAT1_BUTTON_WIDTH;
int CHAT1_BUTTON_HEIGHT;
int CHAT2_BUTTON_X;
int CHAT2_BUTTON_Y;
int CHAT2_BUTTON_WIDTH;
int CHAT2_BUTTON_HEIGHT;
int CHAT3_BUTTON_X;
int CHAT3_BUTTON_Y;
int CHAT3_BUTTON_WIDTH;
int CHAT3_BUTTON_HEIGHT;
int CHAT4_BUTTON_X;
int CHAT4_BUTTON_Y;
int CHAT4_BUTTON_WIDTH;
int CHAT4_BUTTON_HEIGHT;
int CHAT5_BUTTON_X;
int CHAT5_BUTTON_Y;
int CHAT5_BUTTON_WIDTH;
int CHAT5_BUTTON_HEIGHT;
int CHAT6_BUTTON_X;
int CHAT6_BUTTON_Y;
int CHAT6_BUTTON_WIDTH;
int CHAT6_BUTTON_HEIGHT;

int CHAT_SKETCH_BUTTON_X;
int CHAT_SKETCH_BUTTON_Y;
int CHAT_SKETCH_BUTTON_WIDTH;
int CHAT_SKETCH_BUTTON_HEIGHT;

color black = color(0);   // black
color gray = color(128);
color graytransparent = color(128, 128, 128, 128);
color darktransparent = color(32, 32, 32, 128);
color white = color(255); // white
color red = color(255, 0, 0);
color aqua = color(128, 0, 128);
color lightblue = color(64, 64, 128);
color darkblue = color(32, 32, 64);
color blue = color(0, 0, 255);
color hintblue = color(192, 128, 255);
color yellow = color(255, 204, 0);
color silver = color(193, 194, 186);
color brown = color(69, 66, 61);
color bague = color(183, 180, 139);
color offWhite = color(224);

// animation variables section
static final int ANIMATION_STEPS = 4;
int[] animationCounter = new int[3];
String[] animationSequence = {"|", "/", "-", "\\"};
int animationHeight = 96;  // font height
static final int NO_ANIMATION = 0;
static final int SHOW_SECONDS = 1;
static final int SHOW_SPINNER = 2;
int animation = NO_ANIMATION;  // flag to control animation while waiting for a thread like openai-api to respond

/**
 * Perform animation while waiting for a thread to complete
 * selectAnimation variable defines the type of animation seen
 */
void doAnimation(int selectAnimation) {
  fill(blue);
  textSize(animationHeight);
  String working;
  switch(selectAnimation) {
  case SHOW_SECONDS:
    int seconds = animationCounter[selectAnimation]/int(appFrameRate);
    working =  model + "    " + str(seconds) + " ... \u221e" ;  // infinity
    text(working, RESPONSE_WIDTH/2- textWidth(working)/2, RESPONSE_HEIGHT/2);
    animationCounter[selectAnimation]++;
    break;
  case SHOW_SPINNER:
    working = animationSequence[animationCounter[selectAnimation]]; // Symbol sequence
    text(working, RESPONSE_WIDTH/2 - textWidth(working)/2, RESPONSE_HEIGHT/2);
    animationCounter[selectAnimation]++;
    if (animationCounter[selectAnimation] >= ANIMATION_STEPS) animationCounter[selectAnimation] = 0;
    break;
  default:
    animationCounter[0] = 0;
    animationCounter[1] = 0;
    animationCounter[2] = 0;
    break;
  }
}

void showIntroduction() {
  responseArea.setVisible(false);
  textSize(2*fontHeight);
  int delta = int(textAscent() + textDescent());
  int offsetX = 20;
  int offsetY = height/2 - delta;
  drawText("Processing Sketch Chat", offsetX, offsetY, black, hintblue );
  drawText("Version: " + VERSION, offsetX, offsetY+delta, black, hintblue );
  drawText("Copyright 2023 Andy Modla, All Rights Reserved", offsetX, offsetY+2*delta, black, hintblue );
}

void showInformation() {
  responseArea.setVisible(false);
  textSize(fontHeight);
  int delta = int(textAscent() + textDescent());
  int offsetX = 20;
  int offsetY = 3*height/4 - delta;
  drawText("Save Folder: "+ saveFolderPath, offsetX, offsetY, black, offWhite );
  drawText("model: " + model, offsetX, offsetY+delta, black, offWhite );
  drawText("temperature: " + temperature, offsetX, offsetY+2*delta, black, offWhite );
  drawText("topP: " + topP, offsetX, offsetY+3*delta, black, offWhite );
  drawText("timeout: " + timeout+ " seconds", offsetX, offsetY+4*delta, black, offWhite );
}

// display an error message
void showError(String str) {
  if (str != null) {
    fill(color(255, 128, 0));
    textSize(fontHeight);
    int leng = str.length();
    int i = 0;
    int k = 1;
    while (i<leng) {
      if ((leng -i)<80) {
        text(str.substring(i), RESPONSE_WIDTH/128, k*fontHeight+errorMessageHeight);
        break;
      } else {
        text(str.substring(i, i+80), RESPONSE_WIDTH/128, k*fontHeight+errorMessageHeight);
      }
      i+= 80;
      k++;
    }
  }
}

// draw text on screen
void drawText(String str, int x, int y, color foreground, color background) {
  fill(background); // Set the fill color behind text
  noStroke();
  rect(x, y-(textAscent() ), textWidth(str), textAscent() + textDescent()); // Draw a rectangle behind the text
  fill(foreground); // Set the text fill color
  text(str, x, y); // Display the text
}

void initGUI() {
  fontHeight = 24;

  RESPONSE_WIDTH = (3*width) / 4;
  RESPONSE_HEIGHT = height - 5*fontHeight;
  RESPONSE_X = 0;
  RESPONSE_Y = 0;

  PROMPT_WIDTH = (3*width)/4;
  PROMPT_HEIGHT = 5 * fontHeight;
  PROMPT_X = 0;
  PROMPT_Y = height - PROMPT_HEIGHT;

  GENERATE_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  GENERATE_BUTTON_HEIGHT = 5 * fontHeight;
  GENERATE_BUTTON_X = PROMPT_WIDTH + 1;
  GENERATE_BUTTON_Y = height - PROMPT_HEIGHT;

  CLEAR_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  CLEAR_BUTTON_HEIGHT = 5 * fontHeight;
  CLEAR_BUTTON_X = PROMPT_WIDTH + 1 + CLEAR_BUTTON_WIDTH;
  CLEAR_BUTTON_Y = height - PROMPT_HEIGHT;

  RUN_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  RUN_BUTTON_HEIGHT = 5 * fontHeight;
  RUN_BUTTON_X = PROMPT_WIDTH + 1;
  RUN_BUTTON_Y = 25 * fontHeight;

  RUNJ_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  RUNJ_BUTTON_HEIGHT = 5 * fontHeight;
  RUNJ_BUTTON_X = PROMPT_WIDTH + 1 + RUN_BUTTON_WIDTH;
  RUNJ_BUTTON_Y = 25 * fontHeight;

  LOAD_CHATLOG_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  LOAD_CHATLOG_BUTTON_HEIGHT = 5 * fontHeight;
  LOAD_CHATLOG_BUTTON_X = PROMPT_WIDTH + 1 ;
  LOAD_CHATLOG_BUTTON_Y = height - 3*PROMPT_HEIGHT;

  REVIEW_CHAT_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  REVIEW_CHAT_BUTTON_HEIGHT = 5 * fontHeight;
  REVIEW_CHAT_BUTTON_X = PROMPT_WIDTH + 1 ;
  REVIEW_CHAT_BUTTON_Y = height - 2*PROMPT_HEIGHT;

  SAVE_FOLDER_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  SAVE_FOLDER_BUTTON_HEIGHT = 5 * fontHeight;
  SAVE_FOLDER_BUTTON_X = PROMPT_WIDTH + 1 + CLEAR_BUTTON_WIDTH;
  SAVE_FOLDER_BUTTON_Y = height - 2*PROMPT_HEIGHT;

  CHAT1_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  CHAT1_BUTTON_HEIGHT = 5 * fontHeight;
  CHAT1_BUTTON_X = PROMPT_WIDTH + 1;
  CHAT1_BUTTON_Y = 0;

  CHAT2_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  CHAT2_BUTTON_HEIGHT = 5 * fontHeight;
  CHAT2_BUTTON_X = PROMPT_WIDTH + 1 + CLEAR_BUTTON_WIDTH;
  CHAT2_BUTTON_Y = 0;

  CHAT3_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  CHAT3_BUTTON_HEIGHT = 5 * fontHeight;
  CHAT3_BUTTON_X = PROMPT_WIDTH + 1 ;
  CHAT3_BUTTON_Y = 5 * fontHeight;

  CHAT4_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  CHAT4_BUTTON_HEIGHT = 5 * fontHeight;
  CHAT4_BUTTON_X = PROMPT_WIDTH + 1 + CLEAR_BUTTON_WIDTH;
  CHAT4_BUTTON_Y = 5 * fontHeight;

  CHAT5_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  CHAT5_BUTTON_HEIGHT = 5 * fontHeight;
  CHAT5_BUTTON_X = PROMPT_WIDTH + 1 ;
  CHAT5_BUTTON_Y = 10 * fontHeight;

  CHAT6_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  CHAT6_BUTTON_HEIGHT = 5 * fontHeight;
  CHAT6_BUTTON_X = PROMPT_WIDTH + 1 + CLEAR_BUTTON_WIDTH;
  CHAT6_BUTTON_Y = 10 * fontHeight;

  //CHAT_SKETCH_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  //CHAT_SKETCH_BUTTON_HEIGHT = 5 * fontHeight;
  //CHAT_SKETCH_BUTTON_X = PROMPT_WIDTH + 1 + CLEAR_BUTTON_WIDTH;
  //CHAT_SKETCH_BUTTON_Y = 0;

  G4P.setMouseOverEnabled(true);
  promptArea = new GTextArea(this, PROMPT_X, PROMPT_Y, PROMPT_WIDTH, PROMPT_HEIGHT, G4P.SCROLLBARS_NONE, PROMPT_WIDTH-3*int(textWidth("W")));
  promptArea.setFont(new Font("Arial", Font.BOLD, fontHeight));
  promptArea.setPromptText(INITIAL_PROMPT);
  promptArea.setOpaque(true);

  //responseArea = new GTextArea(this, RESPONSE_X, RESPONSE_Y, RESPONSE_WIDTH, RESPONSE_HEIGHT, G4P.SCROLLBARS_NONE);
  responseArea = new GTextArea(this, RESPONSE_X, RESPONSE_Y, RESPONSE_WIDTH, RESPONSE_HEIGHT, G4P.SCROLLBARS_VERTICAL_ONLY);
  responseArea.setFont(new Font("Arial", Font.PLAIN, fontHeight));
  responseArea.setOpaque(true);

  generateButton = new GButton(this, GENERATE_BUTTON_X, GENERATE_BUTTON_Y, GENERATE_BUTTON_WIDTH, GENERATE_BUTTON_HEIGHT, "Generate");
  generateButton.tag = "Button:  Generate";
  generateButton.setOpaque(true);

  Font buttonFont = new Font("Arial", Font.BOLD, 2*fontHeight);
  generateButton.setFont(buttonFont);
  clearButton = new GButton(this, CLEAR_BUTTON_X, CLEAR_BUTTON_Y, CLEAR_BUTTON_WIDTH, CLEAR_BUTTON_HEIGHT, "Clear");
  clearButton.tag = "Button:  Clear";
  clearButton.setOpaque(true);
  clearButton.setFont(buttonFont);

  runButton = new GButton(this, RUN_BUTTON_X, RUN_BUTTON_Y, RUN_BUTTON_WIDTH, RUN_BUTTON_HEIGHT, "Run IDE\nSketch");
  runButton.tag = "Button:  Run";
  runButton.setOpaque(true);
  runButton.setFont(buttonFont);

  runJButton = new GButton(this, RUNJ_BUTTON_X, RUNJ_BUTTON_Y, RUNJ_BUTTON_WIDTH, RUNJ_BUTTON_HEIGHT, "Run\nSketch");
  runJButton.tag = "Button:  Run Sketch";
  runJButton.setOpaque(true);
  runJButton.setFont(buttonFont);

  loadChatLogButton = new GButton(this, LOAD_CHATLOG_BUTTON_X, LOAD_CHATLOG_BUTTON_Y, LOAD_CHATLOG_BUTTON_WIDTH, LOAD_CHATLOG_BUTTON_HEIGHT, "Load\nChat Log");
  loadChatLogButton.tag = "Button:  Load Chat Log";
  loadChatLogButton.setOpaque(true);
  loadChatLogButton.setFont(buttonFont);

  reviewChatButton = new GButton(this, REVIEW_CHAT_BUTTON_X, REVIEW_CHAT_BUTTON_Y, REVIEW_CHAT_BUTTON_WIDTH, REVIEW_CHAT_BUTTON_HEIGHT, "Show\nChat Log");
  reviewChatButton.tag = "Button:  Review Chat";
  reviewChatButton.setOpaque(true);
  reviewChatButton.setFont(buttonFont);

  saveFolderButton = new GButton(this, SAVE_FOLDER_BUTTON_X, SAVE_FOLDER_BUTTON_Y, SAVE_FOLDER_BUTTON_WIDTH, SAVE_FOLDER_BUTTON_HEIGHT, "Save\nFolder");
  saveFolderButton.tag = "Button:  Save Folder";
  saveFolderButton.setOpaque(true);
  saveFolderButton.setFont(buttonFont);

  chat1Button = new GButton(this, CHAT1_BUTTON_X, CHAT1_BUTTON_Y, CHAT1_BUTTON_WIDTH, CHAT1_BUTTON_HEIGHT, "Single\nPrompt");
  chat1Button.tag = "Button:  Single Prompt";
  chat1Button.setOpaque(true);
  chat1Button.setFont(buttonFont);
  chat1Button.setTip("New Single Prompt", 0, 0);

  chat2Button = new GButton(this, CHAT2_BUTTON_X, CHAT2_BUTTON_Y, CHAT2_BUTTON_WIDTH, CHAT2_BUTTON_HEIGHT, "General\nChat");
  chat2Button.tag = "Button:  Chat";
  chat2Button.setOpaque(true);
  chat2Button.setFont(buttonFont);
  chat2Button.setTip("New General Chat", 0, 0);

  chat3Button = new GButton(this, CHAT3_BUTTON_X, CHAT3_BUTTON_Y, CHAT3_BUTTON_WIDTH, CHAT3_BUTTON_HEIGHT, "Sketch\nChat");
  chat3Button.tag = "Button:  Sketch Chat";
  chat3Button.setOpaque(true);
  chat3Button.setFont(buttonFont);
  chat3Button.setTip("New Processing Sketch Chat", 0, 0);

  chat4Button = new GButton(this, CHAT4_BUTTON_X, CHAT4_BUTTON_Y, CHAT4_BUTTON_WIDTH, CHAT4_BUTTON_HEIGHT, "Custom\nChat");
  chat4Button.tag = "Button:  Custom Chat";
  chat4Button.setOpaque(true);
  chat4Button.setFont(buttonFont);
  chat4Button.setTip("Left Click - New Custom Chat\nRight Click - Select Custom Chat File", 0, 0);

  //chat5Button = new GButton(this, CHAT5_BUTTON_X, CHAT5_BUTTON_Y, CHAT5_BUTTON_WIDTH, CHAT5_BUTTON_HEIGHT, "Custom\nChat2");
  //chat5Button.tag = "Button:  Custom Chat2";
  //chat5Button.setOpaque(true);
  //chat5Button.setFont(buttonFont);
  //chat5Button.setTip("Function Key F5", 0, 0);

  //chat6Button = new GButton(this, CHAT6_BUTTON_X, CHAT6_BUTTON_Y, CHAT6_BUTTON_WIDTH, CHAT6_BUTTON_HEIGHT, "Custom\nChat3");
  //chat6Button.tag = "Button:  Custom Chat3";
  //chat6Button.setOpaque(true);
  //chat6Button.setFont(buttonFont);
  //chat6Button.setTipText("Function Key F6");
}

void setChatButtonText(String text) {
  chat4Button.setText(text);
}

void setChatButtonBackgroundColor(GButton button, boolean active) {
  if (active)
    button.setLocalColor(6, #FF808000);
  else
    button.setLocalColor(6, #FF000080);
}

public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) {
  /* code */
  //logger(event.toString());
  if (event.toString().equals("LOST_FOCUS")) {
  }
}

public void handleButtonEvents(GButton button, GEvent event) {
  if (mouseButtonAlert == RIGHT) {
    if (button == chat4Button && event == GEvent.CLICKED) {
      logger("Button Custom1 Chat pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_GET_CUSTOM_CHAT_FILE;
      logger("Get custom chat file");
    }
  } else if (mouseButtonAlert == LEFT) {
    if (button == generateButton && event == GEvent.CLICKED) {
      logger("Button Generate pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_ENTER;
    } else if (button == runButton && event == GEvent.CLICKED) {
      logger("Button Run pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_F10;
    } else if (button == runJButton && event == GEvent.CLICKED) {
      logger("Button Run pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_F11;
    } else if (button == chat1Button && event == GEvent.CLICKED) {
      logger("Button Chat pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_F1;
    } else if (button == chat2Button && event == GEvent.CLICKED) {
      logger("Button Chat pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_F2;
    } else if (button == chat3Button && event == GEvent.CLICKED) {
      logger("Button Chat Sketch pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_F3;
    } else if (button == chat4Button && event == GEvent.CLICKED) {
      logger("Button Custom1 Chat pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_F4;
    } else if (button == chat5Button && event == GEvent.CLICKED) {
      logger("Button Custom2 Chat pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_F5;
    } else if (button == chat6Button && event == GEvent.CLICKED) {
      logger("Button Custom3 Chat pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_F6;
    } else if (button == clearButton && event == GEvent.CLICKED) {
      logger("Button Clear pressed");
      clearPrompt();
    } else if (button == reviewChatButton && event == GEvent.CLICKED) {
      logger("Review Chat pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_TAB;
    } else if (button == saveFolderButton && event == GEvent.CLICKED) {
      logger("saveFolder selection pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_F9;
    } else if (button == loadChatLogButton && event == GEvent.CLICKED) {
      logger("Load chat log Button");
      lastKey = 0;
      lastKeyCode = KEYCODE_LOAD_CHAT_LOG_FILE;
    }
  }
}

public void clearPrompt() {
  promptArea.setText("");
  prompt = "";
}

public void clearAll() {
  promptArea.setText("");
  prompt = "";
  responseArea.setText("");
}
