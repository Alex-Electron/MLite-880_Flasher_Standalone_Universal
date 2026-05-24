#!/bin/bash

# ===================================================
#  macOS Cleanup Script for Testing
#  Removes dfu-util and Homebrew
# ===================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}===================================================${NC}"
echo -e "${YELLOW}            macOS Environment Cleanup              ${NC}"
echo -e "${YELLOW}===================================================${NC}"
echo ""

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}[ERROR] This script is only intended for macOS.${NC}"
    exit 1
fi

# 1. Uninstall dfu-util
if command -v dfu-util &> /dev/null; then
    echo -e "${YELLOW}dfu-util is installed. Removing it...${NC}"
    if command -v brew &> /dev/null; then
        brew uninstall dfu-util
        echo -e "${GREEN}[OK] dfu-util uninstalled.${NC}"
    else
        echo -e "${RED}[ERROR] Homebrew is not installed, cannot uninstall dfu-util automatically.${NC}"
    fi
else
    echo -e "${GREEN}[INFO] dfu-util is not installed.${NC}"
fi

echo ""

# 2. Uninstall Homebrew
if command -v brew &> /dev/null; then
    read -p "Are you sure you want to completely UNINSTALL Homebrew? This will remove all packages installed via brew. (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Uninstalling Homebrew...${NC}"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
        
        # Cleanup remaining directories
        echo -e "${YELLOW}Cleaning up remaining Homebrew directories...${NC}"
        if [ -d "/opt/homebrew" ]; then
            sudo rm -rf /opt/homebrew
        fi
        if [ -d "/usr/local/Homebrew" ]; then
            sudo rm -rf /usr/local/Homebrew
        fi
        echo -e "${GREEN}[OK] Homebrew completely removed.${NC}"
    else
        echo -e "${GREEN}[INFO] Skipping Homebrew uninstallation.${NC}"
    fi
else
    echo -e "${GREEN}[INFO] Homebrew is not installed.${NC}"
fi

echo ""
echo -e "${GREEN}Cleanup complete! Your Mac is clean for the next test.${NC}"
