// Output files

interface Output {
  public void open(String outputPath);
  public void add(String name, String filePath, String[] lines);
  public void close();
}

import java.io.*;

public class HtmlFileCreator implements Output {
  private BufferedWriter writer;
  
  public void open(String outputPath) {
    if (writer != null) return; // only initialize first time
    try {
      writer = new BufferedWriter(new FileWriter(outputPath+File.separator+getDateTime()+"_log.html"));
      writer.write("<html>\n<head>\n<title>Log file summaries</title>\n</head>\n<body>\n");
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
  public void add(String name, String filePath, String[] lines) {
    try {
      if (lines.length > 0) {
        writer.write("<h3> ");
        writer.write(lines[0]);
        writer.write("</h3>\n");

        writer.write("<p>\n");
        for (int i=1; i<lines.length; i++) {
          writer.write(lines[i] + "\n");
        }
        writer.write("</p>\n");
      }
      writer.write("<a \"" + name + "\">" + name + "\n");
      writer.write("<a href=\"" + filePath + "\">" + filePath + "</a>\n");
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
  public void close() {
    try {
      writer.write("</body>\n</html>");
      writer.close();
    }
    catch (IOException e) {
      e.printStackTrace();
    }
    writer = null; // clear for next initialization 
  }
}

public class TextFileCreator implements Output{
  private BufferedWriter writer;
  
  public void open(String outputPath) {
    if (writer != null) return; // only initialize first time
    try {
      writer = new BufferedWriter(new FileWriter(outputPath+File.separator+getDateTime()+"_log.txt"));
      writer.write("");
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
  public void add(String name, String filePath, String[] lines) {
    try {
      if (lines.length > 0) {
        writer.write(lines[0]);
        for (int i=1; i<lines.length; i++) {
          writer.write(lines[i] + "\n");
        }
      }
      //writer.write(name);
      //writer.write(filePath);
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
  public void close() {
    try {
      writer.write("");
      writer.close();
    }
    catch (IOException e) {
      e.printStackTrace();
    }
    writer = null; // clear for next initialization 
  }
}
