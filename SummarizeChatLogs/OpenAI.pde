/**
 * OpenAI API interface
 * OpenAI java library in code folder is from https://github.com/TheoKanning/openai-java
 */

import java.time.Duration;
import java.lang.Exception;

import com.theokanning.openai.completion.chat.ChatCompletionRequest;
import com.theokanning.openai.completion.chat.ChatCompletionChoice;
import com.theokanning.openai.completion.chat.ChatCompletionChoice;
import com.theokanning.openai.completion.chat.ChatCompletionResult;
import com.theokanning.openai.completion.chat.ChatMessage;
import com.theokanning.openai.service.OpenAiService;
import com.theokanning.openai.completion.CompletionRequest;

public class OpenAI {
  OpenAiService service;

  String model = "gpt-3.5-turbo";
  //String model = "gpt-3.5-turbo-16k";  // allows larger context prompt/response
  //String model = "gpt-3.5-turbo-0613"; // function calling, system message steering better
  //String model = "gpt-4";
  double topP = 1.0;
  int timeout = 120; // LLM server reponse timeout in seconds

  private static final String OPENAI_URL = "https://api.openai.com/";
  private static final String BASE_URL = OPENAI_URL;
  //private static final String BASE_URL = "http://localhost:4891/v1/";  // GPT4All LLM server on local machine (verified)
  //private static final String BASE_URL = "http://127.0.0.1:7860/v1/";  // Local Vicuan CPU LLM (not working)
  //private static final String BASE_URL = "http://localhost:8000/v1/";  // FastChat https://github.com/lm-sys/FastChat (not verified)

  double temperature = 0.0; // expect no randomness from the model
  String[] systemPrompt;  // current system prompt
  final List<ChatMessage> messages = new ArrayList<ChatMessage>();
  final List<ChatMessage> context = new ArrayList<ChatMessage>();
  ChatMessage systemMessage;
  String customChatFilePath = "Summary Prompt.txt";
  String instructChatFilePath = "Instruct Prompt.txt";
  String chatName;

  String errorText;
  //List<String[]> prompts;
  String prompt;

  //List<String[]> responses;
  String response;
  boolean ready = false;

  OpenAI() { // constructer
    // OPENAI_API_KEY is your paid account token variable defined in the environment variables for Windows 10/11
    String token;
    if (BASE_URL.equals(OPENAI_URL)) {
      token = getToken();
    } else {
      token = "local LLM";  // override to test GPT4All on local machine
    }

    // create the OPENAI API service
    final Duration CHAT_TIMEOUT = Duration.ofSeconds(timeout);
    service = new OpenAiService(token, CHAT_TIMEOUT);  // default BASE_URL for OpenAI
    //service = new OpenAiService(token, CHAT_TIMEOUT, BASE_URL);  // for custom LLM or OpenAI server
  }

  /**
   * get OPEN AI token from Windows environment variable
   */
  private String getToken() {
    return System.getenv("OPENAI_API_KEY");
  }

  volatile boolean threadStarted = false;
  volatile boolean threadDone = false;
  String[] aiSummary;
  String[] aiLines;

  public String[] summarizeLog(String[] lines) {
    String[] result = null;
    if (!threadStarted) {
      aiLines = lines;
      OpenAiRunnable chatbotRunnable = new OpenAiRunnable(); // Create an instance of your Runnable
      Thread thread = new Thread(chatbotRunnable); // Create a new thread with your Runnable
      thread.start(); // Start the thread
      threadStarted = true;
    }

    if (threadDone) {
      threadDone = false;
      threadStarted = false;
      result = aiSummary;
    }
    return result;
  }

  public class OpenAiRunnable implements Runnable { // Define a class that implements the Runnable interface
    public void run() { // Override the run method to specify the task
      requestSummary();
      threadDone = true;
      //println("Task is running...");
    }
  }

  void requestSummary() {
    errorText = null;
    processCustomChat();
    if (errorText != null) {
      println("Error Message: "+errorText);
    } else {
      println("Completed..........");
    }
  }

  //void requestSummaryDebug() {
  //  String[]summary = new String[10];  // for debug
  //  int size = 10;
  //  for (int i=0; i<size; i++) {
  //    summary[i] = "";
  //  }
  //  if (aiLines.length < size)
  //    size = aiLines.length;
  //  println("summarizeLog ");
  //  for (int i=0; i<size; i++) {
  //    println(aiLines[i]);
  //    summary[i] = aiLines[i];
  //  }
  //  aiSummary = summary;
  //}

  // Load Custom chat system message
  void processCustomChat() {
    context.clear();
    println("customChat: " + customChatFilePath);
    if (customChatFilePath == null) {
      errorText = "No Custom Chat Selected or invalid.";
      return;
    }
    systemPrompt = loadStrings(customChatFilePath);
    println("systemMessage "+"systemPrompt= ");
    for (String line : systemPrompt) {
      println(line);
    }
    String msg = combineStrings(systemPrompt);
    ChatMessage systemMessage = new ChatMessage(ChatMessageRole.SYSTEM.value(), msg);
    context.add(systemMessage);

    println("instructChat: " + instructChatFilePath);
    if (instructChatFilePath == null) {
      errorText = "No Instruct Chat Selected or invalid.";
      return;
    }

    String[] userPrompt = loadStrings(instructChatFilePath);
    prompt = combineStrings(userPrompt);
    aiLines[0] =  prompt + aiLines[0];
    prompt = combineStrings(aiLines);
    logger("\n");
    logger("userMessage prompt= "+prompt);
     
    ChatMessage userMessage = new ChatMessage(ChatMessageRole.USER.value(), prompt);
    context.add(userMessage);

    sendOpenAiRequest();

    if (ready && response != null) {
      aiSummary = parseString(response);
      ready = false;
    } else {
      errorText = "No response from OpenAI";
    }
  }

  /**
   * read custom chat text file
   */
  String[] readCustomChatFile(String path) {
    String[] str = loadStrings(path);
    return str;
  }

  void addUserMessage(String promptStr) {
    ChatMessage pMessage = new ChatMessage(ChatMessageRole.USER.value(), promptStr);
    context.add(pMessage);
  }

  void addAssistantMessage(String response) {
    ChatMessage rMessage = new ChatMessage(ChatMessageRole.ASSISTANT.value(), response);
    context.add(rMessage);
  }

  // Processing thread call, no parameters, works during draw()
  void sendOpenAiRequest() {
    logger("sendOpenAiRequest");
    try {
      response = getCompletion(prompt);
      ready = true;
    }
    catch(Exception rex) {
      errorText = "Service problem "+ rex;
      rex.printStackTrace();
      System.out.println(errorText);
    }
  }

  // Processing thread call, no parameters, works during draw()
  void sendOpenAiChatRequest() {
    logger("sendOpenAiChatRequest");
    try {
      response = getCompletionFromMessages(context);
      ready = true;
    }
    catch(Exception rex) {
      errorText = "Service problem "+ rex;
      logger("Service problem "+ rex + " "+ rex.toString());
    }
  }

  public String getCompletion(String promptStr) {
    if (DEBUG) {
      println("getCompletion");
      println("Prompt: "+promptStr);
      println();
    }
    final List<ChatMessage> messages = new ArrayList<>();
    final ChatMessage chatMessage = new ChatMessage(ChatMessageRole.USER.value(), promptStr);
    messages.add(chatMessage);
    ChatCompletionRequest request = ChatCompletionRequest.builder()
      .model(model)
      .messages(messages)
      .temperature(temperature)
      .build();

    ChatCompletionResult completion = service.createChatCompletion(request);
    ChatCompletionChoice choice = completion.getChoices().get(0);
    String content = choice.getMessage().getContent();
    if (DEBUG) {
      println("Response: "+content);
      println();
    }
    return content;
  }

  public String getCompletionFromMessages(List<ChatMessage> messages) {
    if (DEBUG) {
      println("getCompletionFromMessages");
      println("Messages: "+messages);
      println();
    }

    ChatCompletionRequest request = ChatCompletionRequest.builder()
      .model(model)
      .messages(messages)
      .temperature(temperature)
      .build();

    ChatCompletionResult completion = service.createChatCompletion(request);
    ChatCompletionChoice choice = completion.getChoices().get(0);
    String content = choice.getMessage().getContent();
    String finishReason = choice.getFinishReason();
    if (DEBUG) {
      println("Response: "+content);
      println("finish_reason: "+finishReason);
      println();
    }
    return content;
  }

} // class OpenAI
