#! /usr/bin/gawk -f 

@include "commons.awk"
@include "array.awk"

BEGIN {
    initAvailableColors()
    TotalDefaultColors = length(AvailableColors)
}

###
### Init functions
###

function initAvailableColors() {

    # LaTeX predefined color
    AvailableColors[1]  = "black"
    AvailableColors[2]  = "blue"
    AvailableColors[3]  = "brown"
    AvailableColors[4]  = "cyan"
    AvailableColors[5]  = "darkgray"
    AvailableColors[6]  = "gray"
    AvailableColors[7]  = "green"
    AvailableColors[8]  = "lightgray"
    AvailableColors[9]  = "lime"
    AvailableColors[10] = "magenta"
    AvailableColors[11] = "olive"
    AvailableColors[12] = "orange"
    AvailableColors[13] = "pink"
    AvailableColors[14] = "purple"
    AvailableColors[15] = "red"
    AvailableColors[16] = "teal"
    AvailableColors[17] = "violet"
    AvailableColors[18] = "white"
    AvailableColors[19] = "yellow"

    # dvips color
    AvailableColors[20] = "Apricot"
    AvailableColors[21] = "Bittersweet"
    AvailableColors[22] = "Blue"
    AvailableColors[23] = "BlueViolet"
    AvailableColors[24] = "Brown"
    AvailableColors[25] = "CadetBlue"
    AvailableColors[26] = "Cerulean"
    AvailableColors[27] = "Cyan"
    AvailableColors[28] = "DarkOrchid"
    AvailableColors[29] = "ForestGreen"
    AvailableColors[30] = "Goldenrod"
    AvailableColors[31] = "Green"
    AvailableColors[32] = "JungleGreen"
    AvailableColors[33] = "LimeGreen"
    AvailableColors[34] = "Mahogany"
    AvailableColors[35] = "Melon"
    AvailableColors[36] = "Mulberry"
    AvailableColors[37] = "OliveGreen"
    AvailableColors[38] = "OrangeRed"
    AvailableColors[39] = "Peach"
    AvailableColors[40] = "PineGreen"
    AvailableColors[41] = "ProcessBlue"
    AvailableColors[42] = "RawSienna"
    AvailableColors[43] = "RedOrange"
    AvailableColors[44] = "Rhodamine"
    AvailableColors[45] = "RoyalPurple"
    AvailableColors[46] = "Salmon"
    AvailableColors[47] = "Sepia"
    AvailableColors[48] = "SpringGreen"
    AvailableColors[49] = "TealBlue"
    AvailableColors[50] = "Turquoise"
    AvailableColors[51] = "VioletRed"
    AvailableColors[52] = "WildStrawberry"
    AvailableColors[53] = "YellowGreen"
    AvailableColors[54] = "Aquamarine"
    AvailableColors[55] = "Black"
    AvailableColors[56] = "BlueGreen"
    AvailableColors[57] = "BrickRed"
    AvailableColors[58] = "BurntOrange"
    AvailableColors[59] = "CarnationPink"
    AvailableColors[60] = "CornflowerBlue"
    AvailableColors[61] = "Dandelion"
    AvailableColors[62] = "Emerald"
    AvailableColors[63] = "Fuchsia"
    AvailableColors[64] = "Gray"
    AvailableColors[65] = "GreenYellow"
    AvailableColors[66] = "Lavender"
    AvailableColors[67] = "Magenta"
    AvailableColors[68] = "Maroon"
    AvailableColors[69] = "MidnightBlue"
    AvailableColors[70] = "NavyBlue"
    AvailableColors[71] = "Orange"
    AvailableColors[72] = "Orchid"
    AvailableColors[73] = "Periwinkle"
    AvailableColors[74] = "Plum"
    AvailableColors[75] = "Purple"
    AvailableColors[76] = "Red"
    AvailableColors[77] = "RedViolet"
    AvailableColors[78] = "RoyalBlue"
    AvailableColors[79] = "RubineRed"
    AvailableColors[80] = "SeaGreen"
    AvailableColors[81] = "SkyBlue"
    AvailableColors[82] = "Tan"
    AvailableColors[83] = "Thistle"
    AvailableColors[84] = "Violet"
    AvailableColors[85] = "White"
    AvailableColors[86] = "Yellow"
    AvailableColors[87] = "YellowOrange"
}

# Given a color name, check if it exist or not
function isAvailableColor(colorName){
    return belongsTo(colorName, AvailableColors)
}

# Check if a color is a default one
function isDefaultColor(colorName){
    if (isAvailableColor(colorName) + 0 == 0) {
        return FALSE
    } else {
        return  isAvailableColor(colorName) + 0 <= TotalDefaultColors
    }
}

