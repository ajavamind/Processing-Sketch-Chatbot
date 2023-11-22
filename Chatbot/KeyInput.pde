// Text Entry and control key input handling
// Key codes serve dual purpose for commands and text entry
// Keycodes common to both Windows and Android

static final int KEYCODE_NOP = 0;
static final int KEYCODE_BACK = 4;
static final int KEYCODE_BACKSPACE = 8;
static final int KEYCODE_TAB = 9;
static final int KEYCODE_ENTER = 66; // Android only
static final int KEYCODE_LF = 10;
static final int KEY_CTRL_C = 3;
static final int KEY_CTRL_D = 4;
static final int KEY_CTRL_V = 22;
static final int KEY_CTRL_Z = 26;

static final int KEYCODE_SHIFT = 16;
static final int KEYCODE_CTRL = 17;
static final int KEYCODE_ALT = 18;
static final int KEYCODE_ESC = 27;

static final int KEYCODE_SPACE = 32;
static final int KEYCODE_PAGE_UP = 33;
static final int KEYCODE_PAGE_DOWN = 34;
static final int KEYCODE_END = 35;
static final int KEYCODE_HOME = 36;
static final int KEYCODE_LEFT = 37;
static final int KEYCODE_UP = 38;
static final int KEYCODE_RIGHT = 39;
static final int KEYCODE_DOWN = 40;

static final int KEYCODE_COMMA = 44;
static final int KEYCODE_MINUS = 45;
static final int KEYCODE_PERIOD = 46;
static final int KEYCODE_SLASH = 47;
static final int KEYCODE_QUESTION_MARK = 47;
static final int KEYCODE_0 = 48;
static final int KEYCODE_1 = 49;
static final int KEYCODE_2 = 50;
static final int KEYCODE_3 = 51;
static final int KEYCODE_4 = 52;
static final int KEYCODE_5 = 53;
static final int KEYCODE_6 = 54;
static final int KEYCODE_7 = 55;
static final int KEYCODE_8 = 56;
static final int KEYCODE_9 = 57;
static final int KEYCODE_SEMICOLON = 59;
static final int KEYCODE_PLUS = 61;
static final int KEYCODE_EQUAL = 61;
static final int KEYCODE_A = 65;
static final int KEYCODE_B = 66;
static final int KEYCODE_C = 67;
static final int KEYCODE_D = 68;
static final int KEYCODE_E = 69;
static final int KEYCODE_F = 70;
static final int KEYCODE_G = 71;
static final int KEYCODE_H = 72;
static final int KEYCODE_I = 73;
static final int KEYCODE_J = 74;
static final int KEYCODE_K = 75;
static final int KEYCODE_L = 76;
static final int KEYCODE_M = 77;
static final int KEYCODE_N = 78;
static final int KEYCODE_O = 79;
static final int KEYCODE_P = 80;
static final int KEYCODE_Q = 81;
static final int KEYCODE_R = 82;
static final int KEYCODE_S = 83;
static final int KEYCODE_T = 84;
static final int KEYCODE_U = 85;
static final int KEYCODE_V = 86;
static final int KEYCODE_W = 87;
static final int KEYCODE_X = 88;
static final int KEYCODE_Y = 89;
static final int KEYCODE_Z = 90;
static final int KEYCODE_LEFT_BRACKET = 91;
static final int KEYCODE_BACK_SLASH = 92;
static final int KEYCODE_RIGHT_BRACKET = 93;

static final int KEYCODE_F1 = 112;
static final int KEYCODE_F2 = 113;
static final int KEYCODE_F3 = 114;
static final int KEYCODE_F4 = 115;
static final int KEYCODE_F5 = 116;
static final int KEYCODE_F6 = 117;
static final int KEYCODE_F7 = 118;
static final int KEYCODE_F8 = 119;
static final int KEYCODE_F9 = 120;
static final int KEYCODE_F10 = 121;
static final int KEYCODE_F11 = 122;
static final int KEYCODE_F12 = 123;

static final int KEYCODE_LEFT_BRACE = 123;
static final int KEYCODE_VERTICAL = 124;
static final int KEYCODE_RIGHT_BRACE = 125;
static final int KEYCODE_TILDE = 126;

static final int KEYCODE_DEL = 127;
static final int KEYCODE_QUOTE = 222;

static final int KEYCODE_KEYBOARD = 1000;
static final int KEYCODE_ERROR = 10000;
static final int KEYCODE_GET_CUSTOM_CHAT_FILE = 20000;
static final int KEYCODE_LOAD_CHAT_LOG_FILE = 20001;
static final int KEYCODE_READ_CHAT_LOG_FILE = 20002;
static final int KEYCODE_ENTER_TEXT_PROMPT_FILE = 20003;
static final int KEYCODE_READ_TEXT_PROMPT_FILE = 20004;
static final int KEY_CONTROL = 65535;

//-------------------------------------------------------------------------------------

private boolean shiftKey = false;
private boolean controlKey = false;
private boolean altKey = false;
String errorText = null;

// save exec refactor needed
String execFn[];
String execJFn;
boolean forceExecJFn = false;

static final int FILENAME_LENGTH = 60;
// store for key presses when it is time for draw() to process input key commands
volatile int lastKey;
volatile int lastKeyCode;

void keyPressed() {
  //logger("key="+ key + " key10=" + int(key) + " keyCode="+keyCode);
  first = false;
  if (lastKeyCode == KEYCODE_ERROR) {
    return;
  } else if (buildMode == ANDROID_BUILD_MODE && key == KEYCODE_LF) {
    keyCode = KEYCODE_LF;
  } else if (buildMode == ANDROID_BUILD_MODE && keyCode == 67) {
    keyCode = KEYCODE_BACKSPACE;
  } else if (buildMode == ANDROID_BUILD_MODE && key >= ' ' && key < '~'
    || key == '\'' || key == '`') {
    keyCode = KEYCODE_KEYBOARD; // these keys for prompt text entry
  } else if (buildMode == ANDROID_BUILD_MODE && key == '~') {
    key = KEY_CTRL_V;   // paste
    keyCode = 0;
  } else if (buildMode == JAVA_BUILD_MODE && key >= ' ' && key <= '~'
    || key == '\'' || key == '`') {
    keyCode = KEYCODE_KEYBOARD; // these keys for prompt text entry
  } else if (key==ESC) {  // prevent worker sketch exit
    key = 0; // override so that key is ignored
    keyCode = KEYCODE_ESC;
  } else if (keyCode == KEYCODE_CTRL) {
    controlKey = true;
  } else if (keyCode == KEYCODE_ALT) {
    altKey = true;
  }
  lastKey = key;
  lastKeyCode = keyCode;
}

void keyReleased() {
  if (keyCode == KEYCODE_CTRL) {
    controlKey = false;
    //logger("keyReleased Ctrl");
  } else if (keyCode == KEYCODE_ALT) {
    altKey = false;
    //logger("keyReleased Alt");
  }
}

/**
 * updateKey
 * keyboard entry and display in text area
 * return true when key consumed
 */
boolean updateKey() {
  //if (DEBUG && lastKeyCode !=0 && lastKey != 0) println("lastKey="+ lastKey + " lastKeyCode="+lastKeyCode);
  boolean status = false;

  // check for control keys
  switch(lastKey) {
  case KEY_CTRL_V:
  case KEY_CTRL_C:
  case KEY_CTRL_Z:
    lastKey = 0;
    lastKeyCode = 0;
    return status;
  case KEY_CTRL_D:
    lastKey = 0;
    lastKeyCode = 0;
    // print debug information for context
    logger("debug context");
    for (int i=0; i<context.size(); i++) {
      logger("context["+i+"]="+context.get(i));
    }
    return status;
  default:
    break;
  }

  switch(lastKeyCode) {
  case KEYCODE_ERROR:
    resetChat();
    break;
  case KEYCODE_LF:
    break;
  case KEYCODE_TAB:
    showChatLogFile(chatLogFilePath + ".log");
    break;
  case KEYCODE_ENTER:
    logger("Enter");
    prompt = promptArea.getText();
    responseArea.setVisible(false);
    startChat();
    break;
  case KEYCODE_PAGE_UP:
    break;
  case KEYCODE_PAGE_DOWN:
    break;
  case KEYCODE_F1:
    mode = SINGLE_MODE; // Single prompt response, no chat, no system message
    logger("CHAT_MODE F1");
    initChat();
    context.clear();
    setTitle(TITLE + " - Single Prompt ");
    break;
  case KEYCODE_F2:
    mode = CHAT_MODE;
    logger("CHAT_MODE F2");
    generalChat();
    break;
  case KEYCODE_F3:
    mode = CHAT_MODE;
    logger("CHAT_MODE F3");
    processingChat();
    break;
  case KEYCODE_F4:
    mode = CHAT_MODE;
    logger("Custom CHAT F4");
    processCustomChat();
    //    processingAltChat();  // custom
    break;
  case KEYCODE_F5:
    mode = CHAT_MODE;
    logger("CHAT_MODE F5");
    processing3DChat();   // custom
    break;
  case KEYCODE_F6:
    mode = CHAT_MODE;
    logger("CHAT_MODE F6");
    break;
  case KEYCODE_F7:
    logger("F7");
    break;
  case KEYCODE_F9:
    selectSaveFolder();
    break;
  case KEYCODE_F8:
    forceExecJFn = true;
    // fall through intentional
  case KEYCODE_F10:  // extract and save embedded code as a processing sketch file and run in IDE
    logger("\nExtract and save embedded code as a processing sketch file and run in IDE");
    // check if response text was modified and TODO
    logger("saveSketch folder="+chatLogFilePath);
    execFn = saveSketch(chatLogFilePath);
    for (int i=0; i<execFn.length; i++) {
      logger("using file: "+execFn[i]);
    }
    if (execFn != null) {
      if (forceExecJFn) {
        forceExecJFn = false;
        execJava(execFn[0], execFn[1]);
      } else {
        if (execFn[2].equals(".java")) {
          execJava(execFn[0], execFn[1]);
        } else {
          execPSketch(execFn);
        }
      }
    }
    break;
  case KEYCODE_F11:
    logger("F8 executing file: "+execFn);
    if (execFn != null) execSketch(execFn);
    break;
  case KEYCODE_F12:
    logger("F12 screenshot command");
    screenshot = true;
    break;
  case KEYCODE_ESC:
    service.shutdownExecutor();
    exit(); // exit gracefully from the application after draw
    break;
  case KEYCODE_GET_CUSTOM_CHAT_FILE:
    selectCustomChatFile();
    break;
  case KEYCODE_LOAD_CHAT_LOG_FILE:
    selectChatLogFile();
    break;
  case KEYCODE_READ_CHAT_LOG_FILE:
    readChatLogFile(chatLogFilePath + ".log");
    initReviewText(chatLogFilePath + ".log");
    readLastSketchFile(chatLogFilePath + ".txt");
    break;
  case KEYCODE_ENTER_TEXT_PROMPT_FILE:
    selectTextPromptFile();
    break;
  case KEYCODE_READ_TEXT_PROMPT_FILE:
    logger("KEYCODE_READ_TEXT_PROMPT_FILE");
    readTextPromptFile(textPromptFilePath);
    break;
  default:
    break;
  }
  lastKey = 0;
  lastKeyCode = 0;
  return status;
}

// TODO reference code for launching a companion sketch window
//String[] args ={this.toString()};  //Need to attach current name which is stripped by the new sketch
//String[] newArgs = {name, str(handle)};
//SecondApplet sa = new SecondApplet();
//PApplet.runSketch(concat(args, newArgs), sa);
