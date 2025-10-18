# Configuration Guide for Notes iOS App

This guide provides detailed instructions for configuring all credentials and settings.

## Quick Setup Checklist

- [ ] Download Firebase `GoogleService-Info.plist`
- [ ] Update Supabase credentials in `SupabaseManager.swift`
- [ ] Configure Google Sign-In URL scheme in `Info.plist`
- [ ] Enable Firebase Authentication (Google provider)
- [ ] Enable Firebase Storage
- [ ] Set up Supabase database tables
- [ ] Open project in Xcode (dependencies will auto-download)
- [ ] Build and run

---

## 1. Firebase Configuration

### A. Download Firebase Config File

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Click the gear icon (Settings) > Project Settings
4. Scroll down to "Your apps" section
5. If you don't have an iOS app yet:
   - Click "Add app" > iOS
   - Enter bundle ID: `com.yourcompany.NotesIOSApp`
   - Register the app
6. Download the `GoogleService-Info.plist` file
7. **Replace** the placeholder file at:
   ```
   NotesIOSApp/NotesIOSApp/GoogleService-Info.plist
   ```

### B. Enable Firebase Authentication

1. In Firebase Console, go to **Build** > **Authentication**
2. Click "Get Started" (if first time)
3. Go to **Sign-in method** tab
4. Enable **Google** provider:
   - Toggle it on
   - Use the default OAuth client ID
   - Save

### C. Enable Firebase Storage

1. In Firebase Console, go to **Build** > **Storage**
2. Click "Get Started"
3. Choose production mode or test mode
4. Select a location (e.g., `us-central1`)
5. Create bucket
6. **Update Storage Rules** for security:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Only allow authenticated users to upload to their own folder
    match /notes/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### D. Get OAuth Client ID

From your `GoogleService-Info.plist` file, find:
```xml
<key>CLIENT_ID</key>
<string>YOUR_CLIENT_ID.apps.googleusercontent.com</string>

<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
```

Copy the `REVERSED_CLIENT_ID` value (without the `com.googleusercontent.apps.` prefix).

---

## 2. Update Info.plist

Open `NotesIOSApp/NotesIOSApp/Info.plist` and update:

### Replace CLIENT_ID placeholders:

**Before:**
```xml
<string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
```

**After:**
```xml
<string>com.googleusercontent.apps.123456789-abcdefghijk.apps.googleusercontent.com</string>
```

**Before:**
```xml
<key>GIDClientID</key>
<string>YOUR-CLIENT-ID.apps.googleusercontent.com</string>
```

**After:**
```xml
<key>GIDClientID</key>
<string>123456789-abcdefghijk.apps.googleusercontent.com</string>
```

Replace `123456789-abcdefghijk` with your actual client ID from `GoogleService-Info.plist`.

---

## 3. Supabase Configuration

### A. Get Supabase Credentials

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Go to **Settings** > **API**
4. Copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJhbG...`)

### B. Update SupabaseManager.swift

Open `NotesIOSApp/NotesIOSApp/Managers/SupabaseManager.swift`

**Find:**
```swift
private let supabaseURL = "YOUR_SUPABASE_URL"
private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
```

**Replace with:**
```swift
private let supabaseURL = "https://xxxxx.supabase.co"
private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...."
```

### C. Create Database Tables

Run these SQL commands in Supabase SQL Editor:

#### 1. Notes Table

```sql
CREATE TABLE IF NOT EXISTS notes (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_favorite BOOLEAN DEFAULT FALSE,
  tags TEXT[] DEFAULT '{}',
  attachments JSONB DEFAULT '[]'
);

-- Create index for faster queries
CREATE INDEX idx_notes_user_id ON notes(user_id);
CREATE INDEX idx_notes_created_at ON notes(created_at DESC);

-- Enable RLS (Row Level Security)
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Allow users to see only their own notes
CREATE POLICY "Users can view their own notes"
  ON notes FOR SELECT
  USING (true);

-- Allow users to insert their own notes
CREATE POLICY "Users can insert their own notes"
  ON notes FOR INSERT
  WITH CHECK (true);

-- Allow users to update their own notes
CREATE POLICY "Users can update their own notes"
  ON notes FOR UPDATE
  USING (true);

-- Allow users to delete their own notes
CREATE POLICY "Users can delete their own notes"
  ON notes FOR DELETE
  USING (true);
```

#### 2. User Profiles Table

```sql
CREATE TABLE IF NOT EXISTS user_profiles (
  id SERIAL PRIMARY KEY,
  user_id TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  name TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  premium_since TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view all profiles"
  ON user_profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Users can update their own profile"
  ON user_profiles FOR UPDATE
  USING (true);
```

#### 3. Subscription Status Table

```sql
CREATE TABLE IF NOT EXISTS subscription_status (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  user_email TEXT NOT NULL,
  subscription_id TEXT,
  status BOOLEAN DEFAULT FALSE,
  payment_id TEXT,
  checkout_session_id TEXT,
  total_amount NUMERIC,
  currency TEXT,
  payment_method TEXT,
  payment_status TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index
CREATE INDEX idx_subscription_status_user_id ON subscription_status(user_id);

-- Enable RLS
ALTER TABLE subscription_status ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view all subscriptions"
  ON subscription_status FOR SELECT
  USING (true);

CREATE POLICY "System can insert subscriptions"
  ON subscription_status FOR INSERT
  WITH CHECK (true);

CREATE POLICY "System can update subscriptions"
  ON subscription_status FOR UPDATE
  USING (true);
```

---

## 4. Open Project in Xcode

### A. Open the Project

```bash
cd /Users/jamespaul/Documents/Projects/notes/NotesIOSApp
open NotesIOSApp.xcodeproj
```

⚠️ **Important:** Open `NotesIOSApp.xcodeproj`, NOT the folder!

### B. Wait for Dependencies

When you first open the project:
1. Xcode will automatically start downloading Swift packages
2. Look for "Fetching..." progress at the top of the window
3. This typically takes 2-5 minutes
4. Dependencies include:
   - Firebase iOS SDK (~200MB)
   - Supabase Swift (~50MB)
   - Google Sign-In iOS (~30MB)

If dependencies don't download:
- Go to **File** > **Packages** > **Reset Package Caches**
- Go to **File** > **Packages** > **Resolve Package Versions**
- Restart Xcode

### C. Verify Installation

Check that packages are installed:
1. In Xcode's Project Navigator, look for "Package Dependencies" section
2. Should show:
   - firebase-ios-sdk
   - supabase-swift
   - GoogleSignIn-iOS

---

## 5. Build Settings (Optional)

### Change Bundle Identifier

If you want your own bundle ID:

1. Select project in Xcode navigator
2. Select "NotesIOSApp" target
3. Go to "Signing & Capabilities" tab
4. Change "Bundle Identifier" to your own (e.g., `com.mycompany.mynotes`)
5. **Important:** Update this in Firebase Console too:
   - Firebase Console > Project Settings > Your apps
   - Add new iOS app or update existing one with new bundle ID

### Code Signing

For development:
- Select "Automatically manage signing"
- Choose your team

For distribution:
- Configure provisioning profiles as needed

---

## 6. Test the Setup

### Build the Project

1. Select a simulator (e.g., iPhone 15 Pro)
2. Press `Cmd + B` to build
3. Fix any build errors

Common build errors:
- **Missing GoogleService-Info.plist**: Add the file and ensure it's in target
- **Module not found**: Wait for packages to download completely
- **Signing error**: Configure code signing in project settings

### Run the App

1. Press `Cmd + R` to run
2. The app should launch in simulator
3. Try signing in with Google
4. Check Xcode console for logs

### Verify Features

✅ **Authentication:**
- Google Sign-In works
- User profile is created in Supabase
- Check Supabase dashboard > Authentication tab

✅ **Notes:**
- Can create notes
- Notes appear in list
- Can edit and delete notes
- Check Supabase dashboard > Table Editor > notes

✅ **File Upload:**
- Can attach photos
- Photos upload to Firebase Storage
- Check Firebase Console > Storage

✅ **Premium Status:**
- Premium badge appears if user has premium status
- Manually set `is_premium = true` in Supabase to test

---

## 7. Troubleshooting

### Google Sign-In Not Working

**Error:** "Sign-In failed: Invalid client ID"

**Fix:**
1. Verify `Info.plist` has correct CLIENT_ID
2. Check bundle ID matches in Firebase Console
3. Re-download `GoogleService-Info.plist` if needed

### Supabase Connection Fails

**Error:** "Failed to load notes"

**Fix:**
1. Check Supabase URL and key in `SupabaseManager.swift`
2. Verify tables exist in Supabase
3. Check RLS policies allow read/write
4. Review Supabase logs for errors

### Files Won't Upload

**Error:** "Upload failed"

**Fix:**
1. Verify Firebase Storage is enabled
2. Check storage rules allow uploads
3. Ensure user is authenticated
4. Check Firebase Console > Storage > Usage

### Dependencies Won't Download

**Fix:**
1. Check internet connection
2. File > Packages > Reset Package Caches
3. File > Packages > Update to Latest Package Versions
4. Restart Xcode
5. Check Xcode > Preferences > Accounts (sign in with Apple ID)

---

## 8. Production Checklist

Before releasing:

- [ ] Use production Firebase project
- [ ] Configure proper Firebase Storage rules
- [ ] Set up Supabase RLS policies correctly
- [ ] Use production Supabase project
- [ ] Configure code signing with distribution certificate
- [ ] Update app icons in Assets.xcassets
- [ ] Test on real devices
- [ ] Configure App Store Connect
- [ ] Submit for review

---

## Summary

**Minimum required steps to run:**

1. Replace `GoogleService-Info.plist` with your Firebase config
2. Update `SupabaseManager.swift` with your Supabase URL and key
3. Update `Info.plist` with your Google Sign-In client ID
4. Open `NotesIOSApp.xcodeproj` in Xcode (dependencies auto-download)
5. Build and run (Cmd + R)

**That's it!** The app should now work with full functionality.

