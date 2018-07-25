#! /usr/bin/gawk -f



@include "files.awk"
@include "commons.awk"
@include "parser.awk"
@include "blocks.awk"
@include "io.awk"
@include "options.awk"


BEGIN {
    PREC="oct"
    CONVFMT="%.17g"
    FS = "\n"
    RS = ""

    copyTemplates()
    cleanContentsOf(Files["output"]["content"])
}


FNR == 1 {

    cleanContentsOf(Files["output"]["def"])
    cleanContentsOf(Files["output"]["colors"])
    for (i = 1; i <= NF; ++i) {
        parseGlobalOptions($i);
    }
    for (i in Option) {
        defineOption(i)
    }

}

$0 ~ /^\s*[^#].*:.*$/ {
    writeBlock($0)
}

END {

    # TODO: binary search debug
    for (z = 1; z <= length(ParsedBlocks); z++) {
        appendTo(buildLaTeXCmd("input", Files["filename"] ".colors." z ".tex"), Files["output"]["content"])
        appendTo(buildLaTeXCmd("input", ParsedBlocks[z]["filename"]), Files["output"]["content"])
    }

    debug("Start of compilation.")
    compileResult = compile()
    if(!compileResult){
        error("Compilation failed.")
        linearLaTeXDebug()
        exit(-1)
    } else {
        info("Compilation succeeded. " ansi("bold", Files["filename"] ".pdf") " is generated.")
    }
    copyTo(Files["output"]["pdf"], Files["filename"]".pdf")
}
