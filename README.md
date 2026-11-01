# BAFT Image Builder

A standalone image-to-block wall builder for Build A Boat For Treasure. Image downloading, PNG/JPEG decoding, resizing, sharpening, color reduction and block planning happen in the executor. No Python installation, key, account, image-processing cloud, or separately started PC server is required.

## Run

Paste this line into a compatible Roblox executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/datadaniklan/script-rb/main/loader.lua"))()
```

The loader automatically creates **`baft image builder`** inside the **current executor's own workspace**, downloads the current release, checks that it compiles, verifies the written cache, and opens the interface. The executor determines the real workspace location; the script does not contain a Wave directory or Windows username.

All filesystem paths are relative, such as `baft image builder/builder_a.lua`. Startup checks that the folder can actually be written and read. If `isfolder` is unavailable, or `makefolder` reports that the folder already exists, the write/read check still determines whether startup can continue. An already-created writable folder also works without `makefolder`.

1. Paste a **direct PNG or JPEG image URL**.
2. Choose wall width, resolution, material, and quality. Select **Convert image**.
3. Select **Place**, aim the green preview, and click. **R** rotates 90 degrees; **Q/E** rotate 15 degrees.
4. **Hands free**, **Luau.pro** speed and **Infinite Blocks** are selected initially. Select tools from the game's normal hotbar while building; use **Stop** to cancel. Choose Rapid for the existing adaptive pipeline, or a lower speed if needed.

Run the same link again to obtain the latest published version. A saved `baft image builder/start.lua` contains the same online launcher. The loader stops visibly on a failed update; it does not silently run an old version. Only one builder operation should run at a time.

## Luau.pro method in version 3.1.1

The image-builder adapter now has a **Luau.pro** profile. It ports the recovered material-preparation lifecycle and staged image placement into this builder. It is an independent implementation of those methods; the original Luau.pro engine and its unresolved helper bindings are not bundled or invoked.

- **Material preparation:** when stock is short and Infinite Blocks is enabled, reuse one newly identified helper for up to four top-up rounds, then remove it. Launch each scaling group together, matching the recovered method's within-group timing. Measure the first group before scheduling the remaining work. Check actual inventory both before and after cleanup; image building starts only with sufficient verified material. At least one available block is needed to begin preparation.
- **Image placement:** place in cohorts of up to 50, identify the new owned models, paint them in batches, then resize in windows of up to 150. Larger images use bounded work windows. Position, size, orientation and color must pass the existing final checks before a block counts as completed.
- **Hands-free operation:** keep the normal game hotbar and manual tool selection, cancellation, tool restoration and protection against starting another build while earlier requests are still unresolved.

The Luau.pro wall profile now adapts to response latency: it starts at 120 requests per second and 16 workers, with ceilings of 600 requests per second and 64 pending requests. Preparation is separate: groups of up to 100 scaling calls are launched together, fully drained before the next group, and paced between groups at an average ceiling of 120 calls per second. These are request limits, not a promised completed-block rate. Rapid remains available. Selecting Compatible tool mode changes either background-only profile to Fast.

During preparation, the display shows actual available material, completed checks and pending calls. Returning the helper's original block is not counted as new material. If the first group produces no net gain after cleanup and a replication wait, the builder stops with an explanation rather than sending the rest of a large estimated round. The local report records inventory before/after cleanup and observed helper geometry for diagnosis.

This update applies only to the image builder. It does not modify the separate AI builder.

## Image quality

- **Auto** fits the requested pixel size within the maximum pixel count.
- **Source** retains the decoded source dimensions; with palette 0 and no sharpening it preserves source RGB. Source mode reports an error if the original exceeds the chosen pixel limit.
- **Photo** uses Lanczos-3 resampling, **Pixel art** uses nearest-neighbor, and **Soft** uses area sampling.
- Detail can be None, Light, or Strong. Palette 0 retains full color; 2–256 reduces colors. Identical neighboring colors are merged into rectangles where possible.
- Width 50 and pixel size 0.125 requests 400 pixels across, subject to the selected resolution mode and maximum pixels. Enlarging a low-resolution source cannot restore missing detail.
- The standalone resampling and palette implementation is independent of the private Pillow-based test server; results are not promised to be bit-for-bit identical.

## Compatibility and limits

The executor needs a callable HTTP function named `request`, `http_request`, `syn.request`, or `http.request`; `loadstring`; Luau `buffer` and `bit32`; and workspace `readfile` and `writefile`. `makefolder` is needed to create the folder on first use; `isfolder` is optional. Non-function aliases are skipped. `getcustomasset` or `getsynasset`, together with `delfile`, enables the detailed preview; otherwise the interface uses a coarse preview. The one-line online launcher also uses `game:HttpGet`. Files are never written outside `baft image builder` by the standalone package.

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
