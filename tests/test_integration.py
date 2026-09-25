"""Exercise actual download -> decode -> plan -> encoded preview without live game mutations."""
import importlib.util
import io
from pathlib import Path
import unittest

from PIL import Image
import test_runtime

ROOT = test_runtime.ROOT


def literal(data):
    return '"' + ''.join(f"\\{value:03d}" for value in data) + '"'


class PipelineIntegrationTests(unittest.TestCase):
    # RuntimeTests methods are deliberately not repeated by this integration class.
    execute = test_runtime.RuntimeTests.execute

    def test_actual_png_jpeg_conversion(self):
        spec = importlib.util.spec_from_file_location("release_builder", ROOT / "build.py")
        builder = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(builder)
        decoder = builder.module("local_image_decoder.lua", {
            "__PNG_DECODER__": builder.module("vendor/png.luau"),
            "__JPEG_DECODER__": builder.module("local_jpeg_decoder.lua"),
        })
        backend = builder.module("backend.lua", {
            "__IMAGE_DECODER__": decoder,
            "__IMAGE_PLANNER__": builder.module("local_image_processing.lua"),
        })
        image = Image.new("RGBA", (7, 5))
        image.putdata([(x * 30, y * 40, (x + y) * 20, 0 if x == y else 255)
                       for y in range(5) for x in range(7)])
        png = io.BytesIO()
        image.save(png, "PNG")
        jpeg = io.BytesIO()
        exif = Image.Exif()
        exif[274] = 6
        image.convert("RGB").save(jpeg, "JPEG", progressive=True, exif=exif)
        code = '''
local bytes, previewSaved, requests = nil, {}, 0
local function request(args)
    requests += 1
    assert(args.Method == "GET" and args.Url == "https://images.example/image")
    return {StatusCode=200,Body=bytes}
end
local task = {spawn=function(fn) fn() end, wait=function() end}
local function writefile(path, value) previewSaved[path]=value end
local game = {GetService=function() return {
    GenerateGUID=function() return "12345678-1234-1234-1234-123456789abc" end,
    JSONEncode=function() return "{}" end,
} end}
local Backend = ''' + backend + '\n'
        code += 'local pngBytes, jpegBytes = ' + literal(png.getvalue()) + ', ' + literal(jpeg.getvalue()) + '\n'
        code += 'local original = ' + literal(image.tobytes()) + '\n'
        code += '''
local settings = {image_url="https://images.example/image",width_studs=7,pixel_studs=1,
    resolution_mode="source",max_blocks=250000,palette_size=0,detail="none",sampling="nearest",block_type="WoodBlock"}
bytes = pngBytes
local plan = Backend.convert(settings)
assert(plan.columns==7 and plan.rows==5 and plan.block_count==30)
local restored, seen = {}, {}
for _, rect in ipairs(plan.rectangles) do
    for y=rect.y, rect.y+rect.h-1 do for x=rect.x, rect.x+rect.w-1 do
        local i=y*7+x
        assert(not seen[i], "overlapping rectangles")
        seen[i]=true
        local at=i*4
        assert(original:byte(at+4)==255)
        for c=1,3 do assert(rect.color[c]==original:byte(at+c)) end
    end end
end
assert(Backend.preview(plan.id):sub(1,8)=="\\137PNG\\13\\10\\26\\10")
bytes = jpegBytes
local rotated = Backend.convert(settings)
assert(rotated.columns==5 and rotated.rows==7 and rotated.block_count==35)
assert(rotated.width_studs==7 and math.abs(rotated.height_studs-9.8)<1e-10, "rotated physical dimensions")
assert(requests==2)
print("PIPELINE_INTEGRATION_PASSED 2")
'''
        self.execute("integration_shell.lua", "--[[INTEGRATION]]", code, "PIPELINE_INTEGRATION_PASSED 2")


if __name__ == "__main__":
    unittest.main()
