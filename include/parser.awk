#! /usr/bin/gawk -f


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

                gsub(/\\/,"\\textbackslash~", curSymb)
                gsub(/%/,"\\%", curSymb)
                gsub(/#/,"\\#", curSymb)
                gsub(/{/,"\\{", curSymb)
                gsub(/}/,"\\}", curSymb)
                gsub(/~/,"\\textasciitilde~", curSymb)
                gsub(/\^/,"\\textasciicircum~", curSymb)

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

# JSON parser
function parseJson(returnAST, tokens,
                   arrayStartTokens, arrayEndTokens,
                   objectStartTokens, objectEndTokens,
                   commas, colons,
                   ####
                   flag, i, j, key, name, p, stack, token) {

    # Default parameters
    if (!arrayStartTokens[0])  arrayStartTokens[0]  = "["
    if (!arrayEndTokens[0])    arrayEndTokens[0]    = "]"
    if (!objectStartTokens[0]) objectStartTokens[0] = "{"
    if (!objectEndTokens[0])   objectEndTokens[0]   = "}"
    if (!commas[0])            commas[0]            = ","
    if (!colons[0])            colons[0]            = ":"

    stack[p = 0] = 0
    flag = 0 # ready to read key
    for (i = 0; i < length(tokens); i++) {
        token = tokens[i]
        if (belongsTo(token, arrayStartTokens)) {
            stack[++p] = 0
        } else if (belongsTo(token, objectStartTokens)) {
            stack[++p] = NULLSTR
            flag = 0 # ready to read key
        } else if (belongsTo(token, objectEndTokens) ||
                   belongsTo(token, arrayEndTokens)) {
            --p
        } else if (belongsTo(token, commas)) {
            if (isNum(stack[p])) # array
                stack[p]++ # increase index
            else # object
                flag = 0 # ready to read key
        } else if (belongsTo(token, colons)) {
            flag = 1 # ready to read value
        } else if (isNum(stack[p]) || flag) {
            # Read a value
            key = stack[0]
            for (j = 1; j <= p; j++)
                key = key SUBSEP stack[j]
            returnAST[key] = token
            flag = 0 # ready to read key
        } else {
            # Read a key
            stack[p] = unparameterize(token)
        }
    }
}


# Tokenize a string and return a token list.
function tokenize(returnTokens, string,
                  delimiters, newlines,
                  quotes, escapeChars,
                  leftBlockComments, rightBlockComments,
                  lineComments, reservedOperators,
                  reservedPatterns,
                  ####
                  blockCommenting, c,
                  currentToken, escaping,
                  i, lineCommenting, p, quoting,
                  r, s, tempGroup, tempPattern,
                  tempString) {
    # Default parameters
    if (!delimiters[0]) {
        delimiters[0] = " "  # whitespace
        delimiters[1] = "\t" # horizontal tab
        delimiters[2] = "\v" # vertical tab
    }
    if (!newlines[0]) {
        newlines[0] = "\n" # line feed
        newlines[1] = "\r" # carriage return
    }
    if (!quotes[0]) {
        quotes[0] = "\"" # double quote
    }
    if (!escapeChars[0]) {
        escapeChars[0] = "\\" # backslash
    }
    if (!leftBlockComments[0]) {
        leftBlockComments[0] = "#|" # Lisp-style extended comment (open)
        leftBlockComments[1] = "/*" # C-style comment (open)
        leftBlockComments[2] = "(*" # ML-style comment (open)
    }
    if (!rightBlockComments[0]) {
        rightBlockComments[0] = "|#" # Lisp-style extended comment (close)
        rightBlockComments[1] = "*/" # C-style comment (close)
        rightBlockComments[2] = "*)" # ML-style comment (close)
    }
    if (!lineComments[0]) {
        lineComments[0] = ";"  # Lisp-style line comment
        lineComments[1] = "//" # C++-style line comment
        lineComments[2] = "#"  # hash comment
    }
    if (!reservedOperators[0]) {
        reservedOperators[0] = "(" #  left parenthesis
        reservedOperators[1] = ")" # right parenthesis
        reservedOperators[2] = "[" #  left bracket
        reservedOperators[3] = "]" # right bracket
        reservedOperators[4] = "{" #  left brace
        reservedOperators[5] = "}" # right brace
        reservedOperators[6] = "," # comma
    }
    if (!reservedPatterns[0]) {
        reservedPatterns[0] = "[+-]?((0|[1-9][0-9]*)|[.][0-9]*|(0|[1-9][0-9]*)[.][0-9]*)([Ee][+-]?[0-9]+)?" # numeric literal (scientific notation possible)
        reservedPatterns[1] = "[+-]?0[0-7]+([.][0-7]*)?" # numeric literal (octal)
        reservedPatterns[2] = "[+-]?0[Xx][0-9A-Fa-f]+([.][0-9A-Fa-f]*)?" # numeric literal (hexadecimal)
    }

    split(string, s, "")
    currentToken = ""
    quoting = escaping = blockCommenting = lineCommenting = 0
    p = 0
    i = 1
    while (i <= length(s)) {
        c = s[i]
        r = substr(string, i)

        if (blockCommenting) {
            if (tempString = startsWithAny(r, rightBlockComments))
                blockCommenting = 0 # block comment ends

            i++

        } else if (lineCommenting) {
            if (belongsTo(c, newlines))
                lineCommenting = 0 # line comment ends

            i++

        } else if (quoting) {
            currentToken = currentToken c

            if (escaping) {
                escaping = 0 # escape ends

            } else {
                if (belongsTo(c, quotes)) {
                    # Finish the current token
                    if (currentToken) {
                        returnTokens[p++] = currentToken
                        currentToken = ""
                    }

                    quoting = 0 # quotation ends

                } else if (belongsTo(c, escapeChars)) {
                    escaping = 1 # escape begins

                } else {
                    # Continue
                }
            }

            i++

        } else {
            if (belongsTo(c, delimiters) || belongsTo(c, newlines)) {
                # Finish the current token
                if (currentToken) {
                    returnTokens[p++] = currentToken
                    currentToken = ""
                }

                i++

            } else if (belongsTo(c, quotes)) {
                # Finish the current token
                if (currentToken) {
                    returnTokens[p++] = currentToken
                }

                currentToken = c

                quoting = 1 # quotation begins

                i++

            } else if (tempString = startsWithAny(r, leftBlockComments)) {
                # Finish the current token
                if (currentToken) {
                    returnTokens[p++] = currentToken
                    currentToken = ""
                }

                blockCommenting = 1 # block comment begins

                i += length(tempString)

            } else if (tempString = startsWithAny(r, lineComments)) {
                # Finish the current token
                if (currentToken) {
                    returnTokens[p++] = currentToken
                    currentToken = ""
                }

                lineCommenting = 1 # line comment begins

                i += length(tempString)

            } else if (tempString = startsWithAny(r, reservedOperators)) {
                # Finish the current token
                if (currentToken) {
                    returnTokens[p++] = currentToken
                    currentToken = ""
                }

                # Reserve token
                returnTokens[p++] = tempString

                i += length(tempString)

            } else if (tempPattern = matchesAny(r, reservedPatterns)) {
                # Finish the current token
                if (currentToken) {
                    returnTokens[p++] = currentToken
                    currentToken = ""
                }

                # Reserve token
                match(r, "^" reservedPatterns[tempPattern], tempGroup)
                returnTokens[p++] = tempGroup[0]

                i += length(tempGroup[0])

            } else {
                # Continue with the current token
                currentToken = currentToken c

                i++
            }
        }
    }

    # Finish the last token
    if (currentToken)
        returnTokens[p++] = currentToken

}

