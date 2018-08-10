#! /usr/bin/gawk -f

function initQueue(queue){
    queue[0][0]
    delete queue[0]
}

function enqueue(queue, ele, key,   i){
    for (i in queue) {
        # loop to the rear
    }
    queue[i + 1][key] = ele
}

function dequeue(queue,    frontEle, front){

    if (isEmpty(queue)) return NULLSTR

    frontEle = getFrontValue(queue)

    for (front in queue) {
        delete queue[front]
        break
    }
    return frontEle
}

function getFrontValue(queue,    front, i) {

    if (isEmpty(queue)) return NULLSTR

    for (front in queue) {
        for (i in queue[front]) {
            return queue[front][i]
        }
    }
}

function getFrontKey(queue,    front, i) {

    if (isEmpty(queue)) return NULLSTR

    for (front in queue) {
        for (i in queue[front]) {
            return i
        }
    }
}
