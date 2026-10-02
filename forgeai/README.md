# AI Build by Notascripter

This is the older ForgeAI distribution folder. The current project, instructions, server updates, and feature checklist are in [AI-Build-Notascripter](https://github.com/datadaniklan/AI-Build-Notascripter).

The `loader.lua` in this folder now forwards to the current canonical loader. Existing chats and settings stay in the same executor workspace folder.

Use this current one-line launcher:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/datadaniklan/AI-Build-Notascripter/main/loader.lua?ai_build_refresh="..game:GetService("HttpService"):GenerateGUID(false)))()
```

Use the current project's server package and setup instructions; the other files retained in this legacy folder describe the old 0.1.0 preview.

The current release discloses service presence and optional AI/public-chat sharing before opening. Review the switches there; saved Off choices remain Off. See the current README for the full behavior and limits.
