// A processing java sketch that does the following sequential tasks:
// select a user folder in setup
// find all text files of file type ".log" in this folder and all subfolders
// for each text file found, create an string array of all lines in the file using loadStrings
// call the function "summarizeLog" with parameter string array to process the data.
// summarizeLog returns a string[] text summary array
// summarizeLog works on its own thread so that draw can display while it works, so draw() check for summarizeLog completes.
// using the uri of the text file, file:// and the text summary array build a html file showing the summary text with its file uri link where located in the file system.
// close the generated html file when finished.
// The above procedure takes place during draw() and displays a countdown of the number of text files to process along with the filename being processed.

import java.io.*;
import java.io.File;
import java.io.FilenameFilter;
import java.nio.file.*;
import java.util.List;
import java.util.ArrayList;

private static final boolean DEBUG = true;
ArrayList<String> list;
File folder;
String folderPath;
File[] listOfFiles;
int fileCount = 0;
int currentFile = 0;
boolean input = false;
boolean working = false;
boolean done = false;
ArrayList<String> logFiles = new ArrayList<>();
ArrayList<String> logFilePaths = new ArrayList<>();
Output output;
//HtmlFileCreator htmlCreate;
OpenAI chatbot;

// file types to scan
//String[] scanFileType = { ".log" };  // default scan log files only
String[] scanFileType = { ".java", ".pde", ".js", ".py", ".pyde" };  // scan both java, javascript, python and pde files
private static final int TEXT = 0;
private static final int HTML = 1;
int outputType = HTML;
//int outputType = TEXT;

void setup() {
  size(1080, 1080);
  textSize(18);
  list = new ArrayList<String>();
  switch (outputType) {
  case HTML:
    output = new HtmlFileCreator();
    break;
  case TEXT:
    output = new TextFileCreator();
    break;
  default:
    println("Exit error internal output file generation");
    exit();
    break;
  }
  chatbot = new OpenAI();

  // Select a folder using a folder selector dialog
  selectFolder("Select starting folders:", "folderSelected");
}

void draw() {
  background(255);
  fill(0);

  if (input && logFiles.size() > 0) {
    text("Processing file " + (currentFile) + " of " + fileCount, 10, 100);
    text("File name: " + logFiles.get(currentFile), 10, 120);
  }
  text("Summarize Files", 20, 20);
  if (folderPath != null) {
    text(folderPath, 20, 40);
  }
  if (processNextFile(outputType)) {
    text("Summarize log file completed " + (currentFile) + " of " + fileCount, 10, 140);
  }
}

void folderSelected(File selection) {
  if (selection == null) {
    println("No folder was selected.");
    // for debug
    folderPath = "F:\\data\\projects\\processing4\\Repositories\\Processing-Sketch-Chatbot\\Chatbot\\output";
    selection = new File(folderPath);
    folder = selection;
  } else {
    folder = selection;
    folderPath = selection.getAbsolutePath();
  }

  if (folder != null) {
    outputText("User selected " + folderPath);
    folderPath = selection.getAbsolutePath();
    scanFolder(folder);
    System.out.println("Log Files: " + logFiles);
    System.out.println("Log File Paths: " + logFilePaths);
    currentFile = 0;
    fileCount = logFiles.size();
    //fileCount = 1; // limit for debug only
    input = true;
  }
}

public void scanFolder(File folder) {
  File[] files = folder.listFiles();
  if (files != null) {
    for (File file : files) {
      if (file.isDirectory()) {
        scanFolder(file);
      } else {
        for (String s : scanFileType) {
          String name = file.getName().toLowerCase();
          if (!(name.equals("p5.js") || name.equals("p5.sound.min.js") || name.equals("p5.sound.js") || name.equals("p5.min.js"))) {
            if (name.endsWith(s)) {
              logFiles.add(file.getName());
              logFilePaths.add(file.getAbsolutePath());
              break;
            }
          }
        }
      }
    }
  }
}

void outputText(String s) {
  list.add(s);
  println(s);
}

/**
 * Process next file in list
 * return false if no file was processed or there are more to process
 * return true if all files processed
 */
boolean processNextFile(int outputType) {
  if (currentFile == fileCount) {
    return true;  // all files processed
  }
  if (input && currentFile < fileCount) {
    String fileName = logFiles.get(currentFile);
    String filePath = logFilePaths.get(currentFile);
    String[] lines = loadStrings(filePath);
    String[] summary = chatbot.summarizeLog(lines);
    if (summary != null) {
      output.open(folderPath); // once even if called again
      output.add(fileName, filePath, summary);
      currentFile++;
    }
    if (currentFile == fileCount) {
      input = false;  // no more input
      output.close();
    }
  }
  return false;
}
