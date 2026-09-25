-- Deterministic local doubles only. No Roblox/Wave connection or real remotes.
local clock = 0
local queue = {}
local frameStep
local hitchAt, hitchDuration, hitchApplied
local task = {}
local os = {clock = function() return clock end}
local function resumeThread(thread, ...)
    local ok, delay = coroutine.resume(thread, ...)
    assert(ok, tostring(delay))
    if coroutine.status(thread) ~= "dead" then
        table.insert(queue, {at = clock + math.max(delay or 0, 0.000001), thread = thread})
    end
end
function task.spawn(callback, ...)
    local thread = coroutine.create(callback)
    resumeThread(thread, ...)
    return thread
end
function task.defer(callback, ...)
    local args = table.pack(...)
    local thread = coroutine.create(function() callback(table.unpack(args, 1, args.n)) end)
    table.insert(queue, {at = clock + 0.000001, thread = thread})
    return thread
end
function task.wait(delay)
    delay = delay or 1 / 60
    local frame = type(frameStep) == "function" and frameStep() or frameStep
    if frame then
        local deadline = math.ceil((clock + math.max(delay, 0.000001) - 0.000000001) / frame) * frame
        delay = math.max(frame * 0.000001, deadline - clock)
    end
    return coroutine.yield(delay)
end
local function nextTask()
    local best = 1
    for i = 2, #queue do if queue[i].at < queue[best].at then best = i end end
    local item = table.remove(queue, best)
    clock = math.max(clock, item.at)
    if hitchAt and not hitchApplied and clock >= hitchAt then
        hitchApplied = true
        clock += hitchDuration
    end
    resumeThread(item.thread)
end
local function run(callback)
    local finished, result = false, nil
    task.spawn(function() result = callback(); finished = true end)
    local steps = 0
    while not finished do
        assert(#queue > 0, "Mock scheduler deadlocked")
        steps += 1
        assert(steps < 2000000 and clock < 600, "Mock scheduler exceeded bounds")
        nextTask()
    end
    return result
end
local function drain()
    local steps = 0
    while #queue > 0 do
        steps += 1
        assert(steps < 100000, "Too many pending mock tasks")
        nextTask()
    end
end

local Vector3 = {}
local vectorMethods = {}
local vectorMeta = {
    __index = function(v, key)
        if key == "Magnitude" then return math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z) end
        return vectorMethods[key]
    end,
    __add = function(a, b) return Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end,
    __sub = function(a, b) return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end,
}
function Vector3.new(x, y, z) return setmetatable({X = x, Y = y, Z = z}, vectorMeta) end
function vectorMethods:Dot(other) return self.X * other.X + self.Y * other.Y + self.Z * other.Z end
local CFrame = {}
local frameMethods = {}
local function rotate(vector, yaw)
    return Vector3.new(math.cos(yaw) * vector.X + math.sin(yaw) * vector.Z,
        vector.Y, -math.sin(yaw) * vector.X + math.cos(yaw) * vector.Z)
end
local frameMeta = {
    __index = function(cf, key)
        if key == "RightVector" then return rotate(Vector3.new(1, 0, 0), cf.yaw) end
        if key == "UpVector" then return Vector3.new(0, 1, 0) end
        return frameMethods[key]
    end,
    __mul = function(a, b)
        local pos = a.Position + rotate(b.Position, a.yaw)
        local value = CFrame.new(pos.X, pos.Y, pos.Z)
        value.yaw = a.yaw + b.yaw
        return value
    end,
}
function CFrame.new(x, y, z)
    return setmetatable({Position = Vector3.new(x or 0, y or 0, z or 0), yaw = 0}, frameMeta)
end
function CFrame.Angles(_, yaw, _) local cf = CFrame.new(); cf.yaw = yaw; return cf end
function frameMethods:PointToWorldSpace(vector) return self.Position + rotate(vector, self.yaw) end
function frameMethods:PointToObjectSpace(vector) return rotate(vector - self.Position, -self.yaw) end
function frameMethods:ToObjectSpace(other)
    local position = self:PointToObjectSpace(other.Position)
    local cf = CFrame.new(position.X, position.Y, position.Z)
    cf.yaw = other.yaw - self.yaw
    return cf
end
local Color3 = {fromRGB = function(r, g, b) return {R = r / 255, G = g / 255, B = b / 255} end}

local function signal()
    local callbacks = {}
    return {
        Connect = function(_, callback)
            local connection = {Connected = true}
            function connection:Disconnect() self.Connected = false end
            table.insert(callbacks, {connection = connection, callback = callback})
            return connection
        end,
        Fire = function(_, child)
            for _, entry in ipairs(callbacks) do
                if entry.connection.Connected then entry.callback(child) end
            end
        end,
        listenerCount = function()
            local count = 0
            for _, entry in ipairs(callbacks) do if entry.connection.Connected then count += 1 end end
            return count
        end,
    }
end
local instanceMethods = {}
local instanceMeta = {__index = function(instance, key)
    if key == "Parent" then return rawget(instance, "_parent") end
    if key == "Disabled" then return rawget(instance, "_disabled") end
    if key == "Position" and instance.CFrame then return instance.CFrame.Position end
    if instanceMethods[key] then return instanceMethods[key] end
    for _, child in ipairs(instance.children) do if child.Name == key then return child end end
end, __newindex = function(child, key, value)
    if key == "Disabled" then
        if rawget(child, "_disabled") == true and value == false then rawset(child, "_controllerReadyAt", clock + 1 / 60) end
        rawset(child, "_disabled", value)
        return
    end
    if key ~= "Parent" then rawset(child, key, value); return end
    local old = rawget(child, "_parent")
    if old == value then return end
    if old then
        for i, member in ipairs(old.children) do
            if member == child then table.remove(old.children, i); break end
        end
    end
    rawset(child, "_parent", value)
    if child.ClassName == "Tool" and old and old.Name == "Character" then child.Unequipped:Fire() end
    if value then
        table.insert(value.children, child)
        value.ChildAdded:Fire(child)
        local ancestor = value
        while ancestor do
            ancestor.DescendantAdded:Fire(child)
            ancestor = ancestor.Parent
        end
        if child.ClassName == "Tool" and value.Name == "Character" then child.Equipped:Fire() end
    end
end}
local function instance(class, name)
    return setmetatable({ClassName = class, Name = name, children = {}, ChildAdded = signal(),
        DescendantAdded = signal(), Equipped = signal(), Unequipped = signal(), _instance = true}, instanceMeta)
end
function instanceMethods:IsA(class)
    return self.ClassName == class or (class == "BasePart" and self.ClassName == "Part")
end
function instanceMethods:FindFirstChild(name)
    for _, child in ipairs(self.children) do if child.Name == name then return child end end
end
function instanceMethods:FindFirstChildOfClass(class)
    for _, child in ipairs(self.children) do if child:IsA(class) then return child end end
end
function instanceMethods:GetChildren() return table.clone(self.children) end
function instanceMethods:GetDescendants()
    local descendants = {}
    local function visit(node)
        for _, child in ipairs(node.children) do table.insert(descendants, child); visit(child) end
    end
    visit(self)
    return descendants
end
function instanceMethods:IsDescendantOf(ancestor)
    local current = self.Parent
    while current do if current == ancestor then return true end; current = current.Parent end
    return false
end
local function parent(child, value)
    child.Parent = value
    return child
end
local function typeof(value) return type(value) == "table" and value._instance and "Instance" or type(value) end
local sharedEnvironment = {}
local function getgenv() return sharedEnvironment end
local game
local function newAdapter()
    return (function()
--[[ADAPTER_SOURCE]]
    end)()
end

local function context(settings)
    settings = settings or {}
    clock, queue, sharedEnvironment = 0, {}, {}
    frameStep = settings.frameStep
    hitchAt, hitchDuration, hitchApplied = settings.hitchAt, settings.hitchDuration or 0, false
    local ctx = {settings = settings, calls = {}, dispatches = {}, built = {}, scaled = {}, painted = {}, deleted = {},
        counters = {}, tools = {}, remotes = {}, scripts = {}, guis = {}, equipCalls = 0}
    ctx.world = instance("Workspace", "Workspace")
    ctx.player = instance("Player", "TestBuilder")
    ctx.player.TeamColor = "Red"
    ctx.player.Team = {Name = settings.teamName or "Red"}
    ctx.character = instance("Model", "Character")
    ctx.player.Character = ctx.character
    ctx.backpack = parent(instance("Backpack", "Backpack"), ctx.player)
    ctx.playerGui = parent(instance("PlayerGui", "PlayerGui"), ctx.player)
    for _, name in ipairs({"BuildGui", "PaintGui", "ScaleToolDisplayGui", "DeleteGui", "UnrelatedGui"}) do
        local gui = parent(instance("ScreenGui", name), ctx.playerGui)
        gui.Enabled = true
        ctx.guis[name] = gui
    end
    local humanoid = parent(instance("Humanoid", "Humanoid"), ctx.character)
    humanoid.Health = 100
    function humanoid:EquipTool(tool)
        ctx.equipCalls += 1
        if settings.allowEquip then ctx:hold(tool); return end
        error("The background adapter must never equip a tool")
    end
    function humanoid:UnequipTools() ctx:hold(nil) end
    function ctx:hold(tool)
        for _, child in ipairs(ctx.character:GetChildren()) do
            if child:IsA("Tool") then parent(child, ctx.backpack) end
        end
        if tool then parent(tool, ctx.character) end
    end
    if settings.noHumanoid then parent(humanoid, nil) end
    local data = parent(instance("Folder", "Data"), ctx.player)
    ctx.stock = parent(instance("IntValue", settings.blockType or "PlasticBlock"), data)
    ctx.stock.Value = settings.stock or 100
    if settings.used or settings.prepUsesUsed then
        ctx.used = parent(instance("NumberValue", "Used"), ctx.stock)
        ctx.used.Value = settings.used or 0
    end
    local blocks = parent(instance("Folder", "Blocks"), ctx.world)
    ctx.folder = parent(instance("Folder", ctx.player.Name), blocks)
    ctx.zone = parent(instance("Part", "RedZone"), ctx.world)
    ctx.zone.CFrame = CFrame.new()
    ctx.zone.Size = Vector3.new(200, 1, 200)
    local team = parent(instance("BrickColorValue", "TeamColor"), ctx.zone)
    team.Value = ctx.player.TeamColor
    local launched = parent(instance("BoolValue", "Launched"), ctx.zone)
    launched.Value = false
    function ctx:addBlock(cf)
        local model = instance("Model", settings.blockType or "PlasticBlock")
        local part = parent(instance("Part", "PPart"), model)
        part.CFrame = cf
        part.Size = Vector3.new(2, 2, 2)
        part.Color = Color3.fromRGB(255, 255, 255)
        local delay = type(settings.replicationDelay) == "function" and settings.replicationDelay(ctx, "build") or settings.replicationDelay
        if delay and delay > 0 then
            task.spawn(function() task.wait(delay); parent(model, self.folder) end)
        else parent(model, self.folder) end
        return model
    end
    for _, pair in ipairs({{"BuildingTool", "build"}, {"ScalingTool", "scale"}, {"PaintingTool", "paint"}, {"DeleteTool", "delete"}}) do
        if pair[2] == "delete" and settings.noDelete then continue end
        local tool = parent(instance("Tool", pair[1]), ctx.backpack)
        local script = parent(instance("LocalScript", "ToolClient"), tool)
        script.Disabled = false
        ctx.scripts[pair[2]] = script
        local remote = parent(instance("RemoteFunction", "RF"), tool)
        local stage = pair[2]
        ctx.tools[stage], ctx.remotes[stage] = tool, remote
        function remote:InvokeServer(...)
            local args = table.pack(...)
            local prepScale = stage == "scale" and args[1].preparation
            if prepScale then
                ctx.activePrepScales = (ctx.activePrepScales or 0) + 1
                ctx.maxPrepScales = math.max(ctx.maxPrepScales or 0, ctx.activePrepScales)
            end
            ctx.counters[stage] = (ctx.counters[stage] or 0) + 1
            local count = ctx.counters[stage]
            table.insert(ctx.calls, {stage = stage, args = args, at = clock, owner = tool.Parent})
            if settings.onDispatch then settings.onDispatch(ctx, stage, args, count) end
            if settings.delayStage == stage then task.wait(settings.delay or 20) end
            if prepScale then ctx.activePrepScales -= 1 end
            if settings.errorStage == stage then error("mock rejection") end
            if settings.declineStage == stage then return false end
            if settings.requireHeld and tool.Parent ~= ctx.character then return false end
            if stage == "build" then
                if settings.noNewBlock then return ctx.preexisting end
                if settings.beforeBuild then settings.beforeBuild(ctx, count, args) end
                local model = ctx:addBlock(args[6] or (args[3].CFrame * args[4]))
                model.preparation = args[6] == nil and args[8] == false
                table.insert(ctx.built, model)
                if settings.prepUsesUsed then ctx.used.Value += 1 else ctx.stock.Value -= 1 end
                if settings.afterBuild then settings.afterBuild(ctx, count) end
                if settings.returnOld then return ctx.preexisting end
                if settings.returnNil then return nil end
                return model
            elseif stage == "scale" then
                table.insert(ctx.scaled, args[1])
                if not settings.noScale then
                    local function applyGeometry() args[1].PPart.Size = args[2]; args[1].PPart.CFrame = args[3] end
                    local delay = type(settings.replicationDelay) == "function" and settings.replicationDelay(ctx, "scale") or settings.replicationDelay
                    if delay and delay > 0 then
                        task.spawn(function() task.wait(delay); applyGeometry() end)
                    else applyGeometry() end
                end
                if settings.minimumScale then
                    args[1].PPart.Size = Vector3.new(math.max(args[2].X, settings.minimumScale),
                        math.max(args[2].Y, settings.minimumScale), math.max(args[2].Z, settings.minimumScale))
                end
                if settings.afterScale then settings.afterScale(ctx, count) end
                if args[1].preparation and settings.prepGain then
                    local gain = type(settings.prepGain) == "function" and settings.prepGain(ctx, count, args)
                        or settings.prepGain
                    if settings.prepGainOnDelete then
                        args[1].pendingPrepGain = (args[1].pendingPrepGain or 0) + gain
                    elseif settings.prepUsesUsed then ctx.used.Value -= gain
                    else ctx.stock.Value += gain end
                end
                return true
            elseif stage == "delete" then
                table.insert(ctx.deleted, args[1])
                if not settings.noDeleteEffect then
                    parent(args[1], nil)
                    if args[1].preparation then
                        if settings.prepUsesUsed then ctx.used.Value -= 1 else ctx.stock.Value += 1 end
                        local gain = args[1].pendingPrepGain or 0
                        local function applyGain()
                            if settings.prepGainDelay then task.wait(settings.prepGainDelay) end
                            if settings.prepUsesUsed then ctx.used.Value -= gain
                            else ctx.stock.Value += gain end
                        end
                        if settings.prepGainDelay then task.spawn(applyGain) else applyGain() end
                    end
                end
                if settings.afterDelete then settings.afterDelete(ctx, count, args) end
                return true
            else
                for _, entry in ipairs(args[1]) do
                    table.insert(ctx.painted, entry[1])
                    if not settings.noPaint then
                        local delay = type(settings.replicationDelay) == "function" and settings.replicationDelay(ctx, "paint") or settings.replicationDelay
                        if delay and delay > 0 then
                            task.spawn(function() task.wait(delay); entry[1].PPart.Color = entry[2] end)
                        else entry[1].PPart.Color = entry[2] end
                    end
                end
                if settings.afterPaint then settings.afterPaint(ctx, count) end
                return true
            end
        end
        if settings.remoteDelay then
            local originalInvoke = remote.InvokeServer
            function remote:InvokeServer(...)
                table.insert(ctx.dispatches, {stage = stage, at = clock, pending = sharedEnvironment.__ImageBuilderFlight.pending})
                ctx.activeRemoteCalls = (ctx.activeRemoteCalls or 0) + 1
                ctx.maxRemoteCalls = math.max(ctx.maxRemoteCalls or 0, ctx.activeRemoteCalls)
                if stage == "paint" then
                    ctx.activePaintCalls = (ctx.activePaintCalls or 0) + 1
                    ctx.maxPaintCalls = math.max(ctx.maxPaintCalls or 0, ctx.activePaintCalls)
                end
                local delay = type(settings.remoteDelay) == "function" and settings.remoteDelay(ctx, stage) or settings.remoteDelay
                task.wait(delay)
                local ok, result = pcall(originalInvoke, self, ...)
                ctx.activeRemoteCalls -= 1
                if stage == "paint" then ctx.activePaintCalls -= 1 end
                if not ok then error(result) end
                return result
            end
        end
    end
    game = {PlaceId = 537413528, GetService = function(_, name)
        if name == "Players" then return {LocalPlayer = ctx.player} end
        if name == "Workspace" then return ctx.world end
        error("Unexpected service " .. name)
    end}
    ctx.adapter = newAdapter()
    return ctx
end
local function plan(count)
    local rects = {}
    for x = 0, (count or 3) - 1 do table.insert(rects, {x = x, y = 0, w = 1, h = 1, color = {230, (x * 30) % 256, 50}}) end
    return {pixel_studs = 0.5, width_studs = (count or 3) * 0.5, height_studs = 0.5,
        columns = count or 3, rows = 1, cells = {}, block_type = "PlasticBlock", rectangles = rects}
end
local function equal(a, b, message) assert(a == b, (message or "Mismatch") .. ": " .. tostring(a) .. " ~= " .. tostring(b)) end
local function near(a, b) assert(math.abs(a - b) < 0.000001, tostring(a) .. " not near " .. tostring(b)) end
local function has(text, needle) assert(string.find(text, needle, 1, true), text .. " lacks " .. needle) end
local tests = 0
local function test(name, callback)
    local ok, message = pcall(callback)
    assert(ok, name .. ": " .. tostring(message))
    tests += 1
    print("PASS " .. name)
end

test("upright geometry starts from image top and composes wall rotation", function()
    local ctx = context()
    local p = {pixel_studs = 0.5, width_studs = 1, height_studs = 1}
    local cf, size = ctx.adapter.geometry(p, {x = 0, y = 0, w = 1, h = 1}, CFrame.new(10, 20, 30))
    near(cf.Position.X, 9.75); near(cf.Position.Y, 20.75); near(cf.Position.Z, 30)
    near(size.X, 0.5); near(size.Y, 0.5); near(size.Z, 0.5)
    local rotated = CFrame.new(10, 20, 30) * CFrame.Angles(0, math.pi / 2, 0)
    cf, size = ctx.adapter.geometry(p, {x = 0, y = 1, w = 2, h = 1}, rotated)
    near(cf.Position.X, 10); near(cf.Position.Y, 20.25); near(cf.Position.Z, 30)
    near(size.X, 1); near(cf.RightVector.Z, -1)
end)

test("first block build scale paint is verified before bulk; payloads are exact", function()
    local ctx = context()
    local p, origin = plan(), CFrame.new(5, 3, 7)
    local result = run(function() return ctx.adapter.build(p, origin, {speed = "Normal"}) end)
    assert(result.ok, result.message); equal(result.completed, 3); equal(result.created, 3)
    local stages = {}; for _, call in ipairs(ctx.calls) do table.insert(stages, call.stage) end
    equal(table.concat(stages, ","), "build,scale,paint,build,build,scale,scale,paint")
    local args = ctx.calls[1].args
    equal(args.n, 8); equal(args[1], "PlasticBlock"); equal(args[2], 100); equal(args[3], ctx.zone)
    equal(args[5], true); equal(args[7], false); equal(args[8], true)
    near((args[4].Position - ctx.zone.CFrame:ToObjectSpace(args[6]).Position).Magnitude, 0)
    equal(ctx.calls[2].args.n, 3); equal(ctx.calls[2].args[1], ctx.built[1])
    near(ctx.calls[2].args[2].X, 0.5)
    equal(ctx.calls[3].args.n, 1); equal(#ctx.calls[3].args[1], 1)
    equal(ctx.calls[3].args[1][1][1], ctx.built[1])
    near(ctx.calls[3].args[1][1][2].R, 230 / 255)
    equal(#ctx.calls[8].args[1], 2)
    equal(ctx.folder.ChildAdded.listenerCount(), 0)
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
    equal(sharedEnvironment.__ImageBuilderFlight.busy, false)
end)

test("both tool modes preserve the recorded eight-argument WoodBlock call on a rotated plot", function()
    -- Normal manual placement captured 2026-09-24. This verifies the authored
    -- protocol shape against observed data, not real server acceptance.
    for _, mode in ipairs({"background", "compatible"}) do
        local ctx = context({blockType = "WoodBlock", stock = 928, allowEquip = true})
        ctx.zone.CFrame = CFrame.new(221.83432006835938, -17.99999237060547, 289.4931945800781)
            * CFrame.Angles(0, -math.pi / 2, 0)
        ctx.zone.Size = Vector3.new(251.80001831054688, 10.199999809265137, 299)
        local worldCF = CFrame.new(322.8343200683594, -11.899991989135742, 273.4931945800781)
            * CFrame.Angles(0, -math.pi / 2, 0)
        local p = plan(1)
        p.block_type = "WoodBlock"
        local origin = worldCF * CFrame.new(0, -p.pixel_studs / 2, 0)
        local result = run(function() return ctx.adapter.build(p, origin, {speed = "Normal", toolMode = mode}) end)
        assert(result.ok, result.message)
        local args = ctx.calls[1].args
        equal(args.n, 8); equal(args[1], "WoodBlock"); equal(args[2], 928); equal(args[3], ctx.zone)
        near(args[4].Position.X, -16); near(args[4].Position.Y, 6.100000381469727)
        near(args[4].Position.Z, -101); near(args[4].yaw, 0)
        equal(args[5], true)
        near((args[6].Position - worldCF.Position).Magnitude, 0); near(args[6].yaw, worldCF.yaw)
        equal(args[7], false); equal(args[8], true)
        equal(ctx.calls[1].owner, ctx.character)
        if mode == "background" then equal(ctx.equipCalls, 0) end
        equal(result.diagnostics.placement_argument_count, 8)
        equal(result.diagnostics.placement_tool_held, true)
    end
end)

test("failed first paint gate prevents further block requests", function()
    local ctx = context({noPaint = true})
    local result = run(function() return ctx.adapter.build(plan(), CFrame.new()) end)
    equal(result.ok, false); equal(result.completed, 0); equal(result.created, 1)
    equal(ctx.counters.build, 1); has(result.message, "paint color")
end)

test("preexisting block returned by remote is ignored in favor of new observed block", function()
    local ctx = context({returnOld = true})
    local p = plan(1)
    ctx.preexisting = ctx:addBlock(ctx.adapter.geometry(p, p.rectangles[1], CFrame.new()))
    local result = run(function() return ctx.adapter.build(p, CFrame.new()) end)
    assert(result.ok, result.message)
    equal(ctx.scaled[1], ctx.built[1]); equal(ctx.painted[1], ctx.built[1])
    near(ctx.preexisting.PPart.Size.X, 2); near(ctx.preexisting.PPart.Color.R, 1)
end)

test("without a new replicated block no preexisting block is scaled or painted", function()
    local ctx = context({noNewBlock = true})
    local p = plan(1)
    ctx.preexisting = ctx:addBlock(ctx.adapter.geometry(p, p.rectangles[1], CFrame.new()))
    local result = run(function() return ctx.adapter.build(p, CFrame.new()) end)
    equal(result.ok, false); equal(#ctx.scaled, 0); equal(#ctx.painted, 0)
    equal(ctx.counters.build, 1); has(result.message, "No new block appeared")
end)

test("inventory exhaustion stops before the next request and reports partial work", function()
    local ctx = context({stock = 1})
    local result = run(function() return ctx.adapter.build(plan(), CFrame.new(), {speed = "Normal"}) end)
    equal(result.ok, false); equal(result.completed, 1); equal(ctx.counters.build, 1)
    has(result.message, "Out of available"); has(result.message, "New or partial blocks may remain")
end)

test("explicit request rejection is not retried", function()
    local ctx = context({declineStage = "build"})
    local result = run(function() return ctx.adapter.build(plan(), CFrame.new()) end)
    equal(result.ok, false); equal(ctx.counters.build, 1); equal(#ctx.calls, 1)
    has(result.message, "declined")
end)

test("tool exception stops and releases completed flight lock", function()
    local ctx = context({errorStage = "scale"})
    local result = run(function() return ctx.adapter.build(plan(), CFrame.new()) end)
    equal(result.ok, false); equal(ctx.counters.build, 1); equal(ctx.counters.scale, 1)
    equal(ctx.counters.paint, nil); has(result.message, "mock rejection")
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
    equal(sharedEnvironment.__ImageBuilderFlight.busy, false)
end)

test("cancellation before execution issues no requests", function()
    local ctx = context()
    local result = run(function() return ctx.adapter.build(plan(), CFrame.new(), {shouldCancel = function() return true end}) end)
    equal(result.ok, false); equal(#ctx.calls, 0); equal(result.created, 0)
end)

test("cancellation while build is in flight stops following operations", function()
    local ctx = context({delayStage = "build", delay = 0.3})
    local result = run(function()
        return ctx.adapter.build(plan(), CFrame.new(), {shouldCancel = function() return clock >= 0.15 end})
    end)
    equal(result.ok, false); equal(ctx.counters.build, 1); equal(#ctx.calls, 1)
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
end)

test("timed out request remains locked until late completion with no duplicate retry", function()
    local ctx = context({delayStage = "build", delay = 20})
    local p = plan()
    local result = run(function() return ctx.adapter.build(p, CFrame.new()) end)
    equal(result.ok, false); has(result.message, "without retrying")
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 1)
    local valid, reason = ctx.adapter.validate(p)
    equal(valid, false); has(reason, "still running")
    local replacement = newAdapter()
    valid = replacement.validate(p); equal(valid, false)
    local again = run(function() return replacement.build(p, CFrame.new()) end)
    equal(again.ok, false); equal(#ctx.calls, 1)
    drain()
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
    equal(#ctx.built, 1); equal(#ctx.scaled, 0); equal(#ctx.painted, 0)
    equal(#ctx.calls, 1); assert(replacement.validate(p))
end)

test("respawn between phases stops before changing a tool", function()
    local ctx = context({afterBuild = function(value) value.player.Character = instance("Model", "Respawned") end})
    local result = run(function() return ctx.adapter.build(plan(), CFrame.new()) end)
    equal(result.ok, false); equal(ctx.counters.build, 1); equal(#ctx.calls, 1)
end)

test("wall outside plot is rejected before remote requests", function()
    local ctx = context()
    local result = run(function() return ctx.adapter.build(plan(), CFrame.new(100, 0, 0)) end)
    equal(result.ok, false); equal(#ctx.calls, 0); has(result.message, "inside")
end)

test("concurrent request reservations enforce aggregate preset rate", function()
    local ctx = context({returnNil = true})
    local p = plan(15)
    local result = run(function() return ctx.adapter.build(p, CFrame.new(), {speed = "Fast"}) end)
    assert(result.ok, result.message); equal(result.completed, 15)
    for index = 2, #ctx.calls do
        assert(ctx.calls[index].at - ctx.calls[index - 1].at >= 1 / 60 - 0.000001,
            "Aggregate calls exceeded selected rate")
    end
    local seen = {}
    for _, model in ipairs(ctx.scaled) do assert(not seen[model], "Model scaled twice"); seen[model] = true end
    equal(#ctx.scaled, 15); equal(#ctx.painted, 15)
end)

test("invalid finite geometry or colors fail validation before requests", function()
    local ctx = context()
    for _, mutate in ipairs({
        function(p) p.pixel_studs = 0 / 0 end,
        function(p) p.width_studs = math.huge end,
        function(p) p.height_studs = -1 end,
        function(p) p.rectangles[1].x = -1 end,
        function(p) p.rectangles[1].w = 100 end,
        function(p) p.rectangles[1].color[2] = 256 end,
    }) do
        local p = plan()
        mutate(p)
        equal(ctx.adapter.validate(p), false)
    end
    equal(#ctx.calls, 0)
end)

test("teardown makes the previous adapter reject another build", function()
    local ctx = context()
    ctx.adapter.teardown()
    local result = run(function() return ctx.adapter.build(plan(), CFrame.new()) end)
    equal(result.ok, false); has(result.message, "closed"); equal(#ctx.calls, 0)
end)

test("background directly holds owned tools without a Humanoid or any equip call", function()
    local ctx = context({noHumanoid = true})
    local result = run(function() return ctx.adapter.build(plan(5), CFrame.new()) end)
    assert(result.ok, result.message); equal(ctx.equipCalls, 0)
    for _, call in ipairs(ctx.calls) do equal(call.owner, ctx.character) end
    for _, tool in pairs(ctx.tools) do equal(tool.Parent, ctx.backpack) end
end)

test("an unrelated tool can stay selected throughout all background phases", function()
    local ctx = context({
        requireHeld = true,
        afterBuild = function(value) value:hold(value.otherTool) end,
        afterScale = function(value) value:hold(value.otherTool) end,
        afterPaint = function(value) value:hold(value.otherTool) end,
    })
    ctx.otherTool = parent(instance("Tool", "Jetpack"), ctx.backpack)
    local result = run(function() return ctx.adapter.build(plan(10), CFrame.new(), {speed = "Turbo"}) end)
    assert(result.ok, result.message); equal(result.completed, 10); equal(ctx.equipCalls, 0)
    equal(ctx.otherTool.Parent, ctx.character)
    for _, tool in pairs(ctx.tools) do equal(tool.Parent, ctx.backpack) end
end)

test("held background rejection stops without retry or Humanoid equip", function()
    local ctx = context({declineStage = "build"})
    local result = run(function() return ctx.adapter.build(plan(), CFrame.new()) end)
    equal(result.ok, false); has(result.message, "declined")
    equal(ctx.equipCalls, 0); equal(#ctx.calls, 1)
end)

test("fine pixel matching excludes an adjacent manual block created first", function()
    local ctx = context({returnNil = true, beforeBuild = function(value, _, args)
        value.manual = value:addBlock(args[6] * CFrame.new(0.05, 0, 0))
    end})
    local p = plan(1); p.pixel_studs, p.width_studs, p.height_studs = 0.05, 0.05, 0.05
    local result = run(function() return ctx.adapter.build(p, CFrame.new()) end)
    assert(result.ok, result.message)
    equal(ctx.scaled[1], ctx.built[1]); equal(ctx.painted[1], ctx.built[1])
    near(ctx.manual.PPart.Size.X, 2); near(ctx.manual.PPart.Color.R, 1)
end)

test("ambiguous fallback stops the entire batch before sizing or painting", function()
    local ctx = context({returnNil = true, beforeBuild = function(value, count, args)
        if count == 2 then value.manual = value:addBlock(args[6]) end
    end})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {speed = "Fast"}) end)
    equal(result.ok, false); equal(result.completed, 1); has(result.message, "Multiple new blocks")
    equal(#ctx.built, 3); equal(#ctx.scaled, 1); equal(#ctx.painted, 1)
    near(ctx.manual.PPart.Size.X, 2); near(ctx.manual.PPart.Color.R, 1)
end)

test("returned new owned instance takes priority over a manual block at its position", function()
    local ctx = context({beforeBuild = function(value, _, args) value.manual = value:addBlock(args[6]) end})
    local result = run(function() return ctx.adapter.build(plan(1), CFrame.new()) end)
    assert(result.ok, result.message); equal(ctx.scaled[1], ctx.built[1]); equal(ctx.painted[1], ctx.built[1])
    near(ctx.manual.PPart.Size.X, 2); near(ctx.manual.PPart.Color.R, 1)
end)

test("an unrelated manual block added during a batch is never changed", function()
    local ctx = context({returnNil = true, beforeBuild = function(value, count, args)
        if count == 2 then value.manual = value:addBlock(args[6] * CFrame.new(5, 2, 0)) end
    end})
    local result = run(function() return ctx.adapter.build(plan(6), CFrame.new()) end)
    assert(result.ok, result.message); equal(result.completed, 6)
    for _, model in ipairs(ctx.scaled) do assert(model ~= ctx.manual) end
    for _, model in ipairs(ctx.painted) do assert(model ~= ctx.manual) end
    near(ctx.manual.PPart.Size.X, 2); near(ctx.manual.PPart.Color.R, 1)
end)

test("stock consumed while waiting for a dispatch slot prevents stale inventory requests", function()
    local ctx = context()
    task.spawn(function() task.wait(0.065); ctx.stock.Value = 0 end)
    local result = run(function() return ctx.adapter.build(plan(8), CFrame.new(), {speed = "Fast"}) end)
    equal(result.ok, false); has(result.message, "Out of available")
    -- The first block completes its proof gate. At most the next request can
    -- have been dispatched before the manual stock update.
    assert((ctx.counters.build or 0) <= 2)
    for _, call in ipairs(ctx.calls) do
        if call.stage == "build" then assert(call.at < 0.065); assert(call.args[2] >= 1) end
    end
end)

test("removed or replaced remote ownership is rejected before dispatch", function()
    local ctx = context({afterPaint = function(value, count)
        if count == 1 then
            task.spawn(function() task.wait(0.008); parent(value.tools.build, nil) end)
        end
    end})
    local result = run(function() return ctx.adapter.build(plan(10), CFrame.new(), {speed = "Fast"}) end)
    equal(result.ok, false); assert(result.completed >= 1); equal(ctx.equipCalls, 0)
    assert(string.find(result.message, "removed or replaced", 1, true) or string.find(result.message, "remote is unavailable", 1, true))
end)

test("Normal Fast and Turbo preserve aggregate rates and larger paint batches", function()
    for _, setting in ipairs({{name = "Normal", rate = 8, batch = 4}, {name = "Fast", rate = 60, batch = 32},
        {name = "Turbo", rate = 120, batch = 64}}) do
        local ctx = context()
        local result = run(function() return ctx.adapter.build(plan(70), CFrame.new(), {speed = setting.name}) end)
        assert(result.ok, result.message); equal(result.completed, 70)
        local largest = 0
        for index, call in ipairs(ctx.calls) do
            if index > 1 then assert(call.at - ctx.calls[index - 1].at >= 1 / setting.rate - 0.000001) end
            if call.stage == "paint" then largest = math.max(largest, #call.args[1]) end
        end
        equal(largest, setting.batch); equal(ctx.equipCalls, 0)
    end
end)

test("HD grids validate through 250000 cells and reject a larger grid", function()
    local ctx = context()
    local p = plan(1)
    p.columns, p.rows, p.pixel_studs = 500, 500, 0.05
    p.width_studs, p.height_studs = 25, 25
    assert(ctx.adapter.validate(p))
    p.rows, p.height_studs = 501, 25.05
    equal(ctx.adapter.validate(p), false)
end)

test("source pixels below 0.05 retain exact geometry and exclude adjacent candidates", function()
    local ctx = context({returnNil = true, beforeBuild = function(value, _, args)
        value.manual = value:addBlock(args[6] * CFrame.new(0.001, 0, 0))
    end})
    local p = plan(1); p.pixel_studs, p.width_studs, p.height_studs = 0.001, 0.001, 0.001
    local result = run(function() return ctx.adapter.build(p, CFrame.new()) end)
    assert(result.ok, result.message); equal(ctx.scaled[1], ctx.built[1])
    near(ctx.built[1].PPart.Size.X, 0.001); near(ctx.built[1].PPart.Size.Y, 0.001)
    near(ctx.built[1].PPart.Size.Z, 0.05); near(ctx.manual.PPart.Size.X, 2)
    p.pixel_studs, p.width_studs, p.height_studs = 0.0009, 0.0009, 0.0009
    local valid, reason = ctx.adapter.validate(p)
    equal(valid, false); has(reason, "below 0.001")
end)

test("a server minimum larger than tiny source pixels fails the first block proof gate", function()
    local ctx = context({minimumScale = 0.02})
    local p = plan(2); p.pixel_studs, p.width_studs, p.height_studs = 0.001, 0.002, 0.001
    local result = run(function() return ctx.adapter.build(p, CFrame.new()) end)
    equal(result.ok, false); equal(ctx.counters.build, 1); equal(ctx.counters.scale, 1)
    equal(ctx.counters.paint, nil); equal(result.completed, 0); has(result.message, "requested block size")
end)

test("Compatible mode equips normal tools when the server requires held tools", function()
    local ctx = context({allowEquip = true, requireHeld = true})
    local result = run(function() return ctx.adapter.build(plan(4), CFrame.new(), {toolMode = "compatible"}) end)
    assert(result.ok, result.message)
    equal(result.completed, 4); equal(ctx.equipCalls, 6)
    for _, call in ipairs(ctx.calls) do equal(call.owner, ctx.character) end
    equal(result.diagnostics.tool_mode, "compatible")
end)

test("Compatible mode stops if the active tool changes mid batch", function()
    local ctx = context({allowEquip = true, afterBuild = function(c, count)
        if count == 2 then c:hold(c.tools.paint) end
    end})
    local result = run(function() return ctx.adapter.build(plan(6), CFrame.new(), {toolMode = "compatible", speed = "Normal"}) end)
    equal(result.ok, false); has(result.message, "active tool changed")
    equal(result.completed, 1)
end)

test("a directly returned new owned block may be snapped before exact scaling", function()
    local ctx = context({afterBuild = function(c)
        local part = c.built[#c.built].PPart
        part.CFrame = part.CFrame * CFrame.new(0.08, 0, 0)
    end})
    local p = plan(2)
    local result = run(function() return ctx.adapter.build(p, CFrame.new()) end)
    assert(result.ok, result.message)
    for i, model in ipairs(ctx.built) do
        local expected = ctx.adapter.geometry(p, p.rectangles[i], CFrame.new())
        near((model.PPart.Position - expected.Position).Magnitude, 0)
    end
end)

test("an unidentified offset block is counted as observed and never modified", function()
    local ctx = context({returnNil = true, afterBuild = function(c)
        local part = c.built[#c.built].PPart
        part.CFrame = part.CFrame * CFrame.new(0.08, 0, 0)
    end})
    local result = run(function() return ctx.adapter.build(plan(1), CFrame.new()) end)
    equal(result.ok, false); equal(result.created, 0)
    equal(result.diagnostics.observed_new_models, 1)
    near(result.diagnostics.nearest_position_error, 0.08)
    equal(#ctx.scaled, 0); equal(#ctx.painted, 0)
    has(result.message, "1 new object(s) appeared")
end)

test("no new objects produces accurate diagnostics without claiming partial blocks", function()
    local ctx = context({noNewBlock = true})
    local result = run(function() return ctx.adapter.build(plan(1), CFrame.new()) end)
    equal(result.ok, false); equal(result.diagnostics.observed_new_models, 0)
    equal(result.diagnostics.requests_sent, 1); equal(ctx.counters.build, 1)
    has(result.message, "Select Tools: Compatible")
    assert(not result.message:find("Partial blocks remain", 1, true))
end)

test("Compatible mode without a live Humanoid sends no tool requests", function()
    local ctx = context({noHumanoid = true})
    local result = run(function() return ctx.adapter.build(plan(1), CFrame.new(), {toolMode = "compatible"}) end)
    equal(result.ok, false); equal(#ctx.calls, 0)
    has(result.message, "Wait for your character")
end)

test("available inventory subtracts Used while owned fully used material stays selectable", function()
    local ctx = context({stock = 12, used = 12})
    equal(ctx.adapter.available("PlasticBlock"), 0)
    equal(ctx.adapter.inventory()[1].count, 0)
    equal(ctx.adapter.inventory()[1].name, "PlasticBlock")
    ctx.used.Value = 7
    equal(ctx.adapter.available("PlasticBlock"), 5)
    equal(ctx.adapter.inventory()[1].count, 5)
end)

test("material need rounds every actual image rectangle separately", function()
    local ctx = context()
    equal(ctx.adapter.materialNeed(plan(3)), 3)
    local p = plan(1)
    p.pixel_studs, p.columns, p.rows = 3, 2, 1
    p.width_studs, p.height_studs = 6, 3
    p.rectangles = {{x = 0, y = 0, w = 2, h = 1, color = {0, 0, 0}}}
    equal(ctx.adapter.materialNeed(p), 3) -- 6 x 3 x 1 / 8 rounds up to 3.
    equal(ctx.adapter.materialNeed(nil), 0)
    equal(ctx.adapter.materialNeed({pixel_studs = 1, rectangles = {"bad"}}), 0)
end)

test("Infinite Blocks already satisfied sends only normal wall calls and needs no DeleteTool", function()
    local ctx = context({noDelete = true})
    local result = run(function() return ctx.adapter.build(plan(2), CFrame.new(), {infiniteBlocks = true}) end)
    assert(result.ok, result.message)
    equal(result.diagnostics.preparation_status, "already_sufficient")
    equal(result.diagnostics.prep_requests, 0); equal(ctx.equipCalls, 0)
    equal(ctx.counters.build, 2); equal(result.diagnostics.inventory_before, 100)
end)

test("bounded preparation verifies replicated gain then builds and restores held tool", function()
    local ctx = context({stock = 1, allowEquip = true, prepGain = 100})
    ctx:hold(ctx.tools.paint)
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    assert(result.ok, result.message); equal(result.completed, 3); equal(result.created, 3)
    equal(result.diagnostics.preparation_status, "verified")
    equal(result.diagnostics.prep_requests, 3)
    equal(result.diagnostics.inventory_before, 1); equal(result.diagnostics.inventory_after, 101)
    equal(result.diagnostics.material_required, 3)
    equal(result.diagnostics.observed_new_models, 3)
    equal(result.diagnostics.temporary_block_remaining, false)
    equal(#ctx.deleted, 1); equal(ctx.deleted[1], ctx.built[1])
    equal(ctx.built[1].Parent, nil); equal(ctx.tools.paint.Parent, ctx.character)
    equal(ctx.tools.build.Parent, ctx.backpack); equal(ctx.tools.scale.Parent, ctx.backpack)
    for i = 1, 3 do equal(ctx.calls[i].owner, ctx.character) end
end)

test("Infinite Blocks is opt in and normal shortage never runs preparation", function()
    local ctx = context({stock = 1, allowEquip = true, prepGain = 100})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new()) end)
    equal(result.ok, false); equal(result.completed, 1)
    equal(result.diagnostics.infinite_requested, false); equal(result.diagnostics.prep_requests, 0)
    equal(ctx.counters.delete, nil); equal(ctx.equipCalls, 0)
end)

test("unchanged replicated inventory fails after cleanup before any wall placement", function()
    local ctx = context({stock = 1, allowEquip = true})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    equal(result.ok, false); equal(result.created, 0); equal(result.completed, 0)
    equal(ctx.counters.build, 1); equal(ctx.counters.scale, 1); equal(ctx.counters.delete, 1)
    equal(ctx.counters.paint, nil); equal(result.diagnostics.inventory_after, 1)
    equal(result.diagnostics.temporary_block_remaining, false)
    has(result.message, "did not provide enough material")
end)

test("missing DeleteTool fails preparation without sending any requests", function()
    local ctx = context({stock = 1, noDelete = true, allowEquip = true})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    equal(result.ok, false); equal(#ctx.calls, 0); equal(ctx.equipCalls, 0)
    has(result.message, "DeleteTool"); equal(result.diagnostics.prep_requests, 0)
end)

test("preparation uses absolute count argument and available shortage from Used", function()
    local ctx = context({stock = 10, used = 9, allowEquip = true, prepGain = 100})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    assert(result.ok, result.message)
    equal(ctx.calls[1].args[2], 10); equal(result.diagnostics.inventory_before, 1)
    equal(result.diagnostics.inventory_after, 101)
    equal(ctx.calls[4].args[2], 110)
end)

test("ambiguous temporary block fallback changes and deletes neither candidate", function()
    local ctx = context({stock = 1, allowEquip = true, returnNil = true, beforeBuild = function(c, _, args)
        c.manual = c:addBlock(args[3].CFrame * args[4])
    end})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    equal(result.ok, false); equal(ctx.counters.scale, nil); equal(ctx.counters.delete, nil)
    equal(ctx.manual.Parent, ctx.folder); equal(ctx.built[1].Parent, ctx.folder)
    has(result.message, "multiple new blocks"); equal(result.diagnostics.temporary_block_remaining, true)
end)

test("preparation ignores preexisting returned model and cleans only unique new helper", function()
    local ctx = context({stock = 1, allowEquip = true, returnOld = true, prepGain = 100})
    ctx.preexisting = ctx:addBlock(CFrame.new(0, -250000, 0))
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    assert(result.ok, result.message)
    equal(ctx.deleted[1], ctx.built[1]); equal(ctx.preexisting.Parent, ctx.folder)
    near(ctx.preexisting.PPart.Size.X, 2)
end)

test("cancelled preparation stops further scales and cleans its identified helper", function()
    local ctx = context({stock = 1, allowEquip = true, afterScale = function(c) c.cancel = true end})
    local result = run(function()
        return ctx.adapter.build(plan(200), CFrame.new(), {infiniteBlocks = true, speed = "Normal",
            shouldCancel = function() return ctx.cancel == true end})
    end)
    equal(result.ok, false); equal(result.created, 0)
    equal(ctx.counters.build, 1); equal(ctx.counters.scale, 1); equal(ctx.counters.delete, 1)
    equal(result.diagnostics.temporary_block_remaining, false); equal(ctx.built[1].Parent, nil)
end)

test("timed out preparation scale retains lock and never sends deletion or retries", function()
    local ctx = context({stock = 1, allowEquip = true, delayStage = "scale", delay = 20})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    equal(result.ok, false); equal(ctx.counters.build, 1); equal(ctx.counters.scale, 1)
    equal(ctx.counters.delete, nil); equal(sharedEnvironment.__ImageBuilderFlight.pending, 1)
    equal(result.diagnostics.temporary_block_remaining, true); has(result.message, "still pending")
    equal(ctx.adapter.validate(plan(3)), false)
    drain()
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0); equal(#ctx.calls, 2)
    equal(ctx.built[1].Parent, ctx.folder)
end)

test("timed out preparation delete is never resent and late completion unlocks", function()
    local ctx = context({stock = 1, allowEquip = true, prepGain = 100, delayStage = "delete", delay = 20})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    equal(result.ok, false); equal(ctx.counters.delete, 1); equal(sharedEnvironment.__ImageBuilderFlight.pending, 1)
    equal(result.diagnostics.temporary_block_remaining, true)
    drain()
    equal(ctx.counters.delete, 1); equal(ctx.built[1].Parent, nil)
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
end)

test("explicit scale error cleans verified helper without changing preexisting blocks", function()
    local ctx = context({stock = 1, allowEquip = true, errorStage = "scale"})
    ctx.preexisting = ctx:addBlock(CFrame.new(0, -250000, 0))
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    equal(result.ok, false); equal(ctx.counters.delete, 1); equal(ctx.deleted[1], ctx.built[1])
    equal(ctx.preexisting.Parent, ctx.folder); has(result.message, "mock rejection")
end)

test("unconfirmed helper deletion is attempted once and stops before wall", function()
    local ctx = context({stock = 1, allowEquip = true, prepGain = 100, noDeleteEffect = true})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    equal(result.ok, false); equal(ctx.counters.delete, 1); equal(ctx.counters.build, 1)
    equal(result.diagnostics.temporary_block_remaining, true); has(result.message, "did not confirm removal")
end)

test("white preparation swaps thin axis and uses rotated plot local placement", function()
    local ctx = context({stock = 1, allowEquip = true, prepGain = 100, teamName = "White"})
    ctx.zone.CFrame = CFrame.new(20, -18, 30) * CFrame.Angles(0, -math.pi / 2, 0)
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(20, 0, 30), {infiniteBlocks = true}) end)
    assert(result.ok, result.message)
    local args = ctx.calls[1].args
    equal(args.n, 8); equal(args[3], ctx.zone); equal(args[5], true)
    equal(args[6], nil); equal(args[7], nil); equal(args[8], false)
    local worldCF = ctx.zone.CFrame * args[4]
    near(worldCF.Position.X, 20); near(worldCF.Position.Y, -250000); near(worldCF.Position.Z, 30)
    near(worldCF.yaw, math.rad(40.135))
    equal(ctx.calls[2].args[2].X, 1.1755e-38)
    near(ctx.calls[2].args[2].Y, 2048); near(ctx.calls[2].args[2].Z, 390.632)
end)

test("late preparation return restores original selection before releasing shared build lock", function()
    local ctx = context({stock = 1, allowEquip = true, delayStage = "scale", delay = 20})
    ctx:hold(ctx.tools.paint)
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true, toolMode = "compatible"}) end)
    equal(result.ok, false); equal(ctx.tools.scale.Parent, ctx.character)
    equal(sharedEnvironment.__ImageBuilderFlight.busy, true)
    local replacement = newAdapter()
    equal(replacement.validate(plan(1)), false)
    local callsBefore = ctx.equipCalls
    drain()
    equal(sharedEnvironment.__ImageBuilderFlight.busy, false)
    equal(ctx.tools.paint.Parent, ctx.character); equal(ctx.equipCalls, callsBefore + 1)
    ctx.stock.Value = 100
    ctx.settings.delayStage = nil
    local nextResult = run(function() return replacement.build(plan(1), CFrame.new()) end)
    assert(nextResult.ok, nextResult.message)
    drain()
    equal(ctx.equipCalls, callsBefore + 1) -- No delayed restore remains to steal a new build's selection.
end)

test("manual selection after preparation timeout is preserved on late completion", function()
    local ctx = context({stock = 1, allowEquip = true, delayStage = "scale", delay = 20})
    ctx:hold(ctx.tools.paint)
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true, toolMode = "compatible"}) end)
    equal(result.ok, false)
    ctx:hold(ctx.tools.build)
    local callsBefore = ctx.equipCalls
    drain()
    equal(ctx.tools.build.Parent, ctx.character); equal(ctx.equipCalls, callsBefore)
    equal(sharedEnvironment.__ImageBuilderFlight.busy, false)
end)

test("preparation leaves an existing multi-tool character unchanged", function()
    local ctx = context({stock = 1, allowEquip = true})
    parent(ctx.tools.build, ctx.character); parent(ctx.tools.paint, ctx.character)
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true, toolMode = "compatible"}) end)
    equal(result.ok, false); has(result.message, "at most one equipped tool")
    equal(#ctx.calls, 0); equal(ctx.equipCalls, 0)
    equal(ctx.tools.build.Parent, ctx.character); equal(ctx.tools.paint.Parent, ctx.character)
end)

test("preparation refuses an excessive scale budget before placing helper", function()
    local ctx = context({stock = 1, allowEquip = true})
    local p = plan(1)
    p.columns, p.rows, p.pixel_studs, p.width_studs, p.height_studs = 1, 5000, 32, 32, 160000
    p.rectangles = {}
    for y = 0, 4999 do table.insert(p.rectangles, {x = 0, y = y, w = 1, h = 1, color = {1, 2, 3}}) end
    local result = run(function() return ctx.adapter.build(p, CFrame.new(), {infiniteBlocks = true}) end)
    equal(result.ok, false); has(result.message, "4096 scale requests")
    equal(#ctx.calls, 0); equal(ctx.equipCalls, 0)
end)

test("holder restores exact script GUI and parent states while reserving only three tools", function()
    local ctx = context({requireHeld = true, beforeBuild = function(c)
        for _, stage in ipairs({"build", "scale", "paint"}) do
            equal(c.tools[stage].Parent, c.character); equal(c.scripts[stage].Disabled, true)
        end
        equal(c.scripts.delete.Disabled, false); equal(c.tools.delete.Parent, c.backpack)
        equal(c.guis.BuildGui.Enabled, false); equal(c.guis.PaintGui.Enabled, false)
        equal(c.guis.ScaleToolDisplayGui.Enabled, false); equal(c.guis.UnrelatedGui.Enabled, true)
        equal(c.guis.DeleteGui.Enabled, true)
        equal(c.toolGui.Enabled, false)
    end})
    ctx.scripts.scale.Disabled = true
    ctx.guis.PaintGui.Enabled = false
    ctx.toolGui = parent(instance("ScreenGui", "OwnedToolGui"), ctx.tools.build)
    ctx.toolGui.Enabled = true
    ctx:hold(ctx.tools.paint)
    local result = run(function() return ctx.adapter.build(plan(2), CFrame.new()) end)
    assert(result.ok, result.message); equal(result.diagnostics.borrowed_tools, 3)
    equal(result.diagnostics.holder_active, false); equal(result.diagnostics.tool_restore_errors, 0)
    equal(ctx.scripts.build.Disabled, false); equal(ctx.scripts.scale.Disabled, true)
    equal(ctx.scripts.paint.Disabled, false); equal(ctx.guis.BuildGui.Enabled, true)
    equal(ctx.guis.PaintGui.Enabled, false); equal(ctx.guis.ScaleToolDisplayGui.Enabled, true)
    equal(ctx.toolGui.Enabled, true); equal(ctx.tools.paint.Parent, ctx.character)
    equal(ctx.tools.build.Parent, ctx.backpack); equal(ctx.tools.scale.Parent, ctx.backpack)
    equal(ctx.backpack.ChildAdded.listenerCount(), 0); equal(ctx.character.ChildAdded.listenerCount(), 0)
    equal(ctx.playerGui.ChildAdded.listenerCount(), 0)
    for _, tool in pairs(ctx.tools) do equal(tool.DescendantAdded.listenerCount(), 0) end
end)

test("holder notices scoped new scripts and GUIs without suppressing unrelated controls", function()
    local ctx = context({beforeBuild = function(c)
        c.newScript = instance("LocalScript", "LateToolClient"); c.newScript.Disabled = false
        parent(c.newScript, c.tools.build)
        equal(c.newScript.Disabled, true)
        c.newGui = instance("ScreenGui", "BuildGui"); c.newGui.Enabled = true
        parent(c.newGui, c.playerGui)
        equal(c.newGui.Enabled, false)
        c.unrelatedScript = instance("LocalScript", "OtherClient"); c.unrelatedScript.Disabled = false
        parent(c.unrelatedScript, c.otherTool)
        equal(c.unrelatedScript.Disabled, false)
    end})
    ctx.otherTool = parent(instance("Tool", "Jetpack"), ctx.character)
    local result = run(function() return ctx.adapter.build(plan(1), CFrame.new()) end)
    assert(result.ok, result.message)
    equal(ctx.newScript.Disabled, false); equal(ctx.newGui.Enabled, true)
    equal(ctx.otherTool.Parent, ctx.character); equal(ctx.unrelatedScript.Disabled, false)
end)

test("new unrelated selection is preserved instead of restoring a borrowed original selection", function()
    local ctx = context({requireHeld = true, afterBuild = function(c) c:hold(c.otherTool) end})
    ctx.otherTool = parent(instance("Tool", "Camera"), ctx.backpack)
    ctx:hold(ctx.tools.paint)
    local result = run(function() return ctx.adapter.build(plan(2), CFrame.new()) end)
    assert(result.ok, result.message); equal(ctx.otherTool.Parent, ctx.character)
    for _, tool in pairs(ctx.tools) do equal(tool.Parent, ctx.backpack) end
    equal(ctx.equipCalls, 0)
end)

test("normal cancellation and errors release reserved states without subsequent phases", function()
    for _, scenario in ipairs({"cancel", "error", "teardown", "team"}) do
        local ctx = context({errorStage = scenario == "error" and "build" or nil,
            afterBuild = function(c)
                if scenario == "cancel" then c.cancel = true end
                if scenario == "teardown" then c.adapter.teardown() end
                if scenario == "team" then c.player.TeamColor = "Blue" end
            end})
        local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {
            shouldCancel = function() return ctx.cancel == true end}) end)
        equal(result.ok, false); equal(#ctx.calls, 1)
        equal(sharedEnvironment.__ImageBuilderFlight.busy, false)
        equal(result.diagnostics.holder_active, false)
        for _, stage in ipairs({"build", "scale", "paint"}) do
            equal(ctx.tools[stage].Parent, ctx.backpack); equal(ctx.scripts[stage].Disabled, false)
        end
        equal(ctx.guis.BuildGui.Enabled, true); equal(ctx.backpack.ChildAdded.listenerCount(), 0)
    end
end)

test("pending background timeout keeps tools reserved until return and then restores once", function()
    local ctx = context({delayStage = "build", delay = 20, requireHeld = true})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new()) end)
    equal(result.ok, false); equal(result.diagnostics.holder_active, true)
    equal(result.diagnostics.tool_restore_pending, true)
    equal(sharedEnvironment.__ImageBuilderFlight.busy, true)
    equal(ctx.scripts.build.Disabled, true); equal(ctx.tools.build.Parent, ctx.character)
    ctx.otherTool = parent(instance("Tool", "Camera"), ctx.backpack)
    ctx:hold(ctx.otherTool)
    local replacement = newAdapter(); equal(replacement.validate(plan(1)), false)
    drain()
    equal(#ctx.calls, 1); equal(ctx.counters.scale, nil)
    equal(ctx.otherTool.Parent, ctx.character); equal(ctx.tools.build.Parent, ctx.backpack)
    equal(ctx.scripts.build.Disabled, false); equal(ctx.guis.BuildGui.Enabled, true)
    equal(result.diagnostics.holder_active, false); equal(result.diagnostics.tool_restore_pending, false)
    equal(sharedEnvironment.__ImageBuilderFlight.busy, false)
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0); assert(replacement.validate(plan(1)))
    equal(ctx.backpack.ChildAdded.listenerCount(), 0)
end)

test("respawn during pending request never borrows the new character tools", function()
    local ctx = context({delayStage = "build", delay = 20})
    task.spawn(function()
        task.wait(0.15)
        ctx.newCharacter = instance("Model", "NewCharacter")
        ctx.player.Character = ctx.newCharacter
        ctx.newTool = parent(instance("Tool", "BuildingTool"), ctx.newCharacter)
        ctx.newClient = parent(instance("LocalScript", "Client"), ctx.newTool)
        ctx.newClient.Disabled = false
    end)
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new()) end)
    equal(result.ok, false); equal(ctx.newClient.Disabled, false)
    drain()
    equal(#ctx.calls, 1); equal(ctx.newTool.Parent, ctx.newCharacter); equal(ctx.newClient.Disabled, false)
    equal(ctx.scripts.build.Disabled, false); equal(ctx.tools.build.Parent, ctx.backpack)
    equal(sharedEnvironment.__ImageBuilderFlight.busy, false)
end)

test("holder never borrows another player's same-name tools or touches their GUI", function()
    local ctx = context({beforeBuild = function(c)
        equal(c.foreignClient.Disabled, false); equal(c.foreignTool.Parent, c.otherCharacter)
        equal(c.foreignGui.Enabled, true)
    end})
    ctx.otherCharacter = parent(instance("Model", "AnotherPlayer"), ctx.world)
    ctx.foreignTool = parent(instance("Tool", "BuildingTool"), ctx.otherCharacter)
    ctx.foreignClient = parent(instance("LocalScript", "Client"), ctx.foreignTool); ctx.foreignClient.Disabled = false
    ctx.foreignGui = parent(instance("ScreenGui", "BuildGui"), ctx.otherCharacter); ctx.foreignGui.Enabled = true
    local result = run(function() return ctx.adapter.build(plan(1), CFrame.new()) end)
    assert(result.ok, result.message)
    equal(ctx.foreignClient.Disabled, false); equal(ctx.foreignGui.Enabled, true)
    equal(ctx.foreignTool.Parent, ctx.otherCharacter)
end)

test("identified block moved out of own folder is never sent to a paint remote", function()
    local ctx = context({afterScale = function(c) parent(c.built[1], c.otherFolder) end})
    ctx.otherFolder = parent(instance("Folder", "OtherPlayer"), ctx.folder.Parent)
    local result = run(function() return ctx.adapter.build(plan(1), CFrame.new()) end)
    equal(result.ok, false); equal(ctx.counters.paint, nil); equal(#ctx.painted, 0)
    has(result.message, "did not accept"); equal(ctx.built[1].Parent, ctx.otherFolder)
end)

test("background preparation shares four reserved tools while unrelated tool stays usable", function()
    local ctx = context({stock = 1, prepGain = 100, requireHeld = true,
        beforeBuild = function(c)
            for _, stage in ipairs({"build", "scale", "paint", "delete"}) do
                equal(c.tools[stage].Parent, c.character); equal(c.scripts[stage].Disabled, true)
            end
        end,
        afterScale = function(c) c:hold(c.otherTool) end})
    ctx.otherTool = parent(instance("Tool", "Camera"), ctx.character)
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    assert(result.ok, result.message); equal(result.diagnostics.preparation_status, "verified")
    equal(result.diagnostics.borrowed_tools, 4); equal(result.diagnostics.prep_requests, 3)
    equal(ctx.equipCalls, 0); equal(ctx.otherTool.Parent, ctx.character)
    for stage, tool in pairs(ctx.tools) do equal(tool.Parent, ctx.backpack); equal(ctx.scripts[stage].Disabled, false) end
end)

test("cancelled background preparation cleans helper before restoring all borrowed tools", function()
    local ctx = context({stock = 1, requireHeld = true, afterScale = function(c) c.cancel = true end})
    local result = run(function() return ctx.adapter.build(plan(4), CFrame.new(), {infiniteBlocks = true,
        speed = "Normal", shouldCancel = function() return ctx.cancel == true end}) end)
    equal(result.ok, false); equal(result.created, 0); equal(ctx.counters.delete, 1)
    equal(ctx.deleted[1], ctx.built[1]); equal(ctx.built[1].Parent, nil)
    equal(result.diagnostics.holder_active, false); equal(ctx.equipCalls, 0)
    for stage, tool in pairs(ctx.tools) do equal(tool.Parent, ctx.backpack); equal(ctx.scripts[stage].Disabled, false) end
end)

test("timed out background preparation retains reservation and never deletes uncertain helper", function()
    local ctx = context({stock = 1, delayStage = "scale", delay = 20, requireHeld = true})
    ctx:hold(ctx.tools.paint)
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true}) end)
    equal(result.ok, false); equal(result.diagnostics.tool_restore_pending, true)
    equal(ctx.counters.delete, nil); equal(ctx.scripts.delete.Disabled, true)
    equal(ctx.tools.delete.Parent, ctx.character)
    drain()
    equal(ctx.counters.delete, nil); equal(#ctx.calls, 2); equal(ctx.built[1].Parent, ctx.folder)
    equal(ctx.tools.paint.Parent, ctx.character); equal(ctx.tools.delete.Parent, ctx.backpack)
    equal(ctx.scripts.delete.Disabled, false); equal(ctx.guis.PaintGui.Enabled, true)
    equal(sharedEnvironment.__ImageBuilderFlight.busy, false); equal(ctx.equipCalls, 0)
end)

test("stock drop during holder setup borrows DeleteTool before any helper creation", function()
    local ctx = context({stock = 100, prepGain = 100, requireHeld = true, beforeBuild = function(c)
        equal(c.tools.delete.Parent, c.character); equal(c.scripts.delete.Disabled, true)
    end})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true,
        onProgress = function(_, _, message)
            if string.find(message, "reserving build tools", 1, true) then ctx.stock.Value = 1 end
        end}) end)
    assert(result.ok, result.message); equal(result.diagnostics.borrowed_tools, 4)
    equal(result.diagnostics.preparation_status, "verified")
    equal(ctx.counters.delete, 1); equal(ctx.tools.delete.Parent, ctx.backpack)
    equal(ctx.scripts.delete.Disabled, false)
end)

test("stock drop with no DeleteTool fails before preparation changes any block", function()
    local ctx = context({stock = 100, noDelete = true})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true,
        onProgress = function(_, _, message)
            if string.find(message, "reserving build tools", 1, true) then ctx.stock.Value = 1 end
        end}) end)
    equal(result.ok, false); equal(#ctx.calls, 0); has(result.message, "DeleteTool")
    equal(ctx.tools.build.Parent, ctx.backpack); equal(ctx.scripts.build.Disabled, false)
end)

test("compact rectangle-only plans validate and build without redundant cells", function()
    local ctx = context({requireHeld = true})
    local p = plan(3); p.cells = nil
    assert(ctx.adapter.validate(p)); equal(ctx.adapter.materialNeed(p), 3)
    local result = run(function() return ctx.adapter.build(p, CFrame.new()) end)
    assert(result.ok, result.message); equal(result.completed, 3)
    local bad = plan(1); bad.cells = nil; bad.rectangles = "invalid"
    equal(ctx.adapter.validate(bad), false)
    bad.rectangles = {{x = 0, y = 0, w = 99, h = 1, color = {1, 2, 3}}}
    equal(ctx.adapter.validate(bad), false)
    bad.rectangles = nil
    equal(ctx.adapter.validate(bad), false)
    equal(#ctx.scaled, 3, "invalid plans unexpectedly sent modification requests")
end)

local function materialPlan(rectangleCount)
    local p = plan(1)
    p.columns, p.rows, p.pixel_studs = 1, rectangleCount, 32
    p.width_studs, p.height_studs, p.cells, p.rectangles = 32, rectangleCount * 32, nil, {}
    for y = 0, rectangleCount - 1 do
        table.insert(p.rectangles, {x = 0, y = y, w = 1, h = 1, color = {30, 60, 90}})
    end
    return p
end

test("adaptive preparation uses fractional replicated Used gain instead of the reference estimate", function()
    local ctx = context({stock = 1, prepGain = 7.25, prepUsesUsed = true})
    local result = run(function() return ctx.adapter.build(plan(120), CFrame.new(), {infiniteBlocks = true}) end)
    assert(result.ok, result.message)
    local d = result.diagnostics
    equal(d.prep_version, 2); equal(d.prep_rounds, 2); equal(d.prep_scale_requests, 17)
    equal(d.prep_samples[1].requests, 2); near(d.prep_samples[1].gain, 14.5)
    equal(d.prep_samples[2].requests, 15); near(d.inventory_before, 1); near(d.inventory_after, 124.25)
    near(d.prep_gain, 123.25); equal(d.prep_stop_reason, "satisfied")
    equal(#ctx.deleted, 2); equal(ctx.deleted[1].Parent, nil); equal(ctx.deleted[2].Parent, nil)
end)

test("adaptive rounds remeasure a changing gain rather than assuming the first yield persists", function()
    local ctx = context({stock = 1, prepGain = function(_, count) return count <= 2 and 20 or 5 end})
    local result = run(function() return ctx.adapter.build(plan(120), CFrame.new(), {infiniteBlocks = true}) end)
    assert(result.ok, result.message)
    local samples = result.diagnostics.prep_samples
    equal(#samples, 3); equal(samples[1].requests, 2); equal(samples[2].requests, 4); equal(samples[3].requests, 12)
    near(samples[1].after, 41); near(samples[2].after, 61); near(samples[3].after, 121)
end)

test("preparation waits for delayed post-delete gain before measuring another round", function()
    local ctx = context({stock = 1, prepGain = 7.25, prepGainOnDelete = true, prepGainDelay = 2, prepUsesUsed = true})
    local result = run(function() return ctx.adapter.build(plan(120), CFrame.new(), {infiniteBlocks = true}) end)
    assert(result.ok, result.message); equal(result.diagnostics.prep_rounds, 2)
    near(result.diagnostics.prep_samples[1].gain, 14.5); near(result.diagnostics.prep_samples[2].gain, 108.75)
    local previousDelete
    for _, call in ipairs(ctx.calls) do
        if call.stage == "delete" then previousDelete = call.at end
        if call.stage == "build" and previousDelete then assert(call.at - previousDelete >= 2) end
    end
end)

test("a zero gain round after partial progress stops with truthful shortfall and bounded diagnostics", function()
    local ctx = context({stock = 1, prepGain = function(_, count) return count == 1 and 10 or 0 end})
    local result = run(function() return ctx.adapter.build(plan(100), CFrame.new(), {infiniteBlocks = true}) end)
    equal(result.ok, false); equal(result.created, 0); equal(result.diagnostics.prep_rounds, 2)
    equal(result.diagnostics.prep_stop_reason, "no_gain"); equal(result.diagnostics.prep_scale_requests, 10)
    near(result.diagnostics.inventory_before, 1); near(result.diagnostics.inventory_after, 11)
    near(result.diagnostics.prep_gain, 10); equal(result.diagnostics.prep_samples[2].gain, 0)
    has(result.message, "started with 1.000, now 11.000"); has(result.message, "89.000 more needed")
    equal(ctx.counters.delete, 2); equal(ctx.counters.paint, nil)
end)

test("calibration is capped at sixteen and later rounds are capped at 256 requests", function()
    local ctx = context({stock = 1, prepGain = 1})
    local result = run(function() return ctx.adapter.build(materialPlan(20), CFrame.new(), {infiniteBlocks = true, speed = "Turbo"}) end)
    assert(result.ok, result.message)
    equal(result.diagnostics.prep_samples[1].requests, 16)
    equal(result.diagnostics.prep_samples[2].requests, 256)
    for _, sample in ipairs(result.diagnostics.prep_samples) do assert(sample.requests <= 256) end
    equal(result.diagnostics.prep_scale_requests, 2559)
end)

test("adaptive preparation enforces a total4096 scale budget despite small positive gains", function()
    local ctx = context({stock = 1, prepGain = 0.1, prepUsesUsed = true})
    local result = run(function() return ctx.adapter.build(materialPlan(10), CFrame.new(), {infiniteBlocks = true, speed = "Turbo"}) end)
    equal(result.ok, false); equal(result.created, 0)
    equal(result.diagnostics.prep_scale_requests, 4096); equal(ctx.counters.scale, 4096)
    equal(result.diagnostics.prep_stop_reason, "request_limit"); assert(result.diagnostics.prep_rounds <= 32)
    equal(#result.diagnostics.prep_samples, result.diagnostics.prep_rounds)
    equal(ctx.counters.delete, result.diagnostics.prep_rounds); equal(result.diagnostics.temporary_block_remaining, false)
    near(result.diagnostics.inventory_after, 410.6); equal(ctx.counters.paint, nil)
end)

test("slow changing yields stop at32 completed rounds without unbounded history", function()
    local ctx = context({stock = 1, prepGain = function(c)
        return math.max(0, 3 - (c.adapter.available("PlasticBlock") + 1)) / 2
    end, prepGainOnDelete = true, prepUsesUsed = true})
    local result = run(function() return ctx.adapter.build(plan(3), CFrame.new(), {infiniteBlocks = true, speed = "Turbo"}) end)
    equal(result.ok, false); equal(result.diagnostics.prep_stop_reason, "round_limit")
    equal(result.diagnostics.prep_rounds, 32); equal(#result.diagnostics.prep_samples, 32)
    assert(result.diagnostics.prep_scale_requests < 4096); equal(ctx.counters.delete, 32)
    equal(ctx.counters.paint, nil); equal(result.diagnostics.temporary_block_remaining, false)
end)

test("cancelling after completed round deletion never creates a second helper", function()
    local ctx = context({stock = 1, prepGain = 10, afterDelete = function(c) c.cancel = true end})
    local result = run(function() return ctx.adapter.build(plan(100), CFrame.new(), {infiniteBlocks = true,
        shouldCancel = function() return ctx.cancel == true end}) end)
    equal(result.ok, false); equal(ctx.counters.build, 1); equal(ctx.counters.delete, 1)
    equal(result.diagnostics.prep_rounds, 1); equal(result.diagnostics.prep_stop_reason, "cancelled_or_context_changed")
    near(result.diagnostics.prep_samples[1].gain, 10); near(result.diagnostics.inventory_after, 11)
    equal(result.diagnostics.temporary_block_remaining, false); equal(ctx.tools.build.Parent, ctx.backpack)
end)

test("preparation scale calls never overlap even inTurbo and retain aggregate rate", function()
    local ctx = context({stock = 1, prepGain = 10, delayStage = "scale", delay = 0.2})
    local result = run(function() return ctx.adapter.build(materialPlan(1), CFrame.new(), {infiniteBlocks = true, speed = "Turbo"}) end)
    assert(result.ok, result.message); equal(ctx.maxPrepScales, 1)
    local previous
    for _, call in ipairs(ctx.calls) do
        if previous then assert(call.at - previous >= 1 / 120 - 0.000001) end
        previous = call.at
    end
end)

test("later rounds exclude prior helper instances and between-round manual blocks", function()
    local ctx = context({stock = 1, prepGain = 10, returnOld = true, beforeBuild = function(c, count)
        if count == 2 then parent(c.built[1], c.folder); c.preexisting = c.built[1] end
    end, afterDelete = function(c, count)
        if count == 1 then c.manualBetween = c:addBlock(CFrame.new(0, -250000, 0)) end
    end})
    local result = run(function() return ctx.adapter.build(plan(100), CFrame.new(), {infiniteBlocks = true}) end)
    assert(result.ok, result.message); equal(result.diagnostics.prep_rounds, 2)
    equal(ctx.deleted[1], ctx.built[1]); equal(ctx.deleted[2], ctx.built[2])
    equal(ctx.manualBetween.Parent, ctx.folder); near(ctx.manualBetween.PPart.Size.X, 2)
    equal(ctx.built[1].Parent, ctx.folder)
    for i = 2, #ctx.scaled do assert(ctx.scaled[i] ~= ctx.built[1]) end
end)

test("a later uncertain scale stops without another helper or deletion retry", function()
    local ctx = context({stock = 1, prepGain = 10, afterDelete = function(c, count)
        if count == 1 then c.settings.delayStage, c.settings.delay = "scale", 20 end
    end})
    local result = run(function() return ctx.adapter.build(plan(100), CFrame.new(), {infiniteBlocks = true}) end)
    equal(result.ok, false); equal(ctx.counters.build, 2); equal(ctx.counters.delete, 1)
    equal(result.diagnostics.prep_rounds, 2); equal(result.diagnostics.prep_stop_reason, "request_pending")
    equal(result.diagnostics.temporary_block_remaining, true)
    local requests = #ctx.calls
    drain(); equal(#ctx.calls, requests); equal(ctx.counters.delete, 1)
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0); equal(ctx.tools.scale.Parent, ctx.backpack)
end)

test("Rapid latency benchmark improves throughput within its request and pending bounds", function()
    local elapsed = {}
    for _, setting in ipairs({{name = "Turbo", rate = 120, workers = 8, batch = 64},
        {name = "Rapid", rate = 600, workers = 64, batch = 256}}) do
        local ctx = context({stock = 1000, remoteDelay = 0.1})
        local result = run(function() return ctx.adapter.build(plan(384), CFrame.new(), {speed = setting.name}) end)
        assert(result.ok, result.message); equal(result.completed, 384)
        equal(result.created, 384); equal(ctx.counters.build, 384); equal(ctx.counters.scale, 384)
        equal(ctx.calls[1].stage, "build"); equal(ctx.calls[2].stage, "scale"); equal(ctx.calls[3].stage, "paint")
        assert(ctx.maxRemoteCalls <= setting.workers); assert(ctx.maxRemoteCalls > 1)
        equal(ctx.maxRemoteCalls, result.diagnostics.peak_pending)
        equal(result.diagnostics.speed_mode, setting.name)
        if setting.name == "Rapid" then assert(result.diagnostics.effective_request_rate <= setting.rate) else equal(result.diagnostics.effective_request_rate, setting.rate) end
        equal(result.diagnostics.peak_geometry_jobs, math.min(setting.batch, 383))
        equal(sharedEnvironment.__ImageBuilderFlight.pending, 0); equal(ctx.activeRemoteCalls, 0)
        for index, call in ipairs(ctx.calls) do
            if index > 1 then assert(call.at - ctx.calls[index - 1].at >= 1 / setting.rate - 0.000001) end
            if call.stage == "paint" then assert(#call.args[1] <= (setting.name == "Rapid" and 32 or setting.batch)) end
        end
        near(result.diagnostics.wall_elapsed_seconds, clock)
        near(result.diagnostics.verified_blocks_per_second, 384 / clock)
        elapsed[setting.name] = clock
        print(string.format("MOCK_LATENCY_BENCHMARK %s 384 verified blocks %.3fs %.2f blocks/s peak %d pending",
            setting.name, clock, 384 / clock, ctx.maxRemoteCalls))
    end
    assert(elapsed.Rapid < elapsed.Turbo, "Adaptive Rapid should improve throughput in this healthy100ms mock")
end)

test("Compatible clamps Rapid to Fast scheduling", function()
    local ctx = context({allowEquip = true, requireHeld = true, stock = 100, remoteDelay = 0.1})
    local result = run(function() return ctx.adapter.build(plan(35), CFrame.new(),
        {speed = "Rapid", toolMode = "compatible"}) end)
    assert(result.ok, result.message)
    equal(result.diagnostics.selected_speed_mode, "Rapid"); equal(result.diagnostics.speed_mode, "Fast")
    equal(result.diagnostics.effective_request_rate, 60); equal(result.diagnostics.worker_limit, 4)
    assert(ctx.maxRemoteCalls <= 4)
    for index = 2, #ctx.calls do assert(ctx.calls[index].at - ctx.calls[index - 1].at >= 1 / 60 - 0.000001) end
end)

test("Rapid preparation remains serial and capped at120 requests per second", function()
    local ctx = context({stock = 1, prepGain = 10, delayStage = "scale", delay = 0.002})
    local result = run(function() return ctx.adapter.build(plan(100), CFrame.new(),
        {speed = "Rapid", infiniteBlocks = true}) end)
    assert(result.ok, result.message); equal(ctx.maxPrepScales, 1)
    equal(result.diagnostics.preparation_request_rate, 120)
    assert(result.diagnostics.prep_rounds > 0)
    assert(result.diagnostics.wall_elapsed_seconds < clock)
    local previous
    for index = 1, result.diagnostics.prep_requests do
        local call = ctx.calls[index]
        if previous then assert(call.at - previous.at >= 1 / 120 - 0.000001) end
        previous = call
    end
end)

test("a60000 part plan constructs only first proof geometry before cancellation", function()
    local ctx = context({stock = 100000, afterPaint = function(c) c.cancel = true end})
    local p = plan(60000)
    p.columns, p.rows, p.width_studs, p.height_studs = 300, 200, 150, 100
    for index, rect in ipairs(p.rectangles) do rect.x = (index - 1) % 300; rect.y = math.floor((index - 1) / 300) end
    local geometryCalls = 0
    local geometry = ctx.adapter.geometry
    ctx.adapter.geometry = function(...)
        geometryCalls += 1
        return geometry(...)
    end
    local result = run(function() return ctx.adapter.build(p, CFrame.new(), {speed = "Rapid",
        shouldCancel = function() return ctx.cancel == true end}) end)
    equal(result.ok, false); equal(result.completed, 1); equal(result.total, 60000)
    equal(geometryCalls, 1); equal(result.diagnostics.peak_geometry_jobs, 1)
    equal(ctx.counters.build, 1); equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
end)

test("Rapid cancellation drains already dispatched work without later modifications", function()
    local ctx = context({stock = 1000, remoteDelay = 0.1, afterBuild = function(c, count)
        if count == 2 then c.cancel = true; c.cancelAt = clock end
    end})
    local result = run(function() return ctx.adapter.build(plan(200), CFrame.new(), {speed = "Rapid",
        shouldCancel = function() return ctx.cancel == true end}) end)
    equal(result.ok, false); equal(result.completed, 1)
    equal(ctx.counters.scale, 1); equal(ctx.counters.paint, 1)
    assert(ctx.counters.build <= 385); assert(ctx.maxRemoteCalls <= 384)
    equal(ctx.activeRemoteCalls, 0); equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
    equal(ctx.tools.build.Parent, ctx.backpack)
    local calls = #ctx.calls
    drain(); equal(#ctx.calls, calls)
end)

test("Rapid will not resize or paint a returned block moved out of its owner's folder", function()
    local ctx = context({stock = 100, remoteDelay = 0.02, afterBuild = function(c, count)
        if count == 2 then
            c.moved = c.built[count]
            parent(c.moved, c.world)
        end
    end})
    local result = run(function() return ctx.adapter.build(plan(20), CFrame.new(), {speed = "Rapid"}) end)
    equal(result.ok, false); equal(result.completed, 1)
    equal(ctx.counters.scale, 1); equal(ctx.counters.paint, 1)
    near(ctx.moved.PPart.Size.X, 2); equal(ctx.moved.Parent, ctx.world)
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
end)

test("Rapid uncertain concurrent scales retain reservations until every late call returns", function()
    local ctx = context({stock = 100, afterBuild = function(c, count)
        if count == 2 then c.settings.delayStage = "scale"; c.settings.delay = 20 end
    end})
    local result = run(function() return ctx.adapter.build(plan(70), CFrame.new(), {speed = "Rapid"}) end)
    equal(result.ok, false); equal(result.completed, 1)
    equal(ctx.counters.scale, 17); equal(result.diagnostics.peak_pending, 16)
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 16)
    equal(sharedEnvironment.__ImageBuilderFlight.busy, true)
    equal(ctx.tools.scale.Parent, ctx.character); equal(ctx.scripts.scale.Disabled, true)
    local calls = #ctx.calls
    drain(); equal(#ctx.calls, calls); equal(ctx.counters.paint, 1)
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0); equal(sharedEnvironment.__ImageBuilderFlight.busy, false)
    equal(ctx.tools.scale.Parent, ctx.backpack); equal(ctx.scripts.scale.Disabled, false)
end)

local function nativeControllers(ctx)
    ctx.nativeActive, ctx.nativeEquips, ctx.nativeUnequips = {}, {}, {}
    for stage, tool in pairs(ctx.tools) do
        local client = ctx.scripts[stage]
        tool.Equipped:Connect(function()
            if client.Disabled or clock + 0.000001 < (client._controllerReadyAt or 0) then return end
            ctx.nativeActive[stage] = true
            ctx.nativeEquips[stage] = (ctx.nativeEquips[stage] or 0) + 1
            if ctx.onNativeEquip then ctx.onNativeEquip(stage) end
        end)
        tool.Unequipped:Connect(function()
            if client.Disabled then return end
            ctx.nativeActive[stage] = false
            ctx.nativeUnequips[stage] = (ctx.nativeUnequips[stage] or 0) + 1
        end)
    end
    ctx.selection = {revision = 0, available = true}
    return function() return ctx.selection end
end

test("explicit manual building selection gets fresh native equip while automated remotes continue", function()
    local ctx = context({stock = 100})
    local getter = nativeControllers(ctx)
    ctx.selection = {revision = 1, tool = ctx.tools.build, available = true}
    ctx.settings.beforeBuild = function(c)
        equal(c.nativeActive.build, true); equal(c.scripts.build.Disabled, false)
        equal(c.scripts.scale.Disabled, true); equal(c.scripts.paint.Disabled, true)
        equal(c.guis.BuildGui.Enabled, true); equal(c.guis.PaintGui.Enabled, false)
    end
    local result = run(function() return ctx.adapter.build(plan(8), CFrame.new(), {getManualToolSelection = getter}) end)
    assert(result.ok, result.message); equal(result.completed, 8); equal(ctx.nativeEquips.build, 1)
    equal(ctx.tools.build.Parent, ctx.character); equal(ctx.nativeActive.build, true)
    equal(ctx.tools.scale.Parent, ctx.backpack); equal(ctx.tools.paint.Parent, ctx.backpack)
    equal(result.diagnostics.manual_tool_name, "BuildingTool")
    equal(result.diagnostics.manual_selection_revision, 1); equal(result.diagnostics.manual_selection_supported, true)
end)

test("switching native controller cleans the old one before enabling the new one", function()
    local ctx = context({stock = 100})
    local getter = nativeControllers(ctx)
    ctx.selection = {revision = 1, tool = ctx.tools.build, available = true}
    ctx.settings.afterBuild = function(c, count)
        if count == 1 then c.selection = {revision = 2, tool = c.tools.paint, available = true} end
    end
    ctx.onNativeEquip = function(stage)
        if stage == "paint" then equal(ctx.nativeActive.build, false); equal(ctx.scripts.build.Disabled, true) end
    end
    local result = run(function() return ctx.adapter.build(plan(8), CFrame.new(), {getManualToolSelection = getter}) end)
    assert(result.ok, result.message); equal(ctx.nativeEquips.build, 1); equal(ctx.nativeEquips.paint, 1)
    equal(ctx.nativeUnequips.build, 1); equal(ctx.nativeActive.paint, true)
    equal(ctx.tools.paint.Parent, ctx.character); equal(ctx.tools.build.Parent, ctx.backpack)
    equal(result.diagnostics.manual_tool_name, "PaintingTool")
end)

test("a new revision for the same native tool forces another initialized equip", function()
    local ctx = context({stock = 100})
    local getter = nativeControllers(ctx)
    ctx.selection = {revision = 1, tool = ctx.tools.build, available = true}
    ctx.settings.afterBuild = function(c, count)
        if count == 1 then c.selection = {revision = 2, tool = c.tools.build, available = true} end
    end
    local result = run(function() return ctx.adapter.build(plan(4), CFrame.new(), {getManualToolSelection = getter}) end)
    assert(result.ok, result.message); equal(ctx.nativeEquips.build, 2); equal(ctx.nativeUnequips.build, 1)
    equal(ctx.nativeActive.build, true); equal(result.diagnostics.manual_selection_revision, 2)
end)

test("reclaiming the same manually enabled tool preserves its script and native control", function()
    local ctx = context({stock = 100})
    local getter = nativeControllers(ctx)
    ctx.selection = {revision = 1, tool = ctx.tools.build, available = true}
    ctx.settings.afterBuild = function(c, count)
        if count == 1 then parent(c.tools.build, c.backpack) end
    end
    local result = run(function() return ctx.adapter.build(plan(8), CFrame.new(), {getManualToolSelection = getter}) end)
    assert(result.ok, result.message); equal(ctx.nativeEquips.build, 2); equal(ctx.nativeUnequips.build, 1)
    equal(ctx.nativeActive.build, true); equal(ctx.scripts.build.Disabled, false)
end)

test("cancellation preserves the currently selected native tool and restores other states", function()
    local ctx = context({stock = 100, afterPaint = function(c) c.cancel = true end})
    local getter = nativeControllers(ctx)
    ctx.selection = {revision = 1, tool = ctx.tools.scale, available = true}
    local result = run(function() return ctx.adapter.build(plan(8), CFrame.new(), {getManualToolSelection = getter,
        shouldCancel = function() return ctx.cancel == true end}) end)
    equal(result.ok, false); equal(result.completed, 1); equal(ctx.nativeEquips.scale, 1)
    equal(ctx.tools.scale.Parent, ctx.character); equal(ctx.nativeActive.scale, true)
    equal(ctx.tools.build.Parent, ctx.backpack); equal(ctx.scripts.build.Disabled, false)
    equal(ctx.guis.BuildGui.Enabled, true); equal(ctx.guis.ScaleToolDisplayGui.Enabled, true)
end)

test("new manual controller selection waits until the pending automated phase has drained", function()
    local ctx = context({stock = 100, remoteDelay = 0.1})
    local getter = nativeControllers(ctx)
    ctx.selection = {revision = 1, tool = ctx.tools.build, available = true}
    ctx.settings.afterBuild = function(c, count)
        if count == 2 then c.selection = {revision = 2, tool = c.tools.paint, available = true} end
        if count > 1 and not c.nativeActive.paint then equal(c.scripts.paint.Disabled, true); assert(sharedEnvironment.__ImageBuilderFlight.pending > 0) end
    end
    ctx.onNativeEquip = function(stage)
        equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
        if stage == "paint" then assert(ctx.counters.build > 1 and ctx.counters.build < 20) end
    end
    local result = run(function() return ctx.adapter.build(plan(20), CFrame.new(),
        {getManualToolSelection = getter, speed = "Rapid"}) end)
    assert(result.ok, result.message); equal(ctx.nativeEquips.paint, 1)
end)

test("an unrelated native selection suppresses the old manual controller before deferred reclaim", function()
    local ctx = context({stock = 100, remoteDelay = 0.1})
    local getter = nativeControllers(ctx)
    ctx.selection = {revision = 1, tool = ctx.tools.build, available = true}
    local unrelated = parent(instance("Tool", "UnrelatedTool"), ctx.backpack)
    local unrelatedScript = parent(instance("LocalScript", "OtherClient"), unrelated); unrelatedScript.Disabled = false
    ctx.settings.afterBuild = function(c, count)
        if count ~= 2 then return end
        c:hold(unrelated)
        c.selection = {revision = 2, tool = unrelated, available = true}
        task.defer(function()
            equal(c.nativeActive.build, false); equal(c.scripts.build.Disabled, true)
            equal(unrelated.Parent, c.character); equal(unrelatedScript.Disabled, false)
            assert(sharedEnvironment.__ImageBuilderFlight.pending > 0)
            c.checkedDeferred = true
        end)
    end
    local result = run(function() return ctx.adapter.build(plan(20), CFrame.new(),
        {getManualToolSelection = getter, speed = "Rapid"}) end)
    assert(result.ok, result.message); equal(ctx.checkedDeferred, true)
    equal(ctx.nativeActive.build, false); equal(ctx.nativeEquips.build, 1)
    equal(unrelated.Parent, ctx.character); equal(unrelatedScript.Disabled, false)
    equal(ctx.tools.build.Parent, ctx.backpack); equal(result.diagnostics.manual_tool_name, "none")
end)

test("manual selection preserves originally disabled scripts and GUI states", function()
    local ctx = context({stock = 100})
    local getter = nativeControllers(ctx)
    ctx.scripts.paint.Disabled = true; ctx.guis.PaintGui.Enabled = false
    ctx.selection = {revision = 1, tool = ctx.tools.paint, available = true}
    local result = run(function() return ctx.adapter.build(plan(4), CFrame.new(), {getManualToolSelection = getter}) end)
    assert(result.ok, result.message); equal(ctx.nativeEquips.paint, nil)
    equal(ctx.scripts.paint.Disabled, true); equal(ctx.guis.PaintGui.Enabled, false)
    equal(ctx.tools.paint.Parent, ctx.character)
end)

test("manual controller can invoke the original paint remote on a separate block during automation", function()
    local ctx = context({stock = 100, remoteDelay = 0.1})
    local getter = nativeControllers(ctx)
    local manualBlock = ctx:addBlock(CFrame.new(50, 0, 50))
    ctx.selection = {revision = 1, tool = ctx.tools.paint, available = true}
    ctx.settings.afterBuild = function(c, count)
        if count ~= 2 then return end
        task.spawn(function()
            equal(c.nativeActive.paint, true); assert(sharedEnvironment.__ImageBuilderFlight.pending > 0)
            assert(c.remotes.paint:InvokeServer({{manualBlock, Color3.fromRGB(1, 2, 3)}}))
            c.manualPaintFinished = true
        end)
    end
    local result = run(function() return ctx.adapter.build(plan(20), CFrame.new(),
        {getManualToolSelection = getter, speed = "Rapid"}) end)
    assert(result.ok, result.message); equal(result.completed, 20); equal(ctx.manualPaintFinished, true)
    equal(result.created, 20); near(manualBlock.PPart.Color.R, 1 / 255)
    for _, model in ipairs(ctx.scaled) do assert(model ~= manualBlock) end
end)

test("uncertain automation retains tools and later cleanup preserves the selected manual controller", function()
    local ctx = context({stock = 100, afterBuild = function(c, count)
        if count == 2 then c.settings.delayStage, c.settings.delay = "scale", 20 end
    end})
    local getter = nativeControllers(ctx)
    ctx.selection = {revision = 1, tool = ctx.tools.build, available = true}
    local result = run(function() return ctx.adapter.build(plan(20), CFrame.new(),
        {getManualToolSelection = getter, speed = "Rapid"}) end)
    equal(result.ok, false); assert(sharedEnvironment.__ImageBuilderFlight.pending > 0)
    equal(ctx.scripts.scale.Disabled, true); equal(ctx.nativeActive.build, true)
    local calls = #ctx.calls
    drain(); equal(#ctx.calls, calls); equal(ctx.nativeEquips.build, 1)
    equal(ctx.tools.build.Parent, ctx.character); equal(ctx.nativeActive.build, true)
    equal(ctx.tools.scale.Parent, ctx.backpack); equal(ctx.scripts.scale.Disabled, false)
end)

test("a newer native selection during controller initialization never equips the stale choice", function()
    local ctx = context({stock = 100})
    local getter = nativeControllers(ctx)
    ctx.selection = {revision = 1, tool = ctx.tools.build, available = true}
    task.spawn(function()
        task.wait(0.01)
        ctx.selection = {revision = 2, tool = ctx.tools.paint, available = true}
    end)
    local result = run(function() return ctx.adapter.build(plan(8), CFrame.new(), {getManualToolSelection = getter}) end)
    assert(result.ok, result.message); equal(ctx.nativeEquips.build, nil); equal(ctx.nativeEquips.paint, 1)
    equal(ctx.nativeActive.paint, true); equal(result.diagnostics.manual_selection_revision, 2)
    equal(result.diagnostics.manual_tool_name, "PaintingTool")
end)

test("native selection during preparation applies before the next serial scale request", function()
    local ctx = context({stock = 1, prepGain = 100, remoteDelay = 0.1})
    local getter = nativeControllers(ctx)
    ctx.settings.afterScale = function(c, count)
        if count == 2 then c.selection = {revision = 1, tool = c.tools.paint, available = true} end
        if count == 3 then
            equal(c.nativeActive.paint, true); equal(c.nativeEquips.paint, 1)
            equal(c.scripts.paint.Disabled, false); equal(c.counters.delete, nil)
            c.checkedPromptSelection = true
        end
    end
    local result = run(function() return ctx.adapter.build(materialPlan(20), CFrame.new(),
        {getManualToolSelection = getter, infiniteBlocks = true, speed = "Rapid"}) end)
    assert(result.ok, result.message); equal(ctx.checkedPromptSelection, true)
    equal(ctx.maxPrepScales, 1); equal(ctx.nativeActive.paint, true)
    equal(result.diagnostics.preparation_status, "verified"); equal(result.completed, 20)
end)

local function gridPlan(count)
    local p = plan(count)
    p.columns, p.rows = math.min(128, count), math.ceil(count / 128)
    p.width_studs, p.height_studs = p.columns * p.pixel_studs, p.rows * p.pixel_studs
    for index, rect in ipairs(p.rectangles) do rect.x = (index - 1) % 128; rect.y = math.floor((index - 1) / 128) end
    return p
end

test("Rapid verifies delayed geometry before sending each bounded paint payload", function()
    local ctx = context({stock = 1000, remoteDelay = 0.1, replicationDelay = 0.15, returnNil = true,
        onDispatch = function(c, stage, args, count)
            if stage == "paint" then
                assert(#args[1] <= 64)
                for _, entry in ipairs(args[1]) do near(entry[1].PPart.Size.X, 0.5) end
            end
        end})
    local result = run(function() return ctx.adapter.build(gridPlan(257), CFrame.new(), {speed = "Rapid"}) end)
    assert(result.ok, result.message); equal(result.completed, 257); assert(result.diagnostics.pipeline_paint_batches >= 4)
end)

test("Rapid handles a last small window without losing or double counting its paint tail", function()
    local ctx = context({stock = 2000, remoteDelay = 0.02, returnNil = true})
    local result = run(function() return ctx.adapter.build(gridPlan(1030), CFrame.new(), {speed = "Rapid"}) end)
    assert(result.ok, result.message); equal(result.completed, 1030); equal(result.created, 1030)
    equal(result.diagnostics.pipeline_windows, 5); equal(#ctx.painted, 1030)
    local seen = {}; for _, model in ipairs(ctx.painted) do assert(not seen[model]); seen[model] = true end
end)

test("Rapid nil-return cohort boundary rejects two matching models before either is changed", function()
    local ctx = context({stock = 1000, returnNil = true, remoteDelay = 0.1,
        afterBuild = function(c, count)
            if count == 65 then c.ambiguous = c.built[count]; c.manual = c:addBlock(c.ambiguous.PPart.CFrame) end
        end})
    local result = run(function() return ctx.adapter.build(gridPlan(130), CFrame.new(), {speed = "Rapid"}) end)
    equal(result.ok, false); has(result.message, "Multiple new blocks")
    for _, model in ipairs(ctx.scaled) do assert(model ~= ctx.ambiguous and model ~= ctx.manual) end
    for _, model in ipairs(ctx.painted) do assert(model ~= ctx.ambiguous and model ~= ctx.manual) end
    near(ctx.ambiguous.PPart.Size.X, 2); near(ctx.manual.PPart.Size.X, 2)
end)

test("Rapid rejects geometry failure without sending that model to paint", function()
    local ctx = context({stock = 1000, remoteDelay = 0.1, afterScale = function(c, count)
        if count == 2 then c.bad = c.scaled[count]; c.bad.PPart.Size = Vector3.new(2, 2, 2) end
    end})
    local result = run(function() return ctx.adapter.build(gridPlan(130), CFrame.new(), {speed = "Rapid"}) end)
    equal(result.ok, false); has(result.message, "requested block size")
    for _, model in ipairs(ctx.painted) do assert(model ~= ctx.bad) end
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
end)

test("Rapid rechecks final geometry after paint when manual scaling changes a block", function()
    local ctx = context({stock = 1000, remoteDelay = 0.1, afterPaint = function(c, count)
        if count == 2 then c.bad = c.painted[#c.painted]; c.bad.PPart.Size = Vector3.new(2, 2, 2) end
    end})
    local result = run(function() return ctx.adapter.build(gridPlan(130), CFrame.new(), {speed = "Rapid"}) end)
    equal(result.ok, false); has(result.message, "requested block size or position")
    assert(result.completed < 130); equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
    equal(result.diagnostics.verification_failure_phase, "paint")
    assert(result.diagnostics.verification_size_error > 1)
    near(result.diagnostics.verification_color_error, 0)
end)

test("Rapid pipeline drains promptly for a manual selection before the finite window ends", function()
    local ctx = context({stock = 2000, remoteDelay = 0.4, returnNil = true, frameStep = 1 / 60})
    local getter = nativeControllers(ctx)
    ctx.settings.afterBuild = function(c, count)
        if count == 2 then c.changedAt = clock; c.selection = {revision = 1, tool = c.tools.paint, available = true} end
    end
    ctx.onNativeEquip = function(stage)
        if stage == "paint" then
            equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
            assert(clock - ctx.changedAt < 0.75, "Manual controls should not wait for the whole window")
            assert(ctx.counters.build < 1025, "Selection must happen before the placement window ends")
            ctx.applied = true
        end
    end
    local result = run(function() return ctx.adapter.build(gridPlan(1025), CFrame.new(),
        {speed = "Rapid", getManualToolSelection = getter}) end)
    assert(result.ok, result.message); equal(ctx.applied, true); assert(result.diagnostics.manual_drains >= 1)
    equal(result.diagnostics.manual_selection_revision, 1)
end)

test("Rapid discards a disappeared manual selection instead of deadlocking the dispatch drain", function()
    local ctx = context({stock = 1000, remoteDelay = 0.2, returnNil = true})
    local getter = nativeControllers(ctx)
    ctx.extra = parent(instance("Tool", "ExtraTool"), ctx.backpack)
    ctx.settings.afterBuild = function(c, count)
        if count == 2 then c.selection = {revision = 1, tool = c.extra, available = true} end
        if count == 3 then parent(c.extra, nil) end
    end
    local result = run(function() return ctx.adapter.build(gridPlan(257), CFrame.new(),
        {speed = "Rapid", getManualToolSelection = getter}) end)
    assert(result.ok, result.message); equal(result.completed, 257); assert(clock < 10)
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
end)

test("Rapid limits catch-up bursts after a half-second client Heartbeat stall", function()
    local ctx = context({stock = 2000, remoteDelay = 0.1, returnNil = true, frameStep = 1 / 60,
        hitchAt = 0.55, hitchDuration = 0.5})
    local result = run(function() return ctx.adapter.build(gridPlan(1025), CFrame.new(), {speed = "Rapid"}) end)
    assert(result.ok, result.message); equal(hitchApplied, true); equal(result.completed, 1025)
    local byFrame, start = {}, 1
    for finish, call in ipairs(ctx.dispatches) do
        local key = string.format("%.6f", call.at)
        byFrame[key] = (byFrame[key] or 0) + 1
        assert(byFrame[key] <= 12, "Overdue reservations exceeded the12 request burst budget")
        while call.at - ctx.dispatches[start].at >= 1 do start += 1 end
        assert(finish - start + 1 <= 612, "Dispatch exceeded600 requests/s plus12 catch-up tokens")
    end
    assert(ctx.maxRemoteCalls <= 384); equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
end)

test("Adaptive Rapid grows gradually on healthy60Hz and30Hz clients without false frame backoff", function()
    for _, frame in ipairs({1 / 60, 1 / 30}) do
        local ctx = context({stock = 3000, remoteDelay = 0.1, returnNil = true, frameStep = frame})
        local result = run(function() return ctx.adapter.build(gridPlan(768), CFrame.new(), {speed = "Rapid"}) end)
        assert(result.ok, result.message); equal(result.completed, 768)
        equal(result.diagnostics.pipeline_version, 2); equal(result.diagnostics.adaptive_downshifts, 0)
        assert(result.diagnostics.adaptive_upshifts > 0)
        assert(result.diagnostics.adaptive_peak_workers <= 64); assert(ctx.maxRemoteCalls <= 64)
        assert(result.diagnostics.pipeline_peak_active <= 128)
        assert(result.diagnostics.peak_geometry_jobs <= 256)
        assert(result.diagnostics.verification_checks_peak <= 24)
        equal(ctx.maxPaintCalls, 1)
    end
end)

test("Adaptive Rapid backs off and completes when server and replication latency grow with load", function()
    local ctx
    ctx = context({stock = 3000, returnNil = true,
        remoteDelay = function(c) return 0.1 + math.max(0, c.activeRemoteCalls - 8) * 0.6 end,
        replicationDelay = function(c) return 0.15 + math.max(0, (c.activeRemoteCalls or 0) - 8) * 0.25 end,
        frameStep = function() return ctx and (ctx.activeRemoteCalls or 0) > 10 and 0.1 or 1 / 60 end})
    local result = run(function() return ctx.adapter.build(gridPlan(257), CFrame.new(), {speed = "Rapid"}) end)
    assert(result.ok, result.message); equal(result.completed, 257); equal(result.created, 257)
    assert(result.diagnostics.adaptive_downshifts > 0); assert(result.diagnostics.rpc_latency_max_seconds > 1)
    assert(result.diagnostics.replication_pause_count > 0)
    assert(ctx.maxRemoteCalls <= 64); equal(ctx.maxPaintCalls, 1)
    assert(result.diagnostics.replication_peak_waiting <= 128)
    assert(result.diagnostics.verification_checks_peak <= 24)
    equal(ctx.counters.build, 257); equal(ctx.counters.scale, 257); equal(#ctx.painted, 257)
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
    assert(clock < 200, "Adaptive admission must not deadlock while waiting for replication")
    print(string.format("MOCK_ADAPTIVE_LOAD 257 verified %.3fs peak%d pending downshifts%d peakRPC%.3fs",
        clock, ctx.maxRemoteCalls, result.diagnostics.adaptive_downshifts, result.diagnostics.rpc_latency_max_seconds))
end)

test("Rapid first proof tolerates six-second placement geometry and paint replication", function()
    for _, delayedStage in ipairs({"build", "scale", "paint"}) do
        local ctx = context({stock = 100, remoteDelay = 0.1, returnNil = true,
            replicationDelay = function(c, stage) return stage == delayedStage and 6 or 0 end})
        local result = run(function() return ctx.adapter.build(gridPlan(1), CFrame.new(), {speed = "Rapid"}) end)
        assert(result.ok, delayedStage .. ": " .. result.message); equal(result.completed, 1)
        equal(ctx.counters.build, 1); equal(ctx.counters.scale, 1); equal(ctx.counters.paint, 1)
        assert(clock >= 6); assert(clock < 9); assert(result.diagnostics.verification_budget_seconds >= 8)
    end
end)

test("Rapid waits for six-second paint replication on proof and later jobs without duplicate requests", function()
    local ctx = context({stock = 1000, remoteDelay = 0.1, returnNil = true,
        replicationDelay = function(c, stage) return stage == "paint" and 6 or 0.05 end})
    local result = run(function() return ctx.adapter.build(gridPlan(33), CFrame.new(), {speed = "Rapid"}) end)
    assert(result.ok, result.message); equal(result.completed, 33); equal(result.created, 33)
    equal(ctx.counters.build, 33); equal(ctx.counters.scale, 33); equal(#ctx.painted, 33)
    equal(ctx.maxPaintCalls, 1); assert(result.diagnostics.replication_pause_count > 0)
    local painted, scaled = {}, {}
    for _, model in ipairs(ctx.painted) do assert(not painted[model]); painted[model] = true end
    for _, model in ipairs(ctx.scaled) do assert(not scaled[model]); scaled[model] = true end
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
end)

test("Rapid permanent bad paint fails one absolute deadline while other correct jobs count once", function()
    local ctx = context({stock = 1000, remoteDelay = 0.1, afterPaint = function(c, count)
        if count == 2 then
            c.bad = c.painted[#c.painted]; c.bad.PPart.Color = Color3.fromRGB(0, 0, 0); c.badAt = clock
        end
    end})
    local result = run(function() return ctx.adapter.build(gridPlan(65), CFrame.new(), {speed = "Rapid"}) end)
    equal(result.ok, false); has(result.message, "requested paint color")
    equal(result.diagnostics.verification_failure_phase, "paint")
    equal(result.diagnostics.verification_failure_owned, true)
    near(result.diagnostics.verification_size_error, 0); near(result.diagnostics.verification_position_error, 0)
    assert(result.diagnostics.verification_color_error > 0.5)
    assert(result.completed > 1 and result.completed < 65)
    assert(clock - ctx.badAt < 9, "Each job must not receive an extra serial timeout")
    local seen = {}; for _, model in ipairs(ctx.painted) do assert(not seen[model]); seen[model] = true end
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
end)

test("Rapid rechecks reduced capacity after old reservations when frame cadence becomes slow", function()
    local ctx = context({stock = 1000, remoteDelay = 0.2, returnNil = true,
        frameStep = function() return clock >= 1.5 and 0.2 or 1 / 60 end})
    local result = run(function() return ctx.adapter.build(gridPlan(96), CFrame.new(), {speed = "Rapid"}) end)
    assert(result.ok, result.message); equal(result.completed, 96)
    assert(result.diagnostics.adaptive_downshifts > 0); equal(result.diagnostics.worker_limit, 4)
    local checked = 0
    for _, call in ipairs(ctx.dispatches) do
        if call.at >= 3 then checked += 1; assert(call.pending <= 4, "An old reservation bypassed the reduced cap") end
    end
    assert(checked > 0); assert(result.diagnostics.monitor_delay_max_seconds >= 0.19)
end)

test("Rapid cancellation while replication is backed up stops admission and keeps verified counts", function()
    local ctx = context({stock = 1000, remoteDelay = 0.1, returnNil = true,
        replicationDelay = function(c, stage) return stage == "paint" and 6 or 0 end})
    local result = run(function() return ctx.adapter.build(gridPlan(257), CFrame.new(), {speed = "Rapid",
        shouldCancel = function() return ctx.cancel == true end,
        onProgress = function(done, total, message)
            if string.find(message, "Waiting for block updates", 1, true) then ctx.cancel = true end
        end}) end)
    equal(result.ok, false); assert(result.completed >= 1); assert(ctx.counters.build <= 49)
    local calls = #ctx.calls
    drain(); equal(#ctx.calls, calls); equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
end)

test("Rapid final verification reports ownership loss immediately instead of waiting the slow budget", function()
    local ctx = context({stock = 1000, remoteDelay = 0.1, afterPaint = function(c, count)
        if count == 2 then c.movedAt = clock; parent(c.painted[#c.painted], c.world) end
    end})
    local result = run(function() return ctx.adapter.build(gridPlan(65), CFrame.new(), {speed = "Rapid"}) end)
    equal(result.ok, false); equal(result.diagnostics.verification_failure_owned, false)
    has(result.message, "outside your plot"); assert(clock - ctx.movedAt < 1)
end)

test("Rapid caches borrowed tool descendant scans rather than rescanning every request", function()
    local ctx = context({stock = 1000, remoteDelay = 0.1})
    local reads = 0
    for _, tool in pairs(ctx.tools) do
        local original = tool.GetDescendants
        function tool:GetDescendants() reads += 1; return original(self) end
    end
    local result = run(function() return ctx.adapter.build(gridPlan(130), CFrame.new(), {speed = "Rapid"}) end)
    assert(result.ok, result.message); assert(reads <= 10, "Tool hierarchy must not be walked for every RPC")
    equal(ctx.scripts.build.Disabled, false); equal(ctx.scripts.scale.Disabled, false); equal(ctx.scripts.paint.Disabled, false)
end)

test("Cancelling slow first-proof replication reports cancellation rather than a false paint rejection", function()
    local ctx = context({stock = 1000, remoteDelay = 0.1,
        replicationDelay = function(c, stage) return stage == "paint" and 6 or 0 end,
        afterPaint = function(c) task.spawn(function() task.wait(0.3); c.cancel = true end) end})
    local result = run(function() return ctx.adapter.build(gridPlan(33), CFrame.new(), {speed = "Rapid",
        shouldCancel = function() return ctx.cancel == true end}) end)
    equal(result.ok, false); equal(result.completed, 0); equal(ctx.counters.build, 1)
    has(result.message, "Stopped by you"); equal(result.diagnostics.verification_failure_phase, nil)
    equal(sharedEnvironment.__ImageBuilderFlight.pending, 0)
end)

print("MOCK_GAME_ADAPTER_TESTS_PASSED " .. tostring(tests))
