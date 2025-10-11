# 🔧 Environment Variables Setup for Render

## 📋 Required Environment Variables

Set these environment variables in your Render dashboard:

### **1. SUPABASE_URL**
- **Variable Name**: `SUPABASE_URL`
- **Value**: Your Supabase project URL
- **Format**: `https://your-project-id.supabase.co`
- **Example**: `https://abcdefghijklmnop.supabase.co`

### **2. SUPABASE_ANON_KEY**
- **Variable Name**: `SUPABASE_ANON_KEY`
- **Value**: Your Supabase anonymous/public key
- **Format**: Long JWT token starting with `eyJ...`
- **Example**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYzNDU2Nzg5MCwiZXhwIjoxOTUwMTQzODkwfQ.example_signature`

## 🚀 How to Set Environment Variables in Render

### **Step 1: Get Supabase Credentials**
1. Go to your Supabase project dashboard
2. Click **Settings** → **API**
3. Copy:
   - **Project URL** (for `SUPABASE_URL`)
   - **anon/public key** (for `SUPABASE_ANON_KEY`)

### **Step 2: Add to Render Dashboard**
1. Go to https://render.com
2. Select your **smart-notes-app** service
3. Click on **Environment** tab
4. Click **Add Environment Variable**
5. Add both variables:

```
Name: SUPABASE_URL
Value: https://your-project-id.supabase.co

Name: SUPABASE_ANON_KEY
Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### **Step 3: Redeploy**
1. Click **Manual Deploy** → **Deploy latest commit**
2. Wait for deployment to complete
3. Check logs to verify environment variables are loaded

## 🔍 Verification

After deployment, check your Render logs. You should see:
```
🔧 Supabase URL: https://your-project-id.supabase.co
🔑 Supabase Key: Set
```

## 🛠️ How It Works

The server automatically injects environment variables into your HTML:
- Server reads `SUPABASE_URL` and `SUPABASE_ANON_KEY` from environment
- Replaces placeholder values in HTML with actual values
- Client-side JavaScript uses the injected values to connect to Supabase

## 🔒 Security Notes

- **SUPABASE_ANON_KEY** is safe to expose (it's designed for client-side use)
- **SUPABASE_URL** is also safe to expose (it's your public API endpoint)
- Row Level Security (RLS) in Supabase protects your data
- Users can only access their own notes

## 🚨 Troubleshooting

### **Environment Variables Not Working?**
1. Check Render logs for environment variable status
2. Verify variable names are exactly: `SUPABASE_URL` and `SUPABASE_ANON_KEY`
3. Ensure no extra spaces in variable values
4. Redeploy after adding variables

### **Database Connection Issues?**
1. Verify Supabase project is active
2. Check if RLS policies are correctly set
3. Ensure SQL queries were executed in Supabase
4. Test with Supabase dashboard to verify data

## 📊 Expected Result

Once environment variables are set:
- ✅ App connects to Supabase database
- ✅ Users can create, read, update, delete notes
- ✅ Data persists across sessions
- ✅ Each user sees only their own notes
- ✅ Favorites and search work with database

Your Smart Notes App will be fully functional with Supabase! 🎉
