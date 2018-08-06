#! /usr/bin/gawk -f 

#
# Global variables:
# - TRUE, FALSE: number -> boolean constant
#

###
### Init functions
###

function initConst() {
    TRUE    = 1
    FALSE   = 0
}

###
### Utils functions
###

function isNum(string) {
    return typeof(string) == "number"
}

# Used to test if parameter is given
function isNotDefined(obj){
    return length(obj) == 0
}

# Return the HEAD revision if the current directory is a git repo;
# Otherwise return a null string.
function getGitHead(    line, group) {
    if (fileExists(".git/HEAD")) {
        getline line < ".git/HEAD"
        match(line, /^ref: (.*)$/, group)
        if (fileExists(".git/" group[1])) {
            getline line < (".git/" group[1])
            return substr(line, 1, 7)
        } else
            return NULLSTR
    } else
        return NULLSTR
}

function evalBool(obj) {
    if (isNum(obj)) return obj
    if (obj == "0" || tolower(obj) ~ /^f(alse)?$/) {
        return 0
    } else 
        return 1
}

function getTerminalWidth() {
    return getOutput("tput cols") + 0
}
