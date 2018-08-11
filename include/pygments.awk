
#
# Global variables:
# - Pygments: string -> pygments version
# - PygmentsLexers: array -> list of pygmentize lexers
# - PygmentsStyles: array -> list of pygmentize code-highlighting styles
#

function initPygments() {
    Pygments = isExistProgram("pygmentize") ? getOutput("pygmentize -V") : NULLSTR
}

function getAvailableStyle(styleArr,
                           #########
                           lexers, lexersArr, j, line, str, tmpArr, i){
    # TODO translate this and add corresponding warning message
    # add a cmd option to show available PL
    lexers = getOutput("pygmentize -L styles") 
    split(lexers, lexersArr, "\n")
    j = 0
    for(line in lexersArr) {
        if (lexersArr[line] ~ /^\*/){
            str = substr(lexersArr[line], 3); 
            split(str, tmpArr, ", ")
            for(i in tmpArr) {
                gsub(":","",tmpArr[i]) 
                styleArr[++j] = tmpArr[i]
            }
        }
    }
}

function isPygmentsLexer(lexer) {
    return belongsTo(lexer, PygmentsLexers)
}

function getAvailableLexers(plArr,
                            ######
                            lexers, lexersArr, j, line, str, tmpArr, i){
    # TODO translate this and add corresponding warning message
    # add a cmd option to show available PL
    lexers = getOutput("pygmentize -L lexers") 
    split(lexers, lexersArr, "\n")
    j = 0
    for(line in lexersArr) {
        if (lexersArr[line] ~ /^\*/){
            str = substr(lexersArr[line], 3); 
            split(str, tmpArr, ", ")
            for(i in tmpArr) {
                gsub(":","",tmpArr[i]) 
                plArr[++j] = tmpArr[i]
            }
        }
    }
}

