-- Pure-data fixtures. No Roblox/executor/network APIs are invoked.
local realClock, fakeClock = os.clock, nil
local os = {clock = function() return fakeClock or realClock() end}
local Planner = (function()
--[[LOCAL_PLANNER_SOURCE]]
end)()
local tests = 0
local function equal(actual, expected)
    assert(actual == expected, tostring(actual) .. " ~= " .. tostring(expected))
end
local function near(actual, expected, tolerance)
    assert(math.abs(actual - expected) <= (tolerance or 1e-9), tostring(actual) .. " differs from " .. tostring(expected))
end
local function test(name, callback)
    local ok, message = pcall(callback)
    assert(ok, name .. ": " .. tostring(message))
    tests += 1
    print("PASS " .. name)
end
local function image(w, h, pixel)
    local bytes = buffer.create(w * h * 4)
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local r, g, b, a = pixel(x, y)
            local at = (y * w + x) * 4
            buffer.writeu8(bytes, at, r); buffer.writeu8(bytes, at + 1, g)
            buffer.writeu8(bytes, at + 2, b); buffer.writeu8(bytes, at + 3, a == nil and 255 or a)
        end
    end
    return bytes
end
local function settings(changes)
    local result = {width_studs = 4, pixel_studs = 1, max_blocks = 10000, block_type = "PlasticBlock", sampling = "nearest"}
    for key, value in pairs(changes or {}) do result[key] = value end
    return result
end
local function solid() return 20, 40, 60, 255 end
local function convert(w, h, pixel, changes, hooks)
    return Planner.convertRGBA(w, h, image(w, h, pixel), settings(changes), hooks)
end
local function rejects(callback, needle)
    local ok, message = pcall(callback)
    assert(not ok, "Expected rejection")
    assert(string.find(tostring(message), needle, 1, true), tostring(message) .. " lacks " .. needle)
end
local function assertCover(plan, preview)
    local pixels, covered = {}, 0
    local lastY, lastX = -1, -1
    for _, rect in ipairs(plan.rectangles) do
        assert(rect.w >= 1 and rect.h >= 1 and rect.x >= 0 and rect.y >= 0)
        assert(rect.x + rect.w <= plan.columns and rect.y + rect.h <= plan.rows)
        assert(rect.w * plan.pixel_studs <= 32 + 1e-9 and rect.h * plan.pixel_studs <= 32 + 1e-9)
        assert(rect.y > lastY or rect.y == lastY and rect.x >= lastX, "Rectangle order must be row-major")
        lastY, lastX = rect.y, rect.x
        for y = rect.y, rect.y + rect.h - 1 do
            for x = rect.x, rect.x + rect.w - 1 do
                local index = y * plan.columns + x
                assert(pixels[index] == nil, "Rectangles overlap")
                pixels[index] = rect.color
                covered += 1
            end
        end
    end
    equal(covered, plan.block_count); equal(#plan.rectangles, plan.placement_count)
    if preview.width == plan.columns and preview.height == plan.rows then
        for index = 0, plan.columns * plan.rows - 1 do
            local offset, color = index * 4, pixels[index]
            if color then
                for channel = 1, 3 do equal(buffer.readu8(preview.rgba, offset + channel - 1), color[channel]) end
                equal(buffer.readu8(preview.rgba, offset + 3), 255)
            else equal(buffer.readu8(preview.rgba, offset + 3), 0) end
        end
    end
    if plan.cells then
        equal(#plan.cells, covered)
        for _, cell in ipairs(plan.cells) do
            local color = pixels[cell.y * plan.columns + cell.x]
            assert(color)
            for channel = 1, 3 do equal(color[channel], cell.color[channel]) end
        end
    end
    return pixels
end

test("Requested spacing preserves physical width with square pixels", function()
    local plan, preview = convert(2, 2, solid, {width_studs = 50, pixel_studs = 0.5})
    equal(plan.columns, 100); equal(plan.rows, 100); near(plan.pixel_studs, 0.5)
    near(plan.width_studs, 50); near(plan.height_studs, 50); equal(plan.placement_count, 4)
    equal(plan.cells, nil); equal(plan.compact, true); assertCover(plan, preview)
end)

test("Non-divisible and decimal spacing use stable upward column rounding", function()
    local plan = convert(2, 2, solid, {width_studs = 10, pixel_studs = 3})
    equal(plan.columns, 4); near(plan.pixel_studs, 2.5); near(plan.requested_pixel_studs, 3)
    plan = convert(14, 1, solid, {width_studs = 0.14, pixel_studs = 0.01, max_blocks = 14})
    equal(plan.columns, 14); equal(plan.rows, 1)
end)

test("Aspect rows round half upward", function()
    local plan = convert(2, 1, solid, {width_studs = 3, pixel_studs = 1})
    equal(plan.columns, 3); equal(plan.rows, 2); near(plan.height_studs, 2)
end)

test("Source preserves every visible RGB and disables requested sharpening", function()
    local raw = image(4, 2, function(x, y) return x * 50 + 1, y * 110 + 3, x + y, x == 0 and 0 or 255 end)
    local plan, preview = Planner.convertRGBA(4, 2, raw,
        settings({resolution_mode = "source", detail = "strong", sampling = "lanczos", pixel_studs = 0.001, include_cells = true}))
    equal(plan.columns, 4); equal(plan.rows, 2); equal(plan.detail, "none"); equal(plan.requested_detail, "strong")
    equal(plan.detail_applied, false); equal(plan.block_count, 6); assert(#plan.warnings > 0)
    local reconstructed = assertCover(plan, preview)
    for index, color in pairs(reconstructed) do
        for c = 1, 3 do equal(color[c], buffer.readu8(raw, index * 4 + c - 1)) end
    end
end)

test("Packed RGBA strings and buffers produce identical Source pixels", function()
    local raw = image(3, 2, function(x, y) return x * 40, y * 70, 255, 255 end)
    local a, pa = Planner.convertRGBA(3, 2, raw, settings({resolution_mode = "source"}))
    local b, pb = Planner.convertRGBA(3, 2, buffer.tostring(raw), settings({resolution_mode = "source"}))
    equal(a.block_count, b.block_count); equal(a.placement_count, b.placement_count)
    equal(buffer.tostring(pa.rgba), buffer.tostring(pb.rgba))
end)

test("Auto caps full grid while exact Source and spacing reject excess before transparency", function()
    local plan = convert(2, 1, solid, {width_studs = 100, pixel_studs = 0.01, max_blocks = 10000, resolution_mode = "auto"})
    assert(plan.columns * plan.rows <= 10000); equal(plan.grid_limited, true); assert(#plan.warnings > 0)
    rejects(function() convert(4, 4, solid, {resolution_mode = "source", max_blocks = 10}) end, "Source resolution")
    rejects(function() convert(4, 4, function() return 0, 0, 0, 0 end, {width_studs = 50, pixel_studs = 0.01}) end, "before transparency")
end)

test("Auto supports250000 cells and remains cooperative with bounded preview", function()
    local yields = 0
    local plan, preview = convert(1, 1, solid,
        {width_studs = 50, pixel_studs = 0.001, max_blocks = 250000, resolution_mode = "auto"},
        {yield = function() yields += 1 end})
    equal(plan.columns, 500); equal(plan.rows, 500); equal(plan.block_count, 250000)
    assert(yields > 10); assert(preview.width <= 256 and preview.height <= 256)
    assert(plan.thumbnail.columns <= 48 and plan.thumbnail.rows <= 48)
    equal(buffer.len(preview.rgba), preview.width * preview.height * 4)
end)

test("Explicit columns resolve presets without floating-point ambiguity", function()
    local plan = convert(16, 9, solid, {width_studs = 50, resolution_mode = "columns", columns = 128})
    equal(plan.columns, 128); equal(plan.rows, 72); near(plan.pixel_studs, 50 / 128)
    equal(plan.resolution_mode, "columns")
end)

test("Transparent pixels never build including zero alpha threshold", function()
    local plan, preview = convert(3, 1, function(x) return 255, 0, 0, x == 0 and 0 or x end,
        {resolution_mode = "source", alpha_threshold = 0})
    equal(plan.block_count, 2); equal(plan.transparent_cell_count, 1); assertCover(plan, preview)
    plan, preview = convert(3, 1, function() return 123, 45, 67, 0 end, {resolution_mode = "source"})
    equal(plan.block_count, 0); equal(plan.placement_count, 0); equal(plan.color_count, 0); assertCover(plan, preview)
end)

test("Area reduction computes weighted averages on both axis orders", function()
    local plan, preview = convert(2, 2, function(x, y) return x * 255, y * 255, 0, 255 end,
        {width_studs = 1, sampling = "area"})
    equal(plan.columns, 1); equal(plan.rows, 1)
    local color = plan.rectangles[1].color
    equal(color[1], 128); equal(color[2], 128); equal(color[3], 0); assertCover(plan, preview)
    plan, preview = convert(3, 2, function(x, y) return x * 60, y * 200, 0, 255 end,
        {width_studs = 2, sampling = "area"})
    equal(plan.columns, 2); equal(plan.rows, 1)
    equal(plan.rectangles[1].color[1], 20); equal(plan.rectangles[2].color[1], 100)
    equal(plan.rectangles[1].color[2], 100); assertCover(plan, preview)
end)

test("Premultiplied filters ignore hidden transparent RGB", function()
    for _, mode in ipairs({"area", "lanczos"}) do
        local function a(x) return x == 0 and 255 or 0, 0, x == 0 and 0 or 255, x == 0 and 255 or 0 end
        local function b(x) return x == 0 and 255 or 64, x == 0 and 0 or 123, x == 0 and 0 or 9, x == 0 and 255 or 0 end
        local pa, previewA = convert(2, 1, a, {width_studs = 9, sampling = mode, alpha_threshold = 1})
        local pb, previewB = convert(2, 1, b, {width_studs = 9, sampling = mode, alpha_threshold = 1})
        equal(buffer.tostring(previewA.rgba), buffer.tostring(previewB.rgba)); equal(pa.block_count, pb.block_count)
        for _, rect in ipairs(pa.rectangles) do equal(rect.color[1], 255); equal(rect.color[2], 0); equal(rect.color[3], 0) end
    end
end)

test("Lanczos smooths an enlarged edge and nearest retains only original colors", function()
    local function source(x) return x * 255, x * 255, x * 255, 255 end
    local nearest = convert(2, 1, source, {width_studs = 10, sampling = "nearest"})
    local smooth, preview = convert(2, 1, source, {width_studs = 10, sampling = "lanczos"})
    equal(nearest.color_count, 2); assert(smooth.color_count > 2); equal(smooth.upscaled, true)
    assert(#smooth.warnings > 0); assertCover(smooth, preview)
end)

test("Lanczos preserves constant opaque colors during reduction and enlargement", function()
    for _, dims in ipairs({{19, 7, 3}, {3, 7, 16}}) do
        local plan, preview = convert(dims[1], dims[2], solid, {width_studs = dims[3], sampling = "lanczos"})
        equal(plan.color_count, 1)
        for _, rect in ipairs(plan.rectangles) do equal(rect.color[1], 20); equal(rect.color[2], 40); equal(rect.color[3], 60) end
        assertCover(plan, preview)
    end
end)

test("Sharpening increases edge contrast without changing alpha visibility", function()
    local function source(x) local n = x < 3 and 80 or 160; return n, n, n, 255 end
    local plain, p0 = convert(6, 1, source, {width_studs = 6, detail = "none"})
    local light, p1 = convert(6, 1, source, {width_studs = 6, detail = "light"})
    local strong, p2 = convert(6, 1, source, {width_studs = 6, detail = "strong"})
    assert(buffer.readu8(p1.rgba, 2 * 4) < buffer.readu8(p0.rgba, 2 * 4))
    assert(buffer.readu8(p2.rgba, 3 * 4) > buffer.readu8(p1.rgba, 3 * 4))
    equal(plain.block_count, light.block_count); equal(light.block_count, strong.block_count)
    equal(strong.detail_applied, true)
end)

test("Sharpening excludes hidden and below-threshold neighbor colors", function()
    local function sourceA(x) return x < 2 and 100 or 255, 50, 25, x < 2 and 255 or 10 end
    local function sourceB(x) return x < 2 and 100 or 0, x < 2 and 50 or 255, 25, x < 2 and 255 or 10 end
    for _, detail in ipairs({"light", "strong"}) do
        local _, a = convert(4, 1, sourceA, {width_studs = 4, detail = detail, alpha_threshold = 128})
        local _, b = convert(4, 1, sourceB, {width_studs = 4, detail = detail, alpha_threshold = 128})
        equal(buffer.tostring(a.rgba), buffer.tostring(b.rgba))
    end
end)

test("Palette reduction is bounded deterministic and excludes transparent RGB", function()
    local function source(x, y) return x * 15, y * 25, (x * 17 + y * 21) % 256, x == 0 and 0 or 255 end
    local plan, preview = convert(16, 8, source, {resolution_mode = "source", palette_size = 4})
    local again, second = convert(16, 8, source, {resolution_mode = "source", palette_size = 4})
    assert(plan.color_count <= 4); equal(plan.placement_count, again.placement_count)
    equal(buffer.tostring(preview.rgba), buffer.tostring(second.rgba)); assertCover(plan, preview)
    local changed, changedPreview = convert(16, 8, function(x, y)
        if x == 0 then return 255, 0, 255, 0 end
        return source(x, y)
    end, {resolution_mode = "source", palette_size = 4})
    equal(changed.color_count, plan.color_count); equal(buffer.tostring(preview.rgba), buffer.tostring(changedPreview.rgba))
end)

test("Palette leaves exact colors alone when their count already fits", function()
    local plan, preview = convert(2, 1, function(x) return 1 + x, 3, 4, 255 end,
        {resolution_mode = "source", palette_size = 2})
    equal(plan.color_count, 2); equal(buffer.readu8(preview.rgba, 0), 1); equal(buffer.readu8(preview.rgba, 4), 2)
end)

test("Two-axis merging finds smaller T cover and preserves holes", function()
    local plan, preview = convert(4, 3, function(x, y)
        local on = x == 1 and y == 0 or y == 1 and x <= 2
        return 20, 40, 60, on and 255 or 0
    end, {resolution_mode = "source"})
    equal(plan.placement_count, 2); equal(plan.merge_savings_percent, 50)
    equal(plan.rectangles[1].x, 1); equal(plan.rectangles[1].y, 0); equal(plan.rectangles[1].h, 1)
    equal(plan.rectangles[2].x, 0); equal(plan.rectangles[2].y, 1); equal(plan.rectangles[2].w, 3)
    assertCover(plan, preview)
end)

test("Rectangle merging respects32-stud axis cap", function()
    local plan, preview = convert(40, 2, solid, {resolution_mode = "source", width_studs = 100})
    equal(plan.pixel_studs, 2.5); assert(plan.placement_count >= 4); assertCover(plan, preview)
    rejects(function() convert(1, 1, solid, {resolution_mode = "source", width_studs = 40}) end, "32-stud")
end)

test("Mixed grids reconstruct without overlap for all filters and detail settings", function()
    for _, sampling in ipairs({"nearest", "area", "lanczos"}) do
        for _, detail in ipairs({"none", "light", "strong"}) do
            for _, palette in ipairs({0, 4}) do
                local plan, preview = convert(13, 8, function(x, y)
                    return (x * 37 + y * 11) % 256, (x * 3 + y * 53) % 256, (x * 71 + y * 5) % 256,
                        (x + y) % 5 == 0 and 0 or 255
                end, {width_studs = 9, pixel_studs = 0.5, sampling = sampling, detail = detail,
                    palette_size = palette, include_cells = true})
                assertCover(plan, preview)
                if palette > 0 then assert(plan.color_count <= palette) end
            end
        end
    end
end)

test("Cancellation yields during large work and never mutates decoder input", function()
    local raw = image(300, 200, solid)
    local before, yields = buffer.tostring(raw), 0
    rejects(function() Planner.convertRGBA(300, 200, raw,
        settings({resolution_mode = "source", max_blocks = 250000}),
        {yield = function() yields += 1 end, checkCancelled = function() return yields >= 3 end}) end, "cancelled")
    equal(buffer.tostring(raw), before); assert(yields >= 3)
end)

test("RGBA shape bounds and malformed options reject before processing", function()
    rejects(function() Planner.convertRGBA(2, 2, buffer.create(4), settings()) end, "byte length")
    rejects(function() Planner.convertRGBA(1, 1, {}, settings()) end, "packed byte")
    rejects(function() Planner.convertRGBA(20000000, 2, "", settings()) end, "input limit")
    for _, change in ipairs({{max_blocks = 250001}, {max_blocks = false}, {palette_size = 1}, {palette_size = false},
        {alpha_threshold = 256}, {sampling = "bilinear"}, {sampling = false}, {detail = "extreme"},
        {width_studs = 0}, {width_studs = math.huge}, {pixel_studs = 0 / 0}, {resolution_mode = false},
        {resolution_mode = "columns", columns = 1.5}, {block_type = "bad\nname"}, {preview_max_size = 513}}) do
        local ok = pcall(function() convert(1, 1, solid, change) end)
        assert(not ok, "Malformed option unexpectedly accepted")
    end
end)

test("Unrepresentable tall Auto grid and overflow spacing fail cleanly", function()
    rejects(function() convert(1, 20, solid, {max_blocks = 10, resolution_mode = "auto"}) end, "too tall")
    rejects(function() convert(1, 1, solid, {pixel_studs = 1e-320, width_studs = 50}) end, "exceeds")
end)

test("Plan is JSON-safe and preview is separate and bounded", function()
    local plan, preview = convert(200, 100, solid, {resolution_mode = "source", max_blocks = 250000, preview_max_size = 64})
    local function visit(value)
        assert(typeof(value) ~= "buffer", "Plan must not contain raw buffers")
        if type(value) == "table" then for _, child in pairs(value) do visit(child) end
        else assert(type(value) ~= "function" and type(value) ~= "userdata") end
    end
    visit(plan); equal(preview.width, 64); equal(preview.height, 32)
    equal(plan.columns, 200); equal(plan.rows, 100); equal(typeof(preview.rgba), "buffer")
end)

test("Progress phases finish at1 and execute cooperative hooks", function()
    local phases, yields = {}, 0
    convert(8, 8, solid, {}, {yield = function() yields += 1 end,
        onProgress = function(name, fraction) table.insert(phases, {name, fraction}) end})
    assert(yields >= 5); equal(phases[#phases][1], "Image ready"); equal(phases[#phases][2], 1)
    for index = 2, #phases do assert(phases[index][2] >= phases[index - 1][2]) end
end)

test("Pathological work and elapsed processing time stop with explicit bounded errors", function()
    local limit = Planner.MAX_WORK
    Planner.MAX_WORK = 100
    local ok, message = pcall(function() convert(64, 64, solid, {resolution_mode = "source"}) end)
    Planner.MAX_WORK = limit
    assert(not ok and string.find(tostring(message), "work budget", 1, true))
    fakeClock = 1
    ok, message = pcall(function()
        convert(4, 4, solid, {}, {yield = function() fakeClock += 61 end})
    end)
    fakeClock = nil
    assert(not ok and string.find(tostring(message), "60 seconds", 1, true))
end)

print("LOCAL_IMAGE_PLANNER_TESTS_PASSED " .. tostring(tests))
