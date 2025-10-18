#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}    🔧 Package Resolution Fix Script${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PROJECT_DIR="/Users/jamespaul/Documents/Projects/notes/NotesIOSApp"
cd "$PROJECT_DIR"

# Step 1: Close Xcode
echo -e "${YELLOW}Step 1: Closing Xcode...${NC}"
osascript -e 'quit app "Xcode"' 2>/dev/null
sleep 2
killall Xcode 2>/dev/null
sleep 1
echo -e "${GREEN}✓ Xcode closed${NC}"
echo ""

# Step 2: Clean all caches
echo -e "${YELLOW}Step 2: Cleaning all package caches...${NC}"
rm -rf ~/Library/Caches/org.swift.swiftpm 2>/dev/null
rm -rf ~/Library/Developer/Xcode/DerivedData/NotesIOSApp-* 2>/dev/null
rm -rf "$PROJECT_DIR/.swiftpm" 2>/dev/null
rm -rf "$PROJECT_DIR/NotesIOSApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm" 2>/dev/null
echo -e "${GREEN}✓ Caches cleared${NC}"
echo ""

# Step 3: Create fresh package directory
echo -e "${YELLOW}Step 3: Creating fresh package workspace...${NC}"
mkdir -p "$PROJECT_DIR/NotesIOSApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm"
echo -e "${GREEN}✓ Workspace prepared${NC}"
echo ""

# Step 4: Remove Package.resolved to force fresh resolution
echo -e "${YELLOW}Step 4: Removing old Package.resolved...${NC}"
rm -f "$PROJECT_DIR/NotesIOSApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" 2>/dev/null
echo -e "${GREEN}✓ Old package metadata removed${NC}"
echo ""

# Step 5: Reopen Xcode
echo -e "${YELLOW}Step 5: Opening Xcode...${NC}"
open "$PROJECT_DIR/NotesIOSApp.xcodeproj"
echo -e "${GREEN}✓ Xcode opened${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo ""
echo -e "${YELLOW}⏳ Now wait for Xcode to automatically resolve packages...${NC}"
echo ""
echo -e "${BLUE}What to watch for in Xcode:${NC}"
echo -e "  1. Look at the TOP of the Xcode window"
echo -e "  2. You should see: ${YELLOW}\"Fetching firebase-ios-sdk\"${NC}"
echo -e "  3. Then: ${YELLOW}\"Fetching GoogleSignIn-iOS\"${NC}"
echo -e "  4. Then: ${YELLOW}\"Fetching supabase-swift\"${NC}"
echo -e "  5. Wait 2-5 minutes for download to complete"
echo ""
echo -e "${BLUE}If packages STILL don't appear after 5 minutes:${NC}"
echo -e "  In Xcode menu: ${YELLOW}File → Packages → Resolve Package Versions${NC}"
echo ""
echo -e "${GREEN}The errors should disappear once packages finish downloading!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

