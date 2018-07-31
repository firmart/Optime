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

    return str array[i] 
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
    if(typeof(var[i][SUBSEP]) != "array"){
        var[i][SUBSEP] = SUBSEP
        delete var[i][SUBSEP]
    }
}

###
### Print function
###

function printArr(arr, num, sep,     i) {

    if (isNotDefined(sep)) {
        sep = " : "
    }

    if (isNotDefined(num)) {
        num = 0
    }

    for (i in arr) {
        if (isarray(arr[i])) {
            printf "%*s%s%s\n", num, " ", i, sep
            printArr(arr[i], num + 4, sep)
        } else {
            printf "%*s%s : %s\n", num, " ", i, arr[i]
        }
    }
}

###
### Conversion function
###


# Convert a pseudo-multidimensional array to a multidimensional array
#    pArr : pseudo-multidimensional array
#    mArr : multidimensional array
# TODO : pseudo-multidimensional array mustn't have keys like that
#           pArr["a", "b"] = "v1"
#           pArr["a", "b", "c"] = "v2"
function pseudoArrToMArr(pArr, mArr,    i, indices, ind) {
    asorti(pArr, ind)

    for (i in ind) {
        split(ind[i], indices, SUBSEP)
        assignValue(mArr, indices, pArr[ind[i]])
    }
}

function _assignValue(barr, indice, i, val) {

    if (i >= length(indice)) {
        barr[indice[i]] = val
        return 
    } else {
        initEleAsArr(barr, indice[i])
        _assignValue(barr[indice[i]], indice, i+1, val)
    }

}
function assignValue(carr, ind, val) {
    _assignValue(carr, ind, 1, val) 
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
