"""Exercise the platform flasher's firmware list without connecting a receiver."""

from __future__ import annotations

import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
FIRMWARE = ROOT / "Firmware" / "MLite-880"
SCRIPT_NAME = "flash_MLite880.bat" if os.name == "nt" else "flash_MLite880.sh"
ROW = re.compile(r"^\s+\[(\d+)\]\s+(MLite880_v\S+\.bin)\s*(?:\(|$)")
ANSI = re.compile(r"\x1b\[[0-9;]*m")
DATE = re.compile(r"_(\d{8})\.bin$")


def listed_firmware(script: Path) -> list[str]:
    command = (["cmd", "/c", str(script), "--list-firmware"] if os.name == "nt"
               else ["bash", str(script), "--list-firmware"])
    result = subprocess.run(command, cwd=tempfile.gettempdir(), capture_output=True,
                            text=True, errors="replace", timeout=30)
    output = ANSI.sub("", result.stdout + result.stderr)
    if result.returncode:
        raise AssertionError(f"{SCRIPT_NAME} exited {result.returncode}:\n{output}")
    rows = [ROW.match(line) for line in output.splitlines()]
    entries = [(int(match[1]), match[2]) for match in rows if match]
    assert [number for number, _ in entries] == list(range(1, len(entries) + 1)), output
    return [name for _, name in entries]


def newest_first(names: list[str]) -> list[str]:
    assert all(DATE.search(name) for name in names), names
    return sorted(names, key=lambda name: DATE.search(name)[1], reverse=True)


def main() -> None:
    actual = sorted(path.name for path in FIRMWARE.glob("MLite880_v*.bin"))
    assert actual, "No MLite-880 firmware found"
    assert not list(ROOT.glob("MLite880_v*.bin")), "MLite-880 firmware remains in repo root"
    assert listed_firmware(ROOT / SCRIPT_NAME) == newest_first(actual)

    web_page = (ROOT / "docs" / "index.html").read_text(encoding="utf-8")
    web_path = re.search(r"const FIRMWARE_REPO_PATH = '([^']+)'", web_page)
    assert web_path, "Web flasher firmware path is missing"
    assert (ROOT / web_path[1]).resolve() == FIRMWARE.resolve(), web_path[1]
    assert "contents/' + FIRMWARE_REPO_PATH + '?ref=main'" in web_page

    # This fixture catches hard-coded working directories, unquoted paths, and
    # accidental inclusion of a future DSP4 image in the MLite-880 menu.
    with tempfile.TemporaryDirectory(prefix="MLite firmware path ") as location:
        test_root = Path(location)
        shutil.copy2(ROOT / SCRIPT_NAME, test_root / SCRIPT_NAME)
        target = test_root / "Firmware" / "MLite-880"
        target.mkdir(parents=True)
        (test_root / "Firmware" / "DSP4").mkdir()
        for name in ("MLite880_v1.20_20260206.bin", "MLite880_v1.60_20261011.bin"):
            (target / name).write_bytes(b"fixture")
        (test_root / "Firmware" / "DSP4" / "DSP4_v2.60_20990101.bin").write_bytes(b"fixture")
        assert listed_firmware(test_root / SCRIPT_NAME) == [
            "MLite880_v1.60_20261011.bin", "MLite880_v1.20_20260206.bin"
        ]
    print(f"{SCRIPT_NAME}: {len(actual)} repository images and model-isolation fixture OK")


if __name__ == "__main__":
    main()
