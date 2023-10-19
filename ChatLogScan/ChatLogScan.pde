// <prompt>
// code a java sketch to select a folder in setup.
// get an array list of subfolders in the selected folder
// for each subfolder read the log file ending with filetype ".log"  from the folder.
// from the log file print the line after the 2nd line that starts with "<prompt>"
//
// <response>
// Here is a simple sketch that should do what you're asking for. This code uses Processing's `selectFolder()`, `listFiles()`, and `loadStrings()` functions to select a folder, get an array of subfolders, and read a log file, respectively.
//
// Modified to make it work ;>)
// ```java
import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;

//StringBuilder sb;
ArrayList<String> list;
String outputPath;
boolean done = false;

void setup() {
  size(1080, 1080);
  //sb = new StringBuilder();
  list = new ArrayList<String>();

  // Select a folder using a folder selector dialog
  selectFolder("Select a Folder", "folderSelected");
}

void folderSelected(File selection) {
  if (selection == null) {
    println("No folder was selected.");
    exit();
  } else {
    outputText("User selected " + selection.getAbsolutePath());
    outputPath = selection.getAbsolutePath();
    // Get an array list of subfolders in the selected folder
    File[] subfolders = selection.listFiles(new FilenameFilter() {
      public boolean accept(File file, String name) {
        return file.isDirectory();
      }
    }
    );
    outputText("number of folders="+subfolders.length);
    int numFound = 0;
    int numLogNoGood = 0;
    // For each subfolder, read the log file ending with filetype ".log"
    for (File subfolder : subfolders) {

      File[] logFiles = subfolder.listFiles(new FilenameFilter() {
        public boolean accept(File dir, String name) {
          boolean found = name.endsWith(".log");
          return found;
        }
      }
      );

      File[] pdeFiles = subfolder.listFiles(new FilenameFilter() {
        public boolean accept(File dir, String name) {
          boolean found = name.endsWith(".pde");
          return found;
        }
      }
      );

      // folder with pde files
      if (pdeFiles != null) {
        for (File pdeFile : pdeFiles) {
          String[] lines = loadStrings(pdeFile.getAbsolutePath());
          for (int i = 0; i < lines.length; i++) {
            if (lines[i].toLowerCase().contains("prompt")) {
              if (lines[i].length() > 3) {
                numFound++;
                outputText(str(numFound) + " folder: " + subfolder.getName() + " PDE: " + pdeFile.getName() + " " + lines[i + 1]);
                break;
              }
            }
          }
        }
      }

      // From the log file, print the line after the 2nd line that starts with "<prompt>" or "Prompt:"
      if (logFiles == null) {
        outputText("no log file in "+subfolder.getName());
      } else {
        //println("number of Log files="+ logFiles.length);
        for (File logFile : logFiles) {
          String[] lines = loadStrings(logFile.getAbsolutePath());
          String[] ptext = parsePrompts(lines);
          int count = 0;
          int isave = 0;
          boolean logGood = false;
          for (int i = 0; i < lines.length; i++) {
            if (lines[i].startsWith("###")) {
              count = 0;
            } else if ((lines[i].startsWith("<prompt>") || (lines[i].startsWith("Prompt:")))&& i < lines.length - 1) {
              count++;
              if (count == 1) {
                if (isave == 0) isave = i+1;
                continue;
              }
              if (count == 2) {
                if (lines[i+1].isBlank()) i++;
                numFound++;
                isave = 0;
                logGood = true;
                outputText(str(numFound) + " folder: " + subfolder.getName()); // + " "+ lines[i + 1]);
                for (String s : ptext) {
                  if (!(s.isBlank() || s.isEmpty())) outputText(s);
                }
                break;
              }
            }
          }
          if (isave > 0) {
            numFound++;
            logGood = true;
            outputText(str(numFound) + " folder: " + subfolder.getName()); // + " "+ lines[isave]);
            for (String s : ptext) {
              if (!(s.isBlank() || s.isEmpty())) outputText(s);
            }
          }
          if (!logGood) {
            numLogNoGood++;
            outputText( "nothing in log file: "+logFile.getName());
          }
        }
      }
    }
    outputText("number of incomplete log files=" + numLogNoGood);
    String[] out = list.toArray(new String[list.size()]);
    saveStrings(outputPath + File.separator+"logIndex.txt", out);
    done = true;
  }
}

void outputText(String s) {
  list.add(s);
  println(s);
}

String[] parsePrompts(String[] lines) {
  ArrayList<String> prompts = new ArrayList<String>();
  boolean copying = false;

  for (String line : lines) {
    if (line.startsWith("<prompt>") || line.startsWith("Prompt:")) {
      copying = true;
      continue; // Skip this line
    }
    if (line.startsWith("<response>")|| line.startsWith("Response:")) {
      copying = false;
      prompts.add("---");
    }
    if (copying) {
      prompts.add(line);
    }
  }

  // Convert the ArrayList back to a String array
  String[] result = new String[prompts.size()];
  result = prompts.toArray(result);
  return result;
}

void draw() {
  if (done) {
    background(255);
    fill(0);
    textSize(72);
    text("Done", width/2, height/2);
  }
}

// ```
//
// Please note that this code will only print the line after the 2nd line that starts with "<prompt>" for each log file. If you want to print the line after every line that starts with "<prompt>", you should remove the `break;` statement.
//
// Also, please note that this code uses the `loadStrings()` function to read the entire log file into memory. If your log files are very large, this could cause your program to run out of memory. In that case, you would need to use a different method to read the log files line by line.
//
// Sources:
// - https://processing.org/reference/selectFolder_.html
// - https://processing.org/reference/loadStrings_.html
// - https://docs.oracle.com/javase/7/docs/api/java/io/File.html#listFiles(java.io.FileFilter)
// - https://docs.oracle.com/javase/7/docs/api/java/io/File.html#isDirectory()
// - https://docs.oracle.com/javase/7/docs/api/java/io/FilenameFilter.html
// - https://docs.oracle.com/javase/7/docs/api/java/lang/String.html#startsWith(java.lang.String)
//
//
