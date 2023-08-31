// This window reviews all previous prompts and responses from OpenAI during a single chat dialog
// Displays chat script in a separate window
// The log shows the initial system prompt that drives the conversation.

import g4p_controls.*;

GWindow winAWT = null;
GTextArea reviewArea;

String chatLogFilePath;

void chatLogFileSelected(File selection) {
  if (selection == null) {
    if (DEBUG) println("Window was closed or the user hit cancel.");
  } else {
    String logFile = selection.getAbsolutePath(); //selection.getAbsoluteFile();
    if (DEBUG) println("Chat Log File selected " + logFile);
    chatLogFilePath = logFile.substring(0, logFile.lastIndexOf("."));
    lastKeyCode = KEYCODE_READ_CHAT_LOG_FILE;
    if (DEBUG) println("chatLogFilePath="+chatLogFilePath);
  }
}

/**
 * show chat log file
 * return 0 OK
 * return -1 no log file exists
 */
int showChatLogFile(String logFile) {
  if (DEBUG) println("showChatLogFile="+logFile);
  if (logFile == null || logFile.equals("null.log")) return -1;
  if (winAWT == null) {
    String title = logFile.substring(logFile.lastIndexOf(File.separator)+1);
    winAWT = GWindow.getWindow(this, "Chat Log  " + title, 50, 50, RESPONSE_WIDTH, RESPONSE_HEIGHT, JAVA2D);
    winAWT.noLoop();
    winAWT.setActionOnClose(G4P.HIDE_WINDOW);
    //winAWT.addDrawHandler(this, "win_awt_draw");  // no handler
    reviewArea = new GTextArea(winAWT, 0, 0, RESPONSE_WIDTH, RESPONSE_HEIGHT, G4P.SCROLLBARS_VERTICAL_ONLY);
    reviewArea.setFont(new Font("Arial", Font.PLAIN, fontHeight));
    reviewArea.setOpaque(true);
  } else {
    winAWT.loop();
    winAWT.setVisible(!winAWT.isVisible());
  }
  initReviewText(logFile);
  return 0;
}

void readChatLogFile(String logFile) {
  if (DEBUG) println("readChatLogFile="+logFile);
  if (logFile == null) return;
  String[] chatLog = loadStrings(logFile);
  parseChatLog(logFile, chatLog);
  showChatLogFile(logFile);
}

void readLastSketchFile(String logFile) {
  if (DEBUG) println("readLastSketchFile="+logFile);
  if (logFile == null) return;
  // update sketch counter from sketch param file
  String paramFile = logFile.substring(0, logFile.lastIndexOf(File.separator)) + File.separator + sketchParamFile;
  if (DEBUG) println("sketchParamFile path="+paramFile);
  String[] sketchText = loadStrings(paramFile);
  String counter = sketchText[0];
  sketchCounter = parseInt(counter);
  if (DEBUG) println("read sketchCounter="+sketchCounter);
}

/**
 * initialize chat log file
 */
void initReviewText(String logFile) {
  if (logFile != null && reviewArea != null) {
    if (DEBUG) println("Load strings: "+logFile);
    String[] reviewText = loadStrings(logFile);
    if (DEBUG) println("initReviewText setText array ");
    try {
      winAWT.noLoop();
      reviewArea.setText(reviewText);
      winAWT.loop();
    }
    catch (Exception ne) {
      ne.printStackTrace();
    }
    if (DEBUG) println("setVisible window");
    reviewArea.setVisible(true);
    if (DEBUG) println("initReviewText complete ");
    
  }
}
