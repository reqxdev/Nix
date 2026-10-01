local M = {}

function M.setup(hl)

	local variables = require("modules.variables")

	local mainMod = variables.mainMod
	local terminal = variables.terminal
	local fileManager = variables.fileManager
	local menu = variables.menu
	local browser = variables.browser
    hl.bind(
        mainMod .. " + K",
        hl.dsp.window.close()
    )

    hl.bind(
        mainMod .. " + B",
        hl.dsp.exec_cmd(browser)
    )

    hl.bind(
        mainMod .. " + T",
        hl.dsp.exec_cmd(terminal)
    )

    hl.bind(
        mainMod .. " + F",
        hl.dsp.exec_cmd(fileManager)
    )

    hl.bind(
	mainMod .. " + P",
	hl.dsp.exec_cmd("prismlauncher")
    )

    hl.bind(
        " + ALT  + T",
        hl.dsp.exec_cmd(terminal .. " -e yazi")
    )

    hl.bind(
        mainMod .. " + SPACE",
        hl.dsp.exec_cmd(menu .. " -show drun")
    )
    
    hl.bind(
        mainMod .. " + V",
        hl.dsp.exec_cmd("vesktop")
    )

    hl.bind(
    "PRINT",
    hl.dsp.exec_cmd("hyprshot -m region")
    ) 

    hl.bind(
        mainMod .. " + mouse:272",
        hl.dsp.window.drag(),
        { mouse = true }
    )

    hl.bind(
        mainMod .. " + mouse:273",
        hl.dsp.window.resize(),
        { mouse = true }
    )

end

return M
