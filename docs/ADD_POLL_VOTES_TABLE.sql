-- ================================================
-- ADD POLL VOTES TABLE
-- This script adds the poll_votes table for tracking user votes on polls
-- Run this in your Supabase SQL Editor.
-- ================================================

-- Create poll_votes table
CREATE TABLE IF NOT EXISTS poll_votes (
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  option_index INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (post_id, user_id)
);

-- Create indexes for efficient lookups
CREATE INDEX IF NOT EXISTS idx_poll_votes_post ON poll_votes(post_id);
CREATE INDEX IF NOT EXISTS idx_poll_votes_user ON poll_votes(user_id);
CREATE INDEX IF NOT EXISTS idx_poll_votes_created_at ON poll_votes(created_at DESC);

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Poll votes table created successfully!';
END $$;

