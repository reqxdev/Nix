local M = {}

function M.setup(hl)

    -- Minecraft Auto Sort
    hl.workspace_rule({
        workspace = "2",
        monitor = "DP-2",
        default = true,
        persistent = true,

        layout = "lua:mc-grid",

        gaps_in = 0,
        gaps_out = 1,

        no_border = true,
        no_shadow = true,
        no_rounding = true,
    })

end

return M
