#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}    📱 Notes iOS App - Dependency Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PROJECT_PATH="/Users/jamespaul/Documents/Projects/notes/NotesIOSApp/NotesIOSApp.xcodeproj"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"

# Check if project exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}❌ Error: Project not found at $PROJECT_PATH${NC}"
    exit 1
fi

# Open Xcode project
echo -e "${GREEN}🚀 Opening Xcode project...${NC}"
open "$PROJECT_PATH"
sleep 3

echo ""
echo -e "${YELLOW}⏳ Waiting for Xcode to start package resolution...${NC}"
echo -e "${YELLOW}   (This may take a few seconds)${NC}"
echo ""
sleep 5

# Monitor package resolution
echo -e "${BLUE}📦 Monitoring dependency downloads:${NC}"
echo ""

PACKAGES_TO_DOWNLOAD=("firebase-ios-sdk" "supabase-swift" "GoogleSignIn-iOS")
DOWNLOAD_COMPLETE=0
MAX_WAIT=600  # 10 minutes max
ELAPSED=0
CHECK_INTERVAL=3

while [ $ELAPSED -lt $MAX_WAIT ]; do
    FOUND_COUNT=0
    
    # Check if packages are being downloaded/resolved
    if [ -d "$HOME/Library/Caches/org.swift.swiftpm" ]; then
        for package in "${PACKAGES_TO_DOWNLOAD[@]}"; do
            if find "$HOME/Library/Caches/org.swift.swiftpm" -name "*$package*" 2>/dev/null | grep -q .; then
                if [ $ELAPSED -eq 0 ] || [ $((ELAPSED % 15)) -eq 0 ]; then
                    echo -e "  ${GREEN}✓${NC} $package - downloading/cached"
                fi
                ((FOUND_COUNT++))
            fi
        done
    fi
    
    # Check DerivedData for compiled packages
    if [ -d "$DERIVED_DATA" ]; then
        DERIVED_PROJECT=$(find "$DERIVED_DATA" -maxdepth 1 -name "NotesIOSApp-*" 2>/dev/null | head -1)
        if [ -n "$DERIVED_PROJECT" ]; then
            if [ -d "$DERIVED_PROJECT/SourcePackages" ]; then
                PACKAGE_COUNT=$(find "$DERIVED_PROJECT/SourcePackages" -type d -name "*.git" 2>/dev/null | wc -l | tr -d ' ')
                if [ $PACKAGE_COUNT -ge 3 ]; then
                    echo ""
                    echo -e "${GREEN}✅ All packages downloaded and resolved!${NC}"
                    DOWNLOAD_COMPLETE=1
                    break
                fi
            fi
        fi
    fi
    
    # Show progress indicator
    if [ $((ELAPSED % 15)) -eq 0 ] && [ $ELAPSED -gt 0 ]; then
        echo -e "${BLUE}⏱  Still downloading... ($ELAPSED seconds elapsed)${NC}"
    fi
    
    sleep $CHECK_INTERVAL
    ((ELAPSED += CHECK_INTERVAL))
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $DOWNLOAD_COMPLETE -eq 1 ]; then
    echo -e "${GREEN}🎉 Dependencies installed successfully!${NC}"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo -e "  1. Configure Firebase (GoogleService-Info.plist)"
    echo -e "  2. Configure Supabase (SupabaseManager.swift)"
    echo -e "  3. Update Info.plist with OAuth client ID"
    echo -e "  4. Build and run (Cmd + R in Xcode)"
    echo ""
    echo -e "${BLUE}📖 Read GETTING_STARTED.md for detailed instructions${NC}"
else
    echo -e "${YELLOW}⏳ Package resolution in progress...${NC}"
    echo ""
    echo -e "${YELLOW}What to check in Xcode:${NC}"
    echo -e "  • Look at top of Xcode window for 'Fetching...' message"
    echo -e "  • Package resolution can take 2-5 minutes"
    echo -e "  • Check File > Packages > Package Dependencies"
    echo ""
    echo -e "${YELLOW}If packages don't appear after 5 minutes:${NC}"
    echo -e "  • Xcode > File > Packages > Reset Package Caches"
    echo -e "  • Xcode > File > Packages > Resolve Package Versions"
    echo -e "  • Restart Xcode and try again"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Keep terminal open
echo -e "${BLUE}Press Enter to close this window...${NC}"
read

