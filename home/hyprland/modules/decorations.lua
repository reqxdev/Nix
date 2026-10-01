local M = {}

function M.setup(hl)

    hl.config({
        general = {
            gaps_in = 10,
            gaps_out = 10,

            border_size = 2,

            col = {
                active_border = "#3293d4",
                inactive_border = "#ffffff00",
            },

            resize_on_border = false,
            allow_tearing = false,
        },

        decoration = {
            rounding = 18,
            rounding_power = 3,

            active_opacity = 0.95,
            inactive_opacity = 0.9,

        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            ignore_opacity = true,

            noise = 0.008,
            contrast = 0.95,
            brightness = 0.72,
            vibrancy = 0.0,
            vibrancy_darkness = 0.0,
       },


        shadow = {
            enabled = true,
            range = 18,
            render_power = 3,
            color = "rgba(00000088)",
        },
    },
})
end

return M
