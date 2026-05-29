# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.0] - 2026-05-29

### Added
- **Arch Linux: Interactive Auto-Install** — if `dfu-util` is missing, the script now automatically offers to install it via `pacman` (`sudo pacman -Sy --noconfirm dfu-util`). Same one-click UX as Debian/Ubuntu. Tested on Arch Linux live ISO.
- **Fedora / RHEL: Interactive Auto-Install** — same auto-install flow via `dnf install -y dfu-util`.
- **openSUSE: Interactive Auto-Install** — same auto-install flow via `zypper install -y dfu-util`.

### Changed
- Refactored Linux install path in `flash_MLite880.sh`: shared logic extracted into a `_install_dfu_util_pkg` helper to avoid duplication across the four package managers. The existing `apt` branch behaves identically to v2.2.0.
- Bumped script version to **2.3.0** in `flash_MLite880.sh`, `flash_MLite880.bat`, and `README.md`.

## [2.2.0] - 2026-05-27

### Added
- Added new firmware: **MLite880_v1.55_20260527.bin**.

### Fixed
- **Windows: Version display in `flash_MLite880.bat`** — the script header still showed `v2.0.0`, even though the v2.1.0 changelog claimed it was bumped.
- **Windows: Removed orphaned dead code** at the end of `flash_MLite880.bat` (leftover PowerShell input-flush fragment from the v2.1.0 cleanup).
- **Removed `test_check.bat`** — local diagnostic script with a hardcoded absolute path, accidentally committed during v2.0.0 development.

### Changed
- Bumped script version to **2.2.0** in `flash_MLite880.sh` and `flash_MLite880.bat`.

## [2.1.0] - 2026-05-25

### Added
- Added new firmware: **MLite880_v1.54_20260526.bin**.

### Fixed
- **Windows: UI responsiveness at the end of the script**: Removed a slow PowerShell-based input buffer flush that caused a delay and required an extra keypress before displaying the final "Press any key" prompt.

### Changed
- Bumped script version to **2.1.0** in `flash_MLite880.sh` and `flash_MLite880.bat`.

## [2.0.0] - 2026-05-24

### Added
- **macOS: Interactive Auto-Install** — if Homebrew and/or `dfu-util` are missing, the script will automatically offer to install them.
- **Debian/Ubuntu: Interactive Auto-Install** — if `dfu-util` is missing, the script will automatically offer to install it via `apt`.
- **Auto-elevate to `sudo` on Linux/macOS** when raw USB DFU access is denied — no need to manually prefix `sudo` anymore.
- **Upfront USB device detection** across all platforms before firmware selection: `lsusb` on Linux, `system_profiler` on macOS, `pnputil` on Windows. The user gets a clear message ("device not in DFU mode" vs "driver missing") instead of confusing dfu-util errors.
- **Windows: Silent WinUSB driver install** — if the STM32 BOOTLOADER device is on the USB bus but the WinUSB driver is missing, the `.bat` self-elevates to Administrator and runs the bundled `qmk_driver_installer.exe`. No clicks required. It then programmatically restarts the USB port (`pnputil /restart-device`) to bind the driver without requiring a physical unplug/replug.
- Added `qmk_driver_installer.exe` (6.19 MB, SHA256 in sidecar file `qmk_driver_installer.exe.sha256`) for silent WinUSB installation.
- Added a `tools/` folder containing cleanup scripts for testing and environment resets: `cleanup_drivers.bat` (Windows, handles UTF-16 INF files) and `cleanup_mac.sh` (macOS).

### Fixed
- **False-positive failure on a successful flash (Exit Code 74)**: Both `.sh` and `.bat` scripts now correctly interpret Exit Code 74 combined with device disconnection (or log verification) as a successful flash.
- **Windows false-positive success on driver failure**: Fixed a bug where a `LIBUSB_ERROR_NOT_SUPPORTED` failure on Windows was incorrectly reported as a success. The `.bat` script now strictly verifies that the exit code is 74 *and* the device is no longer on the bus, while maintaining the native `dfu-util` real-time progress bar (avoiding carriage return rendering issues caused by PowerShell pipes).
- `udev` hint after a flash failure now matches all Linux distros (`linux*` in `$OSTYPE`).

### Changed
- Bumped script version to **2.0.0** in `flash_MLite880.sh` and `flash_MLite880.bat`.

## [1.2.1] - 2026-05-23

### Fixed
- Improved OS detection logic to correctly handle bundled binaries on Windows while using system binaries on macOS and Linux.
- Fixed 'Permission denied' error when running the bash script on Linux/macOS.

## [1.2.0] - 2026-05-23

### Fixed
- Fixed flashing speed and reliability by switching to **Sector-by-Sector erase** mode (matching official ST utility behavior).
- Fixed issues with bundled binaries not being correctly detected in Windows Git Bash.
- Removed invalid `:verify` modifier that caused `dfu-util` to crash.
- Restored `:leave` modifier for automatic device reboot after a successful flash.

### Added
- Unified naming convention for all firmware files (`MLite880_vX.XX_YYYYMMDD.bin`) for better sorting and clarity.
- Interactive selection menu in both `.bat` and `.sh` scripts now displays firmware file sizes and versions clearly.
- ANSI color output for the macOS/Linux script (`flash_MLite880.sh`).
- Explicit DFU mode instructions provided in the console before starting the flash process.
- Complete standalone package: bundled `dfu-util`, `libusb`, and `Zadig` for Windows users.

## [1.0.1] - 2026-05-23

### Added
- Added clear instructions on how to enter DFU mode to `README.md` and script outputs.
- Added firmware source links to the disclaimer.
- Initial versioning display in scripts.

## [1.0.0] - 2026-05-23

### Added
- Initial release of the Universal Flasher for Malachite DSP (MLite-880).
- Windows batch script (`flash_MLite880.bat`) with interactive menu.
- macOS / Linux bash script (`flash_MLite880.sh`) with interactive menu.
- Added MIT License and initial documentation.

