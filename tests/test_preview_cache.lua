local passed = 0
local FOLDER = "baft image builder"
local function path(n) return FOLDER .. "/preview_" .. string.format("%024x", n) .. ".png" end
local function test(name, fn)
    local ok, message = pcall(fn)
    assert(ok, name .. ": " .. tostring(message))
    passed += 1
end

local function context(options)
    options = options or {}
    local files, removed, saves, jobs, images = {}, {}, {}, {}, {}
    local journal = options.journal or {}
    for _, name in ipairs(options.existing or {}) do files[name] = "existing" end
    local pendingPreview = "\137PNG\13\10\26\10payload"
    local decodeCalls, peak, assetCalls = 0, 0, 0
    local now = 0
    local os = {clock = function() return now end}
    local Backend = {}
    local function countFiles()
        local count = 0
        for name in pairs(files) do if name:match("/preview_.*%.png$") then count += 1 end end
        return count
    end
    local function readfile(name)
        assert(name == FOLDER .. "/previews.json")
        if options.readFailure then error("read failed") end
        return options.oversized and string.rep("x", 1025) or files[name] or "mock journal"
    end
    local function writefile(name, value)
        if options.journalWriteFailure and name == FOLDER .. "/previews.json" then error("journal write failed") end
        if options.journalCorrupt and name == FOLDER .. "/previews.json" then value = "corrupt journal" end
        if options.imageWriteFailure and name:match("%.png$") then files[name] = "partial"; error("partial image write") end
        files[name] = value
        peak = math.max(peak, countFiles())
    end
    local delfile = if options.noDelete then nil else function(name)
        table.insert(removed, name)
        if options.deleteFailure then error("delete failed") end
        if files[name] == nil then error("missing file") end
        files[name] = nil
    end
    local function isfile(name) return files[name] ~= nil end
    local function isfolder() return true end
    local function makefolder() error("already exists") end
    local HttpService = {
        JSONDecode = function(_, contents)
            decodeCalls += 1
            if options.invalidJSON then error("invalid JSON") end
            return table.clone(journal)
        end,
        JSONEncode = function(_, values)
            journal = table.clone(values)
            table.insert(saves, table.clone(values))
            return "encoded journal"
        end,
    }
    --[[JOURNAL]]
    Backend.preview = function() return pendingPreview end
    local previewFiles, activePreviewPath = Backend.previewFiles(), nil
    local api, ENV = {}, {}
    ENV.ImageBuilder = api
    local destroyed, generation, plan = false, 0, nil
    local preview, previewEmpty, thumbnailCaption = {}, {}, {}
    local UI, UDim2, Enum = {}, {}, {ScaleType = {Fit = 1}}
    UDim2.fromOffset = function() return {} end
    UDim2.fromScale = UDim2.fromOffset
    local getcustomasset = function(name) assetCalls += 1; return "asset:" .. name end
    local function create(_, properties, parent)
        local object = properties
        object.Parent = parent
        object.IsLoaded = not options.pendingImage
        function object:Destroy() self.destroyed = true; self.Parent = nil end
        table.insert(images, object)
        return object
    end
    local function clearPreview()
        activePreviewPath = nil
        for _, image in ipairs(images) do if image.Parent == preview then image:Destroy() end end
    end
    local function resume(job)
        local ok, err = coroutine.resume(job)
        assert(ok, tostring(err))
    end
    local task = {
        spawn = function(fn)
            local job = coroutine.create(fn)
            table.insert(jobs, job)
            resume(job)
        end,
        wait = function(delay) now += delay or 0.01; coroutine.yield() end,
    }
    --[[PREVIEW]]
    return {
        files = files, removed = removed, saves = saves, images = images,
        loadedJournal = function() return Backend.previewFiles() end,
        saveJournal = Backend.savePreviewFiles,
        stats = function() return {peak = peak, count = countFiles(), assets = assetCalls,
            decoded = decodeCalls, tracked = #previewFiles, active = activePreviewPath} end,
        load = function(n, pending)
            generation += 1
            plan = {id = string.format("%024x", n)}
            clearPreview()
            options.pendingImage = pending == true
            loadNativePreview(plan, generation)
            return jobs[#jobs]
        end,
        resume = resume,
        replace = function() destroyed = true; generation += 1; ENV.ImageBuilder = {} end,
    }
end

test("journal rejects traversal and unrelated files", function()
    local foreign = "outside/keep.png"
    local ctx = context({journal = {
        "../keep.png", "baft image builder/../keep.png", foreign,
        "baft image builder/preview_" .. string.rep("a", 23) .. ".png",
        "baft image builder/preview_" .. string.rep("a", 24) .. ".png/../keep",
        "baft image builder\\preview_" .. string.rep("a", 24) .. ".png",
        path(1), path(1), path(2), path(3), path(4),
    }, existing = {foreign, path(1), path(2), path(3)}})
    assert(#ctx.removed == 3 and ctx.files[foreign] == "existing")
    for _, removed in ipairs(ctx.removed) do assert(removed == path(1) or removed == path(2) or removed == path(3)) end
end)

test("oversized and malformed journals are ignored", function()
    for _, option in ipairs({"oversized", "invalidJSON", "readFailure"}) do
        local ctx = context({[option] = true, journal = {path(1)}, existing = {path(1)}})
        assert(#ctx.removed == 0 and ctx.files[path(1)] == "existing")
        if option == "oversized" then assert(ctx.stats().decoded == 0) end
    end
end)

test("journal serialization only stores bounded validated paths", function()
    local ctx = context()
    ctx.saveJournal({"../outside", path(1), path(2), path(3), path(4)})
    local saved = ctx.saves[#ctx.saves]
    assert(#saved == 3 and saved[1] == path(1) and saved[3] == path(3))
end)

test("successive native previews never exceed three files", function()
    local ctx = context()
    for n = 1, 8 do
        ctx.load(n)
        assert(ctx.files[path(n)] ~= nil and ctx.stats().active == path(n))
    end
    assert(ctx.stats().peak <= 3 and ctx.stats().count <= 3 and ctx.stats().assets == 8)
end)

test("stale generation only deletes its own unique path", function()
    local ctx = context()
    local old = ctx.load(1, true)
    ctx.load(2, false)
    ctx.resume(old)
    assert(ctx.files[path(1)] == nil and ctx.files[path(2)] ~= nil)
    assert(ctx.stats().active == path(2) and ctx.images[2].destroyed ~= true)
end)

test("obsolete loader cleanup cannot overwrite the replacement journal", function()
    local ctx = context()
    local old = ctx.load(1, true)
    local saves = #ctx.saves
    ctx.replace()
    ctx.resume(old)
    assert(#ctx.saves == saves and ctx.files[path(1)] == nil)
end)

test("no delfile keeps the coarse preview without writing image files", function()
    local ctx = context({noDelete = true})
    ctx.load(1)
    assert(ctx.stats().count == 0 and ctx.stats().assets == 0)
end)

test("missing persisted files do not block fresh native previews", function()
    local ctx = context({journal = {path(1), path(2), path(3)}})
    ctx.load(4)
    assert(ctx.stats().tracked == 1 and ctx.stats().active == path(4))
end)

test("failed deletions preserve the three-file bound", function()
    local ctx = context({deleteFailure = true, journal = {path(1), path(2), path(3)},
        existing = {path(1), path(2), path(3)}})
    ctx.load(4)
    assert(ctx.stats().count == 3 and ctx.files[path(4)] == nil and ctx.stats().assets == 0)
end)

test("failed or unverified journal reservation never writes a PNG", function()
    for _, option in ipairs({"journalWriteFailure", "journalCorrupt", "readFailure"}) do
        local ctx = context({[option] = true})
        ctx.load(1)
        assert(ctx.stats().count == 0 and ctx.stats().assets == 0 and ctx.stats().tracked == 0)
    end
end)

test("partial image write is removed or remains tracked for cleanup", function()
    local ctx = context({imageWriteFailure = true})
    ctx.load(1)
    assert(ctx.files[path(1)] == nil and ctx.stats().tracked == 0)
    local blocked = context({imageWriteFailure = true, deleteFailure = true})
    for n = 1, 5 do blocked.load(n) end
    assert(blocked.stats().count == 3 and blocked.stats().tracked == 3 and blocked.stats().assets == 0)
end)

print("PREVIEW_CACHE_CASES " .. passed)
