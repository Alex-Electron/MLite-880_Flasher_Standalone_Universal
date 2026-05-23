#!/bin/bash

# ===================================================
#  Malachite DSP Firmware Flasher for macOS / Linux
#  Created by: Alexander Lavrinovich
#  GitHub: https://github.com/Alex-Electron
#  Email: EU1L@mail.ru
# ===================================================

echo "==================================================="
echo "            Malachite DSP Flasher v1.0.1"
echo ""
echo "  Developed by: Alexander Lavrinovich"
echo "  GitHub:       https://github.com/Alex-Electron"
echo "  Email:        EU1L@mail.ru"
echo "==================================================="
echo ""

# Check if dfu-util is installed
if ! command -v dfu-util &> /dev/null; then
    echo "[ERROR] dfu-util is not installed."
    echo "To install it on macOS, open Terminal and run:"
    echo "  brew install dfu-util"
    echo ""
    echo "To install on Ubuntu/Debian, run:"
    echo "  sudo apt install dfu-util"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

# Get the directory where the script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Find all .bin files in the script directory
bin_files=("$DIR"/*.bin)
count=0

for file in "${bin_files[@]}"; do
    if [ -f "$file" ]; then
        count=$((count+1))
    fi
done

if [ "$count" -eq 0 ]; then
    echo "[ERROR] No .bin firmware files found in this folder!"
    echo "Please place your .bin files here: $DIR"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

echo "Available firmware files:"
echo "---------------------------------------------------"
i=1
for file in "${bin_files[@]}"; do
    filename=$(basename "$file")
    echo "  [$i] $filename"
    i=$((i+1))
done
echo "---------------------------------------------------"
echo ""

read -p "Select a firmware to flash (1-$count): " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$count" ]; then
    echo ""
    echo "[ERROR] Invalid selection! Please enter a number from 1 to $count."
    read -p "Press Enter to exit..."
    exit 1
fi

selected_file="${bin_files[$((choice-1))]}"
selected_filename=$(basename "$selected_file")

echo ""
echo "==================================================="
echo "Selected firmware: $selected_filename"
echo "==================================================="
echo ""
echo "1. Connect the receiver via USB."
echo "2. Put the receiver into DFU mode:"
echo "   (Press and hold 1, turn on radio, wait 3s, release 1)"
echo ""
read -p "Press Enter when ready..."

echo ""
echo "==================================================="
echo "Starting flash process (Mass Erase -> Download)..."
echo "Please DO NOT disconnect the cable!"
echo "==================================================="
echo ""

# Run dfu-util
dfu-util -a 0 -s 0x08000000:mass-erase:force:leave -D "$selected_file"

echo ""
echo "==================================================="
echo " [DONE] The flashing process has finished."
echo ""
echo " * Note: If you see 'Error during download get_status'"
echo "   above, it is completely NORMAL and means SUCCESS."
echo "   It just means the receiver rebooted successfully."
echo "==================================================="
echo ""
read -p "Press Enter to exit..."



