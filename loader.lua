-- BAFT Image Builder bootstrap. Downloads only this repository's versioned bundle.
local ROOT = "https://raw.githubusercontent.com/datadaniklan/script-rb/main/"
-- Relative to the current executor's workspace; never a Wave/Windows path.
local FOLDER = "baft image builder"
local MAX_SOURCE = 3 * 1024 * 1024
local env = (getgenv and getgenv()) or _G
if env.BAFTImageLoaderBusy then warn("Image Builder is already loading."); return end
env.BAFTImageLoaderBusy = true

local ok, failure = pcall(function()
    local function firstFunction(...)
        for index = 1, select("#", ...) do
            local value = select(index, ...)
            if type(value) == "function" then return value end
        end
    end
    local send = firstFunction(request, http_request,
        type(syn) == "table" and syn.request, type(http) == "table" and http.request)
    assert(send, "This executor needs request, http_request, syn.request, or http.request.")
    assert(type(loadstring) == "function" and type(readfile) == "function" and type(writefile) == "function",
        "This executor needs loadstring and workspace readfile and writefile functions.")
    assert(type(buffer) == "table" and type(buffer.create) == "function", "Luau buffer support is required.")
    -- Some executors omit isfolder or throw when makefolder finds an existing
    -- folder. Verify the real filesystem operation instead of testing a brand.
    local exists = false
    if type(isfolder) == "function" then
        local checked, found = pcall(isfolder, FOLDER)
        exists = checked and found == true
    end
    if not exists and type(makefolder) == "function" then pcall(makefolder, FOLDER) end
    local probe = FOLDER .. "/workspace-check.txt"
    local marker = "BAFT Image Builder workspace check\n"
    local writable, verified = pcall(function()
        writefile(probe, marker)
        return readfile(probe) == marker
    end)
    assert(writable and verified, "Cannot write and read 'baft image builder' in this executor's workspace. Check its file-access support.")
    if type(delfile) == "function" then pcall(delfile, probe) end
    local function get(path, maximum)
        local response = send({Url = ROOT .. path, Method = "GET", Timeout = 30})
        assert(type(response) == "table", "GitHub did not return a response.")
        local status = tonumber(response.StatusCode) or tonumber(response.Status) or tonumber(response.status_code) or 0
        assert(status == 200, "GitHub download failed (HTTP " .. status .. "). Try again later.")
        local body = type(response.Body) == "string" and response.Body or response.body
        assert(type(body) == "string" and #body > 0 and #body <= maximum, "Empty or oversized GitHub response.")
        return body
    end
    local HttpService = game:GetService("HttpService")
    local manifest = HttpService:JSONDecode(get("manifest.json", 4096))
    assert(type(manifest) == "table" and manifest.format == 1, "Unsupported release manifest.")
    local build = manifest.build
    assert(type(build) == "string" and #build == 20 and build:match("^[0-9a-f]+$"), "Invalid release identifier.")
    assert(type(manifest.bytes) == "number" and manifest.bytes % 1 == 0
        and manifest.bytes > 0 and manifest.bytes <= MAX_SOURCE, "Invalid bundle size.")
    local source = get("dist/builder_" .. build .. ".lua", MAX_SOURCE)
    assert(#source == manifest.bytes,
        "Bundle does not match the release manifest.")
    assert(source:match("^%-%- BAFT Image Builder release ([0-9a-f]+)\n") == build, "Bundle release mismatch.")
    local run, syntaxError = loadstring(source, "BAFTImageBuilder/" .. build)
    assert(run, "Downloaded bundle did not compile: " .. tostring(syntaxError))
    local activeOK, active = pcall(readfile, FOLDER .. "/active.txt")
    local previousSlot = activeOK and (active == "a" or active == "b") and active or nil
    local nextSlot = previousSlot == "a" and "b" or "a"
    local candidate = FOLDER .. "/builder_" .. nextSlot .. ".lua"
    writefile(candidate, source)
    assert(readfile(candidate) == source, "Downloaded cache could not be verified; existing cache was preserved.")
    writefile(FOLDER .. "/start.lua", 'loadstring(game:HttpGet("' .. ROOT .. 'loader.lua"))()\n')
    writefile(FOLDER .. "/active.txt", nextSlot)
    assert(readfile(FOLDER .. "/active.txt") == nextSlot, "Could not verify the active cache index.")
    local ran, runtimeError = pcall(run)
    if not ran then
        if previousSlot then pcall(writefile, FOLDER .. "/active.txt", previousSlot) end
        error("Builder could not start: " .. tostring(runtimeError), 0)
    end
end)
env.BAFTImageLoaderBusy = nil
if not ok then
    local message = "Image Builder: " .. tostring(failure):sub(1, 700)
    warn(message)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Image Builder could not load", Text = message:sub(1, 220), Duration = 12,
        })
    end)
    error(message, 0)
end
