-- BAFT Image Builder release 60964b2d81616f4c6d0a
--[==[
Third-party notices

BAFT Image Builder license
MIT License

Copyright (c) 2026 datadaniklan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Separately attributed third-party components retain their own licenses.
See src/vendor for the MIT PNG decoder and Apache-2.0 JPEG decoder notices.


vendor/png-luau.LICENSE
The MIT License (MIT)

Copyright (c) 2025 sircfenner

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


vendor/jpeg-js/NOTICE.txt
JPEG decoder attribution

The pure-Luau decoder in ../../local_jpeg_decoder.lua adapts the entropy
decoder and progressive JPEG state machine from jpeg-js/lib/decoder.js.

Upstream: https://github.com/jpeg-js/jpeg-js
Pinned commit: 1031ccd7a63c641c16afb2430279d1598530a85c
Source file: lib/decoder.js

Copyright 2011 notmasteryet
Licensed under the Apache License, Version 2.0.
The full license is included as LICENSE-APACHE-2.0.txt.

The upstream repository also includes a BSD license:
Copyright (c) 2014, Eugene Ware. All rights reserved.
Its complete notice and terms are retained in LICENSE-UPSTREAM-BSD.txt.

The port is modified from the upstream JavaScript: strict bounds and format
validation, flat Luau buffers, canonical Huffman decoding, a separable
floating-point inverse DCT, cooperative checkpoints, EXIF orientation,
and RGBA output. It contains no runtime networking or downloaded code.

Supported: 8-bit Huffman baseline, extended sequential, and progressive
single-frame JPEG; grayscale, YCbCr and RGB; common chroma subsampling;
restart markers; EXIF orientation values 1-8.

Unsupported formats are rejected: CMYK/YCCK, arithmetic coding, lossless
JPEG, precision other than 8 bits, and changes to a component's active
quantization table. ICC profiles are not applied. Chroma upsampling is
nearest-neighbor, so subsampled color edges can differ from Pillow/libjpeg's
smoothed output. Images without EXIF orientation keep their encoded layout.

Limits: 10 MiB compressed input, 4096 pixels per axis, 4194304 pixels total,
96 MiB explicitly accounted input/coefficient/sample/output storage,
96 scans, 2048 markers, 256 total Huffman/quantization table definitions,
and 134217728 coefficient-work units.
These limits can reject unusually complex otherwise-valid JPEG files.
Small tables and interpreter/runtime overhead are additional to the
explicitly accounted buffer storage. Checkpoints allow the caller to
yield or cancel parsing, entropy decoding, IDCT and RGBA conversion.

decoder.reference.js is the unmodified pinned reference for auditing.
source.json records its SHA-256. It is not loaded or executed at runtime.


vendor/jpeg-js/LICENSE-APACHE-2.0.txt

                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS

   APPENDIX: How to apply the Apache License to your work.

      To apply the Apache License to your work, attach the following
      boilerplate notice, with the fields enclosed by brackets "[]"
      replaced with your own identifying information. (Don't include
      the brackets!)  The text should be enclosed in the appropriate
      comment syntax for the file format. We also recommend that a
      file or class name and description of purpose be included on the
      same "printed page" as the copyright notice for easier
      identification within third-party archives.

   Copyright [yyyy] [name of copyright owner]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.


vendor/jpeg-js/LICENSE-UPSTREAM-BSD.txt
Copyright (c) 2014, Eugene Ware
All rights reserved.
  
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:  

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.  
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.  
3. Neither the name of Eugene Ware nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.  
  
THIS SOFTWARE IS PROVIDED BY EUGENE WARE ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL EUGENE WARE BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]==]
-- BAFT Image Builder: standalone interface; conversion runs in this client.
local ENV = (getgenv and getgenv()) or _G
local previous = ENV.ImageBuilder
if previous and type(previous.IsBusy) == "function" and previous.IsBusy() then
    if type(previous.Stop) == "function" then previous.Stop() end
    local deadline = os.clock() + 15
    repeat task.wait(0.1) until not previous.IsBusy() or os.clock() >= deadline
    if previous.IsBusy() then
        warn("Image Builder: the previous operation is still stopping. Wait until it stops, then run the loader again.")
        return
    end
end
-- Another loader may have finished the replacement while this one was waiting.
if ENV.ImageBuilder and ENV.ImageBuilder ~= previous then return end
if previous and type(previous.Destroy) == "function" then previous.Destroy() end

local Adapter = (function()
-- Build A Boat adapter. The game's private tool protocol may change.
-- No inventory writes, local-only replacement blocks, or uncertain-call retries.
local Adapter = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local world = game:GetService("Workspace")
local env = (getgenv and getgenv()) or _G
env.__ImageBuilderFlight = env.__ImageBuilderFlight or {pending = 0, busy = false}
local flight = env.__ImageBuilderFlight
local destroyed = false
local allowed = {}
for _, name in ipairs({"WoodBlock", "StoneBlock", "RustedBlock", "MetalBlock",
    "ConcreteBlock", "MarbleBlock", "TitaniumBlock", "GoldBlock", "PlasticBlock",
    "GlassBlock", "IceBlock", "SandBlock", "GrassBlock", "ObsidianBlock",
    "FabricBlock", "BrickBlock", "NeonBlock"}) do allowed[name] = true end

local function getTool(name)
    local character = player.Character
    local backpack = player:FindFirstChildOfClass("Backpack")
    return (character and character:FindFirstChild(name)) or (backpack and backpack:FindFirstChild(name))
end

local function getZone()
    for _, item in ipairs(world:GetChildren()) do
        local color = item:FindFirstChild("TeamColor")
        if item:IsA("BasePart") and color and color:IsA("BrickColorValue")
            and color.Value == player.TeamColor then return item end
    end
end

local function ownFolder()
    local blocks = world:FindFirstChild("Blocks")
    return blocks and blocks:FindFirstChild(player.Name)
end

local function stock(name)
    local data = player:FindFirstChild("Data")
    local value = data and data:FindFirstChild(name)
    return value and value:IsA("IntValue") and value.Value or 0
end

function Adapter.available(name)
    local data = player:FindFirstChild("Data")
    local value = data and data:FindFirstChild(name)
    local used = value and value:FindFirstChild("Used")
    return math.max(0, stock(name) - (used and tonumber(used.Value) or 0))
end

function Adapter.inventory()
    local result = {}
    for name in pairs(allowed) do
        local amount = Adapter.available(name)
        if stock(name) > 0 then table.insert(result, {name = name, count = amount}) end
    end
    table.sort(result, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        return a.name < b.name
    end)
    return result
end

local function rectangles(plan)
    if plan.rectangles then return plan.rectangles end
    local result = {}
    for _, cell in ipairs(plan.cells or {}) do
        table.insert(result, {x = cell.x, y = cell.y, w = 1, h = 1, color = cell.color})
    end
    return result
end

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function integer(value, minimum, maximum)
    return finite(value) and value % 1 == 0 and value >= minimum and value <= maximum
end

function Adapter.validate(plan)
    if destroyed then return false, "This builder has been closed. Run Image_Builder.lua again." end
    if game.PlaceId ~= 537413528 then return false, "Join Build A Boat For Treasure first." end
    if flight.busy or flight.pending > 0 then
        return false, "A previous build request is still running. Wait for it to finish."
    end
    if type(plan) ~= "table" or not allowed[plan.block_type] then
        return false, "Choose an available solid block type."
    end
    if not finite(plan.pixel_studs) or plan.pixel_studs < 0.001 or plan.pixel_studs > 32 then
        return false, "Use a pixel size between 0.001 and 32 studs. Pixel sizes below 0.001 are not supported by this builder; the game's minimum may be larger."
    end
    if not integer(plan.columns, 1, 250000) or not integer(plan.rows, 1, 250000)
        or plan.columns * plan.rows > 250000 or not finite(plan.width_studs) or not finite(plan.height_studs)
        or math.abs(plan.width_studs - plan.columns * plan.pixel_studs) > 0.001
        or math.abs(plan.height_studs - plan.rows * plan.pixel_studs) > 0.001
        or (plan.rectangles ~= nil and type(plan.rectangles) ~= "table")
        or (plan.rectangles == nil and type(plan.cells) ~= "table") then
        return false, "The image plan has invalid dimensions. Convert it again."
    end
    local items = rectangles(plan)
    if #items == 0 then return false, "The image contains no visible pixels." end
    if #items > 250000 then return false, "Too many blocks; increase pixel size." end
    for _, rect in ipairs(items) do
        if type(rect) ~= "table" or not integer(rect.x, 0, plan.columns - 1)
            or not integer(rect.y, 0, plan.rows - 1) or not integer(rect.w, 1, plan.columns)
            or not integer(rect.h, 1, plan.rows) or rect.x + rect.w > plan.columns
            or rect.y + rect.h > plan.rows or rect.w * plan.pixel_studs > 32.001
            or rect.h * plan.pixel_studs > 32.001 or type(rect.color) ~= "table"
            or not integer(rect.color[1], 0, 255) or not integer(rect.color[2], 0, 255)
            or not integer(rect.color[3], 0, 255) then
            return false, "The image plan has an invalid block. Convert it again."
        end
    end
    for _, name in ipairs({"BuildingTool", "ScalingTool", "PaintingTool"}) do
        local tool = getTool(name)
        if not tool or not tool:IsA("Tool") or not tool:FindFirstChild("RF") or not tool.RF:IsA("RemoteFunction") then
            return false, "Your " .. name .. " is required and must be in your inventory."
        end
    end
    if stock(plan.block_type) < 1 then return false, "No " .. plan.block_type .. " available." end
    if not ownFolder() then return false, "Your build folder is not ready yet." end
    local zone = getZone()
    if not zone then return false, "Your team's build plot was not found." end
    local launched = zone:FindFirstChild("Launched")
    if launched and launched.Value then return false, "Return to the build plot before placing an image." end
    return true, string.format("%d placements; inventory shows %d %s. Scaling cost is checked by the game.",
        #items, stock(plan.block_type), plan.block_type)
end

-- origin is bottom-center of the upright wall. Rows run down from the image top.
function Adapter.geometry(plan, rect, origin)
    local step = plan.pixel_studs
    local size = Vector3.new(rect.w * step, rect.h * step, math.max(0.05, math.min(step, 1)))
    local x = (rect.x + rect.w / 2) * step - plan.width_studs / 2
    local y = plan.height_studs - (rect.y + rect.h / 2) * step
    return origin * CFrame.new(x, y, 0), size
end

function Adapter.materialNeed(plan)
    if type(plan) ~= "table" or not finite(plan.pixel_studs) or plan.pixel_studs <= 0
        or (plan.rectangles ~= nil and type(plan.rectangles) ~= "table")
        or (plan.rectangles == nil and type(plan.cells) ~= "table") then return 0 end
    if plan.rectangles == nil then
        for _, cell in ipairs(plan.cells) do if type(cell) ~= "table" then return 0 end end
    end
    local total = 0
    local step, depth = plan.pixel_studs, math.max(0.05, math.min(plan.pixel_studs, 1))
    for _, rect in ipairs(rectangles(plan)) do
        if type(rect) ~= "table" or not finite(rect.w) or not finite(rect.h)
            or rect.w <= 0 or rect.h <= 0 then return 0 end
        local cost = rect.w * step * rect.h * step * depth / 8
        if not finite(cost) then return 0 end
        total += math.max(math.ceil(cost), 1)
    end
    return total
end

function Adapter.canPlace(plan, origin)
    local zone = getZone()
    if not zone then return false, "Your build plot was not found." end
    local depth = math.max(0.05, math.min(plan.pixel_studs, 1))
    for _, x in ipairs({-plan.width_studs / 2, plan.width_studs / 2}) do
        for _, z in ipairs({-depth / 2, depth / 2}) do
            local corner = zone.CFrame:PointToObjectSpace(origin:PointToWorldSpace(Vector3.new(x, 0, z)))
            if math.abs(corner.X) > zone.Size.X / 2 or math.abs(corner.Z) > zone.Size.Z / 2 then
                return false, "Move the whole wall inside your team's build plot."
            end
        end
    end
    return true, "Click to build here. Q / E rotate."
end

function Adapter.build(plan, origin, options)
    options = options or {}
    local toolMode = options.toolMode or "background"
    if toolMode ~= "background" and toolMode ~= "compatible" then
        return {ok = false, message = "Choose Compatible or Hands free tool mode.", completed = 0, total = 0}
    end
    local valid, reason = Adapter.validate(plan)
    if not valid then return {ok = false, message = reason, completed = 0, total = 0} end
    valid, reason = Adapter.canPlace(plan, origin)
    if not valid then return {ok = false, message = reason, completed = 0, total = 0} end
    local items = rectangles(plan)
    local required = Adapter.materialNeed(plan)
    local presets = {Normal = {rate = 8, workers = 1, batch = 4},
        Fast = {rate = 60, workers = 4, batch = 32}, Turbo = {rate = 120, workers = 8, batch = 64},
        Rapid = {rate = 120, workers = 16, maxRate = 600, maxWorkers = 64, batch = 256, cohort = 16, paint = 32}}
    local selectedSpeed = presets[options.speed] and options.speed or "Fast"
    local speedMode = toolMode == "compatible" and selectedSpeed == "Rapid" and "Fast" or selectedSpeed
    local speed = presets[speedMode]
    local wallStarted
    local completed, created, nextSend, failure = 0, 0, 0, nil
    local folder, zone, character = ownFolder(), getZone(), player.Character
    local originalTeam = player.TeamColor
    local existing, claimed, added = {}, {}, {}
    local progress = options.onProgress or function() end
    local shouldCancel = options.shouldCancel or function() return false end
    local getManualSelection = type(options.getManualToolSelection) == "function" and options.getManualToolSelection or nil
    local connection
    local preparing, cleanupMode, helper, helperPossible = false, false, nil, false
    local deleteAttempted = false
    local originalHeld, lastPrepTool, restoreAfterPending, prepSample
    local holder
    local pipelineActive, dispatchReservations, manualDrain = false, 0, false
    local dispatchTokens, tokenUpdatedAt = 12, os.clock()
    local observedNew, observedCount, observedMaterialCount, batchNewCount = {}, 0, 0, 0
    local diagnostics = {tool_mode = toolMode, phase = "starting", requests_sent = 0,
        selected_speed_mode = selectedSpeed, speed_mode = speedMode, effective_request_rate = speed.rate,
        worker_limit = speed.workers, batch_limit = speed.batch, peak_pending = 0, peak_geometry_jobs = 0,
        pipeline_version = speedMode == "Rapid" and 2 or 0, pipeline_windows = 0,
        pipeline_peak_ready = 0, pipeline_peak_active = 0, pipeline_paint_batches = 0, manual_drains = 0,
        rpc_completed = 0, rpc_latency_total_seconds = 0, rpc_latency_max_seconds = 0,
        max_request_rate = speed.maxRate or speed.rate, max_pending_limit = speed.maxWorkers or speed.workers,
        adaptive_upshifts = 0, adaptive_downshifts = 0, adaptive_peak_rate = speed.rate,
        adaptive_peak_workers = speed.workers, rpc_latency_ewma_seconds = 0,
        monitor_delay_ewma_seconds = 0, monitor_delay_max_seconds = 0,
        replication_peak_waiting = 0, replication_pause_count = 0, verification_budget_seconds = 0,
        verification_checks_peak = 0,
        preparation_request_rate = math.min(speed.rate, 120),
        observed_new_models = 0, observed_material_models = 0, returned_type = "none",
        infinite_requested = options.infiniteBlocks == true, material_required = required,
        inventory_before = Adapter.available(plan.block_type), prep_requests = 0,
        prep_version = 2, prep_rounds = 0, prep_scale_requests = 0, prep_gain = 0, prep_samples = {}}
    local adaptive = {rate = speed.rate, workers = speed.workers, latency = nil, recentMax = 0,
        healthyCalls = 0, nextIncrease = os.clock() + 3, lastDecrease = -math.huge,
        pausePlacements = false, overshoot = 0}
    flight.busy = true

    local function contextChanged()
        return player.Character ~= character or player.TeamColor ~= originalTeam
            or not folder.Parent or (zone:FindFirstChild("Launched") and zone.Launched.Value)
    end
    local function stopped()
        if cleanupMode then return contextChanged() or flight.pending > 0 end
        return destroyed or failure ~= nil or shouldCancel() or contextChanged()
    end
    local function report(message)
        pcall(progress, completed, #items, message)
    end
    local function fail(message)
        failure = failure or message
        return false
    end
    local function setAdaptiveLimits(rate, workers)
        adaptive.rate, adaptive.workers = rate, workers
        diagnostics.effective_request_rate, diagnostics.worker_limit = rate, workers
        diagnostics.adaptive_peak_rate = math.max(diagnostics.adaptive_peak_rate, rate)
        diagnostics.adaptive_peak_workers = math.max(diagnostics.adaptive_peak_workers, workers)
    end
    local function slowDown()
        if speedMode ~= "Rapid" then return end
        local now = os.clock()
        adaptive.nextIncrease = now + 5
        adaptive.healthyCalls = 0
        if now - adaptive.lastDecrease < 0.5 then return end
        adaptive.lastDecrease = now
        local rate = math.max(20, math.floor(adaptive.rate * 0.6))
        local workers = math.max(4, math.floor(adaptive.workers / 2))
        if rate ~= adaptive.rate or workers ~= adaptive.workers then
            setAdaptiveLimits(rate, workers)
            diagnostics.adaptive_downshifts += 1
        end
    end
    local function observeLatency(elapsed)
        if speedMode ~= "Rapid" or preparing then return end
        adaptive.latency = adaptive.latency and adaptive.latency * 0.8 + elapsed * 0.2 or elapsed
        adaptive.recentMax = math.max(elapsed, adaptive.recentMax * 0.98)
        diagnostics.rpc_latency_ewma_seconds = adaptive.latency
        if elapsed > 1 or adaptive.latency > 0.65 then slowDown()
        elseif elapsed < 0.45 then adaptive.healthyCalls += 1 end
    end
    local function verificationBudget()
        if speedMode ~= "Rapid" then return 4 end
        local budget = math.max(8, math.min(24, 4 + (adaptive.latency or 0) * 4 + adaptive.recentMax * 1.5))
        diagnostics.verification_budget_seconds = math.max(diagnostics.verification_budget_seconds, budget)
        return budget
    end
    -- Reserve exact owned instances, not every tool with a matching name. Direct
    -- parenting leaves tools available for remotes. Only an explicitly selected
    -- native controller is enabled; the other borrowed controllers stay silent.
    local function engageHolder()
        if toolMode ~= "background" then return true end
        local backpack = player:FindFirstChildOfClass("Backpack")
        if not character or not backpack or contextChanged() then
            return fail("Wait for your character and backpack before using Hands free mode.")
        end
        local names = {"BuildingTool", "ScalingTool", "PaintingTool"}
        if diagnostics.infinite_requested and Adapter.available(plan.block_type) < required then
            table.insert(names, "DeleteTool")
        end
        holder = {tools = {}, scripts = {}, guis = {}, links = {}, active = true,
            backpack = backpack, playerGui = player:FindFirstChildOfClass("PlayerGui"), selectionChanged = false}
        for _, name in ipairs(names) do
            local tool = getTool(name)
            if not tool or not tool:IsA("Tool") or not tool:FindFirstChild("RF")
                or not tool.RF:IsA("RemoteFunction") then
                return fail("Hands free mode needs your owned " .. name .. ". No requests were sent.")
            end
            holder.tools[name] = {tool = tool, parent = tool.Parent}
        end
        local guiNames = {BuildGui = "BuildingTool", PaintGui = "PaintingTool", ScaleToolDisplayGui = "ScalingTool"}
        local function silence(item, tool)
            local manual = holder.manualTool
            local selected = manual and (tool == manual or (not tool and guiNames[item.Name] == manual.Name))
            if item:IsA("LocalScript") then
                if holder.scripts[item] == nil then
                    holder.scripts[item] = {value = item.Disabled, tool = tool}
                end
                local desired = selected and holder.scripts[item].value or not selected
                if item.Disabled ~= desired then item.Disabled = desired end
            elseif item:IsA("ScreenGui") then
                if holder.guis[item] == nil then holder.guis[item] = {value = item.Enabled, tool = tool} end
                local desired = selected and holder.guis[item].value or false
                if item.Enabled ~= desired then item.Enabled = desired end
            end
        end
        function holder.ensure(name)
            if holder.suppressSupersededManual then holder.suppressSupersededManual() end
            local record = holder.tools[name]
            local tool = record and record.tool
            if not holder.active or contextChanged() or not tool or getTool(name) ~= tool
                or (tool.Parent ~= character and tool.Parent ~= backpack) then
                return fail("A borrowed build tool was removed or replaced. Stopped.")
            end
            if not record.scanned then
                for _, item in ipairs(tool:GetDescendants()) do silence(item, tool) end
                record.scanned = true
            end
            if tool.Parent ~= character then tool.Parent = character end
            return tool.Parent == character or fail("Could not hold " .. name .. " for background building.")
        end
        local function listen(signal, callback)
            table.insert(holder.links, signal:Connect(function(item)
                if not holder.active or contextChanged() then return end
                local ok, message = pcall(callback, item)
                if not ok then fail("Could not keep build tools reserved: " .. tostring(message)) end
            end))
        end
        function holder.borrow(name)
            local record = holder.tools[name]
            if not record then
                local tool = getTool(name)
                if not tool or not tool:IsA("Tool") or not tool:FindFirstChild("RF")
                    or not tool.RF:IsA("RemoteFunction") then
                    return fail("Hands free preparation needs your owned " .. name .. ". No preparation requests were sent.")
                end
                record = {tool = tool, parent = tool.Parent}
                holder.tools[name] = record
                diagnostics.borrowed_tools = (diagnostics.borrowed_tools or #names) + 1
            end
            if not record.listening then
                listen(record.tool.DescendantAdded, function(item) silence(item, record.tool) end)
                record.listening = true
            end
            return holder.ensure(name)
        end
        listen(backpack.ChildAdded, function(tool)
            local record = holder.tools[tool.Name]
            if record and record.tool == tool then
                -- Humanoid:EquipTool may still be moving the other tools while
                -- ChildAdded fires. Reclaim after that operation has finished.
                task.defer(function()
                    if holder.active and not holder.transitioning and not contextChanged() and tool.Parent == backpack then
                        local ok, message = pcall(holder.ensure, tool.Name)
                        if not ok then fail(tostring(message)) end
                    end
                end)
            end
        end)
        listen(character.ChildAdded, function(tool)
            if tool:IsA("Tool") then
                local record = holder.tools[tool.Name]
                if not record or record.tool ~= tool then holder.selectionChanged = true end
            end
        end)
        if holder.playerGui then
            for _, gui in ipairs(holder.playerGui:GetChildren()) do
                if guiNames[gui.Name] and gui:IsA("ScreenGui") then silence(gui) end
            end
            listen(holder.playerGui.ChildAdded, function(gui)
                if guiNames[gui.Name] and gui:IsA("ScreenGui") then silence(gui) end
            end)
        end
        for name in pairs(holder.tools) do
            if not holder.borrow(name) then return false end
        end
        -- Selection comes from exact owned instances captured by the existing
        -- hotbar, not from our own parenting events. Several tools are held for
        -- remotes, but only the explicitly selected one's native controller runs.
        holder.manualRevision = 0
        function holder.suppressSupersededManual()
            local old = holder.manualTool
            if not getManualSelection or holder.transitioning or not old or old.Parent ~= backpack then return end
            local read, selection = pcall(getManualSelection)
            if not read or type(selection) ~= "table" or not integer(selection.revision, 0, 2147483647)
                or selection.revision <= holder.manualRevision then return end
            -- Native selection has already unequipped this controller. Prevent
            -- a deferred reclaim from restarting it beside the newly chosen tool
            -- while an automation batch still has remote requests in flight.
            holder.manualTool = nil
            for _, item in ipairs(old:GetDescendants()) do silence(item, old) end
            for gui, state in pairs(holder.guis) do
                if not state.tool and gui.Parent == holder.playerGui then silence(gui) end
            end
            diagnostics.manual_tool_name = "none"
        end
        function holder.applyManualSelection()
            if not getManualSelection or not holder.active or flight.pending > 0 or holder.transitioning then return true end
            local read, selection = pcall(getManualSelection)
            diagnostics.manual_selection_supported = read and type(selection) == "table" and selection.available ~= false
            if not read or type(selection) ~= "table" or not integer(selection.revision, 0, 2147483647)
                or selection.revision <= holder.manualRevision then return true end
            local chosen = selection.tool
            if chosen ~= nil and (typeof(chosen) ~= "Instance" or not chosen:IsA("Tool")
                or (chosen.Parent ~= character and chosen.Parent ~= backpack)) then return true end
            local record = chosen and holder.tools[chosen.Name]
            local selected = record and record.tool == chosen and chosen or nil
            local previous = holder.manualTool
            holder.transitioning = true
            -- Unequipped must run while the old native controller is enabled:
            -- it removes previews, input listeners and selection handles.
            if previous and previous.Parent == character then previous.Parent = backpack end
            task.wait()
            if stopped() then holder.transitioning = false; return false end
            holder.manualTool = nil
            for _, borrowed in pairs(holder.tools) do
                for _, item in ipairs(borrowed.tool:GetDescendants()) do silence(item, borrowed.tool) end
            end
            for gui, state in pairs(holder.guis) do
                if not state.tool and gui.Parent == holder.playerGui then silence(gui) end
            end
            if selected and selected.Parent == character then selected.Parent = backpack end
            holder.manualTool = selected
            for name, borrowed in pairs(holder.tools) do
                if borrowed.tool ~= selected and not holder.ensure(name) then holder.transitioning = false; return false end
            end
            if selected then
                for _, item in ipairs(selected:GetDescendants()) do silence(item, selected) end
                for gui, state in pairs(holder.guis) do
                    if not state.tool and gui.Parent == holder.playerGui then silence(gui) end
                end
                -- Restarted LocalScripts need time to connect Equipped before
                -- a fresh native equip event initializes their normal controls.
                task.wait()
                if stopped() then holder.transitioning = false; return false end
                local function superseded()
                    local ok, latest = pcall(getManualSelection)
                    return ok and type(latest) == "table" and integer(latest.revision, 0, 2147483647)
                        and latest.revision > selection.revision
                end
                local function deferLatestSelection()
                    if selected.Parent == character then selected.Parent = backpack; task.wait() end
                    holder.manualTool = nil
                    for _, item in ipairs(selected:GetDescendants()) do silence(item, selected) end
                    for gui, state in pairs(holder.guis) do
                        if not state.tool and gui.Parent == holder.playerGui then silence(gui) end
                    end
                    -- Keep the original remote ready, but do not turn a stale
                    -- selection's controller back on. Read the new revision at
                    -- the next normal boundary without delaying the whole job.
                    local ready = holder.ensure(selected.Name)
                    holder.transitioning = false
                    diagnostics.manual_tool_name = "none"
                    return ready and not stopped()
                end
                if superseded() then return deferLatestSelection() end
                if selected.Parent ~= backpack or getTool(selected.Name) ~= selected then
                    holder.transitioning = false
                    return fail("The manually selected build tool was removed or replaced. Stopped.")
                end
                selected.Parent = character
                task.wait()
                if superseded() then return deferLatestSelection() end
            end
            holder.transitioning = false
            holder.manualRevision = selection.revision
            holder.manualSelectionApplied = true
            diagnostics.manual_tool_name = selected and selected.Name or "none"
            diagnostics.manual_selection_revision = selection.revision
            return not stopped()
        end
        diagnostics.borrowed_tools = #names
        diagnostics.holder_active = true
        report(getManualSelection and "Hands free: native tool selection is available while building."
            or "Hands free: reserving build tools; other tools remain available.")
        return true
    end
    local function releaseHolder()
        if not holder or not holder.active then return end
        holder.active = false
        local restoreErrors = 0
        local function safely(callback)
            local ok = pcall(callback)
            if not ok then restoreErrors += 1 end
        end
        for _, link in ipairs(holder.links) do safely(function() link:Disconnect() end) end
        local function stillOurs(tool)
            return tool.Parent == character or (tool.Parent == holder.backpack and holder.backpack.Parent == player)
        end
        local keepSelection = holder.manualSelectionApplied == true
        if holder.selectionChanged and player.Character == character then
            for _, child in ipairs(character:GetChildren()) do
                local record = holder.tools[child.Name]
                if child:IsA("Tool") and (not record or record.tool ~= child) then keepSelection = true end
            end
        end
        for _, record in pairs(holder.tools) do
            safely(function()
                if not stillOurs(record.tool) then return end
                local destination = record.parent
                if destination == character and keepSelection then destination = holder.backpack end
                if holder.manualTool == record.tool and record.tool.Parent == character then destination = character end
                if destination == holder.backpack and (holder.backpack.Parent ~= player
                    or player:FindFirstChildOfClass("Backpack") ~= holder.backpack) then return end
                record.tool.Parent = destination
            end)
        end
        for script, record in pairs(holder.scripts) do
            safely(function()
                if stillOurs(record.tool) and script:IsDescendantOf(record.tool) then script.Disabled = record.value end
            end)
        end
        for gui, record in pairs(holder.guis) do
            safely(function()
                if (record.tool and stillOurs(record.tool) and gui:IsDescendantOf(record.tool))
                    or (not record.tool and gui.Parent == holder.playerGui and holder.playerGui.Parent == player) then
                    gui.Enabled = record.value
                end
            end)
        end
        diagnostics.holder_active = false
        diagnostics.tool_restore_pending = false
        diagnostics.tool_restore_errors = restoreErrors
    end
    local function ownedRemote(name)
        if stopped() then return nil end
        if holder and holder.active and not pipelineActive and not cleanupMode and not holder.applyManualSelection() then return nil end
        if holder and holder.active and not pipelineActive and not holder.ensure(name) then return nil end
        local tool = getTool(name)
        local remote = tool and tool:FindFirstChild("RF")
        if not tool or not tool:IsA("Tool") or not remote or not remote:IsA("RemoteFunction") then
            fail("Your owned " .. name .. " remote is unavailable. Keep the tool in your inventory or character.")
            return nil
        end
        if toolMode == "compatible" or (preparing and not holder) then
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                fail("Wait for your character to spawn before using Compatible mode.")
                return nil
            end
            if tool.Parent ~= character then
                humanoid:EquipTool(tool)
                task.wait(0.08)
            end
            if preparing then lastPrepTool = tool end
            if stopped() then return nil end
            if tool.Parent ~= character then
                fail("Could not equip " .. name .. ". Compatible mode needs to use your normal tools.")
                return nil
            end
        end
        return remote
    end

    local function refreshManualDrain()
        if not pipelineActive or not holder or not holder.active or not getManualSelection then return end
        local ok, selection = pcall(getManualSelection)
        if ok and type(selection) == "table" and integer(selection.revision, 0, 2147483647)
            and selection.revision > holder.manualRevision
            and (selection.tool == nil or typeof(selection.tool) == "Instance" and selection.tool:IsA("Tool")
                and (selection.tool.Parent == character or selection.tool.Parent == holder.backpack)) then
            if not manualDrain then diagnostics.manual_drains += 1 end
            manualDrain = true
        else manualDrain = false end
    end

    -- Capacity includes callers waiting for their rate slot. A manual selection
    -- cancels those reservations, drains only already dispatched requests, then
    -- changes native controllers before any new request may start.
    local function awaitDispatch(remote)
        local placement = remote and remote.Parent and remote.Parent.Name == "BuildingTool"
        while not stopped() do
            local reserved = not pipelineActive
            local limit = adaptive.workers
            if placement then limit = math.max(1, limit - math.min(4, math.floor(limit / 4))) end
            if pipelineActive then
                refreshManualDrain()
                if manualDrain then
                    if flight.pending == 0 and dispatchReservations == 0 and not holder.transitioning then
                        if not holder.applyManualSelection() then return false end
                        manualDrain = false
                        refreshManualDrain()
                    end
                elseif not holder.transitioning and not (placement and adaptive.pausePlacements)
                    and flight.pending + dispatchReservations < limit then
                    dispatchReservations += 1
                    reserved = true
                end
            end
            if reserved then
                local when = math.max(os.clock(), nextSend)
                local requestRate = preparing and math.min(speed.rate, 120)
                    or speedMode == "Rapid" and adaptive.rate or speed.rate
                nextSend = when + 1 / requestRate
                local delay = when - os.clock()
                if delay > 0 then task.wait(delay) end
                if pipelineActive then
                    dispatchReservations -= 1
                    refreshManualDrain()
                    limit = adaptive.workers
                    if placement then limit = math.max(1, limit - math.min(4, math.floor(limit / 4))) end
                    if not stopped() and not manualDrain and not holder.transitioning and flight.pending < limit
                        and not (placement and adaptive.pausePlacements) then
                        -- A stalled client can wake many overdue reservations
                        -- on one frame. Limit that catch-up burst explicitly.
                        local now = os.clock()
                        dispatchTokens = math.min(12, dispatchTokens + math.max(0, now - tokenUpdatedAt) * adaptive.rate)
                        tokenUpdatedAt = now
                        if dispatchTokens >= 1 then dispatchTokens -= 1; return true end
                    end
                else
                    return not stopped()
                end
            end
            if not stopped() then task.wait(0.03) end
        end
        return false
    end

    -- A timeout is indeterminate: retain the shared pending lock until it returns.
    local function invoke(remote, ...)
        if stopped() or not awaitDispatch(remote) then return false end
        local tool = remote and remote.Parent
        local backpack = player:FindFirstChildOfClass("Backpack")
        if holder and holder.active and (not tool or not holder.ensure(tool.Name)) then return false end
        if not tool or not tool:IsA("Tool") or (tool.Parent ~= character and tool.Parent ~= backpack)
            or getTool(tool.Name) ~= tool or tool:FindFirstChild("RF") ~= remote
            or not remote:IsA("RemoteFunction") then
            return fail("A build tool was removed or replaced. Stopped.")
        end
        if (toolMode == "compatible" or preparing) and tool.Parent ~= character then
            return fail("The active tool changed during Compatible building. Leave the build tools selected while it runs, or use Hands free mode.")
        end
        local args = table.pack(...)
        -- Recheck ownership at dispatch, after waiting for the shared rate slot.
        -- Never resize/paint a model that was moved into another player's folder.
        local function mayModify(model)
            return model and model.Parent == folder and model.Name == plan.block_type and not existing[model]
                and (claimed[model] or (preparing and model == helper))
        end
        if tool.Name == "ScalingTool" or tool.Name == "DeleteTool" then
            if not mayModify(args[1]) then return fail("An identified owned block was removed or moved. Stopped.") end
        elseif tool.Name == "PaintingTool" then
            for _, entry in ipairs(args[1]) do
                if not mayModify(entry[1]) then return fail("An identified owned block was removed or moved. Stopped.") end
            end
        end
        if tool.Name == "BuildingTool" then
            -- Manual building can consume stock while a request waits for its
            -- rate slot. Read the server-replicated count again at dispatch.
            args[2] = stock(plan.block_type)
            if args[2] < 1 or (not preparing and Adapter.available(plan.block_type) < 1) then
                return fail("Out of available " .. plan.block_type .. ". Increase pixel size or choose another block.")
            end
            diagnostics.placement_argument_count = args.n
            diagnostics.placement_tool_held = tool.Parent == character
        end
        local wasUnheld = tool.Parent ~= character
        local finished, ok, result = false, false, nil
        flight.pending += 1
        diagnostics.peak_pending = math.max(diagnostics.peak_pending, flight.pending)
        diagnostics.requests_sent += 1
        if preparing then
            diagnostics.prep_requests += 1
            if tool.Name == "ScalingTool" then
                diagnostics.prep_scale_requests += 1
                if prepSample then prepSample.requests += 1 end
            end
        end
        local invokedAt = os.clock()
        task.spawn(function()
            ok, result = pcall(function() return remote:InvokeServer(table.unpack(args, 1, args.n)) end)
            local elapsed = math.max(0, os.clock() - invokedAt)
            diagnostics.rpc_completed += 1
            diagnostics.rpc_latency_total_seconds += elapsed
            diagnostics.rpc_latency_max_seconds = math.max(diagnostics.rpc_latency_max_seconds, elapsed)
            observeLatency(elapsed)
            flight.pending -= 1
            finished = true
            if flight.pending == 0 and restoreAfterPending then restoreAfterPending() end
        end)
        local deadline = os.clock() + 12
        while not finished and os.clock() < deadline do task.wait(0.03) end
        if not finished then
            return fail("The game has not answered a request. Stopped without retrying; it may still finish later.")
        end
        local unheldHint = wasUnheld and " The tool was unheld; this server may require holding it and may not support background building." or ""
        if not ok then return fail("The game rejected a tool request: " .. tostring(result) .. unheldHint) end
        if result == false then return fail("The game declined the request. Check inventory, scale limits, and plot position." .. unheldHint) end
        return true, result
    end

    local function waitFor(predicate, timeout)
        local deadline = os.clock() + timeout
        repeat
            local value = predicate()
            if value then return value end
            if stopped() then return nil end
            task.wait(0.03)
        until os.clock() >= deadline
        return nil
    end
    local positionTolerance = math.max(0.0001, math.min(0.02, plan.pixel_studs * 0.1))
    local sizeTolerance = math.max(0.0001, math.min(0.04, plan.pixel_studs * 0.1))
    local function matches(part, cf)
        return part and part:IsA("BasePart") and (part.Position - cf.Position).Magnitude < positionTolerance
    end
    local function identify(cf, result)
        if typeof(result) == "Instance" and result:IsA("BasePart") then result = result.Parent end
        if typeof(result) == "Instance" and not existing[result] and result.Parent ~= nil and result.Parent ~= folder then
            fail("A returned image block was moved outside your plot. Stopped before modifying it.")
            return nil
        end
        local function candidate(model, returnedByServer)
            if not model or existing[model] or claimed[model] or model.Parent ~= folder
                or model.Name ~= plan.block_type then return nil end
            local part = model:FindFirstChild("PPart")
            -- A returned new owned block is directly identified by the server.
            -- Its initial placement can be snapped; ScalingTool will move it
            -- to the exact image position and the final geometry is verified.
            if part and part:IsA("BasePart") and (returnedByServer or matches(part, cf)) then return model end
        end
        return waitFor(function()
            if typeof(result) == "Instance" then
                local found = candidate(result, true)
                if found then claimed[found] = true; return found end
            end
            local found
            for _, model in ipairs(added) do
                local match = candidate(model, false)
                if match then
                    if found and found ~= match then
                        fail("Multiple new blocks appeared at the same image position. Stopped before sizing or painting this batch to avoid changing a manually placed block.")
                        return nil
                    end
                    found = match
                end
            end
            if found then claimed[found] = true; return found end
        end, speedMode == "Rapid" and verificationBudget() or 5)
    end
    local function geometryCorrect(job)
        local model = job.model
        local part = model and model:FindFirstChild("PPart")
        return model and model.Parent == folder and part and matches(part, job.cf)
            and (part.Size - job.size).Magnitude < sizeTolerance
            and part.CFrame.RightVector:Dot(job.cf.RightVector) > 0.995
            and part.CFrame.UpVector:Dot(job.cf.UpVector) > 0.995
    end
    local function paintCorrect(job)
        local part = job.model and job.model:FindFirstChild("PPart")
        return geometryCorrect(job) and part and math.abs(part.Color.R - job.color.R) <= 1.5 / 255
            and math.abs(part.Color.G - job.color.G) <= 1.5 / 255
            and math.abs(part.Color.B - job.color.B) <= 1.5 / 255
    end
    local function verificationFailure(job, phase, started)
        local model = job.model
        local part = model and model:FindFirstChild("PPart")
        local owned = model ~= nil and model.Parent == folder and model.Name == plan.block_type
            and claimed[model] == true and not existing[model]
        local present = part and part:IsA("BasePart")
        diagnostics.verification_failure_phase = phase
        diagnostics.verification_failure_owned = owned
        diagnostics.verification_position_error = present and (part.Position - job.cf.Position).Magnitude or 999999
        diagnostics.verification_size_error = present and (part.Size - job.size).Magnitude or 999999
        diagnostics.verification_right_dot = present and part.CFrame.RightVector:Dot(job.cf.RightVector) or -1
        diagnostics.verification_up_dot = present and part.CFrame.UpVector:Dot(job.cf.UpVector) or -1
        diagnostics.verification_color_error = present and math.max(math.abs(part.Color.R - job.color.R),
            math.abs(part.Color.G - job.color.G), math.abs(part.Color.B - job.color.B)) or 1
        diagnostics.verification_wait_seconds = math.max(0, os.clock() - started)
        if not owned then return fail("An identified image block was removed or moved outside your plot. Stopped.") end
        if not geometryCorrect(job) then
            return fail(string.format("The game did not accept the requested block size or position after %.1f seconds. Stopped with verified progress preserved.",
                diagnostics.verification_wait_seconds))
        end
        return fail(string.format("The game did not confirm the requested paint color after %.1f seconds. Stopped with verified progress preserved.",
            diagnostics.verification_wait_seconds))
    end
    local function runPool(jobs, worker, count)
        local index, running = 0, 0
        for _ = 1, math.min(count or speed.workers, #jobs) do
            running += 1
            task.spawn(function()
                local ok, message = pcall(function()
                    while not stopped() do
                        index += 1
                        local job = jobs[index]
                        if not job then break end
                        if worker(job) == false then break end
                    end
                end)
                if not ok then fail(tostring(message)) end
                running -= 1
            end)
        end
        while running > 0 do task.wait(0.03) end
        return not stopped()
    end

    local function validHelper(model)
        return model and not existing[model] and model.Parent == folder
            and model.Name == plan.block_type and model:FindFirstChild("PPart")
            and model.PPart:IsA("BasePart")
    end
    local function restoreHeldTool()
        if not preparing then return end
        if holder then preparing = false; return end
        local function restore()
            if contextChanged() then return end
            pcall(function()
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local backpack = player:FindFirstChildOfClass("Backpack")
                if not humanoid or humanoid.Health <= 0 then return end
                -- Never override a selection made after our last equipment
                -- change, including a manual switch while a call timed out.
                local held, count = nil, 0
                for _, child in ipairs(character:GetChildren()) do
                    if child:IsA("Tool") then held = child; count += 1 end
                end
                if count ~= 1 or held ~= lastPrepTool then return end
                if originalHeld and (originalHeld.Parent == character or originalHeld.Parent == backpack) then
                    humanoid:EquipTool(originalHeld)
                elseif not originalHeld then
                    humanoid:UnequipTools()
                end
            end)
        end
        if flight.pending > 0 then
            restoreAfterPending = function()
                restoreAfterPending = nil
                restore()
                flight.busy = false
            end
        else
            restore()
        end
        preparing = false
    end
    local function removeHelper()
        if not helperPossible then return true end
        if helper and helper.Parent == nil then helperPossible = false; return true end
        if deleteAttempted or not validHelper(helper) or contextChanged() or flight.pending > 0 then return false end
        -- Cleanup can run after cancellation, but never alongside an uncertain
        -- request. It addresses only the one positively identified new helper.
        cleanupMode = true
        local ok, removed = pcall(function()
            local remote = ownedRemote("DeleteTool")
            if not remote then return false end
            diagnostics.phase = "preparing_delete"
            deleteAttempted = true
            if not invoke(remote, helper) then return false end
            return waitFor(function() return helper.Parent ~= folder end, 5) == true
        end)
        cleanupMode = false
        if ok and removed then helperPossible = false; return true end
        return false
    end
    local function prepareInventory()
        if not diagnostics.infinite_requested then return true end
        local before = Adapter.available(plan.block_type)
        diagnostics.inventory_before = before
        if before >= required then
            diagnostics.preparation_status = "already_sufficient"
            diagnostics.inventory_after = before
            return true
        end
        -- The reference yield is only an initial estimate. Measure completed
        -- create/scale/delete rounds before scheduling any additional material.
        local estimated = math.ceil((required - before) / 99.0017938123301)
        if estimated > 4096 then
            diagnostics.prep_stop_reason = "request_limit"
            return fail("This image exceeds the Infinite Blocks preparation limit of 4096 scale requests. Use a smaller image.")
        end
        local deleteTool = getTool("DeleteTool")
        if not deleteTool or not deleteTool:IsA("Tool") or not deleteTool:FindFirstChild("RF")
            or not deleteTool.RF:IsA("RemoteFunction") then
            return fail("Infinite Blocks preparation needs your owned DeleteTool. No preparation requests were sent.")
        end
        -- Inventory can change between holder engagement and this recheck.
        -- Acquire the cleanup tool before creating a helper in that case.
        if holder and not holder.borrow("DeleteTool") then return false end
        if stopped() then return false end
        local heldCount = 0
        for _, child in ipairs(character and character:GetChildren() or {}) do
            if child:IsA("Tool") then originalHeld = child; heldCount += 1 end
        end
        if heldCount > 1 and not holder then
            return fail("Infinite Blocks preparation needs at most one equipped tool. Close other builders and unequip extra tools first.")
        end
        preparing = true
        diagnostics.preparation_status = "running"
        local cf = CFrame.new(zone.Position.X, -250000, zone.Position.Z)
            * CFrame.Angles(0, math.rad(40.135), 0)
        local isWhite = player.Team and string.lower(player.Team.Name) == "white"
        local size = isWhite and Vector3.new(1.1755e-38, 2048, 390.632)
            or Vector3.new(390.632, 2048, 1.1755e-38)
        local measuredYield
        local function preparationFailed(code, reason)
            local after = Adapter.available(plan.block_type)
            diagnostics.inventory_after = after
            diagnostics.prep_gain = after - before
            diagnostics.prep_stop_reason = code
            return fail(string.format("Infinite Blocks preparation %s: started with %.3f, now %.3f available; %.3f more needed (%d required). The wall was not started.",
                reason, before, after, math.max(0, required - after), required))
        end
        while Adapter.available(plan.block_type) < required do
            if stopped() then return false end
            if diagnostics.prep_scale_requests >= 4096 then
                return preparationFailed("request_limit", "reached its limit of 4096 scale requests")
            end
            if diagnostics.prep_rounds >= 32 then
                return preparationFailed("round_limit", "reached its limit of 32 measured rounds")
            end
            local roundBefore = Adapter.available(plan.block_type)
            local count = measuredYield and math.ceil((required - roundBefore) / measuredYield)
                or math.min(16, estimated)
            count = math.max(1, math.min(count, 256, 4096 - diagnostics.prep_scale_requests))
            -- A fresh snapshot prevents a prior helper or another block made
            -- between rounds from being mistaken for this round's helper.
            for _, model in ipairs(folder:GetChildren()) do existing[model] = true end
            helper, helperPossible, deleteAttempted = nil, false, false
            diagnostics.prep_rounds += 1
            prepSample = {before = roundBefore, after = roundBefore, requests = 0, gain = 0}
            table.insert(diagnostics.prep_samples, prepSample)
            diagnostics.phase = "preparing_place"
            report(string.format("Preparing material: round %d; %.3f / %d available...",
                diagnostics.prep_rounds, roundBefore, required))
            local remote = ownedRemote("BuildingTool")
            if not remote then return false end
            local priorRequests = diagnostics.prep_requests
            local accepted, result = invoke(remote, plan.block_type, stock(plan.block_type), zone,
                zone.CFrame:ToObjectSpace(cf), true, nil, nil, false)
            helperPossible = diagnostics.prep_requests > priorRequests
            if not accepted then return false end
            if typeof(result) == "Instance" and result:IsA("BasePart") then result = result.Parent end
            helper = waitFor(function()
                if typeof(result) == "Instance" and validHelper(result) then return result end
                local found
                for _, model in ipairs(folder:GetChildren()) do
                    if validHelper(model) and (model.PPart.Position - cf.Position).Magnitude <= 0.02 then
                        if found then
                            fail("Infinite Blocks preparation found multiple new blocks at the staging position. None were scaled or deleted.")
                            return nil
                        end
                        found = model
                    end
                end
                return found
            end, 5)
            if not helper then
                return fail("Infinite Blocks preparation could not identify its new temporary block. No block was scaled or deleted.")
            end
            if stopped() then return false end
            remote = ownedRemote("ScalingTool")
            if not remote then return false end
            diagnostics.phase = "preparing_scale"
            -- Requests change the same model, so wait for each response rather
            -- than letting multiple writes race. invoke caps preparation at 120/s.
            for index = 1, count do
                if stopped() then return false end
                if not validHelper(helper) then return fail("The identified preparation block was removed or changed. Stopped.") end
                -- Each scale has fully returned here. Apply native selection
                -- before the next call rather than delaying it a whole round.
                remote = ownedRemote("ScalingTool")
                if not remote then return false end
                report(string.format("Preparing material: round %d, scale request %d / %d",
                    diagnostics.prep_rounds, index, count))
                if not invoke(remote, helper, size, cf) then return false end
            end
            if not removeHelper() then return fail("The game did not confirm removal of the temporary preparation block.") end
            existing[helper] = true -- Never reuse this exact instance in a later round.
            diagnostics.phase = "preparing_verify"
            report("Checking material gained from the completed round...")
            local deadline = os.clock() + 5
            local after, changedAt = Adapter.available(plan.block_type), os.clock()
            repeat
                if stopped() then return false end
                local current = Adapter.available(plan.block_type)
                if current ~= after then after, changedAt = current, os.clock() end
                if after >= required or (after > roundBefore and os.clock() - changedAt >= 0.5) then break end
                task.wait(0.03)
            until os.clock() >= deadline
            after = Adapter.available(plan.block_type)
            prepSample.after, prepSample.gain = after, after - roundBefore
            diagnostics.inventory_after = after
            diagnostics.prep_gain = after - before
            local gain = prepSample.gain
            prepSample = nil
            if gain <= 0 then
                return preparationFailed("no_gain", "did not provide enough material; the last completed round produced no positive gain")
            end
            measuredYield = gain / count
        end
        if stopped() then return false end
        diagnostics.preparation_status = "verified"
        diagnostics.prep_stop_reason = "satisfied"
        diagnostics.inventory_after = Adapter.available(plan.block_type)
        diagnostics.prep_gain = diagnostics.inventory_after - before
        restoreHeldTool()
        return true
    end

    local function doBatch(jobs, first)
        -- Earlier batches have already replicated and verified. Keep candidate
        -- matching bounded by this batch instead of rescanning the entire wall.
        table.clear(added)
        batchNewCount = 0
        diagnostics.phase = "placing"
        local remote = ownedRemote("BuildingTool")
        if not remote then return false end
        report(first and "Checking the first block with the game..." or "Placing blocks...")
        if not runPool(jobs, function(job)
            local remaining = stock(plan.block_type)
            if Adapter.available(plan.block_type) < 1 then return fail("Out of available " .. plan.block_type .. ". Increase pixel size or choose another block.") end
            -- Three normal manual placements captured on 2026-09-24 supplied
            -- eight arguments ending false, true. The last flag's server-side
            -- meaning is unknown; preserve the observed value in both modes.
            local ok, result = invoke(remote, plan.block_type, remaining, zone,
                zone.CFrame:ToObjectSpace(job.cf), true, job.cf, false, true)
            if not ok then return false end
            job.result = result
            if first then diagnostics.returned_type = typeof(result) end
            return true
        end, first and 1 or speed.workers) then return false end

        -- Wait until placement calls for the batch have returned before using
        -- ChildAdded fallback evidence. A returned new owned instance is the
        -- strongest correlation; location alone cannot establish provenance if
        -- a manual placement is the sole new object at that exact position.
        for _, job in ipairs(jobs) do
            job.model = identify(job.cf, job.result)
            if not job.model then
                diagnostics.observed_new_models = observedCount
                diagnostics.observed_material_models = observedMaterialCount
                if stopped() then return false end
                diagnostics.last_batch_new_objects = batchNewCount
                if batchNewCount == 0 then
                    local hint = toolMode == "background"
                        and " Select Tools: Compatible, then place again; it uses the normal game tools."
                        or " Check the selected plot and available material. The game did not confirm placement."
                    return fail("No new block appeared after the placement request." .. hint)
                end
                local nearest
                for _, model in ipairs(added) do
                    local part = model:FindFirstChild("PPart")
                    if model.Name == plan.block_type and part and part:IsA("BasePart") then
                        local distance = (part.Position - job.cf.Position).Magnitude
                        if not nearest or distance < nearest then nearest = distance end
                    end
                end
                diagnostics.nearest_position_error = nearest
                return fail(string.format("%d new object(s) appeared, but the requested block could not be identified%s. Stopped before modifying them.",
                    batchNewCount, nearest and string.format(" (nearest position differs by %.4g studs)", nearest) or ""))
            end
            created += 1
        end

        diagnostics.phase = "scaling"
        remote = ownedRemote("ScalingTool")
        if not remote then return false end
        report("Sizing blocks...")
        if not runPool(jobs, function(job)
            local ok = invoke(remote, job.model, job.size, job.cf)
            if not ok then return false end
            local started = os.clock()
            local correct = waitFor(function()
                return geometryCorrect(job)
            end, verificationBudget())
            if not correct then
                if speedMode == "Rapid" then
                    if stopped() then return false end
                    return verificationFailure(job, "geometry", started)
                end
                return fail("The game did not accept the requested block size. It may require held tools; try a larger pixel size or more inventory.")
            end
            return true
        end) then return false end

        diagnostics.phase = "painting"
        remote = ownedRemote("PaintingTool")
        if not remote then return false end
        report("Painting and verifying...")
        -- A bounded paint batch reduces round trips; every result is verified.
        local paint = {}
        for _, job in ipairs(jobs) do table.insert(paint, {job.model, job.color}) end
        if not invoke(remote, paint) then return false end
        for _, job in ipairs(jobs) do
            local started = os.clock()
            if not waitFor(function()
                return paintCorrect(job)
            end, verificationBudget()) then
                if speedMode == "Rapid" then
                    if stopped() then return false end
                    return verificationFailure(job, "paint", started)
                end
                return fail("The game did not confirm the requested paint color. It may require held tools. Stopped.")
            end
            completed += 1
        end
        report(string.format("Verified %d / %d blocks", completed, #items))
        return true
    end

    local function doRapidWindow(jobs)
        table.clear(added)
        batchNewCount = 0
        pipelineActive = true
        adaptive.pausePlacements = false
        diagnostics.pipeline_windows += 1
        diagnostics.phase = "pipelining"
        report("Building at a measured pace...")
        local checking, ready = {}, {}
        local cohortsRunning, paintsRunning, nextJob, activeCount = 0, 0, 1, 0
        local checkCursor, readySince = 1, nil
        local reportedAt, reportedCount, reportedStatus = 0, completed, ""
        local function launch(callback, painting)
            if painting then paintsRunning += 1 else cohortsRunning += 1 end
            task.spawn(function()
                local ok, message = pcall(callback)
                if not ok then fail(tostring(message)) end
                if painting then paintsRunning -= 1 else cohortsRunning -= 1 end
            end)
        end
        local function queueVerification(job, phase, started, deadline)
            job.verifyPhase, job.verifyStarted, job.verifyDeadline = phase, started, deadline
            table.insert(checking, job)
        end
        local function launchCohort()
            local cohort = {}
            for _ = 1, math.min(speed.cohort, #jobs - nextJob + 1) do
                table.insert(cohort, jobs[nextJob]); nextJob += 1
            end
            activeCount += #cohort
            diagnostics.pipeline_peak_active = math.max(diagnostics.pipeline_peak_active, activeCount)
            launch(function()
                local buildRemote = ownedRemote("BuildingTool")
                if not buildRemote then return end
                if not runPool(cohort, function(job)
                    local ok, result = invoke(buildRemote, plan.block_type, stock(plan.block_type), zone,
                        zone.CFrame:ToObjectSpace(job.cf), true, job.cf, false, true)
                    if not ok then return false end
                    job.result = result
                    return true
                end, speed.cohort) then return end
                -- Nil replies require the whole small placement cohort to
                -- return before matching any of its new models.
                for _, job in ipairs(cohort) do
                    if stopped() then return end
                    job.model = identify(job.cf, job.result)
                    if not job.model then
                        if not stopped() then fail("A requested block could not be uniquely identified. Stopped before modifying it; partial blocks may remain.") end
                        return
                    end
                    created += 1
                end
                local scaleRemote = ownedRemote("ScalingTool")
                if not scaleRemote then return end
                runPool(cohort, function(job)
                    if not invoke(scaleRemote, job.model, job.size, job.cf) then return false end
                    local started = os.clock()
                    queueVerification(job, "geometry", started, started + verificationBudget())
                    return true
                end, speed.cohort)
            end, false)
        end
        repeat
            if not stopped() then
                refreshManualDrain()
                if manualDrain and flight.pending == 0 and dispatchReservations == 0 and not holder.transitioning then
                    if not holder.applyManualSelection() then break end
                    manualDrain = false
                    refreshManualDrain()
                end
                local tickStarted, oldestWait, checks = os.clock(), 0, 0
                -- A fair cursor gives every waiting job a bounded share of
                -- CPU. Deadlines are absolute; one slow job cannot grant the
                -- next one another full timeout or stop correct jobs counting.
                for _ = 1, math.min(24, #checking) do
                    if stopped() or #checking == 0 then break end
                    if checks > 0 and os.clock() - tickStarted >= 0.002 then break end
                    if checkCursor > #checking then checkCursor = 1 end
                    local job = checking[checkCursor]
                    checks += 1
                    local age = os.clock() - job.verifyStarted
                    oldestWait = math.max(oldestWait, age)
                    if not job.model or job.model.Parent ~= folder or job.model.Name ~= plan.block_type then
                        verificationFailure(job, job.verifyPhase, job.verifyStarted)
                        break
                    end
                    local correct = job.verifyPhase == "geometry" and geometryCorrect(job)
                        or job.verifyPhase == "paint" and paintCorrect(job)
                    if correct then
                        table.remove(checking, checkCursor)
                        if job.verifyPhase == "geometry" then
                            table.insert(ready, job)
                            readySince = readySince or os.clock()
                        else
                            completed += 1
                            activeCount -= 1
                        end
                    elseif os.clock() >= job.verifyDeadline then
                        verificationFailure(job, job.verifyPhase, job.verifyStarted)
                        break
                    else checkCursor += 1 end
                end
                diagnostics.verification_checks_peak = math.max(diagnostics.verification_checks_peak, checks)
                diagnostics.pipeline_peak_ready = math.max(diagnostics.pipeline_peak_ready, #ready)
                diagnostics.replication_peak_waiting = math.max(diagnostics.replication_peak_waiting, #checking)
                local paused = #checking >= math.max(16, adaptive.workers * 2)
                    or #ready >= math.max(32, adaptive.workers * 2)
                    or oldestWait > math.max(0.6, (adaptive.latency or 0) * 1.5)
                if paused and not adaptive.pausePlacements then diagnostics.replication_pause_count += 1 end
                adaptive.pausePlacements = paused
                if oldestWait > math.max(1, (adaptive.latency or 0) * 2) or #ready > 64 then slowDown() end
                if not paused and adaptive.latency and adaptive.latency < 0.45 and adaptive.overshoot < 0.02
                    and adaptive.healthyCalls >= 16 and os.clock() >= adaptive.nextIncrease then
                    local workers = math.min(speed.maxWorkers, adaptive.workers + 4)
                    local rate = math.min(speed.maxRate, adaptive.rate + 40)
                    if workers ~= adaptive.workers or rate ~= adaptive.rate then
                        setAdaptiveLimits(rate, workers)
                        diagnostics.adaptive_upshifts += 1
                    end
                    adaptive.nextIncrease = os.clock() + 3
                    adaptive.healthyCalls = 0
                end
                -- Only one small paint payload may be in flight. The reference
                -- protocol gives no guarantee about concurrent paint handlers.
                if not stopped() and paintsRunning == 0 and #ready > 0
                    and (#ready >= speed.paint or cohortsRunning == 0 or os.clock() - readySince >= 0.1) then
                    local paintJobs, payload = {}, {}
                    for _ = 1, math.min(speed.paint, #ready) do
                        local job = table.remove(ready)
                        table.insert(paintJobs, job); table.insert(payload, {job.model, job.color})
                    end
                    readySince = #ready > 0 and os.clock() or nil
                    diagnostics.pipeline_paint_batches += 1
                    launch(function()
                        local remote = ownedRemote("PaintingTool")
                        if not remote or not invoke(remote, payload) then return end
                        local started = os.clock()
                        local deadline = started + verificationBudget()
                        for _, job in ipairs(paintJobs) do queueVerification(job, "paint", started, deadline) end
                    end, true)
                end
                local cohortLimit = math.min(4, math.max(1, math.ceil(adaptive.workers / speed.cohort)))
                local activeLimit = math.min(128, math.max(32, adaptive.workers * 3))
                while not stopped() and not adaptive.pausePlacements and not manualDrain
                    and nextJob <= #jobs and cohortsRunning < cohortLimit and activeCount + speed.cohort <= activeLimit do
                    launchCohort()
                end
                local status = paused and "Waiting for block updates; holding new placements..."
                    or diagnostics.adaptive_downshifts > 0 and "Building with reduced load..."
                    or "Placing, sizing and painting..."
                if status ~= reportedStatus or completed ~= reportedCount and os.clock() - reportedAt >= 0.2 then
                    report(status)
                    reportedAt, reportedCount, reportedStatus = os.clock(), completed, status
                end
            end
            if cohortsRunning > 0 or paintsRunning > 0 or not stopped() and (nextJob <= #jobs or #checking > 0 or #ready > 0) then
                local beforeWait = os.clock()
                task.wait(0.05)
                local elapsed = math.max(0, os.clock() - beforeWait)
                local overshoot = math.max(0, elapsed - 0.05)
                adaptive.overshoot = adaptive.overshoot * 0.8 + overshoot * 0.2
                diagnostics.monitor_delay_ewma_seconds = diagnostics.monitor_delay_ewma_seconds == 0 and elapsed
                    or diagnostics.monitor_delay_ewma_seconds * 0.8 + elapsed * 0.2
                diagnostics.monitor_delay_max_seconds = math.max(diagnostics.monitor_delay_max_seconds, elapsed)
                if overshoot > 0.08 or adaptive.overshoot > 0.035 then slowDown() end
            end
        until cohortsRunning == 0 and paintsRunning == 0
            and (stopped() or nextJob > #jobs and #checking == 0 and #ready == 0)
        pipelineActive = false
        adaptive.pausePlacements = false
        manualDrain = false
        return not stopped()
    end

    local ok, message = pcall(function()
        for _, model in ipairs(folder:GetChildren()) do existing[model] = true end
        if stopped() or not engageHolder() then return end
        if not prepareInventory() then return end
        -- The preparation helper is excluded from all wall observations/counts.
        connection = folder.ChildAdded:Connect(function(model)
            table.insert(added, model)
            if not existing[model] and not observedNew[model] then
                observedNew[model] = true
                observedCount += 1
                batchNewCount += 1
                if model.Name == plan.block_type then observedMaterialCount += 1 end
            end
        end)
        -- Construct only this batch's CFrames, sizes and colors. Large plans
        -- already contain their rectangles; a second full job list adds a long
        -- allocation pause and keeps every job alive for the whole build.
        local function makeBatch(firstIndex, lastIndex)
            local jobs = {}
            for index = firstIndex, lastIndex do
                local rect = items[index]
                local cf, size = Adapter.geometry(plan, rect, origin)
                table.insert(jobs, {cf = cf, size = size,
                    color = Color3.fromRGB(rect.color[1], rect.color[2], rect.color[3])})
            end
            diagnostics.peak_geometry_jobs = math.max(diagnostics.peak_geometry_jobs, #jobs)
            return jobs
        end
        wallStarted = os.clock()
        -- Prove this server accepts all three operations before concurrent work.
        if not doBatch(makeBatch(1, 1), true) then return end
        local offset = 2
        while offset <= #items and not stopped() do
            local batch = makeBatch(offset, math.min(#items, offset + speed.batch - 1))
            if speedMode == "Rapid" then
                if not doRapidWindow(batch) then break end
            elseif not doBatch(batch, false) then break end
            offset += #batch
            task.wait()
        end
        if holder and holder.active and not stopped() then holder.applyManualSelection() end
    end)
    if connection then connection:Disconnect() end
    if not ok then failure = failure or tostring(message) end
    if preparing then
        if helperPossible then removeHelper() end
        restoreHeldTool()
    end
    if holder then
        if flight.pending > 0 then
            diagnostics.tool_restore_pending = true
            restoreAfterPending = function()
                restoreAfterPending = nil
                releaseHolder()
                flight.busy = false
            end
        else
            releaseHolder()
        end
    end
    if diagnostics.infinite_requested then
        if diagnostics.preparation_status ~= "verified" and diagnostics.preparation_status ~= "already_sufficient" then
            diagnostics.preparation_status = "failed"
            diagnostics.inventory_after = Adapter.available(plan.block_type)
            diagnostics.prep_gain = diagnostics.inventory_after - diagnostics.inventory_before
            diagnostics.prep_stop_reason = diagnostics.prep_stop_reason
                or (flight.pending > 0 and "request_pending")
                or (failure and "request_failed") or "cancelled_or_context_changed"
            if prepSample then
                prepSample.after = diagnostics.inventory_after
                prepSample.gain = prepSample.after - prepSample.before
            end
        end
    end
    diagnostics.temporary_block_remaining = helperPossible
    flight.busy = restoreAfterPending ~= nil
    local success = completed == #items
    local status = success and string.format("Built and verified %d blocks. Use the game's Save button to keep the wall.", completed)
        or (failure or "Stopped by you, respawn, launch, or team change.")
    if not success then
        status ..= string.format(" %d/%d finished; %d blocks identified.", completed, #items, created)
        if observedCount > 0 or created > 0 then
            status ..= " New or partial blocks may remain; check your plot before retrying."
        else
            status ..= " No new wall blocks were observed during this attempt."
        end
        if helperPossible then
            status ..= " A temporary preparation block may remain below the plot; it was not safe to delete it."
        end
        if flight.pending > 0 then status ..= " A request is still pending; tools could not be restored yet." end
    end
    diagnostics.observed_new_models = observedCount
    diagnostics.observed_material_models = observedMaterialCount
    diagnostics.wall_elapsed_seconds = wallStarted and math.max(0, os.clock() - wallStarted) or 0
    diagnostics.verified_blocks_per_second = diagnostics.wall_elapsed_seconds > 0
        and completed / diagnostics.wall_elapsed_seconds or 0
    diagnostics.rpc_latency_mean_seconds = diagnostics.rpc_completed > 0
        and diagnostics.rpc_latency_total_seconds / diagnostics.rpc_completed or 0
    return {ok = success, message = status, completed = completed, total = #items, created = created,
        diagnostics = diagnostics}
end

function Adapter.teardown() destroyed = true end
return Adapter
end)()
local Backend = (function()
-- Image bytes are data only. All decoding and planning happen locally.
local Decoder = (function()
-- Local image decoding. The release builder substitutes the two reviewed modules.
-- No network, file access, Roblox image permissions, or external processes here.
local PNG = (function()
-- Modified for BAFT Image Builder: per-call checkpoints, bounded Huffman traversal,
-- and correct code-length repeats spanning DEFLATE literal/distance tables.
-- Upstream sircfenner/png-luau v0.2.1, MIT; see png-luau.LICENSE and PNG_PROVENANCE.md.
--!strict
--!native
--!optimize 2
type PNG__DARKLUA_TYPE_a = {
	width: number,
	height: number,
	pixels: buffer,
	readPixel: (x: number, y: number) -> (number, number, number, number),
}

type Chunk__DARKLUA_TYPE_b = {
	type: string,
	offset: number,
	length: number,
}

type IHDRChunk__DARKLUA_TYPE_c = {
	width: number,
	height: number,
	bitDepth: number,
	colorType: number,
	interlaced: boolean,
}

type PaletteColor__DARKLUA_TYPE_d = {
	r: number,
	g: number,
	b: number,
	a: number,
}

type PLTEChunk__DARKLUA_TYPE_e = {
	colors: { PaletteColor__DARKLUA_TYPE_d },
}

type tRNSChunk__DARKLUA_TYPE_f = {
	gray: number,
	red: number,
	green: number,
	blue: number,
}

type HuffmanTable__DARKLUA_TYPE_g = { number }
local __BUNDLE = { cache = {} :: any }
do
	do
		local function __modImpl()
			return {}
		end
		function __BUNDLE.a(): typeof(__modImpl())
			local v = __BUNDLE.cache.a
			if not v then
				v = { c = __modImpl() }
				__BUNDLE.cache.a = v
			end
			return v.c
		end
	end
	do
		local function __modImpl()
			__BUNDLE.a()

			local COLOR_TYPE_BIT_DEPTH = {
				[0] = { 1, 2, 4, 8, 16 },
				[2] = { 8, 16 },
				[3] = { 1, 2, 4, 8 },
				[4] = { 8, 16 },
				[6] = { 8, 16 },
			}

			local function read(buf: buffer, chunk: Chunk__DARKLUA_TYPE_b): IHDRChunk__DARKLUA_TYPE_c
				assert(chunk.length == 13, "IHDR data must be 13 bytes")

				local offset = chunk.offset

				local width = bit32.byteswap(buffer.readu32(buf, offset))
				local height = bit32.byteswap(buffer.readu32(buf, offset + 4))
				local bitDepth = buffer.readu8(buf, offset + 8)
				local colorType = buffer.readu8(buf, offset + 9)
				local compression = buffer.readu8(buf, offset + 10)
				local filter = buffer.readu8(buf, offset + 11)
				local interlace = buffer.readu8(buf, offset + 12)

				assert(width > 0 and width <= 2 ^ 31 and height > 0 and height <= 2 ^ 31, "invalid dimensions")
				assert(compression == 0, "invalid compression method")
				assert(filter == 0, "invalid filter method")
				assert(interlace == 0 or interlace == 1, "invalid interlace method")

				local allowedBitDepth = COLOR_TYPE_BIT_DEPTH[colorType]
				assert(allowedBitDepth ~= nil, "invalid color type")
				assert(table.find(allowedBitDepth, bitDepth) ~= nil, "invalid bit depth")

				return {
					width = width,
					height = height,
					bitDepth = bitDepth,
					colorType = colorType,
					interlaced = interlace == 1,
				}
			end

			return read
		end
		function __BUNDLE.b(): typeof(__modImpl())
			local v = __BUNDLE.cache.b
			if not v then
				v = { c = __modImpl() }
				__BUNDLE.cache.b = v
			end
			return v.c
		end
	end
	do
		local function __modImpl()
			__BUNDLE.a()

			local function read(
				buf: buffer,
				chunk: Chunk__DARKLUA_TYPE_b,
				header: IHDRChunk__DARKLUA_TYPE_c
			): PLTEChunk__DARKLUA_TYPE_e
				assert(chunk.length % 3 == 0, "malformed PLTE chunk")

				local count = chunk.length / 3
				assert(count > 0, "no entries in PLTE")
				assert(count <= 256, "too many entries in PLTE")
				assert(count <= 2 ^ header.bitDepth, "too many entries in PLTE for bit depth")

				local colors = table.create(count)
				local offset = chunk.offset

				for i = 1, count do
					colors[i] = {
						r = buffer.readu8(buf, offset),
						g = buffer.readu8(buf, offset + 1),
						b = buffer.readu8(buf, offset + 2),
						a = 255,
					}
					offset += 3
				end

				return {
					colors = colors,
				}
			end

			return read
		end
		function __BUNDLE.c(): typeof(__modImpl())
			local v = __BUNDLE.cache.c
			if not v then
				v = { c = __modImpl() }
				__BUNDLE.cache.c = v
			end
			return v.c
		end
	end
	do
		local function __modImpl()
			__BUNDLE.a()

			local function readU16(buf: buffer, offset: number, depth: number)
				return bit32.extract(
					bit32.bor(bit32.lshift(buffer.readu8(buf, offset), 8), buffer.readu8(buf, offset + 1)),
					0,
					depth
				)
			end

			local function read(
				buf: buffer,
				chunk: Chunk__DARKLUA_TYPE_b,
				header: IHDRChunk__DARKLUA_TYPE_c,
				palette: PLTEChunk__DARKLUA_TYPE_e?
			): tRNSChunk__DARKLUA_TYPE_f
				local gray = -1
				local red = -1
				local green = -1
				local blue = -1

				if header.colorType == 0 then
					assert(chunk.length == 2, "invalid tRNS length for color type")
					gray = readU16(buf, chunk.offset, header.bitDepth)
				elseif header.colorType == 2 then
					assert(chunk.length == 6, "invalid tRNS length for color type")
					red = readU16(buf, chunk.offset, header.bitDepth)
					green = readU16(buf, chunk.offset + 2, header.bitDepth)
					blue = readU16(buf, chunk.offset + 4, header.bitDepth)
				else
					local count = chunk.length
					assert(palette, "tRNS requires PLTE for color type")
					assert(count <= #palette.colors, "tRNS specified too many PLTE alphas")
					for i = 1, count do
						palette.colors[i].a = buffer.readu8(buf, chunk.offset + i - 1)
					end
				end

				return {
					gray = gray,
					red = red,
					green = green,
					blue = blue,
				}
			end

			return read
		end
		function __BUNDLE.d(): typeof(__modImpl())
			local v = __BUNDLE.cache.d
			if not v then
				v = { c = __modImpl() }
				__BUNDLE.cache.d = v
			end
			return v.c
		end
	end
	do
		local function __modImpl()
			return {
				IHDR = __BUNDLE.b(),
				PLTE = __BUNDLE.c(),
				tRNS = __BUNDLE.d(),
			}
		end
		function __BUNDLE.e(): typeof(__modImpl())
			local v = __BUNDLE.cache.e
			if not v then
				v = { c = __modImpl() }
				__BUNDLE.cache.e = v
			end
			return v.c
		end
	end
	do
		local function __modImpl()


-- stylua: ignore

local lookup = {
	0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3,
	0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91,
	0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
	0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5,
	0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B,
	0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
	0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F,
	0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D,
	0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
	0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01,
	0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457,
	0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
	0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB,
	0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9,
	0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
	0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD,
	0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A, 0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683,
	0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
	0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7,
	0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5,
	0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
	0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79,
	0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F,
	0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D,
	0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713,
	0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21,
	0x86D3D2D4, 0xF1D4E242, 0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
	0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45,
	0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB,
	0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
	0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF,
	0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94, 0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D,
}

			local function crc32(buf: buffer, i: number, j: number, checkpoint: (() -> ())?)
				local code = 0xFFFFFFFF
				for k = i, j do
					if checkpoint and (k - i) % 8192 == 0 then checkpoint() end
					code = bit32.bxor(
						bit32.rshift(code, 8),
						lookup[bit32.bxor(bit32.band(code, 0xFF), buffer.readu8(buf, k)) + 1]
					)
				end
				return bit32.bxor(code, 0xFFFFFFFF)
			end

			return crc32
		end
		function __BUNDLE.f(): typeof(__modImpl())
			local v = __BUNDLE.cache.f
			if not v then
				v = { c = __modImpl() }
				__BUNDLE.cache.f = v
			end
			return v.c
		end
	end
	do
		local function __modImpl()
			local MAX_BITS = 15

-- stylua: ignore
local LIT_LEN = {
	3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131,
	163, 195, 227, 258
}

-- stylua: ignore
local LIT_EXTRA = {
	1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0,
}

-- stylua: ignore
local DIST_OFF = {
	1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049,
	3073, 4097, 6145, 8193, 12289, 16385, 24577
}

-- stylua: ignore
local DIST_EXTRA = {
	0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13
}

-- stylua: ignore
local LEN_ORDER = {
	16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15
}

-- stylua: ignore
local FIXED_LIT = {
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
	9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
	9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
	9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8
}

			local WINDOW_LOOKAHEAD = 258
			local WINDOW_SEARCH = 0x8000 - WINDOW_LOOKAHEAD

			local MAX_CHAIN_NODES = 50_000
			local MAX_CHAIN_SEARCH = 12
			local MAX_MATCH_LENGTH = 96
			local DEFLATE_BLOCK_SIZE = 0x8000

			local function createHuffmanTable(
				lengths: { number }
			): (HuffmanTable__DARKLUA_TYPE_g, { number }, { number })
				local lengthCount = table.create(MAX_BITS, 0)
				lengthCount[0] = 0
				for _, length in lengths do
					if length > 0 then
						lengthCount[length] = (lengthCount[length] or 0) + 1
					end
				end

				local lastCode = 1
				local nextCode = table.create(MAX_BITS)
				for bits = 1, MAX_BITS do
					lastCode = bit32.lshift(lastCode + lengthCount[bits - 1], 1)
					nextCode[bits] = lastCode
				end

				local mapping = {}
				local codeValues = {}
				local codeLengths = {}
				for i, length in lengths do
					if length > 0 then
						mapping[nextCode[length]] = i - 1
						codeValues[i - 1] = bit32.extract(nextCode[length], 0, length)
						codeLengths[i - 1] = length
						nextCode[length] += 1
					end
				end

				return mapping, codeValues, codeLengths
			end

			local cachedLitValues = {}
			local cachedLitExtraValues = {}
			local cachedLitExtraBits = {}
			for length = 3, 258 do
				local idx
				for i = #LIT_LEN, 1, -1 do
					if length >= LIT_LEN[i] then
						idx = i
						break
					end
				end
				cachedLitValues[length] = 0x100 + idx
				cachedLitExtraValues[length] = length - LIT_LEN[idx]
				cachedLitExtraBits[length] = LIT_EXTRA[idx - 8] or 0
			end

			local cachedDistIndices = {}
			for distance = 1, 1024 do
				local distIdx
				for i = #DIST_OFF, 1, -1 do
					if distance >= DIST_OFF[i] then
						distIdx = i
						break
					end
				end
				cachedDistIndices[distance] = distIdx
			end

			local fixedLitTable, fixedLitCodeValues, fixedLitCodeLengths = createHuffmanTable(FIXED_LIT)
			local fixedDistTable, fixedDistCodeValues, fixedDistCodeLengths = createHuffmanTable(table.create(32, 5))

			local function getStoreSize(blockSize: number)
				return math.ceil(blockSize / DEFLATE_BLOCK_SIZE) * 5 + blockSize
			end

			local function getDistIdx(distance: number)
				return if distance < 1025
					then cachedDistIndices[distance]
					elseif distance < 1537 then 21
					elseif distance < 2049 then 22
					elseif distance < 3073 then 23
					elseif distance < 4097 then 24
					elseif distance < 6145 then 25
					elseif distance < 8193 then 26
					elseif distance < 12289 then 27
					elseif distance < 16385 then 28
					elseif distance < 24577 then 29
					else 30
			end

			local function adler32(input: buffer, offset: number, length: number, checkpoint: (() -> ())?): number
				local s0 = 1
				local s1 = 0
				local count = 0
				for i = offset, offset + length - 1 do
					if checkpoint and (i - offset) % 8192 == 0 then checkpoint() end
					s0 += buffer.readu8(input, i)
					s1 += s0
					count += 1
					if count == 8_400_000 then
						s0 %= 65521
						s1 %= 65521
						count = 0
					end
				end
				return bit32.bor(bit32.lshift(s1 % 65521, 16), s0 % 65521)
			end

			local function inflate(input: buffer, output: buffer, checkpoint: (() -> ())?): number
				local header0 = buffer.readu8(input, 0)
				local header1 = buffer.readu8(input, 1)
				assert(bit32.extract(header0, 0, 4) == 8, "invalid zlib comp method")
				assert(bit32.extract(header0, 4, 4) <= 7, "invalid zlib window size")
				assert(bit32.extract(header1, 5, 1) == 0, "preset dictionary is not allowed")
				assert(bit32.bor(bit32.lshift(header0, 8), header1) % 31 == 0, "zlib header sum mismatch")

				local readOffset = 2
				local readOffsetBit = 0

				local function readBit()
					local bit = bit32.extract(buffer.readu8(input, readOffset), readOffsetBit)
					readOffsetBit += 1
					if readOffsetBit == 8 then
						readOffsetBit = 0
						readOffset += 1
					end
					return bit
				end

				local function readBits(n: number)
					local bits = buffer.readbits(input, readOffset * 8 + readOffsetBit, n)
					readOffsetBit += n
					readOffset += bit32.rshift(readOffsetBit, 3)
					readOffsetBit = bit32.band(readOffsetBit, 0b111)
					return bits
				end

				local function readHuffmanTable(huffmanTable: HuffmanTable__DARKLUA_TYPE_g): number
					local code = 2 + readBit()
					local depth = 1
					while not huffmanTable[code] do
						assert(depth < 15, "invalid Huffman code")
						depth += 1
						code = 2 * code + readBit()
					end
					return huffmanTable[code]
				end

				local writeOffset = 0
				local steps = 0

				repeat
					if checkpoint then checkpoint() end
					local bfinal = readBit()
					local btype = readBits(2)
					assert(btype ~= 0b11, "reserved btype")

					if btype == 0b00 then
						if readOffsetBit > 0 then
							readOffset += 1
							readOffsetBit = 0
						end
						local len = buffer.readu16(input, readOffset)
						assert(bit32.bxor(len, buffer.readu16(input, readOffset + 2)) == 0xFFFF, "len ~= nlen")
						readOffset += 4
						buffer.copy(output, writeOffset, input, readOffset, len)
						writeOffset += len
						readOffset += len
					else
						local litTable = fixedLitTable
						local distTable = fixedDistTable

						if btype == 0b10 then
							local litsCount = readBits(5) + 257
							local distsCount = readBits(5) + 1
							local codesCount = readBits(4) + 4

							local codeLengths = table.create(19, 0)
							for i = 1, codesCount do
								codeLengths[LEN_ORDER[i] + 1] = readBits(3)
							end
							local codeLengthsTable = createHuffmanTable(codeLengths)

							local totalCount = litsCount + distsCount
							local lengths = table.create(totalCount)
							local previousLength
							repeat
							    local code = readHuffmanTable(codeLengthsTable)
							    local repeatCount = 1
							    local value
							    if code <= 15 then
							        value = code
							    elseif code == 16 then
							        assert(previousLength ~= nil, "code-length repeat has no previous value")
							        value = previousLength
							        repeatCount = readBits(2) + 3
							    elseif code == 17 then
							        value = 0
							        repeatCount = readBits(3) + 3
							    elseif code == 18 then
							        value = 0
							        repeatCount = readBits(7) + 11
							    else
							        error("invalid code-length symbol")
							    end
							    assert(#lengths + repeatCount <= totalCount, "code-length repeat exceeds table size")
							    for _ = 1, repeatCount do table.insert(lengths, value) end
							    previousLength = value
							until #lengths == totalCount
							local litLengths = table.create(litsCount)
							local distLengths = table.create(distsCount)
							for i = 1, litsCount do litLengths[i] = lengths[i] end
							for i = 1, distsCount do distLengths[i] = lengths[litsCount + i] end
							assert(litLengths[257] ~= 0, "missing end-of-block Huffman symbol")
							litTable = createHuffmanTable(litLengths)
							distTable = createHuffmanTable(distLengths)
						end

						repeat
							steps += 1
							if checkpoint and steps % 2048 == 0 then checkpoint() end
							local v = readHuffmanTable(litTable)
							if v < 0x100 then
								buffer.writeu8(output, writeOffset, v)
								writeOffset += 1
							elseif v > 0x100 then
								local len = LIT_LEN[v - 0x100]
								if v > 0x10C then
									len += readBits(LIT_EXTRA[v - 0x108])
								elseif v > 0x108 then
									len += readBit()
								end

								local d = readHuffmanTable(distTable)
								local dist = DIST_OFF[d + 1]
								if d > 5 then
									dist += readBits(DIST_EXTRA[d])
								elseif d > 3 then
									dist += readBit()
								end

								if len <= dist then
									buffer.copy(output, writeOffset, output, writeOffset - dist, len)
									writeOffset += len
								else
									repeat
										local size = math.min(len, dist)
										buffer.copy(output, writeOffset, output, writeOffset - dist, size)
										writeOffset += size
										len -= size
										dist += size
									until len == 0
								end
							end
						until v == 0x100
					end
				until bfinal == 0b1

				if readOffsetBit > 0 then
					readOffsetBit = 0
					readOffset += 1
				end

				assert(
					adler32(output, 0, buffer.len(output), checkpoint) == bit32.byteswap(buffer.readu32(input, readOffset)),
					"adler-32 checksum mismatch"
				)

				return writeOffset
			end

			local function deflate(input: buffer): (buffer, number)
				local inputSize = buffer.len(input)
				local output = buffer.create(getStoreSize(inputSize) + 6)

				buffer.writeu16(output, 0, 0b01_0_11110_0111_1000)

				local writeOffset = 2
				local writeOffsetBits = 0

				local function writeBits(n: number, width: number)
					buffer.writebits(output, writeOffset * 8 + writeOffsetBits, width, n)
					writeOffsetBits += width
					writeOffset += bit32.rshift(writeOffsetBits, 3)
					writeOffsetBits = bit32.band(writeOffsetBits, 0b111)
				end

				local function writeHuffmanBits(n: number, w: number)
					n = bit32.bor(
						bit32.band(bit32.rshift(n, 1), 0x55555555),
						bit32.band(bit32.lshift(n, 1), 0xAAAAAAAA)
					)
					n = bit32.bor(
						bit32.band(bit32.rshift(n, 2), 0x33333333),
						bit32.band(bit32.lshift(n, 2), 0xCCCCCCCC)
					)
					n = bit32.bor(
						bit32.band(bit32.rshift(n, 4), 0x0F0F0F0F),
						bit32.band(bit32.lshift(n, 4), 0xF0F0F0F0)
					)
					n = bit32.bor(
						bit32.band(bit32.rshift(n, 8), 0x00FF00FF),
						bit32.band(bit32.lshift(n, 8), 0xFF00FF00)
					)
					n = bit32.bor(bit32.rshift(n, 16), bit32.lshift(n, 16))
					n = bit32.band(bit32.rshift(n, 32 - w), bit32.lshift(1, w) - 1)
					writeBits(n, w)
				end

				local function writeLitOrLen(value: number)
					writeHuffmanBits(fixedLitCodeValues[value], fixedLitCodeLengths[value])
				end

				local function writeBackRef(distance: number, length: number)
					writeLitOrLen(cachedLitValues[length])
					if length > 10 then
						writeBits(cachedLitExtraValues[length], cachedLitExtraBits[length])
					end
					local distIdx = getDistIdx(distance)
					writeHuffmanBits(fixedDistCodeValues[distIdx - 1], fixedDistCodeLengths[distIdx - 1])
					if distIdx > 3 then
						writeBits(distance - DIST_OFF[distIdx], DIST_EXTRA[distIdx - 1])
					end
				end

				local function getLitOrLenSize(value: number)
					return fixedLitCodeLengths[value]
				end

				local function getBackRefSize(distance: number, length: number)
					local distIdx = getDistIdx(distance)
					return getLitOrLenSize(cachedLitValues[length])
						+ cachedLitExtraBits[length]
						+ fixedDistCodeLengths[distIdx - 1]
						+ (DIST_EXTRA[distIdx - 1] or 0)
				end

				local offsets = {}
				local nexts = {}
				local heads = {}
				local nodeCount = 0

				local function insertNode(offset: number, nextIndex: number)
					nodeCount += 1
					offsets[nodeCount] = offset
					nexts[nodeCount] = nextIndex
					return nodeCount
				end

				local function clearTables()
					table.clear(offsets)
					table.clear(nexts)
					table.clear(heads)
					nodeCount = 0
				end

				for startReadOffset = 0, inputSize - 1, DEFLATE_BLOCK_SIZE do
					local huffmanSizeBits = 0

					local nextBlockReadOffset = math.min(inputSize, startReadOffset + DEFLATE_BLOCK_SIZE)
					local readOffset = startReadOffset

					local tokens: { vector } = {}
					while readOffset < nextBlockReadOffset - 3 do
						local hash = bit32.band(buffer.readu32(input, readOffset), 0xFFFFFF)
						local newNodeIndex = insertNode(readOffset, heads[hash] or 0)
						heads[hash] = newNodeIndex

						local bestLength = 0
						local bestOffset = -1

						local chainCount = 0
						local nodeIndex = nexts[newNodeIndex]
						while
							nodeIndex
							and (offsets[nodeIndex] or -math.huge) >= readOffset - WINDOW_SEARCH
							and chainCount < MAX_CHAIN_SEARCH
							and bestLength < MAX_MATCH_LENGTH
						do
							local searchLength = 3
							local searchOffset = offsets[nodeIndex]

							local exit = false
							local limit = math.min(nextBlockReadOffset, readOffset + WINDOW_LOOKAHEAD)
							if
								readOffset + bestLength < limit
								and buffer.readu8(input, searchOffset + bestLength)
									~= buffer.readu8(input, readOffset + bestLength)
							then
								exit = true
							end

							while
								not exit
								and searchLength < WINDOW_LOOKAHEAD
								and readOffset + searchLength < nextBlockReadOffset
								and buffer.readu8(input, searchOffset + searchLength)
									== buffer.readu8(input, readOffset + searchLength)
							do
								searchLength += 1
							end
							if searchLength > bestLength then
								bestLength = searchLength
								bestOffset = searchOffset
								if bestLength >= WINDOW_LOOKAHEAD then
									break
								end
							end
							nodeIndex = nexts[nodeIndex]
							chainCount += 1
						end

						if bestLength == 0 then
							local b = buffer.readu8(input, readOffset)
							huffmanSizeBits += getLitOrLenSize(b)
							table.insert(tokens, vector.create(0, b))
							readOffset += 1
						else
							huffmanSizeBits += getBackRefSize(readOffset - bestOffset, bestLength)
							table.insert(tokens, vector.create(1, readOffset - bestOffset, bestLength))
							for newOffset = readOffset + 1, math.min(readOffset + bestLength - 1, nextBlockReadOffset - 4) do
								local newHash = bit32.band(buffer.readu32(input, newOffset), 0xFFFFFF)
								heads[newHash] = insertNode(newOffset, heads[newHash] or 0)
							end
							readOffset += bestLength
						end
					end

					while readOffset < nextBlockReadOffset do
						local b = buffer.readu8(input, readOffset)
						huffmanSizeBits += getLitOrLenSize(b)
						table.insert(tokens, vector.create(0, b))
						readOffset += 1
					end

					huffmanSizeBits += getLitOrLenSize(0x100)
					table.insert(tokens, vector.create(0, 0x100))

					if nextBlockReadOffset == inputSize then
						writeBits(0b1, 1)
					else
						writeBits(0b0, 1)
					end

					local blockLength = nextBlockReadOffset - startReadOffset
					local fixedHuffmanSize = math.ceil(huffmanSizeBits / 8) + 1
					if fixedHuffmanSize < getStoreSize(blockLength) then
						writeBits(0b01, 2)
						for _, token in tokens do
							if token.x == 0 then
								writeLitOrLen(token.y)
							else
								writeBackRef(token.y, token.z)
							end
						end
					else
						writeBits(0b00, 2)
						if writeOffsetBits > 0 then
							writeOffset += 1
							writeOffsetBits = 0
						end
						buffer.writeu16(output, writeOffset, blockLength)
						buffer.writeu16(output, writeOffset + 2, bit32.bxor(0xFFFF, blockLength))
						buffer.copy(output, writeOffset + 4, input, startReadOffset, blockLength)
						writeOffset += 4 + blockLength
					end

					if nodeCount > MAX_CHAIN_NODES then
						clearTables()
					end
				end

				if writeOffsetBits > 0 then
					writeOffset += 1
				end

				local checksum = adler32(input, 0, buffer.len(input))
				buffer.writeu32(output, writeOffset, bit32.byteswap(checksum))

				return output, writeOffset + 4
			end

			return {
				inflate = inflate,
				deflate = deflate,
			}
		end
		function __BUNDLE.g(): typeof(__modImpl())
			local v = __BUNDLE.cache.g
			if not v then
				v = { c = __modImpl() }
				__BUNDLE.cache.g = v
			end
			return v.c
		end
	end
end
__BUNDLE.a()

local chunkReaders = __BUNDLE.e()
local crc32 = __BUNDLE.f()
local zlib = __BUNDLE.g()

local COLOR_TYPE_CHANNELS = {
	[0] = 1,
	[2] = 3,
	[3] = 1,
	[4] = 2,
	[6] = 4,
}

local INTERLACE_ROW_START = { 0, 0, 4, 0, 2, 0, 1 }
local INTERLACE_COL_START = { 0, 4, 0, 2, 0, 1, 0 }
local INTERLACE_ROW_INCR = { 8, 8, 8, 4, 4, 2, 2 }
local INTERLACE_COL_INCR = { 8, 8, 4, 4, 2, 2, 1 }

-- selene: allow(bad_string_escape)
local SIGNATURE = "\x89PNG\x0D\x0A\x1A\x0A"

export type PNG = PNG__DARKLUA_TYPE_a

export type DecodeOptions = {
	allowIncorrectCRC: boolean?,
	checkpoint: (() -> ())?,
}

export type EncodeOptions = {
	width: number,
	height: number,
}

local function decode(buf: buffer, options: DecodeOptions?): PNG
	local checkpoint = options and options.checkpoint
	local bufLen = buffer.len(buf)
	assert(bufLen >= 8, "not a PNG")
	assert(buffer.readstring(buf, 0, 8) == SIGNATURE, "not a PNG")

	local chunks: { Chunk__DARKLUA_TYPE_b } = table.create(3)
	local offset = 8

	local skipCRC = options ~= nil and options.allowIncorrectCRC == true
	repeat
		if checkpoint then checkpoint() end
		local dataLength = bit32.byteswap(buffer.readu32(buf, offset))
		local chunkType = buffer.readstring(buf, offset + 4, 4)
		assert(string.match(chunkType, "%a%a%a%a"), `invalid chunk type {chunkType}`)

		local dataOffset = offset + 8
		local nextOffset = dataOffset + dataLength + 4
		assert(nextOffset <= bufLen, `EOF while reading {chunkType} chunk`)

		local chunkCode = bit32.byteswap(buffer.readu32(buf, nextOffset - 4))
		local expectCode = crc32(buf, offset + 4, nextOffset - 5, checkpoint)
		assert(skipCRC or chunkCode == expectCode, `incorrect checksum in {chunkType}`)

		table.insert(chunks, {
			type = chunkType,
			offset = dataOffset,
			length = dataLength,
		})
		offset = nextOffset
	until offset >= bufLen
	assert(offset == bufLen, "trailing data in file")

	for _, chunk in chunks do
		local t = chunk.type
		if bit32.extract(string.byte(t, 1, 1), 5) == 0 then
			if t ~= "IHDR" and t ~= "IDAT" and t ~= "PLTE" and t ~= "IEND" then
				error(`unhandled critical chunk {t}`)
			end
		end
	end

	local header: IHDRChunk__DARKLUA_TYPE_c
	local headerChunk = chunks[1]
	assert(headerChunk.type == "IHDR", "first chunk must be IHDR")
	for i = 2, #chunks do
		assert(chunks[i].type ~= "IHDR", "multiple IHDR chunks are not allowed")
	end
	header = chunkReaders.IHDR(buf, headerChunk)

	local dataChunkIndex0 = -1
	local dataChunkIndex1 = -1
	local compressedDataLength = 0
	for i, chunk in chunks do
		if chunk.type == "IDAT" then
			if dataChunkIndex0 < 0 then
				dataChunkIndex0 = i
			else
				assert(i == dataChunkIndex1 + 1, "multiple IDAT chunks must be consecutive")
			end
			dataChunkIndex1 = i
			compressedDataLength += chunk.length
		end
	end
	assert(dataChunkIndex0 > 0, "no IDAT chunks")
	assert(compressedDataLength > 0, "no image data in IDAT chunks")

	local palette: PLTEChunk__DARKLUA_TYPE_e?
	local paletteChunkIndex = -1
	for i, chunk in chunks do
		if chunk.type == "PLTE" then
			assert(not palette, "multiple PLTE chunks are not allowed")
			assert(i < dataChunkIndex0, "PLTE not allowed after IDAT chunks")
			assert(header.colorType ~= 0 and header.colorType ~= 4, "PLTE not allowed for color type")
			palette = chunkReaders.PLTE(buf, chunk, header)
			paletteChunkIndex = i
		end
	end
	if header.colorType == 3 then
		assert(palette ~= nil, "color type requires a PLTE chunk")
	end

	local transparencyData: tRNSChunk__DARKLUA_TYPE_f?
	for i, chunk in chunks do
		if chunk.type == "tRNS" then
			assert(transparencyData == nil, "multiple tRNS chunks are not allowed")
			assert(i < dataChunkIndex0, "tRNS not allowed after IDAT chunks")
			assert(not palette or i > paletteChunkIndex, "tRNS must be after PLTE")
			assert(header.colorType ~= 4 and header.colorType ~= 6, "tRNS not allowed for color type")
			transparencyData = chunkReaders.tRNS(buf, chunk, header, palette)
		end
	end

	local finalChunk = chunks[#chunks]
	assert(finalChunk.type == "IEND", "final chunk must be IEND")
	assert(finalChunk.length == 0, "IEND chunk must be empty")
	for i = 2, #chunks - 1 do
		assert(chunks[i].type ~= "IEND", "multiple IEND chunks are not allowed")
	end

	local compressedData = buffer.create(compressedDataLength)
	local compressedOffset = 0
	for _, chunk in chunks do
		if chunk.type == "IDAT" then
			buffer.copy(compressedData, compressedOffset, buf, chunk.offset, chunk.length)
			compressedOffset += chunk.length
		end
	end

	local width = header.width
	local height = header.height
	local bitDepth = header.bitDepth
	local colorType = header.colorType
	local channels = COLOR_TYPE_CHANNELS[colorType]

	local rawSize = 0
	if not header.interlaced then
		rawSize = height * (math.ceil(width * channels * bitDepth / 8) + 1)
	else
		for i = 1, 7 do
			local w = math.ceil((width - INTERLACE_COL_START[i]) / INTERLACE_COL_INCR[i])
			local h = math.ceil((height - INTERLACE_ROW_START[i]) / INTERLACE_ROW_INCR[i])
			if w > 0 and h > 0 then
				local scanlineSize = math.ceil(w * channels * bitDepth / 8) + 1
				rawSize += h * scanlineSize
			end
		end
	end

	local paletteColors
	if palette then
		paletteColors = palette.colors
	end

	local rescale
	if colorType ~= 3 and bitDepth < 8 then
		rescale = 0xFF / (2 ^ bitDepth - 1)
	end

	local bpp = math.ceil(channels * bitDepth / 8)
	local defaultAlpha = 2 ^ bitDepth - 1

	local idx = 0
	local working = buffer.create(rawSize)
	local inflatedSize = zlib.inflate(compressedData, working, checkpoint)
	assert(inflatedSize == rawSize, "decompressed data size mismatch")

	local rgba8 = buffer.create(width * height * 4)

	local alphaGray = if transparencyData then transparencyData.gray else -1
	local alphaRed = if transparencyData then transparencyData.red else -1
	local alphaGreen = if transparencyData then transparencyData.green else -1
	local alphaBlue = if transparencyData then transparencyData.blue else -1

	local function pass(sx: number, sy: number, dx: number, dy: number)
		local w = math.ceil((width - sx) / dx)
		local h = math.ceil((height - sy) / dy)
		if w < 1 or h < 1 then
			return
		end

		local scanlineSize = math.ceil(w * channels * bitDepth / 8)
		local newIdx = idx

		for y = 1, h do
			if checkpoint then checkpoint() end
			local rowFilter = buffer.readu8(working, idx)
			idx += 1

			if rowFilter == 0 or (rowFilter == 2 and y == 1) then
				idx += scanlineSize
			elseif rowFilter == 1 then
				for x = 1, scanlineSize do
					local sub = if x <= bpp then 0 else buffer.readu8(working, idx - bpp)
					local value = bit32.band(buffer.readu8(working, idx) + sub, 0xFF)
					buffer.writeu8(working, idx, value)
					idx += 1
				end
			elseif rowFilter == 2 then
				for _ = 1, scanlineSize do
					local up = buffer.readu8(working, idx - scanlineSize - 1)
					local value = bit32.band(buffer.readu8(working, idx) + up, 0xFF)
					buffer.writeu8(working, idx, value)
					idx += 1
				end
			elseif rowFilter == 3 then
				for x = 1, scanlineSize do
					local sub = if x <= bpp then 0 else buffer.readu8(working, idx - bpp)
					local up = if y == 1 then 0 else buffer.readu8(working, idx - scanlineSize - 1)
					local value = bit32.band(buffer.readu8(working, idx) + bit32.rshift(sub + up, 1), 0xFF)
					buffer.writeu8(working, idx, value)
					idx += 1
				end
			elseif rowFilter == 4 then
				for x = 1, scanlineSize do
					local sub = if x <= bpp then 0 else buffer.readu8(working, idx - bpp)
					local up = if y == 1 then 0 else buffer.readu8(working, idx - scanlineSize - 1)
					local corner = if x <= bpp or y == 1
						then 0
						else buffer.readu8(working, idx - scanlineSize - bpp - 1)
					local p0 = math.abs(up - corner)
					local p1 = math.abs(sub - corner)
					local p2 = math.abs(sub + up - 2 * corner)
					local paeth = if p0 <= p1 and p0 <= p2 then sub elseif p1 <= p2 then up else corner
					local value = bit32.band(buffer.readu8(working, idx) + paeth, 0xFF)
					buffer.writeu8(working, idx, value)
					idx += 1
				end
			else
				error("invalid row filter")
			end
		end

		local bit = 8
		local function readValue()
			local b = buffer.readu8(working, newIdx)
			if bitDepth < 8 then
				b = bit32.extract(b, bit - bitDepth, bitDepth)
				bit -= bitDepth
				if bit == 0 then
					bit = 8
					newIdx += 1
				end
			elseif bitDepth == 8 then
				newIdx += 1
			else
				b = bit32.bor(bit32.lshift(b, 8), buffer.readu8(working, newIdx + 1))
				newIdx += 2
			end
			return b
		end

		for y = 1, h do
			if checkpoint then checkpoint() end
			newIdx += 1
			if bit < 8 then
				bit = 8
				newIdx += 1
			end

			for x = 1, w do
				local r, g, b, a

				if colorType == 0 then
					local gray = readValue()
					r = gray
					g = gray
					b = gray
					a = if gray == alphaGray then 0 else defaultAlpha
				elseif colorType == 2 then
					r = readValue()
					g = readValue()
					b = readValue()
					a = if r == alphaRed and g == alphaGreen and b == alphaBlue then 0 else defaultAlpha
				elseif colorType == 3 then
					local color = paletteColors[readValue() + 1]
					r = color.r
					g = color.g
					b = color.b
					a = color.a
				elseif colorType == 4 then
					local gray = readValue()
					r = gray
					g = gray
					b = gray
					a = readValue()
				elseif colorType == 6 then
					r = readValue()
					g = readValue()
					b = readValue()
					a = readValue()
				end

				local py = sy + (y - 1) * dy
				local px = sx + (x - 1) * dx
				local i = (py * width + px) * 4

				if rescale then
					r = math.round(r * rescale)
					g = math.round(g * rescale)
					b = math.round(b * rescale)
					a = math.round(a * rescale)
				elseif bitDepth == 16 then
					r = bit32.rshift(r, 8)
					g = bit32.rshift(g, 8)
					b = bit32.rshift(b, 8)
					a = bit32.rshift(a, 8)
				end

				buffer.writeu32(rgba8, i, bit32.bor(bit32.lshift(a, 24), bit32.lshift(b, 16), bit32.lshift(g, 8), r))
			end
		end
	end

	if not header.interlaced then
		pass(0, 0, 1, 1)
	else
		for i = 1, 7 do
			pass(INTERLACE_COL_START[i], INTERLACE_ROW_START[i], INTERLACE_COL_INCR[i], INTERLACE_ROW_INCR[i])
		end
	end

	local function readPixel(x: number, y: number)
		assert(x >= 1 and x <= width and y >= 1 and y <= height, "pixel out of range")

		local i = ((y - 1) * width + x - 1) * 4
		return buffer.readu8(rgba8, i),
			buffer.readu8(rgba8, i + 1),
			buffer.readu8(rgba8, i + 2),
			buffer.readu8(rgba8, i + 3)
	end

	return {
		width = width,
		height = height,
		pixels = rgba8,
		readPixel = readPixel,
	}
end

local function encode(pixels: buffer, options: EncodeOptions): buffer
	local width = options.width
	local height = options.height

	local dataSize = buffer.len(pixels)
	local expectSize = width * height * 4
	assert(dataSize == expectSize, `expected {expectSize} bytes, got {dataSize} bytes`)

	local imageDataRowSize = width * 4 + 1
	local imageData = buffer.create(height * imageDataRowSize)
	for row = 0, height - 1 do
		local sourceOffset = row * width * 4
		local targetOffset = row * imageDataRowSize
		buffer.writeu8(imageData, targetOffset, 0)
		buffer.copy(imageData, targetOffset + 1, pixels, sourceOffset, 4 * width)
	end

	local imageDataDeflated, imageDataDeflatedLength = zlib.deflate(imageData)
	local outputLength = 8 + 25 + (8 + imageDataDeflatedLength + 4) + 12

	local output = buffer.create(outputLength)
	buffer.writestring(output, 0, SIGNATURE)

	buffer.writeu32(output, 8, bit32.byteswap(13))
	buffer.writestring(output, 12, "IHDR")
	buffer.writeu32(output, 16, bit32.byteswap(width))
	buffer.writeu32(output, 20, bit32.byteswap(height))
	buffer.writeu8(output, 24, 8)
	buffer.writeu8(output, 25, 6)
	buffer.writeu8(output, 26, 0)
	buffer.writeu8(output, 27, 0)
	buffer.writeu8(output, 28, 0)
	buffer.writeu32(output, 29, bit32.byteswap(crc32(output, 12, 28)))

	buffer.writeu32(output, 33, bit32.byteswap(imageDataDeflatedLength))
	buffer.writestring(output, 37, "IDAT")
	buffer.copy(output, 41, imageDataDeflated, 0, imageDataDeflatedLength)
	local x = 41 + imageDataDeflatedLength
	buffer.writeu32(output, x, bit32.byteswap(crc32(output, 37, x - 1)))

	buffer.writeu32(output, x + 4, 0)
	buffer.writestring(output, x + 8, "IEND")
	buffer.writeu32(output, x + 12, 0x826042AE)

	return output
end

return {
	decode = decode,
	encode = encode,
}
end)()
local JPEG = (function()
-- Pure Luau JPEG decoder, adapted from jpeg-js/lib/decoder.js.
-- Copyright 2011 notmasteryet; licensed under Apache-2.0.
-- Pinned upstream: 1031ccd7a63c641c16afb2430279d1598530a85c.
-- Changes: strict bounded parser, flat coefficient buffers, floating-point IDCT,
-- cooperative checkpoints, RGBA output, and EXIF orientation. See vendor/jpeg-js.
-- Supports 8-bit Huffman baseline/extended sequential and progressive gray/YCbCr/RGB.
local JPEG = {}
local MAX_INPUT, MAX_AXIS, MAX_PIXELS = 10 * 1024 * 1024, 4096, 4194304
local MAX_MEMORY, MAX_WORK = 96 * 1024 * 1024, 134217728
local floor, ceil, abs = math.floor, math.ceil, math.abs
local zig = {0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5,12,19,26,33,40,48,41,34,27,20,13,6,
    7,14,21,28,35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51,58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63}
local basis = {}
for x = 0, 7 do
    local row = {}
    for u = 0, 7 do row[u + 1] = (u == 0 and math.sqrt(0.5) or 1) * math.cos((2 * x + 1) * u * math.pi / 16) end
    basis[x + 1] = row
end
local function bad(message) error("JPEG: " .. message, 0) end
local function byteClamp(value) return math.clamp(floor(value + 0.5), 0, 255) end

function JPEG.decode(bytes, hooks)
    local kind = typeof(bytes)
    if kind ~= "buffer" and type(bytes) ~= "string" then bad("expected image bytes") end
    local length = kind == "buffer" and buffer.len(bytes) or #bytes
    if length < 4 or length > MAX_INPUT then bad("input must be 4 bytes to 10 MiB") end
    local data = kind == "buffer" and bytes or buffer.fromstring(bytes)
    local checkpoint = hooks and hooks.checkpoint
    if checkpoint ~= nil and type(checkpoint) ~= "function" then bad("invalid checkpoint hook") end
    local function tick() if checkpoint then checkpoint() end end
    tick()
    local memory = kind == "buffer" and length or length * 2
    local function allocate(size)
        if size < 0 or size % 1 ~= 0 or memory + size > MAX_MEMORY then bad("working-memory limit exceeded") end
        memory += size
        return buffer.create(size)
    end
    local function at(index)
        if index < 0 or index >= length then bad("truncated image") end
        return buffer.readu8(data, index)
    end
    local pos = 0
    local function byte() local v = at(pos); pos += 1; return v end
    local function word() local a, b = byte(), byte(); return a * 256 + b end
    local function marker()
        if byte() ~= 255 then bad("expected a marker") end
        local code = byte()
        while code == 255 do code = byte() end
        if code == 0 then bad("unexpected stuffed byte outside a scan") end
        return code
    end
    if word() ~= 65496 then bad("missing SOI marker") end
    local quant, dcTables, acTables = {}, {}, {}
    local frame, restart, orientation, adobe = nil, 0, 1, nil
    local sawEnd, scans, markers, work, tableDefinitions = false, 0, 0, 0, 0
    local function defineTable()
        tableDefinitions += 1
        if tableDefinitions > 256 then bad("table definition limit exceeded") end
    end

    local function readExif(start, finish)
        if finish - start < 14 or buffer.readstring(data, start, 6) ~= "Exif\0\0" then return end
        local base = start + 6
        local little = at(base) == 73 and at(base + 1) == 73
        if not little and not (at(base) == 77 and at(base + 1) == 77) then return end
        local function u16(p)
            if p < base or p + 2 > finish then return nil end
            local a, b = at(p), at(p + 1)
            return little and a + b * 256 or a * 256 + b
        end
        local function u32(p)
            local a, b = u16(p), u16(p + 2)
            if a == nil or b == nil then return nil end
            return little and a + b * 65536 or a * 65536 + b
        end
        if u16(base + 2) ~= 42 then return end
        local offset = u32(base + 4)
        if not offset then return end
        local directory = base + offset
        local count = u16(directory)
        if not count or count > 4096 or directory + 2 + count * 12 > finish then return end
        for i = 0, count - 1 do
            local entry = directory + 2 + i * 12
            if u16(entry) == 274 and u16(entry + 2) == 3 and u32(entry + 4) == 1 then
                local value = u16(entry + 8)
                if value and value >= 1 and value <= 8 then orientation = value end
                return
            end
        end
    end

    local function makeHuffman(counts, values)
        local minimum, maximum, offset = {}, {}, {}
        local code, index = 0, 1
        for n = 1, 16 do
            local count = counts[n]
            if code + count > 2 ^ n then bad("oversubscribed Huffman table") end
            minimum[n], maximum[n], offset[n] = code, code + count - 1, index - code
            index += count
            code = (code + count) * 2
        end
        if index == 1 then bad("empty Huffman table") end
        return {minimum = minimum, maximum = maximum, offset = offset, values = values}
    end

    local function decodeScan(components, spectralStart, spectralEnd, previous, successive)
        local bitCount, bitData, eob, acState, nextValue = 0, 0, 0, 0, 0
        local scanStart = pos
        local function bit()
            if bitCount == 0 then
                bitData = byte()
                if bitData == 255 and byte() ~= 0 then bad("unexpected marker inside entropy data") end
                bitCount = 8
            end
            bitCount -= 1
            return floor(bitData / 2 ^ bitCount) % 2
        end
        local function receive(n)
            if n < 0 or n > 16 then bad("invalid coefficient bit length") end
            local value = 0
            for _ = 1, n do value = value * 2 + bit() end
            return value
        end
        local function extend(n)
            if n == 0 then return 0 end
            local value = receive(n)
            return value >= 2 ^ (n - 1) and value or value + 1 - 2 ^ n
        end
        local function huffman(t)
            if not t then bad("missing Huffman table") end
            local code = 0
            for n = 1, 16 do
                code = code * 2 + bit()
                if code >= t.minimum[n] and code <= t.maximum[n] then return t.values[code + t.offset[n]] end
            end
            bad("invalid Huffman code")
        end
        local shift = 2 ^ successive
        local visited = 0
        local function block(c, bx, by)
            if bx < 0 or bx >= c.stride or by < 0 or by >= c.paddedRows then bad("invalid scan block") end
            local base = (by * c.stride + bx) * 256
            local function read(k) return buffer.readi32(c.blocks, base + k * 4) end
            local function put(k, value)
                if abs(value) > 1048576 then bad("coefficient range exceeded") end
                buffer.writei32(c.blocks, base + k * 4, value)
            end
            work += frame.progressive and (spectralEnd - spectralStart + 1) * 2 or 64
            if work > MAX_WORK then bad("scan work limit exceeded") end
            visited += 1
            if visited % 128 == 0 then tick() end
            if not frame.progressive then
                local category = huffman(c.dc)
                if category > 11 then bad("invalid DC category") end
                c.pred += extend(category); put(0, c.pred)
                local k = 1
                while k < 64 do
                    local value = huffman(c.ac)
                    local size, run = value % 16, floor(value / 16)
                    if size == 0 then
                        if run ~= 15 then
                            if run ~= 0 then bad("invalid sequential end-of-block code") end
                            break
                        end
                        k += 16
                        if k > 64 then bad("AC run exceeds block") end
                    else
                        if size > 10 then bad("invalid AC category") end
                        k += run
                        if k >= 64 then bad("AC run exceeds block") end
                        put(zig[k + 1], extend(size)); k += 1
                    end
                end
            elseif spectralStart == 0 then
                if previous == 0 then
                    local category = huffman(c.dc)
                    if category > 11 then bad("invalid progressive DC category") end
                    c.pred += extend(category) * shift; put(0, c.pred)
                else put(0, read(0) + bit() * shift) end
            elseif previous == 0 then
                if eob > 0 then eob -= 1; return end
                local k = spectralStart
                while k <= spectralEnd do
                    local value = huffman(c.ac)
                    local size, run = value % 16, floor(value / 16)
                    if size == 0 then
                        if run < 15 then eob = receive(run) + 2 ^ run - 1; break end
                        k += 16
                        if k > spectralEnd + 1 then bad("progressive AC run exceeds band") end
                    else
                        if size > 10 then bad("invalid progressive AC category") end
                        k += run
                        if k > spectralEnd then bad("progressive AC run exceeds band") end
                        put(zig[k + 1], extend(size) * shift); k += 1
                    end
                end
            else
                local k, run = spectralStart, 0
                while k <= spectralEnd do
                    local z = zig[k + 1]
                    local value = read(z)
                    local direction = value < 0 and -1 or 1
                    if acState == 0 then
                        local rs = huffman(c.ac)
                        local size = rs % 16
                        run = floor(rs / 16)
                        if size == 0 then
                            if run < 15 then eob = receive(run) + 2 ^ run; acState = 4
                            else run = 16; acState = 1 end
                        else
                            if size ~= 1 then bad("invalid AC refinement") end
                            nextValue = extend(size)
                            acState = run > 0 and 2 or 3
                        end
                        continue
                    elseif acState == 1 or acState == 2 then
                        if value ~= 0 then put(z, value + bit() * shift * direction)
                        else
                            run -= 1
                            if run == 0 then acState = acState == 2 and 3 or 0 end
                        end
                    elseif acState == 3 then
                        if value ~= 0 then put(z, value + bit() * shift * direction)
                        else put(z, nextValue * shift); acState = 0 end
                    elseif acState == 4 and value ~= 0 then put(z, value + bit() * shift * direction) end
                    k += 1
                end
                if acState == 4 then eob -= 1; if eob == 0 then acState = 0 end
                elseif acState ~= 0 then bad("AC refinement run exceeds band") end
            end
        end
        local single = #components == 1
        local c = components[1]
        local expected = single and c.columns * c.rows or frame.mcuColumns * frame.mcuRows
        local interval = restart == 0 and expected or restart
        local mcu, nextRestart = 0, 0
        while mcu < expected do
            for _, component in ipairs(components) do component.pred = 0 end
            eob, acState = 0, 0
            local finish = math.min(expected, mcu + interval)
            while mcu < finish do
                if single then block(c, mcu % c.columns, floor(mcu / c.columns))
                else
                    local mx, my = mcu % frame.mcuColumns, floor(mcu / frame.mcuColumns)
                    for _, component in ipairs(components) do
                        for y = 0, component.v - 1 do
                            for x = 0, component.h - 1 do block(component, mx * component.h + x, my * component.v + y) end
                        end
                    end
                end
                mcu += 1
            end
            bitCount = 0
            if mcu < expected then
                if marker() ~= 208 + nextRestart then bad("missing or out-of-order restart marker") end
                nextRestart = (nextRestart + 1) % 8
            end
        end
        if pos <= scanStart then bad("empty entropy scan") end
        tick()
    end

    while pos < length do
        tick()
        markers += 1
        if markers > 2048 then bad("too many markers") end
        local code = marker()
        if code == 217 then sawEnd = true; break end
        if code == 216 or code >= 208 and code <= 215 then bad("unexpected standalone marker") end
        local size = word()
        if size < 2 or pos + size - 2 > length then bad("truncated marker segment") end
        local start, finish = pos, pos + size - 2
        local function segmentByte()
            if pos >= finish then bad("truncated marker payload") end
            return byte()
        end
        local function segmentWord() return segmentByte() * 256 + segmentByte() end
        if code == 219 then
            while pos < finish do
                defineTable()
                local spec = segmentByte()
                local precision, id = floor(spec / 16), spec % 16
                if precision > 1 or id > 3 then bad("unsupported quantization table") end
                local q = {}
                for k = 1, 64 do
                    local value = precision == 0 and segmentByte() or segmentWord()
                    if value == 0 then bad("zero quantization value") end
                    q[zig[k] + 1] = value
                end
                quant[id] = q
            end
        elseif code == 196 then
            while pos < finish do
                defineTable()
                local spec = segmentByte()
                local class, id = floor(spec / 16), spec % 16
                if class > 1 or id > 3 then bad("unsupported Huffman table") end
                local counts, values, total = {}, {}, 0
                for i = 1, 16 do counts[i] = segmentByte(); total += counts[i] end
                if total > 256 then bad("Huffman table too large") end
                for i = 1, total do values[i] = segmentByte() end
                local target = class == 0 and dcTables or acTables
                target[id] = makeHuffman(counts, values)
            end
        elseif code == 192 or code == 193 or code == 194 then
            if frame then bad("multiple frames are unsupported") end
            local precision, height, width, count = segmentByte(), segmentWord(), segmentWord(), segmentByte()
            if precision ~= 8 then bad("only 8-bit JPEG precision is supported") end
            if width < 1 or height < 1 or width > MAX_AXIS or height > MAX_AXIS or width * height > MAX_PIXELS then
                bad("dimensions exceed 4096 per axis or 4194304 pixels")
            end
            if count ~= 1 and count ~= 3 then bad("only grayscale and three-component JPEGs are supported (CMYK is unsupported)") end
            frame = {width = width, height = height, progressive = code == 194, components = {}, ordered = {}, maxH = 1, maxV = 1}
            local samples = 0
            for _ = 1, count do
                local id, hv, qid = segmentByte(), segmentByte(), segmentByte()
                local h, v = floor(hv / 16), hv % 16
                if frame.components[id] or h < 1 or h > 4 or v < 1 or v > 4 or qid > 3 then bad("invalid frame component") end
                local component = {id = id, h = h, v = v, qid = qid, levels = {}}
                frame.components[id] = component; table.insert(frame.ordered, component)
                frame.maxH, frame.maxV = math.max(frame.maxH, h), math.max(frame.maxV, v)
                samples += h * v
            end
            if samples > 10 then bad("too many sampling blocks per MCU") end
            frame.mcuColumns, frame.mcuRows = ceil(width / (8 * frame.maxH)), ceil(height / (8 * frame.maxV))
            for _, component in ipairs(frame.ordered) do
                component.columns = ceil(width * component.h / (frame.maxH * 8))
                component.rows = ceil(height * component.v / (frame.maxV * 8))
                component.stride, component.paddedRows = frame.mcuColumns * component.h, frame.mcuRows * component.v
                component.blocks = allocate(component.stride * component.paddedRows * 256)
            end
        elseif code == 221 then
            if size ~= 4 then bad("invalid restart interval") end
            restart = segmentWord()
        elseif code == 218 then
            if not frame then bad("scan appears before the frame") end
            scans += 1
            if scans > 96 then bad("scan count limit exceeded") end
            local count, components, seen = segmentByte(), {}, {}
            if count < 1 or count > #frame.ordered then bad("invalid scan component count") end
            for _ = 1, count do
                local id, tables = segmentByte(), segmentByte()
                local component = frame.components[id]
                if not component or seen[id] or floor(tables / 16) > 3 or tables % 16 > 3 then bad("invalid scan component") end
                seen[id] = true
                component.dc, component.ac = dcTables[floor(tables / 16)], acTables[tables % 16]
                if not quant[component.qid] then bad("missing quantization table") end
                if component.qt and component.qt ~= quant[component.qid] then bad("changing active quantization tables is unsupported") end
                component.qt = quant[component.qid]
                table.insert(components, component)
            end
            local first, last, approximation = segmentByte(), segmentByte(), segmentByte()
            local previous, successive = floor(approximation / 16), approximation % 16
            if pos ~= finish then bad("invalid scan header length") end
            if frame.progressive then
                if first > last or last > 63 or first == 0 and last ~= 0 or first > 0 and count ~= 1
                    or previous > 13 or successive > 13 or previous > 0 and previous ~= successive + 1 then bad("invalid progressive scan") end
            elseif first ~= 0 or last ~= 63 or approximation ~= 0 then bad("invalid sequential scan") end
            for _, component in ipairs(components) do
                if first > 0 and component.levels[0] == nil then bad("AC scan precedes DC data") end
                for k = first, last do
                    local level = component.levels[k]
                    if previous == 0 and level ~= nil or previous > 0 and level ~= previous then bad("invalid progressive scan order") end
                    component.levels[k] = successive
                end
                if (not frame.progressive or first == 0 and previous == 0) and not component.dc then bad("missing DC table") end
                if (not frame.progressive or first > 0) and not component.ac then bad("missing AC table") end
            end
            decodeScan(components, first, last, previous, successive)
            continue
        elseif code == 225 then readExif(start, finish); pos = finish
        elseif code == 238 then
            if finish - start >= 12 and buffer.readstring(data, start, 5) == "Adobe" then adobe = at(start + 11) end
            pos = finish
        elseif code >= 224 and code <= 239 or code == 254 then pos = finish
        else bad(string.format("unsupported marker 0xFF%02X (lossless/arithmetic JPEGs are unsupported)", code)) end
        if pos ~= finish then bad("invalid marker segment length") end
    end
    if not sawEnd or not frame or scans == 0 then bad("missing complete frame or EOI marker") end

    -- Separable double-precision IDCT. The entropy and progressive state machine
    -- above follows jpeg-js; this transform avoids signed-bitwise overflow and
    -- uses a flat buffer plus two reusable 64-number scratch arrays.
    local scratch, horizontal = table.create(64, 0), table.create(64, 0)
    for _, c in ipairs(frame.ordered) do
        if c.levels[0] == nil or not c.qt then bad("component has no DC scan") end
        local stride, rows = c.columns * 8, c.rows * 8
        c.samples, c.sampleStride = allocate(stride * rows), stride
        for by = 0, c.rows - 1 do
            tick()
            for bx = 0, c.columns - 1 do
                if bx % 32 == 0 then tick() end
                local base = (by * c.stride + bx) * 256
                local ac = false
                for k = 0, 63 do
                    local value = buffer.readi32(c.blocks, base + k * 4)
                    scratch[k + 1] = value * c.qt[k + 1]
                    if k > 0 and value ~= 0 then ac = true end
                end
                if not ac then
                    local value = byteClamp(128 + scratch[1] / 8)
                    for y = 0, 7 do buffer.fill(c.samples, (by * 8 + y) * stride + bx * 8, value, 8) end
                else
                    for v = 0, 7 do
                        local o = v * 8
                        local a,b,d,e,f,g,h,j = scratch[o+1],scratch[o+2],scratch[o+3],scratch[o+4],scratch[o+5],scratch[o+6],scratch[o+7],scratch[o+8]
                        for x = 1, 8 do
                            local q = basis[x]
                            horizontal[o+x] = q[1]*a+q[2]*b+q[3]*d+q[4]*e+q[5]*f+q[6]*g+q[7]*h+q[8]*j
                        end
                    end
                    for x = 1, 8 do
                        local a,b,d,e,f,g,h,j = horizontal[x],horizontal[x+8],horizontal[x+16],horizontal[x+24],horizontal[x+32],horizontal[x+40],horizontal[x+48],horizontal[x+56]
                        for y = 1, 8 do
                            local q = basis[y]
                            local value = (q[1]*a+q[2]*b+q[3]*d+q[4]*e+q[5]*f+q[6]*g+q[7]*h+q[8]*j) / 4 + 128
                            buffer.writeu8(c.samples, (by * 8 + y - 1) * stride + bx * 8 + x - 1, byteClamp(value))
                        end
                    end
                end
            end
        end
        c.blocks = nil
    end
    local w, h = frame.width, frame.height
    local swap = orientation >= 5
    local width, height = swap and h or w, swap and w or h
    local output = allocate(width * height * 4)
    local gray = #frame.ordered == 1
    local c1, c2, c3 = frame.ordered[1], frame.ordered[2], frame.ordered[3]
    local direct = not gray and (adobe == 0 or adobe == nil and c1.id == 82 and c2.id == 71 and c3.id == 66)
    if adobe ~= nil and adobe ~= 0 and adobe ~= 1 then bad("unsupported Adobe color transform") end
    local function sample(c, x, y)
        local sx, sy = floor(x * c.h / frame.maxH), floor(y * c.v / frame.maxV)
        return buffer.readu8(c.samples, sy * c.sampleStride + sx)
    end
    for y = 0, h - 1 do
        if y % 4 == 0 then tick() end
        for x = 0, w - 1 do
            local r, g, b = sample(c1, x, y), 0, 0
            if gray then g, b = r, r
            elseif direct then g, b = sample(c2, x, y), sample(c3, x, y)
            else
                local cb, cr = sample(c2, x, y) - 128, sample(c3, x, y) - 128
                local luminance = r
                r, g, b = byteClamp(luminance + 1.402 * cr), byteClamp(luminance - 0.344136 * cb - 0.714136 * cr), byteClamp(luminance + 1.772 * cb)
            end
            local dx, dy = x, y
            if orientation == 2 then dx = w - 1 - x
            elseif orientation == 3 then dx, dy = w - 1 - x, h - 1 - y
            elseif orientation == 4 then dy = h - 1 - y
            elseif orientation == 5 then dx, dy = y, x
            elseif orientation == 6 then dx, dy = h - 1 - y, x
            elseif orientation == 7 then dx, dy = h - 1 - y, w - 1 - x
            elseif orientation == 8 then dx, dy = y, w - 1 - x end
            local index = (dy * width + dx) * 4
            buffer.writeu8(output, index, r); buffer.writeu8(output, index + 1, g)
            buffer.writeu8(output, index + 2, b); buffer.writeu8(output, index + 3, 255)
        end
    end
    tick()
    return width, height, output
end
return JPEG
end)()

local MAX_BYTES = 10 * 1024 * 1024
local MAX_AXIS = 4096
local MAX_PIXELS = 4194304
local MAX_WORKING_BYTES = 96 * 1024 * 1024
local MAX_CHUNKS = 4096
local PNG_SIGNATURE = "\137PNG\13\10\26\10"

local function fail(message)
    error("Image decoder: " .. message, 0)
end

local function dimensions(width, height)
    if type(width) ~= "number" or type(height) ~= "number"
        or width % 1 ~= 0 or height % 1 ~= 0 or width < 1 or height < 1
        or width > MAX_AXIS or height > MAX_AXIS or width * height > MAX_PIXELS then
        fail("image exceeds the local limit of 4096 per side and 4,194,304 pixels.")
    end
end

local function checkpointFor(hooks)
    if hooks ~= nil and type(hooks) ~= "table" then fail("invalid processing hooks.") end
    local started = os.clock()
    local lastYield = started
    return function()
        if hooks and hooks.checkpoint then hooks.checkpoint() end
        if hooks and hooks.isCancelled and hooks.isCancelled() then fail("conversion cancelled.") end
        local now = os.clock()
        if now - started > 60 then fail("decoding exceeded the 60-second processing budget; use a smaller image.") end
        if now - lastYield >= 0.008 and task and task.wait then
            task.wait()
            lastYield = os.clock()
        end
    end
end

local function be32(data, offset)
    return bit32.byteswap(buffer.readu32(data, offset))
end

local function be16(data, offset)
    return buffer.readu8(data, offset) * 256 + buffer.readu8(data, offset + 1)
end

local function preflightPNG(data, checkpoint)
    local length = buffer.len(data)
    if length < 33 or be32(data, 8) ~= 13 or buffer.readstring(data, 12, 4) ~= "IHDR" then
        fail("PNG has a missing or truncated IHDR header.")
    end
    local width, height = be32(data, 16), be32(data, 20)
    dimensions(width, height)
    local depth, color = buffer.readu8(data, 24), buffer.readu8(data, 25)
    local channels = ({[0] = 1, [2] = 3, [3] = 1, [4] = 2, [6] = 4})[color]
    local allowed = (color == 0 and (depth == 1 or depth == 2 or depth == 4 or depth == 8 or depth == 16))
        or (color == 3 and (depth == 1 or depth == 2 or depth == 4 or depth == 8))
        or ((color == 2 or color == 4 or color == 6) and (depth == 8 or depth == 16))
    if not channels or not allowed then fail("unsupported PNG color type or bit depth.") end
    if buffer.readu8(data, 26) ~= 0 or buffer.readu8(data, 27) ~= 0 or buffer.readu8(data, 28) > 1 then
        fail("unsupported PNG compression, filter, or interlace method.")
    end
    -- Conservatively cover Adam7 row padding plus the input copy, IDAT copy,
    -- unfiltered samples, RGBA output, and bounded parser metadata.
    local rawBound = width * height * channels * depth / 8 + height * 14 + 1024
    local workingBound = length * 3 + rawBound + width * height * 4 + 2 * 1024 * 1024
    if workingBound > MAX_WORKING_BYTES then fail("PNG exceeds the 96 MiB local working-memory budget.") end
    local offset, count = 8, 0
    while offset < length do
        checkpoint()
        count += 1
        if count > MAX_CHUNKS then fail("PNG contains too many chunks.") end
        if offset + 12 > length then fail("truncated PNG chunk.") end
        local chunkLength = be32(data, offset)
        if chunkLength > length - offset - 12 then fail("truncated PNG chunk data.") end
        offset += chunkLength + 12
    end
    return width, height
end

local function preflightJPEG(data, checkpoint)
    local length, offset, count = buffer.len(data), 2, 0
    while offset < length do
        checkpoint()
        count += 1
        if count > MAX_CHUNKS then fail("JPEG contains too many header markers.") end
        if buffer.readu8(data, offset) ~= 255 then fail("invalid JPEG marker.") end
        repeat
            offset += 1
            if offset % 4096 == 0 then checkpoint() end
            if offset >= length then fail("truncated JPEG marker.") end
        until buffer.readu8(data, offset) ~= 255
        local marker = buffer.readu8(data, offset)
        offset += 1
        if marker == 0xD9 or marker == 0xDA then fail("JPEG has no size header before image data.") end
        if marker == 0 or marker == 0xD8 or (marker >= 0xD0 and marker <= 0xD7) then
            fail("unexpected JPEG marker in header.")
        end
        if marker ~= 1 then
            if offset + 2 > length then fail("truncated JPEG segment length.") end
            local segmentLength = be16(data, offset)
            if segmentLength < 2 or segmentLength > length - offset then fail("truncated JPEG segment.") end
            local isFrame = marker >= 0xC0 and marker <= 0xCF and marker ~= 0xC4 and marker ~= 0xC8 and marker ~= 0xCC
            if isFrame then
                if segmentLength < 8 then fail("truncated JPEG size header.") end
                local height, width = be16(data, offset + 3), be16(data, offset + 5)
                dimensions(width, height)
                return width, height
            end
            offset += segmentLength
        end
    end
    fail("JPEG has no size header.")
end

local function decode(bytes, hooks)
    local kind = typeof(bytes)
    if kind ~= "string" and kind ~= "buffer" then fail("expected image bytes as a string or buffer.") end
    local length = if kind == "string" then #bytes else buffer.len(bytes)
    if length < 3 then fail("empty or truncated image.") end
    if length > MAX_BYTES then fail("download exceeds the 10 MiB image limit.") end
    local checkpoint = checkpointFor(hooks)
    checkpoint()
    local data = if kind == "buffer" then bytes else buffer.fromstring(bytes)
    local width, height, pixels
    if length >= 8 and buffer.readstring(data, 0, 8) == PNG_SIGNATURE then
        width, height = preflightPNG(data, checkpoint)
        local decoded = PNG.decode(data, {checkpoint = checkpoint})
        if decoded.width ~= width or decoded.height ~= height then fail("PNG decoder returned inconsistent dimensions.") end
        pixels = decoded.pixels
    elseif buffer.readu8(data, 0) == 255 and buffer.readu8(data, 1) == 216 then
        local expectedWidth, expectedHeight = preflightJPEG(data, checkpoint)
        if not JPEG or type(JPEG.decode) ~= "function" then fail("JPEG decoder is missing from this installation.") end
        width, height, pixels = JPEG.decode(data, {checkpoint = checkpoint})
        -- EXIF rotation may only swap the two axes.
        dimensions(width, height)
        if not ((width == expectedWidth and height == expectedHeight)
            or (width == expectedHeight and height == expectedWidth)) then
            fail("JPEG decoder returned inconsistent dimensions.")
        end
    else
        fail("unsupported image format. Use a direct PNG or JPEG image link.")
    end
    if typeof(pixels) ~= "buffer" or buffer.len(pixels) ~= width * height * 4 then
        fail("decoder returned an invalid RGBA pixel buffer.")
    end
    checkpoint()
    return width, height, pixels
end

-- Stored DEFLATE is deliberately used for tiny previews: bounded, linear work
-- and no color loss. Output is an ordinary RGBA PNG accepted by getcustomasset.
local crcTable = table.create(256)
for n = 0, 255 do
    local c = n
    for _ = 1, 8 do c = bit32.bxor(bit32.rshift(c, 1), if bit32.band(c, 1) == 1 then 0xEDB88320 else 0) end
    crcTable[n + 1] = c
end

local function encodePreview(width, height, pixels, hooks)
    dimensions(width, height)
    if width > 512 or height > 512 or width * height > 262144 then fail("preview exceeds 512 by 512 pixels.") end
    if typeof(pixels) ~= "buffer" or buffer.len(pixels) ~= width * height * 4 then fail("invalid preview RGBA pixel buffer.") end
    local checkpoint = checkpointFor(hooks)
    checkpoint()
    local stride = width * 4 + 1
    local raw = buffer.create(stride * height)
    for y = 0, height - 1 do
        checkpoint()
        buffer.copy(raw, y * stride + 1, pixels, y * width * 4, width * 4)
    end
    local rawLength = buffer.len(raw)
    local packed = buffer.create(2 + rawLength + 5 * math.ceil(rawLength / 65535) + 4)
    buffer.writeu8(packed, 0, 0x78)
    buffer.writeu8(packed, 1, 0x01)
    local offset, position = 0, 2
    while offset < rawLength do
        checkpoint()
        local length = math.min(65535, rawLength - offset)
        buffer.writeu8(packed, position, if offset + length == rawLength then 1 else 0)
        buffer.writeu16(packed, position + 1, length)
        buffer.writeu16(packed, position + 3, 65535 - length)
        buffer.copy(packed, position + 5, raw, offset, length)
        offset += length
        position += length + 5
    end
    local a, b = 1, 0
    for i = 0, rawLength - 1 do
        if i % 4096 == 0 then checkpoint() end
        a = (a + buffer.readu8(raw, i)) % 65521
        b = (b + a) % 65521
    end
    buffer.writeu32(packed, position, bit32.byteswap(b * 65536 + a))
    local output = buffer.create(57 + buffer.len(packed))
    buffer.writestring(output, 0, PNG_SIGNATURE)
    local function chunk(at, name, contents)
        local size = buffer.len(contents)
        buffer.writeu32(output, at, bit32.byteswap(size))
        buffer.writestring(output, at + 4, name)
        buffer.copy(output, at + 8, contents)
        local crc = 0xFFFFFFFF
        for i = at + 4, at + 7 + size do
            if (i - at) % 4096 == 0 then checkpoint() end
            crc = bit32.bxor(bit32.rshift(crc, 8), crcTable[bit32.bxor(bit32.band(crc, 255), buffer.readu8(output, i)) + 1])
        end
        buffer.writeu32(output, at + 8 + size, bit32.byteswap(bit32.bxor(crc, 0xFFFFFFFF)))
        return at + size + 12
    end
    local header = buffer.create(13)
    buffer.writeu32(header, 0, bit32.byteswap(width))
    buffer.writeu32(header, 4, bit32.byteswap(height))
    buffer.writeu8(header, 8, 8)
    buffer.writeu8(header, 9, 6)
    local endOffset = chunk(chunk(chunk(8, "IHDR", header), "IDAT", packed), "IEND", buffer.create(0))
    assert(endOffset == buffer.len(output))
    checkpoint()
    return buffer.tostring(output)
end

return {
    decode = decode,
    encodePreview = encodePreview,
    limits = {maxBytes = MAX_BYTES, maxAxis = MAX_AXIS, maxPixels = MAX_PIXELS},
}
end)()
local Planner = (function()
-- Pure Luau raster planning. No HTTP, game access, filesystem or native decoder.
-- convertRGBA(width, height, packedRGBA, settings, hooks) -> plan, preview.
-- packedRGBA is a buffer or an RGBA byte string, already oriented by the decoder.
-- preview = {width, height, rgba = buffer}; it is separate from the JSON-safe plan.
-- Source/nearest RGB is exact. Filtered RGB and palette choices are independent
-- implementations and are not guaranteed bit-identical to Pillow.
local Planner = {Version = 1, MAX_GRID_CELLS = 250000, MAX_INPUT_PIXELS = 20000000, MAX_WORK = 134217728}
local floor, ceil, min, max, abs = math.floor, math.ceil, math.min, math.max, math.abs
local read8, write8 = buffer.readu8, buffer.writeu8
local read32, write32 = buffer.readu32, buffer.writeu32
local readFloat, writeFloat = buffer.readf32, buffer.writef32
local band, rshift, lshift = bit32.band, bit32.rshift, bit32.lshift
local function finite(n) return type(n) == "number" and n == n and abs(n) < math.huge end
local function positive(n, name)
    if not finite(n) or n <= 0 then error(name .. " must be a positive finite number.", 0) end
    return n
end
local function integer(n, name, low, high)
    if not finite(n) or n % 1 ~= 0 or n < low or n > high then
        error(string.format("%s must be a whole number between %d and %d.", name, low, high), 0)
    end
    return n
end
local function byte(n) return max(0, min(255, floor(n + 0.5))) end
local function rgb(code)
    code -= 1
    return band(code, 255), band(rshift(code, 8), 255), band(rshift(code, 16), 255)
end
local function colorCode(r, g, b) return r + g * 256 + b * 65536 + 1 end
local function option(settings, key, default)
    if settings[key] == nil then return default end
    return settings[key]
end

local function cooperator(hooks)
    hooks = hooks or {}
    local yieldFn = hooks.yield
    if yieldFn == nil and task and task.wait then yieldFn = task.wait end
    local checked, worked, totalWork, lastYield = 0, 0, 0, os.clock()
    local started = lastYield
    local function checkpoint(amount, force)
        checked += amount or 0
        worked += amount or 0
        totalWork += amount or 0
        if force or checked >= 2048 then
            checked = 0
            if hooks.checkCancelled and hooks.checkCancelled() then error("Image conversion cancelled.", 0) end
            if totalWork > Planner.MAX_WORK then error("Image conversion exceeded the local work budget. Use a smaller source or output grid.", 0) end
            if os.clock() - started > 60 then error("Image conversion exceeded 60 seconds. Use a smaller source or output grid.", 0) end
            if force or worked >= 65536 or os.clock() - lastYield >= 0.006 then
                if yieldFn then yieldFn() end
                worked, lastYield = 0, os.clock()
                if hooks.checkCancelled and hooks.checkCancelled() then error("Image conversion cancelled.", 0) end
            end
        end
    end
    local function phase(name, progress)
        checkpoint(0, true)
        if hooks.onProgress then hooks.onProgress(name, progress) end
    end
    return checkpoint, phase
end

local function gridRows(columns, w, h) return max(1, floor((2 * columns * h + w) / (2 * w))) end
local function finestColumns(w, h, limit)
    local lo, hi, best = 1, limit, 0
    while lo <= hi do
        local c = floor((lo + hi) / 2)
        if c * gridRows(c, w, h) <= limit then best, lo = c, c + 1 else hi = c - 1 end
    end
    return best
end
local function dimensions(w, h, settings)
    local physicalWidth = positive(settings.width_studs, "width_studs")
    local requested = positive(option(settings, "pixel_studs", 0.5), "pixel_studs")
    local limit = integer(option(settings, "max_blocks", 10000), "max_blocks", 1, Planner.MAX_GRID_CELLS)
    local mode = option(settings, "resolution_mode", "spacing")
    if mode ~= "spacing" and mode ~= "auto" and mode ~= "source" and mode ~= "columns" then
        error("resolution_mode must be spacing, auto, source or columns.", 0)
    end
    local columns, rows, limited
    if mode == "source" then columns, rows = w, h
    elseif mode == "columns" then
        columns = integer(settings.columns, "columns", 1, Planner.MAX_GRID_CELLS)
        rows = gridRows(columns, w, h)
        requested = physicalWidth / columns
    else
        local ratio = physicalWidth / requested
        local nearest = floor(ratio + 0.5)
        if finite(ratio) and abs(ratio - nearest) <= max(1e-12, abs(ratio) * 1e-12) then ratio = nearest end
        columns = (not finite(ratio) or ratio > limit) and limit + 1 or max(1, ceil(ratio))
        rows = gridRows(columns, w, h)
    end
    if columns * rows > limit then
        if mode == "auto" then
            columns = finestColumns(w, h, limit)
            if columns == 0 then error("This image is too tall to fit the pixel limit. Crop it or increase Maximum pixels.", 0) end
            rows, limited = gridRows(columns, w, h), true
        elseif mode == "source" then
            error(string.format("Source resolution is %dx%d (%d cells), above the %d-cell limit. Source mode cannot reduce it; use Auto or a smaller image.", w, h, w * h, limit), 0)
        else
            local best = finestColumns(w, h, limit)
            if best == 0 then error("This image is too tall to fit the pixel limit. Crop it or increase Maximum pixels.", 0) end
            local spacing = ceil(physicalWidth / best * 1000000) / 1000000
            error(string.format("Requested grid exceeds the %d-cell limit before transparency. Increase pixel size to at least %.6f, or use Auto.", limit, spacing), 0)
        end
    end
    local pixel = physicalWidth / columns
    if pixel > 32 then error("Pixels exceed the 32-stud block size limit. Increase the image resolution.", 0) end
    local height = pixel * rows
    if not finite(height) then error("Physical height is too large; reduce width_studs.", 0) end
    return columns, rows, pixel, physicalWidth, height, requested, mode, limited == true
end

local function pixelReader(data)
    if typeof(data) == "buffer" then
        return buffer.len(data), function(index)
            local o = index * 4
            return read8(data, o), read8(data, o + 1), read8(data, o + 2), read8(data, o + 3)
        end
    elseif type(data) == "string" then
        return #data, function(index) return string.byte(data, index * 4 + 1, index * 4 + 4) end
    end
    error("RGBA pixels must be a packed byte buffer or string.", 0)
end

local function kernel(src, dst, out, sampling, checkpoint)
    local scale = src / dst
    local first, last, center, support
    if sampling == "area" then
        first, last = floor(out * scale), ceil((out + 1) * scale) - 1
    else
        center, support = (out + 0.5) * scale - 0.5, max(1, scale)
        first, last = ceil(center - 3 * support), floor(center + 3 * support)
    end
    first, last = max(0, first), min(src - 1, last)
    local count = last - first + 1
    local weights, total = buffer.create(count * 4), 0
    for index = first, last do
        local weight
        if sampling == "area" then
            weight = max(0, min(index + 1, (out + 1) * scale) - max(index, out * scale))
        else
            local x = (index - center) / support
            if abs(x) < 1e-12 then weight = 1
            elseif abs(x) >= 3 then weight = 0
            else weight = math.sin(math.pi * x) * math.sin(math.pi * x / 3) / (math.pi * math.pi * x * x / 3) end
        end
        writeFloat(weights, (index - first) * 4, weight)
        total += weight
        checkpoint(1)
    end
    if abs(total) < 1e-12 then error("Resampling produced an empty filter kernel.", 0) end
    return first, count, weights, total
end

local function resample(w, h, reader, columns, rows, sampling, checkpoint)
    local result = buffer.create(columns * rows * 4)
    if w == columns and h == rows or sampling == "nearest" then
        for y = 0, rows - 1 do
            local sy = min(h - 1, floor((y + 0.5) * h / rows))
            for x = 0, columns - 1 do
                local sx = min(w - 1, floor((x + 0.5) * w / columns))
                local r, g, b, a = reader(sy * w + sx)
                local offset = (y * columns + x) * 4
                write8(result, offset, r); write8(result, offset + 1, g)
                write8(result, offset + 2, b); write8(result, offset + 3, a)
                checkpoint(1)
            end
        end
        return result
    end
    local horizontal = columns * h <= w * rows
    local sourceAxis, otherAxis, outputAxis, finalAxis = w, h, columns, rows
    if not horizontal then sourceAxis, otherAxis, outputAxis, finalAxis = h, w, rows, columns end
    local scratchPixels = outputAxis * otherAxis
    if scratchPixels > 4000000 then error("This resize needs too much temporary memory. Use a smaller source image.", 0) end
    local scratch = buffer.create(scratchPixels * 16)
    for out = 0, outputAxis - 1 do
        local first, count, weights, sum = kernel(sourceAxis, outputAxis, out, sampling, checkpoint)
        for other = 0, otherAxis - 1 do
            local rr, gg, bb, aa = 0, 0, 0, 0
            for k = 0, count - 1 do
                local index = horizontal and (other * w + first + k) or ((first + k) * w + other)
                local r, g, b, a = reader(index)
                local weight = readFloat(weights, k * 4)
                local covered = a * weight
                rr += r * covered; gg += g * covered; bb += b * covered; aa += covered
                checkpoint(1)
            end
            local offset = (other * outputAxis + out) * 16
            writeFloat(scratch, offset, rr / (255 * sum)); writeFloat(scratch, offset + 4, gg / (255 * sum))
            writeFloat(scratch, offset + 8, bb / (255 * sum)); writeFloat(scratch, offset + 12, aa / sum)
        end
    end
    for out = 0, finalAxis - 1 do
        local first, count, weights, sum = kernel(otherAxis, finalAxis, out, sampling, checkpoint)
        for along = 0, outputAxis - 1 do
            local rr, gg, bb, aa = 0, 0, 0, 0
            for k = 0, count - 1 do
                local offset = ((first + k) * outputAxis + along) * 16
                local weight = readFloat(weights, k * 4)
                rr += readFloat(scratch, offset) * weight; gg += readFloat(scratch, offset + 4) * weight
                bb += readFloat(scratch, offset + 8) * weight; aa += readFloat(scratch, offset + 12) * weight
                checkpoint(1)
            end
            local target = horizontal and (out * columns + along) or (along * columns + out)
            local offset = target * 4
            local alpha = byte(aa / sum)
            if aa > 1e-9 and alpha > 0 then
                write8(result, offset, byte(rr * 255 / aa)); write8(result, offset + 1, byte(gg * 255 / aa))
                write8(result, offset + 2, byte(bb * 255 / aa)); write8(result, offset + 3, alpha)
            end
        end
    end
    return result
end

local function sharpen(pixels, w, h, detail, threshold, checkpoint)
    if detail == "none" then return pixels end
    local sigma, amount = 0.8, 0.6
    if detail == "strong" then sigma, amount = 1.2, 1.2 end
    local radius, weights, total = ceil(sigma * 3), {}, 0
    for k = -radius, radius do
        local weight = math.exp(-k * k / (2 * sigma * sigma))
        weights[k + radius + 1] = weight; total += weight
    end
    for i = 1, #weights do weights[i] /= total end
    local scratch, result = buffer.create(w * h * 16), buffer.create(w * h * 4)
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local rr, gg, bb, aa = 0, 0, 0, 0
            for k = -radius, radius do
                local offset = (y * w + max(0, min(w - 1, x + k))) * 4
                local a = read8(pixels, offset + 3)
                if a > 0 and a >= threshold then
                    local covered = a * weights[k + radius + 1]
                    rr += read8(pixels, offset) * covered; gg += read8(pixels, offset + 1) * covered
                    bb += read8(pixels, offset + 2) * covered; aa += covered
                end
            end
            local offset = (y * w + x) * 16
            writeFloat(scratch, offset, rr); writeFloat(scratch, offset + 4, gg)
            writeFloat(scratch, offset + 8, bb); writeFloat(scratch, offset + 12, aa)
            checkpoint(radius * 2 + 1)
        end
    end
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local offset = (y * w + x) * 4
            local a = read8(pixels, offset + 3)
            local rr, gg, bb, aa = 0, 0, 0, 0
            for k = -radius, radius do
                local src = (max(0, min(h - 1, y + k)) * w + x) * 16
                local weight = weights[k + radius + 1]
                rr += readFloat(scratch, src) * weight; gg += readFloat(scratch, src + 4) * weight
                bb += readFloat(scratch, src + 8) * weight; aa += readFloat(scratch, src + 12) * weight
            end
            local values = {rr, gg, bb}
            for channel = 0, 2 do
                local value = read8(pixels, offset + channel)
                if a > 0 and a >= threshold and aa > 0 then
                    local difference = value - values[channel + 1] / aa
                    if abs(difference) > 2 then value = byte(value + amount * difference) end
                end
                write8(result, offset + channel, value)
            end
            write8(result, offset + 3, a)
            checkpoint(radius * 2 + 1)
        end
    end
    return result
end

local function quantize(grid, count, palette, checkpoint)
    if palette == 0 then return end
    -- A fixed 5-bit histogram bounds palette work at 32768 bins regardless of
    -- raster size. Weighted median cuts are deterministic and exclude holes.
    local counts, red, green, blue = buffer.create(32768 * 4), buffer.create(32768 * 4), buffer.create(32768 * 4), buffer.create(32768 * 4)
    local bins, exact, exactCount = {}, {}, 0
    for index = 0, count - 1 do
        local code = read32(grid, index * 4)
        if code > 0 then
            if exact and not exact[code] then exact[code] = true; exactCount += 1; if exactCount > palette then exact = nil end end
            local r, g, b = rgb(code)
            local bin = floor(r / 8) * 1024 + floor(g / 8) * 32 + floor(b / 8)
            local offset = bin * 4
            local n = read32(counts, offset)
            if n == 0 then table.insert(bins, bin) end
            write32(counts, offset, n + 1); write32(red, offset, read32(red, offset) + r)
            write32(green, offset, read32(green, offset) + g); write32(blue, offset, read32(blue, offset) + b)
        end
        checkpoint(1)
    end
    if exact or #bins == 0 then return end
    local function component(bin, channel)
        if channel == 1 then return floor(bin / 1024) end
        if channel == 2 then return floor(bin / 32) % 32 end
        return bin % 32
    end
    local function box(items)
        local low, high, population = {31, 31, 31}, {0, 0, 0}, 0
        for _, bin in ipairs(items) do
            population += read32(counts, bin * 4)
            for c = 1, 3 do local value = component(bin, c); low[c] = min(low[c], value); high[c] = max(high[c], value) end
            checkpoint(1)
        end
        local channel = 1
        for c = 2, 3 do if high[c] - low[c] > high[channel] - low[channel] then channel = c end end
        return {items = items, population = population, channel = channel, span = high[channel] - low[channel]}
    end
    local boxes = {box(bins)}
    while #boxes < palette do
        local selected, score = nil, -1
        for i, candidate in ipairs(boxes) do
            local value = candidate.span * candidate.population
            if candidate.span > 0 and value > score then selected, score = i, value end
        end
        if not selected then break end
        local current, histogram = boxes[selected], table.create(32, 0)
        for _, bin in ipairs(current.items) do
            local c = component(bin, current.channel) + 1
            histogram[c] += read32(counts, bin * 4); checkpoint(1)
        end
        local cumulative, split = 0, 0
        for c = 1, 31 do
            cumulative += histogram[c]
            if cumulative > 0 and cumulative < current.population then
                split = c - 1
                if cumulative >= current.population / 2 then break end
            end
        end
        local left, right = {}, {}
        for _, bin in ipairs(current.items) do
            table.insert(component(bin, current.channel) <= split and left or right, bin); checkpoint(1)
        end
        if #left == 0 or #right == 0 then current.span = 0
        else boxes[selected] = box(left); table.insert(boxes, box(right)) end
    end
    local replacements = buffer.create(32768 * 4)
    for _, group in ipairs(boxes) do
        local r, g, b, n = 0, 0, 0, 0
        for _, bin in ipairs(group.items) do
            local o = bin * 4
            r += read32(red, o); g += read32(green, o); b += read32(blue, o); n += read32(counts, o); checkpoint(1)
        end
        local code = colorCode(byte(r / n), byte(g / n), byte(b / n))
        for _, bin in ipairs(group.items) do write32(replacements, bin * 4, code); checkpoint(1) end
    end
    for index = 0, count - 1 do
        local code = read32(grid, index * 4)
        if code > 0 then
            local r, g, b = rgb(code)
            local bin = floor(r / 8) * 1024 + floor(g / 8) * 32 + floor(b / 8)
            write32(grid, index * 4, read32(replacements, bin * 4))
        end
        checkpoint(1)
    end
end

local function cover(grid, columns, rows, span, vertical, visible, checkpoint)
    local work = buffer.create(buffer.len(grid)); buffer.copy(work, 0, grid)
    local rectangles, count = buffer.create(visible * 20), 0
    local width, height = columns, rows
    if vertical then width, height = rows, columns end
    local function offset(x, y) return (vertical and (x * columns + y) or (y * columns + x)) * 4 end
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local code = read32(work, offset(x, y))
            if code > 0 then
                local w, h = 1, 1
                while w < span and x + w < width and read32(work, offset(x + w, y)) == code do w += 1; checkpoint(1) end
                while h < span and y + h < height do
                    local matches = true
                    for dx = 0, w - 1 do
                        if read32(work, offset(x + dx, y + h)) ~= code then matches = false; break end
                        checkpoint(1)
                    end
                    if not matches then break end
                    h += 1
                end
                local at = count * 20
                write32(rectangles, at, vertical and y or x); write32(rectangles, at + 4, vertical and x or y)
                write32(rectangles, at + 8, vertical and h or w); write32(rectangles, at + 12, vertical and w or h)
                write32(rectangles, at + 16, code); count += 1
                for dy = 0, h - 1 do
                    for dx = 0, w - 1 do write32(work, offset(x + dx, y + dy), 0); checkpoint(1) end
                end
            end
            checkpoint(1)
        end
    end
    return rectangles, count
end

function Planner.convertRGBA(width, height, rgba, settings, hooks)
    if settings == nil then settings = {} end
    if type(settings) ~= "table" then error("settings must be a table.", 0) end
    width = integer(width, "source width", 1, Planner.MAX_INPUT_PIXELS)
    height = integer(height, "source height", 1, Planner.MAX_INPUT_PIXELS)
    if width * height > Planner.MAX_INPUT_PIXELS then error("Image exceeds the 20-million-pixel input limit.", 0) end
    local length, reader = pixelReader(rgba)
    if length ~= width * height * 4 then error("RGBA byte length does not match the decoded dimensions.", 0) end
    local sampling, detail = option(settings, "sampling", "lanczos"), option(settings, "detail", "none")
    if sampling ~= "lanczos" and sampling ~= "area" and sampling ~= "nearest" then error("sampling must be lanczos, area or nearest.", 0) end
    if detail ~= "none" and detail ~= "light" and detail ~= "strong" then error("detail must be none, light or strong.", 0) end
    local palette = integer(option(settings, "palette_size", 0), "palette_size", 0, 256)
    if palette == 1 then error("palette_size must be 0 or between 2 and 256.", 0) end
    local threshold = integer(settings.alpha_threshold == nil and 128 or settings.alpha_threshold, "alpha_threshold", 0, 255)
    local previewLimit = integer(option(settings, "preview_max_size", 256), "preview_max_size", 1, 512)
    local blockType = option(settings, "block_type", "PlasticBlock")
    if type(blockType) ~= "string" or #blockType > 80 or string.find(blockType, "[%c]") then error("block_type must be a non-empty name of at most 80 characters.", 0) end
    blockType = string.match(blockType, "^%s*(.-)%s*$")
    if #blockType == 0 then error("block_type must be a non-empty name.", 0) end
    local columns, rows, pixel, physicalWidth, physicalHeight, requested, mode, limited = dimensions(width, height, settings)
    local effectiveDetail = mode == "source" and "none" or detail
    local checkpoint, phase = cooperator(hooks)
    phase("Resampling image", 0.1)
    local pixels = resample(width, height, reader, columns, rows, sampling, checkpoint)
    phase("Adjusting detail", 0.4)
    pixels = sharpen(pixels, columns, rows, effectiveDetail, threshold, checkpoint)
    local count, visible, grid = columns * rows, 0, buffer.create(columns * rows * 4)
    for i = 0, count - 1 do
        local a, o = read8(pixels, i * 4 + 3), i * 4
        if a > 0 and a >= threshold then
            write32(grid, o, colorCode(read8(pixels, o), read8(pixels, o + 1), read8(pixels, o + 2))); visible += 1
        end
        checkpoint(1)
    end
    phase("Reducing colors", 0.55)
    quantize(grid, count, palette, checkpoint)
    phase("Merging matching pixels", 0.7)
    local span = min(max(columns, rows), max(1, floor(32 / pixel + 1e-10)))
    local horizontal, horizontalCount = cover(grid, columns, rows, span, false, visible, checkpoint)
    local vertical, verticalCount = cover(grid, columns, rows, span, true, visible, checkpoint)
    local selected, placementCount = horizontal, horizontalCount
    if verticalCount < horizontalCount then selected, placementCount = vertical, verticalCount end
    local starts = buffer.create(count * 4)
    for i = 0, placementCount - 1 do
        local x, y = read32(selected, i * 20), read32(selected, i * 20 + 4)
        write32(starts, (y * columns + x) * 4, i + 1); checkpoint(1)
    end
    local rectangles, colors, colorCount = {}, buffer.create(2097152), 0
    local preview = buffer.create(count * 4)
    local cells = settings.include_cells == true and {} or nil
    for i = 0, count - 1 do
        local code = read32(grid, i * 4)
        if code > 0 then
            local r, g, b = rgb(code)
            local o = i * 4
            write8(preview, o, r); write8(preview, o + 1, g); write8(preview, o + 2, b); write8(preview, o + 3, 255)
            local color, bit = code - 1, lshift(1, (code - 1) % 8)
            local at = floor(color / 8)
            if band(read8(colors, at), bit) == 0 then write8(colors, at, bit32.bor(read8(colors, at), bit)); colorCount += 1 end
            if cells then table.insert(cells, {x = i % columns, y = floor(i / columns), color = {r, g, b}}) end
        end
        local entry = read32(starts, i * 4)
        if entry > 0 then
            local at = (entry - 1) * 20
            local r, g, b = rgb(read32(selected, at + 16))
            table.insert(rectangles, {x = read32(selected, at), y = read32(selected, at + 4),
                w = read32(selected, at + 8), h = read32(selected, at + 12), color = {r, g, b}})
        end
        checkpoint(1)
    end
    phase("Creating preview", 0.95)
    local ratio = min(1, 48 / columns, 48 / rows)
    local tw, th = max(1, floor(columns * ratio + 0.5)), max(1, floor(rows * ratio + 0.5))
    local thumbnail = {columns = tw, rows = th, cells = {}}
    for y = 0, th - 1 do
        for x = 0, tw - 1 do
            local sx, sy = min(columns - 1, floor((x + 0.5) * columns / tw)), min(rows - 1, floor((y + 0.5) * rows / th))
            local code = read32(grid, (sy * columns + sx) * 4)
            if code > 0 then local r, g, b = rgb(code); table.insert(thumbnail.cells, {x = x, y = y, color = {r, g, b}}) end
        end
        checkpoint(tw)
    end
    local warnings, upscaled = {}, columns > width or rows > height
    if limited then table.insert(warnings, string.format("Auto resolution was capped to %dx%d by the %d-cell limit. Increase Maximum pixels for a finer grid.", columns, rows, settings.max_blocks or 10000)) end
    if upscaled then table.insert(warnings, string.format("The %dx%d grid enlarges a %dx%d source. Smoothing cannot recover missing detail; use a higher-resolution image for more detail.", columns, rows, width, height)) end
    if mode == "source" and detail ~= "none" then table.insert(warnings, "Sharpening is inactive in Source mode to preserve source pixels.")
    elseif effectiveDetail ~= "none" then table.insert(warnings, "Sharpening increases edge contrast and may emphasize noise. It does not add missing source detail.") end
    if mode == "source" and palette > 0 then table.insert(warnings, "Source mode keeps source dimensions; the selected palette still reduces colors.") end
    local plan = {schema_version = 1, processing_engine = "executor-luau-v1", compact = cells == nil,
        columns = columns, rows = rows, width_studs = physicalWidth, height_studs = physicalHeight,
        requested_pixel_studs = requested, pixel_studs = pixel, block_type = blockType,
        block_count = visible, unmerged_block_count = visible, placement_count = placementCount,
        merge_savings_percent = visible > 0 and floor(10000 * (1 - placementCount / visible) + 0.5) / 100 or 0,
        merge_method = "best_axis_greedy", grid_cell_count = count, transparent_cell_count = count - visible,
        color_count = colorCount, palette_size = palette, alpha_threshold = threshold, sampling = sampling,
        detail = effectiveDetail, requested_detail = detail, detail_applied = effectiveDetail ~= "none",
        resolution_mode = mode, grid_limited = limited, input_dims = {width = width, height = height},
        upscaled = upscaled, upscale_factor = max(1, columns / width, rows / height), warnings = warnings,
        input_format = settings.input_format or "RGBA", frame_index = 0, cells = cells,
        rectangles = rectangles, thumbnail = thumbnail}
    local previewRatio = min(1, previewLimit / columns, previewLimit / rows)
    local previewWidth = max(1, floor(columns * previewRatio + 0.5))
    local previewHeight = max(1, floor(rows * previewRatio + 0.5))
    if previewWidth ~= columns or previewHeight ~= rows then
        local reduced = buffer.create(previewWidth * previewHeight * 4)
        for y = 0, previewHeight - 1 do
            for x = 0, previewWidth - 1 do
                local sx = min(columns - 1, floor((x + 0.5) * columns / previewWidth))
                local sy = min(rows - 1, floor((y + 0.5) * rows / previewHeight))
                write32(reduced, (y * previewWidth + x) * 4, read32(preview, (sy * columns + sx) * 4))
                checkpoint(1)
            end
        end
        preview = reduced
    end
    phase("Image ready", 1)
    return plan, {width = previewWidth, height = previewHeight, rgba = preview}
end

return Planner
end)()
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
end)()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui")
if playerGui then
    for _, name in ipairs({"ImageRecorderLoader", "ImageRecorderStatus"}) do
        local diagnosticPanel = playerGui:FindFirstChild(name)
        if diagnosticPanel then diagnosticPanel:Destroy() end
    end
end

local destroyed, processing, building, cancelled = false, false, false, false
local inventoryRefreshing = false
local generation = 0
local plan, placeTool, ghost, placement, renderConnection, placementAllowed, placementReason
local toolConnections, connections, inventory = {}, {}, {}
local selectedBlock, speed, yaw = nil, "Rapid", 0
local toolMode = "background"
local infiniteBlocks = true
local qualityIndex = 1
local samplingIndex, detailIndex = 1, 2
local samplingPresets = {
    {name = "Photo", value = "lanczos"},
    {name = "Pixel art", value = "nearest"},
    {name = "Soft", value = "area"},
}
local detailPresets = {
    {name = "None", value = "none"},
    {name = "Light", value = "light"},
    {name = "Strong", value = "strong"},
}
local programmaticText = setmetatable({}, { __mode = "k" })
local function setFieldText(field, text)
    -- Property signals can be deferred and observe the latest of several writes.
    -- Keep this expected value until a different user edit arrives, rather than
    -- clearing a boolean before Roblox dispatches the queued signal callbacks.
    programmaticText[field] = text
    field.Text = text
end
local qualityPresets = {
    { name = "Auto", mode = "auto", maxPixels = 250000 },
    { name = "Source", mode = "source", maxPixels = 250000 },
    { name = "Preview", columns = 100, mode = "spacing", maxPixels = 100000 },
    { name = "High", columns = 200, mode = "spacing", maxPixels = 250000 },
    { name = "Ultra", columns = 400, mode = "spacing", maxPixels = 250000 },
}
local previewFiles, activePreviewPath = Backend.previewFiles(), nil
local chosenCount = 0
local api = {Version = "3.0.1"}
ENV.ImageBuilder = api

local C = {
    background = Color3.fromRGB(12, 17, 27), card = Color3.fromRGB(19, 27, 41),
    field = Color3.fromRGB(28, 39, 56), edge = Color3.fromRGB(42, 58, 79),
    text = Color3.fromRGB(238, 244, 253), dim = Color3.fromRGB(153, 171, 196),
    green = Color3.fromRGB(85, 223, 162), blue = Color3.fromRGB(96, 165, 255),
    red = Color3.fromRGB(252, 132, 145), yellow = Color3.fromRGB(241, 205, 127),
}
local UI = {width = 480, previewSize = 148, fullHeight = 760, minimized = false,
    startedAt = nil, completed = 0, total = 0}
local function create(class, properties, parent)
    local object = Instance.new(class)
    for key, value in pairs(properties) do object[key] = value end
    object.Parent = parent
    return object
end
local function round(object, radius)
    create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, object)
end
local function label(parent, text, x, y, width, height, size, color)
    return create("TextLabel", {
        Text = text, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, height),
        BackgroundTransparency = 1, BorderSizePixel = 0, Font = Enum.Font.Gotham,
        TextSize = size or 13, TextColor3 = color or C.text,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end
local function button(parent, text, x, y, width, height, color)
    local object = create("TextButton", {
        Text = text, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = color or C.field, BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.text,
        AutoButtonColor = true,
    }, parent)
    round(object)
    return object
end
local function input(parent, text, x, y, width)
    local object = create("TextBox", {
        Text = text, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, 34),
        BackgroundColor3 = C.field, BorderSizePixel = 0, Font = Enum.Font.Gotham,
        TextSize = 13, TextColor3 = C.text, PlaceholderColor3 = C.dim,
        ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
    create("UIPadding", {PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 11)}, object)
    round(object)
    return object
end
local gui = create("ScreenGui", {
    Name = "LocalImageBuilder", ResetOnSpawn = false, IgnoreGuiInset = true,
    DisplayOrder = 200, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, nil)
local parented = pcall(function()
    gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not parented or not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end
local camera = Workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
local panel = create("Frame", {
    Name = "Panel", Size = UDim2.fromOffset(UI.width, UI.fullHeight),
    Position = UDim2.fromOffset(math.max(12, viewport.X - UI.width - 24), 12),
    BackgroundColor3 = C.background, BorderSizePixel = 0,
}, gui)
round(panel, 16)
create("UIStroke", {Color = C.edge, Thickness = 1}, panel)
local panelScale = create("UIScale", {Scale = 1}, panel)
local header = create("Frame", {
    BackgroundTransparency = 1, Size = UDim2.new(1, -94, 0, 54), Active = true,
}, panel)
local brand = label(header, "Image Builder", 18, 15, 230, 26, 18)
brand.Font = Enum.Font.GothamMedium
label(header, "v" .. tostring(api.Version), 255, 19, 70, 20, 11, C.dim)
local minimize = button(panel, "-", 392, 15, 30, 30)
local close = button(panel, "X", 432, 15, 30, 30)
local content = {}
local function remember(object) table.insert(content, object); return object end
local scroll = remember(create("ScrollingFrame", {
    Name = "Settings", Position = UDim2.fromOffset(16, 60), Size = UDim2.new(1, -32, 1, -276),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.edge, CanvasSize = UDim2.fromOffset(0, 796),
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, panel))
local function card(name, y, height)
    local frame = create("Frame", {
        Name = name, Position = UDim2.fromOffset(0, y), Size = UDim2.fromOffset(440, height),
        BackgroundColor3 = C.card, BorderSizePixel = 0,
    }, scroll)
    round(frame, 12)
    return frame
end
local function sectionTitle(parent, number, text)
    local title = label(parent, text, 14, 9, 398, 22, 12)
    title.Font = Enum.Font.GothamMedium
end
local imageCard = card("Image", 0, 270)
sectionTitle(imageCard, "01", "Image & quality")
local urlInput = input(imageCard, "", 14, 39, 412)
urlInput.PlaceholderText = "Paste a direct image URL..."
local preview = create("Frame", {
    Position = UDim2.fromOffset(14, 90), Size = UDim2.fromOffset(UI.previewSize, UI.previewSize),
    BackgroundColor3 = C.background, BorderSizePixel = 0, ClipsDescendants = true,
}, imageCard)
round(preview, 9)
create("UIStroke", {Color = C.edge}, preview)
local previewEmpty = label(preview, "Your preview\nwill appear here", 8, 43, 132, 58, 11, C.dim)
previewEmpty.TextXAlignment = Enum.TextXAlignment.Center
previewEmpty.TextWrapped = true
local thumbnailCaption = label(imageCard, "Processed image", 14, 244, 148, 15, 10, C.dim)
thumbnailCaption.TextXAlignment = Enum.TextXAlignment.Center
local qualityButton = button(imageCard, "Resolution: Auto  >", 178, 90, 248, 38)
local samplingButton = button(imageCard, "Sampling: Photo  >", 178, 137, 248, 38)
local detailButton = button(imageCard, "Detail: Light  >", 178, 184, 248, 38)
label(imageCard, "Photo = smooth  /  Pixel art = sharp edges", 178, 230, 248, 28, 9, C.dim).TextWrapped = true
local geometryCard = card("Dimensions", 282, 174)
sectionTitle(geometryCard, "02", "Wall dimensions")
label(geometryCard, "Width in studs", 14, 36, 198, 18, 11, C.dim)
label(geometryCard, "Pixel size in studs", 226, 36, 200, 18, 11, C.dim)
local widthInput = input(geometryCard, "50", 14, 57, 198)
local pixelInput = input(geometryCard, "0.125", 226, 57, 200)
label(geometryCard, "Maximum pixels", 14, 101, 198, 18, 11, C.dim)
label(geometryCard, "Palette  /  0 = full color", 226, 101, 200, 18, 11, C.dim)
local maxInput = input(geometryCard, "250000", 14, 123, 198)
local paletteInput = input(geometryCard, "0", 226, 123, 200)
local materialCard = card("Building", 468, 208)
sectionTitle(materialCard, "03", "Material & building")
local blockButton = button(materialCard, "Reading your inventory...", 14, 39, 316, 34)
local refreshButton = button(materialCard, "Refresh", 338, 39, 88, 34)
local toolModeButton = button(materialCard, "Tools: Hands free  >", 14, 84, 246, 34)
local speedButton = button(materialCard, "Speed: Rapid  v", 268, 84, 158, 34)
local infiniteButton = button(materialCard, "Infinite Blocks: ON  (verify inventory)", 14, 129, 412, 34)
infiniteButton.TextColor3 = C.green
local explanation = label(materialCard,
    "Use your normal hotbar while building.\nAvailable material is checked before placement.",
    14, 170, 412, 29, 10, C.dim)
explanation.TextWrapped = true
local planCard = card("Plan", 688, 96)
sectionTitle(planCard, "04", "Build plan")
local summary = label(planCard, "Auto chooses more pixels for a larger wall.\nConvert an image to see its size and material needs.", 14, 35, 412, 51, 11, C.dim)
summary.TextWrapped = true
summary.TextYAlignment = Enum.TextYAlignment.Top
local dock = remember(create("Frame", {
    Name = "BuildStatus", Position = UDim2.new(0, 16, 1, -208), Size = UDim2.fromOffset(448, 184),
    BackgroundTransparency = 1,
}, panel))
local phaseLabel = label(dock, "READY TO CONVERT", 0, 0, 314, 20, 11, C.blue)
phaseLabel.Font = Enum.Font.GothamBold
local progressCount = label(dock, "", 306, 0, 142, 20, 11, C.dim)
progressCount.TextXAlignment = Enum.TextXAlignment.Right
local progressTrack = create("Frame", {
    Position = UDim2.fromOffset(0, 27), Size = UDim2.fromOffset(448, 6),
    BackgroundColor3 = C.field, BorderSizePixel = 0, ClipsDescendants = true,
}, dock)
round(progressTrack, 3)
local progressFill = create("Frame", {
    Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.blue, BorderSizePixel = 0,
}, progressTrack)
round(progressFill, 3)
local progressMeta = label(dock, "Convert  >  Place  >  Aim and click", 0, 40, 448, 18, 11, C.dim)
local status = label(dock, "Paste a direct PNG or JPEG image link to begin.", 0, 66, 448, 64, 12, C.dim)
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Top
local convertButton = button(dock, "1  Convert image", 0, 140, 166, 40, Color3.fromRGB(39, 99, 190))
local placeButton = button(dock, "2  Place", 174, 140, 166, 40, Color3.fromRGB(28, 113, 85))
local stopButton = button(dock, "Stop", 348, 140, 100, 40, Color3.fromRGB(60, 37, 50))
local footer = remember(label(panel, "R: 90 degrees  /  Q, E: 15 degrees  /  Drag title to move", 18, 0, 444, 17, 10, C.dim))
footer.Position = UDim2.new(0, 18, 1, -20)
local blockMenu = create("ScrollingFrame", {
    Position = UDim2.fromOffset(16, 170), Size = UDim2.fromOffset(440, 212),
    BackgroundColor3 = C.field, BorderSizePixel = 0, ScrollBarThickness = 4,
    CanvasSize = UDim2.fromOffset(0, 0), Visible = false, ZIndex = 20,
}, panel)
round(blockMenu, 9)
create("UIStroke", { Color = C.blue, Thickness = 1 }, blockMenu)
local speedMenu = create("Frame", {
    Position = UDim2.fromOffset(294, 170), Size = UDim2.fromOffset(162, 141),
    BackgroundColor3 = C.field, BorderSizePixel = 0, Visible = false, ZIndex = 20,
}, panel)
round(speedMenu, 9)
create("UIStroke", {Color = C.edge}, speedMenu)

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end
local function setStatus(message, color)
    if destroyed then return end
    local text, tint = tostring(message), color or C.dim
    if status.Text ~= text then status.Text = text end
    if status.TextColor3 ~= tint then status.TextColor3 = tint end
end
local function resetProgress(phase)
    UI.completed, UI.total = 0, 0
    phaseLabel.Text = phase or "READY TO CONVERT"
    progressCount.Text = ""
    progressFill.Position = UDim2.fromScale(0, 0)
    progressFill.Size = UDim2.fromScale(0, 1)
    progressFill.BackgroundColor3 = C.blue
    progressMeta.Text = "Convert  >  Place  >  Aim and click"
end
local function showBuildProgress(done, total, phase, wallElapsed)
    done, total = math.max(0, tonumber(done) or 0), math.max(0, tonumber(total) or 0)
    UI.completed, UI.total = done, total
    phaseLabel.Text = phase or "BUILDING YOUR WALL"
    progressCount.Text = string.format("%d / %d", done, total)
    progressFill.Position = UDim2.fromScale(0, 0)
    progressFill.Size = UDim2.fromScale(total > 0 and math.clamp(done / total, 0, 1) or 0, 1)
    local elapsed = UI.startedAt and math.max(0.001, os.clock() - UI.startedAt) or 0
    local measured = tonumber(wallElapsed)
    if measured and measured >= 0 and measured < math.huge then elapsed = measured end
    if done > 0 and elapsed > 0 then
        local rate = done / elapsed
        local eta = math.max(0, math.ceil((total - done) / rate))
        local remaining = eta >= 60 and string.format("%dm %02ds", math.floor(eta / 60), eta % 60) or (eta .. "s")
        progressMeta.Text = string.format("%.1f blocks/s  /  %ds elapsed%s", rate, math.floor(elapsed),
            done < total and phase ~= "BUILD STOPPED" and phase ~= "STOPPING" and ("  /  ETA ~" .. remaining) or "")
    elseif phase == "PREPARING MATERIAL" or phase == "CHECKING MATERIAL" then
        progressMeta.Text = "Checking available material before wall placement..."
    else
        progressMeta.Text = "Waiting for verified placements..."
    end
end
local function fitPanel(keepPosition)
    local view = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or viewport
    local scale = math.max(0.2, math.min(1, (view.X - 24) / UI.width, (view.Y - 24) / 520))
    panelScale.Scale = scale
    UI.fullHeight = math.max(520, math.min(820, (view.Y - 24) / scale))
    local height = UI.minimized and 62 or UI.fullHeight
    panel.Size = UDim2.fromOffset(UI.width, height)
    local x = keepPosition and panel.Position.X.Offset or (view.X - UI.width * scale - 24)
    local y = keepPosition and panel.Position.Y.Offset or math.max(12, (view.Y - height * scale) / 2)
    panel.Position = UDim2.fromOffset(math.clamp(x, 0, math.max(0, view.X - UI.width * scale)),
        math.clamp(y, 0, math.max(0, view.Y - height * scale)))
end
local function anchorMenu(menu, trigger)
    local scale = panelScale.Scale
    local x = (trigger.AbsolutePosition.X - panel.AbsolutePosition.X) / scale
    local y = (trigger.AbsolutePosition.Y - panel.AbsolutePosition.Y + trigger.AbsoluteSize.Y) / scale + 5
    menu.Position = UDim2.fromOffset(math.clamp(x, 12, UI.width - menu.Size.X.Offset - 12),
        math.clamp(y, 66, math.max(66, UI.fullHeight - menu.Size.Y.Offset - 12)))
end
local function busy() return processing or building end
api.IsBusy = busy
local function styleEnabled(object, enabled)
    object.AutoButtonColor = enabled
    object.TextTransparency = enabled and 0 or 0.55
end
local function syncButtons()
    if destroyed then return end
    styleEnabled(convertButton, not busy() and selectedBlock ~= nil and not inventoryRefreshing)
    styleEnabled(placeButton, not busy() and plan ~= nil)
    styleEnabled(blockButton, not busy())
    styleEnabled(refreshButton, not busy() and not inventoryRefreshing)
    styleEnabled(speedButton, not busy())
    styleEnabled(qualityButton, not busy())
    styleEnabled(samplingButton, not busy())
    local sourceMode = qualityIndex and qualityPresets[qualityIndex].mode == "source"
    styleEnabled(detailButton, not busy() and not sourceMode)
    detailButton.Text = sourceMode and "Detail: None (Source exact)" or ("Detail: " .. detailPresets[detailIndex].name .. "  >")
    styleEnabled(toolModeButton, not busy())
    styleEnabled(infiniteButton, not busy())
    styleEnabled(stopButton, busy() or placeTool ~= nil)
    convertButton.Text = processing and "Converting..." or "1  Convert image"
    placeButton.Text = building and "Building..." or (placeTool and "Re-equip Place" or "2  Place")
    for _, field in ipairs({ urlInput, widthInput, pixelInput, maxInput, paletteInput }) do
        field.TextEditable = not busy()
    end
end
local function clearGhost()
    if renderConnection then renderConnection:Disconnect(); renderConnection = nil end
    if ghost then ghost:Destroy(); ghost = nil end
    placement = nil
    placementAllowed, placementReason = false, nil
end
local function clearTool()
    clearGhost()
    for _, connection in ipairs(toolConnections) do connection:Disconnect() end
    table.clear(toolConnections)
    if placeTool then placeTool:Destroy(); placeTool = nil end
end
local function clearPreview()
    for _, child in ipairs(preview:GetChildren()) do
        if child:IsA("Frame") or child:IsA("ImageLabel") then child:Destroy() end
    end
    activePreviewPath = nil
    previewEmpty.Visible = true
    thumbnailCaption.Text = "Processed image"
end
local function invalidate()
    if destroyed or busy() then return end
    generation += 1
    plan = nil
    clearTool()
    clearPreview()
    resetProgress("SETTINGS CHANGED")
    local width, pixel = tonumber(widthInput.Text), tonumber(pixelInput.Text)
    if qualityIndex and qualityPresets[qualityIndex].mode == "source" then
        summary.Text = "Source: keeps the original image's pixel dimensions.\nPalette 0 preserves full color; pixel size is calculated."
    elseif width and pixel and width > 0 and pixel > 0 and width < math.huge and pixel < math.huge then
        summary.Text = string.format("%.4g studs / %.4g = %.0f pixels across.\nSmaller pixels give more detail and use more blocks.", width, pixel, math.ceil(width / pixel))
    else
        summary.Text = "Smaller pixels give more detail and use more blocks.\nAuto adjusts to the pixel limit; Source stays exact."
    end
    setStatus("Settings changed. Convert the image to update the plan.")
    syncButtons()
end
for _, field in ipairs({ urlInput, widthInput, pixelInput, maxInput, paletteInput }) do
    connect(field:GetPropertyChangedSignal("Text"), function()
        local expected = programmaticText[field]
        if expected ~= nil then
            if field.Text == expected then return end
            programmaticText[field] = nil
        end
        if field == pixelInput then
            qualityIndex = nil
            qualityButton.Text = "Resolution: Custom  >"
        elseif field == widthInput and qualityIndex and qualityPresets[qualityIndex].columns then
            local width = tonumber(widthInput.Text)
            if width and width > 0 and width < math.huge then
                setFieldText(pixelInput, string.format("%.10g", width / qualityPresets[qualityIndex].columns))
            end
        end
        invalidate()
    end)
end
connect(qualityButton.Activated, function()
    if busy() then return end
    qualityIndex = ((qualityIndex or 0) % #qualityPresets) + 1
    local preset = qualityPresets[qualityIndex]
    local width = tonumber(widthInput.Text)
    if preset.mode == "auto" then
        setFieldText(pixelInput, "0.125")
    elseif preset.columns and width and width > 0 and width < math.huge then
        setFieldText(pixelInput, string.format("%.10g", width / preset.columns))
    end
    setFieldText(maxInput, tostring(preset.maxPixels))
    qualityButton.Text = "Resolution: " .. preset.name .. (preset.columns and (" (" .. preset.columns .. " px)") or "") .. "  >"
    invalidate()
end)
connect(samplingButton.Activated, function()
    if busy() then return end
    samplingIndex = (samplingIndex % #samplingPresets) + 1
    if samplingPresets[samplingIndex].value == "nearest" then detailIndex = 1 end
    samplingButton.Text = "Sampling: " .. samplingPresets[samplingIndex].name .. "  >"
    invalidate()
end)
connect(detailButton.Activated, function()
    if busy() or (qualityIndex and qualityPresets[qualityIndex].mode == "source") then return end
    detailIndex = (detailIndex % #detailPresets) + 1
    invalidate()
end)
connect(toolModeButton.Activated, function()
    if busy() then return end
    toolMode = toolMode == "compatible" and "background" or "compatible"
    local compatible = toolMode == "compatible"
    if compatible and speed == "Rapid" then
        speed = "Fast"
        speedButton.Text = "Speed: Fast  v"
    end
    toolModeButton.Text = compatible and "Tools: Compatible  >" or "Tools: Hands free  >"
    explanation.Text = compatible
        and "Compatible equips the game tools during each operation.\nLeave build tools alone until the job finishes."
        or "Choose a tool from your normal hotbar while the image builds.\nPrepares missing material and checks inventory."
    setStatus(compatible
        and "Compatible uses your build, scale, and paint tools during the job. Leave them alone until the job finishes."
        or "Hands free builds in the background. Select your normal tool from the hotbar to use its controls.", C.dim)
end)
connect(infiniteButton.Activated, function()
    if busy() then return end
    infiniteBlocks = not infiniteBlocks
    infiniteButton.Text = infiniteBlocks and "Infinite Blocks: ON  (verify inventory)" or "Infinite Blocks: OFF"
    infiniteButton.TextColor3 = infiniteBlocks and C.green or C.text
    setStatus(infiniteBlocks
        and "Prepares missing material, then checks the real inventory. If preparation cannot supply enough, the wall will not start."
        or "Material preparation is off. This build uses only your currently available material.", infiniteBlocks and C.yellow or C.dim)
end)
local function updateBlockCaption()
    blockButton.Text = selectedBlock and (selectedBlock .. "  (" .. tostring(chosenCount) .. ")  v") or "No buildable inventory found"
end
local function updateSummary()
    if not plan then return end
    local need = Adapter.materialNeed(plan)
    summary.Text = string.format("%d x %d pixels | %.2f x %.2f studs\n%d blocks | Need %d / available %d\nPixel: %.4g studs%s",
        plan.columns, plan.rows, plan.width_studs, plan.height_studs,
        plan.placement_count or plan.block_count, need, chosenCount, plan.pixel_studs,
        plan.grid_limited and " | Auto resolution capped" or "")
end
local function refreshInventory()
    if destroyed or busy() or inventoryRefreshing then return end
    inventoryRefreshing = true
    syncButtons()
    task.spawn(function()
        local ok, result = pcall(Adapter.inventory)
        inventoryRefreshing = false
        if destroyed then return end
        if not ok or type(result) ~= "table" then
            setStatus("Could not read block inventory: " .. tostring(result), C.red)
            syncButtons()
            return
        end
        local cleaned = {}
        for _, item in ipairs(result) do
            if type(item) == "table" and type(item.name) == "string" and type(item.count) == "number" then
                table.insert(cleaned, { name = item.name, count = math.max(0, math.floor(item.count)) })
            end
        end
        table.sort(cleaned, function(a, b)
            if a.count == b.count then return a.name < b.name end
            return a.count > b.count
        end)
        inventory = cleaned
        local oldSelection = selectedBlock
        local matched = false
        for _, item in ipairs(inventory) do
            if item.name == selectedBlock then chosenCount = item.count; matched = true; break end
        end
        if not matched then
            selectedBlock = inventory[1] and inventory[1].name or nil
            chosenCount = inventory[1] and inventory[1].count or 0
        end
        if oldSelection and oldSelection ~= selectedBlock then invalidate() end
        updateBlockCaption()
        updateSummary()
        for _, child in ipairs(blockMenu:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for index, item in ipairs(inventory) do
            local row = button(blockMenu, item.name .. "  /  " .. item.count .. " available", 6, (index - 1) * 34 + 5, 426, 30)
            row.ZIndex = 21
            row.TextSize = 12
            row.Activated:Connect(function()
                if busy() then return end
                selectedBlock, chosenCount = item.name, item.count
                blockMenu.Visible = false
                updateBlockCaption()
                invalidate()
            end)
        end
        blockMenu.CanvasSize = UDim2.fromOffset(0, #inventory * 34 + 10)
        if #inventory == 0 then setStatus("No building materials found. Join the game and obtain blocks, then refresh.", C.yellow) end
        syncButtons()
    end)
end
connect(refreshButton.Activated, refreshInventory)
connect(blockButton.Activated, function()
    if busy() then return end
    speedMenu.Visible = false
    anchorMenu(blockMenu, blockButton)
    blockMenu.Visible = not blockMenu.Visible
end)
connect(speedButton.Activated, function()
    if busy() then return end
    blockMenu.Visible = false
    anchorMenu(speedMenu, speedButton)
    speedMenu.Visible = not speedMenu.Visible
end)
for index, name in ipairs({ "Normal", "Fast", "Turbo", "Rapid" }) do
    local choice = button(speedMenu, name, 5, 5 + (index - 1) * 33, 152, 29)
    choice.ZIndex = 21
    connect(choice.Activated, function()
        if busy() then return end
        if name == "Rapid" and toolMode ~= "background" then
            speedMenu.Visible = false
            setStatus("Select Hands free tools to use Rapid speed.", C.yellow)
            return
        end
        speed = name
        speedButton.Text = "Speed: " .. name .. "  v"
        speedMenu.Visible = false
        setStatus(name == "Rapid" and "Rapid adjusts to the game's response time and slows down when block updates fall behind. Only verified blocks count toward progress."
            or (name == "Turbo" and "Turbo uses bounded parallel requests. The game can still limit build speed." or (name .. " speed selected.")))
    end)
end

local function numberField(field, name, minimum, maximum, integer)
    local number = tonumber(field.Text)
    if not number or number ~= number or number == math.huge or number == -math.huge then error(name .. " must be a number.", 0) end
    if number < minimum or number > maximum then error(name .. " must be between " .. minimum .. " and " .. maximum .. ".", 0) end
    if integer and number % 1 ~= 0 then error(name .. " must be a whole number.", 0) end
    return number
end
local function drawPreview(imagePlan)
    clearPreview()
    local source = imagePlan.thumbnail
    if type(source) ~= "table" or type(source.cells) ~= "table" then source = imagePlan end
    local columns, rows = source.columns, source.rows
    if type(source.cells) ~= "table" or type(columns) ~= "number" or type(rows) ~= "number"
        or columns < 1 or rows < 1 then return end
    previewEmpty.Visible = false
    thumbnailCaption.Text = "Quick preview"
    local map = {}
    for _, cell in ipairs(source.cells) do map[cell.y * columns + cell.x] = cell.color end
    local step = math.max(1, math.ceil(math.max(columns, rows) / 36))
    local displayColumns, displayRows = math.ceil(columns / step), math.ceil(rows / step)
    local scale = math.min(UI.previewSize / columns, UI.previewSize / rows)
    local offsetX, offsetY = (UI.previewSize - columns * scale) / 2, (UI.previewSize - rows * scale) / 2
    for y = 0, displayRows - 1 do
        for x = 0, displayColumns - 1 do
            local sourceX = math.min(columns - 1, x * step + math.floor(step / 2))
            local sourceY = math.min(rows - 1, y * step + math.floor(step / 2))
            local color = map[sourceY * columns + sourceX]
            if color then
                create("Frame", {
                    Position = UDim2.fromOffset(offsetX + x * step * scale, offsetY + y * step * scale),
                    Size = UDim2.fromOffset(math.min(step, columns - x * step) * scale, math.min(step, rows - y * step) * scale),
                    BackgroundColor3 = Color3.fromRGB(color[1], color[2], color[3]), BorderSizePixel = 0,
                }, preview)
            end
        end
    end
end
local function deletePreviewFile(path)
    if type(delfile) ~= "function" or path == activePreviewPath then return false end
    -- Only paths written by this script enter this list; never scan or delete others.
    local index = table.find(previewFiles, path)
    if not index then return false end
    local ok = pcall(delfile, path)
    if not ok and type(isfile) == "function" then
        local checkOK, exists = pcall(isfile, path)
        if checkOK and not exists then ok = true end
    end
    if ok then
        table.remove(previewFiles, index)
        if ENV.ImageBuilder == api then Backend.savePreviewFiles(previewFiles) end
    end
    return ok
end
-- Restore only this app's validated preview journal; never enumerate other files.
for _, path in ipairs(table.clone(previewFiles)) do deletePreviewFile(path) end
local function loadNativePreview(imagePlan, expectedGeneration)
    local assetFn = type(getcustomasset) == "function" and getcustomasset
        or (type(getsynasset) == "function" and getsynasset)
    local id = imagePlan.id
    if type(writefile) ~= "function" or type(delfile) ~= "function" or type(assetFn) ~= "function"
        or type(id) ~= "string" or #id ~= 24 or not id:match("^[0-9a-fA-F]+$") then return end
    local function current()
        return not destroyed and generation == expectedGeneration and plan == imagePlan
    end
    task.spawn(function()
        if not current() then return end
        local ok, bytes = pcall(Backend.preview, id)
        if not current() or not ok then return end
        if type(bytes) ~= "string" or #bytes > 4 * 1024 * 1024
            or bytes:sub(1, 8) ~= "\137PNG\13\10\26\10" then return end
        local folder = "baft image builder"
        if not current() then return end
        -- The loader has already verified this executor-relative folder.
        -- Keep at most three locally written preview files, even without delfile.
        while #previewFiles >= 3 do
            local victim
            for _, path in ipairs(previewFiles) do
                if path ~= activePreviewPath then victim = path; break end
            end
            if not victim or not deletePreviewFile(victim) then return end
            if not current() then return end
        end
        -- Unique names prevent native asset-cache reuse and stale-job deletion races.
        local path = folder .. "/preview_" .. id .. ".png"
        table.insert(previewFiles, path)
        if not Backend.savePreviewFiles(previewFiles) then
            table.remove(previewFiles, #previewFiles)
            return
        end
        local written = pcall(writefile, path, bytes)
        if not current() or not written then deletePreviewFile(path); return end
        local assetOK, asset = pcall(assetFn, path)
        if not current() then deletePreviewFile(path); return end
        if not assetOK or type(asset) ~= "string" or asset == "" then deletePreviewFile(path); return end
        local image = create("ImageLabel", {
            Name = "ProcessedImageThumbnail", BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0), Size = UDim2.fromScale(1, 1),
            Image = asset, ScaleType = Enum.ScaleType.Fit,
        }, nil)
        if not current() then image:Destroy(); deletePreviewFile(path); return end
        -- Keep the coarse fallback visible until Roblox loads the local PNG.
        image.Parent = preview
        local loadStart = os.clock()
        while not image.IsLoaded and os.clock() - loadStart < 3 do
            task.wait(0.05)
            if not current() or image.Parent ~= preview then image:Destroy(); deletePreviewFile(path); return end
        end
        if not image.IsLoaded then image:Destroy(); deletePreviewFile(path); return end
        image.Parent = nil
        clearPreview()
        previewEmpty.Visible = false
        activePreviewPath = path
        image.Parent = preview
        thumbnailCaption.Text = "Processed image"
    end)
end
local function safeError(value)
    return string.sub(tostring(value), 1, 700)
end
local function conversionSettings()
    local url = string.match(urlInput.Text, "^%s*(.-)%s*$")
    if not url:match("^https?://") then error("Paste a direct http:// or https:// image link.", 0) end
    if #url > 4096 then error("The image link is too long.", 0) end
    local palette = numberField(paletteInput, "Palette", 0, 256, true)
    if palette == 1 then error("Palette must be 0, or 2 to 256 colors.", 0) end
    local mode = qualityIndex and qualityPresets[qualityIndex].mode or "spacing"
    return {
        image_url = url, width_studs = numberField(widthInput, "Wall width", 0.05, 1000, false),
        pixel_studs = mode == "source" and 0.125 or numberField(pixelInput, "Pixel size", 0.001, 32, false),
        block_type = selectedBlock, max_blocks = numberField(maxInput, "Maximum pixels", 1, 250000, true),
        palette_size = palette, sampling = samplingPresets[samplingIndex].value, resolution_mode = mode,
        detail = mode == "source" and "none" or detailPresets[detailIndex].value,
        compact = true,
    }
end
connect(convertButton.Activated, function()
    if destroyed or busy() or inventoryRefreshing then return end
    local available, unavailableReason = Backend.available()
    if not available then setStatus(unavailableReason, C.red); return end
    if not selectedBlock then setStatus("Refresh your block inventory first.", C.yellow); return end
    local valid, settings = pcall(conversionSettings)
    if not valid then setStatus(safeError(settings), C.red); return end
    clearTool()
    blockMenu.Visible, speedMenu.Visible = false, false
    processing, cancelled = true, false
    plan = nil
    clearPreview()
    resetProgress("CONVERTING IMAGE")
    UI.startedAt = nil
    progressMeta.Text = "Local image processing / no blocks placed"
    generation += 1
    local requestGeneration = generation
    setStatus("Downloading image...")
    syncButtons()
    task.spawn(function()
        local ok, result = pcall(function()
            local decoded = Backend.convert(settings, {
                checkCancelled = function()
                    if destroyed or cancelled or generation ~= requestGeneration then error("Conversion cancelled.", 0) end
                end,
                progress = function(message)
                    if not destroyed and generation == requestGeneration then setStatus(tostring(message)) end
                end,
            })
            if type(decoded) ~= "table"
                or (type(decoded.rectangles) ~= "table" and type(decoded.cells) ~= "table")
                or type(decoded.columns) ~= "number" or type(decoded.rows) ~= "number"
                or decoded.columns < 1 or decoded.rows < 1 or decoded.columns * decoded.rows > 250000
                or type(decoded.width_studs) ~= "number" or type(decoded.height_studs) ~= "number"
                or type(decoded.pixel_studs) ~= "number" or type(decoded.block_count) ~= "number" then
                error("The image converter returned an invalid plan.", 0)
            end
            return decoded
        end)
        processing = false
        if destroyed then
            if Adapter.teardown then pcall(Adapter.teardown) end
            if ENV.ImageBuilder == api then ENV.ImageBuilder = nil end
            return
        end
        if cancelled or generation ~= requestGeneration then
            resetProgress("CONVERSION CANCELLED")
            setStatus("Conversion cancelled. No blocks were placed.", C.yellow)
        elseif not ok then
            resetProgress("CONVERSION FAILED")
            setStatus(safeError(result), C.red)
        else
            plan = result
            resetProgress("READY TO PLACE")
            progressMeta.Text = string.format("%d planned blocks / material checked before building", plan.placement_count or plan.block_count)
            if settings.resolution_mode == "source" then
                setFieldText(pixelInput, string.format("%.10g", plan.pixel_studs))
            end
            drawPreview(plan)
            loadNativePreview(plan, requestGeneration)
            updateSummary()
            local callOK, allowed, reason = pcall(Adapter.validate, plan)
            if callOK and allowed then
                local warning = ""
                if type(plan.warnings) == "table" then
                    for index, message in ipairs(plan.warnings) do
                        if index > 2 then break end
                        if type(message) == "string" then warning ..= "\n" .. string.sub(message, 1, 180) end
                    end
                end
                setStatus("Select Place, aim the green wall, then click. R turns 90 degrees; Q / E adjusts 15 degrees." .. warning, warning == "" and C.green or C.yellow)
            else
                setStatus(tostring(callOK and reason or allowed), C.yellow)
            end
        end
        syncButtons()
    end)
end)

local function mouseOverPanel()
    local mouse = UserInputService:GetMouseLocation()
    local position, size = panel.AbsolutePosition, panel.AbsoluteSize
    return mouse.X >= position.X and mouse.X <= position.X + size.X
        and mouse.Y >= position.Y and mouse.Y <= position.Y + size.Y
end
local function sendTelemetry(buildPlan, ok, result, buildToolMode, buildInfiniteBlocks, buildSpeed)
    local report = type(result) == "table" and {
        ok = result.ok == true, message = safeError(result.message or ""),
        completed = tonumber(result.completed) or 0,
        created = tonumber(result.created) or 0,
        total = tonumber(result.total) or (buildPlan.placement_count or buildPlan.block_count),
    } or { ok = false, message = safeError(result), completed = 0,
        total = buildPlan.placement_count or buildPlan.block_count }
    if not ok then report.ok = false end
    if type(result) == "table" and type(result.diagnostics) == "table" then
        local diag = result.diagnostics
        report.diagnostics = {
            tool_mode = safeError(diag.tool_mode or ""), phase = safeError(diag.phase or ""),
            requests_sent = tonumber(diag.requests_sent), observed_new_models = tonumber(diag.observed_new_models),
            observed_material_models = tonumber(diag.observed_material_models),
            returned_type = safeError(diag.returned_type or ""),
            nearest_position_error = tonumber(diag.nearest_position_error),
            last_batch_new_objects = tonumber(diag.last_batch_new_objects),
            placement_argument_count = tonumber(diag.placement_argument_count),
            placement_tool_held = diag.placement_tool_held,
            infinite_requested = diag.infinite_requested == true,
            material_required = tonumber(diag.material_required),
            inventory_before = tonumber(diag.inventory_before),
            inventory_after = tonumber(diag.inventory_after),
            prep_requests = tonumber(diag.prep_requests),
            prep_version = tonumber(diag.prep_version),
            prep_rounds = tonumber(diag.prep_rounds),
            prep_scale_requests = tonumber(diag.prep_scale_requests),
            prep_gain = tonumber(diag.prep_gain),
            prep_stop_reason = safeError(diag.prep_stop_reason or ""),
            preparation_status = safeError(diag.preparation_status or ""),
            temporary_block_remaining = diag.temporary_block_remaining,
            speed_mode = safeError(diag.speed_mode or ""),
            effective_request_rate = tonumber(diag.effective_request_rate),
            peak_pending = tonumber(diag.peak_pending),
            wall_elapsed_seconds = tonumber(diag.wall_elapsed_seconds),
            verified_blocks_per_second = tonumber(diag.verified_blocks_per_second),
            manual_selection_supported = diag.manual_selection_supported == true,
            manual_tool_name = safeError(diag.manual_tool_name or ""),
            manual_selection_revision = tonumber(diag.manual_selection_revision),
            pipeline_version = tonumber(diag.pipeline_version),
            pipeline_windows = tonumber(diag.pipeline_windows),
            pipeline_peak_ready = tonumber(diag.pipeline_peak_ready),
            pipeline_peak_active = tonumber(diag.pipeline_peak_active),
            pipeline_paint_batches = tonumber(diag.pipeline_paint_batches),
            manual_drains = tonumber(diag.manual_drains),
            rpc_completed = tonumber(diag.rpc_completed),
            rpc_latency_total_seconds = tonumber(diag.rpc_latency_total_seconds),
            rpc_latency_max_seconds = tonumber(diag.rpc_latency_max_seconds),
            rpc_latency_mean_seconds = tonumber(diag.rpc_latency_mean_seconds),
            worker_limit = tonumber(diag.worker_limit),
            batch_limit = tonumber(diag.batch_limit),
            peak_geometry_jobs = tonumber(diag.peak_geometry_jobs),
            max_request_rate = tonumber(diag.max_request_rate),
            max_pending_limit = tonumber(diag.max_pending_limit),
            adaptive_upshifts = tonumber(diag.adaptive_upshifts),
            adaptive_downshifts = tonumber(diag.adaptive_downshifts),
            adaptive_peak_rate = tonumber(diag.adaptive_peak_rate),
            adaptive_peak_workers = tonumber(diag.adaptive_peak_workers),
            rpc_latency_ewma_seconds = tonumber(diag.rpc_latency_ewma_seconds),
            monitor_delay_ewma_seconds = tonumber(diag.monitor_delay_ewma_seconds),
            monitor_delay_max_seconds = tonumber(diag.monitor_delay_max_seconds),
            replication_peak_waiting = tonumber(diag.replication_peak_waiting),
            replication_pause_count = tonumber(diag.replication_pause_count),
            verification_budget_seconds = tonumber(diag.verification_budget_seconds),
            verification_checks_peak = tonumber(diag.verification_checks_peak),
            verification_failure_phase = safeError(diag.verification_failure_phase or ""),
            verification_failure_owned = diag.verification_failure_owned,
            verification_position_error = tonumber(diag.verification_position_error),
            verification_size_error = tonumber(diag.verification_size_error),
            verification_color_error = tonumber(diag.verification_color_error),
            verification_right_dot = tonumber(diag.verification_right_dot),
            verification_up_dot = tonumber(diag.verification_up_dot),
            verification_wait_seconds = tonumber(diag.verification_wait_seconds),
        }
        if type(diag.prep_samples) == "table" then
            report.diagnostics.prep_samples = {}
            for index = 1, math.min(#diag.prep_samples, 32) do
                local sample = diag.prep_samples[index]
                if type(sample) == "table" then
                    table.insert(report.diagnostics.prep_samples, {
                        before = tonumber(sample.before), after = tonumber(sample.after),
                        requests = tonumber(sample.requests), gain = tonumber(sample.gain),
                    })
                end
            end
        end
    end
    task.spawn(function()
        pcall(Backend.report, {
                kind = "builder_result", result = report,
                settings = { width_studs = buildPlan.width_studs, pixel_studs = buildPlan.pixel_studs,
                    block_type = buildPlan.block_type, toolMode = buildToolMode, infiniteBlocks = buildInfiniteBlocks == true,
                    sampling = buildPlan.sampling, detail = buildPlan.detail, resolution_mode = buildPlan.resolution_mode,
                    speed = buildSpeed },
        })
    end)
end
-- Observe the existing native hotbar; never replace its UI or input handlers.
local function createManualToolSelector()
    local selection = {revision = 0}
    local listeners, bound = {}, setmetatable({}, {__mode = "k"})
    local closed = false
    local boundCount = 0
    local function listen(signal, callback)
        table.insert(listeners, signal:Connect(callback))
    end
    local function visible(object, root)
        local current, inRoot = object, false
        while current do
            if current:IsA("GuiObject") and not current.Visible then return false end
            if current:IsA("ScreenGui") and not current.Enabled then return false end
            if current == root then inRoot = true end
            current = current.Parent
        end
        return inRoot
    end
    local function requestSelection(tool)
        selection = {tool = tool, revision = selection.revision + 1, available = boundCount > 0}
    end
    local function selectSlot(slot, root)
        if closed or destroyed or not building or toolMode ~= "background" or UserInputService:GetFocusedTextBox() then return end
        local menuRead, menuOpen = pcall(function() return game:GetService("GuiService").MenuIsOpen end)
        if menuRead and menuOpen then return end
        if not slot or not visible(slot, root) then return end
        local label = slot:FindFirstChild("ToolName")
        if not label or not label:IsA("TextLabel") or label.Text == "" then return end
        local chosen
        for _, container in pairs({player.Character, player:FindFirstChildOfClass("Backpack")}) do
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == label.Text then
                    if chosen and chosen ~= tool then requestSelection(nil); return end -- Clear old controls; do not guess duplicates.
                    chosen = tool
                end
            end
        end
        if not chosen then requestSelection(nil); return end
        if selection.tool == chosen then requestSelection(nil) else requestSelection(chosen) end
    end
    local ok = pcall(function()
        local core = game:GetService("CoreGui")
        local robloxGui = core:FindFirstChild("RobloxGui")
        local backpack = robloxGui and robloxGui:FindFirstChild("Backpack")
        if not backpack then return end
        local function bind(object)
            local slot = object:IsA("GuiButton") and object or object.Parent
            if not slot or not slot:IsA("GuiButton") or bound[slot] or not slot:FindFirstChild("ToolName") then return end
            bound[slot] = true
            boundCount += 1
            selection.available = true
            listen(slot.Activated, function() selectSlot(slot, backpack) end)
        end
        for _, object in ipairs(backpack:GetDescendants()) do bind(object) end
        listen(backpack.DescendantAdded, bind)
        local keySlots = {One = "1", Two = "2", Three = "3", Four = "4", Five = "5",
            Six = "6", Seven = "7", Eight = "8", Nine = "9", Zero = "10"}
        listen(UserInputService.InputBegan, function(input)
            local name = keySlots[input.KeyCode.Name]
            local hotbar = backpack:FindFirstChild("Hotbar")
            if name and hotbar then selectSlot(hotbar:FindFirstChild(name), backpack) end
        end)
    end)
    selection.available = ok and boundCount > 0
    return function() return selection end, function()
        closed = true
        for _, listener in ipairs(listeners) do listener:Disconnect() end
        table.clear(listeners)
    end
end

local function beginBuild(origin)
    if busy() or not plan then return end
    local callOK, allowed, reason = pcall(Adapter.validate, plan)
    if not callOK or not allowed then setStatus(safeError(callOK and reason or allowed), C.red); return end
    local buildPlan = plan
    local buildToolMode = toolMode
    local buildInfiniteBlocks = infiniteBlocks
    local buildSpeed = speed
    clearTool()
    building, cancelled = true, false
    resetProgress(buildInfiniteBlocks and "CHECKING MATERIAL" or "BUILDING YOUR WALL")
    UI.startedAt = os.clock()
    showBuildProgress(0, buildPlan.placement_count or buildPlan.block_count, phaseLabel.Text)
    blockMenu.Visible, speedMenu.Visible = false, false
    setStatus(buildToolMode == "compatible"
        and "Building in Compatible mode. Leave the build, scale, and paint tools alone until it finishes. Stop cancels queued work."
        or "Hands free is starting. Select a normal tool from the hotbar to use it while the image builds.")
    syncButtons()
    task.spawn(function()
        local getManualToolSelection, stopManualSelection = createManualToolSelector()
        local ok, result = pcall(Adapter.build, buildPlan, origin, {
            speed = buildSpeed,
            toolMode = buildToolMode,
            infiniteBlocks = buildInfiniteBlocks,
            getManualToolSelection = getManualToolSelection,
            shouldCancel = function() return cancelled or destroyed end,
            onProgress = function(done, total, message)
                if destroyed then return end
                local text = tostring(message or "")
                local preparing = done == 0 and (text:lower():find("prepar", 1, true) or text:lower():find("material", 1, true))
                showBuildProgress(done, total, cancelled and "STOPPING" or (preparing and "PREPARING MATERIAL" or "BUILDING YOUR WALL"))
                setStatus(text ~= "" and text or "Waiting for the next verified block...", cancelled and C.yellow or C.dim)
            end,
        })
        stopManualSelection()
        building = false
        sendTelemetry(buildPlan, ok, result, buildToolMode, buildInfiniteBlocks, buildSpeed)
        if destroyed then
            if Adapter.teardown then pcall(Adapter.teardown) end
            if ENV.ImageBuilder == api then ENV.ImageBuilder = nil end
            return
        end
        if not ok then
            phaseLabel.Text = "BUILD STOPPED"
            progressFill.BackgroundColor3 = C.yellow
            setStatus("Build stopped: " .. safeError(result), C.red)
        elseif type(result) ~= "table" then
            phaseLabel.Text = "RESULT NOT VERIFIED"
            progressFill.BackgroundColor3 = C.yellow
            setStatus("Build ended without a verified result. Check the world before trying again.", C.yellow)
        else
            showBuildProgress(result.completed, result.total or (buildPlan.placement_count or buildPlan.block_count),
                result.ok and "BUILD COMPLETE" or "BUILD STOPPED",
                type(result.diagnostics) == "table" and result.diagnostics.wall_elapsed_seconds or nil)
            progressFill.BackgroundColor3 = result.ok and C.green or C.yellow
            local diagnostics = result.diagnostics
            if result.completed == 0 and type(diagnostics) == "table" and diagnostics.infinite_requested
                and diagnostics.preparation_status == "failed" then
                progressMeta.Text = string.format("Material: %.0f available / %.0f needed  |  %d preparation rounds",
                    tonumber(diagnostics.inventory_after) or tonumber(diagnostics.inventory_before) or 0,
                    tonumber(diagnostics.material_required) or 0, tonumber(diagnostics.prep_rounds) or 0)
            end
            setStatus(string.format("%s\n%d / %d blocks completed.", tostring(result.message or (result.ok and "Build complete." or "Build stopped.")),
                tonumber(result.completed) or 0, tonumber(result.total) or (buildPlan.placement_count or buildPlan.block_count)), result.ok and C.green or C.yellow)
        end
        syncButtons()
        refreshInventory()
    end)
end
local function equipPlacementTool()
    if destroyed or busy() or not plan then return end
    local callOK, allowed, reason = pcall(Adapter.validate, plan)
    if not callOK or not allowed then setStatus(safeError(callOK and reason or allowed), C.yellow); return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local backpack = player:FindFirstChildOfClass("Backpack")
    if not humanoid or not backpack or humanoid.Health <= 0 then setStatus("Wait for your character to spawn, then select Place.", C.yellow); return end
    if placeTool then humanoid:EquipTool(placeTool); return end
    placeTool = create("Tool", { Name = "Place Image", RequiresHandle = false, CanBeDropped = false, ToolTip = "Aim the green wall. Click to build. R: 90 degrees. Q / E: 15 degrees." }, backpack)
    local activeTool = placeTool
    local previewPlan = plan
    -- Every new placement starts aligned with the world, independent of the avatar.
    -- Re-equipping an existing placement tool preserves the user's chosen rotation.
    yaw = 0
    table.insert(toolConnections, activeTool.Equipped:Connect(function()
        if busy() or destroyed or placeTool ~= activeTool then return end
        clearGhost()
        ghost = create("Part", {
            Name = "ImageWallPlacementPreview", Anchored = true, CanCollide = false,
            CanTouch = false, CanQuery = false, CastShadow = false, Locked = true,
            Transparency = 1, Material = Enum.Material.ForceField,
            Color = C.green, Size = Vector3.new(previewPlan.width_studs, previewPlan.height_studs, math.max(0.05, math.min(previewPlan.pixel_studs, 1))),
        }, Workspace)
        local outline = create("SelectionBox", { Adornee = ghost, Color3 = C.green, LineThickness = 0.035, SurfaceTransparency = 1, Visible = false }, ghost)
        local filter = RaycastParams.new()
        filter.FilterType = Enum.RaycastFilterType.Exclude
        filter.FilterDescendantsInstances = { player.Character, ghost }
        filter.IgnoreWater = false
        renderConnection = RunService.RenderStepped:Connect(function()
            if not ghost or not Workspace.CurrentCamera then return end
            local currentCharacter = player.Character
            if not currentCharacter or activeTool.Parent ~= currentCharacter then clearGhost(); return end
            filter.FilterDescendantsInstances = { currentCharacter, ghost }
            local mouse = UserInputService:GetMouseLocation()
            local ray = Workspace.CurrentCamera:ViewportPointToRay(mouse.X, mouse.Y)
            local hit = Workspace:Raycast(ray.Origin, ray.Direction * 1500, filter)
            if hit and not mouseOverPanel() then
                placement = CFrame.new(hit.Position) * CFrame.Angles(0, yaw, 0)
                placementAllowed, placementReason = true, nil
                if type(Adapter.canPlace) == "function" then
                    local ok, allowed, reason = pcall(Adapter.canPlace, previewPlan, placement)
                    placementAllowed = ok and allowed == true
                    placementReason = ok and reason or tostring(allowed)
                end
                ghost.CFrame = placement * CFrame.new(0, previewPlan.height_studs / 2, 0)
                ghost.Transparency = 0.72
                ghost.Color = placementAllowed and C.green or C.red
                outline.Color3, outline.Visible = ghost.Color, true
            else
                placement = nil
                placementAllowed = false
                ghost.Transparency = 1
                outline.Visible = false
            end
        end)
        phaseLabel.Text = "CHOOSE PLACEMENT"
        progressMeta.Text = "R: turn 90 degrees  /  Q or E: turn 15 degrees"
        setStatus("Aim to set the bottom center of the wall. The green outline follows your cursor. Click to build.", C.green)
    end))
    table.insert(toolConnections, activeTool.Unequipped:Connect(clearGhost))
    table.insert(toolConnections, activeTool.Activated:Connect(function()
        if destroyed or busy() or UserInputService:GetFocusedTextBox() or mouseOverPanel() then return end
        if not placement then setStatus("Aim at a surface outside the window first.", C.yellow); return end
        if not placementAllowed then setStatus(placementReason or "Move the whole wall inside your own build area.", C.yellow); return end
        beginBuild(placement)
    end))
    humanoid:EquipTool(activeTool)
    syncButtons()
end
connect(placeButton.Activated, equipPlacementTool)

function api.Stop()
    if destroyed then return end
    cancelled = true
    generation += 1
    clearTool()
    if busy() then
        phaseLabel.Text = "STOPPING"
        setStatus("Stopping... waiting for requests already in progress to finish.", C.yellow)
    else
        resetProgress(plan and "READY TO PLACE" or "READY TO CONVERT")
        setStatus(plan and "Placement cancelled. The converted image is still ready." or "Stopped. Convert an image when ready.", C.yellow)
    end
    syncButtons()
end
function api.Destroy()
    if destroyed then return end
    destroyed, cancelled = true, true
    generation += 1
    clearTool()
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
    gui:Destroy()
    activePreviewPath = nil
    for _, path in ipairs(table.clone(previewFiles)) do deletePreviewFile(path) end
    if not busy() then
        if Adapter.teardown then pcall(Adapter.teardown) end
        if ENV.ImageBuilder == api then ENV.ImageBuilder = nil end
    end
end
connect(stopButton.Activated, api.Stop)
connect(close.Activated, api.Destroy)
connect(minimize.Activated, function()
    UI.minimized = not UI.minimized
    blockMenu.Visible, speedMenu.Visible = false, false
    for _, object in ipairs(content) do object.Visible = not UI.minimized end
    fitPanel(true)
    minimize.Text = UI.minimized and "+" or "-"
end)
local dragStart, panelStart
connect(header.InputBegan, function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
        dragStart, panelStart = inputObject.Position, panel.Position
        blockMenu.Visible, speedMenu.Visible = false, false
    end
end)
connect(UserInputService.InputEnded, function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then dragStart = nil end
end)
connect(UserInputService.InputChanged, function(inputObject)
    if dragStart and (inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch) then
        local delta = inputObject.Position - dragStart
        local currentViewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or viewport
        panel.Position = UDim2.fromOffset(
            math.clamp(panelStart.X.Offset + delta.X, 0, math.max(0, currentViewport.X - UI.width * panelScale.Scale)),
            math.clamp(panelStart.Y.Offset + delta.Y, 0, math.max(0, currentViewport.Y - panel.Size.Y.Offset * panelScale.Scale)))
    end
end)
connect(UserInputService.InputBegan, function(inputObject, processed)
    if destroyed or processed or UserInputService:GetFocusedTextBox() then return end
    if ghost then
        local key = inputObject.KeyCode
        if key == Enum.KeyCode.R then yaw += math.rad(90)
        elseif key == Enum.KeyCode.Q then yaw -= math.rad(15)
        elseif key == Enum.KeyCode.E then yaw += math.rad(15) end
    end
end)
connect(player.CharacterRemoving, function()
    api.Stop()
    if not busy() then setStatus("Character respawned. Select Place again when ready.", C.yellow) end
end)
connect(scroll:GetPropertyChangedSignal("CanvasPosition"), function()
    blockMenu.Visible, speedMenu.Visible = false, false
end)
local viewportConnection
local function watchViewport()
    if viewportConnection then viewportConnection:Disconnect() end
    local currentCamera = Workspace.CurrentCamera
    if currentCamera then
        viewportConnection = connect(currentCamera:GetPropertyChangedSignal("ViewportSize"), function()
            blockMenu.Visible, speedMenu.Visible = false, false
            fitPanel(true)
        end)
    end
    fitPanel(true)
end
connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), watchViewport)
watchViewport()
fitPanel(false)
connect(RunService.Heartbeat, function()
    if processing and not destroyed then
        -- Indeterminate motion during conversion is not a fabricated percentage.
        progressFill.Size = UDim2.fromScale(0.24, 1)
        progressFill.Position = UDim2.fromScale((os.clock() % 1.8) / 1.8 * 1.24 - 0.24, 0)
    end
end)
syncButtons()
refreshInventory()
