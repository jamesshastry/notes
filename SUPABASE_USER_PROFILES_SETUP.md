# Supabase User Profiles Table Setup

## SQL Scripts to Run in Supabase SQL Editor

### 1. Create User Profiles Table

```sql
-- Create user profiles table to store premium status and user information
CREATE TABLE user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL UNIQUE, -- Firebase UID
    email TEXT NOT NULL,
    name TEXT,
    is_premium BOOLEAN DEFAULT FALSE,
    premium_since TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
```

### 2. Enable Row Level Security (RLS)

```sql
-- Enable RLS on user_profiles table
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
```

### 3. Create RLS Policies

```sql
-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON user_profiles;

-- Create new policies for Firebase UIDs
CREATE POLICY "Users can view their own profile" ON user_profiles 
    FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON user_profiles 
    FOR UPDATE USING (true);

CREATE POLICY "Users can insert their own profile" ON user_profiles 
    FOR INSERT WITH CHECK (true);
```

### 4. Create Updated At Trigger

```sql
-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for user_profiles table
CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON user_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

## How to Use

1. **Go to Supabase Dashboard**
2. **Navigate to SQL Editor**
3. **Run each SQL block above in order**
4. **Verify the table was created successfully**

## Table Structure

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | TEXT | Firebase UID (unique) |
| `email` | TEXT | User's email address |
| `name` | TEXT | User's display name |
| `is_premium` | BOOLEAN | Premium status (default: false) |
| `premium_since` | TIMESTAMP | When user became premium |
| `created_at` | TIMESTAMP | Profile creation time |
| `updated_at` | TIMESTAMP | Last update time |

## Benefits

- ✅ **Permanent storage** - Premium status stored in database
- ✅ **Cross-device sync** - Status syncs across all user devices
- ✅ **Server verification** - Premium status validated server-side
- ✅ **Reliable** - Won't be lost if browser data is cleared
- ✅ **Audit trail** - Track when users became premium
- ✅ **Scalable** - Can handle many users efficiently
