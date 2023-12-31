# Processing-Sketch-Chatbot
Processing Sketch Chatbot is an OpenAI artificial intelligence API based assistant for learning and generating Processing sketch code.
It is my personal AI assistant that I can customize for programming tasks, and change it to help with any specific need where I can use AI.
I use it as a workbench for experimenting with OpenAI API and Large Language Models (LLM).

Processing is a programming language and development environment built for the electronic arts, new media art, and visual design communities 
with the purpose of teaching non-programmers the fundamentals of computer programming in a visual context. 
It's primarily used for creating graphics, animations, and interactive experiences.
Processing is capable of building small sized application sketches on several platforms: Windows, Raspberry Pi, Linux, and Apple iOS.
It accepts sketches written in Java, P5.js a JavaScript library, Android, and Python.
Processing Development Environment (PDE) is the file type name for a Processing sketch application. 
The Processing IDE, Integrated Development Environment, is a Processing sketchbook for PDE sketches with code editor, debugger, and run execution capabilities. 

## Background
I'm a retired software engineer who has been using Processing since 2010 for my personal camera, photography, photo and generative art projects.
Typically I write small sketches, but some of my projects require a lot of code.

To learn more about the AI and machine learning revolution going on now, I wrote this Processing sketch code assistant Chatbot using Java API calls to OpenAI.org LLM servers. 
My chatbot application can be modified for other chatbot application uses besides programming code. Custom instruction prompts can be used and added to tailor the chatbot for particular needs and design areas.
It turns out that only a small number of the API features and calls were needed to build the application.

## Introduction
The Processing Sketch Chatbot is an application tool to assist users of the Processing.org IDE (Integrated Development Environment) 
in generating and running code from responses to
prompts sent to the OpenAI ChatGpt service using Java based API (Application Program Interface). 
This respository is work in progress and it only implements essential features to implement a chat prompt request
and run the response code. 

The application is written in the Processing Java language and currently only runs on Windows platform
(due to the library used for GUI is only available for Windows).
It requires an OpenAI API key subscription from OpenAI.org.

Chat responses cause an instance of the sketch to be run with the IDE when a "Run IDE Sketch" key is pressed.

![Chatbot Application Screenshot](Chatbot/screenshots/promptScreen.png)

## Usage
A code assistant is helpful writing small simple sketches quickly, and avoids some tedium and mistakes made during the program development process.
The hard part is expressing your coding requirements in the prompt you give the chatbot.
You cannot trust the output response from the chatbot and have to read and understand the generated code. (Although it is often correct)

I find specific prompts are best to get good generated sketch code. And after a few prompts for requesting changes, I find it easier
to just make code changes myself. I found that starting a new chat to assist with various sections of the code project works best because it gives better responses.
I then integrate code generated into the final sketch I seek to write. The LLM cannot handle extensive coding requests.

One time the Chatbot could not figure out how to generate code for a specific request and told me. I solved this by
instructing the Chatbot to use a specific class or technique and it worked.

The advantage of this application is that it sets up a specific chat assistant for Processing.
You can run the generated code directly with the IDE, rather than copying and pasting.

The OpenAI model used in the application by default is "gpt-4" and 
randomness in responses is limited by the temperature variable set to 0.
The application model can be changed if you build the chat application yourself.
I found the GPT4 model gives the best generated code.

You can change the model using a JSON config file "chatConfig.json" found in the config folder.
Simply update this file to change the model and temperature you would like for your chats.
A second config file "envConfig.json" defines the saved output folder for storing chat prompt/responses, chat log files, and generated code.

You can build your own custom chat by creating a system prompt text file and loading it with the custom chat soft key.
This is similar to custom instructions available in online OpenAI ChatGPT. Use it for specific knowledge domains you would like assistance.
A number of custom chat files can be dound in the customSystemPrompts folder.

It is possible to user other AI chat servers than OpenAI if the server accepts the OpenAI API protocol.
This is done by changing the BASEURL of the server used in a chat.
This feature is experimental and is not fully tested.

## Setup
The Processing Sketch Chatbot application runs on Windows 11 and requires Processing 4.2 or later versions.
Install the Processing IDE, Windows 64 bit, from [www.processing.org/download](https://processing.org/download)
The previous major version of the Processing IDE (3.5.4) will not build this application.

After installing the Processing IDE, note the folder location of the IDE processing.exe run file.
Add the folder location to the environment variable "PROCESSING_HOME" and add %PROCESSING_HOME% to the path in the Windows system environment settings.
This is required for seamless starts of the IDE from the chatbot when you make a run request on code generated using the chatbot.

Note: The application only runs on Windows for now because it uses some libraries that are only available with Windows.

### OpenAI Api Key
You will need an OPENAI API developer payment account to use this chatbot application. 
See [OpenAI](https://openai.com/) for information about setting up an API developer account. 
The Chat API documentation used by this application is described at https://openai.com/product#made-for-developers.
Note that the API developer accounts are relatively inexpensive (for an infrequent user like me, compared to ChatGPT Pro),
but with the trade-off of slow response times, depending on the AI model chosen.

The application makes API calls into the OpenAI endpoint servers and requires an identifying token with API requests.
The application reads a Windows environment variable, OPENAI_API_KEY, for your OpenAI API account token.
Define your OpenAI API Key as variable name "OPENAI_API_KEY" in the Windows environment settings.
Store the account token as the value of the variable.

### IDE Modes
When you request code generation for your Processing sketch project, you can prompt for one of the modes Processing IDE sketches could use.
Generated code can be run in the IDE in the following modes: Java, p5.js (based on Javascript), and Python. 
Android mode is not available yet with the application, but you can still prompt for Android java/kotlin code if you wish.
Make sure the modes you want to run with the generated code are included in the IDE by adding in "manage modes" setup.

### IDE Libraries 
In the IDE enter menu: Sketch -> Import Library -> Manage Libraries... menu selection you can add libaries used by the application.

To build the chatbot application requires the IDE Library:

1. G4P - A graphical user interface library that provides a set of 2D GUI controls and multiple window support. 
This library only runs on Windows and is why the application is only available with Windows at this time.

To run generated code with with the IDE may require other contribution libraries:

1. Other - This is dependent on the generated code response from prompts.

## Application Support Libraries

### Openai-java
The application uses the OpenAI-Java API from the Github implementation (version 0.15.0) found at
https://github.com/TheoKanning/openai-java - thank you Theo Kanning!

I use the build with OpenAI-Java (gradlew) to determine the library jar files needed. 
This command line in Windows uses the gradlew command in info debug mode with a request to build an distribution zip file.

.\gradlew --info example:distZip

The zip file in example/build/distributions, example.zip, is unzipped and 
then copy jar files from example/lib folder into the "code" folder used by this application sketch.

## Alternate Application Code Development Projects
After I started this project I noticed there are other projects using AI to generate application code.

### Gpt-engineer
https://github.com/AntonOsika/gpt-engineer
This is an ambitious project to guide and build a complete software development using ChatGPT from OpenAI.
I may incorporate some ideas from gpt-engineer into this project.

### Gpt Pilot
https://github.com/Pythagora-io/gpt-pilot

### Smol Developer
https://github.com/smol-ai/developer

https://github.com/tmc/smol-dev-go  (fork smol-ai developer using Go language)

### How to Turn ChatGPT into AutoGPT with 1 prompt

https://youtu.be/BL9x1SuNLRo?si=UHBHNFayqNaDJtKn
Use custom prompt "Prof Synapse prompt.txt"

https://github.com/ProfSynapse/Synapse_CoR
Use custom prompt: "Synapse CoR Prof Synapse prompt.txt"
