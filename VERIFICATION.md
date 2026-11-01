# Release verification

Version 3.1.0, prepared 2026-11-01.

The 3.1.0 image-builder update adds a Luau.pro profile to the independent game adapter. It ports shared-helper material top-ups and staged placement, paint and resize from the recovered source descriptions. The original Luau.pro VM, factory and unresolved authorizer/reconciler are not executed or included. The prior Rapid, Turbo, Fast and Normal paths remain available. The AI builder is outside this release.

The new profile retains ownership matching, real inventory checks, bounded request concurrency, cancellation, cleanup, tool restoration and final geometry/color verification. Local simulations cover the port; they are not a live server throughput or inventory measurement.

The 3.0.1 compatibility update uses executor-relative paths throughout, tests HTTP aliases by function capability, accepts numeric HTTP status variants, and verifies workspace write/read access even when `isfolder` is missing. Tests simulate different workspace roots; they do not certify a particular executor or mobile platform. A small `workspace-check.txt` file is removed after a successful probe when `delfile` is available.

The release is built from the public source tree. It includes all PNG and JPEG license notices inside the downloaded bundle as well as in the repository. A publish allowlist and local scan exclude private pairing tokens, personal Windows paths, generated private loaders, local server configuration, recorder data, and recovered third-party scripts.

Automated checks run with the official Luau CLI and Python/Pillow:

- Complete bundled client, adapter, planner, decoder and loader syntax/compilation.
- 148 simulated adapter scenarios: all 118 prior cases plus 30 for the Luau.pro port. They cover phase order across multiple image windows, placement/resize cohort bounds, one shared preparation helper, round and request limits, inventory before and after cleanup, cancellation, ownership changes, missing/rejected/late replies, manual tool selection and final size/color checks. These use local doubles and send no live game requests.
- 31 interface logic scenarios covering options, placement rotation/origin, cancellation, progress, reload behavior, normal hotbar selection, the new default and local diagnostics.
- 34 PNG/wrapper cases, including color types, filters, interlacing, checksums, malformed files, memory bounds, cancellation, and independently verified preview PNG output.
- 14 JPEG test methods using synthetic Pillow fixtures: baseline/progressive, grayscale/RGB, subsampling, odd dimensions, restart markers, EXIF orientations 1–8, malformed data, scan/table limits, cancellation and cooperative yielding. Lossy output is checked with appropriate tolerance; it is not claimed identical to libjpeg's chroma smoothing.
- 26 planner scenarios, including exact Source RGB, 250,000-cell plans, alpha-aware filters, palettes, non-overlapping rectangle reconstruction, transparency, preview bounds, cancellation and work limits.
- Loader success/failure checks for manifest/path validation, HTTP failures, compile errors, cache write/readback failure, runtime startup failure, and concurrent launch suppression.
- Backend checks for download errors/limits, cancellation, credential-bearing URL rejection, local diagnostics, and nonfatal preview failure.
- 11 preview-cache cases covering journal/path validation, three-file bounds, stale jobs, missing files, deletion failures, readback mismatches, and partial writes.
- Two complete real-code conversion fixtures: RGBA PNG and an EXIF-rotated progressive JPEG, from mocked HTTP response to plan and encoded preview.

The bundled standalone release has not yet been verified inside a live Wave/Roblox session. CLI tests do not prove an executor's API compatibility, native image display, current game protocol, inventory outcomes, or a guaranteed build rate. The builder retains live verification and stops if the game does not confirm its changes.

The private PC-server test version remains separate from this public package.
