#!/bin/bash

# Xcode 15.4 Installation Helper Script
# This script helps you install and configure Xcode 15.4 alongside Xcode 26

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}    📥 Xcode 15.4 Installation Helper${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check current Xcode version
echo -e "${YELLOW}Current Xcode version:${NC}"
xcodebuild -version
echo ""

# Check if Xcode 15 already exists
if [ -d "/Applications/Xcode-15.app" ]; then
    echo -e "${GREEN}✓ Xcode 15 is already installed!${NC}"
    echo ""
    read -p "Do you want to switch to Xcode 15? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo xcode-select --switch /Applications/Xcode-15.app/Contents/Developer
        echo -e "${GREEN}✓ Switched to Xcode 15${NC}"
        xcodebuild -version
    fi
    exit 0
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 1: Download Xcode 15.4${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}You need to download Xcode 15.4 from Apple:${NC}"
echo ""
echo -e "1. Open this link in your browser:"
echo -e "   ${BLUE}https://developer.apple.com/download/all/${NC}"
echo ""
echo -e "2. Sign in with your Apple ID"
echo ""
echo -e "3. Search for: ${GREEN}Xcode 15.4${NC}"
echo ""
echo -e "4. Download: ${GREEN}Xcode_15.4.xip${NC} (~8 GB file)"
echo ""
echo -e "5. The file will download to your Downloads folder"
echo ""
echo -e "${YELLOW}This will take 10-30 minutes depending on your internet speed.${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Press Enter once the download is complete (check ~/Downloads/Xcode_15.4.xip)..." 

# Check if file exists
XIP_FILE="$HOME/Downloads/Xcode_15.4.xip"
if [ ! -f "$XIP_FILE" ]; then
    echo -e "${RED}✗ Cannot find Xcode_15.4.xip in Downloads folder${NC}"
    echo -e "${YELLOW}Expected location: $XIP_FILE${NC}"
    echo ""
    echo -e "Please make sure you downloaded Xcode_15.4.xip to your Downloads folder."
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Found Xcode_15.4.xip${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 2: Extract Xcode (this takes 5-10 minutes)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Extracting Xcode_15.4.xip...${NC}"
echo -e "${YELLOW}(This is a large file, please be patient)${NC}"
echo ""

cd ~/Downloads
xip -x Xcode_15.4.xip

if [ ! -d "~/Downloads/Xcode.app" ]; then
    echo -e "${RED}✗ Extraction failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Extraction complete!${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 3: Rename and Move to Applications${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Rename current Xcode.app to Xcode-26.app
if [ -d "/Applications/Xcode.app" ]; then
    echo -e "${YELLOW}Renaming current Xcode.app to Xcode-26.app...${NC}"
    sudo mv /Applications/Xcode.app /Applications/Xcode-26.app
    echo -e "${GREEN}✓ Renamed to Xcode-26.app${NC}"
    echo ""
fi

# Move new Xcode to Applications as Xcode-15.app
echo -e "${YELLOW}Moving Xcode 15.4 to /Applications/Xcode-15.app...${NC}"
sudo mv ~/Downloads/Xcode.app /Applications/Xcode-15.app
echo -e "${GREEN}✓ Moved to Applications${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 4: Accept License and Install Components${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

sudo xcode-select --switch /Applications/Xcode-15.app/Contents/Developer
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch

echo ""
echo -e "${GREEN}✓ License accepted and components installed${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Step 5: Verify Installation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Active Xcode version:${NC}"
xcodebuild -version
echo ""

echo -e "${YELLOW}Available Xcode versions:${NC}"
ls -la /Applications/ | grep Xcode
echo ""

# Clean up
echo -e "${YELLOW}Cleaning up...${NC}"
rm -f ~/Downloads/Xcode_15.4.xip
echo -e "${GREEN}✓ Deleted Xcode_15.4.xip from Downloads${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Installation Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}You now have both Xcode versions installed:${NC}"
echo -e "  • ${GREEN}Xcode 15.4${NC} - Active (use for this project)"
echo -e "  • ${YELLOW}Xcode 26.0${NC} - Available at /Applications/Xcode-26.app"
echo ""
echo -e "${BLUE}To switch between versions:${NC}"
echo -e "  ${YELLOW}Xcode 15:${NC} sudo xcode-select --switch /Applications/Xcode-15.app/Contents/Developer"
echo -e "  ${YELLOW}Xcode 26:${NC} sudo xcode-select --switch /Applications/Xcode-26.app/Contents/Developer"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo -e "  1. Open NotesIOSApp.xcodeproj"
echo -e "  2. Add packages through GUI (will work now!)"
echo -e "  3. Build and run"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

