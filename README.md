# BAFT Image Builder

A standalone image-to-block wall builder for Build A Boat For Treasure. Image downloading, PNG/JPEG decoding, resizing, sharpening, color reduction and block planning happen in the executor. No Python installation, key, account, image-processing cloud, or separately started PC server is required.

## Run

Paste this line into a compatible Roblox executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/datadaniklan/script-rb/main/loader.lua"))()
```

The loader automatically creates **`baft image builder`** inside the executor's workspace, downloads the current release, checks that it compiles, verifies the written cache, and opens the interface. In Wave, the usual location is `%LOCALAPPDATA%\Wave\Workspace\baft image builder`. Other executors choose their own workspace location.

1. Paste a **direct PNG or JPEG image URL**.
2. Choose wall width, resolution, material, and quality. Select **Convert image**.
3. Select **Place**, aim the green preview, and click. **R** rotates 90 degrees; **Q/E** rotate 15 degrees.
4. Hands free is selected initially. Select tools from the game's normal hotbar while building. Rapid adjusts its workload when game responses slow down.

Run the same link again to obtain the latest published version. A saved `baft image builder/start.lua` contains the same online launcher. The loader stops visibly on a failed update; it does not silently run an old version. Only one builder operation should run at a time.

## Image quality

- **Auto** fits the requested pixel size within the maximum pixel count.
- **Source** retains the decoded source dimensions; with palette 0 and no sharpening it preserves source RGB. Source mode reports an error if the original exceeds the chosen pixel limit.
- **Photo** uses Lanczos-3 resampling, **Pixel art** uses nearest-neighbor, and **Soft** uses area sampling.
- Detail can be None, Light, or Strong. Palette 0 retains full color; 2–256 reduces colors. Identical neighboring colors are merged into rectangles where possible.
- Width 50 and pixel size 0.125 requests 400 pixels across, subject to the selected resolution mode and maximum pixels. Enlarging a low-resolution source cannot restore missing detail.
- The standalone resampling and palette implementation is independent of the private Pillow-based test server; results are not promised to be bit-for-bit identical.

## Compatibility and limits

The executor needs HTTP `request`, `loadstring`, Luau `buffer` and `bit32`, and workspace `readfile`, `writefile`, `isfolder`, and `makefolder`. `getcustomasset` and `delfile` enable the detailed preview; without them, the interface uses a coarse preview. Files are never written outside `baft image builder` by the standalone package.

PNG and common 8-bit baseline/progressive RGB or grayscale JPEG are decoded locally. JPEG EXIF orientation is applied. WebP, AVIF, GIF, CMYK/YCCK, arithmetic/lossless JPEG and 12-bit JPEG are unsupported and produce an explanatory error. Image profiles are not color-managed. Use a direct image link, not a webpage or Google Images results page.

Source downloads are checked against a 10 MiB limit after the executor returns their bytes. Sources are limited to 4096 pixels per side and 4,194,304 pixels total, with additional decoder memory/work limits. Build plans are limited to 250,000 pixels. Conversion yields cooperatively and supports Stop; an executor HTTP request may continue finishing after cancellation.

The existing **Infinite Blocks** control attempts material preparation and verifies the resulting inventory. Its name is not a guarantee of unlimited material: if preparation fails or the game rejects an operation, the builder stops. Placement progress counts verified blocks. Game updates, server limits, inventory, and executor differences can affect building. This release does not claim a fixed build speed or compatibility with every executor.

## Local files and privacy

The folder contains two rotating script cache slots, `active.txt`, `start.lua`, one source-image cache, up to three preview PNGs tracked in `previews.json`, and `last-report.json`. The report contains build settings and diagnostics and stays on the user's computer. It is not uploaded. Image URLs are sent only through the image download request to their image host, subject to its redirects; code downloads come from this GitHub repository.

This public release is independent of the developer's private PC-server test setup. No pairing tokens, private bridge endpoints, recorder logs, recovered third-party game scripts, or personal machine paths are included.

## Source and verification

`src/client.lua` is the interface; `src/game_adapter.lua` is the build integration; `src/backend.lua` coordinates downloads and local conversion. `src/local_image_decoder.lua`, `src/local_jpeg_decoder.lua`, and `src/local_image_processing.lua` implement decoding/planning. `build.py` creates an immutable, named bundle and updates `manifest.json` using Python's standard library. Python is for release development only; users do not need it.

To rebuild: `python build.py`. Tests use the official Luau CLI (`LUAU` environment variable) and Python; image decoder fixture generation additionally uses Pillow. Run `python -m unittest discover -s tests -v`.

Third-party decoder attribution and licenses are in `src/vendor/`. See `VERIFICATION.md` for the release's checked behavior and remaining live-runtime checks.
