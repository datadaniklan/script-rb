-- Only the real option callback and beginBuild run here. No Roblox or remotes.
local function context()
    --[[INITIAL_OPTION]]
    local processing, building, cancelled, destroyed = false, false, false, false
    local plan = {placement_count = 1, block_count = 1}
    local blockMenu, speedMenu = {Visible = true}, {Visible = true}
    local infiniteButton = {Activated = {}, Text = "initial"}
    local C = {red = "red", green = "green", text = "text", yellow = "yellow", dim = "dim"}
    local calls, queue, telemetry = {}, {}, {}
    local validations, click = 0, nil
    local Adapter = {
        validate = function(value)
            validations += 1
            assert(value == plan)
            return true
        end,
        build = function(value, origin, options)
            assert(value == plan)
            table.insert(calls, {origin = origin, options = options})
            return {ok = true, completed = 1, total = 1}
        end,
    }
    local task = {spawn = function(callback) table.insert(queue, callback) end}
    local function busy() return processing or building end
    local function connect(signal, callback)
        assert(signal == infiniteButton.Activated)
        click = callback
    end
    local function clearTool() end
    local function setStatus() end
    local function syncButtons() end
    local function refreshInventory() end
    local UI, phaseLabel, progressFill = {}, {}, {}
    local function resetProgress(phase) phaseLabel.Text = phase end
    local function showBuildProgress() end
    local function safeError(value) return tostring(value) end
    local function sendTelemetry(value, ok, result, mode, enabled, buildSpeed)
        table.insert(telemetry, {plan = value, ok = ok, result = result, mode = mode, enabled = enabled, speed = buildSpeed})
    end
    local function createManualToolSelector()
        return function() return {revision = 0} end, function() end
    end
    local ENV, api = {}, {}
    --[[TOGGLE_CALLBACK]]
    --[[BEGIN_BUILD]]
    return {
        begin = beginBuild,
        click = function() click() end,
        enabled = function() return infiniteBlocks end,
        setEnabled = function(value) infiniteBlocks = value end,
        setMode = function(value) toolMode = value end,
        setSpeed = function(value) speed = value end,
        setProcessing = function(value) processing = value end,
        queued = function() return #queue end,
        validations = function() return validations end,
        flush = function()
            while #queue > 0 do table.remove(queue, 1)() end
        end,
        calls = calls, telemetry = telemetry,
    }
end

local passed = 0
local function test(name, run)
    local ok, message = pcall(run)
    assert(ok, name .. ": " .. tostring(message))
    passed += 1
end

test("hands free and material preparation are enabled by default", function()
    local ctx, origin = context(), {}
    assert(ctx.enabled() == true)
    ctx.begin(origin)
    assert(#ctx.calls == 0 and ctx.queued() == 1)
    ctx.flush()
    assert(#ctx.calls == 1 and ctx.calls[1].origin == origin)
    assert(ctx.calls[1].options.infiniteBlocks == true)
    assert(ctx.calls[1].options.toolMode == "background")
    assert(ctx.calls[1].options.speed == "Rapid" and ctx.telemetry[1].speed == "Rapid")
    assert(ctx.telemetry[1].enabled == true)
end)

test("idle toggle disables preparation for the next build", function()
    local ctx = context()
    ctx.click()
    assert(ctx.enabled() == false)
    ctx.begin({})
    ctx.flush()
    assert(ctx.calls[1].options.infiniteBlocks == false)
    assert(ctx.telemetry[1].enabled == false)
end)

test("queued work and telemetry retain the selected option", function()
    for _, value in ipairs({false, true}) do
        local ctx = context()
        ctx.setEnabled(value)
        ctx.setMode("compatible")
        ctx.setSpeed("Normal")
        ctx.begin({})
        ctx.setEnabled(not value)
        ctx.setMode("background")
        ctx.setSpeed("Turbo")
        ctx.flush()
        assert(ctx.calls[1].options.infiniteBlocks == value)
        assert(ctx.telemetry[1].enabled == value)
        assert(ctx.calls[1].options.toolMode == "compatible" and ctx.calls[1].options.speed == "Normal")
        assert(ctx.telemetry[1].mode == "compatible" and ctx.telemetry[1].speed == "Normal")
    end
end)

test("processing blocks new builds and option changes", function()
    local ctx = context()
    ctx.setProcessing(true)
    ctx.click()
    ctx.begin({})
    assert(ctx.enabled() == true and ctx.queued() == 0)
    assert(ctx.validations() == 0)
    ctx.setProcessing(false)
    ctx.click()
    assert(ctx.enabled() == false)
end)

test("a queued build blocks a second build and user option change", function()
    local ctx = context()
    ctx.begin({})
    ctx.click()
    ctx.begin({})
    assert(ctx.enabled() == true and ctx.queued() == 1)
    assert(ctx.validations() == 1)
    ctx.flush()
    assert(#ctx.calls == 1)
    ctx.click()
    assert(ctx.enabled() == false)
end)

local function conversionContext()
    --[[CONFIG]]
    --[[QUALITY]]
    local qualityIndex, processing, invalidations = 1, false, 0
    local qualityButton, samplingButton, detailButton = {Activated = {}}, {Activated = {}}, {Activated = {}}
    local urlInput = {Text = "  https://example.invalid/picture.png  "}
    local widthInput, pixelInput, maxInput, paletteInput = {Text = "50"}, {Text = "0.125"}, {Text = "250000"}, {Text = "0"}
    local selectedBlock = "TitaniumBlock"
    local callbacks = {}
    local function connect(signal, callback) callbacks[signal] = callback end
    local function busy() return processing end
    local function invalidate() invalidations += 1 end
    local function setFieldText(field, text) field.Text = text end
    --[[NUMBERS]]
    --[[SETTINGS]]
    --[[OPTIONS]]
    return {
        settings = conversionSettings,
        quality = function() callbacks[qualityButton.Activated]() end,
        sampling = function() callbacks[samplingButton.Activated]() end,
        detail = function() callbacks[detailButton.Activated]() end,
        busy = function(value) processing = value end,
        invalidations = function() return invalidations end,
        palette = paletteInput, width = widthInput, pixel = pixelInput,
    }
end
test("default conversion is compact Photo with light detail", function()
    local settings = conversionContext().settings()
    assert(settings.sampling == "lanczos" and settings.detail == "light" and settings.compact == true)
    assert(settings.resolution_mode == "auto" and settings.width_studs == 50 and settings.block_type == "TitaniumBlock")
    assert(settings.image_url == "https://example.invalid/picture.png")
end)
test("sampling buttons forward Photo Pixel art and Soft", function()
    local ctx = conversionContext()
    ctx.sampling(); assert(ctx.settings().sampling == "nearest" and ctx.settings().detail == "none")
    ctx.detail(); assert(ctx.settings().detail == "light")
    ctx.sampling(); assert(ctx.settings().sampling == "area")
    ctx.sampling(); assert(ctx.settings().sampling == "lanczos")
    assert(ctx.invalidations() == 4)
end)
test("detail buttons cycle strong none and light", function()
    local ctx = conversionContext()
    ctx.detail(); assert(ctx.settings().detail == "strong")
    ctx.detail(); assert(ctx.settings().detail == "none")
    ctx.detail(); assert(ctx.settings().detail == "light")
    assert(ctx.invalidations() == 3)
end)
test("Source forces no detail and ignores detail clicks", function()
    local ctx = conversionContext()
    ctx.detail(); ctx.quality(); ctx.pixel.Text = "not used in Source"
    assert(ctx.settings().resolution_mode == "source" and ctx.settings().detail == "none")
    local before = ctx.invalidations()
    ctx.detail(); assert(ctx.invalidations() == before and ctx.settings().detail == "none")
    ctx.quality(); assert(ctx.settings().detail == "strong" and ctx.settings().resolution_mode == "spacing")
end)
test("busy quality controls cannot invalidate the running job", function()
    local ctx = conversionContext()
    ctx.busy(true); ctx.detail(); ctx.sampling(); ctx.quality()
    assert(ctx.invalidations() == 0)
    assert(ctx.settings().detail == "light" and ctx.settings().sampling == "lanczos")
end)
test("invalid numeric settings fail before any HTTP request", function()
    local ctx = conversionContext()
    ctx.palette.Text = "1"; assert(not pcall(ctx.settings))
    ctx.palette.Text = "0"; ctx.width.Text = "nan"; assert(not pcall(ctx.settings))
    ctx.width.Text = "50"; ctx.pixel.Text = "0"; assert(not pcall(ctx.settings))
end)

local function placementContext()
    local callbacks, toolConnections = {}, {}
    local function signal()
        local result = {}
        function result:Connect(callback)
            callbacks[self] = callback
            return {Disconnect = function() callbacks[self] = nil end}
        end
        return result
    end
    local destroyed, processing, building = false, false, false
    local plan = {width_studs = 50, height_studs = 30, pixel_studs = 0.125}
    local placeTool, ghost, placement, renderConnection, placementAllowed, placementReason
    local yaw = math.rad(123)
    local backpack, character = {}, {}
    local humanoid = {Health = 100}
    function humanoid:EquipTool(tool) tool.Parent = character; callbacks[tool.Equipped]() end
    function character:FindFirstChildOfClass() return humanoid end
    function character:FindFirstChild() error("Placement must not inherit the character heading") end
    local player = {Character = character}
    function player:FindFirstChildOfClass() return backpack end
    local function busy() return processing or building end
    local C = {green = {}, red = {}, yellow = {}}
    local phaseLabel, progressMeta = {}, {}
    local Adapter = {validate = function() return true end, canPlace = function() return true end}
    local focused, overPanel, rayCoordinates = false, false, nil
    local UserInputService = {InputBegan = signal()}
    function UserInputService:GetFocusedTextBox() return focused end
    function UserInputService:GetMouseLocation() return {X = 740, Y = 386} end
    local GuiService = {GetGuiInset = function() return {X = 13, Y = 36} end}
    local Enum = {Material = {ForceField = {}}, RaycastFilterType = {Exclude = {}}, KeyCode = {Q = "Q", E = "E", R = "R"}}
    local CFrame = {}
    local frameMeta = {__mul = function(a, b) return {left = a, right = b} end}
    function CFrame.new(x, y, z) return setmetatable({x = x, y = y, z = z}, frameMeta) end
    function CFrame.Angles(x, y, z) return {x = x, y = y, z = z} end
    -- Multiplication of an origin by a local half-height offset is inspected below.
    frameMeta.__mul = function(a, b) return setmetatable({left = a, right = b}, frameMeta) end
    local Vector3 = {new = function(x, y, z) return {X = x, Y = y, Z = z} end}
    local RaycastParams = {new = function() return {} end}
    local RunService = {RenderStepped = signal()}
    local Workspace = {CurrentCamera = {}}
    function Workspace.CurrentCamera:ViewportPointToRay(x, y)
        rayCoordinates = {x, y}
        return {Origin = {}, Direction = 1}
    end
    function Workspace:Raycast() return {Position = {X = 10, Y = 2, Z = 20}} end
    local function create(class, properties, parent)
        properties.Parent = parent
        properties.Destroy = function() end
        if class == "Tool" then properties.Equipped, properties.Unequipped, properties.Activated = signal(), signal(), signal() end
        return properties
    end
    local function clearGhost() ghost = nil; placement = nil end
    local function setStatus() end
    local function safeError(value) return tostring(value) end
    local function syncButtons() end
    local function mouseOverPanel() return overPanel end
    local builds = {}
    local function beginBuild(value) table.insert(builds, value) end
    local function connect(s, callback) s:Connect(callback) end
    --[[PLACEMENT]]
    --[[KEYS]]
    return {
        equip = equipPlacementTool,
        yaw = function() return yaw end,
        key = function(key, processed) callbacks[UserInputService.InputBegan]({KeyCode = key}, processed) end,
        focused = function(value) focused = value end,
        render = function() callbacks[RunService.RenderStepped]() end,
        ray = function() return rayCoordinates end,
        ghost = function() return ghost end,
        click = function() callbacks[placeTool.Activated]() end,
        removePlacement = function() placeTool = nil; clearGhost() end,
        overPanel = function(value) overPanel = value end,
        builds = builds,
    }
end
test("new tool has zero yaw and re-equipping retains user rotation", function()
    local ctx = placementContext()
    ctx.equip(); assert(ctx.yaw() == 0)
    ctx.key("R", false); ctx.equip(); assert(ctx.yaw() == math.rad(90))
    ctx.removePlacement(); ctx.equip(); assert(ctx.yaw() == 0)
end)
test("R turns 90 degrees and Q E fine tune without reacting while typing", function()
    local ctx = placementContext(); ctx.equip()
    ctx.key("R", false); ctx.key("Q", false); assert(math.abs(ctx.yaw() - math.rad(75)) < 1e-9)
    ctx.key("E", false); assert(math.abs(ctx.yaw() - math.rad(90)) < 1e-9)
    ctx.key("R", true); ctx.focused(true); ctx.key("R", false)
    assert(math.abs(ctx.yaw() - math.rad(90)) < 1e-9)
end)
test("preview ray uses physical mouse coordinates and wall bottom center", function()
    local ctx = placementContext(); ctx.equip(); ctx.render()
    assert(ctx.ray()[1] == 740 and ctx.ray()[2] == 386)
    assert(ctx.ghost().CFrame.right.y == 15)
    ctx.click(); assert(#ctx.builds == 1)
    ctx.overPanel(true); ctx.render(); ctx.click(); assert(#ctx.builds == 1)
end)

local function progressContext()
    local UI, phaseLabel, progressCount, progressFill, progressMeta = {}, {}, {}, {}, {}
    local C = {blue = "blue"}
    local UDim2 = {fromScale = function(x, y) return {x = x, y = y} end}
    local os = {clock = function() return 20 end}
    --[[PROGRESS]]
    return {reset = resetProgress, show = showBuildProgress, state = UI, fill = progressFill, count = progressCount, meta = progressMeta}
end
test("progress uses verified counts and measured rate", function()
    local ctx = progressContext(); ctx.reset(); ctx.state.startedAt = 10
    ctx.show(20, 100)
    assert(ctx.fill.Size.x == 0.2 and ctx.count.Text == "20 / 100")
    assert(ctx.meta.Text:find("2.0 blocks/s", 1, true) and ctx.meta.Text:find("ETA ~40s", 1, true))
end)
test("zero placements show no invented speed or ETA", function()
    local ctx = progressContext(); ctx.reset(); ctx.state.startedAt = 10; ctx.show(0, 100)
    assert(ctx.fill.Size.x == 0 and ctx.meta.Text == "Waiting for verified placements...")
end)

test("final progress uses measured wall time instead of material preparation time", function()
    local ctx = progressContext(); ctx.reset(); ctx.state.startedAt = 0
    ctx.show(173, 60430, "BUILD STOPPED", 7)
    assert(ctx.meta.Text:find("24.7 blocks/s", 1, true) and ctx.meta.Text:find("7s elapsed", 1, true))
    assert(not ctx.meta.Text:find("ETA", 1, true))
end)

test("material phase explains preparation without showing a placement rate", function()
    local ctx = progressContext(); ctx.reset(); ctx.state.startedAt = 10
    ctx.show(0, 60430, "PREPARING MATERIAL")
    assert(ctx.fill.Size.x == 0 and ctx.meta.Text == "Checking available material before wall placement...")
end)

local function telemetryContext()
    local sent = {}
    local Backend = {report = function(report) table.insert(sent, report) end}
    local task = {spawn = function(callback) callback() end}
    local HttpService = {JSONEncode = function(_, data) return data end}
    local game = {PlaceId = 537413528, JobId = "fixture"}

    local function safeError(value) return tostring(value) end
    --[[TELEMETRY]]
    return {send = sendTelemetry, sent = sent}
end

test("preparation reports preserve measured gains and bound per-round diagnostics", function()
    local ctx = telemetryContext()
    local samples = {}
    for index = 1, 40 do samples[index] = {before = index, after = index + 0.5, requests = 1, gain = 0.5, ignored = "raw"} end
    ctx.send({placement_count = 60430}, true, {ok = false, completed = 0, diagnostics = {
        infinite_requested = true, inventory_before = 25195, inventory_after = 25211,
        prep_version = 2, prep_rounds = 32, prep_scale_requests = 32, prep_gain = 16,
        prep_stop_reason = "round_limit", prep_samples = samples,
        speed_mode = "Rapid", effective_request_rate = 600, peak_pending = 42,
        wall_elapsed_seconds = 12.5, verified_blocks_per_second = 0,
        pipeline_version = 1, pipeline_windows = 4, pipeline_peak_ready = 64, pipeline_peak_active = 768,
        pipeline_paint_batches = 25, manual_drains = 2, rpc_completed = 2000,
        rpc_latency_total_seconds = 800, rpc_latency_max_seconds = 0.75, rpc_latency_mean_seconds = 0.4,
        worker_limit = 384, batch_limit = 1024, peak_geometry_jobs = 1024,
        max_request_rate = 600, max_pending_limit = 64, adaptive_upshifts = 3, adaptive_downshifts = 2,
        adaptive_peak_rate = 240, adaptive_peak_workers = 24, rpc_latency_ewma_seconds = 0.8,
        monitor_delay_ewma_seconds = 0.045, monitor_delay_max_seconds = 0.35,
        replication_peak_waiting = 40, replication_pause_count = 2, verification_budget_seconds = 16,
        verification_checks_peak = 32, verification_failure_phase = "paint", verification_failure_owned = true,
        verification_position_error = 0.001, verification_size_error = 0.002, verification_color_error = 0.2,
        verification_right_dot = 1, verification_up_dot = 0.99, verification_wait_seconds = 16,
    }}, "background", true, "Rapid")
    local body = ctx.sent[1]
    assert(body.settings.toolMode == "background" and body.settings.infiniteBlocks == true)
    local diag = body.result.diagnostics
    assert(diag.prep_version == 2 and diag.prep_rounds == 32 and diag.prep_scale_requests == 32)
    assert(diag.prep_gain == 16 and diag.prep_stop_reason == "round_limit")
    assert(body.settings.speed == "Rapid" and diag.speed_mode == "Rapid" and diag.effective_request_rate == 600)
    assert(diag.peak_pending == 42 and diag.wall_elapsed_seconds == 12.5 and diag.verified_blocks_per_second == 0)
    assert(diag.pipeline_version == 1 and diag.pipeline_windows == 4 and diag.pipeline_peak_active == 768)
    assert(diag.pipeline_peak_ready == 64 and diag.pipeline_paint_batches == 25 and diag.manual_drains == 2)
    assert(diag.rpc_completed == 2000 and diag.rpc_latency_total_seconds == 800)
    assert(diag.rpc_latency_max_seconds == 0.75 and diag.rpc_latency_mean_seconds == 0.4)
    assert(diag.worker_limit == 384 and diag.batch_limit == 1024 and diag.peak_geometry_jobs == 1024)
    assert(diag.max_request_rate == 600 and diag.max_pending_limit == 64)
    assert(diag.adaptive_upshifts == 3 and diag.adaptive_downshifts == 2)
    assert(diag.adaptive_peak_rate == 240 and diag.adaptive_peak_workers == 24)
    assert(diag.rpc_latency_ewma_seconds == 0.8 and diag.monitor_delay_ewma_seconds == 0.045)
    assert(diag.monitor_delay_max_seconds == 0.35 and diag.replication_peak_waiting == 40)
    assert(diag.replication_pause_count == 2 and diag.verification_budget_seconds == 16 and diag.verification_checks_peak == 32)
    assert(diag.verification_failure_phase == "paint" and diag.verification_failure_owned == true)
    assert(diag.verification_position_error == 0.001 and diag.verification_size_error == 0.002)
    assert(diag.verification_color_error == 0.2 and diag.verification_right_dot == 1)
    assert(diag.verification_up_dot == 0.99 and diag.verification_wait_seconds == 16)
    assert(#diag.prep_samples == 32 and diag.prep_samples[32].after == 32.5 and diag.prep_samples[1].ignored == nil)
end)

local function speedContext()
    --[[SPEED_INITIAL]]
    local speedMenu, blockMenu, explanation = {}, {}, {}
    local speedButton, toolModeButton = {Activated = {}}, {Activated = {}}
    local callbacks, choices, messages = {}, {}, {}
    local C = {yellow = "yellow", dim = "dim"}
    local running = false
    local function busy() return running end
    local function connect(signal, callback) callbacks[signal] = callback end
    local function button(_, name)
        local value = {Activated = {}}
        choices[name] = value
        return value
    end
    local function anchorMenu() end
    local function setStatus(message) table.insert(messages, message) end
    --[[MODES]]
    --[[SPEEDS]]
    return {
        choose = function(name) callbacks[choices[name].Activated]() end,
        changeMode = function() callbacks[toolModeButton.Activated]() end,
        running = function(value) running = value end,
        speed = function() return speed end,
        mode = function() return toolMode end,
        messages = messages,
    }
end
test("Rapid is selected initially and incompatible mode falls back visibly to Fast", function()
    local ctx = speedContext()
    assert(ctx.speed() == "Rapid" and ctx.mode() == "background")
    ctx.changeMode(); assert(ctx.speed() == "Fast" and ctx.mode() == "compatible")
    ctx.choose("Rapid"); assert(ctx.speed() == "Fast")
    assert(ctx.messages[#ctx.messages]:find("Select Hands free", 1, true))
    ctx.changeMode(); ctx.choose("Rapid"); assert(ctx.speed() == "Rapid")
end)
test("running builds keep their speed and tool mode while controls are clicked", function()
    local ctx = speedContext(); ctx.running(true)
    ctx.choose("Normal"); ctx.changeMode()
    assert(ctx.speed() == "Rapid" and ctx.mode() == "background")
    ctx.running(false); ctx.choose("Normal"); assert(ctx.speed() == "Normal")
end)

local function nativeSelectorContext(empty)
    local function signal()
        local callbacks = {}
        return {Connect = function(_, callback)
            local connection = {active = true}
            function connection:Disconnect() self.active = false end
            table.insert(callbacks, {connection, callback})
            return connection
        end, Fire = function(_, ...)
            for _, entry in ipairs(callbacks) do if entry[1].active then entry[2](...) end end
        end}
    end
    local function node(class, name, children)
        local object = {ClassName = class, Name = name, Visible = true, Enabled = true, children = children or {}}
        function object:IsA(kind)
            return kind == class or (kind == "GuiButton" and class == "TextButton")
                or (kind == "GuiObject" and (class == "Frame" or class == "TextButton" or class == "TextLabel"))
        end
        function object:GetChildren() return self.children end
        function object:FindFirstChild(target)
            for _, child in ipairs(self.children) do if child.Name == target then return child end end
        end
        function object:GetDescendants()
            local values = {}
            local function walk(item)
                for _, child in ipairs(item.children) do table.insert(values, child); walk(child) end
            end
            walk(self)
            return values
        end
        for _, child in ipairs(object.children) do child.Parent = object end
        return object
    end
    local label = node("TextLabel", "ToolName"); label.Text = "BuildingTool"; label.Visible = false
    local slot = node("TextButton", "2", {label}); slot.Activated = signal()
    local hotbar = node("Frame", "Hotbar", {slot})
    if empty then hotbar.children = {}; slot.Parent = nil end
    local native = node("Frame", "Backpack", {hotbar}); native.DescendantAdded = signal()
    local robloxGui = node("ScreenGui", "RobloxGui", {native})
    local core = node("CoreGui", "CoreGui", {robloxGui})
    local tool = node("Tool", "BuildingTool")
    local backpack = node("Backpack", "Backpack", {tool})
    local player = {Character = node("Model", "Character"), FindFirstChildOfClass = function() return backpack end}
    local destroyed, building, toolMode = false, true, "background"
    local focused
    local UserInputService = {InputBegan = signal(), GetFocusedTextBox = function() return focused end}
    local guiService = {MenuIsOpen = false}
    local game = {GetService = function(_, name)
        if name == "GuiService" then return guiService end
        assert(name == "CoreGui"); return core
    end}
    --[[MANUAL_SELECTOR]]
    local get, stop = createManualToolSelector()
    return {get = get, stop = stop, tool = tool, slot = slot, hotbar = hotbar,
        click = function() slot.Activated:Fire() end,
        key = function() UserInputService.InputBegan:Fire({KeyCode = {Name = "Two"}}) end,
        focused = function(value) focused = value end,
        menu = function(value) guiService.MenuIsOpen = value end,
        coreEnabled = function(value) robloxGui.Enabled = value end,
        addSlot = function()
            hotbar.children = {slot}; slot.Parent = hotbar
            native.DescendantAdded:Fire(slot)
        end,
        duplicate = function() table.insert(backpack.children, node("Tool", "BuildingTool")) end,
        compatible = function() toolMode = "compatible" end}
end
test("existing native hotbar click resolves exact owned tool despite hidden icon label", function()
    local ctx = nativeSelectorContext(); assert(ctx.get().revision == 0 and ctx.get().available)
    ctx.click(); assert(ctx.get().tool == ctx.tool and ctx.get().revision == 1)
    ctx.key(); assert(ctx.get().tool == nil and ctx.get().revision == 2)
    ctx.click(); assert(ctx.get().tool == ctx.tool and ctx.get().revision == 3)
    ctx.stop(); ctx.click(); ctx.key(); assert(ctx.get().revision == 3)
end)
test("native selection ignores typing hidden bars and incompatible builds", function()
    local ctx = nativeSelectorContext()
    ctx.focused(true); ctx.key(); assert(ctx.get().revision == 0)
    ctx.focused(false); ctx.hotbar.Visible = false; ctx.key(); assert(ctx.get().revision == 0)
    ctx.hotbar.Visible = true; ctx.coreEnabled(false); ctx.key(); assert(ctx.get().revision == 0)
    ctx.coreEnabled(true); ctx.menu(true); ctx.key(); assert(ctx.get().revision == 0)
    ctx.menu(false); ctx.compatible(); ctx.click(); assert(ctx.get().revision == 0)
end)
test("native selection refuses ambiguous duplicate tool names", function()
    local ctx = nativeSelectorContext(); ctx.click(); assert(ctx.get().tool == ctx.tool)
    ctx.duplicate(); ctx.click(); ctx.key()
    assert(ctx.get().revision == 3 and ctx.get().tool == nil)
end)
test("native selection reports unavailable until a recognized slot appears", function()
    local ctx = nativeSelectorContext(true)
    assert(ctx.get().available == false); ctx.key(); assert(ctx.get().revision == 0)
    ctx.addSlot(); assert(ctx.get().available == true)
    ctx.click(); assert(ctx.get().tool == ctx.tool and ctx.get().revision == 1)
end)

local function startupContext(settings)
    settings = settings or {}
    local now, stops, destroys, warnings = 0, 0, 0, {}
    local env, replacement = {}, {Version = 2}
    local previous
    if settings.previous then
        previous = {
            IsBusy = function() return settings.busy and (not settings.finishAfter or now < settings.finishAfter) end,
            Stop = function() stops += 1 end,
            Destroy = function()
                assert(not settings.busy or settings.finishAfter and now >= settings.finishAfter)
                destroys += 1
            end,
        }
        env.ImageBuilder = previous
    end
    local function getgenv() return env end
    local os = {clock = function() return now end}
    local task = {wait = function(delay)
        now += delay
        if settings.replaceWhileWaiting then env.ImageBuilder = replacement end
    end}
    local function warn(message) table.insert(warnings, message) end
    local function load()
        --[[STARTUP]]
        env.ImageBuilder = {Version = 2}
        return true
    end
    local installed = load()
    return {installed = installed, stops = stops, destroys = destroys, warnings = warnings,
        elapsed = now, current = env.ImageBuilder, previous = previous, replacement = replacement}
end

test("startup installs directly when no builder exists", function()
    local result = startupContext()
    assert(result.installed and result.current.Version == 2 and result.elapsed == 0)
end)

test("startup replaces an idle old builder without a second loader execution", function()
    local result = startupContext({previous = true})
    assert(result.installed and result.stops == 0 and result.destroys == 1 and result.elapsed == 0)
end)

test("startup waits for a busy old builder to stop and then replaces it", function()
    local result = startupContext({previous = true, busy = true, finishAfter = 0.2})
    assert(result.installed and result.stops == 1 and result.destroys == 1)
    assert(result.elapsed >= 0.2 and result.elapsed < 1 and #result.warnings == 0)
end)

test("startup wait stays bounded and never destroys a still busy builder", function()
    local result = startupContext({previous = true, busy = true})
    assert(not result.installed and result.stops == 1 and result.destroys == 0)
    assert(result.elapsed >= 15 and result.elapsed < 15.2 and #result.warnings == 1)
    assert(result.current == result.previous)
end)

test("startup preserves a replacement installed by another loader while waiting", function()
    local result = startupContext({previous = true, busy = true, finishAfter = 0.2, replaceWhileWaiting = true})
    assert(not result.installed and result.stops == 1 and result.destroys == 0)
    assert(result.current == result.replacement)
end)

print("GUI_OPTION_TESTS_PASSED " .. passed)
