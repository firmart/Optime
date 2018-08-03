#! /usr/bin/gawk -f

#
# Global variables:
# - SageMath: string -> SageMath version
# - Platform: string -> Platform name
#


# Return version as a string.
function getVersion(    build, gitHead) {
    Platform = Platform ? Platform : getOutput("uname -s")
    if (ENVIRON["OPTIME_BUILD"])
        build = "-" ENVIRON["OPTIME_BUILD"]
    else {
        gitHead = getGitHead()
        build = gitHead ? "-git:" gitHead : ""
    }

    return ansi("bold", sprintf("%-22s%s%s\n\n", Name, Version, build))        \
        sprintf("%-22s%s\n", "platform", Platform)                             \
        sprintf("%-22s%s\n", "gawk (GNU Awk)", cmpVersion(PROCINFO["version"], "4.2") >= 0 ? ansi("green", PROCINFO["version"]) : (ansi("red", PROCINFO["version"] " (version >= 4.2 is required)" )))  \
        sprintf("%-22s%s\n", "XeLaTeX", isExistProgram("xelatex") ? ansi("green", "[OK]") : ansi("red", "[NONE]")) \
        sprintf("%-22s%s\n", "pygmentize", Pygments ? ansi("green", Pygments) : ansi("yellow", "[NONE]") " (recommended for code highlighting)")  \
        sprintf("%-22s%s\n", "SageMath", SageMath ? ansi("green", SageMath) : ansi("yellow", "[NONE]") " (recommended for maths and plotting)")  \
        sprintf("%-22s%s\n", "terminal type", ENVIRON["TERM"])                 \
        sprintf("%-22s%s\n", "init file", InitScript ? InitScript : "[NONE]")  \
        sprintf("\n%-22s%s", "Report bugs to:", "https://github.com/firmart/Optime/issues")
        #TODO languages + fonts for others languages
        #sprintf("%-22s%s\n", "home language", getOption("hl"))                                        \
        #sprintf("%-22s%s\n", "theme", getOption("theme"))                                             \
}

# Return  1 if the first version is newer than the second; 
#        -1 is the opposite case
#         0 otherwise
function cmpVersion(ver1, ver2,    i, group1, group2, len) {
    split(ver1, group1, ".")
    split(ver2, group2, ".")
    len = min(length(group1), length(group2))
    for (i = 1; i <= len; i++) {
        if (group1[i] + 0 > group2[i] + 0)
            return 1
        else if (group1[i] + 0 < group2[i] + 0)
            return -1
    }

    if (length(group1) > length(group2))
        return 1
    else if (length(group1) < length(group2))
        return -1
    else 
        return 0
}

function upgrade () {
    #TODO implement upgrade()
}

function getHelp() {
    #TODO implement getHelp()
}
