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
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import io.github.stefanbratanov.jvm.openai.*;
import io.github.stefanbratanov.jvm.openai.OpenAI;

String[] args;
boolean test = true;
static String model = "gpt-4.1";
static double temperature = 0.0; // expect no randomness from the model
static double topP = 1.0;
long timeout = 120; // seconds
final Duration CHAT_TIMEOUT = Duration.ofSeconds(timeout);
int elapsedTime = 0;
int FRAME_RATE = 30;
String promptFilePath;
String inputPathStr;
String outputFolderPath;

void setup() {
  // main paramteres setup - not using command line app feature
  args = new String[3];
  args[0] = sketchPath() + File.separator + "data" + File.separator +"okhttpEditPrompt.txt";
  //args[1] = sketchPath() + File.separator + "in";  // all files in the folder will be processed
  //args[1] = sketchPath() + File.separator + "in" + File.separator + "OpenAI.java";  // only process one file
  args[1] = sketchPath() + File.separator + "in" + File.separator + "OpenAIClient.java";  // only process one file
  args[2] = sketchPath() + File.separator + "out" ; // where to save files
  //args[1] = "F:\\data\\projects\\processing4\\Repositories\\jvm-openai\\src\\main\\java\\io\\github\\stefanbratanov\\jvm\\openai";
  //args[2] = "F:\\data\\projects\\processing4\\Repositories\\jvm-openai\\src\\dev\\java\\io\\github\\stefanbratanov\\jvm\\openai";

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
    String token = System.getenv("OPENAI_API_KEY");
    if (token == null || token.isEmpty()) {
      System.err.println("OPENAI_API_KEY environment variable not set.");
      System.exit(1);
    }
    OpenAI openAI = OpenAI.newBuilder(token)
      .requestTimeout(TIMEOUT)
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
      System.exit(2);
    }
  }
  catch (IOException e) {
    System.err.println("File error: " + e.getMessage());
    System.exit(2);
  }
  catch (Exception e) {
    System.err.println("Error: " + e.getMessage());
    System.exit(3);
  }
  System.out.println("Done");
  noLoop();
}

/**
 * Processes a single file: sends prompt+file to OpenAI, extracts code block, writes output.
 */
private static void processFile(String prompt, Path inputFile, Path outputFolder, ChatClient chatClient) throws IOException {
  System.out.println("Process File "+inputFile.getFileName());
  
  String inputContent = Files.readString(inputFile).trim();
  String fullPrompt = prompt + "\n\n```\n" + inputContent + "\n```";
  CreateChatCompletionRequest createChatCompletionRequest = CreateChatCompletionRequest.newBuilder()
    .model(model)
    .temperature(temperature)
    .message(ChatMessage.userMessage(fullPrompt))
    .build();
  ChatCompletion chatCompletion = chatClient.createChatCompletion(createChatCompletionRequest);
  String response = chatCompletion.choices().get(0).message().content();
  String codeBlock = extractFirstCodeBlock(response);
  // Write to output file with same name in output folder
  Path outputFile = outputFolder.resolve(inputFile.getFileName());
  Files.writeString(outputFile, codeBlock);
  System.out.println("Processed: " + inputFile.getFileName() + " -> " + outputFile.getFileName());
}

/**
 * Extracts the first code block (text between triple backticks) from the response.
 * If no code block is found, returns an empty string.
 */
private static String extractFirstCodeBlock(String text) {
  // Regex to match ``` optionally with a language, then capture everything up to the next ```
  Pattern pattern = Pattern.compile("```(?:[a-zA-Z0-9]*)?\\s*([\\s\\S]*?)\\s*```");
  Matcher matcher = pattern.matcher(text);
  if (matcher.find()) {
    return matcher.group(1).trim();
  }
  return "";
}

//try {
//  // Read prompt from file
//  String prompt = Files.readString(Paths.get(promptFilePath)).trim();
//  println("Reading edit prompt file: "+promptFilePath);

//  // Read input file contents
//  //String inputContent = Files.readString(Paths.get(inputFolderPath)).trim();
//  // Combine prompt and input, with input in code block
//  //String fullPrompt = prompt + "\n\n```\n" + inputContent + "\n```";
//  //println(fullPrompt);
//  println("Reading input folder: "+inputFolderPath);
//  //if (test) return;
//  // Ensure output folder exists
//  Path outputFolder = Paths.get(outputFolderPath);
//  if (!Files.exists(outputFolder)) {
//    Files.createDirectories(outputFolder);
//  }

//  // Set up OpenAI API
//  Duration TIMEOUT = Duration.ofSeconds(timeout);
//  String token = System.getenv("OPENAI_API_KEY");
//  if (token == null || token.isEmpty()) {
//    System.err.println("OPENAI_API_KEY environment variable not set.");
//    System.exit(1);
//  }
//  OpenAI openAI = OpenAI.newBuilder(token)
//    .requestTimeout(TIMEOUT)
//    .build();
//  // Create chat client and request
//  ChatClient chatClient = openAI.chatClient();

//  // Process each file in the input folder
//  try (DirectoryStream<Path> stream = Files.newDirectoryStream(Paths.get(inputFolderPath))) {
//    for (Path inputFile : stream) {
//      if (Files.isRegularFile(inputFile)) {
//        println(inputFile.getFileName());
//        String inputContent = Files.readString(inputFile).trim();
//        String fullPrompt = prompt + "\n\n```\n" + inputContent + "\n```";
//        CreateChatCompletionRequest createChatCompletionRequest = CreateChatCompletionRequest.newBuilder()
//          .model("gpt-4.1")
//          .message(ChatMessage.userMessage(fullPrompt))
//          .build();
//        ChatCompletion chatCompletion = chatClient.createChatCompletion(createChatCompletionRequest);
//        String response = chatCompletion.choices().get(0).message().content();
//        String codeBlock = extractFirstCodeBlock(response);
//        // Write to output file with same name in output folder
//        Path outputFile = outputFolder.resolve(inputFile.getFileName());
//        Files.writeString(outputFile, codeBlock);
//        System.out.println("Processed: " + inputFile.getFileName() + " -> " + outputFile.getFileName());
//      }
//    }
//  }
//}
//catch (IOException e) {
//  System.err.println("File error: " + e.getMessage());
//  System.exit(2);
//}
//catch (Exception e) {
//  System.err.println("Error: " + e.getMessage());
//  System.exit(3);
//}

//void draw() {
//  size(1024, 400);
//  background(128);
//  background(255);
//  fill(0);
//  textSize(36);
//  text("Done", 40, height/2);
//  elapsedTime = int(frameCount/FRAME_RATE);
//  text("Working Elapsed Time (seconds) "+ elapsedTime, 40, height/4);
//}
