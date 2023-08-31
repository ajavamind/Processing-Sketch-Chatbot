/**
 * Processing Sketch Chatbot
 * Calls OpenAI-Java API with prompt
 */

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

private static final boolean DEBUG = true;
private static final boolean DEBUG_TEST = false;
private static final int JAVA_BUILD_MODE = 0;
private static final int ANDROID_BUILD_MODE = 1;

float appFrameRate = 30; // draw loop rate frames per second, used for animation
String RENDERER = JAVA2D; // default for setup size()

boolean screenshot = false;
int screenshotCounter = 1;
volatile boolean start = false;
volatile boolean ready = false;

int errorMessageHeight;
int fontHeight;
int indexOffset;

List<String[]> prompts;
String prompt;

List<String[]> responses;
String response;

String chatbotPrefix = "SketchChat";
String chatSketchPrefix = "Sketch";
String sketchParamFile = "Sketch_Param.txt";
String sessionDateTime;
int sketchCounter = 1; // initialize next sketch folder name counter
String sketchNamePrefix = "sketch";

//// debug test lines for formatting
//String[] lines1;
//String[] lines2;

private static final int SINGLE_MODE = 0; // single prompt, single response, no chat no system message context
private static final int CHAT_MODE = 1; // multiple prompts, chat remembers prompt/responses, saves context
int mode = CHAT_MODE;

// Processing IDE modes
private static final int JAVA_CODE_MODE = 3; // Processing.org IDE, create Java sketch code and run
private static final int P5_CODE_MODE = 4; // Processing.org IDE, create P5 Javascript sketch code and run in browser
private static final int PYTHON_CODE_MODE = 4; // Processing.org IDE, create P5 Javascript sketch code and run in browser
private static final int ANDROID_CODE_MODE = 5; // Processing.org IDE, create PDE Java sketch code and load into Android device to run

void setup() {
  size(1920, 1080, RENDERER);
  background(128);
  cursor(TEXT);
  frameRate(appFrameRate);
  setTitle(TITLE);
  sessionDateTime = getDateTime();
  initGUI();

  setOrientation();
  getFocus();

  saveFolderPath = sketchPath() + File.separator + saveFolder; // default on start
  if (DEBUG) println("saveFolderPath="+saveFolderPath);

  initAI();

  // set start flag false to wait for generation in the draw() animation loop
  start = false;
  ready = false;

  openFileSystem();

  // initial prompt text setup
  prompt = INITIAL_PROMPT;
  prompts = new ArrayList<String[]>();
  responses = new ArrayList<String[]>();
  response = null;

  //if (DEBUG_TEST) {
  //lines1 = loadStrings("debug" + File.separator + "input1.txt");
  //printArray(lines1);
  //lines2 = loadStrings("debug" + File.separator + "input2.txt");
  //printArray(lines2);
  //}

  // set initial action using keyCode with updateKey() in draw()
  lastKeyCode = 0;  // none
  lastKey = 0;
}

// Processing main GUI loop and OpenAI API request start
void draw() {
  background(224); // off white background
  fill(0); // black text

  checkKeyboard();  // should we display soft on screen keyboard?

  // check for key or mouse input and process on this draw thread
  boolean update = updateKey();
  if (update) {
    // place holder for possible changes to draw
    if (DEBUG) println("updateKey = true");
  }

  // check is prompt length is minimum size and start request set
  //if (start && prompt.length() > 3) {
  if (start) {
    start = false;
    responseArea.setVisible(false);

    ready = false;
    // check chat mode for type of request wanted
    if (DEBUG) println("Chat mode="+mode);
    switch(mode) {
    case SINGLE_MODE:
      systemPrompt = null;
      thread("sendOpenAiRequest");
      break;
    case CHAT_MODE:
      addUserMessage(prompt);
      thread("sendOpenAiChatRequest");
      break;
    default:
      break;
    }
    animation = SHOW_SECONDS; // allow animation while waiting for OpenAI response to request
  }

  // check if request response was received and ready
  if (ready) {
    resetChat();
    String[] promptLines = parseString(prompt);
    prompts.add(promptLines);
    responseArea.setText(response);
    responseArea.setVisible(true);

    String[] responseLines = parseString(response);
    responses.add(responseLines);

    // make folder with chatcounter
    //String folder = chatbotPrefix + "_" + sessionDateTime + "_" + number(chatCounter);
    String folder = chatbotPrefix + "_" + sessionDateTime;
    File theDir = new File(saveFolderPath + File.separator + folder);
    if (!theDir.exists()) {
      theDir.mkdirs();
      if (DEBUG) println("make folder " + saveFolderPath + File.separator +folder);
    }
    //String fileName = chatSketchPrefix + "_" + sessionDateTime + "_" + number(chatCounter);
    String fileName = chatSketchPrefix + "_" + sessionDateTime;
    chatLogFilePath = saveFolderPath + File.separator + folder + File.separator + fileName ;
    newLogFile("<system>", systemPrompt, chatLogFilePath);
    saveLogText(promptLines, responseLines, chatLogFilePath);
    if (DEBUG) println("save prompt and responses in a log file in folder: "+ chatLogFilePath + ".log");
    
    if (DEBUG) println("response Chat mode="+mode);
    switch(mode) {
    case SINGLE_MODE:
      break;
    case CHAT_MODE:
      addAssistantMessage(response);  // add to context
      break;
    default:
      break;
    }
    response = null;
  }

  // Update animation if active
  doAnimation(animation);

  // show any errors from the request
  showError(errorText);

  // Drawing finished, check for screenshot request
  saveScreenshot();  // IMPORTANT does not show G4P GUI yet
  
} // draw
