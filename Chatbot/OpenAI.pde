/**
 * OpenAI API interface
 * OpenAI java library in code folder is from https://github.com/TheoKanning/openai-java
 */

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
  String msg = combineStrings(loadStrings("preprompt" + File.separator + "generalPrompt.txt"));
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
  String msg = combineStrings(loadStrings("preprompt" + File.separator + "processingPrompt.txt"));
  ChatMessage systemMessage = new ChatMessage(ChatMessageRole.SYSTEM.value(), msg);
  context.add(systemMessage);
  prompt = "";
  ChatMessage userMessage = new ChatMessage(ChatMessageRole.USER.value(), prompt);
  context.add(userMessage);
  startChat();
}

// Processing alternate chat system message
void processingAltChat() {
  initChat();
  context.clear();
  prompt = "";
  String msg = combineStrings(loadStrings("preprompt" + File.separator + "systemPrompt.txt"));
  ChatMessage systemMessage = new ChatMessage(ChatMessageRole.SYSTEM.value(), msg);
  context.add(systemMessage);
  ChatMessage userMessage = new ChatMessage(ChatMessageRole.USER.value(), prompt);
  context.add(userMessage);
  startChat();
}

// Processing 3D Chat system message
void processing3DChat() {
  initChat();
  println("CHAT_MODE Processing.org stereoscopic 3D vision sketch coder, java programming language assistant");
  context.clear();
  String msg = combineStrings(loadStrings("preprompt" + File.separator + "processing3DPrompt.txt"));
  ChatMessage systemMessage = new ChatMessage(ChatMessageRole.SYSTEM.value(), msg);
  context.add(systemMessage);
  prompt = "";
  ChatMessage userMessage = new ChatMessage(ChatMessageRole.USER.value(), prompt);
  context.add(userMessage);
  startChat();
}

// initialize for new chat
void initChat() {
  chatCounter++;
  fileCounter = 0;
  mode = CHAT_MODE;
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
    println("Service problem "+ rex + " "+ rex.toString());
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
