#! /usr/bin/gawk -f

@include "commons.awk"
@include "string.awk"

BEGIN {
    initIOConst()
}

###
### Init functions
###

function initIOConst() {

    STDIN  = "/dev/stdin"
    STDOUT = "/dev/stdout"
    STDERR = "/dev/stderr"

    SUPOUT = " > /dev/null "  # suppress output
    SUPERR = " 2> /dev/null " # suppress error
    PIPE = " | "

}

###
### I/O functions
###

# Read from a file and return its content.
function readFrom(file,    line, text) {
    if (isNotDefined(file)) file = STDIN
    text = NULLSTR
    while (getline line < file)
        text = (text ? text "\n" : NULLSTR) line
    return text
}

# Write text to file.
function writeTo(text, file) {
    if (isNotDefined(file)) file = STDOUT
    # use shell ">", note that awk's ">" behave differently
    system("printf " parameterize(text) "\\\\n" " > " parameterize(file))
}

# Append text to file.
function appendTo(text, file) {
    if (isNotDefined(file)) file = STDOUT
    # use shell ">>", note that awk's ">>" behave differently
    system("printf " parameterize(text) "\\\\n" " >> " parameterize(file))
}

# Create directory if it isn't exists
function createDir(dirName){
    return system("mkdir -p " parameterize(dirName) SUPERR)
}

# Create directory if it isn't exists
function copyTo(file1, file2){
    return system("cp " parameterize(file1) " " parameterize(file2) )
}

# Clean up the content of file
function cleanContentsOf(file) {
    return writeTo("", file) 
}

# Get the path where script was executed
function getCurrentPath(){
    return getOutput("pwd")
}

# Return non-zero if file exists; otherwise return 0.
function fileExists(file) {
    return !system("test -f " parameterize(file))
}

# Return the output of a command.
function getOutput(command,    content, line) {
    content = NULLSTR
    while ((command |& getline line) > 0)
        content = (content ? content "\n" : NULLSTR) line
    return content
}

# Get filename of a file
function getFilename(string) {
    basename = getOutput("basename " string)
    n = split(basename, group, ".")
    return (n == 1 ? basename : join(group, ".", 1, n - 1))
}

# Remove directory
function removeDir(dir) {
    system("rm -rf " dir)
}
