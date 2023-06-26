// Text Entry and control key input handling
// Key codes serve dual purpose for commands and text entry

static final int KEYCODE_NOP = 0;
static final int KEYCODE_BACK = 4;
static final int KEYCODE_BACKSPACE = 8;
static final int KEYCODE_TAB = 9;
static final int KEYCODE_ENTER = 66; // Android
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
static final int KEY_CONTROL = 65535;

//-------------------------------------------------------------------------------------

private boolean shiftKey = false;
private boolean controlKey = false;
private boolean altKey = false;
//StringBuilder promptEntry;
//int promptIndex;
//String[] promptList = new String[3];
//promptList[0] = prompt;
//promptList[1] = filename;
//promptList[2] = filenamePath + ".png";
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
  //if (DEBUG) println("key="+ key + " key10=" + int(key) + " keyCode="+keyCode);
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
    //println("keyReleased Ctrl");
  } else if (keyCode == KEYCODE_ALT) {
    altKey = false;
    //println("keyReleased Alt");
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
    println("debug context");
    for (int i=0; i<context.size(); i++) {
      println("context["+i+"]="+context.get(i));
    }
    return status;
  default:
    break;
  }

  switch(lastKeyCode) {
  case KEYCODE_ERROR:
    ready = false;
    start = false;
    break;
  case KEYCODE_LF:
    break;
  case KEYCODE_ENTER:
    if (DEBUG) println("Enter");
    prompt = promptArea.getText();
    responseArea.setVisible(false);
    if (!start) {
      errorText = null;
      ready = false;
      start = true;
    }
    break;
    //case KEYCODE_PAGE_UP:
    //  if (currentPromptIndex >= 0) {
    //    if (currentPromptIndex < prompts.size()-1) {
    //      currentPromptIndex++;
    //    }
    //  }
    //  break;
    //case KEYCODE_PAGE_DOWN:
    //  if (currentPromptIndex > 0) {
    //    currentPromptIndex--;
    //  }
    //  break;
  case KEYCODE_F1:
    mode = DEFAULT_MODE;
    println("DEFAULT_MODE");
    break;
  case KEYCODE_F2:
    mode = CHAT_MODE;
    println("CHAT_MODE");
    context.clear();
    prompt = "";
    String gmsg = combineStrings(loadStrings("preprompt" + File.separator + "generalPrompt.txt"));
    ChatMessage chatMsg = new ChatMessage(ChatMessageRole.SYSTEM.value(), gmsg);
    context.add(chatMsg);
    ChatMessage userMsg = new ChatMessage(ChatMessageRole.USER.value(), prompt);
    context.add(userMsg);
    if (!start) {
      errorText = null;
      ready = false;
      start = true;
    }
    break;
  case KEYCODE_F3:
    mode = CHAT_MODE;
    println("CHAT_MODE");
    context.clear();
    prompt = "";
    String msg = combineStrings(loadStrings("preprompt" + File.separator + "systemPrompt.txt"));
    ChatMessage chat0Msg = new ChatMessage(ChatMessageRole.SYSTEM.value(), msg);
    context.add(chat0Msg);
    ChatMessage user0Msg = new ChatMessage(ChatMessageRole.USER.value(), prompt);
    context.add(user0Msg);
    if (!start) {
      errorText = null;
      ready = false;
      start = true;
    }
    break;
 case KEYCODE_F4:
    mode = CHAT_MODE;
    println("CHAT_MODE Programming.org sketch coder, java programming language assistant");
    context.clear();
    String smsg = combineStrings(loadStrings("preprompt" + File.separator + "processingPrompt.txt"));
    ChatMessage systemMessage = new ChatMessage(ChatMessageRole.SYSTEM.value(), smsg);
    context.add(systemMessage);
    prompt = "";
    ChatMessage user1Msg = new ChatMessage(ChatMessageRole.USER.value(), prompt);
    context.add(user1Msg);
    if (!first) {
      if (!start) {
        errorText = null;
        ready = false;
        start = true;
      }
    } else {
      first = false;
    }
    break;
  case KEYCODE_F5:
    mode = CHAT_MODE;
    println("CHAT_MODE Programming.org stereoscopic 3D vision sketch coder, java programming language assistant");
    context.clear();
    ChatMessage system2Message = new ChatMessage(ChatMessageRole.SYSTEM.value(), """You are a processing.org java programming language assistant.
    Your respond with name 'Sketch 3D'.
      When asked to code, generate a processing java sketch with setup using a gray background with black fill.
      You use a screen size of 1920 by 1080. Clear the background in draw().
      You use a camera view to determine the position of the output centered in each half of the screen.
      You generate output for the left half of the screen and the same output on right half of the screen offset by the camera.
      """
    );
    context.add(system2Message);
    prompt = "";
    ChatMessage user2Msg = new ChatMessage(ChatMessageRole.USER.value(), prompt);
    context.add(user2Msg);
    if (!start) {
      errorText = null;
      ready = false;
      start = true;
    }
    break;
  case KEYCODE_F6:
    break;
  case KEYCODE_F7:
    break;
  case KEYCODE_F11:
    println("F8 executing file: "+execFn);
    if (execFn != null) execSketch(execFn);
    break;
  case KEYCODE_F9:
    selectSaveFolder();
    break;
  case KEYCODE_F8:
    forceExecJFn = true;
    // fall through
  case KEYCODE_F10:  // extract and save embedded code as a processing sketch file and run in IDE
    println("extract and save embedded code as a processing sketch file and run in IDE");
    // check if response text was modified and TODO

    execFn = saveSketch(lastResponseFilename);
    for (int i=0; i<execFn.length; i++) {
      println("using file: "+execFn[i]);
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
  case KEYCODE_F12:
    if (DEBUG) println("F12 screenshot command");
    screenshot = true;
    break;
  case KEYCODE_ESC:
    service.shutdownExecutor();
    exit(); // exit gracefully
    break;
  default:
    break;
  }
  lastKey = 0;
  lastKeyCode = 0;
  return status;
}

// TODO reference code in case app wants to launch a companion sketch window
//String[] args ={this.toString()};  //Need to attach current name which is stripped by the new sketch
//String[] newArgs = {name, str(handle)};
//SecondApplet sa = new SecondApplet();
//PApplet.runSketch(concat(args, newArgs), sa);
