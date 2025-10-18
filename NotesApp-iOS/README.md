# Notes App - iOS Client

A native iOS app for the Notes application with Firebase authentication, Supabase backend, and file upload support.

## Features

- ✅ **Google Sign-In** with Firebase Authentication
- ✅ **CRUD Operations** for text notes
- ✅ **File Attachments** - Upload and attach files to notes
- ✅ **Premium Status** - Display user premium status from Supabase
- ✅ **Offline Support** - Works seamlessly with Supabase
- ✅ **Modern UI** - Clean, native iOS design

## Requirements

- Xcode 14.0 or later
- iOS 15.0 or later
- CocoaPods installed
- Firebase project configured
- Supabase project configured

## Setup Instructions

### 1. Install CocoaPods

If you don't have CocoaPods installed:

```bash
sudo gem install cocoapods
```

### 2. Install Dependencies

Navigate to the iOS app directory and install pods:

```bash
cd NotesApp-iOS
pod install
```

### 3. Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Project Settings** → **General**
4. Under **Your apps**, select the iOS app
5. Download `GoogleService-Info.plist`
6. Replace the template `GoogleService-Info.plist` in the project with your downloaded file

### 4. Configure Google Sign-In

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Google** sign-in
3. Note the **iOS client ID** from `GoogleService-Info.plist`
4. In Xcode, go to **NotesApp-iOS target** → **Info** → **URL Types**
5. Add a URL scheme with the **REVERSED_CLIENT_ID** from `GoogleService-Info.plist`

### 5. Configure Supabase

1. Open `NotesApp-iOS/Services/SupabaseService.swift`
2. Replace the placeholders:
   ```swift
   let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
   let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
   ```
3. Use your actual Supabase URL and anon key from your Supabase project

### 6. Open Xcode Project

**IMPORTANT:** Open the `.xcworkspace` file, NOT the `.xcodeproj` file:

```bash
open NotesApp-iOS.xcworkspace
```

### 7. Build and Run

1. Select your target device or simulator
2. Press **Cmd + R** or click the **Run** button
3. The app should build and launch

## Project Structure

```
NotesApp-iOS/
├── NotesApp-iOS/
│   ├── AppDelegate.swift                 # App entry point
│   ├── SceneDelegate.swift               # Scene management
│   ├── Models/
│   │   └── Note.swift                    # Data models
│   ├── Services/
│   │   ├── AuthService.swift             # Firebase authentication
│   │   └── SupabaseService.swift         # Supabase database/storage
│   ├── ViewControllers/
│   │   ├── LoginViewController.swift     # Google sign-in
│   │   ├── NotesListViewController.swift # Notes list view
│   │   └── NoteDetailViewController.swift # Create/edit notes
│   ├── Info.plist                        # App configuration
│   └── GoogleService-Info.plist          # Firebase configuration
├── Podfile                               # CocoaPods dependencies
└── README.md                             # This file
```

## Usage

### Sign In
1. Launch the app
2. Tap "Sign in with Google"
3. Select your Google account
4. Grant permissions

### Create a Note
1. Tap the **+** button in the top right
2. Enter title and content
3. Optionally attach files using the 📎 button
4. Tap **Save**

### Edit a Note
1. Tap on any note in the list
2. Modify the title or content
3. Tap **Save**

### Delete a Note
1. Swipe left on a note
2. Tap **Delete**

### View Premium Status
1. Tap the profile icon in the top right
2. Your premium status will be displayed
3. Premium users see a ⭐ badge in the navigation bar

## Troubleshooting

### Build Errors

**"Firebase not found"**
- Make sure you ran `pod install`
- Open `.xcworkspace` not `.xcodeproj`

**"GoogleService-Info.plist not found"**
- Download from Firebase Console
- Drag into Xcode project
- Make sure "Copy items if needed" is checked

**"No such module 'Supabase'"**
- Run `pod install` again
- Clean build folder (Cmd + Shift + K)
- Rebuild (Cmd + B)

### Runtime Errors

**Google Sign-In fails**
- Check `GoogleService-Info.plist` is properly configured
- Verify URL schemes in Info.plist
- Check Firebase Authentication is enabled

**Supabase connection fails**
- Verify Supabase URL and key are correct
- Check network permissions
- Verify Supabase RLS policies allow access

## API Compatibility

This iOS app is fully compatible with the web version and uses the same:
- Firebase Authentication (Google Sign-In)
- Supabase database schema
- Supabase storage buckets

All notes and files are synced across web and mobile platforms.

## Premium Features

The app displays premium status from the Supabase `user_profiles` table but does not implement payment processing. Users can upgrade to premium on the web version, and the status will automatically sync to the iOS app.

## Dependencies

- **Firebase/Auth** (10.x) - Authentication
- **Firebase/Core** (10.x) - Firebase core SDK
- **GoogleSignIn** (7.x) - Google Sign-In SDK
- **Supabase** (2.x) - Supabase Swift client

## License

This project is part of the Notes App system.

## Support

For issues related to:
- **Firebase**: Check Firebase Console logs
- **Supabase**: Check Supabase Dashboard logs
- **iOS App**: Check Xcode console output

