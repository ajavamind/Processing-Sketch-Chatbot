/**
 * Use OpenAI-Java API
 * https://github.com/TheoKanning/openai-java
 */

import com.theokanning.openai.completion.chat.ChatCompletionRequest;
import com.theokanning.openai.completion.chat.ChatCompletionChoice;
import com.theokanning.openai.completion.chat.ChatCompletionChoice;
import com.theokanning.openai.completion.chat.ChatCompletionResult;
import com.theokanning.openai.completion.chat.ChatMessage;
import com.theokanning.openai.service.OpenAiService;
import com.theokanning.openai.completion.CompletionRequest;

import g4p_controls.*;
import java.awt.Font;

import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Locale;

private static final boolean DEBUG = true;
private static final boolean DEBUG_TEST = false;
private static final int JAVA_MODE = 0;
private static final int ANDROID_MODE = 1;

private static final Duration CHAT_TIMEOUT = Duration.ofSeconds(120);
OpenAiService service;
//String model = "gpt-3.5-turbo"; 
//String model = "gpt-3.5-turbo-16k";  // allows larger context prompt/response
//String model = "gpt-3.5-turbo-0613"; // function calling, system message steering better
String model = "gpt-4";
//String model = "gpt-4-0613";  // function calling

double temperature = 0.0; // expect no randomness from the model
double topP = 1.0;

float appFrameRate = 30; // draw frames per second, used for animation 
String RENDERER = JAVA2D; // default for setup size()

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

boolean screenshot = false;
int screenshotCounter = 1;
static final String TITLE = "Processing Chatbot Using OpenAI API - Java";
static final String INITIAL_PROMPT = "Enter prompt here. Use ESC key to exit";
volatile boolean start = false;
volatile boolean ready = false;
int statusHeight;
//int promptHeight;
int errorMessageHeight;
int fontHeight;
int indexOffset;

GTextArea promptArea;
List<String[]> prompts;
String prompt;

GTextArea responseArea;
List<String[]> responses;
String response;

GButton generateButton;
GButton clearButton;
GButton runButton;
GButton runJButton;
GButton saveFolderButton;
GButton chatButton;
GButton chatSketchButton;

String sessionDateTime;
int fileCounter = 1;
String lastResponseFilename;

//// test lines for formatting
//String[] lines1;
//String[] lines2;

final List<ChatMessage> messages = new ArrayList<ChatMessage>();
final List<ChatMessage> context = new ArrayList<ChatMessage>();
ChatMessage systemMessage;

private static final int DEFAULT_MODE = 0; // single prompt, single response, no chat no context
private static final int CHAT_MODE = 1; // multiple prompts, chat remembers prompt/responses, saves context
int mode = DEFAULT_MODE;

private static final int SAMPLE_MODE = 2; // example OrderBot from ChatGPT pizza restaurant, DeepLearningAI prompt engineering for developers course
private static final int JAVACODE_MODE = 3; // Processing.org SDK, create Java sketch code and run
private static final int P5CODE_MODE = 4; // Processing.org SDK, create P5 Javascript sketch code and run in browser

void setup() {
  size(1920, 1080, RENDERER);
  background(128);
  cursor(TEXT);
  frameRate(appFrameRate);
  setTitle(TITLE);
  sessionDateTime = getDateTime();

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

  setOrientation();
  getFocus();

  // prompt text area can display 3 lines
  // only one line used
  //promptHeight = height-2*fontHeight-4; // top line
  //promptHeight = height-1*fontHeight-4; // middle line
  //promptHeight = height-0*fontHeight-4; // bottom line

  //promptEntry = new StringBuilder(400);
  //promptIndex = 0;

  saveFolderPath = sketchPath() + File.separator + saveFolder; // default on start
  if (DEBUG) println("saveFolderPath="+saveFolderPath);
  // create the OPENAI API service
  // OPENAI_TOKEN is your paid account token stored in the environment variables for Windows 10/11
  String token = getToken();
  service = new OpenAiService(token, CHAT_TIMEOUT);

  // set start flag to begin generation in the draw() animation loop
  start = false;
  ready = false;

  openFileSystem();

  // initial prompt text setup
  //promptPrefix = "";
  //promptSuffix = "";
  prompt = INITIAL_PROMPT;
  prompts = new ArrayList<String[]>();
  responses = new ArrayList<String[]>();
  //currentPromptIndex = -1;
  response = null;

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
  runButton = new GButton(this, RUN_BUTTON_X, RUN_BUTTON_Y, RUN_BUTTON_WIDTH, RUN_BUTTON_HEIGHT, "Run SDK\nSketch");
  runButton.tag = "Button:  Run";
  runButton.setOpaque(true);
  runButton.setFont(buttonFont);
  //runJButton = new GButton(this, RUNJ_BUTTON_X, RUNJ_BUTTON_Y, RUNJ_BUTTON_WIDTH, RUNJ_BUTTON_HEIGHT, "Run Java\nSketch");
  //runJButton.tag = "Button:  Run Java";
  //runJButton.setOpaque(true);
  //runJButton.setFont(buttonFont);
  saveFolderButton = new GButton(this, SAVE_FOLDER_BUTTON_X, SAVE_FOLDER_BUTTON_Y, SAVE_FOLDER_BUTTON_WIDTH, SAVE_FOLDER_BUTTON_HEIGHT, "Save\nFolder");
  saveFolderButton.tag = "Button:  Save Folder";
  saveFolderButton.setOpaque(true);
  saveFolderButton.setFont(buttonFont);
  chatButton = new GButton(this, CHAT_BUTTON_X, CHAT_BUTTON_Y, CHAT_BUTTON_WIDTH, CHAT_BUTTON_HEIGHT, "General\nChat");
  chatButton.tag = "Button:  Chat";
  chatButton.setOpaque(true);
  chatButton.setFont(buttonFont);
  chatSketchButton = new GButton(this, CHAT_SKETCH_BUTTON_X, CHAT_SKETCH_BUTTON_Y, CHAT_SKETCH_BUTTON_WIDTH, CHAT_SKETCH_BUTTON_HEIGHT, "Sketch\nChat");
  chatSketchButton.tag = "Button:  Sketch Chat";
  chatSketchButton.setOpaque(true);
  chatSketchButton.setFont(buttonFont);
  
  //if (DEBUG_TEST) {
  //  lines1 = loadStrings("input1.txt");
  //  lines2 = loadStrings("input2.txt");
  //}
}

public String getCompletion(String promptStr) {
  if (DEBUG) {
    println("getCompletion");
    println("Prompt: "+promptStr);
    println();
  }
  final List<ChatMessage> messages = new ArrayList<>();
  final ChatMessage chatMessage = new ChatMessage(ChatMessageRole.USER.value(), promptStr);
  messages.add(chatMessage);
  ChatCompletionRequest request = ChatCompletionRequest.builder()
    .model(model)
    .messages(messages)
    .temperature(temperature)
    .build();

  ChatCompletionResult completion = service.createChatCompletion(request);
  ChatCompletionChoice choice = completion.getChoices().get(0);
  String content = choice.getMessage().getContent();
  if (DEBUG) {
    println("Response: "+content);
    println();
  }
  return content;
}

public String getCompletionFromMessages(List<ChatMessage> messages) {
  if (DEBUG) {
    println("getCompletionFromMessages");
    println("Messages: "+messages);
    println();
  }

  ChatCompletionRequest request = ChatCompletionRequest.builder()
    .model(model)
    .messages(messages)
    .temperature(temperature)
    .build();

  ChatCompletionResult completion = service.createChatCompletion(request);
  ChatCompletionChoice choice = completion.getChoices().get(0);
  String content = choice.getMessage().getContent();
  String finishReason = choice.getFinishReason();
  if (DEBUG) {
    println("Response: "+content);
    println("finish_reason: "+finishReason);
    println();
  }
  return content;
}

void addUserMessage(String promptStr) {
  ChatMessage pMessage = new ChatMessage(ChatMessageRole.USER.value(), promptStr);
  context.add(pMessage);
}

void addAssistantMessage(String response) {
  ChatMessage rMessage = new ChatMessage(ChatMessageRole.ASSISTANT.value(), response);
  context.add(rMessage);
}

// Processing thread call, no parameters, works during draw()
void sendOpenAiRequest() {
  if (DEBUG) println("sendOpenAiRequest");
  try {
    response = getCompletion(prompt);
    ready = true;
  }
  catch(Exception rex) {
    errorText = "Service problem "+ rex;
    println("Service problem "+ rex);
    lastKeyCode = KEYCODE_ERROR;
  }
  animation = NO_ANIMATION;
}

// Processing thread call, no parameters, works during draw()
void sendOpenAiChatRequest() {
  if (DEBUG) println("sendOpenAiChatRequest");
  try {
    response = getCompletionFromMessages(context);
    ready = true;
  }
  catch(Exception rex) {
    errorText = "Service problem "+ rex;
    println("Service problem "+ rex);
    lastKeyCode = KEYCODE_ERROR;
  }
  animation = NO_ANIMATION;
}

// Processing main GUI loop and OpenAI API request starter
void draw() {
  background(224); // off white background
  fill(0); // black text

  checkKeyboard();
  // check for key or mouse input and process on this draw thread
  boolean update = updateKey();
  if (update) {
    if (DEBUG) println("updateKey = true");
  }

  // check is prompt length is minimum size and start request set
  //if (start && prompt.length() > 3) {
  if (start) {
    start = false;
    responseArea.setVisible(false);

    ready = false;
    // check chat mode for type of request wanted
    switch(mode) {
    case DEFAULT_MODE:
      thread("sendOpenAiRequest");
      break;
    case CHAT_MODE:
      addUserMessage(prompt);
      thread("sendOpenAiChatRequest");
      break;
    default:
      break;
    }
    animation = SHOW_SECONDS; // allow animatins while waiting for OpenAI response to request
  }

  // check if request response was received and ready
  if (ready) {
    start = false;
    ready = false;
    String[] promptLines;
    promptLines = parseString(prompt);
    prompts.add(promptLines);
    responseArea.setText(response);
    responseArea.setVisible(true);

    String[] responseLines = parseString(response);
    responses.add(responseLines);

    int n = prompt.length();
    if (n > 16 ) n = 16;
    String prefix = prompt.substring(0, n);
    prefix.replaceAll(" ", "_");
    //String fn = "ChatGPT_" + sessionDateTime + "_" + "PromptResponse_"+number(fileCounter++);
    String fn = prefix+ "_" + sessionDateTime + "_" + number(fileCounter++);
    lastResponseFilename = saveText(promptLines, responseLines, fn);
    if (DEBUG) println("save prompt and responses in a file "+ lastResponseFilename);

    switch(mode) {
    case DEFAULT_MODE:
      break;
    case CHAT_MODE:
      addAssistantMessage(response);  // add to context
      break;
    default:
      break;
    }
    response = null;
  }

  doAnimation(animation);

  // show any errors from the request
  showError(errorText);

  // Drawing finished, check for screenshot command request
  saveScreenshot();
} // draw

public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) {
  /* code */
  //println(event.toString());
  if (event.toString().equals("LOST_FOCUS")) {
  }
}

public void handleButtonEvents(GButton button, GEvent event) { 
  // Folder selection
  if (button == generateButton) {
    println("Button Generate pressed");
    lastKey = 0;
    lastKeyCode = KEYCODE_ENTER;
  } else if (button == runButton) {
      println("Button Run pressed");
    lastKey = 0;
    lastKeyCode = KEYCODE_F10;
  //} else if (button == runJButton) {
  //    println("Button Run pressed");
  //  lastKey = 0;
  //  lastKeyCode = KEYCODE_F11;
  } else if (button == chatButton) {
      println("Button Chat pressed");
    lastKey = 0;
    lastKeyCode = KEYCODE_F2;
  } else if (button == chatSketchButton) {
      println("Button Chat Sketch pressed");
    lastKey = 0;
    lastKeyCode = KEYCODE_F4;
  } else if (button == clearButton) {
      println("Button Clear pressed");
      promptArea.setText("");  
  }  else if (button == saveFolderButton) {
      println("saveFolder selection pressed");
      lastKey = 0;
      lastKeyCode = KEYCODE_F9;
  }  
  
  //else if (button == btnMdialog)
  //  handleMessageDialog();
  //// Option dialog
  //else if (button == btnOdialog)
  //  handleOptionDialog();
  //// Color chooser
  //else if (button == btnColor)
  //  handleColorChooser();
}

// animation section
static final int ANIMATION_STEPS = 4;
int[] animationCounter = new int[3];
String[] animationSequence = {"|", "/", "-", "\\"};
int animationHeight = 96;
static final int NO_ANIMATION = 0;
static final int SHOW_SECONDS = 1;
static final int SHOW_SPINNER = 2;
int animation = NO_ANIMATION;  // flag to control animation while waiting for openai-api to respond

/**
 * Perform animation while waiting for OpenAI
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
