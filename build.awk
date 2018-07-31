#!/usr/bin/gawk -f

#
# Adapted from github.com/soimort/translate-shell/develop/build.awk
#

@include "string.awk"
@include "array.awk"
@include "io.awk"

function initBuild(){
    BuildPath        = "build/"
    Command          = "optime"
    BuildCommandPath = BuildPath Command
    Main             = BuildCommandPath ".awk"
    EntryPoint       = "main.awk"
    EntryScript      = "main"
}

BEGIN {
    initBuild()
    build(target, type)
}

function readSqueezed(fileName, squeezed,    group, line, ret) {
    if (fileName ~ /\*$/) # glob simulation
        return readSqueezed(fileName ".awk", squeezed)

    ret = NULLSTR
    if (fileExists(fileName))
        while (getline line < fileName) {
            match(line, /^[[:space:]]*@include[[:space:]]*"(.*)"$/, group)
            if (RSTART) { # @include
                if (group[1] ~ /\.awk$/)
                    appendToArray(group[1], Includes)

                if (ret) ret = ret RS
                ret = ret readSqueezed(group[1], squeezed)
            } else if (!squeezed || line = squeeze(line)) { # effective LOC
                if (ret) ret = ret RS
                ret = ret line
            }
        }
    return ret
}

function build(target, type,    i, group, inline, line, temp) {
    # Default target: bash
    if (!target) target = "bash"

    ("mkdir -p " parameterize(BuildPath)) | getline

    if (target == "bash" || target == "zsh") {

        print "#!/usr/bin/env " target > BuildCommandPath

        if (fileExists("DISCLAIMER")) {
            print "#" > BuildCommandPath
            while (getline line < "DISCLAIMER")
                print "# " line > BuildCommandPath
            print "#" > BuildCommandPath
        }

        print "export OPTIME_ENTRY=\"$0\"" > BuildCommandPath
        print "if [[ ! $LANG =~ (UTF|utf)-?8$ ]]; then export LANG=en_US.UTF-8; fi" > BuildCommandPath

        print "read -r -d '' OPTIME_PROGRAM << 'EOF'" > BuildCommandPath
        print readSqueezed(EntryPoint, TRUE) > BuildCommandPath
        print "EOF" > BuildCommandPath

        print "read -r -d '' OPTIME_MANPAGE << 'EOF'" > BuildCommandPath
        if (fileExists(Man))
            while (getline line < Man)
                print line > BuildCommandPath
        print "EOF" > BuildCommandPath
        print "export OPTIME_MANPAGE" > BuildCommandPath

        if (type == "release")
            print "export OPTIME_BUILD=release" temp > BuildCommandPath
        else {
            temp = getGitHead()
            if (temp)
                print "export OPTIME_BUILD=git:" temp > BuildCommandPath
        }

        #print "gawk -f <(echo -E \"$OPTIME_PROGRAM\") - \"$@\"" > BuildCommandPath
        print "gawk -f <(echo -E \"$OPTIME_PROGRAM\")  \"$@\"" > BuildCommandPath

        ("chmod +x " parameterize(BuildCommandPath)) | getline

        # Rebuild EntryScript
        print "#!/bin/sh" > EntryScript
        print "export OPTIME_DIR=`dirname $0`" > EntryScript
        print "gawk \\" > EntryScript
        for (i = 0; i < length(Includes) - 1; i++)
            print "-i \"${OPTIME_DIR}/" Includes[i] "\" \\" > EntryScript
        print "-f \"${OPTIME_DIR}/" Includes[i] "\" -- \"$@\"" > EntryScript
        ("chmod +x " parameterize(EntryScript)) | getline
        return 0

    } else if (target == "awk" || target == "gawk") {

        "uname -s" | getline temp
        print (temp == "Darwin" ?
               "#!/usr/bin/env gawk -f" : # macOS
               "#!/usr/bin/gawk -f") > Main

        print readSqueezed(EntryPoint, TRUE) > Main

        ("chmod +x " parameterize(Main)) | getline
        return 0

    } else {

        warn("[FAILED] Unknown target: " ansi("underline", target))
        warn("         Supported targets: "                                \
          ansi("underline", "bash") ", "                                \
          ansi("underline", "zsh") ", "                                 \
          ansi("underline", "gawk"))
        return 1

    }
}


# Squeeze a source line of AWK code.
function squeeze(line, preserveIndent) {
    # Remove preceding spaces if indentation not preserved
    if (!preserveIndent)
        gsub(/^[[:space:]]+/, NULLSTR, line)
    # Remove comment
    gsub(/^[[:space:]]*#.*$/, NULLSTR, line)
    # Remove in-line comment
    gsub(/#[^"/]*$/, NULLSTR, line)
    # Remove trailing spaces
    gsub(/[[:space:]]+$/, NULLSTR, line)
    gsub(/[[:space:]]+\\$/, "\\", line)

    return line
}

