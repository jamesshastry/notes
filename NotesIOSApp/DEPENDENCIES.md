# iOS App Dependencies

## Automatic Dependency Management

This project uses **Swift Package Manager (SPM)** which is built into Xcode. **All dependencies will be automatically downloaded when you open the project in Xcode for the first time.**

## What Dependencies Are Included?

### 1. Firebase iOS SDK (v10.19.0)
- **FirebaseAuth** - User authentication with Google Sign-In
- **FirebaseStorage** - Cloud file storage for attachments
- **Size:** ~200 MB
- **Repository:** https://github.com/firebase/firebase-ios-sdk

### 2. Supabase Swift (v2.3.0)
- **Supabase Client** - Database operations (CRUD for notes)
- **Size:** ~50 MB
- **Repository:** https://github.com/supabase/supabase-swift

### 3. Google Sign-In iOS (v7.0.0)
- **GoogleSignIn** - Google OAuth authentication
- **GoogleSignInSwift** - SwiftUI integration
- **Size:** ~30 MB
- **Repository:** https://github.com/google/GoogleSignIn-iOS

**Total Download Size:** ~280 MB

---

## How Dependencies Are Downloaded

### Step-by-Step Process:

1. **Open the project:**
   ```bash
   cd /Users/jamespaul/Documents/Projects/notes/NotesIOSApp
   open NotesIOSApp.xcodeproj
   ```

2. **Xcode automatically:**
   - Reads the `project.pbxproj` file
   - Finds all package dependencies
   - Downloads them from GitHub
   - Resolves version requirements
   - Builds the packages
   - Integrates them into your project

3. **You'll see:**
   - Progress indicator at the top: "Fetching firebase-ios-sdk"
   - Activity in the top toolbar
   - Package dependencies appear in Project Navigator

4. **Wait time:**
   - First time: 2-5 minutes (depending on internet speed)
   - Subsequent opens: Instant (uses cached packages)

---

## Where Are Dependencies Stored?

Dependencies are cached in:
```
~/Library/Developer/Xcode/DerivedData/
```

This means:
- ✅ They're shared across all Xcode projects
- ✅ You don't need to download them for each project
- ✅ They persist even if you delete the project folder
- ✅ They update when you update Xcode

---

## Verifying Dependencies

### In Xcode:

1. Open the project
2. Look at the **Project Navigator** (left sidebar)
3. Scroll down to "**Package Dependencies**" section
4. You should see:
   ```
   📦 Package Dependencies
       └─ firebase-ios-sdk
       └─ GoogleSignIn-iOS
       └─ supabase-swift
   ```

### In Build Settings:

1. Select the project in Xcode
2. Go to **Package Dependencies** tab
3. You'll see all three packages listed with their versions

---

## Manual Dependency Management (If Needed)

### Reset Package Caches

If dependencies fail to download:

```
Xcode → File → Packages → Reset Package Caches
```

Then:

```
Xcode → File → Packages → Resolve Package Versions
```

### Update Dependencies

To update to latest versions:

```
Xcode → File → Packages → Update to Latest Package Versions
```

### Remove and Re-add Dependencies

If you encounter issues:

1. Select project in Xcode
2. Go to **Package Dependencies** tab
3. Select a package and click `-` (remove)
4. Click `+` to re-add:
   - **Firebase:** `https://github.com/firebase/firebase-ios-sdk`
   - **Supabase:** `https://github.com/supabase/supabase-swift`
   - **Google Sign-In:** `https://github.com/google/GoogleSignIn-iOS`

---

## Build Process

### When You Build the Project:

1. Xcode checks if dependencies are downloaded
2. If not, it downloads them automatically
3. Compiles the packages
4. Links them to your app
5. Builds your app

### Build Time:

- **First build:** 3-5 minutes (includes compiling packages)
- **Incremental builds:** 5-15 seconds (only your code changes)

---

## Common Issues

### ❌ "Failed to resolve package dependencies"

**Cause:** Network issues, GitHub down, or incorrect package URL

**Fix:**
1. Check internet connection
2. Try again later
3. Reset package caches
4. Check GitHub status: https://www.githubstatus.com/

---

### ❌ "No such module 'FirebaseAuth'"

**Cause:** Packages not fully downloaded or compiled

**Fix:**
1. Wait for package resolution to complete
2. Clean build folder: `Cmd + Shift + K`
3. Rebuild: `Cmd + B`
4. Restart Xcode

---

### ❌ "The package product 'FirebaseAuth' cannot be used..."

**Cause:** Package not linked to target

**Fix:**
1. Select project → Target → General
2. Scroll to "Frameworks, Libraries, and Embedded Content"
3. Ensure packages are linked
4. Or: Remove and re-add in Package Dependencies

---

## No Manual Installation Required

Unlike some dependency managers (CocoaPods), you do **NOT** need to:
- ❌ Run `pod install`
- ❌ Install any command-line tools
- ❌ Manually download frameworks
- ❌ Open a `.xcworkspace` file

**Just open the `.xcodeproj` file and Xcode handles everything!**

---

## Checking Download Progress

### While Downloading:

1. Look at the top of Xcode window
2. You'll see: "Fetching [package-name]"
3. A progress bar appears
4. May take 2-5 minutes total

### In Activity Viewer:

```
Xcode → View → Navigators → Report Navigator (⌘9)
```

You can see:
- Package resolution logs
- Download progress
- Compilation status

---

## Dependency Versions

### Current Versions (as configured):

| Package | Version | Requirement |
|---------|---------|-------------|
| Firebase iOS SDK | 10.19.0 | Up to next major (10.x.x) |
| Supabase Swift | 2.3.0 | Up to next major (2.x.x) |
| Google Sign-In iOS | 7.0.0 | Up to next major (7.x.x) |

These are **minimum versions**. Xcode will use the latest compatible version.

### Version Strategy:

- **Up to next major version** means:
  - ✅ 10.20.0, 10.25.0 are OK
  - ❌ 11.0.0 would require updating

This ensures stability while getting bug fixes and minor improvements.

---

## Summary

### ✅ What Happens Automatically:

1. Open `NotesIOSApp.xcodeproj` in Xcode
2. Xcode downloads all dependencies from GitHub
3. Xcode compiles the packages
4. Dependencies are ready to use

### ⏱️ Expected Time:

- **First time:** 2-5 minutes (download + compile)
- **Subsequent opens:** Instant (uses cache)
- **First build:** 3-5 minutes (compile dependencies + app)
- **Later builds:** 5-15 seconds (only your changes)

### 📝 No Action Required:

You don't need to run any commands. Just open the project and let Xcode do its magic!

---

## Need Help?

If dependencies don't download after 10 minutes:

1. Check internet connection
2. Check Xcode version (15.0+ required)
3. Try: File → Packages → Reset Package Caches
4. Check Xcode console for errors
5. Restart Xcode and try again

**Most common issue:** Just need to wait longer! Large packages take time to download.

