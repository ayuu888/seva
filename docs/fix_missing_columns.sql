-- Fix missing database columns
-- Run this in Supabase SQL Editor

-- Add missing feedback column to event_feedback table
ALTER TABLE event_feedback ADD COLUMN IF NOT EXISTS feedback TEXT;

-- Add missing user_id column to event_feedback table if it doesn't exist
ALTER TABLE event_feedback ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE SET NULL;

-- Add missing verified column to volunteer_hours table
ALTER TABLE volunteer_hours ADD COLUMN IF NOT EXISTS verified BOOLEAN DEFAULT FALSE;

-- Ensure all required columns exist in existing tables
DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'event_feedback') THEN
        ALTER TABLE event_feedback ADD COLUMN IF NOT EXISTS feedback TEXT;
        ALTER TABLE event_feedback ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE SET NULL;
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'volunteer_hours') THEN
        ALTER TABLE volunteer_hours ADD COLUMN IF NOT EXISTS verified BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- Add any other missing columns that might be needed
DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_follows') THEN
        -- This table might not exist, so we'll create it if needed
        CREATE TABLE IF NOT EXISTS user_follows (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
            following_id UUID REFERENCES users(id) ON DELETE CASCADE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(follower_id, following_id)
        );
    END IF;
END $$;

DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'volunteer_hours') THEN
        -- This table might not exist, so we'll create it if needed
        CREATE TABLE IF NOT EXISTS volunteer_hours (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            event_id UUID REFERENCES events(id) ON DELETE CASCADE,
            hours DECIMAL(5, 2) NOT NULL,
            date DATE NOT NULL,
            description TEXT,
            verified BOOLEAN DEFAULT FALSE,
            verified_by UUID REFERENCES users(id) ON DELETE SET NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
    END IF;
END $$;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_following ON user_follows(following_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_hours_user ON volunteer_hours(user_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_hours_event ON volunteer_hours(event_id);

DO $$
BEGIN
    RAISE NOTICE 'Missing columns and tables have been added successfully!';
END $$;
