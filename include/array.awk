#! /usr/bin/gawk -f


# Return 1 if an array is empty; 0 otherwise
function isEmpty(array){
    return length(array) == 0
}

# Only work with number subscripted array
# Make sure that parameter array is initialized as an array (initAsArr)
function appendToArray(element, array) {
    if (typeof(array) != "array") initAsArr(array)
    array[isEmpty(array) ? 1 : length(array) + 1] = element
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
    var[SUBSEP] = NULLSTR
    delete var[SUBSEP]
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

# print recursively an array (included subarray)
function printArr(arr, num, sep,     i) {

    if (missing(sep)) {
        sep = " : "
    }

    if (missing(num)) {
        num = 0
    }

    for (i in arr) {
        if (isarray(arr[i])) {
            printf "%*s%s%s\n", num, " ", ansi("red", i), sep
            printArr(arr[i], num + 4, sep)
        } else {
            printf "%*s%s : %s\n", num, " ", ansi("red", i), arr[i]
        }
    }
}

###
### Conversion function
###


# Convert a pseudo-multidimensional array to a multidimensional array
#    pArr : pseudo-multidimensional array
#    mArr : multidimensional array
# Note : 
#        - pseudo-multidimensional array mustn't have keys like that
#             pArr["a", "b"] = "v1"
#             pArr["a", "b", "c"] = "v2"
#          because this will be translated as :
#             mArr["a"]["b"] = "v1"
#             mArr["a"]["b"]["c"] = "v2"
#          which will raise an scalar/array error.
#        - Usually used for AST, because the problem described above 
#          can't happen.

function pseudoArrToMArr(pArr, mArr,    i, indices, ind) {
    asorti(pArr, ind)

    for (i in ind) {
        split(ind[i], indices, SUBSEP)
        assignValue(mArr, indices, pArr[ind[i]])
    }
}

# Assign value to a multidimensional-array element 
# Example :
#   ind[1] = "a", ind[2] = "b", ind[3] = "c"
#   The call of assignValue(arr, ind, 42) result that
#   arr["a"]["b"]["c"] = 42

function assignValue(arr, ind, val) {
    _assignValue(arr, ind, 1, val) 
}

# Recursive auxiliary function used for assignValue
function _assignValue(barr, indice, i, val) {

    if (i >= length(indice)) {
        barr[indice[i]] = val
        return 
    } else {
        initEleAsArr(barr, indice[i])
        _assignValue(barr[indice[i]], indice, i+1, val)
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

