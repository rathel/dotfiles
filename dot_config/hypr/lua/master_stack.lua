-- A master pane with a vertically scrolling stack on the right. Hyprland's
-- built-in master and scrolling layouts cannot be combined, so this keeps the
-- useful parts of both in a small Lua layout.
local masterStackState = {}
local masterStackRatio = 0.60
local masterStackGap = 3
-- Keep the master and stack columns logically adjacent so directional focus
-- can move between them; target placement still supplies the visual gaps.
local masterStackColumnGap = 0
local masterStackCardRatio = 0.70

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

local function masterStackTargetId(target)
    local window = target.window
    return window and tostring(window.stable_id) or tostring(target.index)
end

local function masterStackWorkspaceKey(targets)
    -- A layout target's primary window is optional. Scan the context instead
    -- of assuming the first target can identify the workspace.
    for _, target in ipairs(targets) do
        local window = target.window
        local workspace = window and window.workspace
        if workspace then
            return tostring(workspace.id)
        end
    end
    return "default"
end

local function masterStackIndexOf(values, value)
    for index, candidate in ipairs(values) do
        if candidate == value then
            return index
        end
    end
end

local function masterStackSync(ctx)
    local stateKey = masterStackWorkspaceKey(ctx.targets)
    local state = masterStackState[stateKey]
    local restoring = false
    if not state then
        state = { order = {}, master = nil, offset = 0 }
        masterStackState[stateKey] = state
        restoring = true
    end

    local targets = {}
    local present = {}
    for _, target in ipairs(ctx.targets) do
        local id = masterStackTargetId(target)
        targets[id] = target
        present[id] = true
    end

    local order = {}
    if restoring then
        -- A Lua reload destroys this table, but the layout targets retain their
        -- last boxes. Reconstruct the master and stack order from those boxes
        -- so a reload does not reset the visible stack position.
        local positioned = {}
        for _, target in ipairs(ctx.targets) do
            local box = target.box
            if box and box.w > 0 and box.h > 0 then
                table.insert(positioned, {
                    id = masterStackTargetId(target),
                    box = box,
                })
            end
        end

        table.sort(positioned, function(left, right)
            return left.box.w > right.box.w
        end)

        local looksLikeMasterStack = #positioned == #ctx.targets
            and (#positioned == 1 or positioned[1].box.w > positioned[2].box.w * 1.1)
        if looksLikeMasterStack then
            state.master = positioned[1].id
            table.insert(order, state.master)

            local stack = {}
            for index = 2, #positioned do
                table.insert(stack, positioned[index])
            end
            table.sort(stack, function(left, right)
                return left.box.y < right.box.y
            end)
            for _, entry in ipairs(stack) do
                table.insert(order, entry.id)
            end

            if #stack > 0 then
                local cardHeight = ctx.area.h
                if #stack > 1 then
                    cardHeight = math.max(1, ctx.area.h * masterStackCardRatio)
                end
                local maxOffset = math.max(0,
                    #stack * cardHeight + (#stack - 1) * masterStackGap - ctx.area.h)
                state.offset = clamp(ctx.area.y - stack[1].box.y, 0, maxOffset)
            end
        end
    end
    for _, id in ipairs(state.order) do
        if present[id] then
            table.insert(order, id)
        end
    end

    -- Insert newly opened windows before the existing stack, rather than at
    -- its bottom. Keep the order in which multiple windows arrive.
    local newIds = {}
    for _, target in ipairs(ctx.targets) do
        local id = masterStackTargetId(target)
        if not masterStackIndexOf(order, id) then
            table.insert(newIds, id)
        end
    end

    local insertAt
    for index, id in ipairs(order) do
        if id ~= state.master then
            insertAt = index
            break
        end
    end
    if not insertAt then
        insertAt = #order + 1
    end
    for _, id in ipairs(newIds) do
        table.insert(order, insertAt, id)
        insertAt = insertAt + 1
    end
    state.order = order

    -- New windows are inserted at the top of the stack. Reveal that position
    -- instead of retaining an offset that can place the focused window above
    -- the visible workspace.
    if #newIds > 0 then
        state.offset = 0
    end

    if not state.master or not present[state.master] then
        state.master = order[1]
        state.offset = 0
    end

    return state, targets
end

local function masterStackGeometry(area, stackCount)
    local masterWidth = (area.w - masterStackColumnGap) * masterStackRatio
    local stackX = area.x + masterWidth + masterStackColumnGap
    local stackWidth = math.max(1, area.w - masterWidth - masterStackColumnGap)
    local cardHeight = area.h

    if stackCount > 1 then
        cardHeight = math.max(1, area.h * masterStackCardRatio)
    end

    local step = cardHeight + masterStackGap
    local contentHeight = stackCount * cardHeight + math.max(0, stackCount - 1) * masterStackGap
    local maxOffset = math.max(0, contentHeight - area.h)

    return {
        masterWidth = math.max(1, masterWidth),
        stackX = stackX,
        stackWidth = stackWidth,
        cardHeight = cardHeight,
        step = step,
        maxOffset = maxOffset,
    }
end

local function masterStackRevealActive(state, targets, geometry, area)
    local stackIndex = 0
    for _, id in ipairs(state.order) do
        if id ~= state.master then
            stackIndex = stackIndex + 1
            local target = targets[id]
            if target and target.window and target.window.active then
                local centeredOffset = (stackIndex - 1) * geometry.step
                    + geometry.cardHeight / 2 - area.h / 2
                state.offset = clamp(centeredOffset, 0, geometry.maxOffset)
                return
            end
        end
    end
end

hl.layout.register("master-stack", {
    recalculate = function(ctx)
        if #ctx.targets == 0 then
            return
        end

        local state, targets = masterStackSync(ctx)
        local master = targets[state.master]
        if not master then
            return
        end

        local area = ctx.area
        local stackIds = {}
        for _, id in ipairs(state.order) do
            if id ~= state.master then
                table.insert(stackIds, id)
            end
        end

        if #stackIds == 0 then
            master:place(area)
            return
        end

        local geometry = masterStackGeometry(area, #stackIds)
        state.offset = clamp(state.offset or 0, 0, geometry.maxOffset)

        master:place({
            x = area.x,
            y = area.y,
            w = geometry.masterWidth,
            h = area.h,
        })

        for index, id in ipairs(stackIds) do
            local target = targets[id]
            if target then
                target:place({
                    x = geometry.stackX,
                    y = area.y + (index - 1) * geometry.step - state.offset,
                    w = geometry.stackWidth,
                    h = geometry.cardHeight,
                })
            end
        end
    end,

    layout_msg = function(ctx, message)
        if #ctx.targets == 0 then
            return true
        end

        local command, argument = message:match("^(%S+)%s*(.*)$")
        local state, targets = masterStackSync(ctx)
        local stackCount = #state.order - 1
        local geometry = masterStackGeometry(ctx.area, math.max(0, stackCount))

        if command == "scroll" then
            local amount = math.max(ctx.area.h * 0.45, geometry.cardHeight * 0.65)
            if argument == "up" then
                state.offset = (state.offset or 0) - amount
            elseif argument == "down" then
                state.offset = (state.offset or 0) + amount
            else
                return "master-stack: expected scroll up or scroll down"
            end
            state.offset = clamp(state.offset, 0, geometry.maxOffset)
        elseif command == "reset" then
            state.offset = 0
        elseif command == "reveal" then
            if argument ~= "" and argument ~= "active" then
                return "master-stack: expected reveal or reveal active"
            end
            masterStackRevealActive(state, targets, geometry, ctx.area)
        elseif command == "select" then
            -- Directional focus is unreliable here because the stack cards
            -- overlap. Select explicitly from the layout's stable order.
            if argument == "master" then
                local selected = targets[state.master]
                if selected and selected.window then
                    hl.dispatch(hl.dsp.focus({ window = selected.window }))
                end
            elseif stackCount > 0 then
                local stackIds = {}
                for _, id in ipairs(state.order) do
                    if id ~= state.master then
                        table.insert(stackIds, id)
                    end
                end

                local activeIndex
                for index, id in ipairs(stackIds) do
                    local target = targets[id]
                    if target and target.window and target.window.active then
                        activeIndex = index
                        break
                    end
                end

                local selectedIndex
                if argument == "next" then
                    selectedIndex = activeIndex and (activeIndex % #stackIds) + 1 or 1
                elseif argument == "previous" then
                    selectedIndex = activeIndex and ((activeIndex - 2) % #stackIds) + 1 or #stackIds
                else
                    return "master-stack: expected select master, select next, or select previous"
                end

                local selected = targets[stackIds[selectedIndex]]
                if selected and selected.window then
                    -- Explicit selection recenters the chosen stack card.
                    local centeredOffset = (selectedIndex - 1) * geometry.step
                        + geometry.cardHeight / 2 - ctx.area.h / 2
                    state.offset = clamp(centeredOffset, 0, geometry.maxOffset)
                    hl.dispatch(hl.dsp.focus({ window = selected.window }))
                end
            end
        elseif command == "reorder" then
            local stackIds = {}
            for _, id in ipairs(state.order) do
                if id ~= state.master then
                    table.insert(stackIds, id)
                end
            end

            local activeIndex
            for index, id in ipairs(stackIds) do
                local target = targets[id]
                if target and target.window and target.window.active then
                    activeIndex = index
                    break
                end
            end

            local delta
            if argument == "up" then
                delta = -1
            elseif argument == "down" then
                delta = 1
            else
                return "master-stack: expected reorder up or reorder down"
            end

            local newIndex = activeIndex and activeIndex + delta
            if newIndex and newIndex >= 1 and newIndex <= #stackIds then
                stackIds[activeIndex], stackIds[newIndex] = stackIds[newIndex], stackIds[activeIndex]
                state.order = { state.master }
                for _, id in ipairs(stackIds) do
                    table.insert(state.order, id)
                end

                -- Follow the moved window so it remains visible as it is
                -- reordered through the vertically scrolling stack.
                local centeredOffset = (newIndex - 1) * geometry.step
                    + geometry.cardHeight / 2 - ctx.area.h / 2
                state.offset = clamp(centeredOffset, 0, geometry.maxOffset)
            end
        elseif command == "promote" then
            for id, target in pairs(targets) do
                if target.window and target.window.active then
                    state.master = id
                    state.offset = 0
                    break
                end
            end
        else
            return "master-stack: expected select master, select next, select previous, reveal active, scroll up, scroll down, reset, reorder up, reorder down, or promote"
        end

        return true
    end,
})

-- Keep state workspace-local, discard it with removed workspaces, and ensure
-- ordinary focus paths such as ALT+TAB never leave the active card off-screen.
hl.on("workspace.removed", function(workspace)
    if workspace then
        masterStackState[tostring(workspace.id)] = nil
    end
end)

hl.on("window.active", function(window)
    if window and not window.floating then
        hl.dispatch(hl.dsp.layout("reveal active"))
    end
end)
