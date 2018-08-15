#! /usr/bin/gawk -f 

# for chdir
@load "filefuncs"

#
# Global variables:
# - LaTeXColorModel: array -> latex color model regex
# - LaTeXDefinedCmd: array -> user defined command
#

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

function addVspace(len){
    return buildLaTeXCmd("par") buildLaTeXCmd("addvspace", len)
}

function hspace(len){
    return buildLaTeXCmd("hspace*", len)
}

function rule(x, y){
    return buildLaTeXCmd("rule", y, x)
}

function colorize(text, color) {

    if (isNotDefined(color))
        color = "textcolor"

    return buildLaTeXCmd("textcolor", text, color)
}

function bold(text) {
    return buildLaTeXCmd("textbf", text)
}

function italic(text) {
    return buildLaTeXCmd("textit", text)
}

function teletype(text) {
    return buildLaTeXCmd("texttt", text)
}

function underline(text) {
    return buildLaTeXCmd("ul", text)
}

function href(text, url) {
    return buildLaTeXCmd("href", text, url)
}


function setRowColor(color) {
    return buildLaTeXCmd("SetRowColor", color)
}


function buildColouredMulticolumn(string, columns){
    return buildLaTeXCmd("colouredMulticolumn", string, columns)   
}

function buildNoteLine (string, columns,
                        ###############
                        contents) {
    sub(/^\s*>\s*/, "", string)
    contents = buildFASymbol("StickyNoteO") "~" string
    return setRowColor("lightbackground") buildColouredMulticolumn(contents , columns) "\\tabularnewline" "\n"
}

function setTitle(title, blockType){
    # TODO:contrast of title above darkbackground
    return setRowColor("darkbackground") \
        buildColouredMulticolumn(BlocksIcon[blockType] "~" bold(colorize(title, "white")), BlocksColumns[blockType]) \
        "\\tabularnewline" "\n"
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
        return buildLaTeXCmd("colorlet", colorSpec, colorName)
    } else {
        options[1] = colorName
        options[2] = model
        return buildLaTeXCmd("definecolor", colorSpec, options)
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
    return "\\" "newcommand"  nameString  numString defString
}

function defineNewCommandInFile(name, definition, num) {
    if (!isDefinedLaTeXCmd(name)) {
        appendTo(defineNewCommand(name, definition, num), AuxFiles["def"])
    } else {
       # warn("Command \"" name "\" is already defined")
    }
}

function input(filename) {
    return buildLaTeXCmd("input", filename)
}

function buildLaTeXEnvBeginTag(envName, options, defaults,     i, optStr, defaultStr) {

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
   return "\\begin{" envName "}" defaultStr optStr "\n"
}

function buildLaTeXEnvEndTag(envName) {
    return "\\end{" envName "}" "\n"
}

function buildLaTeXEnv(envName, contents, options, defaults,
                       ######################################
                       beginTag, endTag) {

    beginTag = buildLaTeXEnvBeginTag(envName, options, defaults)
    endTag = buildLaTeXEnvEndTag(envName)
    return beginTag contents endTag
}

function buildLaTeXCmd(cmdName, contents, options, defaults,
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

    return  "\\" cmdName defaultStr optStr "{" contents "}"  
}


function compile(key, program,    i, currentDir, retValue){
    # compile three times
    # move to LaTeX dir to let pygmentize create 

    if (isNotDefined(program)) {
        program = "xelatex"
    }

    if (isNotDefined(key)) {
        key = "normal"
    }

    currentDir = getCurrentPath()
    retValue = TRUE

    chdir(AuxFiles["dir"])
    if (key == "normal") {
        if (system(program " -halt-on-error -shell-escape main.tex" SUPOUT)) {
            error(program " failed.")
            retValue = FALSE
        }
    } else if (key == "sage") {
        if (system("sage" " main.sagetex.sage" SUPOUT SUPERR)) {
            warn("Sage failed : \n")
            warn(getOutput("sage" " main.sagetex.sage"))
            retValue = TRUE
        }
    } else if (key == "pythontex") {
        if (system("pythontex3" " main.tex" SUPOUT)) {
            warn("Pythontex failed : \n")
            warn(getOutput("pythontex3" " main.tex"))
            retValue TRUE
        }
    }

    chdir(currentDir)
    return retValue
}

function linearLaTeXDebug() {

    debug("Start linear debug.")
    cleanContentsOf(AuxFiles["content"])

    if(!compile()){
        error("Unknown LaTeX error, please report.")
        exit -1
    }
    
    for (i = 1; i <= length(ParsedBlocks); i++){
        
        writeTo(input(ParsedBlocks[i]["filename"]),  AuxFiles["content"])

        if(!compile()) {
            error("Block " i  " contains syntax error :")
            error("Block type : " BlocksName[ParsedBlocks[i]["type"]] )
            error("Block title : " ParsedBlocks[i]["title"] )
            break
        }
    }
}

function isDefinedLaTeXCmd(cmdName){
    return belongsTo(cmdName, LaTeXDefinedCmd)
}

function buildNestedLaTeXEnv(latexArr,   i, tokens, ast,  mAst, stack, type, name, NLStr, endContent) {

    initStack(stack)
    for (i in latexArr) {

        delete tokens; delete ast; delete mAst
        tokenize(tokens, latexArr[i]) 
        parseJson(ast, tokens) 
        pseudoArrToMArr(ast, mAst)

        type = mAst[0]["type"]
        name = mAst[0]["name"]

        if (type == "environment") {
            NLStr = NLStr buildLaTeXEnvBeginTag(name, mAst[0]["options"], mAst[0]["defaults"])
            NLStr = NLStr mAst[0]["beginContent"] 
            push(stack, mAst[0]["endContent"], name)
        } else if (type == "command") {
            NLStr = NLStr buildLaTeXCmd(name, mAst[0]["content"], mAst[0]["options"], mAst[0]["defaults"]) "\n"
        }
    }

    while(!isEmpty(stack)) {
        name = getTopKey(stack)
        endContent = getTopValue(stack)
        pop(stack)
        NLStr = NLStr endContent buildLaTeXEnvEndTag(name)
    }

    return NLStr
}

# Let \pygment work with # and % in tabularx environment.
# See https://tex.stackexchange.com/a/445685/125774
function escapeSpecialCatCode(block) {
    return "{\\catcode`\\#=12 \\catcode`\\%=12\n" block "\n}"
}
