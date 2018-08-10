#! /usr/bin/gawk -f

#
# Global variables:
# - Option: array of stack -> array contains options (each option is implement as stack)
#

function initScopePriority() {

    # Sectioning
    ScopePriority["block"         ] = 9
    ScopePriority["subsubsection" ] = 8
    ScopePriority["subsection"    ] = 7
    ScopePriority["section"       ] = 6
    ScopePriority["part"          ] = 5

    ScopePriority["cli"           ] = 4
    ScopePriority["file"          ] = 3
    ScopePriority["config"        ] = 2
    ScopePriority["default"       ] = 1
}

function initOptions(){

    # Global options
    addOption("title",  "title")
    addOption("date",   "\\today")
    addOption("author", "author")
    #TODO a colorscheme file is a file containing color options definitions
    #     these options have the same priority as the scope they are declared
    #addOption("colorscheme", "other")
    addOption("columns", 3)
    addOption("headerfooter", "TRUE")
    addOption("landscape", "FALSE")
    #addOption("logo", "example-image-a")

    # log
    # TODO use number instead ?
    addOption("debug", "info")

    # Colors 
    addOption("headbackground",  "Orange!60!white")
    addOption("footbackground",  "Orange!60!white")
    addOption("textcolor",       "NavyBlue!60!black")
    addOption("darkbackground",  "OrangeRed!70!white")
    addOption("lightbackground", "red!20!white")
    addOption("linkcolor",       "Blue")
    addOption("citecolor",       "LimeGreen")
    addOption("urlcolor",        "OrangeRed")
}


function defineOption(option, file){

    switch (option) {
        case "title"  : case "date"   : case "author" :
                defineNewCommandInFile("g" option, getOption(option))
            break
        case "headbackground"  : case "footbackground"  : case "textcolor"       :
        case "darkbackground"  : case "lightbackground" : case "linkcolor"       :
        case "citecolor"       : case "urlcolor"        :
                appendTo(definecolor(option, "xcolor", getOption(option)), file ? file : AuxFiles["colors"] )
            break
        default:
            break
    } 

}


function addOption(optionName, optionValue) {

    optionName = tolower(optionName)

    initEleAsArr(Option, optionName)
    initStack(Option[optionName])
    push(Option[optionName], optionValue, CurrentScope)
}

function parseGlobalOptions(str,
                            #########
                            i, declaration, value, splits) {

    # TODO: check argument type
    split(str, declaration, "[[:space:]]*=[[:space:]]*", splits);
    len = length(declaration)
    for (i = 2; i <= len; i++) {
        value = value declaration[i] splits[i]
    }
    addOption(declaration[1], value)
}

function getOption(optionName){
    return getTopValue(Option[optionName])
}

function getDefaultOption(optionName) {
    return Option[optionName][1]["default"]
}

function updateOptions(    optionName) {
    for (optionName in Option) {
        while (!isEmpty(Option[optionName]) && 
            scope2priority("part") <= scope2priority(CurrentScope) && 
            scope2priority(getTopKey(Option[optionName])) >= scope2priority(CurrentScope)) {
                pop(Option[optionName])
        }
    }
}

#TODO global -> file
#TODO add config
function scope2priority(scope) {
    return ScopePriority[scope]
}

function priority2scope(priority) {
    return belongsTo(priority, ScopePriority)
}
