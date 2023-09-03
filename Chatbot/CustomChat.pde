/*
Creating a sketch in Processing, a flexible software sketchbook and a language for learning how to code within the context of the visual arts, 
involves several steps. Here's a general outline:
1. **Conceptualize**: Come up with an idea for what you want your sketch to do. 
This could be anything from a simple animation to a complex interactive piece.
2. **Design**: Sketch out your idea on paper or digitally. 
This will help you visualize what you want to create and plan out the different elements.
3. **Setup**: Open Processing and start a new sketch. 
The setup() function is the first function in a Processing sketch, 
and it's used to define initial environment properties such as screen size and background color.
4. **Coding**: Write the code for your sketch. 
This will typically involve defining variables, creating functions, and using loops and conditionals. The draw() function is used to execute the code. 
5. **Debugging**: As you write your code, you'll likely encounter errors or bugs. 
Debugging involves finding and fixing these issues. Processing's error console can be very helpful in this step.
6. **Testing**: Once you've written your code, run your sketch to see if it works as expected. 
If not, you'll need to go back to the debugging step.
7. **Refining**: After your sketch is working, you might want to refine it by adding more features, improving the visuals, or optimizing the code.
8. **Sharing**: Once you're happy with your sketch, you can share it with others. 
Processing allows you to export your sketch as a standalone application, or you can share the code directly.
Remember, the complexity of these steps can vary greatly depending on the complexity of the sketch you're creating.


Sure, here are some prompts that could help you create a sketch in Processing:
1. "What is the concept or idea for your sketch? Can you describe it in detail?"
2. "Have you designed a rough sketch of your idea on paper or digitally? If not, would you like some tips on how to do this?"
3. "Let's start setting up your sketch in Processing. Have you defined the initial environment properties such as screen size and background color?"
4. "Now, let's move on to coding your sketch. Do you need help with defining variables, creating functions, or using loops and conditionals?"
5. "Are you encountering any errors or bugs in your code? I can help you with debugging."
6. "Have you tested your sketch? Does it work as expected or are there any issues?"
7. "Would you like to refine your sketch by adding more features, improving the visuals, or optimizing the code?"
8. "Are you ready to share your sketch? Processing allows you to export your sketch as a standalone application, or you can share the code directly. Which option do you prefer?"
*/

/*
prompt buttons to include in system prompt
*/

String customChatFilePath;
String chatName;

/** 
 * read custom chat text file
 */
String[] readCustomChatFile(String path) {
  String[] str = loadStrings(path);
  return str;
}
  
