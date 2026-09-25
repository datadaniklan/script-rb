-- Local image decoding. The release builder substitutes the two reviewed modules.
-- No network, file access, Roblox image permissions, or external processes here.
local PNG = __PNG_DECODER__
local JPEG = __JPEG_DECODER__

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
