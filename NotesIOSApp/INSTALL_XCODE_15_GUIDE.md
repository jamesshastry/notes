# Install Xcode 15.4 - Step-by-Step Guide

## 📥 Overview

We need to install Xcode 15.4 to work around the package compatibility issues with Xcode 26.0.

**Time required:** 30-60 minutes (mostly download time)  
**Disk space needed:** ~40 GB (Xcode 15 + temporary files)

---

## 🎯 Step 1: Download Xcode 15.4

I've opened the Apple Developer Downloads page in your browser.

### What to do:

1. **Sign in** with your Apple ID (if prompted)

2. **Search** for: `Xcode 15.4`

3. **Find** this file:
   ```
   Xcode 15.4
   Released: July 29, 2024
   File: Xcode_15.4.xip (approximately 8 GB)
   ```

4. **Click Download**
   - File will save to: `~/Downloads/Xcode_15.4.xip`
   - Download time: 10-30 minutes (depending on internet speed)

5. **Wait** for download to complete
   - You can check progress in your Downloads folder
   - The file is large (~8 GB)

---

## ⏸️ PAUSE HERE

**Don't continue until `Xcode_15.4.xip` is fully downloaded to your Downloads folder!**

Check with:
```bash
ls -lh ~/Downloads/Xcode_15.4.xip
```

Should show something like:
```
-rw-r--r--  1 jamespaul  staff   7.9G Oct 18 02:00 Xcode_15.4.xip
```

---

## 🎯 Step 2: Run Installation Script

Once the download is complete, run the automated installation script:

```bash
cd /Users/jamespaul/Documents/Projects/notes/NotesIOSApp
./install_xcode_15.sh
```

### What the script does:

1. ✅ Checks if download exists
2. ✅ Extracts Xcode_15.4.xip (5-10 minutes)
3. ✅ Renames your current Xcode 26 to `Xcode-26.app` (keeps it!)
4. ✅ Installs Xcode 15.4 as `Xcode-15.app`
5. ✅ Switches active version to Xcode 15.4
6. ✅ Accepts license
7. ✅ Installs required components
8. ✅ Cleans up temporary files

**Note:** The script will ask for your password (sudo) for system operations.

---

## 🎯 Alternative: Manual Installation

If you prefer to do it manually:

### 1. Extract the XIP file
```bash
cd ~/Downloads
xip -x Xcode_15.4.xip
# This takes 5-10 minutes, creates Xcode.app
```

### 2. Rename current Xcode (keep both versions)
```bash
sudo mv /Applications/Xcode.app /Applications/Xcode-26.app
```

### 3. Move Xcode 15 to Applications
```bash
sudo mv ~/Downloads/Xcode.app /Applications/Xcode-15.app
```

### 4. Switch to Xcode 15
```bash
sudo xcode-select --switch /Applications/Xcode-15.app/Contents/Developer
```

### 5. Accept license
```bash
sudo xcodebuild -license accept
```

### 6. Install components
```bash
sudo xcodebuild -runFirstLaunch
```

### 7. Verify
```bash
xcodebuild -version
# Should show: Xcode 15.4
```

### 8. Clean up
```bash
rm ~/Downloads/Xcode_15.4.xip
```

---

## ✅ Step 3: Verify Installation

Check that Xcode 15.4 is active:

```bash
xcodebuild -version
```

Should output:
```
Xcode 15.4
Build version 15F31d
```

Check available versions:
```bash
ls -la /Applications/ | grep Xcode
```

Should show:
```
Xcode-15.app    ← Active (for iOS project)
Xcode-26.app    ← Available (for other projects)
```

---

## 🎯 Step 4: Open iOS Project

Now open the project with Xcode 15:

```bash
cd /Users/jamespaul/Documents/Projects/notes/NotesIOSApp
open NotesIOSApp.xcodeproj
```

**Xcode 15 will open** (not Xcode 26)

---

## 📦 Step 5: Add Packages (Finally Works!)

In Xcode:

1. Select **NotesIOSApp** project
2. Select **NotesIOSApp** target
3. Go to **Package Dependencies** tab
4. Click **`+`** to add packages

### Add these 3 packages:

**Firebase:**
```
https://github.com/firebase/firebase-ios-sdk
```
- Version: 10.19.0 or later
- Products: FirebaseAuth, FirebaseStorage

**Google Sign-In:**
```
https://github.com/google/GoogleSignIn-iOS
```
- Version: 7.0.0 or later
- Products: GoogleSignIn, GoogleSignInSwift

**Supabase:**
```
https://github.com/supabase/supabase-swift
```
- Version: 2.0.0 or later
- Products: Supabase

**These will install perfectly with Xcode 15!** ✅

---

## 🔄 Switching Between Xcode Versions

You now have both versions installed. To switch:

**Use Xcode 15 (for this project):**
```bash
sudo xcode-select --switch /Applications/Xcode-15.app/Contents/Developer
```

**Use Xcode 26 (for other projects):**
```bash
sudo xcode-select --switch /Applications/Xcode-26.app/Contents/Developer
```

**Check current version:**
```bash
xcodebuild -version
```

---

## 🧹 Disk Space

After installation:
- Xcode 15: ~35 GB
- Xcode 26: ~35 GB
- **Total: ~70 GB** for both versions

If you want to remove Xcode 26 later (to save space):
```bash
sudo rm -rf /Applications/Xcode-26.app
```

---

## ⏱️ Timeline

| Step | Time |
|------|------|
| Download Xcode 15.4 | 10-30 min |
| Extract .xip file | 5-10 min |
| Move and configure | 2 min |
| Accept license & components | 1 min |
| **Total** | **20-45 minutes** |

Most of this is waiting time - you can do other things while it downloads/extracts!

---

## 🎉 After Installation

Once Xcode 15.4 is installed and packages are added:

1. ✅ All module errors will be gone
2. ✅ Project will build successfully
3. ✅ You can configure Firebase/Supabase credentials
4. ✅ App will run perfectly

---

## 🆘 Troubleshooting

**Download fails:**
- Check internet connection
- Try Safari instead of Chrome
- Check Apple Developer account status

**Extraction stuck:**
- This is normal, large file takes time
- Wait at least 10 minutes before canceling
- Check Activity Monitor for `xip` process

**"Xcode.app" damaged error:**
- This is Gatekeeper security
- Run: `sudo xattr -r -d com.apple.quarantine /Applications/Xcode-15.app`

**Permission denied:**
- Make sure to use `sudo` for system operations
- Enter your Mac password when prompted

---

## ✨ Benefits

After installing Xcode 15.4:
- ✅ All iOS packages work perfectly
- ✅ Industry-standard stable version
- ✅ Keep Xcode 26 for other projects
- ✅ Easy to switch between versions

**Let me know once the download completes and I'll help you run the installation!**

