# 🚀 Quick Start Guide - NotesApp iOS

This guide will help you set up and run the iOS app in just a few steps.

## Prerequisites

- Mac with macOS 12.0 or later
- Xcode 14.0 or later installed
- Firebase project (same one used for web app)
- Supabase project (same one used for web app)

## Setup Steps

### Option A: Automated Setup (Recommended)

1. **Install CocoaPods** (if not already installed):
   ```bash
   sudo gem install cocoapods
   ```

2. **Run the setup script**:
   ```bash
   cd NotesApp-iOS
   ./generate-xcode-project.sh
   ```

3. **Follow the on-screen instructions** to complete configuration

4. **Open the workspace**:
   ```bash
   open NotesApp-iOS.xcworkspace
   ```

### Option B: Manual Setup (If CocoaPods unavailable)

#### Step 1: Create Xcode Project Manually

1. Open Xcode
2. Click **File → New → Project**
3. Select **iOS → App**
4. Configure:
   - Product Name: `NotesApp-iOS`
   - Organization Identifier: `com.notesapp`
   - Interface: **Storyboard** (we'll use programmatic UI)
   - Language: **Swift**
   - Uncheck "Use Core Data" and "Include Tests"
5. Save in the `NotesApp-iOS` folder

#### Step 2: Add Source Files

1. Delete the default `ViewController.swift` and `Main.storyboard`
2. Drag the following folders into your project:
   - `NotesApp-iOS/Models/`
   - `NotesApp-iOS/Services/`
   - `NotesApp-iOS/ViewControllers/`
   - `NotesApp-iOS/Config/`
3. Replace `AppDelegate.swift` and `SceneDelegate.swift` with the provided versions
4. Make sure "Copy items if needed" is checked
5. Make sure the target is selected

#### Step 3: Add Dependencies via Swift Package Manager

In Xcode:

1. Go to **File → Add Packages...**

2. Add **Firebase**:
   - URL: `https://github.com/firebase/firebase-ios-sdk.git`
   - Version: 10.0.0 or later
   - Select packages: `FirebaseAuth`, `FirebaseCore`

3. Add **Google Sign-In**:
   - URL: `https://github.com/google/GoogleSignIn-iOS.git`
   - Version: 7.0.0 or later

4. Add **Supabase**:
   - URL: `https://github.com/supabase-community/supabase-swift.git`
   - Version: 2.0.0 or later
   - Select: `Supabase`

#### Step 4: Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your Notes App project
3. Click ⚙️ → **Project Settings**
4. Scroll to **Your apps** → Select iOS app (or add new iOS app)
5. Download `GoogleService-Info.plist`
6. Drag `GoogleService-Info.plist` into Xcode project root
7. Check **"Copy items if needed"** and select target

#### Step 5: Configure URL Schemes

1. In Xcode, select your project in the navigator
2. Select the **NotesApp-iOS** target
3. Go to **Info** tab
4. Expand **URL Types**
5. Click **+** to add a new URL Type
6. Set **URL Schemes** to your `REVERSED_CLIENT_ID` from `GoogleService-Info.plist`
   - Example: `com.googleusercontent.apps.123456789`

#### Step 6: Configure Supabase

1. Open `NotesApp-iOS/Config/SupabaseConfig.swift`
2. Replace placeholders:
   ```swift
   static let url = "https://your-project.supabase.co"
   static let anonKey = "your-anon-key-here"
   ```
3. Get these values from Supabase Dashboard → Settings → API

#### Step 7: Configure Info.plist

Add the following keys to `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

#### Step 8: Build and Run

1. Select a simulator or device
2. Press **Cmd + R** or click ▶️ Run
3. App should build and launch

## Troubleshooting

### "Firebase module not found"

**Solution:**
- Make sure you added Firebase via Swift Package Manager
- Clean build folder: **Product → Clean Build Folder** (Cmd + Shift + K)
- Rebuild: **Product → Build** (Cmd + B)

### "GoogleService-Info.plist not found"

**Solution:**
- Download from Firebase Console
- Make sure it's in the project root
- Check that it's included in the target (select file → File Inspector → Target Membership)

### "Google Sign-In fails"

**Solution:**
- Verify `GoogleService-Info.plist` is correct
- Check URL Schemes in Info.plist match `REVERSED_CLIENT_ID`
- Make sure Google Sign-In is enabled in Firebase Console → Authentication

### "Supabase connection fails"

**Solution:**
- Verify `SupabaseConfig.swift` has correct URL and key
- Check network connection
- Verify Supabase RLS policies allow access

### "Missing file errors"

**Solution:**
- Make sure all Swift files are in the correct folders
- Check that files are added to the target
- Rebuild the project

## Testing the App

### 1. Sign In
- Launch app
- Tap "Sign in with Google"
- Select your Google account
- Grant permissions

### 2. View Premium Status
- Tap the profile icon (top right)
- Check if you're Premium or Free
- Premium users see ⭐ in navigation bar

### 3. Create a Note
- Tap **+** button
- Enter title and content
- Optionally attach files with 📎 button
- Tap **Save**

### 4. Edit a Note
- Tap on any note
- Modify content
- Tap **Save**

### 5. Delete a Note
- Swipe left on a note
- Tap **Delete**

## File Structure Reference

```
NotesApp-iOS/
├── NotesApp-iOS/
│   ├── AppDelegate.swift                   ← App lifecycle
│   ├── SceneDelegate.swift                 ← Scene management
│   ├── Models/
│   │   └── Note.swift                      ← Data models
│   ├── Services/
│   │   ├── AuthService.swift               ← Firebase auth
│   │   └── SupabaseService.swift           ← Database & storage
│   ├── ViewControllers/
│   │   ├── LoginViewController.swift       ← Login screen
│   │   ├── NotesListViewController.swift   ← Notes list
│   │   └── NoteDetailViewController.swift  ← Create/edit note
│   ├── Config/
│   │   └── SupabaseConfig.swift            ← Supabase config
│   ├── Info.plist                          ← App config
│   └── GoogleService-Info.plist            ← Firebase config (add this)
├── Podfile                                  ← CocoaPods deps (if using)
├── README.md                                ← Full documentation
└── QUICKSTART.md                            ← This file
```

## Configuration Checklist

Before building, verify:

- [ ] Firebase project created and iOS app added
- [ ] `GoogleService-Info.plist` downloaded and added to project
- [ ] URL Schemes configured with `REVERSED_CLIENT_ID`
- [ ] Google Sign-In enabled in Firebase Console
- [ ] `SupabaseConfig.swift` updated with correct URL and key
- [ ] All Swift files added to project target
- [ ] Dependencies added (Firebase, GoogleSignIn, Supabase)
- [ ] Build succeeds without errors

## Next Steps

Once the app is running:

1. **Test authentication** - Sign in with your Google account
2. **Create test notes** - Verify sync with web app
3. **Test file uploads** - Attach images or documents
4. **Check premium status** - Upgrade on web, verify in app
5. **Test offline behavior** - Turn off network, verify error handling

## Getting Help

If you encounter issues:

1. Check **Xcode console output** for error messages
2. Verify **Firebase Console** for authentication logs
3. Check **Supabase Dashboard** for database/storage logs
4. Review the **README.md** for detailed documentation

## Production Checklist

Before releasing:

- [ ] Update bundle identifier to your own
- [ ] Configure proper provisioning profile
- [ ] Add app icon and launch screen
- [ ] Test on physical devices
- [ ] Configure Firebase for production
- [ ] Review and test all error scenarios
- [ ] Add analytics (optional)
- [ ] Submit for App Store review

---

**Happy Coding! 🎉**

For detailed API documentation and advanced features, see [README.md](README.md)

