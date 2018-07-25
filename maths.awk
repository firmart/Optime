
function max(a, b){
    return (a > b ? a : b)
}

function min(a, b){
    return (a < b ? a : b)
}

function abs(num) {
    if (num < 0) return -num
    else return num
}

function floor(num) {
    return int(num)
}

function ceil(num) {
    return floor(num) + 1
}


function log10(num){
    return log(num)/log(10)
}

function getExponent(num) {
    return floor(log10(abs(num)))
}

function getSignificand(num) {
   return num / 10**getExponent(num) 
}
