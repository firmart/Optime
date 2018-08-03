#!/usr/bin/gawk -f

#
# Adapted from github.com/soimort/translate-shell/develop/build.awk
#

@include "include/string.awk"
@include "include/array.awk"
@include "include/io.awk"
@include "include/commons.awk"
@include "metainfo.awk"

function initBuild(){
    BuildPath = "build/"
    Optime    = BuildPath Command
    OptimeAwk = Optime ".awk"
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

        print "#!/usr/bin/env " target > Optime

        if (fileExists("DISCLAIMER")) {
            print "#" > Optime
            while (getline line < "DISCLAIMER")
                print "# " line > Optime
            print "#" > Optime
        }

        print "export OPTIME_ENTRY=\"$0\"" > Optime
        print "if [[ ! $LANG =~ (UTF|utf)-?8$ ]]; then export LANG=en_US.UTF-8; fi" > Optime

        print "read -r -d '' OPTIME_PROGRAM << 'EOF'" > Optime
        print readSqueezed(EntryPoint, TRUE) > Optime
        print "EOF" > Optime

        print "read -r -d '' OPTIME_MANPAGE << 'EOF'" > Optime
        if (fileExists(Man))
            while (getline line < Man)
                print line > Optime
        print "EOF" > Optime
        print "export OPTIME_MANPAGE" > Optime

        if (type == "release")
            print "export OPTIME_BUILD=release" temp > Optime
        else {
            temp = getGitHead()
            if (temp)
                print "export OPTIME_BUILD=git:" temp > Optime
        }

        print "gawk -f <(echo -E \"$OPTIME_PROGRAM\") -  \"$@\"" > Optime

        ("chmod +x " parameterize(Optime)) | getline

        # Rebuild EntryScript
        print "#!/bin/sh" > EntryScript
        print "export OPTIME_DIR=`dirname $0`" > EntryScript
        #print "gawk \\" > EntryScript
        print "gawk --debug \\" > EntryScript
        for (i = 1; i <= length(Includes) -1; i++)
            print "-i \"${OPTIME_DIR}/" Includes[i] "\" \\" > EntryScript
        print "-f \"${OPTIME_DIR}/" Includes[i] "\" -- \"$@\"" > EntryScript
        ("chmod +x " parameterize(EntryScript)) | getline
        return 0

    } else if (target == "awk" || target == "gawk") {

        "uname -s" | getline temp
        print (temp == "Darwin" ?
               "#!/usr/bin/env gawk -f" : # macOS
               "#!/usr/bin/gawk -f") > OptimeAwk

        print readSqueezed(EntryPoint, TRUE) > OptimeAwk

        ("chmod +x " parameterize(OptimeAwk)) | getline
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

