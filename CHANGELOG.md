# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-05-23

### Fixed
- Fixed flashing speed and reliability by switching to **Sector-by-Sector erase** mode (matching official ST utility behavior).
- Fixed issues with bundled binaries not being correctly detected in Windows Git Bash.
- Removed invalid \:verify\ modifier that caused \dfu-util\ to crash.
- Restored \:leave\ modifier for automatic device reboot after a successful flash.

### Added
- Unified naming convention for all firmware files (\MLite880_vX.XX_YYYYMMDD.bin\) for better sorting and clarity.
- Interactive selection menu in both \.bat\ and \.sh\ scripts now displays firmware file sizes and versions clearly.
- ANSI color output for the macOS/Linux script (\lash_MLite880.sh\).
- Explicit DFU mode instructions provided in the console before starting the flash process.
- Complete standalone package: bundled \dfu-util\, \libusb\, and \Zadig\ for Windows users.

## [1.0.1] - 2026-05-23

### Added
- Added clear instructions on how to enter DFU mode to \README.md\ and script outputs.
- Added firmware source links to the disclaimer.
- Initial versioning display in scripts.

## [1.0.0] - 2026-05-23

### Added
- Initial release of the Universal Flasher for Malachite DSP (MLite-880).
- Windows batch script (\lash_MLite880.bat\) with interactive menu.
- macOS / Linux bash script (\lash_MLite880.sh\) with interactive menu.
- Added MIT License and initial documentation.
