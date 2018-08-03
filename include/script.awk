
function initScript(    file, line, script, temp) {
    # Find the initialization file
    file = ".optime"
    if (!fileExists(file)) {
        file = ENVIRON["HOME"] "/.optime/init.ca"
        if (!fileExists(file)) {
            file = ENVIRON["XDG_CONFIG_HOME"] "/optime/init.ca"
            if (!fileExists(file)) {
                file = ENVIRON["HOME"] "/.config/optime/init.ca"
                if (!fileExists(file)) {
                    file = "/etc/optime"
                    if (!fileExists(file)) return
                }
            }
        }
    }

    InitScript = file
    script = NULLSTR
    while (getline line < InitScript)
        script = script "\n" line
    loadOptions(script)

}


