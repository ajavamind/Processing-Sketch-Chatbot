// Uncomment this file to build Windows application, and comment out Android.pde file
// Build for windows with Java mode
// Accounts for code differences between Android and Java chatbot sketch builds
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

private final static int buildMode = JAVA_BUILD_MODE; 

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
    updateSaveFolderPath();
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

void selectTextPromptFile() {
//  textPromptFilePath 
    selectInput("Select Text Pompt File", "textPromptFileSelected");
}

String textPromptFilePath;
String textPromptFileName;
void textPromptFileSelected(File selection) {
  if (selection == null) {
    logger("Window was closed or the user hit cancel.");
  } else {
    textPromptFilePath = selection.getAbsolutePath(); //selection.getAbsoluteFile();
    logger("Text Prompt File selected " + textPromptFilePath);
    textPromptFileName = textPromptFilePath.substring(0, textPromptFilePath.lastIndexOf("."));
    lastKeyCode = KEYCODE_READ_TEXT_PROMPT_FILE;
    logger("textPromptFileName="+textPromptFileName);
  }
}

void readTextPromptFile(String textPromptFile) {
  logger("readTextPromptFile="+textPromptFile);
  if (textPromptFile == null) return;
  String[] textPrompt = loadStrings(textPromptFile);
  printArray(textPrompt);
  promptArea.appendText("\n");
  for (String s: textPrompt) {
    promptArea.appendText(s);
  }
}

void customChatFileSelected(File selection) {
  if (selection == null) {
    logger("Window was closed or the user hit cancel.");
  } else {
    customChatFilePath = selection.getAbsolutePath(); //selection.getAbsoluteFile();
    int startIndex = customChatFilePath.lastIndexOf(File.separator) + 1;
    //String[] temp = splitTokens(customChatFilePath.substring(startIndex, startIndex+18), ". _-");
    String[] temp = splitTokens(customChatFilePath.substring(startIndex), ". _-");
    chatName = temp[0] + " "+ temp[1];
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

/**
 * This function renames a directory.
 *
 * @param path The path to the folder containing the directory.
 * @param oldName The current name of the directory.
 * @param newName The new name for the directory.
 * @return 0 if the operation was successful, -1 if the directory does not exist, -2 if the operation failed for another reason.
 */
public int renameDirectory(String path, String oldName, String newName) {
    // Create a Path object representing the existing directory
    Path oldDir = Paths.get(path, oldName);
    // Check if the directory exists
    if (!Files.exists(oldDir) || !Files.isDirectory(oldDir)) {
        // The directory does not exist
        return -1;
    }
    // Create a Path object representing the new directory
    Path newDir = Paths.get(path, newName);
    // Attempt to rename the directory
    try {
        Files.move(oldDir, newDir);
        // The operation was successful
        return 0;
    } catch (IOException e) {
        // The operation failed
        e.printStackTrace();
        return -2;
    }
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
