// Graphical User Interface components
// Uses G4P contributed Processing library (only runs with Windows Java)

import g4p_controls.*;
import java.awt.Font;

GButton generateButton;
GButton clearButton;
GButton runButton;
GButton runJButton;
GButton saveFolderButton;
GButton chatButton;
GButton chatSketchButton;
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
int SAVE_FOLDER_BUTTON_X;
int SAVE_FOLDER_BUTTON_Y;
int SAVE_FOLDER_BUTTON_WIDTH;
int SAVE_FOLDER_BUTTON_HEIGHT;
int CHAT_BUTTON_X;
int CHAT_BUTTON_Y;
int CHAT_BUTTON_WIDTH;
int CHAT_BUTTON_HEIGHT;
int CHAT_SKETCH_BUTTON_X;
int CHAT_SKETCH_BUTTON_Y;
int CHAT_SKETCH_BUTTON_WIDTH;
int CHAT_SKETCH_BUTTON_HEIGHT;

// animation variables section
static final int ANIMATION_STEPS = 4;
int[] animationCounter = new int[3];
String[] animationSequence = {"|", "/", "-", "\\"};
int animationHeight = 96;
static final int NO_ANIMATION = 0;
static final int SHOW_SECONDS = 1;
static final int SHOW_SPINNER = 2;
int animation = NO_ANIMATION;  // flag to control animation while waiting for a thread like openai-api to respond

/**
 * Perform animation while waiting for a thread to complete
 * selectAnimation type of animation
 */
void doAnimation(int selectAnimation) {
  fill(color(0, 0, 255));
  textSize(animationHeight);
  switch(selectAnimation) {
  case SHOW_SECONDS:
    int seconds = animationCounter[selectAnimation]/int(appFrameRate);
    String working0 = str(seconds) + " ... \u221e" ;  // infinity
    text(working0, RESPONSE_WIDTH/2- textWidth(working0)/2, RESPONSE_HEIGHT/2);
    animationCounter[selectAnimation]++;
    break;
  case SHOW_SPINNER:
    String working1 = animationSequence[animationCounter[selectAnimation]]; // Symbol sequence
    text(working1, RESPONSE_WIDTH/2 - textWidth(working1)/2, RESPONSE_HEIGHT/2);
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
  RUN_BUTTON_Y = 5 * fontHeight;

  RUNJ_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  RUNJ_BUTTON_HEIGHT = 5 * fontHeight;
  RUNJ_BUTTON_X = PROMPT_WIDTH + 1 + RUN_BUTTON_WIDTH;
  RUNJ_BUTTON_Y = 5 * fontHeight;

  SAVE_FOLDER_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  SAVE_FOLDER_BUTTON_HEIGHT = 5 * fontHeight;
  SAVE_FOLDER_BUTTON_X = PROMPT_WIDTH + 1 + CLEAR_BUTTON_WIDTH;
  SAVE_FOLDER_BUTTON_Y = height - 2*PROMPT_HEIGHT;

  CHAT_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  CHAT_BUTTON_HEIGHT = 5 * fontHeight;
  CHAT_BUTTON_X = PROMPT_WIDTH + 1;
  CHAT_BUTTON_Y = 0;

  CHAT_SKETCH_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  CHAT_SKETCH_BUTTON_HEIGHT = 5 * fontHeight;
  CHAT_SKETCH_BUTTON_X = PROMPT_WIDTH + 1 + CLEAR_BUTTON_WIDTH;
  CHAT_SKETCH_BUTTON_Y = 0;
  
    G4P.setMouseOverEnabled(true);
  promptArea = new GTextArea(this, PROMPT_X, PROMPT_Y, PROMPT_WIDTH, PROMPT_HEIGHT, G4P.SCROLLBARS_NONE, PROMPT_WIDTH-3*int(textWidth("W")));
  promptArea.setFont(new Font("Arial", Font.BOLD, fontHeight));
  promptArea.setPromptText(INITIAL_PROMPT);
  promptArea.setOpaque(true);
  responseArea = new GTextArea(this, RESPONSE_X, RESPONSE_Y, RESPONSE_WIDTH, RESPONSE_HEIGHT, G4P.SCROLLBARS_NONE);
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
  saveFolderButton = new GButton(this, SAVE_FOLDER_BUTTON_X, SAVE_FOLDER_BUTTON_Y, SAVE_FOLDER_BUTTON_WIDTH, SAVE_FOLDER_BUTTON_HEIGHT, "Save\nFolder");
  saveFolderButton.tag = "Button:  Save Folder";
  saveFolderButton.setOpaque(true);
  saveFolderButton.setFont(buttonFont);
  chatButton = new GButton(this, CHAT_BUTTON_X, CHAT_BUTTON_Y, CHAT_BUTTON_WIDTH, CHAT_BUTTON_HEIGHT, "General\nChat");
  chatButton.tag = "Button:  Chat";
  chatButton.setOpaque(true);
  chatButton.setFont(buttonFont);
  chatButton.setTipText("Function Key F2");
  chatSketchButton = new GButton(this, CHAT_SKETCH_BUTTON_X, CHAT_SKETCH_BUTTON_Y, CHAT_SKETCH_BUTTON_WIDTH, CHAT_SKETCH_BUTTON_HEIGHT, "Sketch\nChat");
  chatSketchButton.tag = "Button:  Sketch Chat";
  chatSketchButton.setOpaque(true);
  chatSketchButton.setFont(buttonFont);
  chatSketchButton.setTipText("Function Key F4");

}

public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) {
  /* code */
  //if (DEBUG) println(event.toString());
  if (event.toString().equals("LOST_FOCUS")) {
  }
}

public void handleButtonEvents(GButton button, GEvent event) {
  // Folder selection
  if (button == generateButton && event == GEvent.CLICKED) {
    println("Button Generate pressed");
    lastKey = 0;
    lastKeyCode = KEYCODE_ENTER;
  } else if (button == runButton && event == GEvent.CLICKED) {
    println("Button Run pressed");
    lastKey = 0;
    lastKeyCode = KEYCODE_F10;
  } else if (button == runJButton && event == GEvent.CLICKED) {
    println("Button Run pressed");
    lastKey = 0;
    lastKeyCode = KEYCODE_F11;
  } else if (button == chatButton && event == GEvent.CLICKED) {
    println("Button Chat pressed");
    lastKey = 0;
    lastKeyCode = KEYCODE_F2;
  } else if (button == chatSketchButton && event == GEvent.CLICKED) {
    println("Button Chat Sketch pressed");
    lastKey = 0;
    lastKeyCode = KEYCODE_F4;
  } else if (button == clearButton && event == GEvent.CLICKED) {
    println("Button Clear pressed");
    promptArea.setText("");
  } else if (button == saveFolderButton && event == GEvent.CLICKED) {
    println("saveFolder selection pressed");
    lastKey = 0;
    lastKeyCode = KEYCODE_F9;
  }
}
