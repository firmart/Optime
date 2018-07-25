#! /usr/bin/gawk -f

@include "commons.awk"
@include "array.awk"
@include "string.awk"
@include "stack.awk"
@include "latex.awk"

function findFirstNonEscapedChar(string, char,
                                 ############
                                 str, isEscaped, start, n) {

    isEscaped = TRUE
    str = string
    while(isEscaped){
        start = index(str, char)
        if (start == 0) return 0
        else if (substr(str, start - 1, 1) == "\\") {
            str = substr(str, start + 1)
        } else {
            isEscaped = !isEscaped
        }
    }

    n = index(string, str)
    return n + start - 1
}

#TODO rewrite this function using stack
#TODO This function may not work correctly if cmd's syntax is wrong
function parseCommand(cmdStr, 
                      cmdArray,
                      start,
                      #########
                      i, cmdChar, cmdStrLen, cmdName, optName, contents, end) {

    if (isNotDefined(start)){
        start = findFirstNonEscapedChar(cmdStr, "@")
    }
    if (start == 0) return FALSE

    cmdStrLen = explode(cmdStr, cmdChar)

    bracketLevel     = 0
    parenthesisLevel = 0

    for (i = start + 1; i <= cmdStrLen; i++){

        if (cmdChar[i] == "["){
            bracketLevel++
        } else if (cmdChar[i] == "("){
            parenthesisLevel++
        } else if (cmdChar[i] == "]"){
            bracketLevel--
        } else if (cmdChar[i] == ")"){
            parenthesisLevel--
            if (parenthesisLevel == 0) {
                end = i
                break
            }
        }

        if (parenthesisLevel == 0 && bracketLevel == 0 && cmdChar[i] != "]") {
            cmdName = cmdName cmdChar[i]
        } else if (bracketLevel == 1 && parenthesisLevel == 0 && cmdChar[i] != "[") {
            optName = optName cmdChar[i]
        } else if (parenthesisLevel > 0 && !(cmdChar[i] == "(" && parenthesisLevel == 1)) {
            contents = contents cmdChar[i]
        }
        
    }

    cmdArray["cmd"]      = cmdName
    cmdArray["opt"]      = optName
    cmdArray["contents"] = contents
    cmdArray["start"]    = start
    cmdArray["end"]      = end
    return TRUE
}

function printCmd (result,
                   #######
                   result2, i, j){

        print "start   :\t"result["start"]
        print "end     :\t"result["end"]
        print "cmdName :\t"result["cmd"]
        print "options :\t"result["opt"]
        print "contents:\t"result["contents"]
        print
}

function escapeLaTeX(target,
                     #######
                     contents, stack, charArr, i, twoLenStr, curSymb, tmpString, len) {

    contents = NULLSTR

    initStack(stack)

    len = explode(target, charArr)
    for (i = 1; i <= len; i++) {

        # get current symbol
        #print "#"join(charArr, NULLSTR, i, i+1)"#" belongsTo(join(charArr, NULLSTR, i, i+1), LaTeXMathSep)
        twoLenStr = join(charArr, NULLSTR, i, i+1)
        
        if(twoLenStr == "\\*" || twoLenStr == "\\_"){
            curSymb = join(charArr, NULLSTR, i, i+1)
            i++
        }

        ## 2-length math delimiter
        else if (belongsTo(twoLenStr, LaTeXMathSep)){
            curSymb = twoLenStr
            i++
        ## 1-length math delimiter
        # TODO redundant code
        } else if (belongsTo(charArr[i], LaTeXMathSep)){
            curSymb = charArr[i]
        } else {
            curSymb = charArr[i]
        }

        # maths mode separators
        if (belongsTo(curSymb, LaTeXMathSep)) {

            if (laTeXMathSepMatch(getTopKey(stack), curSymb)) {
                # END LaTeX maths' delimiter pair
                contents = contents getTopKey(stack) pop(stack) curSymb
            } else if (isEmpty(stack)) {
                # BEGIN LaTeX maths mode
                push(stack, NULLSTR, curSymb)
            } else {
                ##TODO: add warning
            }

        } else {

            if (belongsTo(getTopKey(stack), LaTeXMathSep)) {
                # INSIDE maths mode
                # just copy. It's the user's responsability to write correct LaTeX code
                updateTopValue(stack, getTopValue(stack) curSymb)
            } else {
                # OUTSIDE maths mode

                gsub(/\\/,"\\textbackslash ", curSymb)
                gsub(/%/,"\\%", curSymb)
                gsub(/#/,"\\#", curSymb)
                gsub(/{/,"\\{", curSymb)
                gsub(/}/,"\\}", curSymb)
                gsub(/~/,"\\textasciitilde ", curSymb)
                gsub(/\^/,"\\textasciicircum ", curSymb)

                if (curSymb == "`") {

                    if (getTopKey(stack) == "`"){
                        # END teletypefont
                        contents = contents buildLaTeXCmd(LaTeXCmd["teletypefont"], pop(stack))
                    } else {
                        # BEGIN teletypefont
                        push(stack, NULLSTR, curSymb)
                    }

                } else {
                    
                    if (getTopKey(stack) == "`"){
                        # INSIDE teletypefont
                        gsub(/_/, "\\textunderscore ", curSymb)
                        updateTopValue(stack, getTopValue(stack) curSymb)
                    } else {
                        # OUTSIDE teletypefont
                        if (curSymb == "@") {
                            # skip command
                            parseCommand(target, cmdArr, i)
                            tmpString = substr(target, i, cmdArr["end"] - i + 1)

                            if (isEmpty(stack)){
                                contents = contents tmpString
                            } else {
                                updateTopValue(stack, getTopValue(stack) tmpString)
                            }
                            
                            i = cmdArr["end"]
                        } else if (curSymb == "_") {
                            if (getTopKey(stack) == "_") {
                                # END italic style font
                                tmpString = buildLaTeXCmd(LaTeXCmd["italic"], pop(stack))

                                if (isEmpty(stack)){
                                    contents = contents tmpString
                                } else {
                                    updateTopValue(stack, getTopValue(stack) tmpString)
                                }

                            } else {
                                # BEGIN italic style font
                                push(stack, NULLSTR, curSymb)
                            }
                        } else if (curSymb == "*") {
                            if (getTopKey(stack) == "*") {
                                # END bold style font
                                tmpString = buildLaTeXCmd(LaTeXCmd["bold"], pop(stack))

                                if (isEmpty(stack)){
                                    contents = contents tmpString
                                } else {
                                    updateTopValue(stack, getTopValue(stack) tmpString)
                                }
                            } else {
                                # BEGIN bold style font
                                push(stack, NULLSTR, curSymb)
                            }
                        }

                        else {
                            if (curSymb == "\\*" || curSymb == "\\_") {
                                curSymb = substr(curSymb, 2)
                            }

                            if (isEmpty(stack)) {
                                contents = contents curSymb
                            } else {
                                # INSIDE italic/bold style font
                                updateTopValue(stack, getTopValue(stack) curSymb)
                            }
                        }

                    }
                }

            }
        }

    }
    return contents
        
}

