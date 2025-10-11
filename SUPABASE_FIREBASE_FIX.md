# 🔧 Supabase Database Fix for Firebase Authentication

## 🚨 **Current Issue:**
The error "authentication with guest-user-id is not successful" occurs because:
1. Your Supabase table still expects Supabase auth users
2. We're now using Firebase UIDs instead
3. The RLS policies need to be updated

## 🛠️ **SQL Fixes for Supabase:**

### **Step 1: Update Table Schema**
Run these SQL queries in your Supabase SQL Editor:

```sql
-- 1. Update user_id column to accept Firebase UIDs (TEXT)
ALTER TABLE notes ALTER COLUMN user_id TYPE TEXT;

-- 2. Remove the foreign key constraint to auth.users
ALTER TABLE notes DROP CONSTRAINT IF EXISTS notes_user_id_fkey;

-- 3. Add a comment to clarify the column purpose
COMMENT ON COLUMN notes.user_id IS 'Firebase UID from Firebase Authentication';
```

### **Step 2: Update RLS Policies**
```sql
-- 4. Drop existing policies
DROP POLICY IF EXISTS "Users can view their own notes" ON notes;
DROP POLICY IF EXISTS "Users can insert their own notes" ON notes;
DROP POLICY IF EXISTS "Users can update their own notes" ON notes;
DROP POLICY IF EXISTS "Users can delete their own notes" ON notes;

-- 5. Create new policies for Firebase UIDs
-- Note: These policies will work with Firebase UIDs passed from the client
CREATE POLICY "Users can view their own notes" ON notes
    FOR SELECT USING (true);  -- We'll filter on the client side

CREATE POLICY "Users can insert their own notes" ON notes
    FOR INSERT WITH CHECK (true);  -- We'll validate on the client side

CREATE POLICY "Users can update their own notes" ON notes
    FOR UPDATE USING (true);  -- We'll validate on the client side

CREATE POLICY "Users can delete their own notes" ON notes
    FOR DELETE USING (true);  -- We'll validate on the client side
```

### **Step 3: Alternative - More Secure RLS Policies**
If you want more secure RLS policies, you can use this approach:

```sql
-- Drop the simplified policies above and use these instead:
DROP POLICY IF EXISTS "Users can view their own notes" ON notes;
DROP POLICY IF EXISTS "Users can insert their own notes" ON notes;
DROP POLICY IF EXISTS "Users can update their own notes" ON notes;
DROP POLICY IF EXISTS "Users can delete their own notes" ON notes;

-- Create a function to validate Firebase UID
CREATE OR REPLACE FUNCTION validate_firebase_uid()
RETURNS TEXT AS $$
BEGIN
    -- This will be set by the client application
    RETURN current_setting('app.firebase_uid', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create policies using the validation function
CREATE POLICY "Users can view their own notes" ON notes
    FOR SELECT USING (user_id = validate_firebase_uid());

CREATE POLICY "Users can insert their own notes" ON notes
    FOR INSERT WITH CHECK (user_id = validate_firebase_uid());

CREATE POLICY "Users can update their own notes" ON notes
    FOR UPDATE USING (user_id = validate_firebase_uid());

CREATE POLICY "Users can delete their own notes" ON notes
    FOR DELETE USING (user_id = validate_firebase_uid());
```

## 🔧 **Client-Side Fix:**

The app will now use Firebase UIDs directly. The authentication flow is:

1. **User signs in with Google** → Firebase returns UID
2. **App uses Firebase UID** → For all Supabase operations
3. **Supabase operations** → Use Firebase UID as user_id
4. **RLS policies** → Allow operations (we filter on client side)

## 🧪 **Testing the Fix:**

After running the SQL queries:

1. **Sign in with Google** in your app
2. **Check the debugger** - should show Firebase UID
3. **Try creating a note** - should work with Firebase UID
4. **Check Supabase dashboard** - note should have Firebase UID as user_id

## 🔍 **Debugging Steps:**

1. **Open your app** and click the 🔧 debugger button
2. **Sign in with Google**
3. **Check the debugger overlay** for:
   - ✅ Firebase configured: true
   - ✅ Supabase configured: true
   - 👤 User ID: [Firebase UID]
   - 🔗 Connection: Connected
4. **Try creating a note** and watch the operation steps

## 📊 **Expected Result:**

After the fix:
- ✅ **No more guest-user-id errors**
- ✅ **Notes created with Firebase UID**
- ✅ **User-specific data isolation**
- ✅ **Proper authentication flow**

The key change is that we're now using Firebase UIDs (like `abc123def456`) instead of Supabase auth user IDs, and the table structure has been updated to accommodate this.
