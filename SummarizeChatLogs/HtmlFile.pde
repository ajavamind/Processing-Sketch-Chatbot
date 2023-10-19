import java.io.*;
public class HtmlFileCreator {
  private BufferedWriter writer;
  public void initializeHtmlFile(String outputPath) {
    try {
      writer = new BufferedWriter(new FileWriter(outputPath+File.separator+getDateTime()+"_log.html"));
      writer.write("<html>\n<head>\n<title>Log file summaries</title>\n</head>\n<body>\n");
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
  public void addLink(String name, String filePath, String[] lines) {
    try {
      if (lines.length > 0) {
        writer.write("<h2> ");
        writer.write(lines[0]);
        writer.write("</h2>\n");

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
  public void finishHtmlFile() {
    try {
      writer.write("</body>\n</html>");
      writer.close();
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
}
