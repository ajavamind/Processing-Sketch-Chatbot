/**
 AI Editor - applies OPEN AI chat prompt operation on input files using API
 Andy Modla
 - The app now takes **four** parameters:
 1. Path to the prompt file
 2. Path to the input folder or input file
 3. Path to the output folder
 4. (Optional) File extension filter (e.g., `.txt`)
 – if you want to process only certain files within input folder (optional, not implemented )
 */

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.*;
import java.time.Duration;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import io.github.stefanbratanov.jvm.openai.*;
import io.github.stefanbratanov.jvm.openai.OpenAI;

String[] args;
boolean test = true;
static String baseUrl = "http://192.168.1.96:8080/v1/";  // local LLM
//static String CODE_BLOCK = "###";
static String CODE_BLOCK = "```";

//static String model = "gpt-4.1";
static String model = "granite3.3";
static double temperature = 0.1; // expect no randomness from the model
static double topP = 1.0;
long timeout = 3600; // seconds
int elapsedTime = 0;
int FRAME_RATE = 30;
String promptFilePath;
String inputPathStr;
String outputFolderPath;
int exitError = 0;

void setup() {
  size(1024, 400);
  // main paramteres setup - not using command line app feature
  args = new String[3];
  args[0] = sketchPath() + File.separator + "data" + File.separator +"okhttpEditPrompt.txt";
  //args[1] = sketchPath() + File.separator + "in";  // all files in the folder will be processed
  //args[1] = sketchPath() + File.separator + "in" + File.separator + "OpenAI.java";  // only process one file 3 min 37 sec RTX3060
  //args[1] = sketchPath() + File.separator + "in" + File.separator + "OpenAIException.java";  // only process one file
  //args[1] = sketchPath() + File.separator + "in" + File.separator + "OpenAIClient.java";  // only process one file
  //args[2] = sketchPath() + File.separator + "output" ; // where to save files
  args[1] = "F:\\data\\projects\\processing4\\Repositories\\jvm-openai\\src\\main\\java\\io\\github\\stefanbratanov\\jvm\\openai";
  args[2] = "F:\\data\\projects\\processing4\\Repositories\\jvm-openai\\src\\dev\\java\\io\\github\\stefanbratanov\\jvm\\openai";

  // Check for correct number of arguments
  if (args.length != 3) {
    System.err.println("Usage: java examples.AIeditor <promptFile> <inputFolderOrFile> <outputFolder>");
    System.exit(1);
  }

  promptFilePath = args[0];
  inputPathStr = args[1];
  outputFolderPath = args[2];

  try {
    // Read prompt text from the prompt file
    String prompt = Files.readString(Paths.get(promptFilePath)).trim();

    // Prepare OpenAI API
    Duration TIMEOUT = Duration.ofSeconds(timeout);
    //String token = System.getenv("OPENAI_API_KEY");
    String token = "local";
    //if (token == null || token.isEmpty()) {
    //  System.err.println("OPENAI_API_KEY environment variable not set.");
    //  System.exit(1);
    //}
    OpenAI openAI = OpenAI.newBuilder(token)
      .requestTimeout(TIMEOUT)
      .baseUrl(baseUrl) // local LLM
      .build();

    ChatClient chatClient = openAI.chatClient();
    // Ensure output folder exists
    Path outputFolder = Paths.get(outputFolderPath);
    if (!Files.exists(outputFolder)) {
      Files.createDirectories(outputFolder);
    }
    Path inputPath = Paths.get(inputPathStr);
    if (Files.isDirectory(inputPath)) {
      // Process each file in the input folder
      try (DirectoryStream<Path> stream = Files.newDirectoryStream(inputPath)) {
        for (Path inputFile : stream) {
          if (Files.isRegularFile(inputFile)) {
            processFile(prompt, inputFile, outputFolder, chatClient);
          }
        }
      }
    } else if (Files.isRegularFile(inputPath)) {
      // Process the single input file
      processFile(prompt, inputPath, outputFolder, chatClient);
    } else {
      System.err.println("Input path is neither a file nor a directory: " + inputPathStr);
      exitError = 2;
    }
  }
  catch (IOException e) {
    System.err.println("File error: " + e.getMessage());
    exitError = 3;
  }
  catch (Exception e) {
    System.err.println("Error: " + e.getMessage() );
    e.printStackTrace();
    exitError = 4;
  }
  if (exitError > 0) {
    System.out.println("Exit Error "+str(exitError));
  } else {
    System.out.println("Done");
  }
}

/**
 * Processes a single file: sends prompt+input code file content to OpenAI, extracts code block, writes output.
 */
private static void processFile(String prompt, Path inputFile, Path outputFolder, ChatClient chatClient) throws IOException {
  System.out.println("Editing File: "+inputFile.getFileName() + " " + getDateTime());
  Path outputFile = outputFolder.resolve(inputFile.getFileName());
  if (!Files.exists(outputFile)) {
    String inputContent = Files.readString(inputFile).trim();
    String fullPrompt = prompt + "\n\n"+CODE_BLOCK+"\n" + inputContent + "\n"+CODE_BLOCK;
    //println(fullPrompt);
    CreateChatCompletionRequest createChatCompletionRequest = CreateChatCompletionRequest.newBuilder()
      .model(model)
      .temperature(temperature)
      .message(ChatMessage.userMessage(fullPrompt))
      .build();
    ChatCompletion chatCompletion = chatClient.createChatCompletion(createChatCompletionRequest);
    String response = chatCompletion.choices().get(0).message().content();
    String codeBlock = extractFirstCodeBlock(response);
    // Write to output file with same name in output folder
    Files.writeString(outputFile, codeBlock);
    System.out.println("Processed: " + inputFile.getFileName() + " -> " + outputFile.getFileName()+ " " + getDateTime());
  } else {
    System.out.println("Skip existing file: " + inputFile.getFileName() + " == " + outputFile.getFileName()+ " " + getDateTime());
  }
}

/**
 * Extracts the first code block (text between triple backticks) from the response.
 * If no code block is found, returns an empty string.
 */
private static String extractFirstCodeBlock(String text) {
  // Regex to match ``` optionally with a language, then capture everything up to the next ```
  Pattern pattern = Pattern.compile(CODE_BLOCK+"(?:[a-zA-Z0-9]*)?\\s*([\\s\\S]*?)\\s*"+CODE_BLOCK);
  Matcher matcher = pattern.matcher(text);
  if (matcher.find()) {
    return matcher.group(1).trim();
  }
  return "";
}

static String getDateTime() {
  Date current_date = new Date();
  String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(current_date);
  return timeStamp;
}

void draw() {
  background(255);
  fill(0);
  textSize(36);
  if (exitError > 0) {
    text("Error "+str(exitError), 40, height/2);
  } else {
    text("Done", 40, height/2);
  }
}
