#! /usr/bin/gawk -f

#
# Global variables:
# - AuxFiles: array -> auxiliary files path
# - ExitCode: number -> 0, exit without problem
# - CurrentScope: string -> current scope
# - InfoOnly: string -> info only session
# - FileName: string -> current file's name
#



# TODO delete array to prevent exists values
function initMain() {

    BlocksNB = 0
    #CurrentScope = "default"

    # Dependencies
    initSageMath()
    initPygments()

    if (Pygments) {
        getAvailableStyle(PygmentsStyles)
        getAvailableLexers(PygmentsLexers)
    }

    # Boolean, String and I/O constants
    initConst()
    initStrConst()
    initIOConst()


    #log.awk
    initAnsiCode()
    initLogLevelPriority()

    # blocks.awk
    initSectionsName()
    initBlocksName()
    initBlocksColumns()
    initBlocksIcon()

    # cmd.awk
    initCmd()

    # colors.awk
    initAvailableColors()
    TotalDefaultColors = length(AvailableColors)

    # latex.awk
    initLaTeXCmd()
    initLaTeXConstant()
    initLaTeXColorModel()
    initLaTeXDefinedCmd()
    initLaTeXMathSep()

    # options.awk
    initOptions()

    # main.awk
    initAuxFiles()
}

function initSageMath() {
    SageMath = isExistProgram("sage") ? getOutput("sage -v") : NULLSTR
}

function initAuxFiles() {

    AuxFiles["dir"]     = getFileDir(getOption("input")) "/." Command "." FileName "/"
    AuxFiles["colors"]  = AuxFiles["dir"] "preamble_colors.tex"
    AuxFiles["def"]     = AuxFiles["dir"] "preamble_def.tex"
    AuxFiles["content"] = AuxFiles["dir"] "content.tex"
    AuxFiles["main"]    = AuxFiles["dir"] "main.tex"
    AuxFiles["pdf"]     = AuxFiles["dir"] "main.pdf"

}


BEGIN {
    # TODO put these lines into an init function
    PREC="oct"
    CONVFMT="%.17g"
    FS = "\n"
    RS = ""

    ExitCode = 0

    pos = 0
    noargc = 0

    CurrentScope = "cli"
    while(ARGV[++pos]) {

        ## Information options

        # -V, -version
        match(ARGV[pos], /^--?(V|vers(i(on?)?)?)$/)
        if (RSTART) {
            InfoOnly = "version"
            continue
        }

        # -H, -help
        match(ARGV[pos], /^--?(H|h(e(lp?)?)?)$/)
        if (RSTART) {
            InfoOnly = "help"
            continue
        }

        # -U, -upgrade
        match(ARGV[pos], /^--?(U|upgrade)$/)
        if (RSTART) {
            InfoOnly = "upgrade"
            continue
        }

        # non-option argument
        noargv[noargc++] = ARGV[pos]

        ## I/O options

        # -i FILENAME, --input FILENAME, -i=FILENAME
        match(ARGV[pos], /^--?i(n(p(ut?)?)?)?(=(.*)?)?$/, group)
        if (RSTART) {
            # TODO Stack up input filename for future dev (merge multiple input)
            # Only use the top filename as input
            if (group[4] && group[5]) {
                addOption("input", group[5])
            } else {
                addOption("input", ARGV[++pos])
            }
            continue
        }

        # -o FILENAME, -output FILENAME
        match(ARGV[pos], /^--?o(u(t(p(ut?)?)?)?)?(=(.*)?)?$/, group)
        if (RSTART) {
            # TODO Stack up output filename for future dev (merge multiple input)
            # Only use the top filename as output
            if (group[5] && group[6]) {
                addOption("output", group[6])
            } else {
                addOption("output", ARGV[++pos])
            }
            continue
        }

    }

    # Handle options

    ## Info only session

    switch (InfoOnly) {
        case "version":
            print getVersion()
            exit ExitCode
        case "help":
            print getHelp()
            exit ExitCode
        case "upgrade":
            upgrade()
            exit ExitCode
    }

    ## I/O session

    FileName = getFilename(getOption("input"))

    # TODO put these lines into a setup function
    initMain()
    copyTemplates()
    cleanContentsOf(AuxFiles["content"])
    writePreamblePackages()

    #TODO should be call in the end
    optimeMain()

}


# TODO should call readFrom
FNR == 1 {

    #TODO define before cli option parsing
    # cli option > file option > config option > default option

    cleanContentsOf(AuxFiles["def"])
    cleanContentsOf(AuxFiles["colors"])
    CurrentScope = "global"
    for (i = 1; i <= NF; ++i) {
        parseGlobalOptions($i);
    }

    for (i in Option) {
        defineOption(i)
    }
    # write main.tex after read user's options
    writeMainTex()

}

$0 ~ /^\s*[^#].*:.*$/ {
    writeBlock($0)
}

function optimeMain(    i) {
    # TODO: binary search debug
    for (i = 1; i <= length(ParsedBlocks); i++) {
        appendTo(buildLaTeXCmd("input", FileName ".colors." i ".tex"), AuxFiles["content"])
        appendTo(buildLaTeXCmd("input", ParsedBlocks[i]["filename"]), AuxFiles["content"])
    }

    debug("Start of compilation.")
    compileResult = compile()
    if(!compileResult){
        error("Compilation failed.")
        linearLaTeXDebug()
        exit(-1)
    } else {
        info("Compilation succeeded. " ansi("bold", getOption("output")) " is generated.")
        copyTo(AuxFiles["pdf"], getOption("output"))
    }
}

