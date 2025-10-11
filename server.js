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
        console.log('SUPABASE_URL:', process.env.SUPABASE_URL || 'NOT SET');
        console.log('SUPABASE_ANON_KEY:', process.env.SUPABASE_ANON_KEY ? 'SET' : 'NOT SET');
        
        // Replace placeholder values with environment variables
        html = html.replace(
            'https://your-project-id.supabase.co',
            process.env.SUPABASE_URL || 'https://your-project-id.supabase.co'
        );
        
        html = html.replace(
            'your-anon-key-here',
            process.env.SUPABASE_ANON_KEY || 'your-anon-key-here'
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
