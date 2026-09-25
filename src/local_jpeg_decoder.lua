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
