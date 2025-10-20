-- ================================================
-- MESSAGING SYSTEM SCHEMA (SAFE VERSION)
-- For Seva-Setu Platform - Handles existing objects
-- ================================================

-- ================================================
-- MESSAGING TABLES
-- ================================================

-- Conversations Table
CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT,
    type TEXT DEFAULT 'direct', -- 'direct', 'group', 'event', 'ngo'
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'conversations') THEN
        ALTER TABLE conversations ADD COLUMN IF NOT EXISTS name TEXT;
        ALTER TABLE conversations ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'direct';
        ALTER TABLE conversations ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES users(id) ON DELETE SET NULL;
        ALTER TABLE conversations ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        ALTER TABLE conversations ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create indexes safely
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_conversations_type') THEN
        CREATE INDEX idx_conversations_type ON conversations(type);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_conversations_last_message') THEN
        CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);
    END IF;
END $$;

-- Conversation Participants Table
CREATE TABLE IF NOT EXISTS conversation_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_read_at TIMESTAMP WITH TIME ZONE,
    role TEXT DEFAULT 'member', -- 'admin', 'member'
    UNIQUE(conversation_id, user_id)
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'conversation_participants') THEN
        ALTER TABLE conversation_participants ADD COLUMN IF NOT EXISTS last_read_at TIMESTAMP WITH TIME ZONE;
        ALTER TABLE conversation_participants ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'member';
    END IF;
END $$;

-- Create indexes safely
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_conversation_participants_conversation') THEN
        CREATE INDEX idx_conversation_participants_conversation ON conversation_participants(conversation_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_conversation_participants_user') THEN
        CREATE INDEX idx_conversation_participants_user ON conversation_participants(user_id);
    END IF;
END $$;

-- Messages Table
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    sender_name VARCHAR(255) NOT NULL,
    sender_avatar TEXT,
    content TEXT NOT NULL,
    message_type VARCHAR(50) DEFAULT 'text', -- 'text', 'image', 'file', 'video', 'system'
    file_url TEXT,
    file_name VARCHAR(255),
    file_size INTEGER,
    reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL,
    edited BOOLEAN DEFAULT FALSE,
    deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'messages') THEN
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS sender_name VARCHAR(255);
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS sender_avatar TEXT;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS message_type VARCHAR(50) DEFAULT 'text';
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS file_url TEXT;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS file_name VARCHAR(255);
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS file_size INTEGER;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS edited BOOLEAN DEFAULT FALSE;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS deleted BOOLEAN DEFAULT FALSE;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create indexes safely
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_messages_conversation') THEN
        CREATE INDEX idx_messages_conversation ON messages(conversation_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_messages_sender') THEN
        CREATE INDEX idx_messages_sender ON messages(sender_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_messages_created') THEN
        CREATE INDEX idx_messages_created ON messages(created_at DESC);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_messages_type') THEN
        CREATE INDEX idx_messages_type ON messages(message_type);
    END IF;
END $$;

-- Message Reactions Table
CREATE TABLE IF NOT EXISTS message_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    reaction VARCHAR(50) NOT NULL, -- emoji or reaction type
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(message_id, user_id, reaction)
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'message_reactions') THEN
        ALTER TABLE message_reactions ADD COLUMN IF NOT EXISTS reaction VARCHAR(50) NOT NULL DEFAULT '👍';
    END IF;
END $$;

-- Create indexes safely
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_message_reactions_message') THEN
        CREATE INDEX idx_message_reactions_message ON message_reactions(message_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_message_reactions_user') THEN
        CREATE INDEX idx_message_reactions_user ON message_reactions(user_id);
    END IF;
END $$;

-- Message Read Receipts Table
CREATE TABLE IF NOT EXISTS message_read_receipts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(message_id, user_id)
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'message_read_receipts') THEN
        ALTER TABLE message_read_receipts ADD COLUMN IF NOT EXISTS read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create indexes safely
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_message_read_receipts_message') THEN
        CREATE INDEX idx_message_read_receipts_message ON message_read_receipts(message_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_message_read_receipts_user') THEN
        CREATE INDEX idx_message_read_receipts_user ON message_read_receipts(user_id);
    END IF;
END $$;

-- Presence Table (Online/Offline Status)
CREATE TABLE IF NOT EXISTS presence (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'offline', -- 'online', 'offline', 'away', 'busy'
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'presence') THEN
        ALTER TABLE presence ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'offline';
        ALTER TABLE presence ADD COLUMN IF NOT EXISTS last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        ALTER TABLE presence ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create indexes safely
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_presence_status') THEN
        CREATE INDEX idx_presence_status ON presence(status);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_presence_last_seen') THEN
        CREATE INDEX idx_presence_last_seen ON presence(last_seen DESC);
    END IF;
END $$;

-- Typing Indicators Table
CREATE TABLE IF NOT EXISTS typing_indicators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    is_typing BOOLEAN DEFAULT FALSE,
    last_typed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(conversation_id, user_id)
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'typing_indicators') THEN
        ALTER TABLE typing_indicators ADD COLUMN IF NOT EXISTS is_typing BOOLEAN DEFAULT FALSE;
        ALTER TABLE typing_indicators ADD COLUMN IF NOT EXISTS last_typed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create indexes safely
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_typing_indicators_conversation') THEN
        CREATE INDEX idx_typing_indicators_conversation ON typing_indicators(conversation_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_typing_indicators_user') THEN
        CREATE INDEX idx_typing_indicators_user ON typing_indicators(user_id);
    END IF;
END $$;

-- ================================================
-- FUNCTIONS FOR MESSAGING SYSTEM
-- ================================================

-- Function to update conversation last message time
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations 
    SET last_message_at = NEW.created_at,
        updated_at = NOW()
    WHERE id = NEW.conversation_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updating conversation last message time
DROP TRIGGER IF EXISTS trigger_update_conversation_last_message ON messages;
CREATE TRIGGER trigger_update_conversation_last_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_conversation_last_message();

-- Function to update user presence
CREATE OR REPLACE FUNCTION update_user_presence()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO presence (user_id, status, last_seen, updated_at)
    VALUES (NEW.user_id, 'online', NOW(), NOW())
    ON CONFLICT (user_id) 
    DO UPDATE SET 
        status = 'online',
        last_seen = NOW(),
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to mark messages as read
CREATE OR REPLACE FUNCTION mark_messages_as_read(
    p_conversation_id UUID,
    p_user_id UUID,
    p_read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    -- Insert read receipts for all unread messages
    INSERT INTO message_read_receipts (message_id, user_id, read_at)
    SELECT m.id, p_user_id, p_read_at
    FROM messages m
    WHERE m.conversation_id = p_conversation_id
    AND m.sender_id != p_user_id
    AND NOT EXISTS (
        SELECT 1 FROM message_read_receipts mr 
        WHERE mr.message_id = m.id AND mr.user_id = p_user_id
    )
    ON CONFLICT (message_id, user_id) DO NOTHING;
    
    -- Update conversation participant last read time
    UPDATE conversation_participants 
    SET last_read_at = p_read_at
    WHERE conversation_id = p_conversation_id 
    AND user_id = p_user_id;
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- Drop existing function if it exists with different parameter name
DROP FUNCTION IF EXISTS get_unread_message_count(uuid);

-- Function to get unread message count for user
CREATE OR REPLACE FUNCTION get_unread_message_count(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    unread_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO unread_count
    FROM messages m
    JOIN conversation_participants cp ON m.conversation_id = cp.conversation_id
    WHERE cp.user_id = p_user_id
    AND m.sender_id != p_user_id
    AND m.deleted = FALSE
    AND NOT EXISTS (
        SELECT 1 FROM message_read_receipts mr 
        WHERE mr.message_id = m.id AND mr.user_id = p_user_id
    );
    
    RETURN COALESCE(unread_count, 0);
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- INITIAL DATA
-- ================================================

-- Create a system conversation for announcements (if not exists)
INSERT INTO conversations (id, name, type, created_by)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'System Announcements',
    'system',
    NULL
)
ON CONFLICT (id) DO NOTHING;

-- Add all users to system conversation (if they don't exist)
INSERT INTO conversation_participants (conversation_id, user_id, role)
SELECT 
    '00000000-0000-0000-0000-000000000001',
    u.id,
    'member'
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM conversation_participants cp 
    WHERE cp.conversation_id = '00000000-0000-0000-0000-000000000001' 
    AND cp.user_id = u.id
);

-- ================================================
-- COMMENTS AND DOCUMENTATION
-- ================================================

COMMENT ON TABLE conversations IS 'Chat conversations between users, groups, or event participants';
COMMENT ON TABLE conversation_participants IS 'Users participating in conversations with roles and read status';
COMMENT ON TABLE messages IS 'Individual messages within conversations with support for files and replies';
COMMENT ON TABLE message_reactions IS 'Emoji reactions to messages';
COMMENT ON TABLE message_read_receipts IS 'Track which users have read which messages';
COMMENT ON TABLE presence IS 'User online/offline status for real-time messaging';
COMMENT ON TABLE typing_indicators IS 'Real-time typing indicators for conversations';

COMMENT ON FUNCTION update_conversation_last_message() IS 'Automatically updates conversation last message timestamp when new messages are added';
COMMENT ON FUNCTION mark_messages_as_read(UUID, UUID, TIMESTAMP WITH TIME ZONE) IS 'Marks all messages in a conversation as read for a specific user';
COMMENT ON FUNCTION get_unread_message_count(UUID) IS 'Returns the total number of unread messages for a user across all conversations';
