-- BAFT Image Builder bootstrap. Downloads only this repository's versioned bundle.
local ROOT = "https://raw.githubusercontent.com/datadaniklan/script-rb/main/"
local FOLDER = "baft image builder"
local MAX_SOURCE = 3 * 1024 * 1024
local env = (getgenv and getgenv()) or _G
if env.BAFTImageLoaderBusy then warn("Image Builder is already loading."); return end
env.BAFTImageLoaderBusy = true

local ok, failure = pcall(function()
    local send = (syn and syn.request) or request or http_request or (http and http.request)
    assert(type(send) == "function", "An executor HTTP request function is required.")
    assert(type(loadstring) == "function" and type(readfile) == "function" and type(writefile) == "function"
        and type(makefolder) == "function" and type(isfolder) == "function",
        "This executor needs loadstring, readfile, writefile, makefolder, and isfolder.")
    assert(type(buffer) == "table" and type(buffer.create) == "function", "Luau buffer support is required.")
    local function get(path, maximum)
        local response = send({Url = ROOT .. path, Method = "GET", Timeout = 30})
        assert(type(response) == "table", "GitHub did not return a response.")
        local status = tonumber(response.StatusCode or response.Status or response.status_code) or 0
        assert(status == 200, "GitHub download failed (HTTP " .. status .. "). Try again later.")
        local body = response.Body or response.body
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
    if not isfolder(FOLDER) then makefolder(FOLDER) end
    assert(isfolder(FOLDER), "Could not create the baft image builder workspace folder.")
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
