// from https://community.openai.com/t/java-or-kotlin-equivalent-for-transcribe-api/420069/2
// https://platform.openai.com/docs/guides/speech-to-text

// <prompt>
// convert this code to java with processing library:
// fun transcribeAudio(audioFile: File): String {
//         val audioRequestBody = audioFile.asRequestBody("audio/*".toMediaType())
//         val formBody = MultipartBody.Builder()
//             .setType(MultipartBody.FORM)
//             .addFormDataPart("file", audioFile.name, audioRequestBody)
//             .addFormDataPart("model", "whisper-1")
//             .addFormDataPart("language", "en")
//             .build()
//         val request = Request.Builder()
//             .url("https://api.openai.com/v1/audio/transcriptions")
//             .header("Authorization", "Bearer API_KEY")
//             .post(formBody)
//         return client.newCall(request.build()).execute().use { response ->
//             response.body?.string() ?: ""
//         }
//     }
//
// <response>
// Here is the equivalent Java code using the Processing library and OkHttp:
//
// ```java

import java.io.File;
import java.io.IOException;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.MultipartBody;
import java.io.IOException;
import java.util.concurrent.TimeUnit;
import okhttp3.MediaType;

private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");

String token;
String transcript;
volatile File audioFile;
String audioFilename = "media-afc-cal-afc1986022_sr14a01.mp3"; // Roosevelt Day of Infamy speech

void setup() {
  token = getToken();
  selectInput("Select a file to process:", "fileSelected");
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    audioFile = selection;
  }
}

void draw() {
  background(255);
  while ( audioFile == null) {
  };
  String[] text = new String[1];
  text[0] = transcribeAudio(audioFile);
  println(text[0]);
  saveStrings("transcript.txt", text);
  noLoop();
}

String transcribeAudio(File audioFile) {
  println("transcribeAudio");
  // OkHttpClient client = new OkHttpClient();   // timeout errors with this
  OkHttpClient client = new OkHttpClient.Builder()
    .connectTimeout(120, TimeUnit.SECONDS)
    .writeTimeout(60, TimeUnit.SECONDS)
    .readTimeout(120, TimeUnit.SECONDS)
    .build();

  MediaType mediaType = MediaType.parse("audio/*");
  RequestBody audioRequestBody = RequestBody.create(mediaType, audioFile);
  RequestBody formBody = new MultipartBody.Builder()
    .setType(MultipartBody.FORM)
    .addFormDataPart("file", audioFile.getName(), audioRequestBody)
    .addFormDataPart("model", "whisper-1")
    .addFormDataPart("language", "en")
    .build();
  Request request = new Request.Builder()
    .url("https://api.openai.com/v1/audio/transcriptions")
    .header("Authorization", "Bearer "+ token)
    .post(formBody)
    .build();
  try {
    Response response = client.newCall(request).execute();
    return response.body() != null ? response.body().string() : "";
  }
  catch (IOException e) {
    e.printStackTrace();
    return "IOException: " + e.getMessage();
  }
}

/**
 * get OPEN AI token from Windows environment variable
 */
String getToken() {
  return System.getenv("OPENAI_API_KEY");
}
