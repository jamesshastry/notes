#!/bin/bash

echo "🚀 Generating Xcode Project for NotesApp-iOS"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if in correct directory
if [ ! -f "Podfile" ]; then
    echo "${RED}❌ Error: Podfile not found${NC}"
    echo "Please run this script from the NotesApp-iOS directory"
    exit 1
fi

echo "📦 Step 1: Installing CocoaPods dependencies..."
echo ""

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "${RED}❌ CocoaPods is not installed${NC}"
    echo "Install it with: sudo gem install cocoapods"
    exit 1
fi

# Install pods
pod install

if [ $? -ne 0 ]; then
    echo "${RED}❌ Failed to install CocoaPods dependencies${NC}"
    exit 1
fi

echo ""
echo "${GREEN}✅ Successfully installed CocoaPods dependencies${NC}"
echo ""
echo "📋 Step 2: Project Setup Complete"
echo ""
echo "${YELLOW}⚠️  IMPORTANT NEXT STEPS:${NC}"
echo ""
echo "1. ${GREEN}Download GoogleService-Info.plist${NC} from Firebase Console"
echo "   - Go to: https://console.firebase.google.com/"
echo "   - Select your project → Project Settings → Your apps (iOS)"
echo "   - Download the file"
echo ""
echo "2. ${GREEN}Add GoogleService-Info.plist to Xcode:${NC}"
echo "   - Open NotesApp-iOS.xcworkspace (NOT .xcodeproj)"
echo "   - Drag GoogleService-Info.plist into the project"
echo "   - Make sure 'Copy items if needed' is checked"
echo ""
echo "3. ${GREEN}Configure Supabase:${NC}"
echo "   - Edit NotesApp-iOS/Services/SupabaseService.swift"
echo "   - Replace YOUR_SUPABASE_URL with your actual URL"
echo "   - Replace YOUR_SUPABASE_ANON_KEY with your actual key"
echo ""
echo "4. ${GREEN}Open the workspace:${NC}"
echo "   - Run: open NotesApp-iOS.xcworkspace"
echo "   - Build and run the app (Cmd + R)"
echo ""
echo "${GREEN}✅ Setup complete!${NC}"
echo ""

