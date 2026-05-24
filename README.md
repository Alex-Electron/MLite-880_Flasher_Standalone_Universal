# Malachite DSP (MLite-880) Universal Flasher v1.2.1

This is a standalone firmware flashing toolkit for the Malachite DSP (MLite-880) receiver.
Supports Windows, macOS, and Linux.

Developed by: Alexander Lavrinovich
GitHub: https://github.com/Alex-Electron
Email: EU1L@mail.ru

## 🚀 How to Flash Firmware

1. Place your firmware `.bin` files into this directory.
2. Connect your receiver to your computer via USB.
3. Put the receiver into **DFU mode**: Press and hold the **1** button, turn on the radio, wait for 3 seconds, then release the **1** button. The radio will now be in DFU mode.
4. Run the flasher:
   - **Windows:** Double-click `flash_MLite880.bat`.
   - **macOS / Linux:** Open Terminal and run `./flash_MLite880.sh`.
5. Follow the on-screen menu to select the firmware version.

---

## 🛠️ Setup & Troubleshooting

### 🪟 Windows: USB Driver Issue
If the script says "No DFU capable USB device available", you need to install the **WinUSB driver**:
1. Run the included `zadig-2.9.exe`.
2. Click `Options` -> `List All Devices`.
3. Select `STM32 BOOTLOADER` from the list.
4. Ensure the target driver is set to `WinUSB`.
5. Click `Install Driver` and wait for completion.

### 🍎 macOS
1. Install requirements: `brew install dfu-util`
2. Root privileges (sudo) are usually **not required**.
3. If the device is not found, check **System Settings > Privacy & Security** to ensure USB accessories are allowed.

### 🐧 Linux (Ubuntu, Debian, etc.)
By default, Linux requires root privileges for raw USB access. You have two options:

#### Option 1: One-time setup (Recommended)
Grant permanent access to your user so you don't need `sudo` anymore:
```bash
echo 'SUBSYSTEM=="usb", ATTR{idVendor}="0483", ATTR{idProduct}="df11", MODE="0666"' | sudo tee /etc/udev/rules.d/50-dfu-malachite.rules     
sudo udevadm control --reload-rules
```
*After running this, unplug and reconnect the receiver.*

#### Option 2: Run with sudo
If you prefer not to create a system rule:
```bash
sudo ./flash_MLite880.sh
```

---

## ⚖️ Third-Party Software & Disclaimer
This repository bundles tools licensed under GPL/LGPL for convenience.
- **dfu-util**: https://dfu-util.sourceforge.net/ (GPLv2)
- **libusb**: https://libusb.info/ (LGPL)
- **Zadig**: https://zadig.akeo.ie/ (GPLv3)
- **Firmware Files (.bin):**
  - Official Telegram Group: https://t.me/MalahitReceiver/409671
  - Official Website: https://elecevolve.com/download/
  - Facebook Group: https://www.facebook.com/groups/1604528603918557/

**DISCLAIMER:** This software is provided "AS IS". The author is NOT responsible for any damage ("bricking") to your device. Flash at your own risk!
