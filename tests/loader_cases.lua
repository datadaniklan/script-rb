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
    local urls, executed, warning, paths = {}, false, nil, {}
    local function getgenv() return env end
    local function warn(message) warning = message end
    local function request(optionsHTTP)
        table.insert(urls, optionsHTTP.Url)
        if options.throw then error("network failed") end
        if options.http then return {StatusCode = 404, Body = "not found"} end
        local body = #urls == 1 and "manifest" or source
        if options.responseVariant then return {Status = "OK", status_code = "200", Body = false, body = body} end
        return {StatusCode = 200, Body = body}
    end
    local http_request, syn, http
    if options.alias == "http_request" then http_request, request = request, "not callable"
    elseif options.alias == "syn.request" then syn, request = {request = request}, false
    elseif options.alias == "http.request" then http, request = {request = request}, nil end
    if options.badNamespaces then syn, http = true, 42 end
    local function isfolder(_) return true end
    if options.noIsfolder then isfolder = nil end
    if options.badIsfolder then isfolder = function() error("unsupported") end end
    local function makefolder(_)
        if options.alreadyExists then error("already exists") end
    end
    if options.noMakefolder then makefolder = nil end
    local function readfile(path)
        assert(path:sub(1,19) == "baft image builder/", "path must be executor-relative")
        if options.probeCorrupt and path:match("workspace%-check") then return "corrupt" end
        if options.corrupt and path:match("builder_b") then return "truncated" end
        assert(files[path], "not found")
        return files[path]
    end
    local function writefile(path, contents)
        assert(path:sub(1,19) == "baft image builder/", "path must be executor-relative")
        table.insert(paths, (options.workspace or "executor-workspace") .. "/" .. path)
        if options.denied then error("workspace is read only") end
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
    return {ok = ok, err = err, files = files, executed = executed, env = env, urls = urls, warning = warning, paths = paths}
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
for _, alias in ipairs({"http_request", "syn.request", "http.request"}) do
    check(alias, {alias = alias}, function(r) assert(r.ok and r.executed and #r.urls == 2) end)
end
check("invalid namespace values", {badNamespaces = true}, function(r) assert(r.ok and r.executed) end)
for _, options in ipairs({{noIsfolder = true}, {noIsfolder = true, alreadyExists = true}, {badIsfolder = true},
    {noMakefolder = true, noIsfolder = true}}) do
    check("filesystem capability fallback", options, function(r) assert(r.ok and r.executed) end)
end
check("HTTP response field variants", {responseVariant = true}, function(r) assert(r.ok and r.executed) end)
for _, options in ipairs({{denied = true}, {probeCorrupt = true}}) do
    check("unusable workspace", options, function(r)
        assert(not r.ok and not r.executed and #r.urls == 0)
        assert(r.files["baft image builder/active.txt"] == "a")
    end)
end
for _, root in ipairs({"ExecutorOne/Workspace", "D:/PortableExecutor/Files", "/storage/emulated/0/Executor/workspace"}) do
    check("executor owns root", {workspace = root}, function(r)
        assert(r.ok and r.executed and #r.paths > 0)
        local prefix = root .. "/baft image builder/"
        for _, path in ipairs(r.paths) do assert(path:sub(1, #prefix) == prefix) end
    end)
end
print("LOADER_TESTS_PASSED " .. count)
