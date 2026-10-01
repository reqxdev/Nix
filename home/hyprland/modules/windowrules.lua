local M = {}

function M.setup(hl)

    -- Ignore maximize requests from all apps
    local suppressMaximizeRule = hl.window_rule({
        name = "suppress-maximize-events",

        match = {
            class = ".*",
        },

        suppress_event = "maximize",
    })

    -- Uncomment to disable this rule:
    -- suppressMaximizeRule:set_enabled(false)


    -- Fix some dragging issues with XWayland
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


    -- Hyprland-run window rule
    hl.window_rule({
        name = "move-hyprland-run",

        match = {
            class = "hyprland-run",
        },

        move  = "20 monitor_h-120",
        float = true,
    })


    -- Minecraft appearance only.
    -- Positioning and tiling are handled by minecraft.lua.
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
