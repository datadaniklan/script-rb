# Local decoder integration

Build `local_image_decoder.lua` by substituting `__PNG_DECODER__` with the bundled
`png.luau` module result, and `__JPEG_DECODER__` with the reviewed JPEG module
result. Both modules are bundled into the release; image decoding never downloads
or executes additional source.

```lua
local width, height, rgba = Decoder.decode(imageBytes, {
    checkpoint = function()
        -- Throw to cancel. This callback may yield.
    end,
    isCancelled = function() return false end, -- optional
})
local previewPNG = Decoder.encodePreview(previewWidth, previewHeight, previewRGBA, hooks)
```

`imageBytes` is a binary string or Luau buffer. `rgba` is a buffer of exactly
`width * height * 4` bytes in top-to-bottom, left-to-right, straight-alpha RGBA8
order. PNG preserves hidden RGB values under transparent pixels. JPEG can swap
width and height when applying EXIF orientation. Unsupported formats are errors,
not implicit network conversions.

`encodePreview` returns a PNG **binary string**, ready for a local workspace
file. Supply already-resized preview pixels; it does not resize or alter colors.
Preview encoding is limited to 512 pixels per side and 262,144 pixels total.

The decoder wrapper caps compressed bytes at 10 MiB, image dimensions at 4096 per
side, and decoded pixels at 4,194,304. PNG conservatively estimates working
memory before allocating image buffers and limits chunks to 4096. Each operation
has a 60-second budget, invokes per-call checkpoints, and yields to `task.wait`
after approximately 8 ms of processing when that Roblox scheduler is available.
Exceptions from cancellation callbacks propagate unchanged. No process-wide
callback state is used, so nested/concurrent jobs do not overwrite hooks.

The JPEG provider contract is `JPEG.decode(buffer, {checkpoint = function})`
returning the same three values. Its own allocation, scan-work, and malformed
input limits remain necessary because JPEG frame/scan structure is richer than
the wrapper's initial size preflight.
