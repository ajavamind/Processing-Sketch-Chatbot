# Processing-Sketch-Chatbot
A Processing Sketch Chatbot Assistant for sketch code generation and learning using the Processing IDE

## Introduction
The Processing Sketch Chatbot is an application tool to assist users of the Processing.org IDE (Integrated Development Environment) 
in generating and running code from responses to
prompts sent to the OpenAI ChatGpt service using Java based API (Application Program Interface). 
This respository is work in progress and it only implements essential features to implement a chat prompt request
and run the response code. 

Many improvements are possible but time limitations prevent more enhancements for now. 
For example I would like to add a saving the chat in a database to allow resuming the chat at a later date.
Also more parameters should be visible through the GUI and prompts out to be stored in files instead of declared in the code, etc...

The application is written in the Processing Java language and currently only runs on Windows OS platform
(due to the library used for GUI is only available for Windows).
It requires an OpenAI API key subscription from OpenAI.org.

Chat responses cause an instance of the sketch to be run with the IDE when a "Run" key is pressed.

## Background
I'm a Processing user since 2010 and retired software engineer who likes to code.
To learn more about the AI and machine learning revolution going on now, I created here a Processing sketch code assistant chatbot using Java API calls to OpenAI.org. 
My chatbot application could be modified for other chatbot application uses.
Only a small number of the API calls are invoked.

## Usage
I found that a code assistant is helpful to learn about programming and to avoid some tedium and mistakes during the program development process.
You cannot trust the output response from the chatbot and have to read and understand the generated code. (Although it is often correct)

I find specific prompts are best to get good generated sketch code. And after a few prompts for requesting changes, I find it easier
to just make code changes myself. Or start a new chat to assist with another section of the code I am trying to build and
then integrate it into the final sketch I seek to write.

One time the Chatbot could not figure out how to generate code for a specific request. I solved this by
instructing the Chatbot to use a specific class or technique and it worked.

The advantage of this application is that it sets up a specific chat assistant. 
You can run the generated code directly with the IDE, rather than copying and pasting.

The OpenAI model used in the application by default is "gpt-4" and 
randomness in responses is limited by the temperature variable set to 0.

## Setup
The chatbot application runs on Windows 11 and Processing 4.2. 
The previous version of Processing IDE (3.5.4) fails to build the application for unknown reasons.

Install Processing IDE version 4.2 with Windows 64 bit. Note the folder location of the IDE processing.exe file.
Add processing.exe folder location to the Path in the Windows system environment settings.

### OpenAI Api Key
OPENAI_API_KEY is your paid OpenAI API account token stored in the environment variables for Windows 10/11.
Define your OpenAI API Key with variable name "OPENAI_API_KEY" in the Windows environment settings (search for environment).
Use the account token as the value of the variable.
Restart the IDE after adding or changing your environment variable.

### IDE Modes
Code can be run in the IDE for the following modes: Java, p5.js, and Python. Android mode is not available.
Make sure the modes you want to run with the generated code are included in the IDE under manage modes setup.

### IDE Libraries 
In the IDE enter menu: Sketch -> Import Library -> Manage Libraries... menu selection you can add libaries used by the application.

IDE Library requirements are:

1. G4P - A graphical user interface library that provides a set of 2D GUI controls and multiple window support.

2. Other - This is dependent on the generated code response from prompts requesting contributed libraries.
