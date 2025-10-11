const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware to inject environment variables into HTML
const injectEnvVars = (req, res, next) => {
    if (req.path === '/' || req.path === '/index.html') {
        const indexPath = path.join(__dirname, 'index.html');
        let html = fs.readFileSync(indexPath, 'utf8');
        
        // Log environment variables for debugging
        console.log('🔧 Environment Variables:');
        console.log('FIREBASE_API_KEY:', process.env.FIREBASE_API_KEY ? 'SET' : 'NOT SET');
        console.log('FIREBASE_AUTH_DOMAIN:', process.env.FIREBASE_AUTH_DOMAIN || 'NOT SET');
        console.log('FIREBASE_PROJECT_ID:', process.env.FIREBASE_PROJECT_ID || 'NOT SET');
        console.log('FIREBASE_STORAGE_BUCKET:', process.env.FIREBASE_STORAGE_BUCKET || 'NOT SET');
        console.log('FIREBASE_MESSAGING_SENDER_ID:', process.env.FIREBASE_MESSAGING_SENDER_ID || 'NOT SET');
        console.log('FIREBASE_APP_ID:', process.env.FIREBASE_APP_ID || 'NOT SET');
        console.log('SUPABASE_URL:', process.env.SUPABASE_URL || 'NOT SET');
        console.log('SUPABASE_ANON_KEY:', process.env.SUPABASE_ANON_KEY ? 'SET' : 'NOT SET');
        console.log('DODO_PAYMENTS_API_KEY:', process.env.DODO_PAYMENTS_API_KEY ? 'SET' : 'NOT SET');
        console.log('DODO_PRODUCT_ID:', process.env.DODO_PRODUCT_ID ? 'SET' : 'NOT SET');
        console.log('DODO_WEBHOOK_SECRET:', process.env.DODO_WEBHOOK_SECRET ? 'SET' : 'NOT SET');
        
        // Replace Firebase configuration placeholders
        html = html.replace(
            'your-firebase-api-key',
            process.env.FIREBASE_API_KEY || 'your-firebase-api-key'
        );
        
        html = html.replace(
            'your-project-id.firebaseapp.com',
            process.env.FIREBASE_AUTH_DOMAIN || 'your-project-id.firebaseapp.com'
        );
        
        html = html.replace(
            'your-project-id',
            process.env.FIREBASE_PROJECT_ID || 'your-project-id'
        );
        
        html = html.replace(
            'your-project-id.appspot.com',
            process.env.FIREBASE_STORAGE_BUCKET || 'your-project-id.appspot.com'
        );
        
        html = html.replace(
            'your-sender-id',
            process.env.FIREBASE_MESSAGING_SENDER_ID || 'your-sender-id'
        );
        
        html = html.replace(
            'your-app-id',
            process.env.FIREBASE_APP_ID || 'your-app-id'
        );
        
        // Replace Supabase configuration placeholders
        html = html.replace(
            'https://your-project-id.supabase.co',
            process.env.SUPABASE_URL || 'https://your-project-id.supabase.co'
        );
        
        html = html.replace(
            'your-anon-key-here',
            process.env.SUPABASE_ANON_KEY || 'your-anon-key-here'
        );
        
        // Replace Dodo Payments configuration placeholders
        html = html.replace(
            'YOUR_DODO_PAYMENTS_API_KEY',
            process.env.DODO_PAYMENTS_API_KEY || 'YOUR_DODO_PAYMENTS_API_KEY'
        );
        
        html = html.replace(
            'YOUR_DODO_PRODUCT_ID',
            process.env.DODO_PRODUCT_ID || 'YOUR_DODO_PRODUCT_ID'
        );
        
        res.send(html);
    } else {
        next();
    }
};

// Use the middleware before serving static files
app.use(injectEnvVars);

// Serve static files from the root directory
app.use(express.static('.'));

// Serve the main HTML file for all other routes (SPA behavior)
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Start the server
app.listen(PORT, () => {
    console.log(`📝 Smart Notes App running on port ${PORT}`);
    console.log(`🌐 Access your notes at: http://localhost:${PORT}`);
    console.log(`📱 Features: Create, Read, Update, Delete notes with Supabase database`);
    console.log(`🔧 Supabase URL: ${process.env.SUPABASE_URL || 'Not set'}`);
    console.log(`🔑 Supabase Key: ${process.env.SUPABASE_ANON_KEY ? 'Set' : 'Not set'}`);
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
    console.log('🛑 SIGTERM received, shutting down gracefully');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('🛑 SIGINT received, shutting down gracefully');
    process.exit(0);
});
