#! /usr/bin/gawk -f

@include "commons.awk"
@include "array.awk"

#TODO: rename to ordered hash map ?
#TODO: add error managment

function initStack(stack){
    stack[0][0] = NULLSTR
}

function isEmpty(stack){
    return length(stack) == 1
}

function getTopValue(stack,    i) {
    for (i in stack[length(stack) - 1]) {
        return stack[length(stack) - 1][i]
    }
}

function getTopKey(stack,    i) {
    for (i in stack[length(stack) - 1]) {
        if (i == 0) return NULLSTR
        else return i
    }
}

function pop(stack,    topEle){
    if (isEmpty(stack)) return NULLSTR
    topEle = getTopValue(stack)
    delete stack[length(stack) - 1]
    return topEle
}

function popTillKeyEqual(stack, key) {
    while (!isEmpty(stack) && getTopKey(stack) != key) {
        pop(stack)
    }
}

function push(stack, ele, key){
    stack[length(stack)][key] = ele
}

function printStack(stack){
    for (i in stack) {
        if (i == 0){
            continue
        }
        for (j in stack[i]){
            print j":"stack[i][j]
        }
    }
}


function updateTopValue(stack, newValue){
    for (i in stack[length(stack) - 1]){
        stack[length(stack) -  1][i] = newValue
        return
    }
}
