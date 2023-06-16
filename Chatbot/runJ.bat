rem requires java jdk tools
rem %1 is path to working save file directory 
rem %2 is name of class
rem processing core library found at C:\Users\andym\Tools\processing-4.2\core\library\core.jar
javac -cp C:\Users\andym\Tools\processing-4.2\core\library\core.jar  %1\%2.java
java -cp .;%1;C:\Users\andym\Tools\processing-4.2\core\library\core.jar %2
rem pause