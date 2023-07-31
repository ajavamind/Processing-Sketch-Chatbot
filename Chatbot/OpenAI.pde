/**
 * OpenAI API interface
 * OpenAI java library in code folder is from https://github.com/TheoKanning/openai-java
 */

import java.time.Duration;

import com.theokanning.openai.completion.chat.ChatCompletionRequest;
import com.theokanning.openai.completion.chat.ChatCompletionChoice;
import com.theokanning.openai.completion.chat.ChatCompletionChoice;
import com.theokanning.openai.completion.chat.ChatCompletionResult;
import com.theokanning.openai.completion.chat.ChatMessage;
import com.theokanning.openai.service.OpenAiService;
import com.theokanning.openai.completion.CompletionRequest;

final List<ChatMessage> messages = new ArrayList<ChatMessage>();
final List<ChatMessage> context = new ArrayList<ChatMessage>();
ChatMessage systemMessage;

private static final Duration CHAT_TIMEOUT = Duration.ofSeconds(120);
OpenAiService service;
//String model = "gpt-3.5-turbo";
//String model = "gpt-3.5-turbo-16k";  // allows larger context prompt/response
//String model = "gpt-3.5-turbo-0613"; // function calling, system message steering better
String model = "gpt-4";
//String model = "gpt-4-0613";  // function calling

double temperature = 0.0; // expect no randomness from the model
double topP = 1.0;

String[] systemPrompt;  // current system prompt

void initAI() {
  // OPENAI_API_KEY is your paid account token stored in the environment variables for Windows 10/11
  String token = getToken();
  // create the OPENAI API service
  service = new OpenAiService(token, CHAT_TIMEOUT);
}

// General chat system message
void generalChat() {
  initChat();
  context.clear();
  prompt = "";
  String path = sketchPath("systemprompts") + File.separator + "generalPrompt.txt";
  if (DEBUG) println("generalChat: " + path);
  systemPrompt = loadStrings(path);
  if (DEBUG) println("systemMessage="+systemPrompt);
  String msg = combineStrings(systemPrompt);
  ChatMessage systemMessage = new ChatMessage(ChatMessageRole.SYSTEM.value(), msg);
  context.add(systemMessage);
  ChatMessage userMessage = new ChatMessage(ChatMessageRole.USER.value(), prompt);
  context.add(userMessage);
  startChat();
}

// Processing chat system message
void processingChat() {
  initChat();
  context.clear();
  prompt = "";
  String path = sketchPath("systemprompts") + File.separator + "processingPrompt.txt";
  if (DEBUG) println("processingChat: " + path);
  systemPrompt = loadStrings(path);
  if (DEBUG) println("systemMessage="+systemPrompt);
  String msg = combineStrings(systemPrompt);
  ChatMessage systemMessage = new ChatMessage(ChatMessageRole.SYSTEM.value(), msg);
  context.add(systemMessage);
  //ChatMessage userMessage = new ChatMessage(ChatMessageRole.USER.value(), prompt);
  //context.add(userMessage);
  startChat();
}

// Processing load alternate chat system message
void processingAltChat() {
  initChat();
  context.clear();
  prompt = "";
  String path = sketchPath("customSystemPrompts") + File.separator + "systemPrompt.txt";
  systemPrompt = loadStrings(path);
  if (DEBUG) println("systemMessage="+systemPrompt);
  String msg = combineStrings(systemPrompt);
  ChatMessage systemMessage = new ChatMessage(ChatMessageRole.SYSTEM.value(), msg);
  context.add(systemMessage);
  //ChatMessage userMessage = new ChatMessage(ChatMessageRole.USER.value(), prompt);
  //context.add(userMessage);
  startChat();
}

// Load Custom chat system message
void processCustomChat() {
  initChat();
  context.clear();
  prompt = "";
  //String path = sketchPath("customSystemPrompts") + File.separator + "systemPrompt.txt";
  if (DEBUG) println("customChat: " + customChatFilePath);
  systemPrompt = loadStrings(customChatFilePath);
  if (DEBUG) println("systemMessage="+systemPrompt);
  String msg = combineStrings(systemPrompt);
  ChatMessage systemMessage = new ChatMessage(ChatMessageRole.SYSTEM.value(), msg);
  context.add(systemMessage);
  //ChatMessage userMessage = new ChatMessage(ChatMessageRole.USER.value(), prompt);
  //context.add(userMessage);
  startChat();
}

// Processing 3D Chat system message
void processing3DChat() {
  initChat();
  if (DEBUG) println("CHAT_MODE Processing.org stereoscopic 3D vision sketch coder, java programming language assistant");
  context.clear();
  prompt = "";
  String path = sketchPath("customSystemPrompts") + File.separator + "processing3DPrompt.txt";
  if (DEBUG) println("customChat: " + path);
  systemPrompt = loadStrings(path);
  if (DEBUG) println("systemMessage="+systemPrompt);
  String msg = combineStrings(systemPrompt);
  ChatMessage systemMessage = new ChatMessage(ChatMessageRole.SYSTEM.value(), msg);
  context.add(systemMessage);
  ChatMessage userMessage = new ChatMessage(ChatMessageRole.USER.value(), prompt);
  context.add(userMessage);
  startChat();
}

// initialize for new chat
void initChat() {
  chatCounter++;
  fileCounter = 0;
}

void resetChat() {
  ready = false;
  start = false;
}

void startChat() {
  // check if ready to start
  if (!start) {
    errorText = null;
    ready = false;
    start = true;
  }
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
  if (DEBUG) println("sendOpenAiRequest");
  try {
    response = getCompletion(prompt);
    ready = true;
  }
  catch(Exception rex) {
    errorText = "Service problem "+ rex;
    rex.printStackTrace();
    System.out.println(errorText);
    lastKeyCode = KEYCODE_ERROR;
  }
  animation = NO_ANIMATION;
}

// Processing thread call, no parameters, works during draw()
void sendOpenAiChatRequest() {
  if (DEBUG) println("sendOpenAiChatRequest");
  try {
    response = getCompletionFromMessages(context);
    ready = true;
  }
  catch(Exception rex) {
    errorText = "Service problem "+ rex;
    if (DEBUG) println("Service problem "+ rex + " "+ rex.toString());
    lastKeyCode = KEYCODE_ERROR;
  }
  animation = NO_ANIMATION;
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
