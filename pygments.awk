
@include "commons.awk"

# TODO error if pygments isn't installed
# pip3 install pygments

BEGIN {
    getAvailableStyle(PygmentsStyles)
    getAvailableLexers(PygmentsLexers)
}

function getAvailableStyle(styleArr,
                           #########
                           lexers, lexersArr, j, line, str, tmpArr){
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

