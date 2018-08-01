#! /usr/bin/gawk -f

@include "commons.awk"
@include "string.awk"
@include "array.awk"

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
    return ENVIRON["PWD"] ? ENVIRON["PWD"] : getOutput("pwd")
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
    close(command)
    return content
}


# Return 1 if program `prg` exists in path; 0 otherwise
# `command` is standarized by POSIX (use it instead of `where`)
function isExistProgram(prg) {
    return !system("command -v " prg SUPOUT)
}

# Remove directory
function removeDir(dirPath) {
    system("rm -rf " dirPath)
}

# Create temporary directory
function createTempDir() {
    return getOutput("mktemp -d")
}

###
### Path related functions
###

# Get filename of a file (i.e. without extension)
function getFilename(path,    pathArr, group) {
    split(path, pathArr, "/")
    split(pathArr[length(pathArr)], group, ".")
    return join(group, ".", 1, length(group) - 1)
}


# get absolute path of file/dir
#     path    : file/dir path
#     dotPath : string which expands "."
function getAbsolutePath(path, dotPath,
                         ##############
                         charArr) {

    if (isNotDefined(dotPath)) {
        dotPath = getCurrentPath()
    }

    explode(path, charArr) 

    if (charArr[1] == "/") {
        return path
    } else if (charArr[2] != "/") {
        return dotPath "/" path
    } else {
        if (charArr[1] == "~") {
            return ENVIRON["HOME"] join(charArr, NULLSTR, 2)
        } else if (charArr[1] == ".") {
            return dotPath join(charArr, NULLSTR, 2)
        }
   }
}

# get absolute path relatively of a file
#     filepath : file path
#     path     : path relative of file
function getAbsolutePathInFile(filepath, path, 
                               ###############
                               fileDir) {

    fileDir = getFileDir(filepath)
    return getAbsolutePath(path, fileDir)
}

function getFileDir(path,     absPath, absPathArr) {
    absPath = getAbsolutePath(path)
    split(absPath, absPathArr, "/")
    return join(absPathArr, "/", 1, length(absPathArr) - 1)
}

