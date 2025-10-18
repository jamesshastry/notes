# Manual Package Setup Guide

Since automatic package resolution isn't working, let's add packages manually through Xcode's GUI. This is the most reliable method.

## Step-by-Step Instructions

### Step 1: Remove All Existing Package References

1. In Xcode, select **NotesIOSApp** project (blue icon) in the left sidebar
2. Select the **NotesIOSApp** target (under TARGETS)
3. Go to **Frameworks, Libraries, and Embedded Content** section
4. Remove ALL package products by clicking `-` button:
   - FirebaseAuth
   - FirebaseStorage
   - Supabase
   - GoogleSignIn
   - GoogleSignInSwift

5. Now go to the **Package Dependencies** tab (at the top)
6. Remove ALL packages by selecting each and clicking `-`:
   - firebase-ios-sdk
   - supabase-swift
   - GoogleSignIn-iOS

### Step 2: Add Packages Fresh

Now let's add them back one at a time:

#### A. Add Firebase

1. Click the **`+`** button in Package Dependencies
2. In the search field (top right), paste:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
3. Press Enter/Return
4. Wait for it to load (10-30 seconds)
5. In "Dependency Rule", select: **Up to Next Major Version**
6. Enter minimum version: **10.19.0**
7. Click **Add Package**
8. Wait for download (this takes 1-2 minutes - it's ~200MB)
9. When the product selection appears, check ONLY:
   - ☑️ **FirebaseAuth**
   - ☑️ **FirebaseStorage**
10. Click **Add Package**

#### B. Add Google Sign-In

1. Click the **`+`** button again
2. Paste:
   ```
   https://github.com/google/GoogleSignIn-iOS
   ```
3. Press Enter
4. Wait for it to load
5. Select: **Up to Next Major Version**, minimum **7.0.0**
6. Click **Add Package**
7. When products appear, check:
   - ☑️ **GoogleSignIn**
   - ☑️ **GoogleSignInSwift**
8. Click **Add Package**

#### C. Add Supabase

1. Click **`+`** button again
2. Paste:
   ```
   https://github.com/supabase/supabase-swift
   ```
3. Press Enter
4. Wait for it to load
5. Select: **Up to Next Major Version**, minimum **2.0.0**
6. Click **Add Package**
7. When products appear, check:
   - ☑️ **Supabase**
8. Click **Add Package**

### Step 3: Verify

After all packages are added:

1. Look in **Project Navigator** (left sidebar)
2. Scroll down to **Package Dependencies** section
3. You should see:
   - 📦 firebase-ios-sdk
   - 📦 GoogleSignIn-iOS
   - 📦 supabase-swift

4. Go back to your target's **Frameworks, Libraries, and Embedded Content**
5. You should see all 5 products listed

### Step 4: Build

Press **Cmd + B** to build.

The errors should be gone! ✅

---

## Timeline

- Adding each package: 30 seconds to 2 minutes
- Total time: 5-10 minutes
- First build after adding: 2-3 minutes

---

## Troubleshooting

### "Repository not found" or "Cannot resolve package"

**Fix:** Check your internet connection, GitHub might be slow. Wait 30 seconds and try again.

### Package downloads but products don't appear

**Fix:** 
1. Close the add package window
2. Xcode → File → Packages → Resolve Package Versions
3. Wait 2 minutes
4. Try adding the package again

### Build still fails after adding packages

**Fix:**
1. Product → Clean Build Folder (Cmd + Shift + K)
2. Product → Build (Cmd + B)

---

## Why Manual Addition Works Better

- Xcode GUI handles authentication automatically
- Better error messages
- Can see download progress
- Resolves dependencies immediately
- More reliable than programmatic addition

---

## Next Step After Packages Work

Once you can build successfully, see `CONFIGURATION_GUIDE.md` for:
- Firebase configuration
- Supabase credentials
- Running the app

