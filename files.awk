#! /usr/bin/gawk -f

@include "string.awk"
@include "io.awk"

BEGIN {
    initFiles()
}

###
### Init functions
###

function initFiles(){
    Files["input"]    = parameterize(ARGV[1])
    Files["filename"] = getFilename(Files["input"])
    Files["base"]     = getCurrentPath()
    Files["source"]   = "/opt/optime"

    Files["output"]["dir"]     = Files["base"] "/" ".optime." Files["filename"] "/"
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
    copyTo(Files["source"] "/templates/main.tex", Files["output"]["dir"])
}



