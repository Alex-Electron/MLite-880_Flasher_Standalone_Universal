# Release evidence — 2026-10-15

Published installer: [dfu-driver-v1.0.0](https://github.com/Alex-Electron/MLite-880_Flasher_Standalone_Universal/releases/tag/dfu-driver-v1.0.0).

Exact native source commit: `51e0d83ea101f02b685f5472bfbf515c5472d1f4`.
Windows build: [Actions 38697755850](https://github.com/Alex-Electron/MLite-880_Flasher_Standalone_Universal/actions/runs/38697755850).
EXE SHA-256: `14bf70ffffce5f9cc02b775f7edc3f1a528bf24fab2e63ad10ea129e0253810f`.

## Verified

- The original QMK v1.01 and Zadig 2.9 EXEs match their official upstream release downloads byte-for-byte. Their hashes are pinned in source and checked both during build and before extraction.
- Windows compilation and `--self-test` passed. Tests cover matching physical DFU IDs, rejecting different PIDs/composite children, rejecting zero/multiple/changed devices, the fixed single-row WinUSB target CSV, argument quoting, embedded hashes and licenses.
- Both EN and RU setup windows were rendered on the Windows runner using `--preview` and visually inspected. The preview finds no DFU on the runner; it never invokes installation.
- Browser checks with mocked WebUSB passed for Windows and Linux: chooser cancellation, request permission denial, device opening failure, failed-handle cleanup, direct installer link visibility, retry, all five UI languages, desktop and 390 px layout. No physical USB calls were made.
- `node --test tools/dfu-driver/usb-help.test.cjs` passed: page script parsing/loading order, cancellation classification, permission vs opening failures, OS-specific download visibility and language coverage.
- `python3 tools/check_firmware_layout.py` passed with all 14 MLite-880 firmware images. Existing firmware files and firmware write protocol were not changed by this work.

## Acceptance still needed

On Windows 10/11 with a receiver in DFU `0483:DF11`: confirm the displayed instance, click Install WinUSB, approve UAC, verify the helper reports WinUSB actually bound with Windows status 0, then reconnect in the browser. Driver installation, UAC flow and WebUSB opening on physical receiver hardware have not been exercised during this change. Driver installation does not itself establish successful firmware flashing. ARM64 is unvalidated.

The wrapper is unsigned. It does not install firmware or alter browser permissions. It does not prove that every device exposing `0483:DF11` is a MALAHIT receiver. The embedded manual Zadig fallback still lists other device IDs; its warning must be followed.

For continuation, keep the release asset tied to the source commit above; do not silently replace it with a later CI artifact. Publish a new driver release/version for native changes. The web link is defined in `docs/usb-help.js`; cached scripts carry the Web Flasher version query.
