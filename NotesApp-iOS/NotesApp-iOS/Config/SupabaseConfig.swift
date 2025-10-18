import Foundation

struct SupabaseConfig {
    // TODO: Replace with your actual Supabase configuration
    // Get these values from your Supabase Dashboard → Settings → API
    
    static let url = "YOUR_SUPABASE_URL"
    // Example: "https://xxxxxxxxxxxxx.supabase.co"
    
    static let anonKey = "YOUR_SUPABASE_ANON_KEY"
    // Example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    
    // How to find these values:
    // 1. Go to https://app.supabase.com/
    // 2. Select your project
    // 3. Go to Settings → API
    // 4. Copy "Project URL" to `url`
    // 5. Copy "anon public" key to `anonKey`
}

