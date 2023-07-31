// This window reviews all previous prompts and responses from OpenAI during a single chat dialog
// Displays chat script in a separate window
// The log shows the initial system prompt that drives the conversation.

import g4p_controls.*;

GWindow winAWT = null;
String logFile;
GTextArea reviewArea;

void selectChatLogFile(String logFilePath) {
  if (logFilePath == null) return;
  if (winAWT == null) {
    winAWT = GWindow.getWindow(this, "Chat Log", 50, 50, RESPONSE_WIDTH, RESPONSE_HEIGHT, JAVA2D);
    winAWT.setActionOnClose(G4P.HIDE_WINDOW);
    //winAWT.addDrawHandler(this, "win_awt_draw");  // no handler
    reviewArea = new GTextArea(winAWT, 0, 0, RESPONSE_WIDTH, RESPONSE_HEIGHT, G4P.SCROLLBARS_VERTICAL_ONLY);
    reviewArea.setFont(new Font("Arial", Font.PLAIN, fontHeight));
    reviewArea.setOpaque(true);
    logFile = logFilePath + ".log";
  } else {
    winAWT.setVisible(!winAWT.isVisible());
  }
  initReviewText();
}

/**
 * initialize chat log file
 */
void initReviewText() {
  if (logFile != null && reviewArea != null) {
    if (DEBUG) println("Load strings: "+logFile);
    String[] reviewText = loadStrings(logFile);
    reviewArea.setText(reviewText);
    reviewArea.setVisible(true);
  }
}
