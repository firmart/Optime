#!/usr/bin/gawk -f
@include "metainfo.awk"

# no dependencies
@include "include/commons.awk"
@include "include/string.awk"
@include "include/array.awk"
@include "include/stack.awk"
@include "include/symbols.awk"
@include "include/pygments.awk"
@include "include/maths.awk"
@include "include/io.awk"
@include "include/script.awk"

# 1 dependency
@include "include/log.awk"
@include "include/colors.awk"
@include "include/help.awk"

# more than 1 dependency
@include "include/options.awk"
@include "include/files.awk"
@include "include/blocks.awk"
@include "include/cmd.awk"
@include "include/latex.awk"
@include "include/parser.awk"

# main entry
@include "include/main.awk"
