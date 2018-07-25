
BEGIN {
    initAnsiCode()
    initLogLevelPriority()
}

## Display & Debugging:

# Initialize ANSI escape codes for SGR (Select Graphic Rendition).
# (ANSI X3.64 Standard Control Sequences)
# See: <https://en.wikipedia.org/wiki/ANSI_escape_code>
function initAnsiCode() {
    # Dumb terminal: no ANSI escape code whatsoever
    if (ENVIRON["TERM"] == "dumb") return

    AnsiCode["reset"]         = AnsiCode[0] = "\33[0m"

    AnsiCode["bold"]          = "\33[1m"
    AnsiCode["underline"]     = "\33[4m"
    AnsiCode["negative"]      = "\33[7m"
    AnsiCode["no bold"]       = "\33[22m" # SGR code 21 (bold off) not widely supported
    AnsiCode["no underline"]  = "\33[24m"
    AnsiCode["positive"]      = "\33[27m"

    AnsiCode["black"]         = "\33[30m"
    AnsiCode["red"]           = "\33[31m"
    AnsiCode["green"]         = "\33[32m"
    AnsiCode["yellow"]        = "\33[33m"
    AnsiCode["blue"]          = "\33[34m"
    AnsiCode["magenta"]       = "\33[35m"
    AnsiCode["cyan"]          = "\33[36m"
    AnsiCode["gray"]          = "\33[37m"

    AnsiCode["default"]       = "\33[39m"

    AnsiCode["dark gray"]     = "\33[90m"
    AnsiCode["light red"]     = "\33[91m"
    AnsiCode["light green"]   = "\33[92m"
    AnsiCode["light yellow"]  = "\33[93m"
    AnsiCode["light blue"]    = "\33[94m"
    AnsiCode["light magenta"] = "\33[95m"
    AnsiCode["light cyan"]    = "\33[96m"
    AnsiCode["white"]         = "\33[97m"
}

function initLogLevelPriority() {
    LogLevelPriority["trace"]   = 1
    LogLevelPriority["debug"]   = 2
    LogLevelPriority["info"]    = 3
    LogLevelPriority["warning"] = 4
    LogLevelPriority["error"]   = 5
    LogLevelPriority["off"]     = 6
}

# Return ANSI escaped string.
function ansi(code, text) {
    switch (code) {
    case "bold":
        return AnsiCode[code] text AnsiCode["no bold"]
    case "underline":
        return AnsiCode[code] text AnsiCode["no underline"]
    case "negative":
        return AnsiCode[code] text AnsiCode["positive"]
    default:
        return AnsiCode[code] text AnsiCode[0]
    }
}

#TODO: prefix it by context to localize error (wrapped functions)

# Print trace message.
function trace(text) {
    if (LogLevelPriority[getOption("debug")] <= LogLevelPriority["trace"]){
        print ansi("dark gray", "[TRCE] " ansi("reset", text)) > STDERR
    }
}

# Print debug message.
function debug(text) {
    if (LogLevelPriority[getOption("debug")] <= LogLevelPriority["debug"]){
        print ansi("bold", ansi("green", "[DBG]  " ansi("reset", text))) > STDERR
    }
}

# Print info message.
function info(text) {
    if (LogLevelPriority[getOption("debug")] <= LogLevelPriority["info"]){
        print ansi("bold", ansi("white", "[INFO] " ansi("reset", text))) > STDERR
    }
}

# Print warning message.
function warn(text) {
    if (LogLevelPriority[getOption("debug")] <= LogLevelPriority["warning"]){
        print ansi("bold", ansi("magenta", "[WARN] " ansi("reset", text))) > STDERR
    }
}

# Print error message.
function error(text) {
    if (LogLevelPriority[getOption("debug")] <= LogLevelPriority["error"]){
        print ansi("bold", ansi("red", "[ERR]  " ansi("reset", text))) > STDERR
    }
}


