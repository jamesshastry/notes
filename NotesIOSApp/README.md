# Notes iOS App

A beautiful iOS client for the Notes application with Firebase authentication, Supabase database, and Firebase Storage for file uploads.

## Features

✅ **Firebase Authentication**
- Google Sign-In integration
- Secure authentication flow

✅ **Notes Management (CRUD)**
- Create, Read, Update, Delete notes
- Text-based notes with titles and content
- Search functionality
- Real-time sync with Supabase

✅ **File Upload & Storage**
- Upload photos from camera roll
- Upload files (PDF, documents, etc.)
- Store files in Firebase Storage
- Download and view attachments
- Image preview support

✅ **Premium Status Display**
- Fetches premium status from Supabase database
- Visual indicator for premium users
- Checks both `subscription_status` and `user_profiles` tables

## Requirements

- **Xcode 15.0 or later**
- **iOS 15.0 or later**
- **macOS 13.0 or later** (for development)
- Firebase project with Authentication and Storage enabled
- Supabase project with notes database

## Project Structure

```
NotesIOSApp/
├── NotesIOSApp.xcodeproj/          # Xcode project file
│   └── project.pbxproj              # Project configuration
├── NotesIOSApp/
│   ├── NotesIOSAppApp.swift         # App entry point
│   ├── ContentView.swift            # Root view
│   ├── Info.plist                   # App configuration
│   ├── GoogleService-Info.plist     # Firebase configuration
│   ├── Models/
│   │   ├── Note.swift               # Note data model
│   │   └── UserProfile.swift        # User profile model
│   ├── Views/
│   │   ├── AuthenticationView.swift # Login screen
│   │   ├── NotesListView.swift      # Notes list
│   │   ├── NoteDetailView.swift     # Note detail view
│   │   └── NoteEditView.swift       # Note editor
│   ├── Managers/
│   │   ├── AuthenticationManager.swift      # Auth logic
│   │   ├── SupabaseManager.swift            # Database operations
│   │   └── FirebaseStorageManager.swift     # File storage
│   └── Assets.xcassets/             # App assets
└── README.md
```

## Dependencies

The project uses **Swift Package Manager (SPM)** to manage dependencies. Xcode will **automatically download** all dependencies when you first open the project.

### Included Packages:

1. **Firebase iOS SDK** (v10.0+)
   - FirebaseAuth
   - FirebaseStorage

2. **Supabase Swift** (v2.0+)
   - Complete Supabase client

3. **Google Sign-In iOS** (v7.0+)
   - Google authentication

## Setup Instructions

### Step 1: Open the Project in Xcode

1. Navigate to the project directory:
   ```bash
   cd /Users/jamespaul/Documents/Projects/notes/NotesIOSApp
   ```

2. **Open the Xcode project:**
   ```bash
   open NotesIOSApp.xcodeproj
   ```
   
   ⚠️ **IMPORTANT:** Open the `.xcodeproj` file, NOT the folder.

3. **Wait for dependencies to download:**
   - Xcode will automatically resolve and download all Swift packages
   - You'll see a progress indicator at the top of Xcode
   - This may take 2-5 minutes depending on your internet connection
   - Dependencies will be cached for future use

### Step 2: Configure Firebase

1. **Download your Firebase configuration:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Project Settings > Your apps > iOS app
   - Download `GoogleService-Info.plist`

2. **Replace the placeholder file:**
   - Replace `NotesIOSApp/GoogleService-Info.plist` with your downloaded file
   - Make sure it's added to the Xcode project target

3. **Enable Firebase Authentication:**
   - In Firebase Console, go to Authentication > Sign-in method
   - Enable "Google" sign-in provider
   - Add your iOS bundle ID: `com.yourcompany.NotesIOSApp`

4. **Enable Firebase Storage:**
   - In Firebase Console, go to Storage
   - Click "Get Started" and set up storage rules
   - Recommended rules for development:
     ```
     rules_version = '2';
     service firebase.storage {
       match /b/{bucket}/o {
         match /notes/{userId}/{allPaths=**} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
       }
     }
     ```

5. **Configure Google Sign-In:**
   - Get your OAuth client ID from Firebase Console
   - Update `Info.plist` with your client ID:
     - Replace `YOUR-CLIENT-ID` with your actual client ID (found in `GoogleService-Info.plist`)
   - Update the URL scheme: `com.googleusercontent.apps.YOUR-CLIENT-ID`

### Step 3: Configure Supabase

1. **Update Supabase credentials in `SupabaseManager.swift`:**
   ```swift
   private let supabaseURL = "YOUR_SUPABASE_URL"
   private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
   ```

2. **Ensure your Supabase database has the required tables:**
   
   **Notes table:**
   ```sql
   CREATE TABLE notes (
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
   ```

   **User Profiles table:**
   ```sql
   CREATE TABLE user_profiles (
     id SERIAL PRIMARY KEY,
     user_id TEXT UNIQUE NOT NULL,
     email TEXT NOT NULL,
     name TEXT,
     is_premium BOOLEAN DEFAULT FALSE,
     premium_since TIMESTAMP WITH TIME ZONE,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );
   ```

   **Subscription Status table:**
   ```sql
   CREATE TABLE subscription_status (
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
   ```

### Step 4: Update Bundle Identifier (Optional)

If you want to use your own bundle identifier:

1. In Xcode, select the project in the navigator
2. Select the "NotesIOSApp" target
3. Go to "Signing & Capabilities"
4. Change the bundle identifier from `com.yourcompany.NotesIOSApp` to your own
5. Update this in Firebase Console as well

### Step 5: Build and Run

1. **Select a simulator or device:**
   - Choose from the device selector in Xcode toolbar
   - Recommended: iPhone 15 Pro simulator or later

2. **Build and run:**
   - Press `Cmd + R` or click the Play button
   - Wait for the build to complete
   - The app will launch on your selected device/simulator

## Usage

### Sign In
1. Launch the app
2. Tap "Sign in with Google"
3. Choose your Google account
4. Grant permissions

### Create a Note
1. Tap the `+` button in the top right
2. Enter a title and content
3. Optionally add photos or files
4. Tap "Save"

### Edit a Note
1. Tap on any note to view details
2. Tap the menu button (three dots)
3. Select "Edit"
4. Make changes and tap "Save"

### Delete a Note
1. Long press on a note in the list
2. Select "Delete" from the context menu
   OR
1. Open the note
2. Tap the menu button
3. Select "Delete"

### Add Attachments
1. While creating/editing a note
2. Tap "Add Photos" to select from camera roll
3. Tap "Add Files" to select documents
4. Files are automatically uploaded to Firebase Storage

### View Premium Status
- Premium users see a gold star ⭐ next to their profile icon
- Premium status is fetched from Supabase database
- Status is shown in the user menu

## Troubleshooting

### Dependencies Not Downloading

If packages don't download automatically:
1. In Xcode, go to File > Packages > Reset Package Caches
2. Go to File > Packages > Resolve Package Versions
3. Restart Xcode and try again

### Build Errors

**"No such module 'Firebase'"**
- Wait for package resolution to complete
- Check the top of Xcode for download progress
- Try Product > Clean Build Folder (Cmd + Shift + K)

**"Missing GoogleService-Info.plist"**
- Make sure you've downloaded and added your Firebase configuration file
- Check that it's included in the target

### Authentication Issues

**"Google Sign-In failed"**
- Verify your OAuth client ID is correct in `Info.plist`
- Check that Google Sign-In is enabled in Firebase Console
- Make sure your bundle ID matches in Firebase and Xcode

### Database Issues

**"Failed to load notes"**
- Check your Supabase URL and anon key
- Verify the notes table exists in Supabase
- Check Supabase logs for errors

**"Premium status not showing"**
- Verify the user_profiles or subscription_status table exists
- Check that the user has a record in the database
- Review Supabase RLS (Row Level Security) policies

## Architecture

### Authentication Flow
1. User taps "Sign in with Google"
2. Google Sign-In SDK handles OAuth flow
3. Firebase Auth creates/authenticates user session
4. User profile is created/updated in Supabase

### Notes CRUD Flow
1. All note operations go through SupabaseManager
2. Notes are stored in Supabase PostgreSQL database
3. Real-time sync ensures data consistency
4. Search is performed locally for speed

### File Upload Flow
1. User selects files from device
2. Files are uploaded to Firebase Storage
3. URLs and metadata are stored in note attachments
4. Downloads retrieve files from Firebase Storage

### Premium Status Check
1. Check subscription_status table first (priority)
2. Fall back to user_profiles table
3. Cache result in memory for performance

## Tech Stack

- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Authentication:** Firebase Auth + Google Sign-In
- **Database:** Supabase (PostgreSQL)
- **File Storage:** Firebase Storage
- **Dependency Management:** Swift Package Manager

## Features NOT Implemented

❌ Dodo Payments integration (as requested)
- Premium status is read-only from database
- Upgrade functionality would need to be implemented separately

## License

MIT License - See web project for details

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Firebase and Supabase documentation
3. Check Xcode console logs for detailed error messages

## Credits

Created as an iOS companion to the web-based Notes application with Firebase and Supabase integration.

