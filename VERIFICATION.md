# Release verification

Version 3.1.2, prepared 2026-11-01.

The user reports that 3.1.1 is placing the image, with a displayed 22.7 blocks/s at 308 seconds. That live reading included material preparation time; no completed report from that run was available when this correction was prepared. It does not establish a wall-only throughput rate or a verified material gain.

The 3.1.2 change allows four disjoint paint batches to share the existing admission controller instead of awaiting every paint request serially. Placement identification, the first-block proof, the complete paint-before-resize barrier, final verification, and material preparation are retained. Overall limits are unchanged. Periodic progress now separates wall time from preparation, and a bounded local live-progress file makes the current phase and timings inspectable without waiting for completion. The version shown in the interface is corrected to match the release.

Identical local mock runs compared 3.1.1 with two- and four-batch candidates at 30/60 simulated FPS and 100/350 ms RPC delay. For example, at 60 FPS and 350 ms delay a verified 1,201-block run took 52.20 seconds with serial paint, 45.00 seconds with two paint batches and 42.63 seconds with four. Requests and verified counts were unchanged. These are simulated scheduling measurements, not a promise of game throughput. The user's ongoing build is not modified by this release.

The reported live 3.1.0 attempt never reached image placement: it needed 141,015 material, began and ended with 14,479, and completed 187 preparation scale calls before cancellation. Its first estimated round had 1,279 calls, but the UI showed no progress within that round. This establishes zero net gain for that attempt, not failure of the original Luau.pro method; the user reports that the original still works.

The 3.1.1 correction restores simultaneous dispatch within each preparation group, adds progress while requests are pending, measures net gain before extending the first group, and separates helper refunds from material gains. The original can overlap groups without joining every callback; this adapter deliberately tracks and drains each group, with at most 100 preparation requests pending. Wall dispatch now adapts to response latency. Local timing simulations can verify these scheduling and lifecycle properties; they do not establish the current game's material response.

The 3.1.0 image-builder update adds a Luau.pro profile to the independent game adapter. It ports shared-helper material top-ups and staged placement, paint and resize from the recovered source descriptions. The original Luau.pro VM, factory and unresolved authorizer/reconciler are not executed or included. The prior Rapid, Turbo, Fast and Normal paths remain available. The AI builder is outside this release.

The new profile retains ownership matching, real inventory checks, bounded request concurrency, cancellation, cleanup, tool restoration and final geometry/color verification. Local simulations cover the port; they are not a live server throughput or inventory measurement.

The 3.0.1 compatibility update uses executor-relative paths throughout, tests HTTP aliases by function capability, accepts numeric HTTP status variants, and verifies workspace write/read access even when `isfolder` is missing. Tests simulate different workspace roots; they do not certify a particular executor or mobile platform. A small `workspace-check.txt` file is removed after a successful probe when `delfile` is available.

The release is built from the public source tree. It includes all PNG and JPEG license notices inside the downloaded bundle as well as in the repository. A publish allowlist and local scan exclude private pairing tokens, personal Windows paths, generated private loaders, local server configuration, recorder data, and recovered third-party scripts.

Automated checks run with the official Luau CLI and Python/Pillow:

- Complete bundled client, adapter, planner, decoder and loader syntax/compilation.
- 162 simulated adapter scenarios: the 156 earlier cases plus six focused regressions for disjoint concurrent paint batches, rejection, late replies and retained locks, manual tool switching, periodic wall-only progress, and cancellation during paint. Earlier coverage includes preparation timing, no-surplus inventory, separate cleanup accounting and adaptive wall admission. Phase order, ownership, final geometry/color checks and cancellation remain covered. These use local doubles and send no live game requests.
- 34 interface logic scenarios covering options, placement rotation/origin, cancellation, progress, reload behavior, normal hotbar selection, the new default, live material counters, wall-only elapsed time and bounded local diagnostics. Terminal snapshots distinguish complete, stopped and unverified outcomes.
- 34 PNG/wrapper cases, including color types, filters, interlacing, checksums, malformed files, memory bounds, cancellation, and independently verified preview PNG output.
- 14 JPEG test methods using synthetic Pillow fixtures: baseline/progressive, grayscale/RGB, subsampling, odd dimensions, restart markers, EXIF orientations 1–8, malformed data, scan/table limits, cancellation and cooperative yielding. Lossy output is checked with appropriate tolerance; it is not claimed identical to libjpeg's chroma smoothing.
- 26 planner scenarios, including exact Source RGB, 250,000-cell plans, alpha-aware filters, palettes, non-overlapping rectangle reconstruction, transparency, preview bounds, cancellation and work limits.
- Loader success/failure checks for manifest/path validation, HTTP failures, compile errors, cache write/readback failure, runtime startup failure, and concurrent launch suppression.
- Backend checks for download errors/limits, cancellation, credential-bearing URL rejection, local diagnostics, and nonfatal preview failure. Live progress is throttled, drops unknown/nonfinite fields, marks run completion, and does not overwrite the previous completed-run report.
- 11 preview-cache cases covering journal/path validation, three-file bounds, stale jobs, missing files, deletion failures, readback mismatches, and partial writes.
- Two complete real-code conversion fixtures: RGBA PNG and an EXIF-rotated progressive JPEG, from mocked HTTP response to plan and encoded preview.

The bundled standalone release has not yet been verified inside a live Wave/Roblox session. CLI tests do not prove an executor's API compatibility, native image display, current game protocol, inventory outcomes, or a guaranteed build rate. The builder retains live verification and stops if the game does not confirm its changes.

The private PC-server test version remains separate from this public package.
