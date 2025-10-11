# 🔐 Firebase Authentication Setup Guide

## 🚀 Firebase Project Setup

### **Step 1: Create Firebase Project**
1. Go to https://console.firebase.google.com
2. Click "Create a project"
3. Enter project name (e.g., "smart-notes-app")
4. Enable Google Analytics (optional)
5. Click "Create project"

### **Step 2: Enable Authentication**
1. In Firebase Console, go to **Authentication**
2. Click **Get Started**
3. Go to **Sign-in method** tab
4. Enable **Google** provider:
   - Click on Google
   - Toggle "Enable"
   - Add your project support email
   - Click "Save"

### **Step 3: Get Firebase Configuration**
1. Go to **Project Settings** (gear icon)
2. Scroll down to **Your apps**
3. Click **Add app** → **Web** (</> icon)
4. Enter app nickname (e.g., "Smart Notes Web")
5. Click **Register app**
6. Copy the Firebase configuration object

## 🔧 Environment Variables for Render

Add these environment variables in your Render dashboard:

### **Firebase Configuration:**
```
FIREBASE_API_KEY = your-api-key-here
FIREBASE_AUTH_DOMAIN = your-project-id.firebaseapp.com
FIREBASE_PROJECT_ID = your-project-id
FIREBASE_STORAGE_BUCKET = your-project-id.appspot.com
FIREBASE_MESSAGING_SENDER_ID = your-sender-id
FIREBASE_APP_ID = your-app-id
```

### **Supabase Configuration:**
```
SUPABASE_URL = https://your-project-id.supabase.co
SUPABASE_ANON_KEY = your-supabase-anon-key
```

## 🗄️ Supabase Database Updates

### **Update Notes Table Schema**
Run this SQL in your Supabase SQL Editor:

```sql
-- Update the notes table to use Firebase UID
ALTER TABLE notes 
ALTER COLUMN user_id TYPE TEXT;

-- Update the foreign key constraint (remove if exists)
ALTER TABLE notes 
DROP CONSTRAINT IF EXISTS notes_user_id_fkey;

-- Update RLS policies for Firebase UIDs
DROP POLICY IF EXISTS "Users can view their own notes" ON notes;
DROP POLICY IF EXISTS "Users can insert their own notes" ON notes;
DROP POLICY IF EXISTS "Users can update their own notes" ON notes;
DROP POLICY IF EXISTS "Users can delete their own notes" ON notes;

-- Create new policies for Firebase UIDs
CREATE POLICY "Users can view their own notes" ON notes
    FOR SELECT USING (user_id = auth.jwt() ->> 'sub');

CREATE POLICY "Users can insert their own notes" ON notes
    FOR INSERT WITH CHECK (user_id = auth.jwt() ->> 'sub');

CREATE POLICY "Users can update their own notes" ON notes
    FOR UPDATE USING (user_id = auth.jwt() ->> 'sub');

CREATE POLICY "Users can delete their own notes" ON notes
    FOR DELETE USING (user_id = auth.jwt() ->> 'sub');
```

### **Alternative: Use Firebase UID Directly**
If you prefer to use Firebase UID directly without Supabase auth:

```sql
-- Create a function to get Firebase UID
CREATE OR REPLACE FUNCTION get_firebase_uid()
RETURNS TEXT AS $$
BEGIN
    RETURN current_setting('request.jwt.claims', true)::json->>'sub';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update policies to use Firebase UID
CREATE POLICY "Users can view their own notes" ON notes
    FOR SELECT USING (user_id = get_firebase_uid());

CREATE POLICY "Users can insert their own notes" ON notes
    FOR INSERT WITH CHECK (user_id = get_firebase_uid());

CREATE POLICY "Users can update their own notes" ON notes
    FOR UPDATE USING (user_id = get_firebase_uid());

CREATE POLICY "Users can delete their own notes" ON notes
    FOR DELETE USING (user_id = get_firebase_uid());
```

## 🔐 Authentication Flow

### **How It Works:**
1. **User visits app** → Shows authentication modal
2. **User clicks "Sign in with Google"** → Firebase handles OAuth
3. **Firebase returns user data** → App stores Firebase UID
4. **App uses Firebase UID** → For Supabase database operations
5. **Supabase RLS policies** → Ensure user only sees their notes

### **Security Features:**
- ✅ **Google OAuth** - Secure authentication
- ✅ **Firebase UID** - Unique user identification
- ✅ **Supabase RLS** - Database-level security
- ✅ **JWT Tokens** - Secure API communication
- ✅ **User Isolation** - Each user sees only their notes

## 🚀 Deployment Steps

### **1. Set up Firebase Project**
- Create Firebase project
- Enable Google authentication
- Get configuration values

### **2. Update Supabase Database**
- Run SQL queries to update schema
- Update RLS policies for Firebase UIDs

### **3. Add Environment Variables to Render**
- Add all Firebase configuration variables
- Add Supabase configuration variables

### **4. Deploy and Test**
- Deploy to Render
- Test Google Sign-In
- Verify notes are user-specific

## 🔍 Testing Checklist

- [ ] Firebase project created and configured
- [ ] Google authentication enabled
- [ ] Environment variables set in Render
- [ ] Supabase database schema updated
- [ ] RLS policies updated
- [ ] App deployed successfully
- [ ] Google Sign-In works
- [ ] Notes are user-specific
- [ ] Sign-out works correctly

## 🎯 Expected Result

After setup:
- ✅ Users must sign in with Google to access the app
- ✅ Each user sees only their own notes
- ✅ Notes are stored securely in Supabase
- ✅ Authentication state persists across sessions
- ✅ Users can sign out and sign back in

Your Smart Notes App is now secure and user-specific! 🔐✨
