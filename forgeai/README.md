# ForgeAI — AI Build

A chat workspace for building on your own Build A Boat For Treasure plot.

**Preview 0.1.0.** The HTTPS service at `https://r.eggsmp.gg/forgeai` is online. On October 2, 2026, a real GPT-5.5 request returned a valid one-block test plan and decremented the server allowance from 10 to 9. No game placement was performed by that test. Offline client checks have passed; the new client still needs a live Roblox visual and build acceptance check before general promotion.

## Start

Run this single line in an executor with HTTP requests, `loadstring`, and workspace file access:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/datadaniklan/script-rb/main/forgeai/loader.lua"))()
```

Choose **Free**, choose **GPT-5.5**, then continue. Premium and additional models are marked unavailable. Once the service is connected, describe your build, review the assistant's proposed stage, and choose **Build plan**.

## Included

- A dark workspace with chats, saved blueprints, editable memory, and persistent settings.
- GPT-5.5 through the operator's HTTPS relay. The OpenAI key stays on that server.
- Ten free accepted AI requests per 48-hour window, with a reset countdown.
- Build progress and a measured estimate for the current stage after enough work has completed.
- Bounded building, resizing, painting, sign text, property changes, and supported connections.
- A Stop button. Work already submitted to the game may finish; completed parts remain.
- Optional automatic building after a valid AI plan. It starts off.

Requests make useful stages of up to 100 new blocks, 100 edits, and 200 connections. Larger projects need multiple stages. ForgeAI checks the current plot, block inventory, target identity, and supported operations before dispatch. It does not execute model-generated Lua.

## Saving and loading

Chats, settings, memory, and blueprints are stored in the executor's `forgeai` workspace folder. Each Roblox user gets a separate two-file journal with readback checks and recovery from the last valid copy. Keep that folder to retain your data. Turning off remembered chats excludes them from subsequent disk saves; chat contents can still exist in the recovery copy until both journal slots have been replaced.

**Save blueprint stores a build plan, not a native Roblox save slot or a copy of the whole plot.** Load blueprint opens that plan for review. Build plan then applies it. A blueprint that modifies existing parts requires those parts to remain uniquely identifiable at their saved position, rotation, and size; otherwise ForgeAI asks for a fresh plan. Use the game's own Save menu to preserve the complete in-game build.

Settings include autosave, remembered chats, AI memory, automatic building, reduced motion, UI scale, reasoning effort, and output size. The local files and cached loader contain no shared API credential.

## Allowance and privacy

The server, rather than an editable local file, counts requests. A request counts once when accepted for forwarding to OpenAI, including an accepted request that later fails. Local chat switching, saving, and loading blueprints do not spend prompts. Busy, invalid, and unavailable-premium requests do not spend prompts.

This preview uses a supplied Roblox user ID plus a shared-network quota guard. It does **not** authenticate Roblox account ownership. Users sharing one public IP share the network allowance; changing both the claimed ID and network can evade that guard. A strict account-based allowance needs a verified sign-in flow. The operator also has a global daily request ceiling and a concurrency limit.

For each AI request, the recent conversation, enabled memory, and a bounded description of your plot and inventory pass through the relay to OpenAI. The relay does not save chats to disk. It stores hashed quota identifiers and request receipts, and briefly caches successful replies in memory. OpenAI requests use `store: false`. Infrastructure providers may keep their own operational logs. Avoid including private information in build prompts.

## Operator setup

See [SERVER_SETUP.md](SERVER_SETUP.md) for the small Node.js service and Linux HTTPS configuration. The expected base address is already in `config.json`; update its status after the real service passes its checks. The public loader stays the same.

The client bundle is obfuscated to obscure its source. Obfuscation is reversible and is not encryption or protection for secrets. API keys are held only by the server.

## Known verification limits

Offline tests cover storage recovery, UI callbacks, plan validation, target remapping, cancellation, quota persistence, idempotency, and release compilation. They do not establish executor compatibility, live placement correctness, visual layout in Roblox, or the operator's OpenAI account access. Live acceptance is still required before promoting this preview as a finished service.
