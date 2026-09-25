-- BAFT Image Builder: standalone interface; conversion runs in this client.
local ENV = (getgenv and getgenv()) or _G
local previous = ENV.ImageBuilder
if previous and type(previous.IsBusy) == "function" and previous.IsBusy() then
    if type(previous.Stop) == "function" then previous.Stop() end
    local deadline = os.clock() + 15
    repeat task.wait(0.1) until not previous.IsBusy() or os.clock() >= deadline
    if previous.IsBusy() then
        warn("Image Builder: the previous operation is still stopping. Wait until it stops, then run the loader again.")
        return
    end
end
-- Another loader may have finished the replacement while this one was waiting.
if ENV.ImageBuilder and ENV.ImageBuilder ~= previous then return end
if previous and type(previous.Destroy) == "function" then previous.Destroy() end

local Adapter = __GAME_ADAPTER__
local Backend = __IMAGE_BACKEND__
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui")
if playerGui then
    for _, name in ipairs({"ImageRecorderLoader", "ImageRecorderStatus"}) do
        local diagnosticPanel = playerGui:FindFirstChild(name)
        if diagnosticPanel then diagnosticPanel:Destroy() end
    end
end

local destroyed, processing, building, cancelled = false, false, false, false
local inventoryRefreshing = false
local generation = 0
local plan, placeTool, ghost, placement, renderConnection, placementAllowed, placementReason
local toolConnections, connections, inventory = {}, {}, {}
local selectedBlock, speed, yaw = nil, "Rapid", 0
local toolMode = "background"
local infiniteBlocks = true
local qualityIndex = 1
local samplingIndex, detailIndex = 1, 2
local samplingPresets = {
    {name = "Photo", value = "lanczos"},
    {name = "Pixel art", value = "nearest"},
    {name = "Soft", value = "area"},
}
local detailPresets = {
    {name = "None", value = "none"},
    {name = "Light", value = "light"},
    {name = "Strong", value = "strong"},
}
local programmaticText = setmetatable({}, { __mode = "k" })
local function setFieldText(field, text)
    -- Property signals can be deferred and observe the latest of several writes.
    -- Keep this expected value until a different user edit arrives, rather than
    -- clearing a boolean before Roblox dispatches the queued signal callbacks.
    programmaticText[field] = text
    field.Text = text
end
local qualityPresets = {
    { name = "Auto", mode = "auto", maxPixels = 250000 },
    { name = "Source", mode = "source", maxPixels = 250000 },
    { name = "Preview", columns = 100, mode = "spacing", maxPixels = 100000 },
    { name = "High", columns = 200, mode = "spacing", maxPixels = 250000 },
    { name = "Ultra", columns = 400, mode = "spacing", maxPixels = 250000 },
}
local previewFiles, activePreviewPath = Backend.previewFiles(), nil
local chosenCount = 0
local api = {Version = "3.0.1"}
ENV.ImageBuilder = api

local C = {
    background = Color3.fromRGB(12, 17, 27), card = Color3.fromRGB(19, 27, 41),
    field = Color3.fromRGB(28, 39, 56), edge = Color3.fromRGB(42, 58, 79),
    text = Color3.fromRGB(238, 244, 253), dim = Color3.fromRGB(153, 171, 196),
    green = Color3.fromRGB(85, 223, 162), blue = Color3.fromRGB(96, 165, 255),
    red = Color3.fromRGB(252, 132, 145), yellow = Color3.fromRGB(241, 205, 127),
}
local UI = {width = 480, previewSize = 148, fullHeight = 760, minimized = false,
    startedAt = nil, completed = 0, total = 0}
local function create(class, properties, parent)
    local object = Instance.new(class)
    for key, value in pairs(properties) do object[key] = value end
    object.Parent = parent
    return object
end
local function round(object, radius)
    create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, object)
end
local function label(parent, text, x, y, width, height, size, color)
    return create("TextLabel", {
        Text = text, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, height),
        BackgroundTransparency = 1, BorderSizePixel = 0, Font = Enum.Font.Gotham,
        TextSize = size or 13, TextColor3 = color or C.text,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end
local function button(parent, text, x, y, width, height, color)
    local object = create("TextButton", {
        Text = text, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = color or C.field, BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.text,
        AutoButtonColor = true,
    }, parent)
    round(object)
    return object
end
local function input(parent, text, x, y, width)
    local object = create("TextBox", {
        Text = text, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, 34),
        BackgroundColor3 = C.field, BorderSizePixel = 0, Font = Enum.Font.Gotham,
        TextSize = 13, TextColor3 = C.text, PlaceholderColor3 = C.dim,
        ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
    create("UIPadding", {PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 11)}, object)
    round(object)
    return object
end
local gui = create("ScreenGui", {
    Name = "LocalImageBuilder", ResetOnSpawn = false, IgnoreGuiInset = true,
    DisplayOrder = 200, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, nil)
local parented = pcall(function()
    gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not parented or not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end
local camera = Workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
local panel = create("Frame", {
    Name = "Panel", Size = UDim2.fromOffset(UI.width, UI.fullHeight),
    Position = UDim2.fromOffset(math.max(12, viewport.X - UI.width - 24), 12),
    BackgroundColor3 = C.background, BorderSizePixel = 0,
}, gui)
round(panel, 16)
create("UIStroke", {Color = C.edge, Thickness = 1}, panel)
local panelScale = create("UIScale", {Scale = 1}, panel)
local header = create("Frame", {
    BackgroundTransparency = 1, Size = UDim2.new(1, -94, 0, 54), Active = true,
}, panel)
local brand = label(header, "Image Builder", 18, 15, 230, 26, 18)
brand.Font = Enum.Font.GothamMedium
label(header, "v" .. tostring(api.Version), 255, 19, 70, 20, 11, C.dim)
local minimize = button(panel, "-", 392, 15, 30, 30)
local close = button(panel, "X", 432, 15, 30, 30)
local content = {}
local function remember(object) table.insert(content, object); return object end
local scroll = remember(create("ScrollingFrame", {
    Name = "Settings", Position = UDim2.fromOffset(16, 60), Size = UDim2.new(1, -32, 1, -276),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.edge, CanvasSize = UDim2.fromOffset(0, 796),
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, panel))
local function card(name, y, height)
    local frame = create("Frame", {
        Name = name, Position = UDim2.fromOffset(0, y), Size = UDim2.fromOffset(440, height),
        BackgroundColor3 = C.card, BorderSizePixel = 0,
    }, scroll)
    round(frame, 12)
    return frame
end
local function sectionTitle(parent, number, text)
    local title = label(parent, text, 14, 9, 398, 22, 12)
    title.Font = Enum.Font.GothamMedium
end
local imageCard = card("Image", 0, 270)
sectionTitle(imageCard, "01", "Image & quality")
local urlInput = input(imageCard, "", 14, 39, 412)
urlInput.PlaceholderText = "Paste a direct image URL..."
local preview = create("Frame", {
    Position = UDim2.fromOffset(14, 90), Size = UDim2.fromOffset(UI.previewSize, UI.previewSize),
    BackgroundColor3 = C.background, BorderSizePixel = 0, ClipsDescendants = true,
}, imageCard)
round(preview, 9)
create("UIStroke", {Color = C.edge}, preview)
local previewEmpty = label(preview, "Your preview\nwill appear here", 8, 43, 132, 58, 11, C.dim)
previewEmpty.TextXAlignment = Enum.TextXAlignment.Center
previewEmpty.TextWrapped = true
local thumbnailCaption = label(imageCard, "Processed image", 14, 244, 148, 15, 10, C.dim)
thumbnailCaption.TextXAlignment = Enum.TextXAlignment.Center
local qualityButton = button(imageCard, "Resolution: Auto  >", 178, 90, 248, 38)
local samplingButton = button(imageCard, "Sampling: Photo  >", 178, 137, 248, 38)
local detailButton = button(imageCard, "Detail: Light  >", 178, 184, 248, 38)
label(imageCard, "Photo = smooth  /  Pixel art = sharp edges", 178, 230, 248, 28, 9, C.dim).TextWrapped = true
local geometryCard = card("Dimensions", 282, 174)
sectionTitle(geometryCard, "02", "Wall dimensions")
label(geometryCard, "Width in studs", 14, 36, 198, 18, 11, C.dim)
label(geometryCard, "Pixel size in studs", 226, 36, 200, 18, 11, C.dim)
local widthInput = input(geometryCard, "50", 14, 57, 198)
local pixelInput = input(geometryCard, "0.125", 226, 57, 200)
label(geometryCard, "Maximum pixels", 14, 101, 198, 18, 11, C.dim)
label(geometryCard, "Palette  /  0 = full color", 226, 101, 200, 18, 11, C.dim)
local maxInput = input(geometryCard, "250000", 14, 123, 198)
local paletteInput = input(geometryCard, "0", 226, 123, 200)
local materialCard = card("Building", 468, 208)
sectionTitle(materialCard, "03", "Material & building")
local blockButton = button(materialCard, "Reading your inventory...", 14, 39, 316, 34)
local refreshButton = button(materialCard, "Refresh", 338, 39, 88, 34)
local toolModeButton = button(materialCard, "Tools: Hands free  >", 14, 84, 246, 34)
local speedButton = button(materialCard, "Speed: Rapid  v", 268, 84, 158, 34)
local infiniteButton = button(materialCard, "Infinite Blocks: ON  (verify inventory)", 14, 129, 412, 34)
infiniteButton.TextColor3 = C.green
local explanation = label(materialCard,
    "Use your normal hotbar while building.\nAvailable material is checked before placement.",
    14, 170, 412, 29, 10, C.dim)
explanation.TextWrapped = true
local planCard = card("Plan", 688, 96)
sectionTitle(planCard, "04", "Build plan")
local summary = label(planCard, "Auto chooses more pixels for a larger wall.\nConvert an image to see its size and material needs.", 14, 35, 412, 51, 11, C.dim)
summary.TextWrapped = true
summary.TextYAlignment = Enum.TextYAlignment.Top
local dock = remember(create("Frame", {
    Name = "BuildStatus", Position = UDim2.new(0, 16, 1, -208), Size = UDim2.fromOffset(448, 184),
    BackgroundTransparency = 1,
}, panel))
local phaseLabel = label(dock, "READY TO CONVERT", 0, 0, 314, 20, 11, C.blue)
phaseLabel.Font = Enum.Font.GothamBold
local progressCount = label(dock, "", 306, 0, 142, 20, 11, C.dim)
progressCount.TextXAlignment = Enum.TextXAlignment.Right
local progressTrack = create("Frame", {
    Position = UDim2.fromOffset(0, 27), Size = UDim2.fromOffset(448, 6),
    BackgroundColor3 = C.field, BorderSizePixel = 0, ClipsDescendants = true,
}, dock)
round(progressTrack, 3)
local progressFill = create("Frame", {
    Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.blue, BorderSizePixel = 0,
}, progressTrack)
round(progressFill, 3)
local progressMeta = label(dock, "Convert  >  Place  >  Aim and click", 0, 40, 448, 18, 11, C.dim)
local status = label(dock, "Paste a direct PNG or JPEG image link to begin.", 0, 66, 448, 64, 12, C.dim)
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Top
local convertButton = button(dock, "1  Convert image", 0, 140, 166, 40, Color3.fromRGB(39, 99, 190))
local placeButton = button(dock, "2  Place", 174, 140, 166, 40, Color3.fromRGB(28, 113, 85))
local stopButton = button(dock, "Stop", 348, 140, 100, 40, Color3.fromRGB(60, 37, 50))
local footer = remember(label(panel, "R: 90 degrees  /  Q, E: 15 degrees  /  Drag title to move", 18, 0, 444, 17, 10, C.dim))
footer.Position = UDim2.new(0, 18, 1, -20)
local blockMenu = create("ScrollingFrame", {
    Position = UDim2.fromOffset(16, 170), Size = UDim2.fromOffset(440, 212),
    BackgroundColor3 = C.field, BorderSizePixel = 0, ScrollBarThickness = 4,
    CanvasSize = UDim2.fromOffset(0, 0), Visible = false, ZIndex = 20,
}, panel)
round(blockMenu, 9)
create("UIStroke", { Color = C.blue, Thickness = 1 }, blockMenu)
local speedMenu = create("Frame", {
    Position = UDim2.fromOffset(294, 170), Size = UDim2.fromOffset(162, 141),
    BackgroundColor3 = C.field, BorderSizePixel = 0, Visible = false, ZIndex = 20,
}, panel)
round(speedMenu, 9)
create("UIStroke", {Color = C.edge}, speedMenu)

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end
local function setStatus(message, color)
    if destroyed then return end
    local text, tint = tostring(message), color or C.dim
    if status.Text ~= text then status.Text = text end
    if status.TextColor3 ~= tint then status.TextColor3 = tint end
end
local function resetProgress(phase)
    UI.completed, UI.total = 0, 0
    phaseLabel.Text = phase or "READY TO CONVERT"
    progressCount.Text = ""
    progressFill.Position = UDim2.fromScale(0, 0)
    progressFill.Size = UDim2.fromScale(0, 1)
    progressFill.BackgroundColor3 = C.blue
    progressMeta.Text = "Convert  >  Place  >  Aim and click"
end
local function showBuildProgress(done, total, phase, wallElapsed)
    done, total = math.max(0, tonumber(done) or 0), math.max(0, tonumber(total) or 0)
    UI.completed, UI.total = done, total
    phaseLabel.Text = phase or "BUILDING YOUR WALL"
    progressCount.Text = string.format("%d / %d", done, total)
    progressFill.Position = UDim2.fromScale(0, 0)
    progressFill.Size = UDim2.fromScale(total > 0 and math.clamp(done / total, 0, 1) or 0, 1)
    local elapsed = UI.startedAt and math.max(0.001, os.clock() - UI.startedAt) or 0
    local measured = tonumber(wallElapsed)
    if measured and measured >= 0 and measured < math.huge then elapsed = measured end
    if done > 0 and elapsed > 0 then
        local rate = done / elapsed
        local eta = math.max(0, math.ceil((total - done) / rate))
        local remaining = eta >= 60 and string.format("%dm %02ds", math.floor(eta / 60), eta % 60) or (eta .. "s")
        progressMeta.Text = string.format("%.1f blocks/s  /  %ds elapsed%s", rate, math.floor(elapsed),
            done < total and phase ~= "BUILD STOPPED" and phase ~= "STOPPING" and ("  /  ETA ~" .. remaining) or "")
    elseif phase == "PREPARING MATERIAL" or phase == "CHECKING MATERIAL" then
        progressMeta.Text = "Checking available material before wall placement..."
    else
        progressMeta.Text = "Waiting for verified placements..."
    end
end
local function fitPanel(keepPosition)
    local view = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or viewport
    local scale = math.max(0.2, math.min(1, (view.X - 24) / UI.width, (view.Y - 24) / 520))
    panelScale.Scale = scale
    UI.fullHeight = math.max(520, math.min(820, (view.Y - 24) / scale))
    local height = UI.minimized and 62 or UI.fullHeight
    panel.Size = UDim2.fromOffset(UI.width, height)
    local x = keepPosition and panel.Position.X.Offset or (view.X - UI.width * scale - 24)
    local y = keepPosition and panel.Position.Y.Offset or math.max(12, (view.Y - height * scale) / 2)
    panel.Position = UDim2.fromOffset(math.clamp(x, 0, math.max(0, view.X - UI.width * scale)),
        math.clamp(y, 0, math.max(0, view.Y - height * scale)))
end
local function anchorMenu(menu, trigger)
    local scale = panelScale.Scale
    local x = (trigger.AbsolutePosition.X - panel.AbsolutePosition.X) / scale
    local y = (trigger.AbsolutePosition.Y - panel.AbsolutePosition.Y + trigger.AbsoluteSize.Y) / scale + 5
    menu.Position = UDim2.fromOffset(math.clamp(x, 12, UI.width - menu.Size.X.Offset - 12),
        math.clamp(y, 66, math.max(66, UI.fullHeight - menu.Size.Y.Offset - 12)))
end
local function busy() return processing or building end
api.IsBusy = busy
local function styleEnabled(object, enabled)
    object.AutoButtonColor = enabled
    object.TextTransparency = enabled and 0 or 0.55
end
local function syncButtons()
    if destroyed then return end
    styleEnabled(convertButton, not busy() and selectedBlock ~= nil and not inventoryRefreshing)
    styleEnabled(placeButton, not busy() and plan ~= nil)
    styleEnabled(blockButton, not busy())
    styleEnabled(refreshButton, not busy() and not inventoryRefreshing)
    styleEnabled(speedButton, not busy())
    styleEnabled(qualityButton, not busy())
    styleEnabled(samplingButton, not busy())
    local sourceMode = qualityIndex and qualityPresets[qualityIndex].mode == "source"
    styleEnabled(detailButton, not busy() and not sourceMode)
    detailButton.Text = sourceMode and "Detail: None (Source exact)" or ("Detail: " .. detailPresets[detailIndex].name .. "  >")
    styleEnabled(toolModeButton, not busy())
    styleEnabled(infiniteButton, not busy())
    styleEnabled(stopButton, busy() or placeTool ~= nil)
    convertButton.Text = processing and "Converting..." or "1  Convert image"
    placeButton.Text = building and "Building..." or (placeTool and "Re-equip Place" or "2  Place")
    for _, field in ipairs({ urlInput, widthInput, pixelInput, maxInput, paletteInput }) do
        field.TextEditable = not busy()
    end
end
local function clearGhost()
    if renderConnection then renderConnection:Disconnect(); renderConnection = nil end
    if ghost then ghost:Destroy(); ghost = nil end
    placement = nil
    placementAllowed, placementReason = false, nil
end
local function clearTool()
    clearGhost()
    for _, connection in ipairs(toolConnections) do connection:Disconnect() end
    table.clear(toolConnections)
    if placeTool then placeTool:Destroy(); placeTool = nil end
end
local function clearPreview()
    for _, child in ipairs(preview:GetChildren()) do
        if child:IsA("Frame") or child:IsA("ImageLabel") then child:Destroy() end
    end
    activePreviewPath = nil
    previewEmpty.Visible = true
    thumbnailCaption.Text = "Processed image"
end
local function invalidate()
    if destroyed or busy() then return end
    generation += 1
    plan = nil
    clearTool()
    clearPreview()
    resetProgress("SETTINGS CHANGED")
    local width, pixel = tonumber(widthInput.Text), tonumber(pixelInput.Text)
    if qualityIndex and qualityPresets[qualityIndex].mode == "source" then
        summary.Text = "Source: keeps the original image's pixel dimensions.\nPalette 0 preserves full color; pixel size is calculated."
    elseif width and pixel and width > 0 and pixel > 0 and width < math.huge and pixel < math.huge then
        summary.Text = string.format("%.4g studs / %.4g = %.0f pixels across.\nSmaller pixels give more detail and use more blocks.", width, pixel, math.ceil(width / pixel))
    else
        summary.Text = "Smaller pixels give more detail and use more blocks.\nAuto adjusts to the pixel limit; Source stays exact."
    end
    setStatus("Settings changed. Convert the image to update the plan.")
    syncButtons()
end
for _, field in ipairs({ urlInput, widthInput, pixelInput, maxInput, paletteInput }) do
    connect(field:GetPropertyChangedSignal("Text"), function()
        local expected = programmaticText[field]
        if expected ~= nil then
            if field.Text == expected then return end
            programmaticText[field] = nil
        end
        if field == pixelInput then
            qualityIndex = nil
            qualityButton.Text = "Resolution: Custom  >"
        elseif field == widthInput and qualityIndex and qualityPresets[qualityIndex].columns then
            local width = tonumber(widthInput.Text)
            if width and width > 0 and width < math.huge then
                setFieldText(pixelInput, string.format("%.10g", width / qualityPresets[qualityIndex].columns))
            end
        end
        invalidate()
    end)
end
connect(qualityButton.Activated, function()
    if busy() then return end
    qualityIndex = ((qualityIndex or 0) % #qualityPresets) + 1
    local preset = qualityPresets[qualityIndex]
    local width = tonumber(widthInput.Text)
    if preset.mode == "auto" then
        setFieldText(pixelInput, "0.125")
    elseif preset.columns and width and width > 0 and width < math.huge then
        setFieldText(pixelInput, string.format("%.10g", width / preset.columns))
    end
    setFieldText(maxInput, tostring(preset.maxPixels))
    qualityButton.Text = "Resolution: " .. preset.name .. (preset.columns and (" (" .. preset.columns .. " px)") or "") .. "  >"
    invalidate()
end)
connect(samplingButton.Activated, function()
    if busy() then return end
    samplingIndex = (samplingIndex % #samplingPresets) + 1
    if samplingPresets[samplingIndex].value == "nearest" then detailIndex = 1 end
    samplingButton.Text = "Sampling: " .. samplingPresets[samplingIndex].name .. "  >"
    invalidate()
end)
connect(detailButton.Activated, function()
    if busy() or (qualityIndex and qualityPresets[qualityIndex].mode == "source") then return end
    detailIndex = (detailIndex % #detailPresets) + 1
    invalidate()
end)
connect(toolModeButton.Activated, function()
    if busy() then return end
    toolMode = toolMode == "compatible" and "background" or "compatible"
    local compatible = toolMode == "compatible"
    if compatible and speed == "Rapid" then
        speed = "Fast"
        speedButton.Text = "Speed: Fast  v"
    end
    toolModeButton.Text = compatible and "Tools: Compatible  >" or "Tools: Hands free  >"
    explanation.Text = compatible
        and "Compatible equips the game tools during each operation.\nLeave build tools alone until the job finishes."
        or "Choose a tool from your normal hotbar while the image builds.\nPrepares missing material and checks inventory."
    setStatus(compatible
        and "Compatible uses your build, scale, and paint tools during the job. Leave them alone until the job finishes."
        or "Hands free builds in the background. Select your normal tool from the hotbar to use its controls.", C.dim)
end)
connect(infiniteButton.Activated, function()
    if busy() then return end
    infiniteBlocks = not infiniteBlocks
    infiniteButton.Text = infiniteBlocks and "Infinite Blocks: ON  (verify inventory)" or "Infinite Blocks: OFF"
    infiniteButton.TextColor3 = infiniteBlocks and C.green or C.text
    setStatus(infiniteBlocks
        and "Prepares missing material, then checks the real inventory. If preparation cannot supply enough, the wall will not start."
        or "Material preparation is off. This build uses only your currently available material.", infiniteBlocks and C.yellow or C.dim)
end)
local function updateBlockCaption()
    blockButton.Text = selectedBlock and (selectedBlock .. "  (" .. tostring(chosenCount) .. ")  v") or "No buildable inventory found"
end
local function updateSummary()
    if not plan then return end
    local need = Adapter.materialNeed(plan)
    summary.Text = string.format("%d x %d pixels | %.2f x %.2f studs\n%d blocks | Need %d / available %d\nPixel: %.4g studs%s",
        plan.columns, plan.rows, plan.width_studs, plan.height_studs,
        plan.placement_count or plan.block_count, need, chosenCount, plan.pixel_studs,
        plan.grid_limited and " | Auto resolution capped" or "")
end
local function refreshInventory()
    if destroyed or busy() or inventoryRefreshing then return end
    inventoryRefreshing = true
    syncButtons()
    task.spawn(function()
        local ok, result = pcall(Adapter.inventory)
        inventoryRefreshing = false
        if destroyed then return end
        if not ok or type(result) ~= "table" then
            setStatus("Could not read block inventory: " .. tostring(result), C.red)
            syncButtons()
            return
        end
        local cleaned = {}
        for _, item in ipairs(result) do
            if type(item) == "table" and type(item.name) == "string" and type(item.count) == "number" then
                table.insert(cleaned, { name = item.name, count = math.max(0, math.floor(item.count)) })
            end
        end
        table.sort(cleaned, function(a, b)
            if a.count == b.count then return a.name < b.name end
            return a.count > b.count
        end)
        inventory = cleaned
        local oldSelection = selectedBlock
        local matched = false
        for _, item in ipairs(inventory) do
            if item.name == selectedBlock then chosenCount = item.count; matched = true; break end
        end
        if not matched then
            selectedBlock = inventory[1] and inventory[1].name or nil
            chosenCount = inventory[1] and inventory[1].count or 0
        end
        if oldSelection and oldSelection ~= selectedBlock then invalidate() end
        updateBlockCaption()
        updateSummary()
        for _, child in ipairs(blockMenu:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for index, item in ipairs(inventory) do
            local row = button(blockMenu, item.name .. "  /  " .. item.count .. " available", 6, (index - 1) * 34 + 5, 426, 30)
            row.ZIndex = 21
            row.TextSize = 12
            row.Activated:Connect(function()
                if busy() then return end
                selectedBlock, chosenCount = item.name, item.count
                blockMenu.Visible = false
                updateBlockCaption()
                invalidate()
            end)
        end
        blockMenu.CanvasSize = UDim2.fromOffset(0, #inventory * 34 + 10)
        if #inventory == 0 then setStatus("No building materials found. Join the game and obtain blocks, then refresh.", C.yellow) end
        syncButtons()
    end)
end
connect(refreshButton.Activated, refreshInventory)
connect(blockButton.Activated, function()
    if busy() then return end
    speedMenu.Visible = false
    anchorMenu(blockMenu, blockButton)
    blockMenu.Visible = not blockMenu.Visible
end)
connect(speedButton.Activated, function()
    if busy() then return end
    blockMenu.Visible = false
    anchorMenu(speedMenu, speedButton)
    speedMenu.Visible = not speedMenu.Visible
end)
for index, name in ipairs({ "Normal", "Fast", "Turbo", "Rapid" }) do
    local choice = button(speedMenu, name, 5, 5 + (index - 1) * 33, 152, 29)
    choice.ZIndex = 21
    connect(choice.Activated, function()
        if busy() then return end
        if name == "Rapid" and toolMode ~= "background" then
            speedMenu.Visible = false
            setStatus("Select Hands free tools to use Rapid speed.", C.yellow)
            return
        end
        speed = name
        speedButton.Text = "Speed: " .. name .. "  v"
        speedMenu.Visible = false
        setStatus(name == "Rapid" and "Rapid adjusts to the game's response time and slows down when block updates fall behind. Only verified blocks count toward progress."
            or (name == "Turbo" and "Turbo uses bounded parallel requests. The game can still limit build speed." or (name .. " speed selected.")))
    end)
end

local function numberField(field, name, minimum, maximum, integer)
    local number = tonumber(field.Text)
    if not number or number ~= number or number == math.huge or number == -math.huge then error(name .. " must be a number.", 0) end
    if number < minimum or number > maximum then error(name .. " must be between " .. minimum .. " and " .. maximum .. ".", 0) end
    if integer and number % 1 ~= 0 then error(name .. " must be a whole number.", 0) end
    return number
end
local function drawPreview(imagePlan)
    clearPreview()
    local source = imagePlan.thumbnail
    if type(source) ~= "table" or type(source.cells) ~= "table" then source = imagePlan end
    local columns, rows = source.columns, source.rows
    if type(source.cells) ~= "table" or type(columns) ~= "number" or type(rows) ~= "number"
        or columns < 1 or rows < 1 then return end
    previewEmpty.Visible = false
    thumbnailCaption.Text = "Quick preview"
    local map = {}
    for _, cell in ipairs(source.cells) do map[cell.y * columns + cell.x] = cell.color end
    local step = math.max(1, math.ceil(math.max(columns, rows) / 36))
    local displayColumns, displayRows = math.ceil(columns / step), math.ceil(rows / step)
    local scale = math.min(UI.previewSize / columns, UI.previewSize / rows)
    local offsetX, offsetY = (UI.previewSize - columns * scale) / 2, (UI.previewSize - rows * scale) / 2
    for y = 0, displayRows - 1 do
        for x = 0, displayColumns - 1 do
            local sourceX = math.min(columns - 1, x * step + math.floor(step / 2))
            local sourceY = math.min(rows - 1, y * step + math.floor(step / 2))
            local color = map[sourceY * columns + sourceX]
            if color then
                create("Frame", {
                    Position = UDim2.fromOffset(offsetX + x * step * scale, offsetY + y * step * scale),
                    Size = UDim2.fromOffset(math.min(step, columns - x * step) * scale, math.min(step, rows - y * step) * scale),
                    BackgroundColor3 = Color3.fromRGB(color[1], color[2], color[3]), BorderSizePixel = 0,
                }, preview)
            end
        end
    end
end
local function deletePreviewFile(path)
    if type(delfile) ~= "function" or path == activePreviewPath then return false end
    -- Only paths written by this script enter this list; never scan or delete others.
    local index = table.find(previewFiles, path)
    if not index then return false end
    local ok = pcall(delfile, path)
    if not ok and type(isfile) == "function" then
        local checkOK, exists = pcall(isfile, path)
        if checkOK and not exists then ok = true end
    end
    if ok then
        table.remove(previewFiles, index)
        if ENV.ImageBuilder == api then Backend.savePreviewFiles(previewFiles) end
    end
    return ok
end
-- Restore only this app's validated preview journal; never enumerate other files.
for _, path in ipairs(table.clone(previewFiles)) do deletePreviewFile(path) end
local function loadNativePreview(imagePlan, expectedGeneration)
    local assetFn = type(getcustomasset) == "function" and getcustomasset
        or (type(getsynasset) == "function" and getsynasset)
    local id = imagePlan.id
    if type(writefile) ~= "function" or type(delfile) ~= "function" or type(assetFn) ~= "function"
        or type(id) ~= "string" or #id ~= 24 or not id:match("^[0-9a-fA-F]+$") then return end
    local function current()
        return not destroyed and generation == expectedGeneration and plan == imagePlan
    end
    task.spawn(function()
        if not current() then return end
        local ok, bytes = pcall(Backend.preview, id)
        if not current() or not ok then return end
        if type(bytes) ~= "string" or #bytes > 4 * 1024 * 1024
            or bytes:sub(1, 8) ~= "\137PNG\13\10\26\10" then return end
        local folder = "baft image builder"
        if not current() then return end
        -- The loader has already verified this executor-relative folder.
        -- Keep at most three locally written preview files, even without delfile.
        while #previewFiles >= 3 do
            local victim
            for _, path in ipairs(previewFiles) do
                if path ~= activePreviewPath then victim = path; break end
            end
            if not victim or not deletePreviewFile(victim) then return end
            if not current() then return end
        end
        -- Unique names prevent native asset-cache reuse and stale-job deletion races.
        local path = folder .. "/preview_" .. id .. ".png"
        table.insert(previewFiles, path)
        if not Backend.savePreviewFiles(previewFiles) then
            table.remove(previewFiles, #previewFiles)
            return
        end
        local written = pcall(writefile, path, bytes)
        if not current() or not written then deletePreviewFile(path); return end
        local assetOK, asset = pcall(assetFn, path)
        if not current() then deletePreviewFile(path); return end
        if not assetOK or type(asset) ~= "string" or asset == "" then deletePreviewFile(path); return end
        local image = create("ImageLabel", {
            Name = "ProcessedImageThumbnail", BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0), Size = UDim2.fromScale(1, 1),
            Image = asset, ScaleType = Enum.ScaleType.Fit,
        }, nil)
        if not current() then image:Destroy(); deletePreviewFile(path); return end
        -- Keep the coarse fallback visible until Roblox loads the local PNG.
        image.Parent = preview
        local loadStart = os.clock()
        while not image.IsLoaded and os.clock() - loadStart < 3 do
            task.wait(0.05)
            if not current() or image.Parent ~= preview then image:Destroy(); deletePreviewFile(path); return end
        end
        if not image.IsLoaded then image:Destroy(); deletePreviewFile(path); return end
        image.Parent = nil
        clearPreview()
        previewEmpty.Visible = false
        activePreviewPath = path
        image.Parent = preview
        thumbnailCaption.Text = "Processed image"
    end)
end
local function safeError(value)
    return string.sub(tostring(value), 1, 700)
end
local function conversionSettings()
    local url = string.match(urlInput.Text, "^%s*(.-)%s*$")
    if not url:match("^https?://") then error("Paste a direct http:// or https:// image link.", 0) end
    if #url > 4096 then error("The image link is too long.", 0) end
    local palette = numberField(paletteInput, "Palette", 0, 256, true)
    if palette == 1 then error("Palette must be 0, or 2 to 256 colors.", 0) end
    local mode = qualityIndex and qualityPresets[qualityIndex].mode or "spacing"
    return {
        image_url = url, width_studs = numberField(widthInput, "Wall width", 0.05, 1000, false),
        pixel_studs = mode == "source" and 0.125 or numberField(pixelInput, "Pixel size", 0.001, 32, false),
        block_type = selectedBlock, max_blocks = numberField(maxInput, "Maximum pixels", 1, 250000, true),
        palette_size = palette, sampling = samplingPresets[samplingIndex].value, resolution_mode = mode,
        detail = mode == "source" and "none" or detailPresets[detailIndex].value,
        compact = true,
    }
end
connect(convertButton.Activated, function()
    if destroyed or busy() or inventoryRefreshing then return end
    local available, unavailableReason = Backend.available()
    if not available then setStatus(unavailableReason, C.red); return end
    if not selectedBlock then setStatus("Refresh your block inventory first.", C.yellow); return end
    local valid, settings = pcall(conversionSettings)
    if not valid then setStatus(safeError(settings), C.red); return end
    clearTool()
    blockMenu.Visible, speedMenu.Visible = false, false
    processing, cancelled = true, false
    plan = nil
    clearPreview()
    resetProgress("CONVERTING IMAGE")
    UI.startedAt = nil
    progressMeta.Text = "Local image processing / no blocks placed"
    generation += 1
    local requestGeneration = generation
    setStatus("Downloading image...")
    syncButtons()
    task.spawn(function()
        local ok, result = pcall(function()
            local decoded = Backend.convert(settings, {
                checkCancelled = function()
                    if destroyed or cancelled or generation ~= requestGeneration then error("Conversion cancelled.", 0) end
                end,
                progress = function(message)
                    if not destroyed and generation == requestGeneration then setStatus(tostring(message)) end
                end,
            })
            if type(decoded) ~= "table"
                or (type(decoded.rectangles) ~= "table" and type(decoded.cells) ~= "table")
                or type(decoded.columns) ~= "number" or type(decoded.rows) ~= "number"
                or decoded.columns < 1 or decoded.rows < 1 or decoded.columns * decoded.rows > 250000
                or type(decoded.width_studs) ~= "number" or type(decoded.height_studs) ~= "number"
                or type(decoded.pixel_studs) ~= "number" or type(decoded.block_count) ~= "number" then
                error("The image converter returned an invalid plan.", 0)
            end
            return decoded
        end)
        processing = false
        if destroyed then
            if Adapter.teardown then pcall(Adapter.teardown) end
            if ENV.ImageBuilder == api then ENV.ImageBuilder = nil end
            return
        end
        if cancelled or generation ~= requestGeneration then
            resetProgress("CONVERSION CANCELLED")
            setStatus("Conversion cancelled. No blocks were placed.", C.yellow)
        elseif not ok then
            resetProgress("CONVERSION FAILED")
            setStatus(safeError(result), C.red)
        else
            plan = result
            resetProgress("READY TO PLACE")
            progressMeta.Text = string.format("%d planned blocks / material checked before building", plan.placement_count or plan.block_count)
            if settings.resolution_mode == "source" then
                setFieldText(pixelInput, string.format("%.10g", plan.pixel_studs))
            end
            drawPreview(plan)
            loadNativePreview(plan, requestGeneration)
            updateSummary()
            local callOK, allowed, reason = pcall(Adapter.validate, plan)
            if callOK and allowed then
                local warning = ""
                if type(plan.warnings) == "table" then
                    for index, message in ipairs(plan.warnings) do
                        if index > 2 then break end
                        if type(message) == "string" then warning ..= "\n" .. string.sub(message, 1, 180) end
                    end
                end
                setStatus("Select Place, aim the green wall, then click. R turns 90 degrees; Q / E adjusts 15 degrees." .. warning, warning == "" and C.green or C.yellow)
            else
                setStatus(tostring(callOK and reason or allowed), C.yellow)
            end
        end
        syncButtons()
    end)
end)

local function mouseOverPanel()
    local mouse = UserInputService:GetMouseLocation()
    local position, size = panel.AbsolutePosition, panel.AbsoluteSize
    return mouse.X >= position.X and mouse.X <= position.X + size.X
        and mouse.Y >= position.Y and mouse.Y <= position.Y + size.Y
end
local function sendTelemetry(buildPlan, ok, result, buildToolMode, buildInfiniteBlocks, buildSpeed)
    local report = type(result) == "table" and {
        ok = result.ok == true, message = safeError(result.message or ""),
        completed = tonumber(result.completed) or 0,
        created = tonumber(result.created) or 0,
        total = tonumber(result.total) or (buildPlan.placement_count or buildPlan.block_count),
    } or { ok = false, message = safeError(result), completed = 0,
        total = buildPlan.placement_count or buildPlan.block_count }
    if not ok then report.ok = false end
    if type(result) == "table" and type(result.diagnostics) == "table" then
        local diag = result.diagnostics
        report.diagnostics = {
            tool_mode = safeError(diag.tool_mode or ""), phase = safeError(diag.phase or ""),
            requests_sent = tonumber(diag.requests_sent), observed_new_models = tonumber(diag.observed_new_models),
            observed_material_models = tonumber(diag.observed_material_models),
            returned_type = safeError(diag.returned_type or ""),
            nearest_position_error = tonumber(diag.nearest_position_error),
            last_batch_new_objects = tonumber(diag.last_batch_new_objects),
            placement_argument_count = tonumber(diag.placement_argument_count),
            placement_tool_held = diag.placement_tool_held,
            infinite_requested = diag.infinite_requested == true,
            material_required = tonumber(diag.material_required),
            inventory_before = tonumber(diag.inventory_before),
            inventory_after = tonumber(diag.inventory_after),
            prep_requests = tonumber(diag.prep_requests),
            prep_version = tonumber(diag.prep_version),
            prep_rounds = tonumber(diag.prep_rounds),
            prep_scale_requests = tonumber(diag.prep_scale_requests),
            prep_gain = tonumber(diag.prep_gain),
            prep_stop_reason = safeError(diag.prep_stop_reason or ""),
            preparation_status = safeError(diag.preparation_status or ""),
            temporary_block_remaining = diag.temporary_block_remaining,
            speed_mode = safeError(diag.speed_mode or ""),
            effective_request_rate = tonumber(diag.effective_request_rate),
            peak_pending = tonumber(diag.peak_pending),
            wall_elapsed_seconds = tonumber(diag.wall_elapsed_seconds),
            verified_blocks_per_second = tonumber(diag.verified_blocks_per_second),
            manual_selection_supported = diag.manual_selection_supported == true,
            manual_tool_name = safeError(diag.manual_tool_name or ""),
            manual_selection_revision = tonumber(diag.manual_selection_revision),
            pipeline_version = tonumber(diag.pipeline_version),
            pipeline_windows = tonumber(diag.pipeline_windows),
            pipeline_peak_ready = tonumber(diag.pipeline_peak_ready),
            pipeline_peak_active = tonumber(diag.pipeline_peak_active),
            pipeline_paint_batches = tonumber(diag.pipeline_paint_batches),
            manual_drains = tonumber(diag.manual_drains),
            rpc_completed = tonumber(diag.rpc_completed),
            rpc_latency_total_seconds = tonumber(diag.rpc_latency_total_seconds),
            rpc_latency_max_seconds = tonumber(diag.rpc_latency_max_seconds),
            rpc_latency_mean_seconds = tonumber(diag.rpc_latency_mean_seconds),
            worker_limit = tonumber(diag.worker_limit),
            batch_limit = tonumber(diag.batch_limit),
            peak_geometry_jobs = tonumber(diag.peak_geometry_jobs),
            max_request_rate = tonumber(diag.max_request_rate),
            max_pending_limit = tonumber(diag.max_pending_limit),
            adaptive_upshifts = tonumber(diag.adaptive_upshifts),
            adaptive_downshifts = tonumber(diag.adaptive_downshifts),
            adaptive_peak_rate = tonumber(diag.adaptive_peak_rate),
            adaptive_peak_workers = tonumber(diag.adaptive_peak_workers),
            rpc_latency_ewma_seconds = tonumber(diag.rpc_latency_ewma_seconds),
            monitor_delay_ewma_seconds = tonumber(diag.monitor_delay_ewma_seconds),
            monitor_delay_max_seconds = tonumber(diag.monitor_delay_max_seconds),
            replication_peak_waiting = tonumber(diag.replication_peak_waiting),
            replication_pause_count = tonumber(diag.replication_pause_count),
            verification_budget_seconds = tonumber(diag.verification_budget_seconds),
            verification_checks_peak = tonumber(diag.verification_checks_peak),
            verification_failure_phase = safeError(diag.verification_failure_phase or ""),
            verification_failure_owned = diag.verification_failure_owned,
            verification_position_error = tonumber(diag.verification_position_error),
            verification_size_error = tonumber(diag.verification_size_error),
            verification_color_error = tonumber(diag.verification_color_error),
            verification_right_dot = tonumber(diag.verification_right_dot),
            verification_up_dot = tonumber(diag.verification_up_dot),
            verification_wait_seconds = tonumber(diag.verification_wait_seconds),
        }
        if type(diag.prep_samples) == "table" then
            report.diagnostics.prep_samples = {}
            for index = 1, math.min(#diag.prep_samples, 32) do
                local sample = diag.prep_samples[index]
                if type(sample) == "table" then
                    table.insert(report.diagnostics.prep_samples, {
                        before = tonumber(sample.before), after = tonumber(sample.after),
                        requests = tonumber(sample.requests), gain = tonumber(sample.gain),
                    })
                end
            end
        end
    end
    task.spawn(function()
        pcall(Backend.report, {
                kind = "builder_result", result = report,
                settings = { width_studs = buildPlan.width_studs, pixel_studs = buildPlan.pixel_studs,
                    block_type = buildPlan.block_type, toolMode = buildToolMode, infiniteBlocks = buildInfiniteBlocks == true,
                    sampling = buildPlan.sampling, detail = buildPlan.detail, resolution_mode = buildPlan.resolution_mode,
                    speed = buildSpeed },
        })
    end)
end
-- Observe the existing native hotbar; never replace its UI or input handlers.
local function createManualToolSelector()
    local selection = {revision = 0}
    local listeners, bound = {}, setmetatable({}, {__mode = "k"})
    local closed = false
    local boundCount = 0
    local function listen(signal, callback)
        table.insert(listeners, signal:Connect(callback))
    end
    local function visible(object, root)
        local current, inRoot = object, false
        while current do
            if current:IsA("GuiObject") and not current.Visible then return false end
            if current:IsA("ScreenGui") and not current.Enabled then return false end
            if current == root then inRoot = true end
            current = current.Parent
        end
        return inRoot
    end
    local function requestSelection(tool)
        selection = {tool = tool, revision = selection.revision + 1, available = boundCount > 0}
    end
    local function selectSlot(slot, root)
        if closed or destroyed or not building or toolMode ~= "background" or UserInputService:GetFocusedTextBox() then return end
        local menuRead, menuOpen = pcall(function() return game:GetService("GuiService").MenuIsOpen end)
        if menuRead and menuOpen then return end
        if not slot or not visible(slot, root) then return end
        local label = slot:FindFirstChild("ToolName")
        if not label or not label:IsA("TextLabel") or label.Text == "" then return end
        local chosen
        for _, container in pairs({player.Character, player:FindFirstChildOfClass("Backpack")}) do
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == label.Text then
                    if chosen and chosen ~= tool then requestSelection(nil); return end -- Clear old controls; do not guess duplicates.
                    chosen = tool
                end
            end
        end
        if not chosen then requestSelection(nil); return end
        if selection.tool == chosen then requestSelection(nil) else requestSelection(chosen) end
    end
    local ok = pcall(function()
        local core = game:GetService("CoreGui")
        local robloxGui = core:FindFirstChild("RobloxGui")
        local backpack = robloxGui and robloxGui:FindFirstChild("Backpack")
        if not backpack then return end
        local function bind(object)
            local slot = object:IsA("GuiButton") and object or object.Parent
            if not slot or not slot:IsA("GuiButton") or bound[slot] or not slot:FindFirstChild("ToolName") then return end
            bound[slot] = true
            boundCount += 1
            selection.available = true
            listen(slot.Activated, function() selectSlot(slot, backpack) end)
        end
        for _, object in ipairs(backpack:GetDescendants()) do bind(object) end
        listen(backpack.DescendantAdded, bind)
        local keySlots = {One = "1", Two = "2", Three = "3", Four = "4", Five = "5",
            Six = "6", Seven = "7", Eight = "8", Nine = "9", Zero = "10"}
        listen(UserInputService.InputBegan, function(input)
            local name = keySlots[input.KeyCode.Name]
            local hotbar = backpack:FindFirstChild("Hotbar")
            if name and hotbar then selectSlot(hotbar:FindFirstChild(name), backpack) end
        end)
    end)
    selection.available = ok and boundCount > 0
    return function() return selection end, function()
        closed = true
        for _, listener in ipairs(listeners) do listener:Disconnect() end
        table.clear(listeners)
    end
end

local function beginBuild(origin)
    if busy() or not plan then return end
    local callOK, allowed, reason = pcall(Adapter.validate, plan)
    if not callOK or not allowed then setStatus(safeError(callOK and reason or allowed), C.red); return end
    local buildPlan = plan
    local buildToolMode = toolMode
    local buildInfiniteBlocks = infiniteBlocks
    local buildSpeed = speed
    clearTool()
    building, cancelled = true, false
    resetProgress(buildInfiniteBlocks and "CHECKING MATERIAL" or "BUILDING YOUR WALL")
    UI.startedAt = os.clock()
    showBuildProgress(0, buildPlan.placement_count or buildPlan.block_count, phaseLabel.Text)
    blockMenu.Visible, speedMenu.Visible = false, false
    setStatus(buildToolMode == "compatible"
        and "Building in Compatible mode. Leave the build, scale, and paint tools alone until it finishes. Stop cancels queued work."
        or "Hands free is starting. Select a normal tool from the hotbar to use it while the image builds.")
    syncButtons()
    task.spawn(function()
        local getManualToolSelection, stopManualSelection = createManualToolSelector()
        local ok, result = pcall(Adapter.build, buildPlan, origin, {
            speed = buildSpeed,
            toolMode = buildToolMode,
            infiniteBlocks = buildInfiniteBlocks,
            getManualToolSelection = getManualToolSelection,
            shouldCancel = function() return cancelled or destroyed end,
            onProgress = function(done, total, message)
                if destroyed then return end
                local text = tostring(message or "")
                local preparing = done == 0 and (text:lower():find("prepar", 1, true) or text:lower():find("material", 1, true))
                showBuildProgress(done, total, cancelled and "STOPPING" or (preparing and "PREPARING MATERIAL" or "BUILDING YOUR WALL"))
                setStatus(text ~= "" and text or "Waiting for the next verified block...", cancelled and C.yellow or C.dim)
            end,
        })
        stopManualSelection()
        building = false
        sendTelemetry(buildPlan, ok, result, buildToolMode, buildInfiniteBlocks, buildSpeed)
        if destroyed then
            if Adapter.teardown then pcall(Adapter.teardown) end
            if ENV.ImageBuilder == api then ENV.ImageBuilder = nil end
            return
        end
        if not ok then
            phaseLabel.Text = "BUILD STOPPED"
            progressFill.BackgroundColor3 = C.yellow
            setStatus("Build stopped: " .. safeError(result), C.red)
        elseif type(result) ~= "table" then
            phaseLabel.Text = "RESULT NOT VERIFIED"
            progressFill.BackgroundColor3 = C.yellow
            setStatus("Build ended without a verified result. Check the world before trying again.", C.yellow)
        else
            showBuildProgress(result.completed, result.total or (buildPlan.placement_count or buildPlan.block_count),
                result.ok and "BUILD COMPLETE" or "BUILD STOPPED",
                type(result.diagnostics) == "table" and result.diagnostics.wall_elapsed_seconds or nil)
            progressFill.BackgroundColor3 = result.ok and C.green or C.yellow
            local diagnostics = result.diagnostics
            if result.completed == 0 and type(diagnostics) == "table" and diagnostics.infinite_requested
                and diagnostics.preparation_status == "failed" then
                progressMeta.Text = string.format("Material: %.0f available / %.0f needed  |  %d preparation rounds",
                    tonumber(diagnostics.inventory_after) or tonumber(diagnostics.inventory_before) or 0,
                    tonumber(diagnostics.material_required) or 0, tonumber(diagnostics.prep_rounds) or 0)
            end
            setStatus(string.format("%s\n%d / %d blocks completed.", tostring(result.message or (result.ok and "Build complete." or "Build stopped.")),
                tonumber(result.completed) or 0, tonumber(result.total) or (buildPlan.placement_count or buildPlan.block_count)), result.ok and C.green or C.yellow)
        end
        syncButtons()
        refreshInventory()
    end)
end
local function equipPlacementTool()
    if destroyed or busy() or not plan then return end
    local callOK, allowed, reason = pcall(Adapter.validate, plan)
    if not callOK or not allowed then setStatus(safeError(callOK and reason or allowed), C.yellow); return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local backpack = player:FindFirstChildOfClass("Backpack")
    if not humanoid or not backpack or humanoid.Health <= 0 then setStatus("Wait for your character to spawn, then select Place.", C.yellow); return end
    if placeTool then humanoid:EquipTool(placeTool); return end
    placeTool = create("Tool", { Name = "Place Image", RequiresHandle = false, CanBeDropped = false, ToolTip = "Aim the green wall. Click to build. R: 90 degrees. Q / E: 15 degrees." }, backpack)
    local activeTool = placeTool
    local previewPlan = plan
    -- Every new placement starts aligned with the world, independent of the avatar.
    -- Re-equipping an existing placement tool preserves the user's chosen rotation.
    yaw = 0
    table.insert(toolConnections, activeTool.Equipped:Connect(function()
        if busy() or destroyed or placeTool ~= activeTool then return end
        clearGhost()
        ghost = create("Part", {
            Name = "ImageWallPlacementPreview", Anchored = true, CanCollide = false,
            CanTouch = false, CanQuery = false, CastShadow = false, Locked = true,
            Transparency = 1, Material = Enum.Material.ForceField,
            Color = C.green, Size = Vector3.new(previewPlan.width_studs, previewPlan.height_studs, math.max(0.05, math.min(previewPlan.pixel_studs, 1))),
        }, Workspace)
        local outline = create("SelectionBox", { Adornee = ghost, Color3 = C.green, LineThickness = 0.035, SurfaceTransparency = 1, Visible = false }, ghost)
        local filter = RaycastParams.new()
        filter.FilterType = Enum.RaycastFilterType.Exclude
        filter.FilterDescendantsInstances = { player.Character, ghost }
        filter.IgnoreWater = false
        renderConnection = RunService.RenderStepped:Connect(function()
            if not ghost or not Workspace.CurrentCamera then return end
            local currentCharacter = player.Character
            if not currentCharacter or activeTool.Parent ~= currentCharacter then clearGhost(); return end
            filter.FilterDescendantsInstances = { currentCharacter, ghost }
            local mouse = UserInputService:GetMouseLocation()
            local ray = Workspace.CurrentCamera:ViewportPointToRay(mouse.X, mouse.Y)
            local hit = Workspace:Raycast(ray.Origin, ray.Direction * 1500, filter)
            if hit and not mouseOverPanel() then
                placement = CFrame.new(hit.Position) * CFrame.Angles(0, yaw, 0)
                placementAllowed, placementReason = true, nil
                if type(Adapter.canPlace) == "function" then
                    local ok, allowed, reason = pcall(Adapter.canPlace, previewPlan, placement)
                    placementAllowed = ok and allowed == true
                    placementReason = ok and reason or tostring(allowed)
                end
                ghost.CFrame = placement * CFrame.new(0, previewPlan.height_studs / 2, 0)
                ghost.Transparency = 0.72
                ghost.Color = placementAllowed and C.green or C.red
                outline.Color3, outline.Visible = ghost.Color, true
            else
                placement = nil
                placementAllowed = false
                ghost.Transparency = 1
                outline.Visible = false
            end
        end)
        phaseLabel.Text = "CHOOSE PLACEMENT"
        progressMeta.Text = "R: turn 90 degrees  /  Q or E: turn 15 degrees"
        setStatus("Aim to set the bottom center of the wall. The green outline follows your cursor. Click to build.", C.green)
    end))
    table.insert(toolConnections, activeTool.Unequipped:Connect(clearGhost))
    table.insert(toolConnections, activeTool.Activated:Connect(function()
        if destroyed or busy() or UserInputService:GetFocusedTextBox() or mouseOverPanel() then return end
        if not placement then setStatus("Aim at a surface outside the window first.", C.yellow); return end
        if not placementAllowed then setStatus(placementReason or "Move the whole wall inside your own build area.", C.yellow); return end
        beginBuild(placement)
    end))
    humanoid:EquipTool(activeTool)
    syncButtons()
end
connect(placeButton.Activated, equipPlacementTool)

function api.Stop()
    if destroyed then return end
    cancelled = true
    generation += 1
    clearTool()
    if busy() then
        phaseLabel.Text = "STOPPING"
        setStatus("Stopping... waiting for requests already in progress to finish.", C.yellow)
    else
        resetProgress(plan and "READY TO PLACE" or "READY TO CONVERT")
        setStatus(plan and "Placement cancelled. The converted image is still ready." or "Stopped. Convert an image when ready.", C.yellow)
    end
    syncButtons()
end
function api.Destroy()
    if destroyed then return end
    destroyed, cancelled = true, true
    generation += 1
    clearTool()
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
    gui:Destroy()
    activePreviewPath = nil
    for _, path in ipairs(table.clone(previewFiles)) do deletePreviewFile(path) end
    if not busy() then
        if Adapter.teardown then pcall(Adapter.teardown) end
        if ENV.ImageBuilder == api then ENV.ImageBuilder = nil end
    end
end
connect(stopButton.Activated, api.Stop)
connect(close.Activated, api.Destroy)
connect(minimize.Activated, function()
    UI.minimized = not UI.minimized
    blockMenu.Visible, speedMenu.Visible = false, false
    for _, object in ipairs(content) do object.Visible = not UI.minimized end
    fitPanel(true)
    minimize.Text = UI.minimized and "+" or "-"
end)
local dragStart, panelStart
connect(header.InputBegan, function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
        dragStart, panelStart = inputObject.Position, panel.Position
        blockMenu.Visible, speedMenu.Visible = false, false
    end
end)
connect(UserInputService.InputEnded, function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then dragStart = nil end
end)
connect(UserInputService.InputChanged, function(inputObject)
    if dragStart and (inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch) then
        local delta = inputObject.Position - dragStart
        local currentViewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or viewport
        panel.Position = UDim2.fromOffset(
            math.clamp(panelStart.X.Offset + delta.X, 0, math.max(0, currentViewport.X - UI.width * panelScale.Scale)),
            math.clamp(panelStart.Y.Offset + delta.Y, 0, math.max(0, currentViewport.Y - panel.Size.Y.Offset * panelScale.Scale)))
    end
end)
connect(UserInputService.InputBegan, function(inputObject, processed)
    if destroyed or processed or UserInputService:GetFocusedTextBox() then return end
    if ghost then
        local key = inputObject.KeyCode
        if key == Enum.KeyCode.R then yaw += math.rad(90)
        elseif key == Enum.KeyCode.Q then yaw -= math.rad(15)
        elseif key == Enum.KeyCode.E then yaw += math.rad(15) end
    end
end)
connect(player.CharacterRemoving, function()
    api.Stop()
    if not busy() then setStatus("Character respawned. Select Place again when ready.", C.yellow) end
end)
connect(scroll:GetPropertyChangedSignal("CanvasPosition"), function()
    blockMenu.Visible, speedMenu.Visible = false, false
end)
local viewportConnection
local function watchViewport()
    if viewportConnection then viewportConnection:Disconnect() end
    local currentCamera = Workspace.CurrentCamera
    if currentCamera then
        viewportConnection = connect(currentCamera:GetPropertyChangedSignal("ViewportSize"), function()
            blockMenu.Visible, speedMenu.Visible = false, false
            fitPanel(true)
        end)
    end
    fitPanel(true)
end
connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), watchViewport)
watchViewport()
fitPanel(false)
connect(RunService.Heartbeat, function()
    if processing and not destroyed then
        -- Indeterminate motion during conversion is not a fabricated percentage.
        progressFill.Size = UDim2.fromScale(0.24, 1)
        progressFill.Position = UDim2.fromScale((os.clock() % 1.8) / 1.8 * 1.24 - 0.24, 0)
    end
end)
syncButtons()
refreshInventory()
