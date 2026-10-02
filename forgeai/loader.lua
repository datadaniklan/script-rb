-- Compatibility entrypoint for older AI Build / ForgeAI loader URLs.
-- Always fetch the current canonical launcher. Existing saved data is retained.
local http=game:GetService("HttpService")
local nonce=tostring(http:GenerateGUID(false)):gsub("[^%w%-]","")
assert(#nonce>=16 and #nonce<=80,"Could not create a fresh launcher request.")
local source=game:HttpGet("https://raw.githubusercontent.com/datadaniklan/AI-Build-Notascripter/main/loader.lua?ai_build_refresh="..nonce)
assert(type(source)=="string" and #source>0 and #source<=128*1024,"Invalid AI Build launcher download.")
local run=loadstring(source,"AI Build launcher")
assert(run,"AI Build launcher did not compile.")
return run()
