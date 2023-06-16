# Processing-Chatbot
A Processing Chatbot Assistant for sketch code generation using the SDK

## Introduction
The Processing Chatbot is an application tool to assist users of the Processing.org SDK (Software Development Kit) 
in generating and running code from responses to
prompts sent to the OpenAI ChatGpt service using Java based API (Application Program Interface). 
This respository is work in progress and it only implements essential features to implement a chat prompt request
and run the response code. Many improvements are possible but time limitations prevent more enhancements for now.

The application is written in the Processing Java language and currently only runs on Windows OS platform. 
It requires an OpenAI API key subscription from OpenAI.org.

Chat responses cause an instance of the sketch to be run with the SDK when a "Run" key is pressed.

## Background
I'm a Processing user since 2010 and software engineer since 1966 when I starting working part-time in college.
To learn more about the AI and machine learning revolution going on now, I created here a code assistant chatbot using Java API calls to 
OpenAI.org. My chatbot application could be modified for other chatbot application uses, but I chose code generation specifically.
Only a small number of the API calls are invoked.

## Usage
I found that a code assistant is helpful to learn about programming and to avoid some tedium and mistakes during the program development process.
You cannot trust the output response from a chatbot and have to read and understand the generated code. (Although it is often correct)

I find specific prompts are best to get good generated sketch code. And after a few prompts for requesting changes, I find it easier
to just make code changes myself. Or start a new chat to assist with another section of the code I am trying to build and
then integrate it into the final sketch I seek to write.

One time the Chatbot could not figure out how to generate code for a specific request. I solved this by
instructing the Chatbot to use a specific class or technique and it worked.

The advantage of this application is that you can run the generated code directly with the SDK, rather than copying and pasting.

## Setup
The chatbot application runs on Windows 11 and Processing 4.2. 
Earlier versions of Processing SDK fail to build the application for unknown reasons.

The OpenAI model used in the application by default is "gpt-4" and 
randomness in responses is limited by the temperature variable set to 0.

### Requirements
Install Processing SDK 4.2 Windows 64 bit. Note the location of the SDK processing.exe.
Add processing.exe to the Path in the Windows environment settings.

### OpenAI Key
OPENAI_TOKEN is your paid OpenAI API account token stored in the environment variables for Windows 10/11.
Define your OpenAI API Key with name "OPENAI_TOKEN" in the Windows environment settings (search for environment).
Restart the SDK after adding your environment variable.

### SDK Modes
Code can be run in the SDK for the following modes: Java, P5.js, and Python.
Make sure the modes you want to run with generated code are included in the SDK setup.

### SDK Libraries 
In the SDK Sketch -> Import Library -> Manage Libraries... menu selection you can add libaries used by the application.

SDK Library requirements are:

1. G4P - A graphical user interface library that provides a set of 2D GUI controls and multiple window support.

2. Other - This is dependent on the generated code response from prompts requesting contributed libraries.
