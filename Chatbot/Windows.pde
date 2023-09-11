// Uncomment this file to build Windows application, and comment out Android.pde file
// Build for windows with Java mode
// Accounts for code differences between Android and Java chatbot sketch builds

private final static int buildMode = JAVA_BUILD_MODE; 

String saveFolder = "output"; // default output folder location relative to sketch path
String saveFolderPath; // full path to save folder

void setOrientation() {
  orientation(PORTRAIT);
}

/**
 * request focus on main window
 * getFocus is called so user does not have to press mouse button or keyboard key
 * over the window to get focus.
 * This fixes a quirk/bug/problem with processing sketches in Java on Windows
 */
void getFocus() {
  try {
    if (RENDERER.equals(P2D)) {
      ((com.jogamp.newt.opengl.GLWindow) surface.getNative()).requestFocus();  // for P2D
    } else if (RENDERER.equals(P3D)) {
      ((com.jogamp.newt.opengl.GLWindow) surface.getNative()).requestFocus();  // for P2D
    } else {
      ((java.awt.Canvas) surface.getNative()).requestFocus();  // for JAVA2D (default)
    }
  }
  catch (Exception ren) {
    logger("Renderer: "+ RENDERER + " Window focus exception: " + ren.toString());
  }
}

/**
 * get OPEN AI token from Windows environment variable
 */
String getToken() {
  return System.getenv("OPENAI_API_KEY");
}

void openFileSystem() {
}

// on screen keyboard
void checkKeyboard() {
  // do nothing for Windows
}

void setTitle(String str) {
  surface.setTitle(str);
}

void selectSaveFolder() {
    selectFolder("Select Save Folder", "folderSelected");
}

// callback from selectSaveFolder()
void folderSelected(File selection) {
  if (selection == null) {
    logger("Window closed or canceled for Save Folder.");
  } else {
    logger("User selected saveFolderPath=" + selection.getAbsolutePath());
    saveFolderPath = selection.getAbsolutePath();
  }
}

void selectCustomChatFile() {
//  customChatFilePath 
    selectInput("Select Custom Chat File", "customChatFileSelected");
}

void selectChatLogFile() {
//  chatLogFilePath 
    selectInput("Select Chat Log File", "chatLogFileSelected");
}

void customChatFileSelected(File selection) {
  if (selection == null) {
    logger("Window was closed or the user hit cancel.");
  } else {
    customChatFilePath = selection.getAbsolutePath(); //selection.getAbsoluteFile();
    int startIndex = customChatFilePath.lastIndexOf(File.separator) + 1;
    chatName = customChatFilePath.substring(startIndex, startIndex+16);
    setChatButtonText(chatName);
    logger("Custom Chat="+chatName);
    logger("User selected " + customChatFilePath);
  }
}

void saveConfig(String config) {
}

String loadConfig()
{
  return null;
}

void openKeyboard() {  // on screen keyboard
}

void closeKeyboard() {  // on screen keyboard
}

void selectOutputFolder(File selection) {
  if (selection == null) {
    logger("Window closed or canceled.");
  } else {
    logger("User selected Output Folder: " + selection.getAbsolutePath());
    saveFolderPath = selection.getAbsolutePath();
  }
}

void saveScreenshot() {
  if (screenshot) {
    screenshot = false;
    saveScreen(saveFolderPath, "screenshot_"+ getDateTime() + "_", number(screenshotCounter), "png");
    logger("save "+ "screenshot_" + number(screenshotCounter));
    screenshotCounter++;
  }
}

// Save image of the composite screen
void saveScreen(String outputFolderPath, String outputFilename, String suffix, String filetype) {
  save(outputFolderPath + File.separator + outputFilename + suffix + "." + filetype);
  saveFrame();
  saveFrame(outputFolderPath + File.separator + outputFilename + suffix + "." + filetype);
}

// calls exiftool exe in the path
// sets portrait orientation by rotate camera left
void setEXIF(String filename) {
  try {
    Process process = Runtime.getRuntime().exec("exiftool -n -orientation=6 "+filename);
    process.waitFor();
  }
  catch (Exception ex) {
  }
}

// debug logger
public void logger(String str) {
  //logger(str);
  if (DEBUG) System.out.println(str);
}

//-------------------------------------------------------------------------------------

//import java.awt.Toolkit;
//import java.awt.datatransfer.Clipboard;
//import java.awt.datatransfer.DataFlavor;
//import java.awt.datatransfer.StringSelection;
//import java.awt.datatransfer.Transferable;
//import java.awt.datatransfer.UnsupportedFlavorException;

//// copy text to the clipboard in Java:
//void copyText() {
//  StringSelection stringSelection = new StringSelection(prompt);
//  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
//  clipboard.setContents(stringSelection, null);
//}

//// paste text from the clipboard
//void pasteClipboard() {
//  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
//  Transferable contents = clipboard.getContents(null);
//  if (contents != null && contents.isDataFlavorSupported(DataFlavor.stringFlavor)) {
//    String text="";
//    try {
//      text = (String) contents.getTransferData(DataFlavor.stringFlavor);
//      text = text.replaceAll("\n", "   ");
//    }
//    catch (Exception ufe) {
//      text = "";
//    }
//    //logger("paste clipboard "+ text);
//    addString(text);
//  }
//}
