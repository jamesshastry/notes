# Supabase Configuration Instructions

## 🗄️ Database Setup

### 1. Create Supabase Project
1. Go to https://supabase.com
2. Create a new project
3. Note your Project URL and anon key

### 2. Run SQL Queries
Execute these SQL queries in your Supabase SQL Editor:

```sql
-- Create the notes table
CREATE TABLE notes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    is_favorite BOOLEAN DEFAULT FALSE,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_notes_user_id ON notes(user_id);
CREATE INDEX idx_notes_created_at ON notes(created_at DESC);
CREATE INDEX idx_notes_is_favorite ON notes(is_favorite);

-- Enable Row Level Security
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own notes" ON notes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notes" ON notes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own notes" ON notes
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notes" ON notes
    FOR DELETE USING (auth.uid() = user_id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_notes_updated_at 
    BEFORE UPDATE ON notes 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

### 3. Update Configuration
Replace these values in your `index.html`:

```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

### 4. Authentication (Optional)
For production, implement proper authentication:

```javascript
// Sign up
const { data, error } = await supabaseClient.auth.signUp({
  email: 'user@example.com',
  password: 'password'
});

// Sign in
const { data, error } = await supabaseClient.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password'
});

// Sign out
const { error } = await supabaseClient.auth.signOut();
```

## 🚀 Deployment

Your app is now ready for deployment with Supabase integration!

### Features:
- ✅ Full CRUD operations with Supabase
- ✅ Row Level Security (RLS)
- ✅ User-specific data isolation
- ✅ Real-time updates (if needed)
- ✅ Automatic timestamps
- ✅ Favorites system
- ✅ Search and filtering
- ✅ Export/Import functionality

### Next Steps:
1. Set up Supabase project
2. Run SQL queries
3. Update configuration
4. Deploy to Render
5. Test functionality
