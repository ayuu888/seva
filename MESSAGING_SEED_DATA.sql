-- Messaging Seed Data for Seva Setu
-- Run this in Supabase SQL Editor to populate conversations and messages

-- ============================================================================
-- CREATE TABLES (if not already created)
-- ============================================================================

CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT DEFAULT 'direct',
  name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS conversation_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(conversation_id, user_id)
);

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text',
  file_url TEXT,
  file_name TEXT,
  file_size INTEGER,
  reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS message_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  reaction TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(message_id, user_id, reaction)
);

CREATE TABLE IF NOT EXISTS typing_indicators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  is_typing BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(conversation_id, user_id)
);

-- ============================================================================
-- CREATE INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_conversations_type ON conversations(type);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_conversation ON conversation_participants(conversation_id);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_user ON conversation_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_message_reactions_message ON message_reactions(message_id);
CREATE INDEX IF NOT EXISTS idx_typing_indicators_conversation ON typing_indicators(conversation_id);

-- ============================================================================
-- INSERT SAMPLE CONVERSATIONS
-- ============================================================================

-- Get user IDs (adjust these based on your actual user IDs)
-- You can find user IDs by running: SELECT id, name, email FROM users LIMIT 10;

-- Create a conversation between first two users
INSERT INTO conversations (id, type, name) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'direct', 'Direct Message'),
  ('550e8400-e29b-41d4-a716-446655440002', 'direct', 'Direct Message'),
  ('550e8400-e29b-41d4-a716-446655440003', 'group', 'Volunteer Team')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- INSERT SAMPLE MESSAGES
-- ============================================================================

-- Sample messages for first conversation
INSERT INTO messages (conversation_id, sender_id, content, message_type, created_at) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 
   (SELECT id FROM users LIMIT 1), 
   'Hey! How are you doing?', 
   'text', 
   NOW() - INTERVAL '2 hours'),
  ('550e8400-e29b-41d4-a716-446655440001', 
   (SELECT id FROM users OFFSET 1 LIMIT 1), 
   'I''m doing great! Just finished volunteering at the beach cleanup.', 
   'text', 
   NOW() - INTERVAL '1 hour 50 minutes'),
  ('550e8400-e29b-41d4-a716-446655440001', 
   (SELECT id FROM users LIMIT 1), 
   'That sounds amazing! How many people showed up?', 
   'text', 
   NOW() - INTERVAL '1 hour 40 minutes'),
  ('550e8400-e29b-41d4-a716-446655440001', 
   (SELECT id FROM users OFFSET 1 LIMIT 1), 
   'About 50 volunteers! We collected over 200kg of trash.', 
   'text', 
   NOW() - INTERVAL '1 hour 30 minutes'),
  ('550e8400-e29b-41d4-a716-446655440001', 
   (SELECT id FROM users LIMIT 1), 
   'Wow! That''s incredible. We should organize another one soon.', 
   'text', 
   NOW() - INTERVAL '1 hour 20 minutes'),
  ('550e8400-e29b-41d4-a716-446655440001', 
   (SELECT id FROM users OFFSET 1 LIMIT 1), 
   'Absolutely! I''ll send you the details soon.', 
   'text', 
   NOW() - INTERVAL '1 hour 10 minutes');

-- Sample messages for second conversation
INSERT INTO messages (conversation_id, sender_id, content, message_type, created_at) VALUES
  ('550e8400-e29b-41d4-a716-446655440002', 
   (SELECT id FROM users OFFSET 1 LIMIT 1), 
   'Hi there! Interested in the education program?', 
   'text', 
   NOW() - INTERVAL '30 minutes'),
  ('550e8400-e29b-41d4-a716-446655440002', 
   (SELECT id FROM users LIMIT 1), 
   'Yes! Tell me more about it.', 
   'text', 
   NOW() - INTERVAL '25 minutes'),
  ('550e8400-e29b-41d4-a716-446655440002', 
   (SELECT id FROM users OFFSET 1 LIMIT 1), 
   'We''re teaching digital literacy to senior citizens. It''s very rewarding!', 
   'text', 
   NOW() - INTERVAL '20 minutes'),
  ('550e8400-e29b-41d4-a716-446655440002', 
   (SELECT id FROM users LIMIT 1), 
   'That sounds perfect! When can I join?', 
   'text', 
   NOW() - INTERVAL '15 minutes');

-- ============================================================================
-- INSERT SAMPLE CONVERSATION PARTICIPANTS
-- ============================================================================

-- Add participants to conversations (using actual user IDs)
INSERT INTO conversation_participants (conversation_id, user_id) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', (SELECT id FROM users LIMIT 1)),
  ('550e8400-e29b-41d4-a716-446655440001', (SELECT id FROM users OFFSET 1 LIMIT 1)),
  ('550e8400-e29b-41d4-a716-446655440002', (SELECT id FROM users LIMIT 1)),
  ('550e8400-e29b-41d4-a716-446655440002', (SELECT id FROM users OFFSET 1 LIMIT 1))
ON CONFLICT DO NOTHING;

-- ============================================================================
-- VERIFY DATA
-- ============================================================================

-- Check conversations
SELECT 'Conversations created:' as status, COUNT(*) as count FROM conversations;

-- Check messages
SELECT 'Messages created:' as status, COUNT(*) as count FROM messages;

-- Check participants
SELECT 'Participants added:' as status, COUNT(*) as count FROM conversation_participants;

-- Show sample data
SELECT 'Sample conversations:' as status;
SELECT c.id, c.type, COUNT(m.id) as message_count 
FROM conversations c 
LEFT JOIN messages m ON c.id = m.conversation_id 
GROUP BY c.id, c.type;

SELECT 'Sample messages:' as status;
SELECT m.id, u.name, m.content, m.created_at 
FROM messages m 
JOIN users u ON m.sender_id = u.id 
ORDER BY m.created_at DESC 
LIMIT 10;
