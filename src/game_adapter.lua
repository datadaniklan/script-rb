-- Build A Boat adapter. The game's private tool protocol may change.
-- No inventory writes, local-only replacement blocks, or uncertain-call retries.
local Adapter = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local world = game:GetService("Workspace")
local env = (getgenv and getgenv()) or _G
env.__ImageBuilderFlight = env.__ImageBuilderFlight or {pending = 0, busy = false}
local flight = env.__ImageBuilderFlight
local destroyed = false
local allowed = {}
for _, name in ipairs({"WoodBlock", "StoneBlock", "RustedBlock", "MetalBlock",
    "ConcreteBlock", "MarbleBlock", "TitaniumBlock", "GoldBlock", "PlasticBlock",
    "GlassBlock", "IceBlock", "SandBlock", "GrassBlock", "ObsidianBlock",
    "FabricBlock", "BrickBlock", "NeonBlock"}) do allowed[name] = true end

local function getTool(name)
    local character = player.Character
    local backpack = player:FindFirstChildOfClass("Backpack")
    return (character and character:FindFirstChild(name)) or (backpack and backpack:FindFirstChild(name))
end

local function getZone()
    for _, item in ipairs(world:GetChildren()) do
        local color = item:FindFirstChild("TeamColor")
        if item:IsA("BasePart") and color and color:IsA("BrickColorValue")
            and color.Value == player.TeamColor then return item end
    end
end

local function ownFolder()
    local blocks = world:FindFirstChild("Blocks")
    return blocks and blocks:FindFirstChild(player.Name)
end

local function stock(name)
    local data = player:FindFirstChild("Data")
    local value = data and data:FindFirstChild(name)
    return value and value:IsA("IntValue") and value.Value or 0
end

function Adapter.available(name)
    local data = player:FindFirstChild("Data")
    local value = data and data:FindFirstChild(name)
    local used = value and value:FindFirstChild("Used")
    return math.max(0, stock(name) - (used and tonumber(used.Value) or 0))
end

function Adapter.inventory()
    local result = {}
    for name in pairs(allowed) do
        local amount = Adapter.available(name)
        if stock(name) > 0 then table.insert(result, {name = name, count = amount}) end
    end
    table.sort(result, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        return a.name < b.name
    end)
    return result
end

local function rectangles(plan)
    if plan.rectangles then return plan.rectangles end
    local result = {}
    for _, cell in ipairs(plan.cells or {}) do
        table.insert(result, {x = cell.x, y = cell.y, w = 1, h = 1, color = cell.color})
    end
    return result
end

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function integer(value, minimum, maximum)
    return finite(value) and value % 1 == 0 and value >= minimum and value <= maximum
end

function Adapter.validate(plan)
    if destroyed then return false, "This builder has been closed. Run Image_Builder.lua again." end
    if game.PlaceId ~= 537413528 then return false, "Join Build A Boat For Treasure first." end
    if flight.busy or flight.pending > 0 then
        return false, "A previous build request is still running. Wait for it to finish."
    end
    if type(plan) ~= "table" or not allowed[plan.block_type] then
        return false, "Choose an available solid block type."
    end
    if not finite(plan.pixel_studs) or plan.pixel_studs < 0.001 or plan.pixel_studs > 32 then
        return false, "Use a pixel size between 0.001 and 32 studs. Pixel sizes below 0.001 are not supported by this builder; the game's minimum may be larger."
    end
    if not integer(plan.columns, 1, 250000) or not integer(plan.rows, 1, 250000)
        or plan.columns * plan.rows > 250000 or not finite(plan.width_studs) or not finite(plan.height_studs)
        or math.abs(plan.width_studs - plan.columns * plan.pixel_studs) > 0.001
        or math.abs(plan.height_studs - plan.rows * plan.pixel_studs) > 0.001
        or (plan.rectangles ~= nil and type(plan.rectangles) ~= "table")
        or (plan.rectangles == nil and type(plan.cells) ~= "table") then
        return false, "The image plan has invalid dimensions. Convert it again."
    end
    local items = rectangles(plan)
    if #items == 0 then return false, "The image contains no visible pixels." end
    if #items > 250000 then return false, "Too many blocks; increase pixel size." end
    for _, rect in ipairs(items) do
        if type(rect) ~= "table" or not integer(rect.x, 0, plan.columns - 1)
            or not integer(rect.y, 0, plan.rows - 1) or not integer(rect.w, 1, plan.columns)
            or not integer(rect.h, 1, plan.rows) or rect.x + rect.w > plan.columns
            or rect.y + rect.h > plan.rows or rect.w * plan.pixel_studs > 32.001
            or rect.h * plan.pixel_studs > 32.001 or type(rect.color) ~= "table"
            or not integer(rect.color[1], 0, 255) or not integer(rect.color[2], 0, 255)
            or not integer(rect.color[3], 0, 255) then
            return false, "The image plan has an invalid block. Convert it again."
        end
    end
    for _, name in ipairs({"BuildingTool", "ScalingTool", "PaintingTool"}) do
        local tool = getTool(name)
        if not tool or not tool:IsA("Tool") or not tool:FindFirstChild("RF") or not tool.RF:IsA("RemoteFunction") then
            return false, "Your " .. name .. " is required and must be in your inventory."
        end
    end
    if stock(plan.block_type) < 1 then return false, "No " .. plan.block_type .. " available." end
    if not ownFolder() then return false, "Your build folder is not ready yet." end
    local zone = getZone()
    if not zone then return false, "Your team's build plot was not found." end
    local launched = zone:FindFirstChild("Launched")
    if launched and launched.Value then return false, "Return to the build plot before placing an image." end
    return true, string.format("%d placements; inventory shows %d %s. Scaling cost is checked by the game.",
        #items, stock(plan.block_type), plan.block_type)
end

-- origin is bottom-center of the upright wall. Rows run down from the image top.
function Adapter.geometry(plan, rect, origin)
    local step = plan.pixel_studs
    local size = Vector3.new(rect.w * step, rect.h * step, math.max(0.05, math.min(step, 1)))
    local x = (rect.x + rect.w / 2) * step - plan.width_studs / 2
    local y = plan.height_studs - (rect.y + rect.h / 2) * step
    return origin * CFrame.new(x, y, 0), size
end

function Adapter.materialNeed(plan)
    if type(plan) ~= "table" or not finite(plan.pixel_studs) or plan.pixel_studs <= 0
        or (plan.rectangles ~= nil and type(plan.rectangles) ~= "table")
        or (plan.rectangles == nil and type(plan.cells) ~= "table") then return 0 end
    if plan.rectangles == nil then
        for _, cell in ipairs(plan.cells) do if type(cell) ~= "table" then return 0 end end
    end
    local total = 0
    local step, depth = plan.pixel_studs, math.max(0.05, math.min(plan.pixel_studs, 1))
    for _, rect in ipairs(rectangles(plan)) do
        if type(rect) ~= "table" or not finite(rect.w) or not finite(rect.h)
            or rect.w <= 0 or rect.h <= 0 then return 0 end
        local cost = rect.w * step * rect.h * step * depth / 8
        if not finite(cost) then return 0 end
        total += math.max(math.ceil(cost), 1)
    end
    return total
end

function Adapter.canPlace(plan, origin)
    local zone = getZone()
    if not zone then return false, "Your build plot was not found." end
    local depth = math.max(0.05, math.min(plan.pixel_studs, 1))
    for _, x in ipairs({-plan.width_studs / 2, plan.width_studs / 2}) do
        for _, z in ipairs({-depth / 2, depth / 2}) do
            local corner = zone.CFrame:PointToObjectSpace(origin:PointToWorldSpace(Vector3.new(x, 0, z)))
            if math.abs(corner.X) > zone.Size.X / 2 or math.abs(corner.Z) > zone.Size.Z / 2 then
                return false, "Move the whole wall inside your team's build plot."
            end
        end
    end
    return true, "Click to build here. Q / E rotate."
end

function Adapter.build(plan, origin, options)
    options = options or {}
    local toolMode = options.toolMode or "background"
    if toolMode ~= "background" and toolMode ~= "compatible" then
        return {ok = false, message = "Choose Compatible or Hands free tool mode.", completed = 0, total = 0}
    end
    local valid, reason = Adapter.validate(plan)
    if not valid then return {ok = false, message = reason, completed = 0, total = 0} end
    valid, reason = Adapter.canPlace(plan, origin)
    if not valid then return {ok = false, message = reason, completed = 0, total = 0} end
    local items = rectangles(plan)
    local required = Adapter.materialNeed(plan)
    local presets = {Normal = {rate = 8, workers = 1, batch = 4},
        Fast = {rate = 60, workers = 4, batch = 32}, Turbo = {rate = 120, workers = 8, batch = 64},
        Rapid = {rate = 120, workers = 16, maxRate = 600, maxWorkers = 64, batch = 256, cohort = 16, paint = 32}}
    local selectedSpeed = presets[options.speed] and options.speed or "Fast"
    local speedMode = toolMode == "compatible" and selectedSpeed == "Rapid" and "Fast" or selectedSpeed
    local speed = presets[speedMode]
    local wallStarted
    local completed, created, nextSend, failure = 0, 0, 0, nil
    local folder, zone, character = ownFolder(), getZone(), player.Character
    local originalTeam = player.TeamColor
    local existing, claimed, added = {}, {}, {}
    local progress = options.onProgress or function() end
    local shouldCancel = options.shouldCancel or function() return false end
    local getManualSelection = type(options.getManualToolSelection) == "function" and options.getManualToolSelection or nil
    local connection
    local preparing, cleanupMode, helper, helperPossible = false, false, nil, false
    local deleteAttempted = false
    local originalHeld, lastPrepTool, restoreAfterPending, prepSample
    local holder
    local pipelineActive, dispatchReservations, manualDrain = false, 0, false
    local dispatchTokens, tokenUpdatedAt = 12, os.clock()
    local observedNew, observedCount, observedMaterialCount, batchNewCount = {}, 0, 0, 0
    local diagnostics = {tool_mode = toolMode, phase = "starting", requests_sent = 0,
        selected_speed_mode = selectedSpeed, speed_mode = speedMode, effective_request_rate = speed.rate,
        worker_limit = speed.workers, batch_limit = speed.batch, peak_pending = 0, peak_geometry_jobs = 0,
        pipeline_version = speedMode == "Rapid" and 2 or 0, pipeline_windows = 0,
        pipeline_peak_ready = 0, pipeline_peak_active = 0, pipeline_paint_batches = 0, manual_drains = 0,
        rpc_completed = 0, rpc_latency_total_seconds = 0, rpc_latency_max_seconds = 0,
        max_request_rate = speed.maxRate or speed.rate, max_pending_limit = speed.maxWorkers or speed.workers,
        adaptive_upshifts = 0, adaptive_downshifts = 0, adaptive_peak_rate = speed.rate,
        adaptive_peak_workers = speed.workers, rpc_latency_ewma_seconds = 0,
        monitor_delay_ewma_seconds = 0, monitor_delay_max_seconds = 0,
        replication_peak_waiting = 0, replication_pause_count = 0, verification_budget_seconds = 0,
        verification_checks_peak = 0,
        preparation_request_rate = math.min(speed.rate, 120),
        observed_new_models = 0, observed_material_models = 0, returned_type = "none",
        infinite_requested = options.infiniteBlocks == true, material_required = required,
        inventory_before = Adapter.available(plan.block_type), prep_requests = 0,
        prep_version = 2, prep_rounds = 0, prep_scale_requests = 0, prep_gain = 0, prep_samples = {}}
    local adaptive = {rate = speed.rate, workers = speed.workers, latency = nil, recentMax = 0,
        healthyCalls = 0, nextIncrease = os.clock() + 3, lastDecrease = -math.huge,
        pausePlacements = false, overshoot = 0}
    flight.busy = true

    local function contextChanged()
        return player.Character ~= character or player.TeamColor ~= originalTeam
            or not folder.Parent or (zone:FindFirstChild("Launched") and zone.Launched.Value)
    end
    local function stopped()
        if cleanupMode then return contextChanged() or flight.pending > 0 end
        return destroyed or failure ~= nil or shouldCancel() or contextChanged()
    end
    local function report(message)
        pcall(progress, completed, #items, message)
    end
    local function fail(message)
        failure = failure or message
        return false
    end
    local function setAdaptiveLimits(rate, workers)
        adaptive.rate, adaptive.workers = rate, workers
        diagnostics.effective_request_rate, diagnostics.worker_limit = rate, workers
        diagnostics.adaptive_peak_rate = math.max(diagnostics.adaptive_peak_rate, rate)
        diagnostics.adaptive_peak_workers = math.max(diagnostics.adaptive_peak_workers, workers)
    end
    local function slowDown()
        if speedMode ~= "Rapid" then return end
        local now = os.clock()
        adaptive.nextIncrease = now + 5
        adaptive.healthyCalls = 0
        if now - adaptive.lastDecrease < 0.5 then return end
        adaptive.lastDecrease = now
        local rate = math.max(20, math.floor(adaptive.rate * 0.6))
        local workers = math.max(4, math.floor(adaptive.workers / 2))
        if rate ~= adaptive.rate or workers ~= adaptive.workers then
            setAdaptiveLimits(rate, workers)
            diagnostics.adaptive_downshifts += 1
        end
    end
    local function observeLatency(elapsed)
        if speedMode ~= "Rapid" or preparing then return end
        adaptive.latency = adaptive.latency and adaptive.latency * 0.8 + elapsed * 0.2 or elapsed
        adaptive.recentMax = math.max(elapsed, adaptive.recentMax * 0.98)
        diagnostics.rpc_latency_ewma_seconds = adaptive.latency
        if elapsed > 1 or adaptive.latency > 0.65 then slowDown()
        elseif elapsed < 0.45 then adaptive.healthyCalls += 1 end
    end
    local function verificationBudget()
        if speedMode ~= "Rapid" then return 4 end
        local budget = math.max(8, math.min(24, 4 + (adaptive.latency or 0) * 4 + adaptive.recentMax * 1.5))
        diagnostics.verification_budget_seconds = math.max(diagnostics.verification_budget_seconds, budget)
        return budget
    end
    -- Reserve exact owned instances, not every tool with a matching name. Direct
    -- parenting leaves tools available for remotes. Only an explicitly selected
    -- native controller is enabled; the other borrowed controllers stay silent.
    local function engageHolder()
        if toolMode ~= "background" then return true end
        local backpack = player:FindFirstChildOfClass("Backpack")
        if not character or not backpack or contextChanged() then
            return fail("Wait for your character and backpack before using Hands free mode.")
        end
        local names = {"BuildingTool", "ScalingTool", "PaintingTool"}
        if diagnostics.infinite_requested and Adapter.available(plan.block_type) < required then
            table.insert(names, "DeleteTool")
        end
        holder = {tools = {}, scripts = {}, guis = {}, links = {}, active = true,
            backpack = backpack, playerGui = player:FindFirstChildOfClass("PlayerGui"), selectionChanged = false}
        for _, name in ipairs(names) do
            local tool = getTool(name)
            if not tool or not tool:IsA("Tool") or not tool:FindFirstChild("RF")
                or not tool.RF:IsA("RemoteFunction") then
                return fail("Hands free mode needs your owned " .. name .. ". No requests were sent.")
            end
            holder.tools[name] = {tool = tool, parent = tool.Parent}
        end
        local guiNames = {BuildGui = "BuildingTool", PaintGui = "PaintingTool", ScaleToolDisplayGui = "ScalingTool"}
        local function silence(item, tool)
            local manual = holder.manualTool
            local selected = manual and (tool == manual or (not tool and guiNames[item.Name] == manual.Name))
            if item:IsA("LocalScript") then
                if holder.scripts[item] == nil then
                    holder.scripts[item] = {value = item.Disabled, tool = tool}
                end
                local desired = selected and holder.scripts[item].value or not selected
                if item.Disabled ~= desired then item.Disabled = desired end
            elseif item:IsA("ScreenGui") then
                if holder.guis[item] == nil then holder.guis[item] = {value = item.Enabled, tool = tool} end
                local desired = selected and holder.guis[item].value or false
                if item.Enabled ~= desired then item.Enabled = desired end
            end
        end
        function holder.ensure(name)
            if holder.suppressSupersededManual then holder.suppressSupersededManual() end
            local record = holder.tools[name]
            local tool = record and record.tool
            if not holder.active or contextChanged() or not tool or getTool(name) ~= tool
                or (tool.Parent ~= character and tool.Parent ~= backpack) then
                return fail("A borrowed build tool was removed or replaced. Stopped.")
            end
            if not record.scanned then
                for _, item in ipairs(tool:GetDescendants()) do silence(item, tool) end
                record.scanned = true
            end
            if tool.Parent ~= character then tool.Parent = character end
            return tool.Parent == character or fail("Could not hold " .. name .. " for background building.")
        end
        local function listen(signal, callback)
            table.insert(holder.links, signal:Connect(function(item)
                if not holder.active or contextChanged() then return end
                local ok, message = pcall(callback, item)
                if not ok then fail("Could not keep build tools reserved: " .. tostring(message)) end
            end))
        end
        function holder.borrow(name)
            local record = holder.tools[name]
            if not record then
                local tool = getTool(name)
                if not tool or not tool:IsA("Tool") or not tool:FindFirstChild("RF")
                    or not tool.RF:IsA("RemoteFunction") then
                    return fail("Hands free preparation needs your owned " .. name .. ". No preparation requests were sent.")
                end
                record = {tool = tool, parent = tool.Parent}
                holder.tools[name] = record
                diagnostics.borrowed_tools = (diagnostics.borrowed_tools or #names) + 1
            end
            if not record.listening then
                listen(record.tool.DescendantAdded, function(item) silence(item, record.tool) end)
                record.listening = true
            end
            return holder.ensure(name)
        end
        listen(backpack.ChildAdded, function(tool)
            local record = holder.tools[tool.Name]
            if record and record.tool == tool then
                -- Humanoid:EquipTool may still be moving the other tools while
                -- ChildAdded fires. Reclaim after that operation has finished.
                task.defer(function()
                    if holder.active and not holder.transitioning and not contextChanged() and tool.Parent == backpack then
                        local ok, message = pcall(holder.ensure, tool.Name)
                        if not ok then fail(tostring(message)) end
                    end
                end)
            end
        end)
        listen(character.ChildAdded, function(tool)
            if tool:IsA("Tool") then
                local record = holder.tools[tool.Name]
                if not record or record.tool ~= tool then holder.selectionChanged = true end
            end
        end)
        if holder.playerGui then
            for _, gui in ipairs(holder.playerGui:GetChildren()) do
                if guiNames[gui.Name] and gui:IsA("ScreenGui") then silence(gui) end
            end
            listen(holder.playerGui.ChildAdded, function(gui)
                if guiNames[gui.Name] and gui:IsA("ScreenGui") then silence(gui) end
            end)
        end
        for name in pairs(holder.tools) do
            if not holder.borrow(name) then return false end
        end
        -- Selection comes from exact owned instances captured by the existing
        -- hotbar, not from our own parenting events. Several tools are held for
        -- remotes, but only the explicitly selected one's native controller runs.
        holder.manualRevision = 0
        function holder.suppressSupersededManual()
            local old = holder.manualTool
            if not getManualSelection or holder.transitioning or not old or old.Parent ~= backpack then return end
            local read, selection = pcall(getManualSelection)
            if not read or type(selection) ~= "table" or not integer(selection.revision, 0, 2147483647)
                or selection.revision <= holder.manualRevision then return end
            -- Native selection has already unequipped this controller. Prevent
            -- a deferred reclaim from restarting it beside the newly chosen tool
            -- while an automation batch still has remote requests in flight.
            holder.manualTool = nil
            for _, item in ipairs(old:GetDescendants()) do silence(item, old) end
            for gui, state in pairs(holder.guis) do
                if not state.tool and gui.Parent == holder.playerGui then silence(gui) end
            end
            diagnostics.manual_tool_name = "none"
        end
        function holder.applyManualSelection()
            if not getManualSelection or not holder.active or flight.pending > 0 or holder.transitioning then return true end
            local read, selection = pcall(getManualSelection)
            diagnostics.manual_selection_supported = read and type(selection) == "table" and selection.available ~= false
            if not read or type(selection) ~= "table" or not integer(selection.revision, 0, 2147483647)
                or selection.revision <= holder.manualRevision then return true end
            local chosen = selection.tool
            if chosen ~= nil and (typeof(chosen) ~= "Instance" or not chosen:IsA("Tool")
                or (chosen.Parent ~= character and chosen.Parent ~= backpack)) then return true end
            local record = chosen and holder.tools[chosen.Name]
            local selected = record and record.tool == chosen and chosen or nil
            local previous = holder.manualTool
            holder.transitioning = true
            -- Unequipped must run while the old native controller is enabled:
            -- it removes previews, input listeners and selection handles.
            if previous and previous.Parent == character then previous.Parent = backpack end
            task.wait()
            if stopped() then holder.transitioning = false; return false end
            holder.manualTool = nil
            for _, borrowed in pairs(holder.tools) do
                for _, item in ipairs(borrowed.tool:GetDescendants()) do silence(item, borrowed.tool) end
            end
            for gui, state in pairs(holder.guis) do
                if not state.tool and gui.Parent == holder.playerGui then silence(gui) end
            end
            if selected and selected.Parent == character then selected.Parent = backpack end
            holder.manualTool = selected
            for name, borrowed in pairs(holder.tools) do
                if borrowed.tool ~= selected and not holder.ensure(name) then holder.transitioning = false; return false end
            end
            if selected then
                for _, item in ipairs(selected:GetDescendants()) do silence(item, selected) end
                for gui, state in pairs(holder.guis) do
                    if not state.tool and gui.Parent == holder.playerGui then silence(gui) end
                end
                -- Restarted LocalScripts need time to connect Equipped before
                -- a fresh native equip event initializes their normal controls.
                task.wait()
                if stopped() then holder.transitioning = false; return false end
                local function superseded()
                    local ok, latest = pcall(getManualSelection)
                    return ok and type(latest) == "table" and integer(latest.revision, 0, 2147483647)
                        and latest.revision > selection.revision
                end
                local function deferLatestSelection()
                    if selected.Parent == character then selected.Parent = backpack; task.wait() end
                    holder.manualTool = nil
                    for _, item in ipairs(selected:GetDescendants()) do silence(item, selected) end
                    for gui, state in pairs(holder.guis) do
                        if not state.tool and gui.Parent == holder.playerGui then silence(gui) end
                    end
                    -- Keep the original remote ready, but do not turn a stale
                    -- selection's controller back on. Read the new revision at
                    -- the next normal boundary without delaying the whole job.
                    local ready = holder.ensure(selected.Name)
                    holder.transitioning = false
                    diagnostics.manual_tool_name = "none"
                    return ready and not stopped()
                end
                if superseded() then return deferLatestSelection() end
                if selected.Parent ~= backpack or getTool(selected.Name) ~= selected then
                    holder.transitioning = false
                    return fail("The manually selected build tool was removed or replaced. Stopped.")
                end
                selected.Parent = character
                task.wait()
                if superseded() then return deferLatestSelection() end
            end
            holder.transitioning = false
            holder.manualRevision = selection.revision
            holder.manualSelectionApplied = true
            diagnostics.manual_tool_name = selected and selected.Name or "none"
            diagnostics.manual_selection_revision = selection.revision
            return not stopped()
        end
        diagnostics.borrowed_tools = #names
        diagnostics.holder_active = true
        report(getManualSelection and "Hands free: native tool selection is available while building."
            or "Hands free: reserving build tools; other tools remain available.")
        return true
    end
    local function releaseHolder()
        if not holder or not holder.active then return end
        holder.active = false
        local restoreErrors = 0
        local function safely(callback)
            local ok = pcall(callback)
            if not ok then restoreErrors += 1 end
        end
        for _, link in ipairs(holder.links) do safely(function() link:Disconnect() end) end
        local function stillOurs(tool)
            return tool.Parent == character or (tool.Parent == holder.backpack and holder.backpack.Parent == player)
        end
        local keepSelection = holder.manualSelectionApplied == true
        if holder.selectionChanged and player.Character == character then
            for _, child in ipairs(character:GetChildren()) do
                local record = holder.tools[child.Name]
                if child:IsA("Tool") and (not record or record.tool ~= child) then keepSelection = true end
            end
        end
        for _, record in pairs(holder.tools) do
            safely(function()
                if not stillOurs(record.tool) then return end
                local destination = record.parent
                if destination == character and keepSelection then destination = holder.backpack end
                if holder.manualTool == record.tool and record.tool.Parent == character then destination = character end
                if destination == holder.backpack and (holder.backpack.Parent ~= player
                    or player:FindFirstChildOfClass("Backpack") ~= holder.backpack) then return end
                record.tool.Parent = destination
            end)
        end
        for script, record in pairs(holder.scripts) do
            safely(function()
                if stillOurs(record.tool) and script:IsDescendantOf(record.tool) then script.Disabled = record.value end
            end)
        end
        for gui, record in pairs(holder.guis) do
            safely(function()
                if (record.tool and stillOurs(record.tool) and gui:IsDescendantOf(record.tool))
                    or (not record.tool and gui.Parent == holder.playerGui and holder.playerGui.Parent == player) then
                    gui.Enabled = record.value
                end
            end)
        end
        diagnostics.holder_active = false
        diagnostics.tool_restore_pending = false
        diagnostics.tool_restore_errors = restoreErrors
    end
    local function ownedRemote(name)
        if stopped() then return nil end
        if holder and holder.active and not pipelineActive and not cleanupMode and not holder.applyManualSelection() then return nil end
        if holder and holder.active and not pipelineActive and not holder.ensure(name) then return nil end
        local tool = getTool(name)
        local remote = tool and tool:FindFirstChild("RF")
        if not tool or not tool:IsA("Tool") or not remote or not remote:IsA("RemoteFunction") then
            fail("Your owned " .. name .. " remote is unavailable. Keep the tool in your inventory or character.")
            return nil
        end
        if toolMode == "compatible" or (preparing and not holder) then
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                fail("Wait for your character to spawn before using Compatible mode.")
                return nil
            end
            if tool.Parent ~= character then
                humanoid:EquipTool(tool)
                task.wait(0.08)
            end
            if preparing then lastPrepTool = tool end
            if stopped() then return nil end
            if tool.Parent ~= character then
                fail("Could not equip " .. name .. ". Compatible mode needs to use your normal tools.")
                return nil
            end
        end
        return remote
    end

    local function refreshManualDrain()
        if not pipelineActive or not holder or not holder.active or not getManualSelection then return end
        local ok, selection = pcall(getManualSelection)
        if ok and type(selection) == "table" and integer(selection.revision, 0, 2147483647)
            and selection.revision > holder.manualRevision
            and (selection.tool == nil or typeof(selection.tool) == "Instance" and selection.tool:IsA("Tool")
                and (selection.tool.Parent == character or selection.tool.Parent == holder.backpack)) then
            if not manualDrain then diagnostics.manual_drains += 1 end
            manualDrain = true
        else manualDrain = false end
    end

    -- Capacity includes callers waiting for their rate slot. A manual selection
    -- cancels those reservations, drains only already dispatched requests, then
    -- changes native controllers before any new request may start.
    local function awaitDispatch(remote)
        local placement = remote and remote.Parent and remote.Parent.Name == "BuildingTool"
        while not stopped() do
            local reserved = not pipelineActive
            local limit = adaptive.workers
            if placement then limit = math.max(1, limit - math.min(4, math.floor(limit / 4))) end
            if pipelineActive then
                refreshManualDrain()
                if manualDrain then
                    if flight.pending == 0 and dispatchReservations == 0 and not holder.transitioning then
                        if not holder.applyManualSelection() then return false end
                        manualDrain = false
                        refreshManualDrain()
                    end
                elseif not holder.transitioning and not (placement and adaptive.pausePlacements)
                    and flight.pending + dispatchReservations < limit then
                    dispatchReservations += 1
                    reserved = true
                end
            end
            if reserved then
                local when = math.max(os.clock(), nextSend)
                local requestRate = preparing and math.min(speed.rate, 120)
                    or speedMode == "Rapid" and adaptive.rate or speed.rate
                nextSend = when + 1 / requestRate
                local delay = when - os.clock()
                if delay > 0 then task.wait(delay) end
                if pipelineActive then
                    dispatchReservations -= 1
                    refreshManualDrain()
                    limit = adaptive.workers
                    if placement then limit = math.max(1, limit - math.min(4, math.floor(limit / 4))) end
                    if not stopped() and not manualDrain and not holder.transitioning and flight.pending < limit
                        and not (placement and adaptive.pausePlacements) then
                        -- A stalled client can wake many overdue reservations
                        -- on one frame. Limit that catch-up burst explicitly.
                        local now = os.clock()
                        dispatchTokens = math.min(12, dispatchTokens + math.max(0, now - tokenUpdatedAt) * adaptive.rate)
                        tokenUpdatedAt = now
                        if dispatchTokens >= 1 then dispatchTokens -= 1; return true end
                    end
                else
                    return not stopped()
                end
            end
            if not stopped() then task.wait(0.03) end
        end
        return false
    end

    -- A timeout is indeterminate: retain the shared pending lock until it returns.
    local function invoke(remote, ...)
        if stopped() or not awaitDispatch(remote) then return false end
        local tool = remote and remote.Parent
        local backpack = player:FindFirstChildOfClass("Backpack")
        if holder and holder.active and (not tool or not holder.ensure(tool.Name)) then return false end
        if not tool or not tool:IsA("Tool") or (tool.Parent ~= character and tool.Parent ~= backpack)
            or getTool(tool.Name) ~= tool or tool:FindFirstChild("RF") ~= remote
            or not remote:IsA("RemoteFunction") then
            return fail("A build tool was removed or replaced. Stopped.")
        end
        if (toolMode == "compatible" or preparing) and tool.Parent ~= character then
            return fail("The active tool changed during Compatible building. Leave the build tools selected while it runs, or use Hands free mode.")
        end
        local args = table.pack(...)
        -- Recheck ownership at dispatch, after waiting for the shared rate slot.
        -- Never resize/paint a model that was moved into another player's folder.
        local function mayModify(model)
            return model and model.Parent == folder and model.Name == plan.block_type and not existing[model]
                and (claimed[model] or (preparing and model == helper))
        end
        if tool.Name == "ScalingTool" or tool.Name == "DeleteTool" then
            if not mayModify(args[1]) then return fail("An identified owned block was removed or moved. Stopped.") end
        elseif tool.Name == "PaintingTool" then
            for _, entry in ipairs(args[1]) do
                if not mayModify(entry[1]) then return fail("An identified owned block was removed or moved. Stopped.") end
            end
        end
        if tool.Name == "BuildingTool" then
            -- Manual building can consume stock while a request waits for its
            -- rate slot. Read the server-replicated count again at dispatch.
            args[2] = stock(plan.block_type)
            if args[2] < 1 or (not preparing and Adapter.available(plan.block_type) < 1) then
                return fail("Out of available " .. plan.block_type .. ". Increase pixel size or choose another block.")
            end
            diagnostics.placement_argument_count = args.n
            diagnostics.placement_tool_held = tool.Parent == character
        end
        local wasUnheld = tool.Parent ~= character
        local finished, ok, result = false, false, nil
        flight.pending += 1
        diagnostics.peak_pending = math.max(diagnostics.peak_pending, flight.pending)
        diagnostics.requests_sent += 1
        if preparing then
            diagnostics.prep_requests += 1
            if tool.Name == "ScalingTool" then
                diagnostics.prep_scale_requests += 1
                if prepSample then prepSample.requests += 1 end
            end
        end
        local invokedAt = os.clock()
        task.spawn(function()
            ok, result = pcall(function() return remote:InvokeServer(table.unpack(args, 1, args.n)) end)
            local elapsed = math.max(0, os.clock() - invokedAt)
            diagnostics.rpc_completed += 1
            diagnostics.rpc_latency_total_seconds += elapsed
            diagnostics.rpc_latency_max_seconds = math.max(diagnostics.rpc_latency_max_seconds, elapsed)
            observeLatency(elapsed)
            flight.pending -= 1
            finished = true
            if flight.pending == 0 and restoreAfterPending then restoreAfterPending() end
        end)
        local deadline = os.clock() + 12
        while not finished and os.clock() < deadline do task.wait(0.03) end
        if not finished then
            return fail("The game has not answered a request. Stopped without retrying; it may still finish later.")
        end
        local unheldHint = wasUnheld and " The tool was unheld; this server may require holding it and may not support background building." or ""
        if not ok then return fail("The game rejected a tool request: " .. tostring(result) .. unheldHint) end
        if result == false then return fail("The game declined the request. Check inventory, scale limits, and plot position." .. unheldHint) end
        return true, result
    end

    local function waitFor(predicate, timeout)
        local deadline = os.clock() + timeout
        repeat
            local value = predicate()
            if value then return value end
            if stopped() then return nil end
            task.wait(0.03)
        until os.clock() >= deadline
        return nil
    end
    local positionTolerance = math.max(0.0001, math.min(0.02, plan.pixel_studs * 0.1))
    local sizeTolerance = math.max(0.0001, math.min(0.04, plan.pixel_studs * 0.1))
    local function matches(part, cf)
        return part and part:IsA("BasePart") and (part.Position - cf.Position).Magnitude < positionTolerance
    end
    local function identify(cf, result)
        if typeof(result) == "Instance" and result:IsA("BasePart") then result = result.Parent end
        if typeof(result) == "Instance" and not existing[result] and result.Parent ~= nil and result.Parent ~= folder then
            fail("A returned image block was moved outside your plot. Stopped before modifying it.")
            return nil
        end
        local function candidate(model, returnedByServer)
            if not model or existing[model] or claimed[model] or model.Parent ~= folder
                or model.Name ~= plan.block_type then return nil end
            local part = model:FindFirstChild("PPart")
            -- A returned new owned block is directly identified by the server.
            -- Its initial placement can be snapped; ScalingTool will move it
            -- to the exact image position and the final geometry is verified.
            if part and part:IsA("BasePart") and (returnedByServer or matches(part, cf)) then return model end
        end
        return waitFor(function()
            if typeof(result) == "Instance" then
                local found = candidate(result, true)
                if found then claimed[found] = true; return found end
            end
            local found
            for _, model in ipairs(added) do
                local match = candidate(model, false)
                if match then
                    if found and found ~= match then
                        fail("Multiple new blocks appeared at the same image position. Stopped before sizing or painting this batch to avoid changing a manually placed block.")
                        return nil
                    end
                    found = match
                end
            end
            if found then claimed[found] = true; return found end
        end, speedMode == "Rapid" and verificationBudget() or 5)
    end
    local function geometryCorrect(job)
        local model = job.model
        local part = model and model:FindFirstChild("PPart")
        return model and model.Parent == folder and part and matches(part, job.cf)
            and (part.Size - job.size).Magnitude < sizeTolerance
            and part.CFrame.RightVector:Dot(job.cf.RightVector) > 0.995
            and part.CFrame.UpVector:Dot(job.cf.UpVector) > 0.995
    end
    local function paintCorrect(job)
        local part = job.model and job.model:FindFirstChild("PPart")
        return geometryCorrect(job) and part and math.abs(part.Color.R - job.color.R) <= 1.5 / 255
            and math.abs(part.Color.G - job.color.G) <= 1.5 / 255
            and math.abs(part.Color.B - job.color.B) <= 1.5 / 255
    end
    local function verificationFailure(job, phase, started)
        local model = job.model
        local part = model and model:FindFirstChild("PPart")
        local owned = model ~= nil and model.Parent == folder and model.Name == plan.block_type
            and claimed[model] == true and not existing[model]
        local present = part and part:IsA("BasePart")
        diagnostics.verification_failure_phase = phase
        diagnostics.verification_failure_owned = owned
        diagnostics.verification_position_error = present and (part.Position - job.cf.Position).Magnitude or 999999
        diagnostics.verification_size_error = present and (part.Size - job.size).Magnitude or 999999
        diagnostics.verification_right_dot = present and part.CFrame.RightVector:Dot(job.cf.RightVector) or -1
        diagnostics.verification_up_dot = present and part.CFrame.UpVector:Dot(job.cf.UpVector) or -1
        diagnostics.verification_color_error = present and math.max(math.abs(part.Color.R - job.color.R),
            math.abs(part.Color.G - job.color.G), math.abs(part.Color.B - job.color.B)) or 1
        diagnostics.verification_wait_seconds = math.max(0, os.clock() - started)
        if not owned then return fail("An identified image block was removed or moved outside your plot. Stopped.") end
        if not geometryCorrect(job) then
            return fail(string.format("The game did not accept the requested block size or position after %.1f seconds. Stopped with verified progress preserved.",
                diagnostics.verification_wait_seconds))
        end
        return fail(string.format("The game did not confirm the requested paint color after %.1f seconds. Stopped with verified progress preserved.",
            diagnostics.verification_wait_seconds))
    end
    local function runPool(jobs, worker, count)
        local index, running = 0, 0
        for _ = 1, math.min(count or speed.workers, #jobs) do
            running += 1
            task.spawn(function()
                local ok, message = pcall(function()
                    while not stopped() do
                        index += 1
                        local job = jobs[index]
                        if not job then break end
                        if worker(job) == false then break end
                    end
                end)
                if not ok then fail(tostring(message)) end
                running -= 1
            end)
        end
        while running > 0 do task.wait(0.03) end
        return not stopped()
    end

    local function validHelper(model)
        return model and not existing[model] and model.Parent == folder
            and model.Name == plan.block_type and model:FindFirstChild("PPart")
            and model.PPart:IsA("BasePart")
    end
    local function restoreHeldTool()
        if not preparing then return end
        if holder then preparing = false; return end
        local function restore()
            if contextChanged() then return end
            pcall(function()
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local backpack = player:FindFirstChildOfClass("Backpack")
                if not humanoid or humanoid.Health <= 0 then return end
                -- Never override a selection made after our last equipment
                -- change, including a manual switch while a call timed out.
                local held, count = nil, 0
                for _, child in ipairs(character:GetChildren()) do
                    if child:IsA("Tool") then held = child; count += 1 end
                end
                if count ~= 1 or held ~= lastPrepTool then return end
                if originalHeld and (originalHeld.Parent == character or originalHeld.Parent == backpack) then
                    humanoid:EquipTool(originalHeld)
                elseif not originalHeld then
                    humanoid:UnequipTools()
                end
            end)
        end
        if flight.pending > 0 then
            restoreAfterPending = function()
                restoreAfterPending = nil
                restore()
                flight.busy = false
            end
        else
            restore()
        end
        preparing = false
    end
    local function removeHelper()
        if not helperPossible then return true end
        if helper and helper.Parent == nil then helperPossible = false; return true end
        if deleteAttempted or not validHelper(helper) or contextChanged() or flight.pending > 0 then return false end
        -- Cleanup can run after cancellation, but never alongside an uncertain
        -- request. It addresses only the one positively identified new helper.
        cleanupMode = true
        local ok, removed = pcall(function()
            local remote = ownedRemote("DeleteTool")
            if not remote then return false end
            diagnostics.phase = "preparing_delete"
            deleteAttempted = true
            if not invoke(remote, helper) then return false end
            return waitFor(function() return helper.Parent ~= folder end, 5) == true
        end)
        cleanupMode = false
        if ok and removed then helperPossible = false; return true end
        return false
    end
    local function prepareInventory()
        if not diagnostics.infinite_requested then return true end
        local before = Adapter.available(plan.block_type)
        diagnostics.inventory_before = before
        if before >= required then
            diagnostics.preparation_status = "already_sufficient"
            diagnostics.inventory_after = before
            return true
        end
        -- The reference yield is only an initial estimate. Measure completed
        -- create/scale/delete rounds before scheduling any additional material.
        local estimated = math.ceil((required - before) / 99.0017938123301)
        if estimated > 4096 then
            diagnostics.prep_stop_reason = "request_limit"
            return fail("This image exceeds the Infinite Blocks preparation limit of 4096 scale requests. Use a smaller image.")
        end
        local deleteTool = getTool("DeleteTool")
        if not deleteTool or not deleteTool:IsA("Tool") or not deleteTool:FindFirstChild("RF")
            or not deleteTool.RF:IsA("RemoteFunction") then
            return fail("Infinite Blocks preparation needs your owned DeleteTool. No preparation requests were sent.")
        end
        -- Inventory can change between holder engagement and this recheck.
        -- Acquire the cleanup tool before creating a helper in that case.
        if holder and not holder.borrow("DeleteTool") then return false end
        if stopped() then return false end
        local heldCount = 0
        for _, child in ipairs(character and character:GetChildren() or {}) do
            if child:IsA("Tool") then originalHeld = child; heldCount += 1 end
        end
        if heldCount > 1 and not holder then
            return fail("Infinite Blocks preparation needs at most one equipped tool. Close other builders and unequip extra tools first.")
        end
        preparing = true
        diagnostics.preparation_status = "running"
        local cf = CFrame.new(zone.Position.X, -250000, zone.Position.Z)
            * CFrame.Angles(0, math.rad(40.135), 0)
        local isWhite = player.Team and string.lower(player.Team.Name) == "white"
        local size = isWhite and Vector3.new(1.1755e-38, 2048, 390.632)
            or Vector3.new(390.632, 2048, 1.1755e-38)
        local measuredYield
        local function preparationFailed(code, reason)
            local after = Adapter.available(plan.block_type)
            diagnostics.inventory_after = after
            diagnostics.prep_gain = after - before
            diagnostics.prep_stop_reason = code
            return fail(string.format("Infinite Blocks preparation %s: started with %.3f, now %.3f available; %.3f more needed (%d required). The wall was not started.",
                reason, before, after, math.max(0, required - after), required))
        end
        while Adapter.available(plan.block_type) < required do
            if stopped() then return false end
            if diagnostics.prep_scale_requests >= 4096 then
                return preparationFailed("request_limit", "reached its limit of 4096 scale requests")
            end
            if diagnostics.prep_rounds >= 32 then
                return preparationFailed("round_limit", "reached its limit of 32 measured rounds")
            end
            local roundBefore = Adapter.available(plan.block_type)
            local count = measuredYield and math.ceil((required - roundBefore) / measuredYield)
                or math.min(16, estimated)
            count = math.max(1, math.min(count, 256, 4096 - diagnostics.prep_scale_requests))
            -- A fresh snapshot prevents a prior helper or another block made
            -- between rounds from being mistaken for this round's helper.
            for _, model in ipairs(folder:GetChildren()) do existing[model] = true end
            helper, helperPossible, deleteAttempted = nil, false, false
            diagnostics.prep_rounds += 1
            prepSample = {before = roundBefore, after = roundBefore, requests = 0, gain = 0}
            table.insert(diagnostics.prep_samples, prepSample)
            diagnostics.phase = "preparing_place"
            report(string.format("Preparing material: round %d; %.3f / %d available...",
                diagnostics.prep_rounds, roundBefore, required))
            local remote = ownedRemote("BuildingTool")
            if not remote then return false end
            local priorRequests = diagnostics.prep_requests
            local accepted, result = invoke(remote, plan.block_type, stock(plan.block_type), zone,
                zone.CFrame:ToObjectSpace(cf), true, nil, nil, false)
            helperPossible = diagnostics.prep_requests > priorRequests
            if not accepted then return false end
            if typeof(result) == "Instance" and result:IsA("BasePart") then result = result.Parent end
            helper = waitFor(function()
                if typeof(result) == "Instance" and validHelper(result) then return result end
                local found
                for _, model in ipairs(folder:GetChildren()) do
                    if validHelper(model) and (model.PPart.Position - cf.Position).Magnitude <= 0.02 then
                        if found then
                            fail("Infinite Blocks preparation found multiple new blocks at the staging position. None were scaled or deleted.")
                            return nil
                        end
                        found = model
                    end
                end
                return found
            end, 5)
            if not helper then
                return fail("Infinite Blocks preparation could not identify its new temporary block. No block was scaled or deleted.")
            end
            if stopped() then return false end
            remote = ownedRemote("ScalingTool")
            if not remote then return false end
            diagnostics.phase = "preparing_scale"
            -- Requests change the same model, so wait for each response rather
            -- than letting multiple writes race. invoke caps preparation at 120/s.
            for index = 1, count do
                if stopped() then return false end
                if not validHelper(helper) then return fail("The identified preparation block was removed or changed. Stopped.") end
                -- Each scale has fully returned here. Apply native selection
                -- before the next call rather than delaying it a whole round.
                remote = ownedRemote("ScalingTool")
                if not remote then return false end
                report(string.format("Preparing material: round %d, scale request %d / %d",
                    diagnostics.prep_rounds, index, count))
                if not invoke(remote, helper, size, cf) then return false end
            end
            if not removeHelper() then return fail("The game did not confirm removal of the temporary preparation block.") end
            existing[helper] = true -- Never reuse this exact instance in a later round.
            diagnostics.phase = "preparing_verify"
            report("Checking material gained from the completed round...")
            local deadline = os.clock() + 5
            local after, changedAt = Adapter.available(plan.block_type), os.clock()
            repeat
                if stopped() then return false end
                local current = Adapter.available(plan.block_type)
                if current ~= after then after, changedAt = current, os.clock() end
                if after >= required or (after > roundBefore and os.clock() - changedAt >= 0.5) then break end
                task.wait(0.03)
            until os.clock() >= deadline
            after = Adapter.available(plan.block_type)
            prepSample.after, prepSample.gain = after, after - roundBefore
            diagnostics.inventory_after = after
            diagnostics.prep_gain = after - before
            local gain = prepSample.gain
            prepSample = nil
            if gain <= 0 then
                return preparationFailed("no_gain", "did not provide enough material; the last completed round produced no positive gain")
            end
            measuredYield = gain / count
        end
        if stopped() then return false end
        diagnostics.preparation_status = "verified"
        diagnostics.prep_stop_reason = "satisfied"
        diagnostics.inventory_after = Adapter.available(plan.block_type)
        diagnostics.prep_gain = diagnostics.inventory_after - before
        restoreHeldTool()
        return true
    end

    local function doBatch(jobs, first)
        -- Earlier batches have already replicated and verified. Keep candidate
        -- matching bounded by this batch instead of rescanning the entire wall.
        table.clear(added)
        batchNewCount = 0
        diagnostics.phase = "placing"
        local remote = ownedRemote("BuildingTool")
        if not remote then return false end
        report(first and "Checking the first block with the game..." or "Placing blocks...")
        if not runPool(jobs, function(job)
            local remaining = stock(plan.block_type)
            if Adapter.available(plan.block_type) < 1 then return fail("Out of available " .. plan.block_type .. ". Increase pixel size or choose another block.") end
            -- Three normal manual placements captured on 2026-09-24 supplied
            -- eight arguments ending false, true. The last flag's server-side
            -- meaning is unknown; preserve the observed value in both modes.
            local ok, result = invoke(remote, plan.block_type, remaining, zone,
                zone.CFrame:ToObjectSpace(job.cf), true, job.cf, false, true)
            if not ok then return false end
            job.result = result
            if first then diagnostics.returned_type = typeof(result) end
            return true
        end, first and 1 or speed.workers) then return false end

        -- Wait until placement calls for the batch have returned before using
        -- ChildAdded fallback evidence. A returned new owned instance is the
        -- strongest correlation; location alone cannot establish provenance if
        -- a manual placement is the sole new object at that exact position.
        for _, job in ipairs(jobs) do
            job.model = identify(job.cf, job.result)
            if not job.model then
                diagnostics.observed_new_models = observedCount
                diagnostics.observed_material_models = observedMaterialCount
                if stopped() then return false end
                diagnostics.last_batch_new_objects = batchNewCount
                if batchNewCount == 0 then
                    local hint = toolMode == "background"
                        and " Select Tools: Compatible, then place again; it uses the normal game tools."
                        or " Check the selected plot and available material. The game did not confirm placement."
                    return fail("No new block appeared after the placement request." .. hint)
                end
                local nearest
                for _, model in ipairs(added) do
                    local part = model:FindFirstChild("PPart")
                    if model.Name == plan.block_type and part and part:IsA("BasePart") then
                        local distance = (part.Position - job.cf.Position).Magnitude
                        if not nearest or distance < nearest then nearest = distance end
                    end
                end
                diagnostics.nearest_position_error = nearest
                return fail(string.format("%d new object(s) appeared, but the requested block could not be identified%s. Stopped before modifying them.",
                    batchNewCount, nearest and string.format(" (nearest position differs by %.4g studs)", nearest) or ""))
            end
            created += 1
        end

        diagnostics.phase = "scaling"
        remote = ownedRemote("ScalingTool")
        if not remote then return false end
        report("Sizing blocks...")
        if not runPool(jobs, function(job)
            local ok = invoke(remote, job.model, job.size, job.cf)
            if not ok then return false end
            local started = os.clock()
            local correct = waitFor(function()
                return geometryCorrect(job)
            end, verificationBudget())
            if not correct then
                if speedMode == "Rapid" then
                    if stopped() then return false end
                    return verificationFailure(job, "geometry", started)
                end
                return fail("The game did not accept the requested block size. It may require held tools; try a larger pixel size or more inventory.")
            end
            return true
        end) then return false end

        diagnostics.phase = "painting"
        remote = ownedRemote("PaintingTool")
        if not remote then return false end
        report("Painting and verifying...")
        -- A bounded paint batch reduces round trips; every result is verified.
        local paint = {}
        for _, job in ipairs(jobs) do table.insert(paint, {job.model, job.color}) end
        if not invoke(remote, paint) then return false end
        for _, job in ipairs(jobs) do
            local started = os.clock()
            if not waitFor(function()
                return paintCorrect(job)
            end, verificationBudget()) then
                if speedMode == "Rapid" then
                    if stopped() then return false end
                    return verificationFailure(job, "paint", started)
                end
                return fail("The game did not confirm the requested paint color. It may require held tools. Stopped.")
            end
            completed += 1
        end
        report(string.format("Verified %d / %d blocks", completed, #items))
        return true
    end

    local function doRapidWindow(jobs)
        table.clear(added)
        batchNewCount = 0
        pipelineActive = true
        adaptive.pausePlacements = false
        diagnostics.pipeline_windows += 1
        diagnostics.phase = "pipelining"
        report("Building at a measured pace...")
        local checking, ready = {}, {}
        local cohortsRunning, paintsRunning, nextJob, activeCount = 0, 0, 1, 0
        local checkCursor, readySince = 1, nil
        local reportedAt, reportedCount, reportedStatus = 0, completed, ""
        local function launch(callback, painting)
            if painting then paintsRunning += 1 else cohortsRunning += 1 end
            task.spawn(function()
                local ok, message = pcall(callback)
                if not ok then fail(tostring(message)) end
                if painting then paintsRunning -= 1 else cohortsRunning -= 1 end
            end)
        end
        local function queueVerification(job, phase, started, deadline)
            job.verifyPhase, job.verifyStarted, job.verifyDeadline = phase, started, deadline
            table.insert(checking, job)
        end
        local function launchCohort()
            local cohort = {}
            for _ = 1, math.min(speed.cohort, #jobs - nextJob + 1) do
                table.insert(cohort, jobs[nextJob]); nextJob += 1
            end
            activeCount += #cohort
            diagnostics.pipeline_peak_active = math.max(diagnostics.pipeline_peak_active, activeCount)
            launch(function()
                local buildRemote = ownedRemote("BuildingTool")
                if not buildRemote then return end
                if not runPool(cohort, function(job)
                    local ok, result = invoke(buildRemote, plan.block_type, stock(plan.block_type), zone,
                        zone.CFrame:ToObjectSpace(job.cf), true, job.cf, false, true)
                    if not ok then return false end
                    job.result = result
                    return true
                end, speed.cohort) then return end
                -- Nil replies require the whole small placement cohort to
                -- return before matching any of its new models.
                for _, job in ipairs(cohort) do
                    if stopped() then return end
                    job.model = identify(job.cf, job.result)
                    if not job.model then
                        if not stopped() then fail("A requested block could not be uniquely identified. Stopped before modifying it; partial blocks may remain.") end
                        return
                    end
                    created += 1
                end
                local scaleRemote = ownedRemote("ScalingTool")
                if not scaleRemote then return end
                runPool(cohort, function(job)
                    if not invoke(scaleRemote, job.model, job.size, job.cf) then return false end
                    local started = os.clock()
                    queueVerification(job, "geometry", started, started + verificationBudget())
                    return true
                end, speed.cohort)
            end, false)
        end
        repeat
            if not stopped() then
                refreshManualDrain()
                if manualDrain and flight.pending == 0 and dispatchReservations == 0 and not holder.transitioning then
                    if not holder.applyManualSelection() then break end
                    manualDrain = false
                    refreshManualDrain()
                end
                local tickStarted, oldestWait, checks = os.clock(), 0, 0
                -- A fair cursor gives every waiting job a bounded share of
                -- CPU. Deadlines are absolute; one slow job cannot grant the
                -- next one another full timeout or stop correct jobs counting.
                for _ = 1, math.min(24, #checking) do
                    if stopped() or #checking == 0 then break end
                    if checks > 0 and os.clock() - tickStarted >= 0.002 then break end
                    if checkCursor > #checking then checkCursor = 1 end
                    local job = checking[checkCursor]
                    checks += 1
                    local age = os.clock() - job.verifyStarted
                    oldestWait = math.max(oldestWait, age)
                    if not job.model or job.model.Parent ~= folder or job.model.Name ~= plan.block_type then
                        verificationFailure(job, job.verifyPhase, job.verifyStarted)
                        break
                    end
                    local correct = job.verifyPhase == "geometry" and geometryCorrect(job)
                        or job.verifyPhase == "paint" and paintCorrect(job)
                    if correct then
                        table.remove(checking, checkCursor)
                        if job.verifyPhase == "geometry" then
                            table.insert(ready, job)
                            readySince = readySince or os.clock()
                        else
                            completed += 1
                            activeCount -= 1
                        end
                    elseif os.clock() >= job.verifyDeadline then
                        verificationFailure(job, job.verifyPhase, job.verifyStarted)
                        break
                    else checkCursor += 1 end
                end
                diagnostics.verification_checks_peak = math.max(diagnostics.verification_checks_peak, checks)
                diagnostics.pipeline_peak_ready = math.max(diagnostics.pipeline_peak_ready, #ready)
                diagnostics.replication_peak_waiting = math.max(diagnostics.replication_peak_waiting, #checking)
                local paused = #checking >= math.max(16, adaptive.workers * 2)
                    or #ready >= math.max(32, adaptive.workers * 2)
                    or oldestWait > math.max(0.6, (adaptive.latency or 0) * 1.5)
                if paused and not adaptive.pausePlacements then diagnostics.replication_pause_count += 1 end
                adaptive.pausePlacements = paused
                if oldestWait > math.max(1, (adaptive.latency or 0) * 2) or #ready > 64 then slowDown() end
                if not paused and adaptive.latency and adaptive.latency < 0.45 and adaptive.overshoot < 0.02
                    and adaptive.healthyCalls >= 16 and os.clock() >= adaptive.nextIncrease then
                    local workers = math.min(speed.maxWorkers, adaptive.workers + 4)
                    local rate = math.min(speed.maxRate, adaptive.rate + 40)
                    if workers ~= adaptive.workers or rate ~= adaptive.rate then
                        setAdaptiveLimits(rate, workers)
                        diagnostics.adaptive_upshifts += 1
                    end
                    adaptive.nextIncrease = os.clock() + 3
                    adaptive.healthyCalls = 0
                end
                -- Only one small paint payload may be in flight. The reference
                -- protocol gives no guarantee about concurrent paint handlers.
                if not stopped() and paintsRunning == 0 and #ready > 0
                    and (#ready >= speed.paint or cohortsRunning == 0 or os.clock() - readySince >= 0.1) then
                    local paintJobs, payload = {}, {}
                    for _ = 1, math.min(speed.paint, #ready) do
                        local job = table.remove(ready)
                        table.insert(paintJobs, job); table.insert(payload, {job.model, job.color})
                    end
                    readySince = #ready > 0 and os.clock() or nil
                    diagnostics.pipeline_paint_batches += 1
                    launch(function()
                        local remote = ownedRemote("PaintingTool")
                        if not remote or not invoke(remote, payload) then return end
                        local started = os.clock()
                        local deadline = started + verificationBudget()
                        for _, job in ipairs(paintJobs) do queueVerification(job, "paint", started, deadline) end
                    end, true)
                end
                local cohortLimit = math.min(4, math.max(1, math.ceil(adaptive.workers / speed.cohort)))
                local activeLimit = math.min(128, math.max(32, adaptive.workers * 3))
                while not stopped() and not adaptive.pausePlacements and not manualDrain
                    and nextJob <= #jobs and cohortsRunning < cohortLimit and activeCount + speed.cohort <= activeLimit do
                    launchCohort()
                end
                local status = paused and "Waiting for block updates; holding new placements..."
                    or diagnostics.adaptive_downshifts > 0 and "Building with reduced load..."
                    or "Placing, sizing and painting..."
                if status ~= reportedStatus or completed ~= reportedCount and os.clock() - reportedAt >= 0.2 then
                    report(status)
                    reportedAt, reportedCount, reportedStatus = os.clock(), completed, status
                end
            end
            if cohortsRunning > 0 or paintsRunning > 0 or not stopped() and (nextJob <= #jobs or #checking > 0 or #ready > 0) then
                local beforeWait = os.clock()
                task.wait(0.05)
                local elapsed = math.max(0, os.clock() - beforeWait)
                local overshoot = math.max(0, elapsed - 0.05)
                adaptive.overshoot = adaptive.overshoot * 0.8 + overshoot * 0.2
                diagnostics.monitor_delay_ewma_seconds = diagnostics.monitor_delay_ewma_seconds == 0 and elapsed
                    or diagnostics.monitor_delay_ewma_seconds * 0.8 + elapsed * 0.2
                diagnostics.monitor_delay_max_seconds = math.max(diagnostics.monitor_delay_max_seconds, elapsed)
                if overshoot > 0.08 or adaptive.overshoot > 0.035 then slowDown() end
            end
        until cohortsRunning == 0 and paintsRunning == 0
            and (stopped() or nextJob > #jobs and #checking == 0 and #ready == 0)
        pipelineActive = false
        adaptive.pausePlacements = false
        manualDrain = false
        return not stopped()
    end

    local ok, message = pcall(function()
        for _, model in ipairs(folder:GetChildren()) do existing[model] = true end
        if stopped() or not engageHolder() then return end
        if not prepareInventory() then return end
        -- The preparation helper is excluded from all wall observations/counts.
        connection = folder.ChildAdded:Connect(function(model)
            table.insert(added, model)
            if not existing[model] and not observedNew[model] then
                observedNew[model] = true
                observedCount += 1
                batchNewCount += 1
                if model.Name == plan.block_type then observedMaterialCount += 1 end
            end
        end)
        -- Construct only this batch's CFrames, sizes and colors. Large plans
        -- already contain their rectangles; a second full job list adds a long
        -- allocation pause and keeps every job alive for the whole build.
        local function makeBatch(firstIndex, lastIndex)
            local jobs = {}
            for index = firstIndex, lastIndex do
                local rect = items[index]
                local cf, size = Adapter.geometry(plan, rect, origin)
                table.insert(jobs, {cf = cf, size = size,
                    color = Color3.fromRGB(rect.color[1], rect.color[2], rect.color[3])})
            end
            diagnostics.peak_geometry_jobs = math.max(diagnostics.peak_geometry_jobs, #jobs)
            return jobs
        end
        wallStarted = os.clock()
        -- Prove this server accepts all three operations before concurrent work.
        if not doBatch(makeBatch(1, 1), true) then return end
        local offset = 2
        while offset <= #items and not stopped() do
            local batch = makeBatch(offset, math.min(#items, offset + speed.batch - 1))
            if speedMode == "Rapid" then
                if not doRapidWindow(batch) then break end
            elseif not doBatch(batch, false) then break end
            offset += #batch
            task.wait()
        end
        if holder and holder.active and not stopped() then holder.applyManualSelection() end
    end)
    if connection then connection:Disconnect() end
    if not ok then failure = failure or tostring(message) end
    if preparing then
        if helperPossible then removeHelper() end
        restoreHeldTool()
    end
    if holder then
        if flight.pending > 0 then
            diagnostics.tool_restore_pending = true
            restoreAfterPending = function()
                restoreAfterPending = nil
                releaseHolder()
                flight.busy = false
            end
        else
            releaseHolder()
        end
    end
    if diagnostics.infinite_requested then
        if diagnostics.preparation_status ~= "verified" and diagnostics.preparation_status ~= "already_sufficient" then
            diagnostics.preparation_status = "failed"
            diagnostics.inventory_after = Adapter.available(plan.block_type)
            diagnostics.prep_gain = diagnostics.inventory_after - diagnostics.inventory_before
            diagnostics.prep_stop_reason = diagnostics.prep_stop_reason
                or (flight.pending > 0 and "request_pending")
                or (failure and "request_failed") or "cancelled_or_context_changed"
            if prepSample then
                prepSample.after = diagnostics.inventory_after
                prepSample.gain = prepSample.after - prepSample.before
            end
        end
    end
    diagnostics.temporary_block_remaining = helperPossible
    flight.busy = restoreAfterPending ~= nil
    local success = completed == #items
    local status = success and string.format("Built and verified %d blocks. Use the game's Save button to keep the wall.", completed)
        or (failure or "Stopped by you, respawn, launch, or team change.")
    if not success then
        status ..= string.format(" %d/%d finished; %d blocks identified.", completed, #items, created)
        if observedCount > 0 or created > 0 then
            status ..= " New or partial blocks may remain; check your plot before retrying."
        else
            status ..= " No new wall blocks were observed during this attempt."
        end
        if helperPossible then
            status ..= " A temporary preparation block may remain below the plot; it was not safe to delete it."
        end
        if flight.pending > 0 then status ..= " A request is still pending; tools could not be restored yet." end
    end
    diagnostics.observed_new_models = observedCount
    diagnostics.observed_material_models = observedMaterialCount
    diagnostics.wall_elapsed_seconds = wallStarted and math.max(0, os.clock() - wallStarted) or 0
    diagnostics.verified_blocks_per_second = diagnostics.wall_elapsed_seconds > 0
        and completed / diagnostics.wall_elapsed_seconds or 0
    diagnostics.rpc_latency_mean_seconds = diagnostics.rpc_completed > 0
        and diagnostics.rpc_latency_total_seconds / diagnostics.rpc_completed or 0
    return {ok = success, message = status, completed = completed, total = #items, created = created,
        diagnostics = diagnostics}
end

function Adapter.teardown() destroyed = true end
return Adapter
