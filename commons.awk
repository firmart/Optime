#! /usr/bin/gawk -f 

BEGIN {
    initConst()
}

###
### Init functions
###

function initConst() {
    NULLSTR = ""
    TRUE    = 1
    FALSE   = 0

    STDIN   = "/dev/stdin"
    STDOUT  = "/dev/stdout"
    STDERR  = "/dev/stderr"

    SUPOUT  = " > /dev/null "  # suppress output
    SUPERR  = " 2> /dev/null " # suppress error
    PIPE    = " | "
}

###
### Utils functions
###

# Return the pattern subscript if the string matches exactly this pattern
# Otherwise, return a null string.
function matchesAny(string, patterns,
                    ####
                    i) {
    for (i in patterns)
        if (string ~ "^" patterns[i] "$") return i
    return NULLSTR
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

