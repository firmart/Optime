@include "string.awk"
@include "array.awk"
@include "log.awk"
@include "io.awk"

BEGIN {
    initOptions()
}

function initOptions(){


    # Global options
    addOption("title",  "title")
    addOption("date",   "\\today")
    addOption("author", "author")
    #addOption("colorscheme", "other")
    #addOption("columns", 3)
    #addOption("logo", "example-image-a")

    # log
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
                appendTo(definecolor(option, "xcolor", getOption(option)), file ? file : Files["output"]["colors"] )
            break
        default:
            break
    } 

}


function addOption(optionName, optionValue) {

    optionName = tolower(optionName)

    initEleAsArr(Option, optionName)
    initStack(Option[optionName])

    if (getTopKey(Option[optionName]) == NULLSTR){
        # new optionName, create stack
        # first given value is the default's one
        push(Option[optionName], optionValue, "default")
    } else {
        # existed option
        while (!isEmpty(Option[optionName]) && scope2priority(getTopKey(Option[optionName])) <= scope2priority(CurrentScope)) {
            pop(Option[optionName])
        }
        push(Option[optionName], optionValue, CurrentScope)
    }
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
        while (!isEmpty(Option[optionName]) && scope2priority(getTopKey(Option[optionName])) <= scope2priority(CurrentScope)) {
            pop(Option[optionName])
        }
    }
}

function printOptions(    optionName) {
    for(optionName in Option) {
       print "----Option[" optionName "]----"
       printStack(Option[optionName]) 
    }
}

function scope2priority(section) {

    scope["block"        ] = 1
    scope["subsubsection"] = 2
    scope["subsection"   ] = 3
    scope["section"      ] = 4
    scope["part"         ] = 5
    scope["default"      ] = 6

    return scope[section]
}

function priority2scope(priority) {

    scope[1] = "block"        
    scope[2] = "subsubsection"
    scope[3] = "subsection"   
    scope[4] = "section"      
    scope[5] = "part"         
    scope[6] = "default"       

    return scope[priority]
}
