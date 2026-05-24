#!/bin/bash

# ===================================================
#  Malachite DSP Firmware Flasher for macOS / Linux
#  v1.2.1 - Universal Stable Edition
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
echo -e "${BLUE}            Malachite DSP Flasher v1.2.1           ${NC}"
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
    echo "To install it on macOS: brew install dfu-util"
    echo "To install on Ubuntu:   sudo apt install dfu-util"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

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

# Execute flashing command
"$DFU_BIN" -a 0 -s 0x08000000:force:leave -D "$selected_file"
RESULT=$?

if [ $RESULT -eq 0 ] || [ $RESULT -eq 1 ]; then
    echo -e "\n${GREEN}===================================================${NC}"
    echo -e " [SUCCESS] Firmware flashed successfully!"
    echo -e " The receiver should reboot automatically."
    echo -e "${GREEN}===================================================${NC}"
else
    echo -e "\n${RED}[ERROR] Flashing failed with exit code $RESULT${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${YELLOW}Hint:${NC} Check your udev rules (see README.md)"
    fi
fi

echo ""
read -p "Press Enter to exit..."
