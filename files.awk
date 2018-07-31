#! /usr/bin/gawk -f 

@include "io.awk"
@include "string.awk"
@include "array.awk"
@include "metainfo.awk"
@include "latex.awk"
@include "options.awk"

BEGIN {
    initFiles()
}

###
### Init functions
###

function initFiles() {

    Files["input"]             = getAbsolutePath(ARGV[1])
    Files["filename"]          = getFilename(Files["input"])
    Files["base"]              = getFileDir(ARGV[1])
    Files["source"]            = "/opt/" Command

    Files["output"]["dir"]     = Files["base"] "/." Command "." Files["filename"] "/"
    Files["output"]["colors"]  = Files["output"]["dir"] "preamble_colors.tex"
    Files["output"]["def"]     = Files["output"]["dir"] "preamble_def.tex"
    Files["output"]["content"] = Files["output"]["dir"] "content.tex"
    Files["output"]["main"]    = Files["output"]["dir"] "main.tex"
    Files["output"]["pdf"]     = Files["output"]["dir"] "main.pdf"

}

###
### Utils functions
###

# Copy templates 
function copyTemplates(){
    createDir(Files["output"]["dir"])

    copyTo(Files["source"] "/templates/pgf-pie.sty", Files["output"]["dir"])
    copyTo(Files["source"] "/templates/preamble_commands.tex", Files["output"]["dir"])
    copyTo(Files["source"] "/templates/preamble_packages.tex", Files["output"]["dir"])
    copyTo(Files["source"] "/templates/preamble_header_foot.tex", Files["output"]["dir"])
}

#TODO build nested latexEnv
function writeMainTex(    array) {

    initAsArr(array)
    appendToArray("{type : command, name : input, content : preamble_packages.tex}", array)
    appendToArray("{type : command, name : input, content : preamble_commands.tex}", array)
    appendToArray("{type : command, name : input, content : preamble_colors.tex}", array)
    appendToArray("{type : command, name : input, content : preamble_def.tex}", array) 
    #appendToArray("{type : command, name : input, content : preamble_author.tex}", array) 
    if(evalBool(getOption("headerfooter"))) 
        appendToArray("{type : command, name : input, content : preamble_header_foot.tex}", array)

    appendToArray("{type : environment, name : document}", array) 
    appendToArray("{type : command, name : color, content : textcolor}", array) 
    appendToArray("{type : command, name : raggedright}", array) 
    appendToArray("{type : command, name : raggedcolumns}", array) 
    appendToArray("{type : command, name : footnotesize}", array) 

    if (evalBool(getOption("landscape"))) {
        appendToArray("{type : environment, name : landscape }" , array) 
    }

    if (getOption("columns") > 1) {
        appendToArray("{type : environment, name : multicols*, options : " getOption("columns") "}" , array) 
    }
    appendToArray("{type : command, name : input, content : content.tex}", array) 

    writeTo(buildNestedLaTeXEnv(array), Files["output"]["dir"] "/main.tex")
}


