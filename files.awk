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

function writeMainTex(    content) {

    content = NULLSTR
    content = content input("preamble_packages.tex")  "\n"
    content = content input("preamble_commands.tex") "\n"
    content = content input("preamble_colors.tex") "\n"
    content = content input("preamble_def.tex") "\n"
    #content = content input("preamble_author.tex") "\n"
    content = content (evalBool(getOption("headerfooter")) ? input("preamble_header_foot.tex") : NULLSTR) "\n"
    content = content buildLaTeXEnv("document", \
                  buildLaTeXCmd("color", "textcolor") "\n" \
                  buildLaTeXCmd("raggedright") "\n" \
                  buildLaTeXCmd("raggedcolumns") "\n" \
                  buildLaTeXCmd("footnotesize") "\n" \
                  (getOption("columns") <= 1 ? input("content.tex") "\n" :  \
                      buildLaTeXEnv("multicols*", input("content.tex") "\n", getOption("columns"))) \
             )
    writeTo(content, Files["output"]["dir"] "/main.tex")
}


