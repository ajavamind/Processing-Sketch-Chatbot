//// Uncomment this file to build Android application and comment Windows.pde file
//// Android platform build
//// Accounts for code differences between Android and Java sketch builds
//// IMPORTANT: This code will not work until GTextArea.java and G4p library is modified for Android

//private final static int buildMode = ANDROID_BUILD_MODE;  // change manually for the build

//// Android Platform Build Mode
//import android.content.SharedPreferences;
//import android.preference.PreferenceManager;
//import android.content.Context;
//import android.view.inputmethod.InputMethodManager;
//import android.content.ClipData;
//import android.content.ClipboardManager;
//import android.os.Bundle;
//import android.content.Context;
//import android.os.Looper;
//import android.os.PersistableBundle;
//import android.content.ClipDescription;

//import android.graphics.Bitmap;
//import android.app.Activity;
//import select.files.*;

//boolean grantedRead = false;
//boolean grantedWrite = false;

//SelectLibrary files;
//String saveFolder = "Documents"; // default output folder location relative to sketch path
//String saveFolderPath; // full path to save folder
//ClipboardManager clipboard;
//ClipData clipData;

//String getToken() {
//  return "";
//}

//void setOrientation() {
//  orientation(PORTRAIT);
//}

//void checkKeyboard() {
//  // get a reference to the InputMethodManager
//  InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);

//  // check if the keyboard is currently shown
//  if (imm.isAcceptingText()) {
//    // the keyboard is currently shown
//  } else {
//    // the keyboard is currently hidden
//    keyboard = false;
//  }
//}
//void openFileSystem() {
//  requestPermissions();
//  files = new SelectLibrary(this);
//}

//void setTitle(String str) {
//}

//String sketchPath() {
//  return "";
//}

//void getFocus() {
//}

//void saveScreenshot() {
//}

//// paste text from the clipboard
//void pasteClipboard() {
//  Context mContext = getActivity();
//  clipboard = (ClipboardManager) mContext.getSystemService(Context.CLIPBOARD_SERVICE);
//  ClipData clip = clipboard.getPrimaryClip();
//  if (clip != null && clip.getItemCount() > 0) {
//    ClipData.Item item = clip.getItemAt(0);
//    String text = item.getText().toString();
//    text = text.replaceAll("\n", " ");
//    if (DEBUG) println("paste clipboard "+ text);
//    addString(text);
//  }
//}
  
//  void copyText() {
//  }

//  public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
//    if (DEBUG) println("onRequestPermissionsResult "+ requestCode + " " + grantResults + " ");
//    for (int i=0; i<permissions.length; i++) {
//      if (DEBUG) println(permissions[i]);
//    }
//  }

//  void requestPermissions() {
//    if (!hasPermission("android.permission.READ_EXTERNAL_STORAGE")) {
//      requestPermission("android.permission.READ_EXTERNAL_STORAGE", "handleRead");
//    }
//    if (!hasPermission("android.permission.WRITE_EXTERNAL_STORAGE")) {
//      requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "handleWrite");
//    }
//  }

//  void handleRead(boolean granted) {
//    if (granted) {
//      grantedRead = granted;
//      if (DEBUG) println("Granted read permissions.");
//    } else {
//      if (DEBUG) println("Does not have permission to read external storage.");
//    }
//  }

//  void handleWrite(boolean granted) {
//    if (granted) {
//      grantedWrite = granted;
//      if (DEBUG) println("Granted write permissions.");
//    } else {
//      if (DEBUG) println("Does not have permission to write external storage.");
//    }
//  }

//  void selectConfigurationFile() {
//    //if (!grantedRead || !grantedWrite) {
//    //  requestPermissions();
//    //}
//    files.selectInput("Select Configuration File:", "fileSelected");
//  }

//  void selectSaveFolder() {
//    if (saveFolderPath == null) {
//      files.selectFolder("Select Save Folder", "folderSelected");
//    } else {
//      if (DEBUG) println("saveFolderPath="+saveFolderPath);
//    }
//  }

//  void folderSelected(File selection) {
//    if (selection == null) {
//      if (DEBUG) println("Window closed or canceled.");
//    } else {
//      if (DEBUG) println("User selected " + selection.getAbsolutePath());
//      saveFolderPath = selection.getAbsolutePath();
//    }
//  }

//  //void saveConfig(String config) {
//  //  if (DEBUG) println("saveConfig "+config);
//  //  SharedPreferences sharedPreferences;
//  //  SharedPreferences.Editor editor;
//  //  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  //  editor = sharedPreferences.edit();
//  //  editor.putString(configKey, config );
//  //  editor.commit();
//  //}

//  //String loadConfig() {
//  //  SharedPreferences sharedPreferences;
//  //  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  //  String result = sharedPreferences.getString(configKey, null);
//  //  if (DEBUG) println("loadConfig "+result);
//  //  return result;
//  //}

//  //void savePhotoNumber(int number) {
//  //  if (DEBUG) println("savePhotoNumber "+number);
//  //  SharedPreferences sharedPreferences;
//  //  SharedPreferences.Editor editor;
//  //  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  //  editor = sharedPreferences.edit();
//  //  editor.putInt(photoNumberKey, number );
//  //  editor.commit();
//  //}

//  //int loadPhotoNumber() {
//  //  SharedPreferences sharedPreferences;
//  //  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  //  int result = sharedPreferences.getInt(photoNumberKey, 0);
//  //  if (DEBUG) println("loadPhotoNumber "+result);
//  //  return result;
//  //}

//  //private void destroy(PImage img) {
//  //  if (img == null) return;
//  //  Bitmap bitmap = (Bitmap) img.getNative();
//  //  if (bitmap != null)
//  //    bitmap.recycle();
//  //  img.setNative(null);
//  //  System.gc();
//  //}
