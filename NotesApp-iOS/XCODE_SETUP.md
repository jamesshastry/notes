# 🍎 Xcode Project Setup Instructions

Since CocoaPods is not currently installed and we need to create the `.xcodeproj` file, follow these steps to set up the project in Xcode.

## Quick Setup (5-10 minutes)

### Step 1: Create New Xcode Project

1. **Open Xcode**

2. **File → New → Project**

3. **Select Template:**
   - Choose **iOS** tab
   - Select **App** template
   - Click **Next**

4. **Configure Project:**
   - **Product Name:** `NotesApp-iOS`
   - **Team:** Select your team (or leave as None)
   - **Organization Identifier:** `com.notesapp` (or your own)
   - **Bundle Identifier:** Will auto-fill as `com.notesapp.NotesApp-iOS`
   - **Interface:** **Storyboard** (we'll delete it)
   - **Language:** **Swift**
   - **Uncheck** "Use Core Data"
   - **Uncheck** "Include Tests"
   - Click **Next**

5. **Save Location:**
   - Navigate to: `/Users/jamespaul/Documents/Projects/notes/`
   - **IMPORTANT:** Save it as `NotesApp-iOS` (same name as existing folder)
   - Xcode will ask if you want to merge - click **Merge**
   - This will create the `.xcodeproj` file in the existing folder

### Step 2: Clean Up Default Files

In Xcode Project Navigator:

1. **Delete** these files (Move to Trash):
   - `ViewController.swift`
   - `Main.storyboard`

2. **Keep** these files:
   - `AppDelegate.swift` (we'll replace it)
   - `SceneDelegate.swift` (we'll replace it)
   - `Assets.xcassets`
   - `LaunchScreen.storyboard`
   - `Info.plist` (we'll modify it)

### Step 3: Add Source Files

1. **In Finder**, open: `/Users/jamespaul/Documents/Projects/notes/NotesApp-iOS/NotesApp-iOS/`

2. **Drag these folders** into Xcode Project Navigator (into the `NotesApp-iOS` group):
   - `Models/` folder
   - `Services/` folder
   - `ViewControllers/` folder
   - `Config/` folder

3. **When prompted**, make sure:
   - ✅ **"Copy items if needed"** is CHECKED
   - ✅ **"Create groups"** is selected
   - ✅ **NotesApp-iOS target** is checked
   - Click **Finish**

4. **Replace default files:**
   - Open the new `AppDelegate.swift` and `SceneDelegate.swift` from the dragged folders
   - Copy their contents
   - Replace the default `AppDelegate.swift` and `SceneDelegate.swift` at the root

### Step 4: Update Info.plist

1. **Select** `Info.plist` in Project Navigator

2. **Remove** the "Main storyboard file base name" entry:
   - Find `UIApplicationSceneManifest` → `UISceneConfigurations` → `UIWindowSceneSessionRoleApplication`
   - Remove `UISceneStoryboardFile` key (if present)

3. **Add URL Scheme** (for Google Sign-In):
   - Right-click Info.plist → **Open As** → **Source Code**
   - Find `</dict>` before `</plist>`
   - Add this before it:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>notesapp</string>
           </array>
       </dict>
   </array>
   ```

### Step 5: Add Dependencies via Swift Package Manager

1. **File → Add Packages...**

2. **Add Firebase:**
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Click **Add Package**
   - Select: **FirebaseAuth** and **FirebaseCore**
   - Click **Add Package**

3. **Add Google Sign-In:**
   - **File → Add Packages...**
   - URL: `https://github.com/google/GoogleSignIn-iOS`
   - Click **Add Package**
   - Select: **GoogleSignIn**
   - Click **Add Package**

4. **Add Supabase:**
   - **File → Add Packages...**
   - URL: `https://github.com/supabase-community/supabase-swift`
   - Click **Add Package**
   - Select: **Supabase**
   - Click **Add Package**

### Step 6: Configure Firebase

1. **Download GoogleService-Info.plist:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Click ⚙️ → **Project Settings**
   - Scroll to **Your apps** section
   - Click on your iOS app (or **Add app** if you haven't created one)
   - Download `GoogleService-Info.plist`

2. **Add to Xcode:**
   - Drag `GoogleService-Info.plist` into Xcode Project Navigator
   - ✅ Check **"Copy items if needed"**
   - ✅ Check **NotesApp-iOS target**
   - Click **Finish**

3. **Update URL Scheme:**
   - Open `GoogleService-Info.plist` in Xcode
   - Find `REVERSED_CLIENT_ID` value (example: `com.googleusercontent.apps.123456789`)
   - Copy this value
   - Go to **Project Settings** → **NotesApp-iOS target** → **Info** tab
   - Find **URL Types** section
   - Replace `notesapp` with your `REVERSED_CLIENT_ID`

### Step 7: Configure Supabase

1. **Open** `Config/SupabaseConfig.swift`

2. **Replace** the placeholders:
   ```swift
   static let url = "https://your-project-id.supabase.co"
   static let anonKey = "your-actual-anon-key"
   ```

3. **Get these values** from:
   - [Supabase Dashboard](https://app.supabase.com/)
   - Select your project
   - **Settings** → **API**
   - Copy **Project URL** and **anon/public key**

### Step 8: Build and Run

1. **Select target device:**
   - Click the device selector in toolbar
   - Choose **iPhone 15 Pro** (or any simulator)

2. **Build the project:**
   - Press **Cmd + B**
   - Wait for build to complete
   - Fix any errors if they appear

3. **Run the app:**
   - Press **Cmd + R**
   - App should launch in simulator

## Troubleshooting

### Build Errors

**"Cannot find 'Firebase' in scope"**
```
Solution: Clean build folder (Cmd + Shift + K), then rebuild (Cmd + B)
```

**"No such module 'Supabase'"**
```
Solution: 
1. File → Packages → Resolve Package Versions
2. Clean build folder
3. Rebuild
```

**"GoogleService-Info.plist not found"**
```
Solution:
1. Download from Firebase Console
2. Make sure it's in project root
3. Check Target Membership in File Inspector
```

### Runtime Errors

**"Failed to initialize Firebase"**
```
Solution: Verify GoogleService-Info.plist is correctly configured and added to target
```

**"Google Sign-In failed"**
```
Solution:
1. Check URL Schemes match REVERSED_CLIENT_ID
2. Enable Google Sign-In in Firebase Console → Authentication
3. Verify bundle identifier matches Firebase configuration
```

**"Supabase connection failed"**
```
Solution:
1. Verify SupabaseConfig.swift has correct URL and key
2. Check internet connection
3. Verify Supabase project is active
```

## Alternative: Using CocoaPods

If you prefer CocoaPods and have it installed:

```bash
cd NotesApp-iOS
pod install
open NotesApp-iOS.xcworkspace
```

Then skip the Swift Package Manager steps and use the workspace file instead.

## Verification Checklist

Before running, verify:

- [x] Xcode project created in correct location
- [x] All Swift files added to project
- [x] Dependencies added (Firebase, GoogleSignIn, Supabase)
- [x] `GoogleService-Info.plist` downloaded and added
- [x] URL Schemes configured
- [x] `SupabaseConfig.swift` updated
- [x] Info.plist configured (no storyboard reference)
- [x] Project builds without errors
- [x] App launches in simulator

## Next Steps

Once the app is running:

1. Test Google Sign-In
2. Create a test note
3. Verify sync with web app
4. Test file attachments
5. Check premium status display

## Need Help?

Check these resources:

- **QUICKSTART.md** - Quick setup guide
- **README.md** - Full documentation
- **FILES_CREATED.md** - Project structure
- **Xcode Console** - Error messages
- **Firebase Console** - Auth logs
- **Supabase Dashboard** - Database logs

---

**⏱ Estimated Time:** 5-10 minutes
**📱 Platform:** iOS 15.0+
**🔧 Tool:** Xcode 14.0+

