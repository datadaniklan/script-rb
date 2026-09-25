"""Synthetic Pillow fixtures for the bounded pure-Luau JPEG decoder; no network."""
from __future__ import annotations

import io
from pathlib import Path
import os
import struct
import subprocess
import tempfile
import unittest

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1] / "src"
LUAU = Path(os.environ.get("LUAU", ROOT.parents[1] / ".tools/luau/luau.exe"))
COMPILER = LUAU.with_name("luau-compile.exe")
SOURCE = ROOT / "local_jpeg_decoder.lua"


def literal(data: bytes) -> str:
    return '"' + ''.join(f"\\{v:03d}" for v in data) + '"'


def fixture(mode="RGB", size=(37, 29), progressive=False, subsampling=0, **kwargs):
    image = Image.new(mode, size)
    if mode == "L":
        image.putdata([(x * 3 + y * 5) % 256 for y in range(size[1]) for x in range(size[0])])
    elif mode == "CMYK":
        image.paste((30, 80, 150, 20), (0, 0, *size))
    else:
        image.putdata([(round(x * 210 / max(1, size[0] - 1)), round(y * 210 / max(1, size[1] - 1)),
                        round((x + y) * 210 / max(1, size[0] + size[1] - 2)))
                       for y in range(size[1]) for x in range(size[0])])
    out = io.BytesIO()
    image.save(out, "JPEG", quality=88, progressive=progressive, subsampling=subsampling, **kwargs)
    encoded = out.getvalue()
    decoded = ImageOps.exif_transpose(Image.open(io.BytesIO(encoded))).convert("RGBA")
    return encoded, decoded


class LocalJpegDecoderTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if not LUAU.is_file():
            raise unittest.SkipTest("Luau CLI unavailable")
        cls.source = SOURCE.read_text(encoding="utf-8")

    def run_luau(self, code):
        text = "local JPEG=(function()\n" + self.source + "\nend)()\n" + code
        path = None
        try:
            with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".lua", prefix="jpeg-test-", delete=False) as f:
                path = Path(f.name)
                f.write(text)
            result = subprocess.run([str(LUAU), str(path)], capture_output=True, text=True, timeout=30)
        finally:
            if path is not None:
                if not path.name.startswith("jpeg-test-") or path.parent.resolve() != Path(tempfile.gettempdir()).resolve():
                    raise RuntimeError("Unsafe temporary cleanup")
                path.unlink(missing_ok=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result.stdout

    def decode(self, encoded, *, as_buffer=True):
        expression = literal(encoded)
        if as_buffer:
            expression = f"buffer.fromstring({expression})"
        result = self.run_luau(f"""
local checks=0
local w,h,p=JPEG.decode({expression},{{checkpoint=function() checks+=1 end}})
local out=table.create(buffer.len(p))
for i=0,buffer.len(p)-1 do out[i+1]=string.format('%02x',buffer.readu8(p,i)) end
print(w,h,checks)
print(table.concat(out))
""")
        lines = result.strip().splitlines()
        w, h, checks = map(int, lines[0].split())
        self.assertGreater(checks, 0)
        pixels = bytes.fromhex(lines[1])
        self.assertEqual(len(pixels), w * h * 4)
        self.assertTrue(all(pixels[i] == 255 for i in range(3, len(pixels), 4)))
        return Image.frombytes("RGBA", (w, h), pixels)

    def compare(self, encoded, expected, *, mean=1.0, maximum=4, as_buffer=True):
        got = self.decode(encoded, as_buffer=as_buffer)
        self.assertEqual(got.size, expected.size)
        differences = [abs(a - b) for a, b in zip(got.convert("RGB").tobytes(), expected.convert("RGB").tobytes())]
        self.assertLessEqual(sum(differences) / len(differences), mean)
        self.assertLessEqual(max(differences), maximum)
        return got

    def test_compiles(self):
        result = subprocess.run([str(COMPILER), "--null", str(SOURCE)], capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_baseline_and_progressive_gray_and_sampling(self):
        for progressive in (False, True):
            for mode, sampling in (("L", 0), ("RGB", 0), ("RGB", 1), ("RGB", 2)):
                with self.subTest(progressive=progressive, mode=mode, sampling=sampling):
                    encoded, expected = fixture(mode=mode, progressive=progressive, subsampling=sampling)
                    self.compare(encoded, expected, mean=2.3 if sampling else 0.8, maximum=14 if sampling else 4)

    def test_tiny_and_odd_dimensions(self):
        for size in ((1, 1), (1, 17), (17, 1), (9, 9), (31, 17)):
            for progressive in (False, True):
                with self.subTest(size=size, progressive=progressive):
                    encoded, expected = fixture(size=size, progressive=progressive, subsampling=0)
                    self.compare(encoded, expected)

    def test_string_input_and_exif_orientations(self):
        for orientation in range(1, 9):
            exif = Image.Exif()
            exif[274] = orientation
            encoded, expected = fixture(size=(19, 11), exif=exif, progressive=orientation % 2 == 0)
            with self.subTest(orientation=orientation):
                self.compare(encoded, expected, as_buffer=False)

    def test_restart_markers(self):
        for progressive in (False, True):
            for options in ({"restart_marker_blocks": 2}, {"restart_marker_rows": 1}):
                encoded, expected = fixture(size=(47, 35), progressive=progressive, subsampling=2, **options)
                self.assertIn(b"\xff\xdd", encoded)
                with self.subTest(progressive=progressive, options=options):
                    self.compare(encoded, expected, mean=2.3, maximum=14)

    def test_texture_against_pillow(self):
        image = Image.new("RGB", (48, 41))
        image.putdata([((x * 37 + y * 17) % 256, (x * 11 + y * 53) % 256, (x * 23 + y * 29) % 256)
                       for y in range(41) for x in range(48)])
        for progressive in (False, True):
            output = io.BytesIO()
            image.save(output, "JPEG", quality=92, subsampling=0, progressive=progressive)
            expected = Image.open(io.BytesIO(output.getvalue())).convert("RGBA")
            self.compare(output.getvalue(), expected, mean=0.9, maximum=4)

    def test_direct_rgb_and_extended_sequential(self):
        for progressive in (False, True):
            encoded, expected = fixture(size=(23, 19), progressive=progressive, keep_rgb=True)
            self.compare(encoded, expected)
        encoded, expected = fixture(size=(23, 19))
        self.compare(encoded.replace(b"\xff\xc0", b"\xff\xc1", 1), expected)

    def test_16_bit_quantization_in_extended_sequential(self):
        encoded, expected = fixture()
        parts, position = [encoded[:2]], 2
        while position < len(encoded):
            code = encoded[position + 1]
            if code == 0xDA:
                parts.append(encoded[position:])
                break
            length = int.from_bytes(encoded[position + 2:position + 4], "big")
            payload = encoded[position + 4:position + 2 + length]
            if code == 0xDB:
                expanded = bytearray()
                offset = 0
                while offset < len(payload):
                    spec = payload[offset]
                    self.assertLess(spec, 16)
                    expanded.append(spec | 16)
                    for q in payload[offset + 1:offset + 65]:
                        expanded.extend((0, q))
                    offset += 65
                parts.append(b"\xff\xdb" + struct.pack(">H", len(expanded) + 2) + expanded)
            else:
                parts.append(bytes((255, 0xC1 if code == 0xC0 else code)) + encoded[position + 2:position + length + 2])
            position += length + 2
        self.compare(b''.join(parts), expected)

    def test_malformed_tables_sampling_and_scan_headers(self):
        encoded, _ = fixture(progressive=True)
        sof = encoded.index(b"\xff\xc2")
        sos = encoded.index(b"\xff\xda")
        bad_sampling = bytearray(encoded)
        bad_sampling[sof + 11] = 0
        bad_precision = bytearray(encoded)
        bad_precision[sof + 4] = 12
        bad_order = bytearray(encoded)
        scan_size = int.from_bytes(encoded[sos + 2:sos + 4], "big")
        bad_order[sos + 2 + scan_size - 1] = 0x10
        oversubscribed = b"\xff\xd8\xff\xc4\x00\x16\x00\x03" + b"\x00" * 15 + b"\x00\x01\x02\xff\xd9"
        zero_quant = b"\xff\xd8\xff\xdb\x00\x43\x00" + b"\x00" * 64 + b"\xff\xd9"
        for payload in (bytes(bad_sampling), bytes(bad_precision), bytes(bad_order), oversubscribed, zero_quant):
            self.run_luau(f"local ok,err=pcall(JPEG.decode,{literal(payload)}); assert(not ok); assert(tostring(err):find('JPEG:',1,true))")

    def test_excessive_valid_progressive_scan_sequence_is_bounded(self):
        def segment(marker, payload):
            return bytes((255, marker)) + struct.pack(">H", len(payload) + 2) + payload

        data = bytearray(b"\xff\xd8")
        data += segment(0xDB, b"\x00" + b"\x01" * 64)
        data += segment(0xC2, b"\x08\x00\x08\x00\x08\x01\x01\x11\x00")
        table = b"\x01" + b"\x00" * 15 + b"\x00"
        data += segment(0xC4, b"\x00" + table + b"\x10" + table)
        scans = 0
        for coefficient in range(64):
            for low_bit in range(13, -1, -1):
                previous = 0 if low_bit == 13 else low_bit + 1
                data += segment(0xDA, bytes((1, 1, 0, coefficient, coefficient, previous * 16 + low_bit)))
                data += b"\x7f"  # zero Huffman symbol/bit, then one-valued padding
                scans += 1
                if scans == 97:
                    break
            if scans == 97:
                break
        data += b"\xff\xd9"
        self.run_luau(f"local ok,err=pcall(JPEG.decode,{literal(bytes(data))}); assert(not ok); assert(tostring(err):find('scan count limit',1,true),tostring(err))")

    def test_repeated_table_definitions_have_a_separate_allocation_bound(self):
        quant = b"\xff\xdb\x00\x43\x00" + b"\x01" * 64
        huffman = b"\xff\xc4\x00\x14\x00\x01" + b"\x00" * 16
        for table in (quant, huffman):
            payload = b"\xff\xd8" + table * 257 + b"\xff\xd9"
            self.run_luau(f"local ok,err=pcall(JPEG.decode,{literal(payload)}); assert(not ok); assert(tostring(err):find('table definition limit',1,true),tostring(err))")

    def test_heavy_work_can_yield_and_cancel_late(self):
        data, _ = fixture(size=(256, 192), progressive=True, subsampling=2)
        self.run_luau(f"""
local checks, yields, output=0,0,nil
local worker=coroutine.create(function()
 local w,h,p=JPEG.decode({literal(data)},{{checkpoint=function()
  checks+=1; if checks%25==0 then coroutine.yield() end
 end}})
 output={{w,h,buffer.len(p)}}
end)
while coroutine.status(worker)~='dead' do
 local ok,err=coroutine.resume(worker); assert(ok,err); yields+=1
end
assert(output[1]==256 and output[2]==192 and output[3]==256*192*4)
assert(yields>5 and checks>125)
local target=math.floor(checks*.8)
checks=0
local ok,err=pcall(JPEG.decode,{literal(data)},{{checkpoint=function()
 checks+=1; if checks==target then error('late cancellation') end
end}})
assert(not ok and tostring(err):find('late cancellation',1,true))
""")

    def test_rejects_truncation_cmyk_and_dimension_bombs(self):
        baseline, _ = fixture()
        cmyk, _ = fixture(mode="CMYK")
        frame = baseline.index(b"\xff\xc0")
        oversized = bytearray(baseline)
        oversized[frame + 5:frame + 9] = bytes((0x10, 0x01, 0x10, 0x01))
        bomb = bytearray(baseline)
        bomb[frame + 5:frame + 9] = bytes((0x08, 0x01, 0x08, 0x01))
        for payload in (b"abcd", baseline[:-2], baseline[:40], cmyk, bytes(oversized), bytes(bomb)):
            with self.subTest(length=len(payload)):
                self.run_luau(f"local ok,err=pcall(JPEG.decode,{literal(payload)}); assert(not ok); assert(tostring(err):find('JPEG:',1,true))")
        self.run_luau("local ok,err=pcall(JPEG.decode,buffer.create(10*1024*1024+1)); assert(not ok); assert(tostring(err):find('10 MiB',1,true))")

    def test_cancellation_propagates_and_decoder_has_no_shared_scan_state(self):
        data, expected = fixture(size=(64, 64), progressive=True)
        self.run_luau(f"""
local calls=0
local ok,err=pcall(JPEG.decode,{literal(data)},{{checkpoint=function() calls+=1; if calls==8 then error('user cancelled') end end}})
assert(not ok and tostring(err):find('user cancelled',1,true)); assert(calls==8)
local w,h,p=JPEG.decode({literal(data)})
assert(w==64 and h==64 and buffer.len(p)==64*64*4)
""")
        self.compare(data, expected)


if __name__ == "__main__":
    unittest.main(verbosity=2)
