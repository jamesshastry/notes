# 🔍 Debug User Profiles Issue

## Problem
User profiles are not being created in the `user_profiles` table when users sign in.

---

## 🔧 Step-by-Step Debugging

### Step 1: Check Browser Console

Open your browser console (F12) and look for these logs when you sign in:

**Expected logs:**
```
👤 Ensuring user profile exists...
📊 User info: { id: "...", email: "...", name: "..." }
➕ Creating new user profile...
✅ Created new user profile: {...}
```

**If you see errors:**
```
❌ Error creating profile: {...}
❌ Error details: {...}
```

Copy these errors - they tell us exactly what's wrong!

---

### Step 2: Verify Table Exists in Supabase

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Go to **Table Editor** (left sidebar)
4. Look for `user_profiles` table

**If table doesn't exist:**
- Run the SQL scripts from `SUPABASE_USER_PROFILES_SETUP.md`

**If table exists:**
- Check the columns match the schema (user_id, email, name, is_premium, etc.)

---

### Step 3: Check RLS Policies

1. In Supabase Dashboard, go to **Authentication** → **Policies**
2. Select the `user_profiles` table
3. You should see 3 policies:
   - "Users can view their own profile" (SELECT)
   - "Users can update their own profile" (UPDATE)
   - "Users can insert their own profile" (INSERT)

**If policies are missing or different:**

Run this SQL in Supabase SQL Editor:

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON user_profiles;

-- Create permissive policies (allow all authenticated users)
CREATE POLICY "Users can view their own profile" ON user_profiles 
    FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON user_profiles 
    FOR UPDATE USING (true);

CREATE POLICY "Users can insert their own profile" ON user_profiles 
    FOR INSERT WITH CHECK (true);
```

---

### Step 4: Test Profile Creation Manually

Run this in your browser console after signing in:

```javascript
// Get current user info
const user = window.notesApp.user;
console.log('Current user:', user);

// Try to create profile manually
const testProfile = {
    user_id: user.id,
    email: user.email,
    name: user.name,
    is_premium: false,
    premium_since: null
};

// Test insert
supabaseClient
    .from('user_profiles')
    .insert(testProfile)
    .select()
    .then(result => {
        console.log('✅ Manual insert result:', result);
    })
    .catch(error => {
        console.error('❌ Manual insert error:', error);
    });
```

---

## 🐛 Common Issues & Fixes

### Issue 1: "relation 'user_profiles' does not exist"
**Cause:** Table hasn't been created  
**Fix:** Run SQL scripts from `SUPABASE_USER_PROFILES_SETUP.md`

### Issue 2: "new row violates row-level security policy"
**Cause:** RLS policies too restrictive  
**Fix:** Run the SQL above to create permissive policies

### Issue 3: "column 'X' does not exist"
**Cause:** Table schema doesn't match code  
**Fix:** Drop and recreate table with correct schema:

```sql
-- Drop existing table
DROP TABLE IF EXISTS user_profiles CASCADE;

-- Recreate with correct schema
CREATE TABLE user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL,
    name TEXT,
    is_premium BOOLEAN DEFAULT FALSE,
    premium_since TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create permissive policies
CREATE POLICY "Users can view their own profile" ON user_profiles 
    FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON user_profiles 
    FOR UPDATE USING (true);

CREATE POLICY "Users can insert their own profile" ON user_profiles 
    FOR INSERT WITH CHECK (true);
```

### Issue 4: Silent failures (no errors in console)
**Cause:** The ensureUserProfile function catches errors  
**Fix:** Check logs - it logs warnings even when catching errors

Look for:
```
⚠️ Continuing without user profile...
```

---

## 🔍 Check Current State

### In Browser Console:
```javascript
// Check if ensureUserProfile is being called
window.notesApp.ensureUserProfile();

// Check current user
console.log('User:', window.notesApp.user);

// Try to fetch existing profile
supabaseClient
    .from('user_profiles')
    .select('*')
    .eq('user_id', window.notesApp.user.id)
    .then(result => console.log('Existing profile:', result));
```

### In Supabase Dashboard:
1. Go to **Table Editor** → `user_profiles`
2. Click "Insert row" button
3. Manually try to insert a test row
4. If insert fails, check the error message

---

## ✅ Verification Checklist

Run through this checklist:

- [ ] `user_profiles` table exists in Supabase
- [ ] Table has all required columns (user_id, email, name, is_premium, premium_since, created_at, updated_at)
- [ ] RLS is enabled on the table
- [ ] RLS policies exist and allow INSERT
- [ ] Browser console shows "Ensuring user profile exists..." when signing in
- [ ] No errors in browser console about user_profiles
- [ ] Supabase API URL and Key are correct in the web app

---

## 🚀 Quick Fix (If Everything Else Fails)

If you just want it to work quickly, disable RLS temporarily:

```sql
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
```

**⚠️ Warning:** This makes all profiles public! Only use for testing.

To re-enable:
```sql
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
```

---

## 📞 What to Share

If you need help, please share:

1. **Browser console logs** when signing in
2. **Supabase error messages** (if any)
3. **Screenshot** of user_profiles table in Supabase
4. **RLS policies** screenshot from Supabase

This will help diagnose the exact issue!

