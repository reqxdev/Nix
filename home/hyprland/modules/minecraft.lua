local M = {}

function M.setup(hl)

    local MC_WORKSPACE = "2"
    local order = {}

    local function is_minecraft(w)
        return w and w.class and (
            w.class == "com.mojang.minecraft"
            or w.class:match("^Minecraft")
            or w.class:match("^Nebula")
            or w.class:match("^Polar")
            or w.class:match("^Polinex")
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

    local function target_id(target)
        return target.window and tostring(target.window.stable_id) or "target:" .. target.index
    end

    local function insert_at_cursor(ctx, targets, columns)
        local cursor = hl.get_cursor_pos()
        local area = ctx.area

        if not cursor or #targets == 0
            or cursor.x < area.x or cursor.x >= area.x + area.w
            or cursor.y < area.y or cursor.y >= area.y + area.h then
            return
        end

        local rows = math.ceil(#targets / columns)
        local column = math.floor((cursor.x - area.x) * columns / area.w)
        local row = math.floor((cursor.y - area.y) * rows / area.h)
        local slot = math.min(row * columns + column + 1, #targets)

        for i, target in ipairs(targets) do
            if target.window and target.window.active then
                table.insert(targets, slot, table.remove(targets, i))
                return
            end
        end
    end

    local function arrange(ctx, drop)
        local targets = ctx.targets
        local columns = get_columns(#targets)

        table.sort(targets, function(a, b)
            local first = order[target_id(a)] or math.huge
            local second = order[target_id(b)] or math.huge
            if first == second then
                return a.index < b.index
            end
            return first < second
        end)

        if drop then
            insert_at_cursor(ctx, targets, columns)
        end

        order = {}
        for i, target in ipairs(targets) do
            order[target_id(target)] = i
            if not drop then
                target:place(ctx:grid_cell(i, columns))
            end
        end
    end

    local function layout_message(ctx, msg)
        if msg == "drop" then
            arrange(ctx, true)
            return true
        end
    end

    local function drop_window()
        local window = hl.get_active_window()
        local workspace = window and window.workspace

        if workspace and workspace.tiled_layout == "lua:mc-grid" and not window.floating then
            hl.dispatch(hl.dsp.layout("drop"))
        end
    end

    local function open_window(w)
        if not is_minecraft(w) then
            return
        end

        hl.dispatch(hl.dsp.window.move({ workspace = MC_WORKSPACE, follow = false, window = w }))
        hl.dispatch(hl.dsp.window.float({ action = "disable", window = w }))
    end

    hl.layout.register("mc-grid", {
        recalculate = arrange,
        layout_msg = layout_message,
    })

    hl.bind(require("modules.variables").mainMod .. " + mouse:272", drop_window, { drag = true })
    hl.on("window.open", open_window)
end

return M
