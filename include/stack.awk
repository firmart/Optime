#! /usr/bin/gawk -f


#TODO: rename to ordered hash map ?
#TODO: add error managment


function initStack(stack){
    stack[0][0]
    delete stack[0]
}


function getTopValue(stack,    i) {

    if (isEmpty(stack)) return NULLSTR

    for (i in stack[length(stack)]) {
        return stack[length(stack)][i]
    }
}

function getTopKey(stack,    i) {

    if (isEmpty(stack)) return NULLSTR

    for (i in stack[length(stack)]) {
        return i
    }
}

function pop(stack,    topEle){
    if (isEmpty(stack)) return NULLSTR
    topEle = getTopValue(stack)
    delete stack[length(stack)]
    return topEle
}

function popTillKeyEqual(stack, key) {
    while (!isEmpty(stack) && getTopKey(stack) != key) {
        pop(stack)
    }
}

function push(stack, ele, key){
    stack[length(stack) + 1][key] = ele
}

function updateTopValue(stack, newValue){
    for (i in stack[length(stack)]){
        stack[length(stack)][i] = newValue
        return
    }
}

