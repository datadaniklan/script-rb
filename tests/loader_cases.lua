local actualLoadstring = loadstring
local function runCase(options)
    options = options or {}
    local build = string.rep("a", 20)
    local source = "-- BAFT Image Builder release " .. build .. "\nreturn true"
    if options.syntax then source ..= "\nlocal = ?" end
    local files = {["baft image builder/active.txt"] = "a", ["baft image builder/builder_a.lua"] = "previous-good-cache"}
    local manifest = {format = 1, build = build, bytes = #source}
    if options.manifest then manifest.build = "../../bad" end
    if options.size then manifest.bytes += 1 end
    local env = {BAFTImageLoaderBusy = options.busy}
    local urls, executed, warning = {}, false, nil
    local function getgenv() return env end
    local function warn(message) warning = message end
    local function request(optionsHTTP)
        table.insert(urls, optionsHTTP.Url)
        if options.throw then error("network failed") end
        if options.http then return {StatusCode = 404, Body = "not found"} end
        return {StatusCode = 200, Body = #urls == 1 and "manifest" or source}
    end
    local function isfolder(_) return true end
    local function makefolder(_) end
    local function readfile(path)
        if options.corrupt and path:match("builder_b") then return "truncated" end
        assert(files[path], "not found")
        return files[path]
    end
    local function writefile(path, contents)
        if options.disk and path:match("builder_b") then error("disk full") end
        files[path] = contents
    end
    local function loadstring(text, name)
        local fn, err = actualLoadstring(text, name)
        if not fn then return nil, err end
        return function()
            executed = true
            if options.runtime then error("runtime failed") end
            return fn()
        end
    end
    local game = {GetService = function(_, name)
        if name == "HttpService" then return {JSONDecode = function(_, _) return manifest end} end
        return {SetCore = function() end}
    end}
    local ok, err = pcall(function()
        --[[LOADER]]
    end)
    return {ok = ok, err = err, files = files, executed = executed, env = env, urls = urls, warning = warning}
end
local count = 0
local function check(name, options, fn)
    local r = runCase(options)
    assert(r.files["baft image builder/builder_a.lua"] == "previous-good-cache", name .. ": active cache overwritten")
    fn(r)
    count += 1
end
check("fresh release", {}, function(r)
    assert(r.ok and r.executed and #r.urls == 2)
    assert(r.files["baft image builder/active.txt"] == "b")
    assert(r.files["baft image builder/start.lua"]:find("datadaniklan/script-rb/main/loader.lua", 1, true))
    assert(r.env.BAFTImageLoaderBusy == nil)
end)
for _, name in ipairs({"syntax", "manifest", "size", "throw", "http", "corrupt", "disk"}) do
    check(name, {[name] = true}, function(r)
        assert(not r.ok and not r.executed and r.warning)
        assert(r.files["baft image builder/active.txt"] == "a")
        assert(r.env.BAFTImageLoaderBusy == nil)
    end)
end
check("runtime failure", {runtime = true}, function(r)
    assert(not r.ok and r.executed and r.files["baft image builder/active.txt"] == "a")
end)
check("duplicate loader", {busy = true}, function(r)
    assert(r.ok and not r.executed and #r.urls == 0 and r.warning)
end)
print("LOADER_TESTS_PASSED " .. count)
