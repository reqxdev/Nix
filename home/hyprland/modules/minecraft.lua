local M = {}

function M.setup(hl)

    local MC_WORKSPACE = "2"

    local function is_minecraft(w)
    return w
          and w.class
           and (
		   w.class:match("^Minecraft")
		or w.class:match("^Polar")
		or w.class:match("^Polinex")
		or w.class:match("^Nebula")
		or w.class:match("^Taunahi")
               )
	    end

    local function get_columns(count)
        if count == 1 then
            return 1
        elseif count <= 4 then
            return 2
        elseif count <= 6 then
            return 3
        elseif count <= 8 then
            return 4
        elseif count == 9 then
            return 3
        elseif count <= 16 then
            return 4
        elseif count <= 25 then
            return 5
        end

        return math.ceil(math.sqrt(count))
    end

    hl.layout.register("mc-grid", {
        recalculate = function(ctx)
            local count = #ctx.targets

            if count == 0 then
                return
            end

            local columns = get_columns(count)

            for i, target in ipairs(ctx.targets) do
                target:place(
                    ctx:grid_cell(i, columns)
                )
            end
        end,
    })

    hl.on("window.open", function(w)
        if not is_minecraft(w) then
            return
        end

        hl.dispatch(
            hl.dsp.window.move({
                workspace = MC_WORKSPACE,
                follow = false,
                window = w,
            })
        )

        hl.dispatch(
            hl.dsp.window.float({
                action = "disable",
                window = w,
            })
        )

        local workspace = hl.get_workspace(MC_WORKSPACE)
        local layout = workspace and workspace.tiled_layout or "unknown"
   end)
end

return M
