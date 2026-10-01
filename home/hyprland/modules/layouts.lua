local M = {}

function M.setup(hl)

    hl.config({
        general = {
            -- Default layout for normal workspaces.
            -- Minecraft workspace 1 overrides this with lua:mc-grid.
            layout = "dwindle",
        },

        dwindle = {
            preserve_split = true,
        },

        master = {
            new_status = "master",
        },

        scrolling = {
            fullscreen_on_one_column = true,
        },
    })

end

return M
