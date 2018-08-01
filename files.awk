#! /usr/bin/gawk -f 

@include "io.awk"
@include "string.awk"
@include "array.awk"
@include "metainfo.awk"
@include "latex.awk"
@include "options.awk"
@include "pygments.awk"

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
    copyTo(Files["source"] "/templates/preamble_header_foot.tex", Files["output"]["dir"])
}

function writeMainTex(    array) {

    #TODO this is not quite elegant ...
    appendToArray("{type : command, name : input, content : preamble_packages.tex}", array)
    appendToArray("{type : command, name : input, content : preamble_commands.tex}", array)
    appendToArray("{type : command, name : input, content : preamble_colors.tex}", array)
    appendToArray("{type : command, name : input, content : preamble_def.tex}", array) 
    #appendToArray("{type : command, name : input, content : preamble_author.tex}", array) 

    #TODO header and footer in landscape mode
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

    writeTo( \
        "\\documentclass[10pt, a4paper]{article} \n" \
        buildNestedLaTeXEnv(array), Files["output"]["dir"] "/main.tex")
}

function writePreamblePackages(    array) {

    appendToArray("\\usepackage[dvipsnames]{xcolor}", array)
    appendToArray("\\usepackage{tikz}", array)
    appendToArray("\\usepackage{lscape}", array)
    appendToArray("\\usetikzlibrary{calc, matrix, fpu}", array)
    appendToArray("\\usepackage{pgf-pie}", array)
    appendToArray("\\usepackage[hypertexnames=true]{hyperref}", array)
    appendToArray("\\usepackage{caption}", array)
    appendToArray("\\usepackage{etoolbox}", array)
    appendToArray("\\usepackage{subcaption}", array)
    appendToArray("\\usepackage[all]{hypcap}", array)
    appendToArray("\\usepackage{fancyhdr}", array)
    appendToArray("\\usepackage{multicol}", array)
    appendToArray("\\usepackage{tabularx}", array)
    appendToArray("\\usepackage{tabulary}", array)
    appendToArray("\\usepackage{soulutf8}", array)
    appendToArray("\\usepackage{hhline}", array)
    appendToArray("\\usepackage{graphicx}", array)
    appendToArray("\\usepackage{colortbl}", array)
    appendToArray("\\usepackage{setspace}", array)
    appendToArray("\\usepackage{lastpage}", array)
    appendToArray("\\usepackage{seqsplit}", array)
    appendToArray("\\usepackage{amsmath}", array)
    appendToArray("\\usepackage{amsfonts}", array)
    appendToArray("\\usepackage[BoldFont, SlantFont]{xeCJK}", array)
    appendToArray("\\setCJKmainfont{HanaMinA}", array)
    appendToArray("\\usepackage{sectsty}", array)

    if (Pygments)
        appendToArray("\\usepackage{minted}", array)

    appendToArray("\\usepackage{fontspec}", array)
    appendToArray("\\usepackage{fontawesome}", array)
    appendToArray("\\usepackage{xparse}", array)
    appendToArray("\\usepackage{verbatim}", array)
    appendToArray("\\usepackage[most]{tcolorbox}", array)
    appendToArray("\\tcbuselibrary{" (Pygments ? "minted," : NULLSTR) "skins, breakable}", array)
    
    writeTo(join(array, "\n"), Files["output"]["dir"] "/preamble_packages.tex")
}


