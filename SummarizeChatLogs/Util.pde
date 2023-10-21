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

static final String loggerFileType = ".log";
String fileType = ".txt";

void newLogFile(String name, String[] lines, String fname ) {
  File file;
  String fileName = fname + loggerFileType;
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
  String fileName = fname + loggerFileType;
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

// split string into separate text lines delimited by line feed 0x0A
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

// debug logger
public void logger(String str) {
  //logger(str);
  if (DEBUG) System.out.println(str);
}
