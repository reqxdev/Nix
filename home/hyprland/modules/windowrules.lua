local M = {}

function M.setup(hl)

    local suppressMaximizeRule = hl.window_rule({
        name = "suppress-maximize-events",

        match = {
            class = ".*",
        },

        suppress_event = "maximize",
    })



    hl.window_rule({
        name = "fix-xwayland-drags",

        match = {
            class      = "^$",
            title      = "^$",
            xwayland   = true,
            float      = true,
            fullscreen = false,
            pin        = false,
        },

        no_focus = true,
    })


    hl.window_rule({
        name = "move-hyprland-run",

        match = {
            class = "hyprland-run",
        },

        move  = "20 monitor_h-120",
        float = true,
    })


    hl.window_rule({
        name = "minecraft-grid-style",

        match = {
            class = "^Minecraft",
        },

        no_blur = true,
        no_anim = true,
        opacity = "1.0 override",
    })

    hl.layer_rule({
    name = "rofi-glass",
    match = {
        namespace = "rofi",
    },
    blur = true,
    ignore_alpha = 0.10,
})

end

return M
