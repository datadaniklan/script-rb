"""Run the actual local PNG decoder and wrapper in the official Luau CLI."""
from __future__ import annotations

import binascii
import io
from pathlib import Path
import os
import random
import shutil
import struct
import subprocess
import unittest
import uuid
import zlib

from PIL import Image

DIRECTORY = Path(__file__).resolve().parents[1] / "src"
LUAU = Path(os.environ.get("LUAU", DIRECTORY.parents[1] / ".tools/luau/luau.exe"))
COMPILER = Path(os.environ.get("LUAU_COMPILE", LUAU.with_name("luau-compile.exe")))
SIGNATURE = b"\x89PNG\r\n\x1a\n"


def literal(data: bytes) -> str:
    return '"' + "".join(f"\\{value:03d}" for value in data) + '"'


def chunk(name: bytes, body: bytes) -> bytes:
    return struct.pack(">I", len(body)) + name + body + struct.pack(">I", binascii.crc32(name + body))


def png(width, height, depth, color, raw, *, extras=b"", interlace=0, level=6, strategy=0):
    compressor = zlib.compressobj(level=level, strategy=strategy)
    compressed = compressor.compress(raw) + compressor.flush()
    return (SIGNATURE + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, depth, color, 0, 0, interlace))
            + extras + chunk(b"IDAT", compressed) + chunk(b"IEND", b""))


def rgba_fixture(width, height, *, interlace=False, filter_kind=0, level=6, strategy=0):
    pixels = bytes(value for y in range(height) for x in range(width)
                   for value in ((x * 31 + y * 7) % 256, (x * 11 + y * 61) % 256,
                                 (x * 47 + y * 3) % 256, (x * 19 + y * 29) % 256))
    passes = [(0, 0, 1, 1)] if not interlace else [
        (0, 0, 8, 8), (4, 0, 8, 8), (0, 4, 4, 8), (2, 0, 4, 4),
        (0, 2, 2, 4), (1, 0, 2, 2), (0, 1, 1, 2)]
    raw = bytearray()
    for sx, sy, dx, dy in passes:
        previous = b""
        for y in range(sy, height, dy):
            row = b"".join(pixels[(y * width + x) * 4:(y * width + x + 1) * 4]
                           for x in range(sx, width, dx))
            if not row:
                continue
            raw.append(filter_kind)
            for i, value in enumerate(row):
                left = row[i - 4] if i >= 4 else 0
                up = previous[i] if previous else 0
                upper_left = previous[i - 4] if previous and i >= 4 else 0
                p = left + up - upper_left
                distances = [abs(p - left), abs(p - up), abs(p - upper_left)]
                paeth = [left, up, upper_left][distances.index(min(distances))]
                predictor = [0, left, up, (left + up) // 2, paeth][filter_kind]
                raw.append((value - predictor) & 255)
            previous = row
    return png(width, height, 8, 6, raw, interlace=int(interlace), level=level, strategy=strategy), pixels


class LocalImageDecoderTests(unittest.TestCase):
    def test_decode_validation_cancellation_and_preview(self):
        if not LUAU.is_file():
            self.skipTest("Official Luau CLI is not installed")
        vendor = (DIRECTORY / "vendor/png.luau").read_text(encoding="utf-8")
        wrapper = (DIRECTORY / "local_image_decoder.lua").read_text(encoding="utf-8")
        source = wrapper.replace("__PNG_DECODER__", "(function()\n" + vendor + "\nend)()")
        source = source.replace("__JPEG_DECODER__", "jpegStub")
        tests = ["""
local passed = 0
local jpegCalls = 0
local jpegStub = {decode = function(data, hooks)
    jpegCalls += 1
    assert(typeof(data) == 'buffer')
    hooks.checkpoint()
    return 1, 2, buffer.fromstring(string.rep(string.char(1,2,3,255), 2))
end}
local decoder = (function()
""" + source + "\nend)()", """
local function test(name, fn)
    local ok, message = pcall(fn)
    assert(ok, name .. ': ' .. tostring(message))
    passed += 1
end
local function rejects(bytes, pattern)
    local ok, message = pcall(decoder.decode, bytes)
    assert(not ok, 'expected rejection')
    assert(string.find(tostring(message), pattern, 1, true), tostring(message))
end
"""]
        case_count = 0

        def case(name, code):
            nonlocal case_count
            case_count += 1
            tests.append(f"test({name!r}, function()\n{code}\nend)")

        def exact(name, data, expected, width, height, input_buffer=False):
            payload = literal(data)
            if input_buffer:
                payload = "buffer.fromstring(" + payload + ")"
            case(name, f"local w,h,p = decoder.decode({payload})\n"
                       f"assert(w == {width} and h == {height})\n"
                       f"assert(buffer.tostring(p) == {literal(expected)}, 'pixel mismatch')")

        for filter_kind in range(5):
            data, expected = rgba_fixture(9, 7, filter_kind=filter_kind)
            exact(f"RGBA filter {filter_kind}", data, expected, 9, 7, input_buffer=filter_kind == 0)
        for name, args in [("Adam7", {"interlace": True, "filter_kind": 4}),
                           ("stored DEFLATE", {"level": 0}),
                           ("fixed DEFLATE", {"strategy": zlib.Z_FIXED})]:
            data, expected = rgba_fixture(17, 13, **args)
            exact(name, data, expected, 17, 13)
        source_image = Image.new("RGBA", (19, 13))
        rng = random.Random(27)
        source_image.putdata([tuple(rng.randrange(256) for _ in range(4)) for _ in range(19 * 13)])
        for mode in ("RGB", "L", "LA", "1", "P"):
            image = source_image.convert(mode)
            if mode == "P":
                image.info["transparency"] = bytes(range(256))
            output = io.BytesIO()
            image.save(output, format="PNG")
            exact(mode, output.getvalue(), image.convert("RGBA").tobytes(), 19, 13)
        exact("16-bit grayscale", png(3, 1, 16, 0, b"\0\x12\x34\xab\xcd\xff\xff"),
              bytes((0x12, 0x12, 0x12, 255, 0xAB, 0xAB, 0xAB, 255, 255, 255, 255, 255)), 3, 1)
        exact("RGB tRNS", png(2, 1, 8, 2, b"\0\x01\x02\x03\x04\x05\x06",
                              extras=chunk(b"tRNS", struct.pack(">HHH", 1, 2, 3))),
              bytes((1, 2, 3, 0, 4, 5, 6, 255)), 2, 1)
        # Valid DEFLATE: one code-length repeat spans the literal/distance table
        # boundary. Verify the fixture independently, then exercise the Luau path.
        crossing = bytes.fromhex("789cedc081000000000010ffd54e4000050001")
        self.assertEqual(zlib.decompress(crossing), b"\0" * 5)
        crossing_png = (SIGNATURE + chunk(b"IHDR", struct.pack(">IIBBBBB", 1, 1, 8, 6, 0, 0, 0))
                        + chunk(b"IDAT", crossing) + chunk(b"IEND", b""))
        exact("dynamic code-length repeat spans table boundary", crossing_png, b"\0" * 4, 1, 1)
        valid, expected = rgba_fixture(128, 96)
        case("cooperative checkpoints", f"local calls=0\nlocal w,h,p=decoder.decode({literal(valid)}, "
             "{checkpoint=function() calls+=1 end})\nassert(calls>100 and w==128 and h==96)")
        case("cancellation propagates", f"local calls=0\nlocal ok,err=pcall(decoder.decode,{literal(valid)}, "
             "{checkpoint=function() calls+=1; if calls==25 then error('CANCEL_FROM_TEST') end end})\n"
             "assert(not ok and tostring(err):find('CANCEL_FROM_TEST',1,true) and calls==25)")
        small, small_pixels = rgba_fixture(3, 2)
        case("nested decodes have independent hooks", "local nested=false\n"
             f"local w,h,p=decoder.decode({literal(valid)}, {{checkpoint=function()\n"
             f"if not nested then nested=true; local a,b,c=decoder.decode({literal(small)}); "
             f"assert(a==3 and b==2 and buffer.tostring(c)=={literal(small_pixels)}) end end}})\n"
             "assert(nested and w==128 and h==96)")
        case("unknown format", "rejects('GIF89a example', 'unsupported image format')")
        case("oversized input", "rejects(string.rep('x', 10*1024*1024+1), '10 MiB')")
        case("invalid input type", "rejects({}, 'expected image bytes')")
        case("truncated data", "rejects('x', 'truncated')")
        damaged = bytearray(small)
        damaged[-1] ^= 1
        case("CRC remains enforced", f"rejects({literal(damaged)}, 'incorrect checksum')")
        bomb = png(5000, 1, 8, 6, b"\0")
        case("axis bound precedes allocations", f"rejects({literal(bomb)}, '4096 per side')")
        bomb = png(4096, 4096, 8, 6, b"\0")
        case("pixel bound precedes allocations", f"rejects({literal(bomb)}, '4,194,304 pixels')")
        bomb = png(1, 1, 8, 6, b"\0" * 50000)
        case("inflate cannot overrun exact output allocation", f"local ok=pcall(decoder.decode,{literal(bomb)}); assert(not ok)")
        case("chunk count bound", f"rejects({literal(small[:33])} .. string.rep({literal(chunk(b'tEXt', b''))}, 4097) .. "
             f"{literal(small[33:])}, 'too many chunks')")
        fake_jpeg = b"\xff\xd8\xff\xc0" + struct.pack(">HBHHB", 11, 8, 1, 2, 1) + b"\x01\x11\0" + b"\xff\xd9"
        case("JPEG injection forwards hook and permits EXIF-swapped axes", f"local n=0\nlocal w,h,p=decoder.decode({literal(fake_jpeg)}, "
             "{checkpoint=function() n+=1 end})\nassert(w==1 and h==2 and buffer.len(p)==8 and jpegCalls==1 and n>=3)")
        bad_jpeg = fake_jpeg[:7] + struct.pack(">H", 5000) + fake_jpeg[9:]
        case("JPEG bounds before injected decoder", f"rejects({literal(bad_jpeg)}, '4096 per side'); assert(jpegCalls==1)")
        case("JPEG marker padding is cancellable", "local n=0\nlocal ok,err=pcall(decoder.decode,"
             "string.char(255,216)..string.rep(string.char(255),100000),"
             "{checkpoint=function() n+=1; if n==5 then error('STOP_MARKERS') end end}); "
             "assert(not ok and tostring(err):find('STOP_MARKERS',1,true) and n==5)")
        case("PNG preview roundtrip", f"local original={literal(small_pixels)}\n"
             "local encoded=decoder.encodePreview(3,2,buffer.fromstring(original))\n"
             "local w,h,p=decoder.decode(encoded)\nassert(w==3 and h==2 and buffer.tostring(p)==original)\n"
             "local hex={} for i=1,#encoded do hex[i]=string.format('%02x',string.byte(encoded,i)) end\n"
             "print('PREVIEW_HEX '..table.concat(hex))")
        case("preview size bound", "local ok,err=pcall(decoder.encodePreview,513,1,buffer.create(513*4)); "
             "assert(not ok and tostring(err):find('512 by 512',1,true))")
        case("preview cancellation", "local ok,err=pcall(decoder.encodePreview,1,1,buffer.create(4),"
             "{checkpoint=function() error('STOP_PREVIEW') end}); assert(not ok and tostring(err):find('STOP_PREVIEW',1,true))")
        tests.append("print('LOCAL_IMAGE_DECODER_CASES ' .. passed)")
        scratch = DIRECTORY / (".decoder-test-" + uuid.uuid4().hex)
        scratch.mkdir(mode=0o755)
        try:
            fixture = scratch / "decoder.lua"
            fixture.write_text("\n".join(tests), encoding="utf-8")
            if COMPILER.is_file():
                compiled = subprocess.run([str(COMPILER), "--null", str(fixture)], capture_output=True,
                                          text=True, timeout=30)
                self.assertEqual(compiled.returncode, 0, compiled.stdout + compiled.stderr)
            result = subprocess.run([str(LUAU), str(fixture)], capture_output=True, text=True, timeout=60)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn(f"LOCAL_IMAGE_DECODER_CASES {case_count}", result.stdout)
            encoded = bytes.fromhex(next(line.split(" ", 1)[1] for line in result.stdout.splitlines()
                                         if line.startswith("PREVIEW_HEX ")))
            self.assertEqual(Image.open(io.BytesIO(encoded)).convert("RGBA").tobytes(), small_pixels)
            print(f"LOCAL_IMAGE_DECODER_CASES {case_count}")
        finally:
            if scratch.resolve().parent != DIRECTORY.resolve() or not scratch.name.startswith(".decoder-test-"):
                raise RuntimeError("Refusing cleanup outside the decoder test directory")
            shutil.rmtree(scratch)


if __name__ == "__main__":
    unittest.main()
