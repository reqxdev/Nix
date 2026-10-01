local M = {}

function M.setup(hl)

    hl.monitor({
        output   = "DP-1",
        mode     = "1920x1080@300",
        position = "0x1080",
        scale    = "1",
    })

    hl.monitor({
        output   = "DP-2",
        mode     = "1920x1080@144",
        position = "1920x1080",
        scale    = "1",
    })

    hl.monitor({
        output    = "DP-3",
        mode      = "1920x1080@144",
        position  = "0x0",
        scale     = "1",
        transform = 2,
    })

end

return M
