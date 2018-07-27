#! /usr/bin/gawk -f

@include "string.awk"
@include "commons.awk"

# Return true if the array contains anything; otherwise return false.
function anything(array,
                  ####
                  i) {
    for (i in array)
        if (array[i]) return TRUE
    return FALSE
}

# Only work with number subscripted array
# Make sure that parameter array is initialized as an array (initAsArr)
function appendToArray(element, array) {
    array[anything(array) ? length(array) + 1 : 1] = element
}

# Return element's subscript if it belongs to the array;
# Otherwise, return a null string.
function belongsTo(element, array,
                   ####
                   i) {
    for (i in array) {
        if (element == array[i])  return i 
    }
    
    return NULLSTR
}

# Convert an array to a string, inverse of split.
# Used only with number subscripted array.
function join(array, delimiter, start, end,
              ######
              i, str) {

    if (!isarray(array)) return array;

    if (!delimiter)
        delimiter = NULLSTR

    if (!start)
        start = 1

    if (!end)
        end = length(array)

    
    for (i = start; i < end; ++i) {
        str = str array[i] delimiter
    }

    return str array[end] 
}

# Initialise an 'untyped' type variable  as 'array' type
function initAsArr(var) {
    if(isarray(var)) return 
    var[0] = NULLSTR
    delete var[0]
}


# Initialise 'unassigned' type to 'array' type
# var should be 'untyped' ......
function initEleAsArr(var, i) {
    if(!isarray(var[i][0])){
        var[i][0] = NULLSTR
        delete var[i][0]
    }
}

###
### Print function
###

function printArr(arr, sep){

    if (!length(sep)){
        sep = "-"
    }

    for (i in arr) {
        if (typeof(arr[i]) == "array"){
            printf i sep
            printArr(arr[i])
        } else {
            printf i sep arr[i]"\n"
        }
    }
}

###
### Miscellaneous and unused functions
###

# clone array 'rhs' to 'lhs'
# 'lhs' should be untyped.
function clone(lhs, rhs){
    delete lhs
    for (i in rhs) {
        if (isarray(rhs[i])){
            initEleAsArr(lhs, i)
            clone(lhs[i], rhs[i])
        } else {
            lhs[i] = rhs[i]
        }
    }
}

# clone subarray arr[rindex] to arr[lindex]
function clone2 (arr, lindex, rindex) {
    initEleAsArr(arr, lindex)
    clone(arr[lindex], arr[rindex])
}
