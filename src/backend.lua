-- Image bytes are data only. All decoding and planning happen locally.
local Decoder = __IMAGE_DECODER__
local Planner = __IMAGE_PLANNER__
local Backend = {}
local FOLDER = "baft image builder"
local HttpService = game:GetService("HttpService")
local function firstFunction(...)
    for index = 1, select("#", ...) do
        local value = select(index, ...)
        if type(value) == "function" then return value end
    end
end
local send = firstFunction(request, http_request,
    type(syn) == "table" and syn.request, type(http) == "table" and http.request)
local imageRequestPending = false
local previewID, previewBytes
local MAX_BYTES = 10 * 1024 * 1024

function Backend.available()
    if type(send) ~= "function" then return false, "This executor needs an HTTP request function." end
    if type(buffer) ~= "table" or type(buffer.create) ~= "function" then return false, "This executor needs Luau buffer support." end
    if imageRequestPending then return false, "The previous image download is still finishing. Try again shortly." end
    return true
end

local function download(url, checkpoint)
    if type(url) ~= "string" or #url > 4096 or not url:match("^https?://[^%s]+$") then
        error("Paste a direct http:// or https:// image link.", 0)
    end
    local authority = url:match("^https?://([^/?#]+)")
    if not authority or authority:find("@", 1, true) then error("Image links with embedded credentials are not supported.", 0) end
    if imageRequestPending then error("A previous image download is still finishing.", 0) end
    imageRequestPending = true
    local finished, ok, response = false, false, nil
    task.spawn(function()
        ok, response = pcall(send, {
            Url = url, Method = "GET", Timeout = 25,
            Headers = {Accept = "image/png, image/jpeg;q=0.9"},
        })
        imageRequestPending, finished = false, true
    end)
    local deadline = os.clock() + 30
    while not finished do
        checkpoint()
        if os.clock() >= deadline then error("Image download timed out. Try a smaller direct image link.", 0) end
        task.wait(0.05)
    end
    checkpoint()
    if not ok or type(response) ~= "table" then error("Could not download the image. Check the direct image link.", 0) end
    local status = tonumber(response.StatusCode) or tonumber(response.Status) or tonumber(response.status_code) or 0
    if status < 200 or status >= 300 then error("Image download returned HTTP " .. status .. ". Use a direct PNG or JPEG link.", 0) end
    local bytes = type(response.Body) == "string" and response.Body or response.body
    if type(bytes) ~= "string" or #bytes == 0 then error("The image download was empty.", 0) end
    if #bytes > MAX_BYTES then error("Image is larger than 10 MiB. Use a smaller source image.", 0) end
    return bytes
end

function Backend.convert(settings, hooks)
    hooks = hooks or {}
    local lastYield = os.clock()
    local function checkpoint()
        if hooks.checkCancelled then hooks.checkCancelled() end
        if os.clock() - lastYield >= 0.006 then
            task.wait()
            lastYield = os.clock()
            if hooks.checkCancelled then hooks.checkCancelled() end
        end
    end
    local function progress(message)
        checkpoint()
        if hooks.progress then hooks.progress(message) end
    end
    previewID, previewBytes = nil, nil
    progress("Downloading image...")
    local bytes = download(settings.image_url, checkpoint)
    progress("Decoding image locally...")
    local width, height, rgba = Decoder.decode(bytes, {checkpoint = checkpoint})
    checkpoint()
    -- One bounded source cache; filenames never come from URLs or response headers.
    if type(writefile) == "function" then pcall(writefile, FOLDER .. "/source_image.bin", bytes) end
    bytes = nil
    progress("Resizing and planning blocks locally...")
    local plan, preview = Planner.convertRGBA(width, height, rgba, settings, {
        yield = checkpoint, checkCancelled = checkpoint,
        onProgress = function(message) progress(tostring(message) .. "...") end,
    })
    rgba = nil
    checkpoint()
    plan.id = HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 24):lower()
    if preview then
        progress("Preparing preview...")
        local w, h, pixels = preview.width, preview.height, preview.rgba
        if math.max(w, h) > 256 then
            local ratio = 256 / math.max(w, h)
            local pw, ph = math.max(1, math.floor(w * ratio)), math.max(1, math.floor(h * ratio))
            local reduced = buffer.create(pw * ph * 4)
            for y = 0, ph - 1 do
                for x = 0, pw - 1 do
                    local sx = math.min(w - 1, math.floor((x + 0.5) * w / pw))
                    local sy = math.min(h - 1, math.floor((y + 0.5) * h / ph))
                    buffer.copy(reduced, (y * pw + x) * 4, pixels, (sy * w + sx) * 4, 4)
                end
                checkpoint()
            end
            w, h, pixels = pw, ph, reduced
        end
        -- A preview failure must not discard a usable build plan.
        local ok, encoded = pcall(Decoder.encodePreview, w, h, pixels, {checkpoint = checkpoint})
        checkpoint()
        if ok and type(encoded) == "string" and #encoded <= 4 * 1024 * 1024 then
            previewID, previewBytes = plan.id, encoded
        end
    end
    return plan
end

function Backend.preview(id)
    return id == previewID and previewBytes or nil
end

local function validPreviewPath(path)
    if type(path) ~= "string" then return false end
    local id = path:match("^baft image builder/preview_([0-9a-f]+)%.png$")
    return id ~= nil and #id == 24
end
function Backend.previewFiles()
    if type(readfile) ~= "function" then return {} end
    local ok, decoded = pcall(function()
        local contents = readfile(FOLDER .. "/previews.json")
        if type(contents) ~= "string" or #contents > 1024 then return {} end
        return HttpService:JSONDecode(contents)
    end)
    local result = {}
    if ok and type(decoded) == "table" then
        for _, path in ipairs(decoded) do
            if #result >= 3 then break end
            if validPreviewPath(path) and not table.find(result, path) then table.insert(result, path) end
        end
    end
    return result
end
function Backend.savePreviewFiles(paths)
    if type(writefile) ~= "function" or type(readfile) ~= "function" then return false end
    local result = {}
    for _, path in ipairs(paths) do
        if #result >= 3 then break end
        if validPreviewPath(path) then table.insert(result, path) end
    end
    local encoded = HttpService:JSONEncode(result)
    local ok, verified = pcall(function()
        writefile(FOLDER .. "/previews.json", encoded)
        return readfile(FOLDER .. "/previews.json") == encoded
    end)
    return ok and verified
end

function Backend.report(report)
    -- Bounded local diagnostics only: no server, URLs, account IDs, or game-job IDs.
    if type(writefile) ~= "function" then return end
    local encoded = HttpService:JSONEncode(report)
    if #encoded <= 128 * 1024 then writefile(FOLDER .. "/last-report.json", encoded) end
end
return Backend
