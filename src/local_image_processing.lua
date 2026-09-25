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
