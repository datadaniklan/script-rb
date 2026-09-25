# PNG decoder provenance

`png.luau` is the single-file release of **sircfenner/png-luau v0.2.1**:

- Repository: https://github.com/sircfenner/png-luau
- Exact commit/tag target: `d9f8f3b2694dc2308b48f57cdb807efa54b27f13`
- Original artifact: https://github.com/sircfenner/png-luau/releases/download/v0.2.1/png.luau
- Original artifact SHA-256: `3cfd458530c0b4d420ae7899410f741e65484dccf607fdedff9821e5416cb094`
- License: MIT. The complete upstream notice is preserved in `png-luau.LICENSE`.

Local modifications pass an optional per-call checkpoint through PNG parsing,
CRC validation, DEFLATE, Adler-32 validation, and pixel reconstruction. These
checkpoints allow cancellation and cooperative scheduling without global state.
Invalid Huffman traversal is limited to the DEFLATE maximum of 15 bits.
The dynamic code-length reader is corrected to allow a repeat to cross the
literal/distance alphabet boundary, as required by DEFLATE. It also rejects
overlong repeats, repeats without a previous value, and a missing end-of-block
code. A hand-built stream independently accepted by Python zlib covers the
cross-boundary regression.

The public wrapper checks input bytes, dimensions, decoded pixel count,
conservative working memory, and chunk count before this decoder allocates image
buffers. Original CRC checking remains enabled. The decoder returns 8-bit RGBA;
16-bit channels are downsampled. Ancillary metadata other than transparency is
ignored; this is not an ICC color-management or EXIF-orientation implementation.
Animated PNGs are decoded as their default image, not as animation.

The application preview encoder is independent code which emits PNG with stored
DEFLATE blocks. It does not call the upstream compression implementation.
