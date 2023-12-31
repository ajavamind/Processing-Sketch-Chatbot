/**
 * Utility functions
 */

import java.util.List;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.io.BufferedReader;
import java.io.StringReader;
import java.lang.StringBuilder;
import java.lang.Process;
import java.lang.Exception;
import java.util.concurrent.TimeUnit;

static final String fileLogType = ".log";
String fileType = ".txt";

void newLogFile(String name, String[] lines, String fname ) {
  File file;
  String fileName = fname + fileLogType;
  try {
    logger(fileName);
    file = new File(fileName);
    if (!file.exists()) {

      String[] p = new String[1];
      if (name == null) {
        p[0] = "";
      } else {
        p[0] = name;
      }
      createNewFile(fileName, p);
      appendToFile(fileName, lines);
    }
  }
  catch (FileNotFoundException e) {
    e.printStackTrace();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

void appendLog(String fname, String[] lines) {
  File file;
  String fileName = fname + fileLogType;
  try {
    logger(fileName);
    file = new File(fileName);
    if (!file.exists()) {
      println("Error program log file does not exist"); //  createNewFile(fileName, lines);
    } else {
      appendToFile(fileName, lines);
    }
  }
  catch (FileNotFoundException e) {
    e.printStackTrace();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

void createNewFile(String fileName, String[] lines) throws IOException {
  logger("createNewFile="+fileName);
  FileWriter writer = new FileWriter(fileName);
  for (String line : lines) {
    writer.write(line + System.lineSeparator());
  }
  writer.close();
}

void appendToFile(String fileName, String[] lines) throws IOException {
  logger("appendToFile="+fileName);
  if (lines != null) {
    for (String line : lines) {
      Files.write(Paths.get(fileName), (line + System.lineSeparator()).getBytes(), StandardOpenOption.APPEND);
    }
  }
}

// save prompt and response lines in a text or html file and
// generate Processing sketch folder and store all files extracted into the folder
void saveLogText(String[] prompts, String[] responses, String fname) {
  fileType = ".txt";
  int len = prompts.length + responses.length + 3;  // and add space for prompt, response, separation lines
  logger("saveText number of lines: "+len);
  String[] list = new String[len+1];
  int j = 0;
  list[j++] = "<prompt>";
  for (int i = 0; i<prompts.length; i++) {
    list[j++] = prompts[i];
  }
  list[j++] = "<response>";
  for (int i = 0; i<responses.length; i++) {
    list[j++] = responses[i];
  }
  list[j++] = "\n";
  if (responses[0].startsWith("<!DOCTYPE html")) {
    fileType = ".html";
  }
  //String filename = saveFolderPath + File.separator + folderPath + File.separator + name ; // chat folder
  saveStrings(fname + fileType, list);  // save txt or html file
  appendLog(fname, list);
  initReviewText(fname);
}

// split string into separate text lines using line feed 0x0A
public static String[] parseString(String input) {
  //  String[] lines = input.split("\n");
  // keep end of line character
  String[] lines = new BufferedReader(new StringReader(input))
    .lines()
    //    .map(s -> s + "\n")
    .map(s -> s)
    .toArray(String[]::new);
  return lines;
}

public static String combineStrings(String[] strings) {
  StringBuilder result = new StringBuilder();
  for (String s : strings) {
    result.append(s);
  }
  return result.toString();
}

String getDateTime() {
  Date current_date = new Date();
  String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(current_date);
  return timeStamp;
}

// Convert an integer to a String and add leading zeroes to number to make four digits
String number(int index) {
  // fix size of index number at 4 characters long
  //  if (index == 0)
  //    return "";
  if (index < 10)
    return ("000" + String.valueOf(index));
  else if (index < 100)
    return ("00" + String.valueOf(index));
  else if (index < 1000)
    return ("0" + String.valueOf(index));
  return String.valueOf(index);
}

// calls Processing IDE exe
void execSketch(String[] info) {
  String filenamePath = info[0];
  String name = info[1];
  String codeType = info[2];
  logger("execSketch "+filenamePath);
  if (filenamePath == null) return;
  try {
    logger("processing-java.exe --sketch="+ filenamePath
      + " --output=" + filenamePath + "test" + " --force --run");

    Process process = Runtime.getRuntime().exec("processing-java.exe --sketch="+ filenamePath
      + " --output=" + filenamePath + "test" + " --force --run");
    //process.waitFor();
  }
  catch (Exception ex) {
  }
}

// calls Processing IDE exe
void execPSketch(String[] info) {
  String filenamePath = info[0];
  String name = info[1];
  String codeType = info[2];
  logger("execPSketch "+ filenamePath);
  if (filenamePath == null) return;
  String str = "processing.exe "+ filenamePath + File.separator + name + codeType;
  try {
    logger("start processind ide " + str);
    Process process = Runtime.getRuntime().exec(str);
    //process.waitFor();
  }
  catch (Exception ex) {
    logger(ex.toString());
  }
  logger("execPSketch processing.exe call to run " + str);
}

// calls runJ.bat in the sketch path
void execJava(String filenamePath, String name) {
  logger("execJava "+filenamePath);
  if (filenamePath == null || name == null) return;
  String str = sketchPath() + File.separator + "runJ.bat " + filenamePath + " "+name;
  try {
    logger("execJava start process java " + str);
    Process process = Runtime.getRuntime().exec(str);
    //process.waitFor();
  }
  catch (Exception ex) {
    logger(ex.toString());
  }
  logger("processing java call to run "+ str);
}

/**
 * filenamePath is chat folder
 * now create sketch folder in chatfolder
 */
String[] saveSketch(String filenamePath) {
  logger("saveSketch in folder: "+filenamePath);
  if (filenamePath == null) return null;
  boolean pdeType = true;
  boolean androidMode = false;
  String[] info = new String[3];
  String name = null;
  String codeType = ".pde";
  String commentPrefix = "// ";
  String[] lines = loadStrings(filenamePath+ ".txt");
  String[] sketchPrefix = getSketchName(lines);

  if (isPythonApp(lines)) {
    commentPrefix = "# ";
  } else if (isJavaApp(lines)) {
    name = findClassNameRegex(lines);
    if (name != null ) {
      pdeType = false;
    }
  } else if (isAndroidApp(lines)) {
    androidMode = true;
  }
  int leng = lines.length;
  if (leng > 0) {
    boolean comment = true;
    for (int i=0; i<leng; i++) {
      if (lines[i].startsWith("```javascript")) {
        codeType = ".js";
        lines[i] = commentPrefix + lines[i];
        comment = !comment;
      } else if (lines[i].startsWith("```java") || lines[i].startsWith("```processing")) {
        if (pdeType) {
          codeType = ".pde";
        } else {
          codeType = ".java";
        }
        lines[i] = commentPrefix + lines[i];
        comment = !comment;
      } else if (lines[i].startsWith("```python")) {
        codeType = ".pyde";
        commentPrefix = "# ";
        lines[i] = commentPrefix + lines[i];
        comment = !comment;
      } else if (lines[i].startsWith("```html")) {
        codeType = ".html";
        lines[i] = commentPrefix + lines[i];
        comment = !comment;
      } else if (lines[i].startsWith("```")) {
        lines[i] = commentPrefix + lines[i];
        comment = true;
      } else if (comment) {
        lines[i] = commentPrefix + lines[i];
      }
    }
  }
  if (sketchPrefix == null) {
    name = sketchNamePrefix + number(sketchCounter);
    // save next sketchCounter after using here
    String[] sA = new String[1];
    sketchCounter++;
    sA[0] = str(sketchCounter);
    // write sketch counter to sketch param file
    String paramFile = filenamePath.substring(0, filenamePath.lastIndexOf(File.separator)) + File.separator + sketchParamFile;
    logger("sketchParamFile path="+paramFile);
    saveStrings(paramFile, sA);
  } else {
    name = sketchPrefix[0];
  }
  String folder = null;
  if (pdeType) {
    // make folder
    folder = filenamePath + File.separator +  name;
    logger("create folder: "+folder);
    File theDir = new File(folder);
    if (!theDir.exists()) {
      theDir.mkdirs();
    } else {
      logger("folder already exists: "+theDir.getAbsolutePath());
    }

    String fnName = folder + File.separator + name + codeType;
    saveStrings(fnName, lines);
    logger("saveStrings at: "+fnName);

    // copy mode type information
    if (codeType.equals(".pde")) {
      copyFiles("javaMode", folder);
    } else if (codeType.equals(".js")) {
      copyFiles("p5Mode", folder);
      modifyFile(folder, "index.html", "SketchName", name);
    } else if (codeType.equals(".pyde")) {
      copyFiles("pythonMode", folder);
    } else if (codeType.equals(".pde")) {
      if (androidMode) {
        copyFiles("androidMode", folder);
      } else {
        copyFiles("javaMode", folder);
      }
    } else {
    }
  } else {  // java application runs from command line and uses processing core.jar
    // get filename
    //name = findClassNameRegex(lines);
    //if (name == null) return null;
    folder = saveFolderPath + File.separator;
    String fnName = folder  + name + codeType;
    saveStrings(fnName, lines);
  }
  info[0] = folder;
  info[1] = name;
  info[2] = codeType;
  return info;
}

// get sketch name which is line before first line starting with 3 backticks java
String[] getSketchName(String[] lines) {
  String[] result = new String[10];
  int len = 0;

  for (int i=0; i<lines.length; i++) {
    if (lines[i].startsWith("```java")) {
      if (lines[i-1] == null) {
        lines[i-1] = "";
        logger("NuLL line????");
      } else {
        result[len] = lines[i-1];
      }
      // break line into tokens and pick token that ends in .pde
      if (result[len].contains(".pde")) {
        String[] split = splitTokens(result[len]);
        for (String s : split) {
          if (s.contains(".pde")) {
            result[len] = result[len].substring(0, result[len].lastIndexOf(".pde"));
            // check for valid folder name
            len++;
            break;
          } else {
            result[len] = null;
          }
        }
      }
    }
  }
  //if (DEBUG) {
  //  println("getSketchName=");
  //  printArray(result);
  //}
  if (len == 0 || result[0]==null) result = null;
  return result;
}

void copyFiles(String mode, String folder) {
  try {
    String pStr = "xcopy " + sketchPath("data") + File.separator + mode + " " + folder + " /E";
    logger("copyFiles: "+pStr);
    Process process = Runtime.getRuntime().exec(pStr);
    process.waitFor(1, TimeUnit.SECONDS);
    //process.waitFor();
  }
  catch (Exception ex) {
    logger(ex.toString());
  }
}

void modifyFile(String folder, String filename, String token, String name) {
  String where = folder + File.separator + filename;
  logger("where="+where);
  String[] lines = loadStrings(where);
  for (int i = 0; i<lines.length; i++) {
    if (lines[i].contains(token)) {
      lines[i] = lines[i].replace(token, name);
      logger("found "+token +" replace "+name +" "+lines[i]);
      saveStrings(where, lines);
      break;
    }
  }
}

boolean isPythonApp(String[] lines) {
  boolean found = false;
  for (int i = 0; i< lines.length; i++) {
    if (lines[i].contains("```python")) {
      found = true;
      break;
    }
  }
  return found;
}

boolean isJavaApp(String[] lines) {
  boolean found = false;
  for (int i = 0; i< lines.length; i++) {
    if (lines[i].startsWith("```java")) {
      for (int j=i+1; j<lines.length; j++) {
        if (lines[j].startsWith("```")) {
          return found;
        } else if (lines[j].contains("public static void main(String[] args) {")) {
          return true;
        }
      }
      break;
    }
  }
  return found;
}

boolean isAndroidApp(String[] lines) {
  boolean found = false;
  for (int i = 0; i< lines.length; i++) {
    if (lines[i].startsWith("```java")) {
      for (int j=i+1; j<lines.length; j++) {
        if (lines[j].startsWith("```")) {
          return found;
        } else if (lines[j].contains("public class MainActivity extends PApplet")) {
          return true;
        }
      }
      break;
    }
  }
  return found;
}

public static String findClassName(String[] lines) {
  for (String line : lines) {
    if (line.contains("class") && line.contains("extends")) {
      int classIndex = line.indexOf("class") + 6; // add 6 to skip "class "
      int extendsIndex = line.indexOf("extends");
      return line.substring(classIndex, extendsIndex).trim();
    } else if (line.contains("class")) {
      int classIndex = line.indexOf("class") + 6; // add 6 to skip "class "
      return line.substring(classIndex).trim();
    }
  }
  return null; // no class name found
}

public static String findClassNameRegex(String[] lines) {
  Pattern pattern = Pattern.compile("^(public\\s+)?(abstract\\s+)?class\\s+(\\w+)\\s*(extends\\s+\\w+)?\\s*\\{");
  // matches the first line of a class definition, with or without "public" or "abstract" modifiers, and with or without "extends" clause
  for (String line : lines) {
    Matcher matcher = pattern.matcher(line);
    if (matcher.matches()) {
      return matcher.group(3); // returns the third capturing group, which is the class name
    }
  }
  return null; // no class definition found
}

// For reference, not used
// calls exiftool exe in the windows path
// sets portrait orientation by rotate camera left
void setEXIFtool(String filename) {
  try {
    Process process = Runtime.getRuntime().exec("exiftool -n -orientation=6 "+filename);
    process.waitFor();
  }
  catch (Exception ex) {
  }
}

String getPrompt(String filename) {
  String[] lines = loadStrings("preprompt" + File.separator + filename);
  return combineStrings(lines);
}
