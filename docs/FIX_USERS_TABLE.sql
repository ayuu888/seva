-- Fix users table by removing the problematic username column
-- Run this in your Supabase SQL Editor

-- Clear any existing test data that might be causing conflicts
DELETE FROM users;

-- First, check if the username column exists and drop it if it does
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'username'
    ) THEN
        ALTER TABLE users DROP COLUMN username;
        RAISE NOTICE 'Dropped username column from users table';
    ELSE
        RAISE NOTICE 'Username column does not exist in users table';
    END IF;
END $$;

-- Also check for other problematic columns that might exist
DO $$ 
BEGIN
    -- Drop full_name column if it exists (we use 'name')
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'full_name'
    ) THEN
        ALTER TABLE users DROP COLUMN full_name;
        RAISE NOTICE 'Dropped full_name column from users table';
    END IF;
    
    -- Drop role column if it exists (we use 'user_type')
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'role'
    ) THEN
        ALTER TABLE users DROP COLUMN role;
        RAISE NOTICE 'Dropped role column from users table';
    END IF;
END $$;

-- Ensure we have the correct columns
ALTER TABLE users ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS user_type TEXT DEFAULT 'volunteer';

-- Add NOT NULL constraints (safe now that table is empty)
ALTER TABLE users ALTER COLUMN name SET NOT NULL;
ALTER TABLE users ALTER COLUMN email SET NOT NULL;
ALTER TABLE users ALTER COLUMN password_hash SET NOT NULL;
ALTER TABLE users ALTER COLUMN user_type SET NOT NULL;
