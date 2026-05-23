# Malachite DSP (MLite-880) Universal Flasher

This is a standalone firmware flashing toolkit for the Malachite DSP (MLite-880) receiver. 

Developed by: Alexander Lavrinovich
GitHub: https://github.com/Alex-Electron
Email: EU1L@mail.ru

## How to Flash Firmware

1. Place your firmware .bin files into this directory.
2. Connect your receiver to your computer via USB.
3. Put the receiver into **DFU mode**.
4. **On Windows:** Double-click Flash_MLite880.bat.
   **On macOS/Linux:** Open Terminal, navigate to this folder, and run ./flash_MLite880.sh.
5. Follow the on-screen menu to select the firmware you want to flash.

---

## WINDOWS ONLY: USB Driver Issue (Device Not Found)

If the .bat script immediately closes or says "No DFU capable USB device available", your Windows system does not have the required **WinUSB driver** installed. 

To fix this, use the included **Zadig** tool:

1. Make sure your receiver is connected and is in **DFU mode**.
2. Run zadig-2.9.exe (included in this folder).
3. In Zadig, click Options in the top menu and select List All Devices.
4. In the main dropdown menu, select your receiver (it is usually named STM32 BOOTLOADER or something with DFU in FS Mode).
5. Ensure the driver on the **right side** of the green arrow is set to WinUSB.
6. Click the large Install Driver (or Replace Driver) button.
7. Wait for the installation to finish (it may take up to a minute).
8. Close Zadig and run Flash_MLite880.bat again!

## macOS / Linux Notes
- **macOS:** You need to have dfu-util installed via Homebrew. Run brew install dfu-util in your terminal.
- **Ubuntu/Debian:** Run sudo apt install dfu-util.

---

## ⚖️ Third-Party Software, Licenses & Disclaimer

This repository bundles several third-party binaries to provide a seamless "out-of-the-box" experience. These files are not covered by this repository's MIT License. They are distributed under their respective licenses:

*   **[dfu-util](https://dfu-util.sourceforge.net/)** (dfu-util.exe) - Licensed under **GPLv2**.
*   **[libusb](https://libusb.info/)** (libusb-1.0.dll) - Licensed under **LGPL**.
*   **[Zadig](https://zadig.akeo.ie/)** (zadig-2.9.exe) - Licensed under **GPLv3**.
*   **Firmware Files (.bin)** - Property of their respective authors/manufacturers. Provided here purely for convenience.

**DISCLAIMER OF LIABILITY:**
The firmware files and flashing tools in this repository are provided "AS IS", without warranty of any kind. The author of this repository (Alexander Lavrinovich) is **NOT** responsible for any damage, "bricking", or loss of functionality that may occur to your Malachite DSP receiver or computer as a result of using these scripts, tools, or firmware files. Flash at your own risk!
