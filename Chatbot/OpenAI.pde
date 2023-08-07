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

final List<ChatMessage> messages = new ArrayList<ChatMessage>();
final List<ChatMessage> context = new ArrayList<ChatMessage>();
ChatMessage systemMessage;

OpenAiService service;
//String model = "gpt-3.5-turbo";
//String model = "gpt-3.5-turbo-16k";  // allows larger context prompt/response
//String model = "gpt-3.5-turbo-0613"; // function calling, system message steering better
String model = "gpt-4";
//String model = "gpt4all-j-v1.3-groovy"; // local machine data base
//String model = "vicuna-7b-v1.3";

private static final String BASE_URL = "https://api.openai.com/";
//private static final String BASE_URL = "http://localhost:4891/v1/";  // GPT4All LLM server on local machine (verified)
//private static final String BASE_URL = "http://127.0.0.1:7860/v1/";  // Local Vicuan CPU LLM (not working)
//private static final String BASE_URL = "http://localhost:8000/v1/";  // FastChat https://github.com/lm-sys/FastChat (not verified)


double temperature = 0.0; // expect no randomness from the model
double topP = 1.0;
int timeout = 120; // LLM server reponse timeout in seconds

String[] systemPrompt;  // current system prompt

void initAI() {
  // OPENAI_API_KEY is your paid account token variable stored in the environment variables for Windows 10/11
  String token = getToken();
  //token = "local LLM";  // override to test GPT4All on local machine
  // create the OPENAI API service
  final Duration CHAT_TIMEOUT = Duration.ofSeconds(timeout);
  //service = new OpenAiService(token, CHAT_TIMEOUT);  // default BASE_URL for OpenAI
  service = new OpenAiService(token, CHAT_TIMEOUT, BASE_URL);  // for custom LLM or OpenAI server
}

/**
 * parse chat log from an array of Strings
 * returns status 0 OK
 * return status -1 error with log file structure
 */
int parseChatLog(String logFile, String[] log) {
  if (DEBUG) println("parseChatLog\n"+logFile+"\n"+log[0] +"\n"+ log[1] +"\n" + log[2] +"\n"+ log[3]);
  // first line must be <system>
  if (!log[0].equals("<system>")) return -1; // invalid log file
  //initChat();  TO DO set chat counter etc to resume chat
  
  context.clear();  // clear out current chat context for OpenAI
  int index = 1;  // the line after <system>
  // collect and copy system prompt
  int count = countLinesUntil(log, index, "<prompt>");
  systemPrompt = new String[count];
  copyLines(log, index, systemPrompt, count);
  String msg = combineStrings(systemPrompt);
  ChatMessage systemMessage = new ChatMessage(ChatMessageRole.SYSTEM.value(), msg);
  context.add(systemMessage);
  prompt = "";
  ChatMessage userMessage = new ChatMessage(ChatMessageRole.USER.value(), prompt);
  context.add(userMessage);
  index = index + count; // the line after the system prompt, should be prompt or end of file

  //count = countLinesUntil(log, index, "<prompt>");
  //String[] response = new String[count];

  // collect and copy prompt and responses
  while (index < log.length) {
    count = countLinesUntil(log, index, "<response>");
    index = index + count + 1;
    if (count == 0) prompt = "";
    // response is assistant message
    String[] response = new String[count];
    copyLines(log, index, response, count);
    String msgr = combineStrings(response);
    ChatMessage assistantMessage = new ChatMessage(ChatMessageRole.ASSISTANT.value(), msgr);
    context.add(assistantMessage);
    if (index >= log.length)
      break;
    count = countLinesUntil(log, index, "<prompt>");
    if (count == 0) break;
    ChatMessage userMessage2 = new ChatMessage(ChatMessageRole.USER.value(), prompt);
    context.add(userMessage2);
  }
  //startChat();
  return 0;
}
/*
debug context
context[0]=ChatMessage(role=system, content=You are a friendly assistant.)
context[1]=ChatMessage(role=user, content=)
context[2]=ChatMessage(role=user, content=)
context[3]=ChatMessage(role=assistant, content=Hello! How can I assist you today?)
context[4]=ChatMessage(role=user, content=what is a perlin line in processing.org)
context[5]=ChatMessage(role=assistant, content=Perlin noise is a type of gradient noise developed by Ken Perlin in 1983. It's often used in computer graphics for creating procedural textures, shapes, terrains, and other structures that have a natural, organic quality.

In Processing.org, Perlin noise is used to generate smooth, natural-seeming randomness. This is different from the 'random()' function in Processing, which generates purely random values with no relationship to each other.

Here's a simple example of how you might use Perlin noise in Processing:

```processing
float xoff = 0.0;

void draw() {
  background(204);
  xoff = xoff + .01;
  float n = noise(xoff) * width;
  line(n, 0, n, height);
}
```

In this example, the 'noise()' function is used to generate a Perlin noise value, which is then used to determine the x-coordinate of a line drawn on the screen. The result is a line that moves smoothly and organically across the screen, rather than jumping randomly from place to place.)
*/

void copyLines(String[] fromArray, int start, String[] toArray, int count) {
  int j = 0;
  for (int i=start; i<count; i++) {
    toArray[j++] = fromArray[i];
  }
}

/**
 * Count lines in an String array starting at index
 * until a String token is found that begins a line
 */
int countLinesUntil(String[] lines, int index, String token) {
  int count = 0;
  int i = index;
  while (i < lines.length) {
    if (lines[i].startsWith(token)) { // found
      break;
    }
    count++;
    i++;
  }
  return count;
}

// General chat system message
void generalChat() {
  initChat();
  context.clear();
  if (prompt.equals(INITIAL_PROMPT)) prompt = "";
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
  if (prompt.equals(INITIAL_PROMPT)) prompt = "";
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
  if (prompt.equals(INITIAL_PROMPT)) prompt = "";
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
  if (prompt.equals(INITIAL_PROMPT)) prompt = "";
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
  if (prompt.equals(INITIAL_PROMPT)) prompt = "";
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
