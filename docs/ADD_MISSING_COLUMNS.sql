-- ================================================
-- ADD MISSING COLUMNS FOR COMPLETE FUNCTIONALITY
-- Run this in your Supabase SQL Editor
-- ================================================

-- 1. Update event_attendees table to include registered_at
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'event_attendees') THEN
        ALTER TABLE event_attendees ADD COLUMN IF NOT EXISTS registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        CREATE INDEX IF NOT EXISTS idx_event_attendees_registered_at ON event_attendees(registered_at DESC);
    END IF;
END $$;

-- 2. Update conversation_participants table to include last_read_at
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'conversation_participants') THEN
        ALTER TABLE conversation_participants ADD COLUMN IF NOT EXISTS last_read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        CREATE INDEX IF NOT EXISTS idx_conversation_participants_last_read ON conversation_participants(conversation_id, last_read_at);
    END IF;
END $$;

-- 3. Create Supabase Storage bucket for images (if not exists)
-- NOTE: This must be done manually in Supabase Dashboard:
-- 1. Go to Storage section
-- 2. Create new bucket named "images"
-- 3. Make it PUBLIC
-- 4. Set file size limit and allowed file types (jpg, png, gif, webp)

