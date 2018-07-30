#! /usr/bin/gawk -f 

@load "filefuncs"

@include "commons.awk"
@include "array.awk"
@include "colors.awk"

BEGIN {
    initLaTeXCmd()
    initLaTeXConstant()
    initLaTeXColorModel()
    initLaTeXDefinedCmd()
    initLaTeXMathSep()
}

###
### Init functions
###

function initLaTeXDefinedCmd(){
    initAsArr(LaTeXDefinedCmd)
}

# see https://en.wikibooks.org/wiki/LaTeX/Colors#Color_Models
function initLaTeXColorModel(){

    # regex : matched string is unspaced around it
    LaTeXColorModel["gray"  ] = "(0(\\.[0-9]{0,2})?|1(\\.0{0,2})?)"
    LaTeXColorModel["rgb"   ] = "((0(\\.[0-9]{0,2})?|1(\\.0{0,2})?)\\s*,\\s*){2}(0(\\.[0-9]{0,2})?|1(\\.0{0,2})?)"
    LaTeXColorModel["RGB"   ] = "(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-5][0-5])\\s*,\\s*){2}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-5][0-5])"
    LaTeXColorModel["HTML"  ] = "[0-9A-Fa-f]{6}"
    LaTeXColorModel["cmyk"  ] = "((0(\\.[0-9]{0,2})?|1(\\.0{0,2})?)\\s*,\\s*){3}(0(\\.[0-9]{0,2})?|1(\\.0{0,2})?)"
    LaTeXColorModel["xcolor"] = "([a-zA-Z][a-zA-Z0-9]{0,31})(\\s*!\\s*([0-9]|[1-9][0-9])\\s*!\\s*([a-zA-Z][a-zA-Z0-9]{0,31}))*(\\s*!\\s*([0-9]|[1-9][0-9]))?"
}

function initLaTeXConstant() {

    LaTeXConstant["tabular newline"   ] = "\\tn"
    LaTeXConstant["end line"          ] = "\\endlr"
    LaTeXConstant["unbreakable space" ] = "~"
}

function initLaTeXMathSep() {

    LaTeXMathSep[1] = "$"
    LaTeXMathSep[2] = "$$"
    LaTeXMathSep[3] = "\\["
    LaTeXMathSep[4] = "\\]"
}

function getLaTeXMateMathSep(mathSep) {
    ind = belongsTo(mathSep, LaTeXMathSep)
    if (ind == NULLSTR) return NULLSTR
    else if (ind == 3) return LaTeXMathSep[4]
    else if (ind == 4) return LaTeXMathSep[3]
    else return LaTeXMathSep[ind]
}

function laTeXMathSepMatch(lhs, rhs) {
     lindex = belongsTo(lhs, LaTeXMathSep)
     rindex = belongsTo(rhs, LaTeXMathSep)
     if (lindex == NULLSTR || rindex == NULLSTR) return FALSE
     else if (lindex == 3 && rindex == 4) return TRUE
     else if (lindex == rindex) return TRUE
     else return FALSE
}

function initLaTeXCmd() {

    # Font styles
    LaTeXCmd["default"]        = "textnormal"
    LaTeXCmd["emphasis"]       = "emph"
    LaTeXCmd["romant"]         = "textrm"
    LaTeXCmd["sans serif"]     = "textsf"
    LaTeXCmd["teletypefont"]   = "texttt"
    LaTeXCmd["upright"]        = "textup"
    LaTeXCmd["italic"]         = "textit"
    LaTeXCmd["slanted"]        = "textsl"
    LaTeXCmd["small capitals"] = "textsc"
    LaTeXCmd["upper case"]     = "uppercase"
    LaTeXCmd["bold"]           = "textbf"
    LaTeXCmd["medium"]         = "textmd"
    LaTeXCmd["light"]          = "textlf"
    LaTeXCmd["underline"]      = "ul"

    # Image
    LaTeXCmd["graphic"]      = "includegraphics"

    # Hyperlink
    LaTeXCmd["href"]         = "href"

    # Color
    LaTeXCmd["text color"]   = "textcolor"
    LaTeXCmd["define color"] = "definecolor"
    LaTeXCmd["color let"]    = "colorlet"

    # Definition
    LaTeXCmd["new cmd"]      = "newcommand"
    LaTeXCmd["new env"]      = "newenvironment"

    # Custom
    LaTeXCmd["row color"]     = "SetRowColor"

}

function addVspace(len){
    return buildLaTeXCmd("par") buildLaTeXCmd("addvspace", len)
}

function hspace(len){
    return buildLaTeXCmd("hspace*", len)
}

function rule(x, y){
    return buildLaTeXCmd("rule", y, x)
}

function colorize(text, 
                  color,
                  #######
                  options) {

    # TODO: default color is textcolor
    if (isNotDefined(color)){
        color = "textcolor"
    }

    return buildLaTeXCmd(LaTeXCmd["text color"], text, color)
}

function setRowColor(color) {
    return buildLaTeXCmd(LaTeXCmd["row color"], color)
}


function buildColouredMulticolumn(string, columns){
    return buildLaTeXCmd("colouredMulticolumn", string, columns)   
}

function buildNoteLine (string, columns,
                        ###############
                        contents) {
    sub(/^\s*>\s*/, "", string)
    contents = buildFASymbol("StickyNoteO") LaTeXConstant["unbreakable space"] string
    return setRowColor("lightbackground") buildColouredMulticolumn(contents , columns) LaTeXConstant["tabular newline"] "\n"
}

function setTitle(title, blockType){
    # TODO:contrast of title above darkbackground
    return setRowColor("darkbackground") \
        buildColouredMulticolumn(BlocksIcon[blockType] LaTeXConstant["unbreakable space"] fontStyle("bold", colorize(title, "white")), BlocksColumns[blockType]) \
        LaTeXConstant["tabular newline"] "\n"
}

function definecolor(colorName, 
                     model, 
                     colorSpec,
                     ##########
                     options) {

    if (!(model in LaTeXColorModel)) {
        warn("Model " model " is not available. Color definition \"" cmdArray["opt"] "\" is ignored.")
        return NULLSTR
    }


    if (model == "xcolor") {
        return buildLaTeXCmd(LaTeXCmd["color let"], colorSpec, colorName)
    } else {
        options[1] = colorName
        options[2] = model
        return buildLaTeXCmd(LaTeXCmd["define color"], colorSpec, options)
    }
}

function defineNewCommand(name, definition, num,
                          #####################
                          cmdName, numString, nameString, defString) {
    #TODO handle error : name shouldn't contain "/" etc.
    cmdName = name ~ /^\\/ ? substr(name, 2) : name
    if (belongsTo(cmdName, LaTeXDefinedCmd)) {
        warn("Command \"" cmdName "\" is already defined. This definition is ignored.") 
        return NULLSTR
    }
    appendToArray(cmdName, LaTeXDefinedCmd)
    numString = isNotDefined(num) ? NULLSTR : "[" num "]"
    nameString = "{"  "\\" cmdName "}"
    defString = "{" definition "}"
    return "\\" LaTeXCmd["new cmd"]  nameString  numString defString
}

function defineNewCommandInFile(name, definition, num) {
    if (!isDefinedLaTeXCmd(name)) {
        appendTo(defineNewCommand(name, definition, num), Files["output"]["def"])
    } else {
       # warn("Command \"" name "\" is already defined")
    }
}


function fontStyle(code, text) {
    return buildLaTeXCmd(LaTeXCmd[code], text)
}

function input(filename) {
    return buildLaTeXCmd("input", filename)
}

function buildLaTeXEnv(envName, contents, options, defaults,
                       ######################################
                       i, optStr, defaultStr) {

    if (isNotDefined(options)) {
        optStr = ""
    } else if (!isarray(options)) {
        optStr = "{" options "}"
    } else {
        for (i in options) {
            optStr = optStr "{" options[i] "}"
        }
    }

    if (isNotDefined(defaults)) {
        defaultStr = ""
    } else if (!isarray(defaults)) {
        defaultStr = "[" defaults "]"
    } else {
        for (i in defaults) {
            defaultStr = defaultStr "[" defaults[i] "]"
        }
    }

    envStr = "\\begin{" envName "}" defaultStr optStr "\n" contents "\\end{" envName "}" "\n"
    return envStr
}

function buildLaTeXCmd(cmdName,
                       contents,
                       options,
                       defaults,
                       #########
                       i, optStr) {

    if (isNotDefined(contents)) {
        return "\\" cmdName
    }

    if (isNotDefined(options)) {
        optStr = ""
    } else if (!isarray(options)) {
        optStr = "{" options "}"
    } else {
        for (i in options) {
            optStr = optStr "{" options[i] "}"
        }
    }

    if (isNotDefined(defaults)) {
        defaultStr = ""
    } else if (!isarray(defaults)) {
        defaultStr = "[" defaults "]"
    } else {
        for (i in defaults) {
            defaultStr = defaultStr "[" defaults[i] "]"
        }
    }

    cmdStr = "\\" cmdName defaultStr optStr "{" contents "}" 
    return cmdStr
}


function compile(program,    i){
    # compile three times
    # move to LaTeX dir to let pygmentize create 

    if (isNotDefined(program)) {
        program = "xelatex"
    }

    chdir(Files["output"]["dir"])
    debug("Compile " i " time(s).")
    if (system(program " -halt-on-error -shell-escape main.tex" SUPOUT   )) {
        return FALSE
    }
    chdir(Files["base"])
    return TRUE
}

function linearLaTeXDebug() {

    debug("Start linear debug.")
    cleanContentsOf(Files["output"]["content"])

    if(!compile()){
        error("Unknown LaTeX error, please report.")
        #TODO shouldn't exit here
        exit -1
    }
    
    for (i = 1; i <= length(ParsedBlocks); i++){
        
        writeTo(buildLaTeXCmd("input", ParsedBlocks[i]["filename"]),  Files["output"]["content"])

        if(!compile()){
            error("Block " i  " contains syntax error :")
            error("Block type : " BlocksName[ParsedBlocks[i]["type"]] )
            error("Block title : " ParsedBlocks[i]["title"] )
            break;
        }
    }
}

d = {type : command, option : [a, b, c], default : [a, b]}
evalDict(d, arr)
arr["type"] = "command"
arr["option"] = "[a, b, c]"
arr["default"] = "[a, b]"
function isDefinedLaTeXCmd(cmdName){
    return belongsTo(cmdName, LaTeXDefinedCmd)
}

function buildNestedLaTeXEnv(LaTeXArr) {
    
}
