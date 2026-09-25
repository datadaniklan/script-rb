local count = 0
local function scenario(options)
    options = options or {}
    local files, decoded, converted, requests, cancelled = {}, false, false, 0, false
    local task = {spawn = function(fn) fn() end, wait = function() end}
    local function request(data)
        requests += 1
        assert(data.Method == "GET" and data.Headers.Authorization == nil)
        if options.cancel then cancelled = true end
        if options.http then return {StatusCode = 403, Body = "html"} end
        return {StatusCode = 200, Body = options.empty and "" or options.oversize and string.rep("x", 10 * 1024 * 1024 + 1) or "valid-image-bytes"}
    end
    local function writefile(path, value) files[path] = value end
    local game = {GetService = function()
        return {GenerateGUID = function() return "12345678-1234-1234-1234-123456789abc" end,
            JSONEncode = function(_, value) return "safe-local-report" end}
    end}
    local TestDecoder = {
        decode = function(bytes, hooks)
            decoded = true
            assert(bytes == "valid-image-bytes")
            hooks.checkpoint()
            return 1, 1, buffer.create(4)
        end,
        encodePreview = function(w, h, rgba, hooks)
            hooks.checkpoint()
            if options.preview then error("preview failed") end
            return "png-preview"
        end,
    }
    local TestPlanner = {convertRGBA = function(w, h, rgba, settings, hooks)
        converted = true
        hooks.yield()
        return {columns = 1, rows = 1}, {width = 1, height = 1, rgba = rgba}
    end}
    local Backend = (function()
        --[[BACKEND]]
    end)()
    local ok, plan = pcall(Backend.convert, {image_url = options.url or "https://images.example/test.png"}, {
        checkCancelled = function() if cancelled then error("cancelled") end end,
    })
    if options.http or options.empty or options.oversize or options.cancel or options.url then
        assert(not ok and not decoded and not converted)
    else
        assert(ok and decoded and converted and #plan.id == 24)
        if options.preview then assert(Backend.preview(plan.id) == nil)
        else assert(Backend.preview(plan.id) == "png-preview") end
        assert(Backend.preview("other") == nil)
        assert(files["baft image builder/source_image.bin"] == "valid-image-bytes")
        Backend.report({result = {ok = true}})
        assert(files["baft image builder/last-report.json"] == "safe-local-report")
    end
    assert(requests <= 1, "Must never send diagnostics or retries to an external server")
    count += 1
end
scenario({})
for _, option in ipairs({"http", "empty", "oversize", "cancel", "preview"}) do scenario({[option] = true}) end
scenario({url = "https://user:secret@images.example/test.png"})
scenario({url = "javascript:alert(1)"})
print("BACKEND_TESTS_PASSED " .. count)
