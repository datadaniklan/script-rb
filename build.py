"""Build the standalone bundle using only the public source tree (Python 3.10+)."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "src"


def module(name: str, substitutions: dict[str, str] | None = None) -> str:
    text = (SRC / name).read_text(encoding="utf-8")
    for marker, replacement in (substitutions or {}).items():
        if text.count(marker) != 1:
            raise ValueError(f"Expected one {marker} in {name}")
        text = text.replace(marker, replacement)
    return "(function()\n" + text.rstrip() + "\nend)()"


def build() -> Path:
    decoder = module("local_image_decoder.lua", {
        "__PNG_DECODER__": module("vendor/png.luau"),
        "__JPEG_DECODER__": module("local_jpeg_decoder.lua"),
    })
    backend = module("backend.lua", {
        "__IMAGE_DECODER__": decoder,
        "__IMAGE_PLANNER__": module("local_image_processing.lua"),
    })
    source = (SRC / "client.lua").read_text(encoding="utf-8")
    for marker, value in {"__GAME_ADAPTER__": module("game_adapter.lua"), "__IMAGE_BACKEND__": backend}.items():
        if source.count(marker) != 1:
            raise ValueError(f"Expected one {marker}")
        source = source.replace(marker, value)
    if re.search(r"__(?:GAME|IMAGE|PNG|JPEG)_[A-Z_]+__", source):
        raise ValueError("Unresolved source placeholder")
    for forbidden in ("127.0.0.1", "localhost", "Bearer ", "__IMAGE_TOKEN__", "YOUR IMAGE. YOUR WORLD."):
        if forbidden in source:
            raise ValueError(f"Private dependency or removed UI text in bundle: {forbidden}")
    notices = ["BAFT Image Builder license\n" + (ROOT / "LICENSE").read_text(encoding="utf-8")]
    for path in ("vendor/png-luau.LICENSE", "vendor/jpeg-js/NOTICE.txt",
                 "vendor/jpeg-js/LICENSE-APACHE-2.0.txt", "vendor/jpeg-js/LICENSE-UPSTREAM-BSD.txt"):
        notice = (SRC / path).read_text(encoding="utf-8")
        if "]==]" in notice:
            raise ValueError("Unexpected license comment delimiter")
        notices.append(path + "\n" + notice)
    source = "--[==[\nThird-party notices\n\n" + "\n\n".join(notices) + "\n]==]\n" + source
    build_id = hashlib.sha256(source.encode("utf-8")).hexdigest()[:20]
    output = f"-- BAFT Image Builder release {build_id}\n{source}"
    (ROOT / "dist").mkdir(exist_ok=True)
    destination = ROOT / "dist" / f"builder_{build_id}.lua"
    destination.write_text(output, encoding="utf-8", newline="\n")
    data = destination.read_bytes()
    manifest = {"format": 1, "version": "3.0.1", "build": build_id, "bytes": len(data),
                "sha256": hashlib.sha256(data).hexdigest()}
    (ROOT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8", newline="\n")
    return destination


if __name__ == "__main__":
    print(build())
