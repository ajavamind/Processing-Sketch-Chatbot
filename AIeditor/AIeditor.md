# AI Editor
**AI Editor** is a multi-file editing tool that leverages OpenAI LLM API services to edit, modify, convert, or refactor code and text based on user-defined prompts.
The tool is implemented as a Processing sketch in Java, and can be run as a standalone command-line application by including a `main()` method. It reads the contents of a text file, sends them along with a prompt to a large language model (LLM) via the OpenAI API, and saves the response as a new file with the same name in the specified output directory.
---
## OpenAI API Support
AI Editor has been tested with:
- **OpenAI GPT-4.1** via the OpenAI API
- **IBM Granite 3.3 (2B)** model running locally on a networked Linux computer using [llamafile](https://github.com/Mozilla-Ocho/llamafile)

The application is flexible and can be adapted to work with other models, input/output folders, and prompt files as needed. Development and testing are performed using the [Processing IDE](https://processing.org/download) (version 4.3.4) on a Windows 11 PC. The application has not been tried on Linux or iOS. It cannot work on Android until the jvm-openai library replaces HTTP services with Okhttp3.

All required JAR files for API calls are included in the `code` folder. These are sourced from [StefanBratanov/jvm-openai](https://github.com/StefanBratanov/jvm-openai).  
A fork of this repository is maintained at [ajavamind/jvm-openai](https://github.com/ajavamind/jvm-openai), which includes updates for the latest OpenAI image API and additional `build.gradle` tasks to assist with examples and assembling the necessary JAR libraries for Processing.
---
## Parameters
The AI Editor application requires **three** positional command-line parameters:
1. **Prompt file path**  
   Path to the prompt text file. The application reads prompt files from the `data` folder (the standard Processing sketch folder for storing resources).
2. **Input folder or file path**  
   Path to the input folder or a specific input file.  
   - If a folder path is specified, all files in the folder will be processed.
   - If a specific file is specified, only that file will be processed.
3. **Output folder path**  
   Path to the output folder where the edited files will be saved.  
   - Output files retain the same name as the original input files.
   - If a file with the same name already exists in the output folder, it will be skipped to prevent overwriting.
---
## Example Usage
```sh
java -jar AIEditor.jar data/my_prompt.txt input_folder output_folder
```
---
## Notes
- The application is designed for flexibility and can be easily modified to support additional models or workflows.
- Ensure all required JAR dependencies for jvm-openai are present in the `code` folder for Processing compatibility.