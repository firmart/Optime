#! /usr/bin/gawk -f 

#
# Global variables:
# - BlocksNB: number -> number of Blocks (sectionning include)
# - CurrentScope: string -> current scope
# - SectionsName: array -> list of sectionning name
# - BlocksName: array -> list of blocks name (exclude sectionning)
# - BlocksColumns: array -> contains for each block columns number used
# - BlocksIcon: array -> contains icon code for each block (which use icon)
#

###
###  Init functions                               
###

function initSectionsName() {

    # sections Name
    SectionsName["p"  ] = "part"
    SectionsName["s"  ] = "section"
    SectionsName["ss" ] = "subsection"
    SectionsName["sss"] = "subsubsection"

}

function initBlocksName() {

    # blocks Name
    BlocksName["c"     ] = "oneColumn"    
    BlocksName["cc"    ] = "twoColumns"   
    BlocksName["ccc"   ] = "threeColumns" 
    BlocksName["cccc"  ] = "fourColumns"  
    BlocksName["time"  ] = "vtime"        
    BlocksName["code"  ] = "code"         
    BlocksName["pie"   ] = "pieChart"     
    BlocksName["bar"   ] = "barChart"     
    BlocksName["faq"   ] = "faq"          
    BlocksName["tex"   ] = "plainTex"     
    BlocksName["quotes"] = "quotes"     
    BlocksName["img"   ] = "image"     
    BlocksName["sage"  ] = "sageMath"    
}

function initBlocksColumns() {
    # column numbers
    BlocksColumns["c"     ] = 1
    BlocksColumns["cc"    ] = 2
    BlocksColumns["ccc"   ] = 3
    BlocksColumns["cccc"  ] = 4
    BlocksColumns["time"  ] = 1
    BlocksColumns["pie"   ] = 1 
    BlocksColumns["code"  ] = 1
    BlocksColumns["bar"   ] = 3
    BlocksColumns["faq"   ] = 1
    BlocksColumns["tex"   ] = 1
    BlocksColumns["quotes"] = 1     
    BlocksColumns["sage"  ] = 1     
}

function initBlocksIcon() {
    
    # icons
    BlocksIcon["c"     ] = buildFASymbol("Columns")
    BlocksIcon["cc"    ] = buildFASymbol("Columns")
    BlocksIcon["ccc"   ] = buildFASymbol("Columns")
    BlocksIcon["cccc"  ] = buildFASymbol("Columns")
    BlocksIcon["time"  ] = buildFASymbol("ClockO")
    BlocksIcon["pie"   ] = buildFASymbol("PieChart")
    BlocksIcon["bar"   ] = buildFASymbol("BarChart")
    BlocksIcon["faq"   ] = buildFASymbol("QuestionCircleO")
    BlocksIcon["tex"   ] = "\\LaTeX"
    BlocksIcon["quotes"] = buildFASymbol("Quote-left")
}

###
###  Blocks Functions 
###

# Given a block, return its LaTeX code
# If block's type is not recognized, NULLSTR is returned
function buildBlock(blockStr,
                    #########
                    blockLines, blockType, blockTitle, buildFun, blockContents) {

    CurrentScope = "block"

    # remove old block options
    updateOptions()

    split(blockStr, blockLines, "\n")
    blockType  = getBlockType(blockLines[1])
    blockTitle = getBlockTitle(blockLines[1])
    blockContents = join(blockLines, "\n", 2)

    debug(repeat("-", getTerminalWidth() - 7))
    debug("Block " BlocksNB)
    debug("Block title : " blockTitle )

    ParsedBlocks[BlocksNB]["filename"] = "block." BlocksNB ".tex" 
    ParsedBlocks[BlocksNB]["type"]     = blockType
    ParsedBlocks[BlocksNB]["title"]    = blockTitle

    if (blockType in BlocksName){

        debug("Block type  : " BlocksName[blockType] )

        buildFun = BlocksName[blockType] "Block"
        blockStr = @buildFun(blockLines[1], blockContents) addVspace("1.3em")
        if (blockStr && blockType != "code" && blockType != "sage")
            return escapeSpecialCatCode(blockStr)
        else 
            return blockStr

    } else if( blockType in SectionsName) {

        debug("Block type  : " SectionsName[blockType])

        buildFun = SectionsName[blockType] "Block"
        CurrentScope = SectionsName[blockType]
        updateOptions()
        return @buildFun(blockLines[1], blockContents) addVspace("1.3em")

    } else {
        warn("Block type \"" blockType "\" is not available. Ignored.")
        return NULLSTR
    }
}

# SageMath block
function sageMathBlock (blockHeader, contents,
                        #####################
                        blockType, blockTitle, blockContents, len, contentsLine, i, j, mCode, pCode, sageSilent) {

    if (!SageMath) {
        warn("SageMath is not installed !")
        return NULLSTR
    }

    SageMathUsed = TRUE

    blockType = getBlockType(blockHeader)
    blockTitle = getBlockTitle(blockHeader)

    # Title
    blockContents = setTitle(blockTitle, blockType) 

    # Contents
    len = split(contents, contentsLine, "\n")
    for (i = 1; i <= len; i++) {
        
        # note line (started by ">"
        if (contentsLine[i] ~ /^\s*>>>\s*$/) {
          # multiple-lines code 
            j = i + 1
            while(j <= len && contentsLine[j] !~ /^\s*<<<\s*$/) j++
            mCode = ((j == i+1) ? NULLSTR : join(contentsLine, "\n", i + 1, j - 1))

            if (mCode) {
                blockContents = blockContents 
                # code highlighting 
                pCode = NULLSTR
                for (k = i + 1; k <= j - 1; k++) pCode = pCode setRowColor("lightbackground")  buildLaTeXCmd("pygment", contentsLine[k], "sage") "\\tabularnewline" "\n"
                blockContents = blockContents pCode  
                # evaluate code in sage
                sageSilent = sageSilent buildLaTeXEnv("sagesilent", mCode)  "\n"
                # Display the last line as result
                split(contentsLine[j - 1], expr, ";")
                blockContents = blockContents setRowColor("white") bold(colorize("sage:", "blue")) buildLaTeXEnv("dmath*", buildLaTeXCmd("sage", expr[length(expr)]))  "\\tabularnewline" "\n"
            }
            i = j
        } else if (contentsLine[i] ~ /^\s*>\s*.*$/) {
            blockContents = blockContents buildNoteLine(evalLine(escapeLaTeX(contentsLine[i])), BlocksColumns[blockType])
        } else {
                blockContents = blockContents setRowColor("lightbackground")
                # code highlighting 
                blockContents = blockContents buildLaTeXCmd("pygment", contentsLine[i], "sage") "\\tabularnewline" "\n"
                # evaluate code in sage
                sageSilent = sageSilent buildLaTeXEnv("sagesilent", contentsLine[i])  "\n"
                # Display the last line as result
                split(contentsLine[i], expr, ";")
                blockContents = blockContents setRowColor("white") bold(colorize("sage:", "blue")) buildLaTeXEnv("dmath*", buildLaTeXCmd("sage", expr[length(expr)])) "\\tabularnewline" "\n"
        }
    }
    return sageSilent buildLaTeXEnv(BlocksName["c"], blockContents)
}

# Vertical timeline block
function vtimeBlock (blockHeader, 
                     contents,
                     ############
                     blockContents, i, contentsLine, blockType, blockTitle) {

    blockType = getBlockType(blockHeader)
    blockTitle = getBlockTitle(blockHeader)
    # Title
    blockContents = setTitle(blockTitle, blockType) setRowColor("lightbackground")

    # Contents
    split(contents, contentsLine, "\n")
    for (i in contentsLine) {
        line = evalLine(escapeLaTeX(contentsLine[i]))

        # note line (started by ">")
        if (contentsLine[i] ~ /^\s*>\s*.*$/){
            blockContents = blockContents buildNoteLine(line, BlocksColumns[blockType])
        } else {
            if (line) {
                # background color : alter between lightbackground and white
                wrappedContent = wrappedContent \
                    line \
                    "\\endlr" "\n"
            }
        }
    }
    blockContents =  blockContents buildLaTeXEnv("vtimeline", wrappedContent,"", "timeline color=darkbackground, line offset=2pt, description={text width=5.733cm}")
    return buildLaTeXEnv(BlocksName[blockType], blockContents)
}


# Quotation block
function quotesBlock(blockHeader,
                        contents,
                        ############
                        blockType) {

    blockType = getBlockType(blockHeader)
    return buildLaTeXEnv(BlocksName[blockType], evalLine(escapeLaTeX(contents)))
}



# Code block
function codeBlock (blockHeader,
                    contents,
                    ########
                    blockType, blockPL, blockTitle, contentsLine, i, opt) {

    blockType = getBlockType(blockHeader)
    blockTitle = getBlockTitle(blockHeader)
    blockPL = getProgLang(blockHeader)

    opt[1] = blockPL
    opt[2] = blockTitle

    # If Pygments not installed, return nothing
    if (!Pygments) {
        error("Pygments is not installed. Install it with " ansi("blue", "pip install pygments"))
        return NULLSTR
    } else {
        return buildLaTeXEnv(BlocksName[blockType], contents, opt)
    }
    
}

# Pie chart block
function pieChartBlock (blockHeader,
                        contents,
                        ##########
                        blockType, blockTitle, contentsLine, maxValue, j, i, rowData, dataValue, dataName, exponent ) {

    blockType = getBlockType(blockHeader)
    blockTitle = getBlockTitle(blockHeader)

    split(contents, contentsLine, "\n")

    maxValue = NULLSTR
    j = 0
    # Contents
    for (i in contentsLine) {
        
        # note line (started by ">"
        if (contentsLine[i] ~ /^\s*>\s*.*$/){
            blockContents = blockContents buildNoteLine(evalLine(escapeLaTeX(contentsLine[i])), BlocksColumns[blockType])
        } else {
            split(contentsLine[i], rowData, /\s*&\s*/)
            # background color : alter between lightbackground and white
            ++j
            dataValue[j] = rowData[2]
            dataName[j]  = rowData[1] 

            if (!maxValue || maxValue < dataValue[j]) {
                maxValue = dataValue[j]
            }
        }
    }
    exponent = getExponent(maxValue)

    for (i = 1; i <= j; ++i){
        dataValue[i] /= 10**exponent
        data = data dataValue[i] "/" dataName[i] (i == j ? "" : ", " )
    }
    return buildLaTeXEnv(BlocksName["c"], setTitle(blockTitle, blockType) blockContents "\n"  \
        buildLaTeXCmd(BlocksName[blockType],  data, "", 10**exponent) "\\tabularnewline" "\n")
}

# Bar chart block
function barChartBlock (blockHeader,
                        contents,
                        ##########
                        blockContents, contentsLine, i, sum, data, len) {

    blockType = getBlockType(blockHeader)
    blockTitle = getBlockTitle(blockHeader)

    # Title
    blockContents = setTitle(blockTitle, blockType)

    split(contents, contentsLine, "\n")

    # get sum
    sum = 0.0
    for (i in contentsLine) {

        if (contentsLine[i] ~ /^\s*>\s*.*$/)
            continue
        
        split(contentsLine[i], data, "&")
        #TODO:support prefix notation
        sum += data[2]
    }

    # Contents
    for (i in contentsLine) {
        
        # note line (started by ">"
        if (contentsLine[i] ~ /^\s*>\s*.*$/){
            blockContents = blockContents buildNoteLine(evalLine(escapeLaTeX(contentsLine[i])), BlocksColumns[blockType])
        } else {
            split(contentsLine[i], data, "&")
            #TODO: adjust here to support multiple columns
            len = 2.01388*(data[2]/sum)
            # background color : alter between lightbackground and white
            blockContents = blockContents \
                (i % 2 == 1 ? setRowColor("lightbackground") : setRowColor("white")  " ") \
                    evalLine(escapeLaTeX(data[1])) " & " \
                    hspace("6bp") rule(len " cm", "6bp")  " & " \
                    data[2] \
                "\\tabularnewline" "\n"
        }
    }
    return buildLaTeXEnv(BlocksName[blockType], blockContents)
}

# FAQ block
function faqBlock (blockHeader, 
                   contents,
                   ##########
                   blockContents, contentsLine, i, line) {

    blockType = getBlockType(blockHeader)
    blockTitle = getBlockTitle(blockHeader)

    # Title
    blockContents = setTitle(blockTitle, blockType)

    # Contents
    split(contents, contentsLine, "\n")
    for (i in contentsLine) {
        # note line (started by ">"
        line = evalLine(escapeLaTeX(contentsLine[i]))
        if (contentsLine[i] ~ /^\s*>\s*.*$/){
            blockContents = blockContents buildNoteLine(line, BlocksColumns[blockType])
        } else {
            # background color : alter between lightbackground and white
            if (line) {
                blockContents = blockContents \
                    (i % 2 == 1 ? setRowColor("lightbackground") : setRowColor("white") hspace("6bp") rule("2bp", "6bp") hspace("6bp")) " " \
                    line \
                    "\\tabularnewline" "\n"
            }
        }
    }

    return buildLaTeXEnv(BlocksName[blockType], blockContents)
    
}
                  
# Column block (generalisation)                  
function columnBlock (blockHeader,
                      contents,
                      escapeFlag,
                      ##########
                      blockContents, i, contentsLine, blockType, blockTitle) {

    if (missing(escapeFlag))
        escapeFlag = 1

    blockType = getBlockType(blockHeader)
    blockTitle = getBlockTitle(blockHeader)

    # Title
    blockContents = setTitle(blockTitle, blockType)

    # Contents
    split(contents, contentsLine, "\n")
    for (i in contentsLine) {
        line = evalLine(escapeLaTeX(contentsLine[i]))
        # TODO escape \&

        # note line (started by ">")
        if (contentsLine[i] ~ /^\s*>\s*.*$/) {
            blockContents = blockContents (i % 2 == 1 ? buildNoteLine(line, BlocksColumns[blockType], "lightbackground") : buildNoteLine(line, BlocksColumns[blockType])) 
        } else {
            if (line){
                # background color : alter between lightbackground and white
                blockContents = blockContents \
                    (i % 2 == 1 ? setRowColor("lightbackground") : setRowColor("white")) " " \
                    (escapeFlag ? line : evalLine(contentsLine[i])) \
                    "\\tabularnewline" "\n"
            }
        }
    }

    return buildLaTeXEnv(BlocksName[blockType], blockContents)
}

# One column block
function oneColumnBlock (blockHeader, contents) {
    return columnBlock(blockHeader, contents)
}

# Two columns block
function twoColumnsBlock (blockHeader, contents) {
    return columnBlock(blockHeader, contents)
}

# Three columns block
function threeColumnsBlock (blockHeader, contents) {
    return columnBlock(blockHeader, contents)
}

# Four columns block
function fourColumnsBlock (blockHeader, contents) {
    return columnBlock(blockHeader, contents)
}

#TODO: replace tex block by tcolorbox
# Plain TeX Block (no escaping)
function plainTexBlock (blockHeader, contents) {
    return columnBlock(blockHeader, contents, 0)
}

# Image block
# TODO use Image option instead of image block
function imageBlock (blockHeader, contents) {
    split(contents, contentsLine, "\n")
    for (i in contentsLine) {
        line = evalLine(contentsLine[i])
        if (line){
                imgAbsPath = getAbsolutePathInFile(getFrontValue(Input), line)
                if (fileExists(imgAbsPath)){
                    copyTo(imgAbsPath, AuxFiles["dir"] BlocksNB)
                } else {
                    warn("Image \"" line "\" doesn't exist")
                    return NULLSTR
                }
        }
    }
    return buildLaTeXCmd(BlocksName["img"], BlocksNB, NULLSTR, getBlockTitle(blockHeader))
}

###
### Sectionning Functions
###

# Section block (generalisation)
function buildSectionning(blockHeader, blockContents, isNumbered,     optionName){
    
    blockType = getBlockType(blockHeader)
    blockTitle = getBlockTitle(blockHeader)

    # Contents
    split(blockContents, contentsLine, "\n")

    for (i in contentsLine) {
        # Only handle command, ignore text
        evalLine(contentsLine[i])
    }

    return  buildLaTeXCmd(SectionsName[blockType] (isNumbered ? "" : "*"), blockTitle)
}

# Part block
function partBlock (blockHeader, blockContents) {
    return buildSectionning(blockHeader, blockContents, FALSE)
}

# Section block
function sectionBlock (blockHeader, blockContents) {
    return buildSectionning(blockHeader, blockContents, FALSE)
}

# Subsection block
function subsectionBlock (blockHeader, blockContents) {
    return buildSectionning(blockHeader, blockContents, FALSE)
}

# Subsubsection block
function subsubsectionBlock (blockHeader, blockContents) {
    return buildSectionning(blockHeader, blockContents, FALSE)
}

###
### Block utils functions
###

#TODO add code style as option

# Get pygments lexer name from block's header
# If there isn't lexer or it's not supported by pygments, "text" is returned 
function getProgLang(blockHeader,
                     #########
                     blockLines, blockFields) {
    split(blockHeader, blockFields, ":")    

    if (length(blockFields) == 2) return "text"
    else if (Pygments && !isPygmentsLexer(blockFields[2])) {
        warn("Lexer \"" blockFields[2] "\" doesn't exist.")
        return "text"
    } else {
        return blockFields[2]
    }
}

# Get block's type from its header
function getBlockType(blockHeader) {
    split(blockHeader, headerFields, ":")
    return  headerFields[1]
}

# Get block's title from its header
function getBlockTitle(blockHeader,
                       #########
                       blockType) {
    blockType = getBlockType(blockHeader)
    split(blockHeader, headerFields, ":")
    if (blockType == "code" && length(headerFields) > 2) 
        return escapeLaTeX(join(headerFields, ":", 3))
    else  
        return escapeLaTeX(join(headerFields, ":", 2))
}

### 
### Write functions
### 

# Write block's LaTeX code in appropriate file  
function writeBlock(str,     blockStr, file, colorFile) {
    BlocksNB++
    blockStr = buildBlock(str)
    file = AuxFiles["dir"] "block." BlocksNB ".tex"
    colorFile = "colors." BlocksNB ".tex"

    blockStr = input(colorFile) "\n" blockStr 
    writeTo(blockStr, file)
    writeColors(AuxFiles["dir"] colorFile)
}

#TODO modify if there is other type of options (probably)
# Write block's color LaTeX code in appropriate file  
function writeColors(file) {

    cleanContentsOf(file)
    for(optionName in Option) {
        if (optionName == "textcolor") {
            defineOption(optionName, file)
        } else {
            defineOption(optionName, file)
        }
    }
    appendTo("\\color{textcolor}", file)
}

    

