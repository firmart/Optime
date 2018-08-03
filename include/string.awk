
#
# Global variables:
# - NULLSTR: string -> null string
#

BEGIN {
    NULLSTR = ""
}


function replaceSubStringBy(string, start, end, replace, 
                            ############################
                            sstr1, sstr2) {
    sstr1 = substr(string, 1, start - 1)
    sstr2 = substr(string, end + 1)
    return sstr1 replace sstr2
}

# Return one of the patterns if the string matches this pattern at the beginning;
# Otherwise, return a null string.
function matchesAny(string, patterns,
                    ####
                    i) {
    for (i in patterns)
        if (string ~ "^" patterns[i]) return i
    return NULLSTR
}

# Return one of the substrings' index if the string starts with it;
# Otherwise, return a null string.
function startsWithAny(string, substrings,
                       ####
                       i) {
    for (i in substrings)
        if (index(string, substrings[i]) == 1) return substrings[i]
    return NULLSTR
}


# Split a string into characters.
function explode(string, array){
    return split(string, array, NULLSTR)
}


# Return the escaped string.
function escape(string) {
    gsub(/\\/, "\\\\", string) # substitute backslashes first
#    gsub(/"/, "\\\"", string)
    gsub(/%/, "%%", string)    # escape % for printf directive
    gsub(/\\\\'/, "\\'", string)

    return string
}

# Reverse of escape(string).
function unescape(string) {
    gsub(/%%/, "%", string)    # unescape % for printf directive
    gsub(/\\\"/, "\"", string)
    gsub(/\\\\/, "\\", string) # substitute backslashes last

    return string
}

# Return the escaped, quoted string.
function parameterize(string, quotationMark) {
    if (isNotDefined(quotationMark)) {
        quotationMark = "'"
    }

    if (quotationMark == "'") {
        gsub(/'/, "'\\''", string)
        return "'" escape(string) "'"
    } else {
        return "\"" escape(string) "\""
    }
}

# Reverse of parameterize(string, quotationMark).
function unparameterize(string,    temp) {
    match(string, /^'(.*)'$/, temp)
    if (temp[0]) { # use temp[0] (there is a match for quoted empty string)
        string = temp[1]
        gsub(/'\\''/, "'", string)
        return string
    }
    match(string, /^"(.*)"$/, temp)
    if (temp[0]) {
        string = temp[1]
        return unescape(string)
    }
    return string
}
