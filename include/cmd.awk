#! /usr/bin/gawk -f

#TODO: rename to eval.awk

#
# Global variables:
# - CmdRegex: array -> Optime command regex


###
### Init functions
###

#TODO: move to parser.awk
function initCmd() {
    #CmdRegex                         = "@.*(\\[.*\\])?\\(.*\\)"

    # Text related commands
    CmdRegex["Link"]        = "(l|link)"
    CmdRegex["Code"]        = "code"
    CmdRegex["Color"]       = "c(o(l(o(r?)?)?)?)?"
    CmdRegex["Fontawesome"] = "(font-awesome|fa)"
    CmdRegex["Keys"]        = "(keys?|k)"
    CmdRegex["Menus"]       = "(menus?|m)"

    # Action commands : cmd string don't remained
    CmdRegex["Image"]       = "(image|img)"
    CmdRegex["Include"]     = "(include|inc)"
    #CmdRegex["Load"]        = "(load|l)"
    CmdRegex["Definecolor"] = "(definecolor|defc)"
    CmdRegex["Option"]      = "(option|opt)"
}

###
### Eval functions
###

function escapeAmpersand(regex) {
     gsub(/&/, "\\\\&", regex) 
     return regex
}

# Evaluate all commands of a string 
function evalLine(string,    cmdInfo) {
    while (parseCommand(string, cmdInfo)){
        string = replaceSubStringBy(string, cmdInfo["start"], cmdInfo["end"], SUBSEP)
        sub(SUBSEP, escapeAmpersand(evalCmd(cmdInfo)), string)
    }
    return string
}

# Evaluate a command (generalisation)
function evalCmd(cmdArray,
                 #########
                 cmdType, funcName) {
    cmdType = matchesAny(cmdArray["cmd"], CmdRegex)
    if (!cmdType){
        warn("Command \"" cmdArray["cmd"] "\" is not available.")
        return cmdArray["contents"]
    } else {
        funcName = "eval" cmdType
        return @funcName(cmdArray)
    }
    
}

# Evaluate code command
function evalCode(cmdArray) {
    PythonTexUsed = TRUE
    if (!PythonTex3) {
        error("PythonTex3 is not installed.")
        return NULLSTR
    } else {
        return buildLaTeXCmd("pygment", cmdArray["contents"], (isPygmentsLexer(cmdArray["opt"]) ? cmdArray["opt"] : "text"))
    }
}

# Evaluate color command
function evalColor(cmdArray) {
    return colorize(escapeLaTeX(cmdArray["contents"]), cmdArray["opt"])
}

# Evaluate option command
function evalOption(cmdArray,    option){
     addOption(cmdArray["opt"], cmdArray["contents"])
}

# Evaluate color definition command
function evalDefinecolor(cmdArray,    model) {

    if (i = belongsTo(cmdArray["opt"], AvailableColors)){
        warn("Color \"" cmdArray["opt"] "\" is already defined by " (i > TotalDefaultColors ? "yourself" : "LaTeX")   ". This definition is ignored.") 
        return NULLSTR
    }

    model = matchesAny(cmdArray["contents"], LaTeXColorModel)

    if (!model){
        warn("Color definition \"" cmdArray["opt"] "\" don't match any model specification syntax. This definition is ignored.") 
        return NULLSTR
    }

    trace("Color \"" cmdArray["opt"] "\" is defined as " cmdArray["contents"] " in model \"" model "\"." ) 

    appendTo(definecolor(cmdArray["opt"], model, cmdArray["contents"]),  AuxFiles["colors"])
    appendToArray(cmdArray["opt"], AvailableColors)
    
    return NULLSTR
}

# Evaluate link command
# TODO: add unit test with url contains parentheses
function evalLink(cmdArray,
                  ########
                  unixPathRegex, urlRegex) {
    #TODO: add window path regex
    unixPathRegex = "^(([^\\/]+)?(\\/[^\\/]+)*\\/?)$"
    urlRegex = "^(https?:\\/\\/(www\\.)?)?[-a-zA-Z0-9@:%\\._\\+~#=]{2,256}\\.[a-z]{2,6}([-a-zA-Z0-9@:%_\\+\\.\\(\\)~#?&//=]*)$"
    if (cmdArray["contents"] ~ urlRegex){
        return href(underline(escapeLaTeX(cmdArray["opt"])), cmdArray["contents"])
    } else if (cmdArray["contents"] ~ unixPathRegex) {
        return href(underline(escapeLaTeX(cmdArray["opt"])), "run:" cmdArray["contents"])
    } else {
        warn("\"" cmdArray["contents"] "\" is not a correct url/path" )
        return cmdArray["contents"]
    }
}

# Evaluate font awesome command
function evalFontawesome(cmdArray) {
    return buildFASymbol(cmdArray["contents"])
}

# Evaluate include command
function evalInclude(cmdArray) {
    if (fileExists(cmdArray["contents"])) {
        return readFrom(cmdArray["contents"])
    } else {
        warn("No such file or directory : "cmdArray["contents"])
        return NULLSTR
    }
}


#function evalImage(cmdArray) {
#    return buildLaTeXCmd(LaTeXCmd["graphic block"], cmdArray["content"]
#}

