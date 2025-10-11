# Supabase Subscription Tracking Setup

## SQL Scripts to Run in Supabase SQL Editor

### 1. Create Subscription Status Table

```sql
-- Create subscription status table to track user premium subscriptions
CREATE TABLE subscription_status (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL, -- Firebase UID
    user_email TEXT NOT NULL,
    subscription_id TEXT UNIQUE, -- Dodo Payments subscription ID
    status BOOLEAN DEFAULT FALSE, -- true = premium, false = free
    payment_id TEXT, -- Dodo Payments payment ID
    checkout_session_id TEXT, -- Dodo Payments checkout session ID
    total_amount INTEGER, -- Payment amount in smallest currency unit
    currency TEXT, -- Payment currency (e.g., 'INR')
    payment_method TEXT, -- Payment method (e.g., 'card')
    payment_status TEXT, -- Payment status (e.g., 'succeeded')
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP -- Subscription expiration (if applicable)
);

-- Create indexes for faster lookups
CREATE INDEX idx_subscription_status_user_id ON subscription_status(user_id);
CREATE INDEX idx_subscription_status_subscription_id ON subscription_status(subscription_id);
CREATE INDEX idx_subscription_status_user_email ON subscription_status(user_email);
CREATE INDEX idx_subscription_status_status ON subscription_status(status);
```

### 2. Enable Row Level Security (RLS)

```sql
-- Enable RLS on subscription_status table
ALTER TABLE subscription_status ENABLE ROW LEVEL SECURITY;
```

### 3. Create RLS Policies

```sql
-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own subscription" ON subscription_status;
DROP POLICY IF EXISTS "Users can update their own subscription" ON subscription_status;
DROP POLICY IF EXISTS "Users can insert their own subscription" ON subscription_status;
DROP POLICY IF EXISTS "Webhook can manage all subscriptions" ON subscription_status;

-- Create policies for Firebase UIDs
CREATE POLICY "Users can view their own subscription" ON subscription_status 
    FOR SELECT USING (true);

CREATE POLICY "Users can update their own subscription" ON subscription_status 
    FOR UPDATE USING (true);

CREATE POLICY "Users can insert their own subscription" ON subscription_status 
    FOR INSERT WITH CHECK (true);

-- Allow webhook to manage all subscriptions (for payment processing)
CREATE POLICY "Webhook can manage all subscriptions" ON subscription_status 
    FOR ALL USING (true) WITH CHECK (true);
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

-- Create trigger for subscription_status table
CREATE TRIGGER update_subscription_status_updated_at 
    BEFORE UPDATE ON subscription_status 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

## Table Structure

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | TEXT | Firebase UID |
| `user_email` | TEXT | User's email address |
| `subscription_id` | TEXT | Dodo Payments subscription ID (unique) |
| `status` | BOOLEAN | Premium status (true = premium, false = free) |
| `payment_id` | TEXT | Dodo Payments payment ID |
| `checkout_session_id` | TEXT | Dodo Payments checkout session ID |
| `total_amount` | INTEGER | Payment amount in smallest currency unit |
| `currency` | TEXT | Payment currency |
| `payment_method` | TEXT | Payment method |
| `payment_status` | TEXT | Payment status |
| `created_at` | TIMESTAMP | Record creation time |
| `updated_at` | TIMESTAMP | Last update time |
| `expires_at` | TIMESTAMP | Subscription expiration |

## Webhook Integration

The webhook endpoint will:
1. **Receive payment notifications** from Dodo Payments
2. **Extract subscription_id** from webhook payload
3. **Update subscription status** in the database
4. **Set status to true** for successful payments
5. **Store payment details** for audit trail

## Benefits

- ✅ **Real-time updates** - Subscription status updated via webhook
- ✅ **Audit trail** - Complete payment history stored
- ✅ **Cross-device sync** - Status syncs across all user devices
- ✅ **Reliable** - Database-backed subscription tracking
- ✅ **Scalable** - Can handle many users and subscriptions
