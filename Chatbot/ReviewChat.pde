// This window reviews all previous prompts and responses from OpenAI during a single chat dialog
// Displays chat script in a separate window
// The log shows the initial system prompt that drives the conversation.

import g4p_controls.*;

GWindow winAWT = null;
GTextArea reviewArea;

String chatLogFilePath;

void chatLogFileSelected(File selection) {
  if (selection == null) {
    logger("Window was closed or the user hit cancel.");
  } else {
    String logFile = selection.getAbsolutePath(); //selection.getAbsoluteFile();
    logger("Chat Log File selected " + logFile);
    chatLogFilePath = logFile.substring(0, logFile.lastIndexOf("."));
    lastKeyCode = KEYCODE_READ_CHAT_LOG_FILE;
    logger("chatLogFilePath="+chatLogFilePath);
  }
}

/**
 * show chat log file
 * return 0 OK
 * return -1 no log file exists
 */
int showChatLogFile(String logFile) {
  logger("showChatLogFile="+logFile);
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
  logger("readChatLogFile="+logFile);
  if (logFile == null) return;
  String[] chatLog = loadStrings(logFile);
  parseChatLog(logFile, chatLog);
  showChatLogFile(logFile);
}

void readLastSketchFile(String logFile) {
  logger("readLastSketchFile="+logFile);
  if (logFile == null) return;
  // update sketch counter from sketch param file
  String paramFile = logFile.substring(0, logFile.lastIndexOf(File.separator)) + File.separator + sketchParamFile;
  logger("sketchParamFile path="+paramFile);
  String[] sketchText = loadStrings(paramFile);
  if (sketchText == null) {
    sketchCounter = 0;
  } else {
    String counter = sketchText[0];
    sketchCounter = parseInt(counter);
  }
  logger("read sketchCounter="+sketchCounter);
}

/**
 * initialize chat log file
 */
void initReviewText(String logFile) {
  if (logFile != null && reviewArea != null) {
    logger("Load strings: "+logFile);
    String[] reviewText = loadStrings(logFile);
    logger("initReviewText setText array ");
    try {
      winAWT.noLoop();
      reviewArea.setText(reviewText);
      winAWT.loop();
    }
    catch (Exception ne) {
      ne.printStackTrace();
    }
    logger("setVisible window");
    reviewArea.setVisible(true);
    logger("initReviewText complete ");
  }
}
