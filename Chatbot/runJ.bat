rem requires java jdk tools
rem %1 is path to working save file directory 
rem %2 is name of class
rem processing core library found at PROCESSING_HOME\core\library\core.jar
javac -cp %PROCESSING_HOME%\core\library\core.jar  %1\%2.java
java -cp .;%1;%PROCESSING_HOME%\core\library\core.jar %2
rem pause