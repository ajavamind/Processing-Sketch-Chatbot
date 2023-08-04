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
    chatLogFilePath = logFile.substring(0,logFile.lastIndexOf("."));
    readChatLogFile(chatLogFilePath + ".log");
    if (DEBUG) println("chatLogFilePath="+chatLogFilePath);
  }
}

void showChatLogFile(String logFile) {
  if (DEBUG) println("showChatLogFile="+logFile);
  if (logFile == null || logFile.equals("null.log")) return;
  if (winAWT == null) {
    winAWT = GWindow.getWindow(this, "Chat Log", 50, 50, RESPONSE_WIDTH, RESPONSE_HEIGHT, JAVA2D);
    winAWT.setActionOnClose(G4P.HIDE_WINDOW);
    //winAWT.addDrawHandler(this, "win_awt_draw");  // no handler
    reviewArea = new GTextArea(winAWT, 0, 0, RESPONSE_WIDTH, RESPONSE_HEIGHT, G4P.SCROLLBARS_VERTICAL_ONLY);
    reviewArea.setFont(new Font("Arial", Font.PLAIN, fontHeight));
    reviewArea.setOpaque(true);
  } else {
    winAWT.setVisible(!winAWT.isVisible());
  }
  initReviewText(logFile);
}

void readChatLogFile(String logFile) {
  if (DEBUG) println("readChatLogFile="+logFile);
  if (logFile == null) return;
  String[] chatLog = loadStrings(logFile);
  parseChatLog(chatLog);
  showChatLogFile(logFile);
}

/**
 * initialize chat log file
 */
void initReviewText(String logFile) {
  if (logFile != null && reviewArea != null) {
    if (DEBUG) println("Load strings: "+logFile);
    String[] reviewText = loadStrings(logFile);
    reviewArea.setText(reviewText);
    reviewArea.setVisible(true);
  }
}
