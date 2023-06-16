/**
 * Utility functions
 */

import java.util.List;
import java.util.ArrayList;

// save prompt and response lines in a text or html file
String saveText(String[] prompts, String[] responses, String filenamePath) {
  String fileType = ".txt";
  int len = prompts.length + responses.length + 3;  // and add space for prompt, response, separation lines
  if (DEBUG) println("saveText number of lines: "+len);
  String[] list = new String[len];
  int j = 0;
  list[j++] = "Prompt:";
  for (int i = 0; i<prompts.length; i++) {
    list[j++] = prompts[i];
  }
  list[j++] = "Response:";
  for (int i = 0; i<responses.length; i++) {
    list[j++] = responses[i];
  }
  list[j++] = "//";
  if (responses[0].startsWith("<!DOCTYPE html")) {
    fileType = ".html";
  }
  String filename = saveFolderPath + File.separator + filenamePath + fileType;
  saveStrings(filename, list );
  return filename;
}

// split string into separate text lines using line feed 0x0A
public static String[] parseString(String input) {
  String[] lines = input.split("\n");
  return lines;
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

// calls Processing SDK exe
void execSketch(String[] info) {
  String filenamePath = info[0];
  String name = info[1];
  String codeType = info[2];
  println("execSketch "+filenamePath);
  if (filenamePath == null) return;
  try {
    if (DEBUG) println("processing.exe "+ filenamePath + File.separator + name + codeType);

    Process process = Runtime.getRuntime().exec("processing.exe "+ filenamePath + File.separator + name + codeType);
    //process.waitFor();
  }
  catch (Exception ex) {
  }
}

// calls runJ.bat in the sketch path
void execJava(String filenamePath, String name) {
  println("execJava "+filenamePath);
  if (filenamePath == null || name == null) return;
  try {
    if (DEBUG) println("process "+sketchPath() + File.separator + "runJ.bat "+ filenamePath+ " "+name);
    Process process = Runtime.getRuntime().exec(sketchPath()+ File.separator + "runJ.bat "+filenamePath +" "+name);
    //process.waitFor();
  }
  catch (Exception ex) {
  }
}

int sketchCounter = 0;
String sketchNamePrefix = "sketch";

String[] saveSketch(String filenamePath) {
  println("saveSketch "+filenamePath);
  if (filenamePath == null) return null;
  boolean pdeType = true;
  String[] info = new String[3];
  String name = null;
  String codeType = ".pde";
  String commentPrefix = "// ";
  String[] lines = loadStrings(filenamePath);
  if (isPython(lines)) {
    commentPrefix = "# ";
  } else if (isJavaApp(lines)) {
    name = findClassNameRegex(lines);
    if (name != null ) {
      pdeType = false;
    }
  }
  int leng = lines.length;
  if (leng > 0) {
    boolean comment = true;
    for (int i=0; i<leng; i++) {
      if (lines[i].startsWith("```javascript")) {
        codeType = ".js";
        lines[i] = commentPrefix + lines[i];
        comment = !comment;
      } else if (lines[i].startsWith("```java")) {
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
  sketchCounter++;
  String folder = null;
  if (pdeType) {
    // make folder
    String pre = "P";
    folder = saveFolderPath + File.separator + pre + sessionDateTime + "_" + sketchNamePrefix + number(sketchCounter);
    println(folder);
    File theDir = new File(folder);
    if (!theDir.exists()) {
      theDir.mkdirs();
    }
    name = pre + sessionDateTime + "_" + sketchNamePrefix + number(sketchCounter);
    String fnName = folder + File.separator + name + codeType;
    saveStrings(fnName, lines);

    // copy mode type information
    if (codeType.equals(".pde")) {
      copyFiles("javaMode", folder);
    } else if (codeType.equals(".js")) {
      copyFiles("p5Mode", folder);
      modifyFile(folder, "index.html", "SketchName", name);
    } else if (codeType.equals(".pyde")) {
      copyFiles("pythonMode", folder);
    } else if (codeType.equals(".pde")) {
      copyFiles("javaMode", folder);
    } else {
    }
  } else {  // java application runs from command line and uses processing core.jar
    // get filename
    //name = findClassNameRegex(lines);
    //if (name == null) return null;
    folder = saveFolderPath + File.separator ;
    String fnName = folder  + name + codeType;
    saveStrings(fnName, lines);
  }
  info[0] = folder;
  info[1] = name;
  info[2] = codeType;
  return info;
}

void copyFiles(String mode, String folder) {
  try {
    String pStr = "xcopy " + sketchPath("data") + File.separator + mode + " " + folder + " /E";
    if (DEBUG) println("copyFiles: "+pStr);
    Process process = Runtime.getRuntime().exec(pStr);
    process.waitFor();
  }
  catch (Exception ex) {
  }
}

void modifyFile(String folder, String filename, String token, String name) {
  String where = folder + File.separator + filename;
  if (DEBUG) println("where="+where);
  String[] lines = loadStrings(where);
  for (int i = 0; i<lines.length; i++) {
    if (lines[i].contains(token)) {
      lines[i] = lines[i].replace(token, name);
      if (DEBUG) println("found "+token +" replace "+name +" "+lines[i]);
      saveStrings(where, lines);
      break;
    }
  }
}

boolean isPython(String[] lines) {
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

//String saveJavaSketch(String filenamePath) {
//  println("saveJavaSketch "+filenamePath);
//  if (filenamePath == null) return "";
//  String name = null;
//  String[] lines = loadStrings(filenamePath);
//  int leng = lines.length;
//  if (leng > 0) {
//    boolean comment = true;
//    for (int i=0; i<leng; i++) {
//      if (lines[i].startsWith("```java")) {
//        lines[i] = "// " + lines[i];
//        comment = !comment;
//      } else if (lines[i].startsWith("```")) {
//        lines[i] = "// " + lines[i];
//        comment = true;
//      } else if (comment) {
//        lines[i] = "// " + lines[i];
//      }
//    }
//  }

//  // get filename
//  name = findClassNameRegex(lines);
//  if (name == null) return null;
//  String folder = saveFolderPath + File.separator ;
//  String fnName = folder  + name + ".java";
//  saveStrings(fnName, lines);
//  return name;
//}

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

import java.util.regex.Matcher;
import java.util.regex.Pattern;

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
