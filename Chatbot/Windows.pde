// Uncomment this file to build Windows application, comment out Android.pde file
// Build for windows with Java mode
// Accounts for code differences between Android and Java chatbot sketch builds
private final static int buildMode = JAVA_BUILD_MODE; 


String saveFolder = "output"; // default output folder location relative to sketch path
String saveFolderPath; // full path to save folder

// request focus on main window

void setOrientation() {
  orientation(PORTRAIT);
}


/** getFocus is called so user does not have to press mouse button or keyboard key
 over the window to get focus.
 This fixes a quirk/bug/problem with processing sketches in Java on Windows
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
    println("Renderer: "+ RENDERER + " Window focus exception: " + ren.toString());
  }
}

String getToken() {
  return System.getenv("OPENAI_TOKEN");
}

void openFileSystem() {
}

void checkKeyboard() {
  // do nothing
}

void setTitle(String str) {
  surface.setTitle(str);
}

void selectOutputFolder() {
  selectFolder("Select Output Folder", "selectOutputFolder");
}

void selectSaveFolder() {
//  if (saveFolderPath == null) {
    selectFolder("Select Save Folder", "folderSelected");
//  } else {
//    if (DEBUG) println("saveFolderPath="+saveFolderPath);
//  }
}

// callback from selectSaveFolder()
void folderSelected(File selection) {
  if (selection == null) {
    if (DEBUG) println("Window closed or canceled for Save Folder.");
  } else {
    if (DEBUG) println("User selected saveFolderPath=" + selection.getAbsolutePath());
    saveFolderPath = selection.getAbsolutePath();
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
    if (DEBUG) println("Window closed or canceled.");
  } else {
    if (DEBUG) println("User selected Output Folder: " + selection.getAbsolutePath());
    saveFolderPath = selection.getAbsolutePath();
  }
}

void saveScreenshot() {
  if (screenshot) {
    screenshot = false;
    saveScreen(saveFolderPath, "screenshot_"+ getDateTime() + "_", number(screenshotCounter), "png");
    if (DEBUG) println("save "+ "screenshot_" + number(screenshotCounter));
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
//    //println("paste clipboard "+ text);
//    addString(text);
//  }
//}
