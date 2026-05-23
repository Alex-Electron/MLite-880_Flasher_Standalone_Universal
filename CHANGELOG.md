# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-05-23

### Added
- Added clear instructions on how to enter DFU mode directly in the flasher scripts console output (`flash_MLite880.bat` and `flash_MLite880.sh`).
- Added DFU mode instructions to `README.md`.
- Added firmware source links to the disclaimer.

## [1.0.0] - 2026-05-23

### Added
- Initial release of the Universal Flasher for Malachite DSP (MLite-880).
- Windows batch script (`flash_MLite880.bat`) with interactive firmware selection menu.
- macOS / Linux bash script (`flash_MLite880.sh`) with interactive firmware selection menu.
- Bundled `dfu-util.exe` (v0.11) and `libusb-1.0.dll` for standalone execution on Windows.
- Bundled `zadig-2.9.exe` for easy WinUSB driver installation on Windows.
- Comprehensive `README.md` with instructions for Windows, macOS, and Linux.
- Added MIT License.

