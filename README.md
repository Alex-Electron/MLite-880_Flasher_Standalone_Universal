# Malachite DSP (MLite-880) Universal Flasher v2.0.0

This is a standalone firmware flashing toolkit for the Malachite DSP (MLite-880) receiver.
Supports Windows, macOS, and Linux.
**Tested successfully on: Windows 10/11, macOS (Intel), and Ubuntu Linux.**

Developed by: Alexander Lavrinovich
GitHub: https://github.com/Alex-Electron
Email: EU1L@mail.ru

## 🚀 How to Flash Firmware

1. All current firmware `.bin` files (as of May 25, 2026) are already included in this folder. If new versions are released in the future, simply drop the new `.bin` files into this directory, and the flasher will automatically detect them.
2. Connect your receiver to your computer via USB.
3. Put the receiver into **DFU mode**: Press and hold the **1** button, turn on the radio, wait for 3 seconds, then release the **1** button. The radio will now be in DFU mode.
4. Run the flasher:
   - **Windows:** Double-click `flash_MLite880.bat`.
   - **macOS / Linux:** Open Terminal and run `./flash_MLite880.sh`.
5. Follow the on-screen menu to select the firmware version.

That's it. Starting from v2.0.0 the script automatically:
- detects whether the receiver is in DFU mode and visible on the USB bus;
- on macOS — offers to automatically install Homebrew and `dfu-util` if missing;
- on Debian/Ubuntu — offers to automatically install `dfu-util` via `apt`;
- on Linux/macOS — re-runs itself with `sudo` if raw USB access is denied;
- on Windows — detects a missing WinUSB driver and installs it silently (admin elevation handled automatically).

---

## 🛠️ Setup & Troubleshooting

### 🪟 Windows: USB Driver
Since v2.0.0 the `.bat` installs the WinUSB driver **silently** when needed. If the STM32 BOOTLOADER device is on the USB bus but the WinUSB driver is missing, the script:

1. Requests administrator rights (one UAC prompt).
2. Runs the bundled `qmk_driver_installer.exe` with `--vid 0x0483 --pid 0xdf11 --type 0` — installs WinUSB silently, no clicks required.
3. Continues to the firmware selection automatically.

**First-run note:** because the installer is an unsigned binary from a GitHub release, Windows SmartScreen may show a warning the very first time. Click **More info → Run anyway** once and Windows will remember it by hash.

If something goes wrong with the silent install, the script falls back to the bundled `zadig-2.9.exe` (interactive). You can also install the driver manually:
1. Run `zadig-2.9.exe`.
2. Click `Options` -> `List All Devices`.
3. Select `STM32 BOOTLOADER` from the list.
4. Ensure the target driver is set to `WinUSB`.
5. Click `Install Driver` and wait for completion.

### 🍎 macOS
1. The script will **automatically offer to install** `Homebrew` and `dfu-util` for you if they are missing.
2. Root privileges (sudo) are usually **not required**.
3. If the device is not found, check **System Settings > Privacy & Security** to ensure USB accessories are allowed.

### 🐧 Linux (Ubuntu, Debian, Fedora, RHEL, Arch, openSUSE, etc.)

**Debian / Ubuntu:**
The script will **automatically offer to install** `dfu-util` via `apt` if it is missing.

**Other Distributions:**
Install `dfu-util` manually for your distro:
```bash
# Fedora / RHEL
sudo dnf install dfu-util
# Arch
sudo pacman -S dfu-util
# openSUSE
sudo zypper install dfu-util
```

By default, raw USB access on Linux requires root privileges. The script handles this automatically — if it detects an access error, it re-runs itself with `sudo` (you will be prompted for your password once).

If you prefer to avoid `sudo` entirely, install a udev rule once:
```bash
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", MODE="0666"' | sudo tee /etc/udev/rules.d/50-dfu-malachite.rules
sudo udevadm control --reload-rules
```
After this, unplug and reconnect the receiver. From then on the script runs without elevation.

---

## 🧰 Included Utility Tools

The `tools/` folder contains additional scripts to clean up your system environment after flashing or testing:

- **`tools/cleanup_drivers.bat` (Windows):** Removes the installed STM32 WinUSB drivers from your Windows system. Useful if you encounter driver conflicts or want a clean slate.
- **`tools/cleanup_mac.sh` (macOS):** Removes `dfu-util` and offers to completely uninstall Homebrew from your Mac. Useful for restoring a test environment to its original state.

---

## 🔍 Technical Quirks & OS Behaviors

This flasher employs a few technical tricks to provide a seamless experience across platforms:

- **The Exit Code 74 (All Systems):** Upon a successful flash, `dfu-util` sends a `:leave` command to the microcontroller. The device immediately resets and disconnects from the USB bus. Consequently, `dfu-util` fails to close the connection cleanly and returns an `Exit Code 74 (Error during download get_status)`. The scripts are designed to intercept this:
  - The **Windows (`.bat`)** script actively probes the USB bus post-flash. If the DFU device has disappeared, it correctly registers this as a "Success".
  - The **macOS/Linux (`.sh`)** script captures `stdout` in real-time. If it spots the phrase *"File downloaded successfully"*, it overrides the exit code and registers a "Success".
- **PnP Restart (Windows):** When the WinUSB driver is silently installed for the first time, Windows needs to "bind" it to the already connected device. Instead of asking you to physically unplug and replug the receiver, the `.bat` script uses `pnputil /restart-device` to programmatically reboot the USB port.

---

## ⚖️ Third-Party Software & Disclaimer
This repository bundles tools licensed under GPL/LGPL for convenience.
- **dfu-util**: https://dfu-util.sourceforge.net/ (GPLv2)
- **libusb**: https://libusb.info/ (LGPL)
- **Zadig**: https://zadig.akeo.ie/ (GPLv3)
- **qmk_driver_installer**: https://github.com/qmk/qmk_driver_installer (GPLv3 / LGPLv3, fork of libwdi) — used for silent WinUSB driver installation. Verify integrity with the bundled `qmk_driver_installer.exe.sha256`.
- **Firmware Files (.bin):**
  - Official Telegram Group: https://t.me/MalahitReceiver/409671
  - Official Website: https://elecevolve.com/download/
  - Facebook Group: https://www.facebook.com/groups/1604528603918557/

**DISCLAIMER:** This software is provided "AS IS". The author is NOT responsible for any damage ("bricking") to your device. Flash at your own risk!
