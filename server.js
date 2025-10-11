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
        console.log('GOOGLE_ANALYTICS_ID:', process.env.GOOGLE_ANALYTICS_ID ? 'SET' : 'NOT SET');
        
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
        
        // Replace Google Analytics configuration placeholders
        html = html.replace(
            'YOUR_GOOGLE_ANALYTICS_ID',
            process.env.GOOGLE_ANALYTICS_ID || 'YOUR_GOOGLE_ANALYTICS_ID'
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

// Add JSON parsing middleware for POST requests
app.use(express.json());

// Payment endpoint to handle Dodo Payments API calls (server-side to avoid CORS)
app.post('/api/create-checkout', async (req, res) => {
    try {
        console.log('💳 Server-side payment request received');
        console.log('📊 Request body:', req.body);
        
        const { userEmail, userName, userId } = req.body;
        
        // Validate required environment variables
        const apiKey = process.env.DODO_PAYMENTS_API_KEY;
        const productId = process.env.DODO_PRODUCT_ID;
        
        if (!apiKey || apiKey === 'YOUR_DODO_PAYMENTS_API_KEY') {
            throw new Error('DODO_PAYMENTS_API_KEY not configured');
        }
        
        if (!productId || productId === 'YOUR_DODO_PRODUCT_ID') {
            throw new Error('DODO_PRODUCT_ID not configured');
        }
        
        console.log('✅ Environment variables validated');
        
        // Prepare payment data according to Dodo Payments API format
        const paymentData = {
            // Products to sell - use IDs from your Dodo Payments dashboard
            product_cart: [
                {
                    product_id: productId,
                    quantity: 1
                }
            ],
            
            // Pre-fill customer information to reduce checkout friction
            customer: {
                email: userEmail,
                name: userName || 'Notes App User'
                // phone_number removed - let user enter it during checkout
            },
            
            // Billing address for tax calculation and compliance
            billing_address: {
                street: '123 Main St',
                city: 'San Francisco',
                state: 'CA',
                country: 'US', // Required: ISO 3166-1 alpha-2 country code
                zipcode: '94102'
            },
            
            // Where to redirect after successful payment
            return_url: `${req.protocol}://${req.get('host')}?payment=success`,
            
            // Custom data for your internal tracking
            metadata: {
                user_id: userId,
                user_email: userEmail,
                app_name: 'Notes App',
                subscription_type: 'premium'
            }
        };
        
        console.log('📊 Payment data prepared:', paymentData);
        console.log('🌐 Making API request to Dodo Payments...');
        
        // Make the API call to Dodo Payments
        const response = await fetch('https://test.dodopayments.com/checkouts', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`,
            },
            body: JSON.stringify(paymentData)
        });
        
        console.log('📡 Dodo Payments API response status:', response.status);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('❌ Dodo Payments API error:', errorText);
            throw new Error(`Dodo Payments API error: ${response.status} ${response.statusText}. Details: ${errorText}`);
        }
        
        const checkoutData = await response.json();
        console.log('✅ Checkout session created:', checkoutData);
        
        // Return the checkout data to the client
        res.json({
            success: true,
            checkout_url: checkoutData.checkout_url,
            session_id: checkoutData.session_id,
            data: checkoutData
        });
        
    } catch (error) {
        console.error('❌ Server-side payment error:', error);
        res.status(500).json({
            success: false,
            error: error.message,
            details: 'Failed to create checkout session'
        });
    }
});

// Webhook endpoint for Dodo Payments subscription updates
app.post('/api/payments/webhook', async (req, res) => {
    try {
        console.log('🔔 Payment webhook received');
        console.log('📊 Webhook payload:', JSON.stringify(req.body, null, 2));
        
        // Verify webhook signature (if provided)
        const webhookSecret = process.env.DODO_WEBHOOK_SECRET;
        if (webhookSecret) {
            const signature = req.headers['x-dodo-signature'] || req.headers['dodo-signature'];
            if (signature) {
                console.log('✅ Webhook signature received:', signature);
                // Add signature verification logic here if needed
            }
        }
        
        const { data, type } = req.body;
        
        // Only process successful payments
        if (type === 'payment.succeeded' && data.status === 'succeeded') {
            console.log('✅ Processing successful payment webhook');
            
            const {
                subscription_id,
                payment_id,
                checkout_session_id,
                total_amount,
                currency,
                payment_method,
                status: payment_status,
                customer,
                metadata
            } = data;
            
            // Extract user information from metadata
            const userId = metadata?.user_id;
            const userEmail = metadata?.user_email || customer?.email;
            
            if (!userId || !userEmail) {
                console.error('❌ Missing user information in webhook payload');
                return res.status(400).json({
                    success: false,
                    error: 'Missing user information'
                });
            }
            
            console.log('👤 Processing subscription for user:', {
                userId,
                userEmail,
                subscriptionId: subscription_id,
                paymentId: payment_id
            });
            
            // Check if subscription already exists
            const { createClient } = require('@supabase/supabase-js');
            const supabase = createClient(
                process.env.SUPABASE_URL,
                process.env.SUPABASE_ANON_KEY
            );
            
            // Try to find existing subscription
            const { data: existingSubscription, error: selectError } = await supabase
                .from('subscription_status')
                .select('*')
                .eq('subscription_id', subscription_id)
                .single();
            
            if (selectError && selectError.code !== 'PGRST116') {
                console.error('❌ Error checking existing subscription:', selectError);
                throw selectError;
            }
            
            if (existingSubscription) {
                // Update existing subscription
                console.log('🔄 Updating existing subscription');
                const { data: updatedSubscription, error: updateError } = await supabase
                    .from('subscription_status')
                    .update({
                        status: true,
                        payment_id,
                        checkout_session_id,
                        total_amount,
                        currency,
                        payment_method,
                        payment_status,
                        updated_at: new Date().toISOString()
                    })
                    .eq('subscription_id', subscription_id)
                    .select();
                
                if (updateError) {
                    console.error('❌ Error updating subscription:', updateError);
                    throw updateError;
                }
                
                console.log('✅ Subscription updated successfully:', updatedSubscription);
            } else {
                // Create new subscription
                console.log('➕ Creating new subscription');
                const { data: newSubscription, error: insertError } = await supabase
                    .from('subscription_status')
                    .insert({
                        user_id: userId,
                        user_email: userEmail,
                        subscription_id,
                        status: true,
                        payment_id,
                        checkout_session_id,
                        total_amount,
                        currency,
                        payment_method,
                        payment_status
                    })
                    .select();
                
                if (insertError) {
                    console.error('❌ Error creating subscription:', insertError);
                    throw insertError;
                }
                
                console.log('✅ Subscription created successfully:', newSubscription);
            }
            
            // Return success response
            res.json({
                success: true,
                message: 'Subscription status updated successfully',
                subscription_id,
                user_id: userId,
                status: true
            });
            
        } else {
            console.log('ℹ️ Webhook received but not processing (not a successful payment)');
            res.json({
                success: true,
                message: 'Webhook received but not processed'
            });
        }
        
    } catch (error) {
        console.error('❌ Webhook processing error:', error);
        res.status(500).json({
            success: false,
            error: error.message,
            details: 'Failed to process webhook'
        });
    }
});

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
