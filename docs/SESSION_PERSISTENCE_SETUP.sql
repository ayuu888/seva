-- Session Persistence Setup for Seva-Setu
-- Run this in your Supabase SQL Editor

-- 1. Create sessions table for JWT token management
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_accessed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_agent TEXT,
    ip_address TEXT,
    is_active BOOLEAN DEFAULT true
);

-- 2. Create presence table for user online status
CREATE TABLE IF NOT EXISTS presence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'offline', -- offline, online, away, busy
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create user_follows table for user following system
CREATE TABLE IF NOT EXISTS user_follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(follower_id, following_id)
);

-- 4. Add missing columns to event_attendees table
ALTER TABLE event_attendees ADD COLUMN IF NOT EXISTS registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE event_attendees ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'registered'; -- registered, checked_in, cancelled
ALTER TABLE event_attendees ADD COLUMN IF NOT EXISTS checked_in_at TIMESTAMP WITH TIME ZONE;

-- 5. Create volunteer_hours table for tracking volunteer time
CREATE TABLE IF NOT EXISTS volunteer_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    volunteer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    hours DECIMAL(4,2) NOT NULL DEFAULT 0,
    date_worked DATE NOT NULL,
    description TEXT,
    verified_by UUID REFERENCES users(id) ON DELETE SET NULL,
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_sessions_active ON sessions(is_active);

CREATE INDEX IF NOT EXISTS idx_presence_user_id ON presence(user_id);
CREATE INDEX IF NOT EXISTS idx_presence_status ON presence(status);

CREATE INDEX IF NOT EXISTS idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_following ON user_follows(following_id);

CREATE INDEX IF NOT EXISTS idx_event_attendees_user ON event_attendees(user_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_event ON event_attendees(event_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_status ON event_attendees(status);

CREATE INDEX IF NOT EXISTS idx_volunteer_hours_volunteer ON volunteer_hours(volunteer_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_hours_event ON volunteer_hours(event_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_hours_date ON volunteer_hours(date_worked);

-- 7. Create function to clean up expired sessions
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS void AS $$
BEGIN
    DELETE FROM sessions WHERE expires_at < NOW() OR is_active = false;
END;
$$ LANGUAGE plpgsql;

-- 8. Create function to update last accessed time
CREATE OR REPLACE FUNCTION update_session_access(session_token_param TEXT)
RETURNS void AS $$
BEGIN
    UPDATE sessions 
    SET last_accessed = NOW() 
    WHERE session_token = session_token_param AND is_active = true;
END;
$$ LANGUAGE plpgsql;

-- 9. Create function to update user presence
CREATE OR REPLACE FUNCTION update_user_presence(user_id_param UUID, status_param TEXT)
RETURNS void AS $$
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
