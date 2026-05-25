#!/bin/bash

# ===================================================
#  Malachite DSP Firmware Flasher for macOS / Linux
#  v2.1.0 - Universal Stable Edition
#  Created by: Alexander Lavrinovich
#  GitHub: https://github.com/Alex-Electron
#  Email: EU1L@mail.ru
# ===================================================

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}===================================================${NC}"
echo -e "${BLUE}            Malachite DSP Flasher v2.1.0           ${NC}"
echo -e "${BLUE}===================================================${NC}"
echo ""

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Smart DFU binary detection
# On Windows/GitBash: prefer bundled .exe
# On macOS/Linux: use system-installed dfu-util
DFU_BIN="dfu-util"
if [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "win32"* ]]; then
    if [ -f "$DIR/dfu-util.exe" ]; then
        DFU_BIN="$DIR/dfu-util.exe"
    fi
fi

# Check if binary exists or is in PATH
if ! command -v "$DFU_BIN" &> /dev/null && [ ! -f "$DFU_BIN" ]; then
    echo -e "${RED}[ERROR] dfu-util is not installed.${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            echo -e "${YELLOW}Homebrew is not installed but is required to install dfu-util.${NC}"
            read -p "Would you like to install Homebrew now? (y/n): " install_brew
            if [[ "$install_brew" =~ ^[Yy]$ ]]; then
                echo -e "${GREEN}Installing Homebrew...${NC}"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                # Activate Homebrew for the current session (Apple Silicon or Intel)
                if [ -x "/opt/homebrew/bin/brew" ]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                elif [ -x "/usr/local/bin/brew" ]; then
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
            else
                echo -e "Please install Homebrew manually from https://brew.sh/"
                exit 1
            fi
        fi
        
        if command -v brew &> /dev/null; then
            read -p "Would you like to install dfu-util via Homebrew now? (y/n): " install_dfu
            if [[ "$install_dfu" =~ ^[Yy]$ ]]; then
                echo -e "${GREEN}Installing dfu-util...${NC}"
                brew install dfu-util
                DFU_BIN="dfu-util"
            else
                exit 1
            fi
        fi
        
        # Verify installation succeeded
        if ! command -v "$DFU_BIN" &> /dev/null; then
            echo -e "${RED}[ERROR] Failed to install dfu-util.${NC}"
            exit 1
        fi
    else
        # Auto-install prompt for Debian/Ubuntu
        if command -v apt &> /dev/null; then
            read -p "Would you like to install dfu-util via apt now? (Requires sudo password) (y/n): " install_apt
            if [[ "$install_apt" =~ ^[Yy]$ ]]; then
                echo -e "${GREEN}Installing dfu-util...${NC}"
                sudo apt update && sudo apt install -y dfu-util
                DFU_BIN="dfu-util"
            else
                exit 1
            fi
            
            if ! command -v "$DFU_BIN" &> /dev/null; then
                echo -e "${RED}[ERROR] Failed to install dfu-util.${NC}"
                exit 1
            fi
        else
            echo "To install it on Debian/Ubuntu: sudo apt install dfu-util"
            echo "To install it on Fedora/RHEL:   sudo dnf install dfu-util"
            echo "To install it on Arch:          sudo pacman -S dfu-util"
            echo "To install it on openSUSE:      sudo zypper install dfu-util"
            echo ""
            read -p "Press Enter to exit..."
            exit 1
        fi
    fi
fi

# Auto-elevate on Linux/macOS if raw USB access is denied.
# Works on any Linux distro (glibc or musl) and on macOS.
# Linux normally requires root for raw USB unless a udev rule is in place;
# macOS usually does not, but we keep the same safety net for edge cases.
if [[ "$OSTYPE" == "linux"* || "$OSTYPE" == "darwin"* ]]; then
    if [ "$(id -u)" -ne 0 ] && command -v sudo &> /dev/null; then
        dfu_probe="$("$DFU_BIN" -l 2>&1)"
        if echo "$dfu_probe" | grep -qiE 'LIBUSB_ERROR_ACCESS|cannot open|permission denied|operation not permitted'; then
            echo -e "${YELLOW}[INFO] USB access is denied for the current user.${NC}"
            echo -e "${YELLOW}       Re-running this script with sudo...${NC}"
            echo -e "${YELLOW}       Tip (Linux): install a udev rule to avoid sudo next time (see README).${NC}"
            echo ""
            exec sudo -E -- "$0" "$@"
        fi
    fi
fi

# USB device / driver diagnostics.
# Returns 0 = DFU device ready, 1 = device present but driver/permission issue, 2 = not present at all.
detect_dfu_device() {
    if "$DFU_BIN" -l 2>&1 | grep -q "Found DFU"; then
        return 0
    fi
    case "$OSTYPE" in
        linux*)
            if command -v lsusb &> /dev/null && lsusb 2>/dev/null | grep -qi "0483:df11"; then
                return 1
            fi
            ;;
        darwin*)
            if command -v system_profiler &> /dev/null && system_profiler SPUSBDataType 2>/dev/null | grep -qi "0xdf11"; then
                return 1
            fi
            ;;
        msys*|cygwin*|win32*)
            if command -v pnputil.exe &> /dev/null && pnputil.exe /enum-devices 2>/dev/null | grep -qiE "DF11|STM32 BOOTLOADER"; then
                return 1
            fi
            ;;
    esac
    return 2
}

print_device_help() {
    case $1 in
        1)
            echo -e "${YELLOW}[WARN] STM32 DFU device is present on the USB bus but dfu-util cannot open it.${NC}"
            case "$OSTYPE" in
                msys*|cygwin*|win32*)
                    echo -e "       Windows: the WinUSB driver is most likely missing."
                    echo -e "       Fix: run ${GREEN}zadig-2.9.exe${NC} (bundled), select ${GREEN}STM32 BOOTLOADER${NC},"
                    echo -e "            target driver ${GREEN}WinUSB${NC}, then click Install Driver."
                    ;;
                linux*)
                    echo -e "       Linux: missing udev rule or insufficient permissions."
                    echo -e "       Fix: install the udev rule from README, or re-run with sudo."
                    ;;
                darwin*)
                    echo -e "       macOS: USB accessory access may be blocked."
                    echo -e "       Fix: System Settings > Privacy & Security > allow USB accessories."
                    ;;
            esac
            ;;
        2)
            echo -e "${YELLOW}[WARN] STM32 DFU device (VID:PID 0483:df11) was not detected on the USB bus.${NC}"
            echo -e "       Checklist:"
            echo -e "         - USB cable is connected"
            echo -e "         - Receiver is powered on"
            echo -e "         - Receiver is in DFU mode (Hold '1', turn on, wait 3s, release)"
            ;;
    esac
}

# Up-front check so the user gets a clear message before selecting firmware.
detect_dfu_device
device_state=$?
if [ $device_state -ne 0 ]; then
    print_device_help $device_state
    echo ""
    read -p "Press Enter to retry detection, or Ctrl+C to abort..."
    detect_dfu_device
    device_state=$?
    if [ $device_state -ne 0 ]; then
        echo -e "${RED}[ERROR] DFU device still not ready. Aborting.${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}[OK] DFU device detected and ready.${NC}"
echo ""

# Find all .bin files
bin_files=("$DIR"/*.bin)
valid_files=()
count=0
for file in "${bin_files[@]}"; do
    if [ -f "$file" ]; then
        valid_files+=("$file")
        count=$((count+1))
    fi
done

if [ "$count" -eq 0 ]; then
    echo -e "${RED}[ERROR] No .bin firmware files found!${NC}"
    exit 1
fi

echo -e "${GREEN}Available firmware files:${NC}"
echo "---------------------------------------------------"
i=1
for file in "${valid_files[@]}"; do
    filename=$(basename "$file")
    if [[ "$OSTYPE" == "darwin"* ]]; then
        filesize=$(stat -f%z "$file" 2>/dev/null)
    else
        filesize=$(stat -c%s "$file" 2>/dev/null)
    fi
    echo -e "  [$i] $filename (${YELLOW}$((filesize/1024)) KB${NC})"
    i=$((i+1))
done
echo "---------------------------------------------------"
echo ""

read -p "Select a firmware to flash (1-$count): " choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$count" ]; then
    echo -e "${RED}[ERROR] Invalid selection!${NC}"
    exit 1
fi

selected_file="${valid_files[$choice-1]}"
selected_filename=$(basename "$selected_file")

echo -e "\n${YELLOW}Selected: $selected_filename${NC}"
echo "1. Connect USB."
echo "2. Put receiver into DFU mode (Hold '1', turn on, wait 3s)."
echo ""
read -p "Press Enter when ready to flash..."

echo -e "\n${YELLOW}===================================================${NC}"
echo -e "${YELLOW}FLASHING... (Please wait 5-15 seconds)${NC}"
echo -e "${YELLOW}DO NOT DISCONNECT!${NC}"
echo -e "${YELLOW}===================================================${NC}"

# Execute flashing command and capture both stdout/stderr while still showing them live.
# We need the captured output to detect the real success even when dfu-util returns
# a non-zero exit code due to the device rebooting right after `:leave`.
DFU_LOG="$(mktemp 2>/dev/null || echo "/tmp/dfu_log.$$")"
"$DFU_BIN" -a 0 -s 0x08000000:force:leave -D "$selected_file" 2>&1 | tee "$DFU_LOG"
RESULT=${PIPESTATUS[0]}

# A successful flash is indicated by "File downloaded successfully" in the dfu-util output.
# After that, dfu-util sends a `leave` request, the device immediately resets and detaches
# from USB, and dfu-util reports `Error during download get_status` and exits with 74.
# This is expected behaviour, not a real failure.
if grep -q "File downloaded successfully" "$DFU_LOG"; then
    echo -e "\n${GREEN}===================================================${NC}"
    echo -e " [SUCCESS] Firmware flashed successfully!"
    echo -e " The receiver should reboot automatically."
    echo -e "${GREEN}===================================================${NC}"
    RESULT=0
else
    echo -e "\n${RED}[ERROR] Flashing failed with exit code $RESULT${NC}"
    if [[ "$OSTYPE" == "linux"* ]]; then
        echo -e "${YELLOW}Hint:${NC} Check your udev rules (see README.md)"
    fi
fi
rm -f "$DFU_LOG"

echo ""
read -p "Press Enter to exit..."
