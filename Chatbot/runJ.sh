#!/bin/bash

# Require Processing IDE libraries and Java JDK tools

# $1 is the path to the sketch directory and may double as the class name
# $2 (optional) is the name of the sketch java class name to compile and run

# PROCESSING_HOME should be set to the path of the Processing core library
export PROCESSING_HOME=~/Tools/processing-4.3
# JAVA_HOME is included in Processing IDE
export JAVA_HOME=~/Tools/processing-4.3/java/bin

class_name="${2:-$1}"  # Use $1 if $2 is not provided

$JAVA_HOME/javac -cp "$PROCESSING_HOME/core/library/core.jar" "$1/$class_name.java" 2> $1/compilation_errors.log
$JAVA_HOME/java -cp .:"$1":"$PROCESSING_HOME/core/library/core.jar" $class_name 2> $1/runtime_errors.log

# Windows bat file:
# rem requires java jdk tools
# rem %1 is path to working save file directory 
# rem %2 is name of class
# rem processing core library found at PROCESSING_HOME\core\library\core.jar
# javac -cp %PROCESSING_HOME%\core\library\core.jar  %1\%2.java
# java -cp .;%1;%PROCESSING_HOME%\core\library\core.jar %2
# rem pause
