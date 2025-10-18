-- Quick Fix for User Profiles Table
-- Run this entire script in Supabase SQL Editor

-- Step 1: Drop existing table if it has issues
DROP TABLE IF EXISTS user_profiles CASCADE;

-- Step 2: Create fresh table with correct schema
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

-- Step 3: Create indexes for performance
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_email ON user_profiles(email);

-- Step 4: Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Step 5: Create permissive policies (allow all operations)
CREATE POLICY "Allow all SELECT" ON user_profiles 
    FOR SELECT USING (true);

CREATE POLICY "Allow all INSERT" ON user_profiles 
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all UPDATE" ON user_profiles 
    FOR UPDATE USING (true);

CREATE POLICY "Allow all DELETE" ON user_profiles 
    FOR DELETE USING (true);

-- Step 6: Create trigger for auto-updating updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON user_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Step 7: Verify setup
SELECT 'Table created successfully!' AS status;
SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'user_profiles';
SELECT policyname FROM pg_policies WHERE tablename = 'user_profiles';

