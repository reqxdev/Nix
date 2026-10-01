local M = {}

function M.setup(hl)
    hl.env("XCURSOR_THEME", "Osu")
    hl.env("XCURSOR_SIZE", "32")
    hl.env("HYPRCURSOR_SIZE", "32")

    hl.config({
        input = {
            kb_layout = "us",
            kb_variant = "",
            kb_model = "",
            kb_options = "",
            kb_rules = "",

            follow_mouse = 1,
            sensitivity = 0,

            touchpad = {
                natural_scroll = false,
            },
        },
    })

    hl.gesture({
        fingers = 3,
        direction = "horizontal",
        action = "workspace",
    })

    hl.device({
        name = "epic-mouse-v1",
        sensitivity = -0.5,
    })

end

return M
