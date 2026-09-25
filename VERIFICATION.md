# Release verification

Version 3.0.0, prepared 2026-09-25.

The release is built from the public source tree. It includes all PNG and JPEG license notices inside the downloaded bundle as well as in the repository. A publish allowlist and local scan exclude private pairing tokens, personal Windows paths, generated private loaders, local server configuration, recorder data, and recovered third-party scripts.

Automated checks run with the official Luau CLI and Python/Pillow:

- Complete bundled client, adapter, planner, decoder and loader syntax/compilation.
- 118 simulated adapter scenarios covering verified placement, size/color checks, cancellation, tool selection, adaptive speed, limited material preparation, and late replies. These use local doubles and send no live game requests.
- 30 interface logic scenarios covering options, placement rotation/origin, cancellation, progress, reload behavior, and normal hotbar selection.
- 34 PNG/wrapper cases, including color types, filters, interlacing, checksums, malformed files, memory bounds, cancellation, and independently verified preview PNG output.
- 14 JPEG test methods using synthetic Pillow fixtures: baseline/progressive, grayscale/RGB, subsampling, odd dimensions, restart markers, EXIF orientations 1–8, malformed data, scan/table limits, cancellation and cooperative yielding. Lossy output is checked with appropriate tolerance; it is not claimed identical to libjpeg's chroma smoothing.
- 26 planner scenarios, including exact Source RGB, 250,000-cell plans, alpha-aware filters, palettes, non-overlapping rectangle reconstruction, transparency, preview bounds, cancellation and work limits.
- Loader success/failure checks for manifest/path validation, HTTP failures, compile errors, cache write/readback failure, runtime startup failure, and concurrent launch suppression.
- Backend checks for download errors/limits, cancellation, credential-bearing URL rejection, local diagnostics, and nonfatal preview failure.
- 11 preview-cache cases covering journal/path validation, three-file bounds, stale jobs, missing files, deletion failures, readback mismatches, and partial writes.
- Two complete real-code conversion fixtures: RGBA PNG and an EXIF-rotated progressive JPEG, from mocked HTTP response to plan and encoded preview.

The bundled standalone release has not yet been verified inside a live Wave/Roblox session. CLI tests do not prove an executor's API compatibility, native image display, current game protocol, inventory outcomes, or a guaranteed build rate. The builder retains live verification and stops if the game does not confirm its changes.

The private PC-server test version remains separate from this public package.
