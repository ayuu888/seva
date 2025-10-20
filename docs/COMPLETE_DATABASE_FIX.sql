-- ========================================================================================================
-- COMPLETE DATABASE FIX FOR SEVA-SETU
-- This script adds ALL missing tables and columns identified from error logs
-- Run this in your Supabase SQL Editor to fix all database-related errors
-- ========================================================================================================

-- ================================================
-- PART 1: CREATE MISSING TABLES
-- ================================================

-- 1. user_follows table - User-to-user following relationships
CREATE TABLE IF NOT EXISTS user_follows (
  follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID REFERENCES users(id) ON DELETE CASCADE,
  followed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
);

CREATE INDEX IF NOT EXISTS idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_following ON user_follows(following_id);

-- 2. volunteer_hours table - Volunteer time tracking
CREATE TABLE IF NOT EXISTS volunteer_hours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  volunteer_id UUID REFERENCES users(id) ON DELETE CASCADE,
  event_id UUID REFERENCES events(id) ON DELETE SET NULL,
  hours NUMERIC(5, 2) NOT NULL,
  description TEXT,
  verified_by UUID REFERENCES users(id) ON DELETE SET NULL,
  verified_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_volunteer_hours_volunteer ON volunteer_hours(volunteer_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_hours_event ON volunteer_hours(event_id);

-- 3. ngo_team_members table - NGO team member management
CREATE TABLE IF NOT EXISTS ngo_team_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member', -- 'admin', 'member', 'volunteer'
  permissions JSONB DEFAULT '{}',
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  invited_by UUID REFERENCES users(id) ON DELETE SET NULL,
  UNIQUE(ngo_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_ngo_team_members_ngo ON ngo_team_members(ngo_id);
CREATE INDEX IF NOT EXISTS idx_ngo_team_members_user ON ngo_team_members(user_id);
CREATE INDEX IF NOT EXISTS idx_ngo_team_members_role ON ngo_team_members(role);

-- 4. presence table - User online/offline status (if not exists from previous scripts)
CREATE TABLE IF NOT EXISTS presence (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'offline', -- 'online', 'offline', 'away'
  last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_presence_user_id ON presence(user_id);
CREATE INDEX IF NOT EXISTS idx_presence_status ON presence(status);

-- ================================================
-- PART 2: ADD MISSING COLUMNS TO EXISTING TABLES
-- ================================================

-- Add registered_at to event_attendees
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'event_attendees') THEN
        ALTER TABLE event_attendees ADD COLUMN IF NOT EXISTS registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        CREATE INDEX IF NOT EXISTS idx_event_attendees_registered_at ON event_attendees(registered_at DESC);
    END IF;
END $$;

-- Add last_read_at to conversation_participants
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'conversation_participants') THEN
        ALTER TABLE conversation_participants ADD COLUMN IF NOT EXISTS last_read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        CREATE INDEX IF NOT EXISTS idx_conversation_participants_last_read ON conversation_participants(conversation_id, last_read_at);
    END IF;
END $$;

-- ================================================
-- PART 3: CREATE HELPER FUNCTIONS
-- ================================================

-- Function to update presence with UPSERT (prevents duplicate key errors)
CREATE OR REPLACE FUNCTION update_user_presence(
    user_id_param UUID,
    status_param TEXT DEFAULT 'online'
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO presence (user_id, status, last_seen, updated_at)
    VALUES (user_id_param, status_param, NOW(), NOW())
    ON CONFLICT (user_id)
    DO UPDATE SET 
        status = status_param,
        last_seen = NOW(),
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to get user stats (posts, events, volunteer hours, followers, following)
CREATE OR REPLACE FUNCTION get_user_stats(user_id_param UUID)
RETURNS TABLE (
    posts_count BIGINT,
    events_count BIGINT,
    volunteer_hours_total NUMERIC,
    followers_count BIGINT,
    following_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM posts WHERE author_id = user_id_param),
        (SELECT COUNT(*) FROM event_attendees WHERE user_id = user_id_param),
        (SELECT COALESCE(SUM(hours), 0) FROM volunteer_hours WHERE volunteer_id = user_id_param),
        (SELECT COUNT(*) FROM user_follows WHERE following_id = user_id_param),
        (SELECT COUNT(*) FROM user_follows WHERE follower_id = user_id_param);
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- PART 4: VERIFY TABLES EXIST
-- ================================================

-- Check and report on table existence
DO $$
DECLARE
    tables_to_check TEXT[] := ARRAY[
        'users', 'ngos', 'posts', 'events', 'event_attendees',
        'user_follows', 'volunteer_hours', 'ngo_team_members',
        'presence', 'conversations', 'conversation_participants', 'messages'
    ];
    tbl_name TEXT;
    table_exists BOOLEAN;
BEGIN
    RAISE NOTICE '=== TABLE VERIFICATION ===';
    FOREACH tbl_name IN ARRAY tables_to_check
    LOOP
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = tbl_name
        ) INTO table_exists;
        
        IF table_exists THEN
            RAISE NOTICE '✓ Table "%" exists', tbl_name;
        ELSE
            RAISE WARNING '✗ Table "%" is MISSING', tbl_name;
        END IF;
    END LOOP;
    RAISE NOTICE '=== END VERIFICATION ===';
END $$;

-- ================================================
-- SUCCESS MESSAGE
-- ================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'DATABASE UPDATE COMPLETED SUCCESSFULLY!';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Added/Updated:';
    RAISE NOTICE '  ✓ user_follows table';
    RAISE NOTICE '  ✓ volunteer_hours table';
    RAISE NOTICE '  ✓ ngo_team_members table';
    RAISE NOTICE '  ✓ presence table';
    RAISE NOTICE '  ✓ event_attendees.registered_at column';
    RAISE NOTICE '  ✓ conversation_participants.last_read_at column';
    RAISE NOTICE '  ✓ Helper functions';
    RAISE NOTICE '';
    RAISE NOTICE 'Next Steps:';
    RAISE NOTICE '  1. Restart your backend server';
    RAISE NOTICE '  2. Create "images" bucket in Supabase Storage';
    RAISE NOTICE '  3. Test all features';
    RAISE NOTICE '';
END $$;

