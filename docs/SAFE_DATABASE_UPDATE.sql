-- ================================================
-- SEVA-SETU SAFE DATABASE UPDATE
-- This script safely updates existing tables and creates new ones
-- Use this if you already have some tables in your database
-- ================================================

-- ================================================
-- UPDATE EXISTING TABLES (Add missing columns)
-- ================================================

-- Update users table if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users') THEN
        -- Add missing columns to users table
        ALTER TABLE users ADD COLUMN IF NOT EXISTS name TEXT;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS user_type TEXT DEFAULT 'volunteer';
        ALTER TABLE users ADD COLUMN IF NOT EXISTS bio TEXT;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar TEXT;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS cover_photo TEXT;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS phone TEXT;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS website TEXT;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS location TEXT;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS social_links JSONB DEFAULT '{}';
        ALTER TABLE users ADD COLUMN IF NOT EXISTS skills TEXT[] DEFAULT '{}';
        ALTER TABLE users ADD COLUMN IF NOT EXISTS interests TEXT[] DEFAULT '{}';
        ALTER TABLE users ADD COLUMN IF NOT EXISTS followers_count INTEGER DEFAULT 0;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS following_count INTEGER DEFAULT 0;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS is_private BOOLEAN DEFAULT false;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS email_notifications BOOLEAN DEFAULT true;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS is_banned BOOLEAN DEFAULT false;
        
        -- Create indexes safely
        CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
        CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
    END IF;
END $$;

-- Update ngos table if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ngos') THEN
        ALTER TABLE ngos ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES users(id) ON DELETE CASCADE;
        ALTER TABLE ngos ADD COLUMN IF NOT EXISTS founded_year INTEGER;
        ALTER TABLE ngos ADD COLUMN IF NOT EXISTS website TEXT;
        ALTER TABLE ngos ADD COLUMN IF NOT EXISTS logo TEXT;
        ALTER TABLE ngos ADD COLUMN IF NOT EXISTS cover_image TEXT;
        ALTER TABLE ngos ADD COLUMN IF NOT EXISTS gallery TEXT[] DEFAULT '{}';
        ALTER TABLE ngos ADD COLUMN IF NOT EXISTS location TEXT;
        ALTER TABLE ngos ADD COLUMN IF NOT EXISTS followers_count INTEGER DEFAULT 0;
        ALTER TABLE ngos ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;
        
        -- Only create indexes if columns exist
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ngos' AND column_name = 'owner_id') THEN
            CREATE INDEX IF NOT EXISTS idx_ngos_owner ON ngos(owner_id);
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ngos' AND column_name = 'category') THEN
            CREATE INDEX IF NOT EXISTS idx_ngos_category ON ngos(category);
        END IF;
    END IF;
END $$;

-- Update posts table if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'posts') THEN
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE;
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS content TEXT;
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS images TEXT[] DEFAULT '{}';
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS poll JSONB;
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS likes_count INTEGER DEFAULT 0;
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS comments_count INTEGER DEFAULT 0;
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS shares_count INTEGER DEFAULT 0;
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS views_count INTEGER DEFAULT 0;
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS is_pinned BOOLEAN DEFAULT false;
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS is_flagged BOOLEAN DEFAULT false;
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Update events table if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'events') THEN
        ALTER TABLE events ADD COLUMN IF NOT EXISTS ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE;
        ALTER TABLE events ADD COLUMN IF NOT EXISTS title TEXT;
        ALTER TABLE events ADD COLUMN IF NOT EXISTS description TEXT;
        ALTER TABLE events ADD COLUMN IF NOT EXISTS location TEXT;
        ALTER TABLE events ADD COLUMN IF NOT EXISTS location_details JSONB DEFAULT '{}';
        ALTER TABLE events ADD COLUMN IF NOT EXISTS theme TEXT;
        ALTER TABLE events ADD COLUMN IF NOT EXISTS date TIMESTAMP WITH TIME ZONE;
        ALTER TABLE events ADD COLUMN IF NOT EXISTS end_date TIMESTAMP WITH TIME ZONE;
        ALTER TABLE events ADD COLUMN IF NOT EXISTS images TEXT[] DEFAULT '{}';
        ALTER TABLE events ADD COLUMN IF NOT EXISTS volunteers_needed INTEGER DEFAULT 10;
        ALTER TABLE events ADD COLUMN IF NOT EXISTS volunteers_registered INTEGER DEFAULT 0;
        ALTER TABLE events ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'general';
        ALTER TABLE events ADD COLUMN IF NOT EXISTS requires_application BOOLEAN DEFAULT false;
        ALTER TABLE events ADD COLUMN IF NOT EXISTS is_cancelled BOOLEAN DEFAULT false;
        ALTER TABLE events ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Update conversations table if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'conversations') THEN
        ALTER TABLE conversations ADD COLUMN IF NOT EXISTS name TEXT;
        ALTER TABLE conversations ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'direct';
        ALTER TABLE conversations ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES users(id) ON DELETE SET NULL;
        ALTER TABLE conversations ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        ALTER TABLE conversations ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Update messages table if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'messages') THEN
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS sender_id UUID REFERENCES users(id) ON DELETE CASCADE;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS content TEXT;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS message_type TEXT DEFAULT 'text';
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS file_url TEXT;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS file_name TEXT;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS file_size INTEGER;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS is_edited BOOLEAN DEFAULT false;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        ALTER TABLE messages ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Update notifications table if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'notifications') THEN
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS type TEXT;
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS title TEXT;
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS message TEXT;
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS link TEXT;
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS data JSONB DEFAULT '{}';
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS read BOOLEAN DEFAULT false;
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Update donations table if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'donations') THEN
        ALTER TABLE donations ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE SET NULL;
        ALTER TABLE donations ADD COLUMN IF NOT EXISTS ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE;
        ALTER TABLE donations ADD COLUMN IF NOT EXISTS amount DECIMAL;
        ALTER TABLE donations ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'USD';
        ALTER TABLE donations ADD COLUMN IF NOT EXISTS stripe_session_id TEXT UNIQUE;
        ALTER TABLE donations ADD COLUMN IF NOT EXISTS stripe_payment_intent TEXT;
        ALTER TABLE donations ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'pending';
        ALTER TABLE donations ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        ALTER TABLE donations ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- Update analytics tables if they exist
DO $$ 
BEGIN
    -- Update analytics_predictions table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'analytics_predictions') THEN
        ALTER TABLE analytics_predictions ADD COLUMN IF NOT EXISTS prediction_type TEXT;
        ALTER TABLE analytics_predictions ADD COLUMN IF NOT EXISTS entity_id UUID;
        ALTER TABLE analytics_predictions ADD COLUMN IF NOT EXISTS entity_type TEXT;
        ALTER TABLE analytics_predictions ADD COLUMN IF NOT EXISTS prediction_data JSONB;
        ALTER TABLE analytics_predictions ADD COLUMN IF NOT EXISTS confidence_score DECIMAL(3,2);
        ALTER TABLE analytics_predictions ADD COLUMN IF NOT EXISTS model_version TEXT;
        ALTER TABLE analytics_predictions ADD COLUMN IF NOT EXISTS generated_by UUID REFERENCES users(id);
        ALTER TABLE analytics_predictions ADD COLUMN IF NOT EXISTS valid_until TIMESTAMP WITH TIME ZONE;
        ALTER TABLE analytics_predictions ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
    
    -- Update comparative_metrics table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'comparative_metrics') THEN
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE;
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS metric_name TEXT;
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS metric_value DECIMAL;
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS metric_unit TEXT;
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS benchmark_value DECIMAL;
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS percentile_rank INTEGER;
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS comparison_period TEXT;
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
    
    -- Update impact_multipliers table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'impact_multipliers') THEN
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS source_event_id UUID REFERENCES events(id) ON DELETE CASCADE;
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS multiplier_type TEXT;
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS multiplier_value DECIMAL;
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS impact_category TEXT;
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS description TEXT;
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
    
    -- Update sustainability_metrics table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sustainability_metrics') THEN
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE;
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS metric_type TEXT;
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS metric_value DECIMAL;
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS metric_unit TEXT;
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS sustainability_goal TEXT;
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS target_value DECIMAL;
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS achieved_percentage DECIMAL;
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS date_measured DATE;
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
    
    -- Update search_analytics table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'search_analytics') THEN
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS query TEXT;
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS filters JSONB DEFAULT '{}';
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS result_count INTEGER;
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE SET NULL;
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- ================================================
-- CREATE MISSING TABLES
-- ================================================

-- 1. Users Table (if doesn't exist)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  user_type TEXT NOT NULL DEFAULT 'volunteer',
  bio TEXT,
  avatar TEXT,
  cover_photo TEXT,
  phone TEXT,
  website TEXT,
  location TEXT,
  social_links JSONB DEFAULT '{}',
  skills TEXT[] DEFAULT '{}',
  interests TEXT[] DEFAULT '{}',
  followers_count INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  is_private BOOLEAN DEFAULT false,
  email_notifications BOOLEAN DEFAULT true,
  is_admin BOOLEAN DEFAULT false,
  is_banned BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. NGOs Table (if doesn't exist)
CREATE TABLE IF NOT EXISTS ngos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  founded_year INTEGER,
  website TEXT,
  logo TEXT,
  cover_image TEXT,
  gallery TEXT[] DEFAULT '{}',
  location TEXT,
  owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
  followers_count INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. NGO Follows Table
CREATE TABLE IF NOT EXISTS ngo_follows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  followed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(ngo_id, user_id)
);

-- 4. Posts Table
CREATE TABLE IF NOT EXISTS posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  images TEXT[] DEFAULT '{}',
  poll JSONB,
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  shares_count INTEGER DEFAULT 0,
  views_count INTEGER DEFAULT 0,
  is_pinned BOOLEAN DEFAULT false,
  is_flagged BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Post Likes Table
CREATE TABLE IF NOT EXISTS post_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- 6. Post Comments Table
CREATE TABLE IF NOT EXISTS post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Post Shares Table
CREATE TABLE IF NOT EXISTS post_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  share_text TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Events Table
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  location TEXT NOT NULL,
  location_details JSONB DEFAULT '{}',
  theme TEXT,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE,
  images TEXT[] DEFAULT '{}',
  volunteers_needed INTEGER DEFAULT 10,
  volunteers_registered INTEGER DEFAULT 0,
  category TEXT DEFAULT 'general',
  requires_application BOOLEAN DEFAULT false,
  is_cancelled BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Event RSVPs Table
CREATE TABLE IF NOT EXISTS event_rsvps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'attending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- 10. Volunteer Applications Table
CREATE TABLE IF NOT EXISTS volunteer_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  skills TEXT[] DEFAULT '{}',
  interests TEXT[] DEFAULT '{}',
  experience TEXT,
  availability JSONB DEFAULT '{}',
  motivation TEXT,
  status TEXT DEFAULT 'pending',
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewed_by UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================
-- GAMIFICATION TABLES (These are likely missing)
-- ================================================

-- 11. Leaderboards Table
CREATE TABLE IF NOT EXISTS leaderboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    metric_type VARCHAR(50) NOT NULL,
    total_value DECIMAL(15, 2) DEFAULT 0,
    rank_position INTEGER,
    last_updated TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 12. Badges Table
CREATE TABLE IF NOT EXISTS badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    badge_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    icon VARCHAR(50) NOT NULL,
    criteria JSONB NOT NULL,
    level VARCHAR(20) DEFAULT 'bronze',
    points INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 13. User Badges Table
CREATE TABLE IF NOT EXISTS user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    badge_id UUID REFERENCES badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, badge_id)
);

-- 14. Challenges Table
CREATE TABLE IF NOT EXISTS challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    challenge_type VARCHAR(50) NOT NULL,
    target_value DECIMAL(15, 2) NOT NULL,
    target_metric VARCHAR(50) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    reward_points INTEGER DEFAULT 50,
    reward_badge_id UUID REFERENCES badges(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 15. Challenge Participants Table
CREATE TABLE IF NOT EXISTS challenge_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT NOW(),
    progress_value DECIMAL(15, 2) DEFAULT 0,
    completed_at TIMESTAMP,
    UNIQUE(challenge_id, user_id)
);

-- 16. Streaks Table
CREATE TABLE IF NOT EXISTS streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    streak_type VARCHAR(50) NOT NULL,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ================================================
-- ANALYTICS & IMPACT TABLES
-- ================================================

-- 17. Impact Metrics Table
CREATE TABLE IF NOT EXISTS impact_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  metric_type TEXT NOT NULL,
  value DECIMAL NOT NULL,
  unit TEXT NOT NULL,
  date DATE NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 18. Real-time Counters Table
CREATE TABLE IF NOT EXISTS real_time_counters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    counter_name VARCHAR(100) NOT NULL UNIQUE,
    counter_value BIGINT DEFAULT 0,
    description TEXT,
    last_updated TIMESTAMP DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- ================================================
-- MESSAGING TABLES
-- ================================================

-- 19. Conversations Table
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT,
  type TEXT DEFAULT 'direct',
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 20. Conversation Participants Table
CREATE TABLE IF NOT EXISTS conversation_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(conversation_id, user_id)
);

-- 21. Messages Table
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
  is_edited BOOLEAN DEFAULT false,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 22. Message Reads Table
CREATE TABLE IF NOT EXISTS message_reads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(message_id, user_id)
);

-- ================================================
-- NOTIFICATIONS & REPORTS TABLES
-- ================================================

-- 23. Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  link TEXT,
  data JSONB DEFAULT '{}',
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 24. Content Reports Table
CREATE TABLE IF NOT EXISTS content_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL,
  content_id UUID NOT NULL,
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'pending',
  reviewed_by UUID REFERENCES users(id),
  reviewed_at TIMESTAMP WITH TIME ZONE,
  action_taken TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================
-- DONATIONS TABLES
-- ================================================

-- 25. Donations Table
CREATE TABLE IF NOT EXISTS donations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  amount DECIMAL NOT NULL,
  currency TEXT DEFAULT 'USD',
  stripe_session_id TEXT UNIQUE,
  stripe_payment_intent TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- 26. Analytics Predictions Table
CREATE TABLE IF NOT EXISTS analytics_predictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prediction_type TEXT NOT NULL,
  entity_id UUID,
  entity_type TEXT,
  prediction_data JSONB NOT NULL,
  confidence_score DECIMAL(3,2),
  model_version TEXT,
  generated_by UUID REFERENCES users(id),
  valid_until TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 27. Comparative Metrics Table
CREATE TABLE IF NOT EXISTS comparative_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  metric_name TEXT NOT NULL,
  metric_value DECIMAL NOT NULL,
  metric_unit TEXT,
  benchmark_value DECIMAL,
  percentile_rank INTEGER,
  comparison_period TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 28. Impact Multipliers Table
CREATE TABLE IF NOT EXISTS impact_multipliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  multiplier_type TEXT NOT NULL,
  multiplier_value DECIMAL NOT NULL,
  impact_category TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 29. Sustainability Metrics Table
CREATE TABLE IF NOT EXISTS sustainability_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  metric_type TEXT NOT NULL,
  metric_value DECIMAL NOT NULL,
  metric_unit TEXT,
  sustainability_goal TEXT,
  target_value DECIMAL,
  achieved_percentage DECIMAL,
  date_measured DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 30. Search Analytics Table
CREATE TABLE IF NOT EXISTS search_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  query TEXT NOT NULL,
  filters JSONB DEFAULT '{}',
  result_count INTEGER,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================
-- CREATE INDEXES SAFELY
-- ================================================

-- Core indexes (with column existence checks)
DO $$ 
BEGIN
    -- Users table indexes
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'email') THEN
        CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'user_type') THEN
        CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
    END IF;
    
    -- NGOs table indexes
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ngos' AND column_name = 'owner_id') THEN
        CREATE INDEX IF NOT EXISTS idx_ngos_owner ON ngos(owner_id);
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ngos' AND column_name = 'category') THEN
        CREATE INDEX IF NOT EXISTS idx_ngos_category ON ngos(category);
    END IF;
END $$;
-- Other table indexes (safe creation)
DO $$ 
BEGIN
    -- NGO Follows indexes
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ngo_follows') THEN
        CREATE INDEX IF NOT EXISTS idx_ngo_follows_ngo ON ngo_follows(ngo_id);
        CREATE INDEX IF NOT EXISTS idx_ngo_follows_user ON ngo_follows(user_id);
    END IF;
    
    -- Posts indexes
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'posts') THEN
        CREATE INDEX IF NOT EXISTS idx_posts_user ON posts(user_id);
        CREATE INDEX IF NOT EXISTS idx_posts_ngo ON posts(ngo_id);
        CREATE INDEX IF NOT EXISTS idx_posts_created ON posts(created_at DESC);
    END IF;
    
    -- Post Likes indexes
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'post_likes') THEN
        CREATE INDEX IF NOT EXISTS idx_post_likes_post ON post_likes(post_id);
        CREATE INDEX IF NOT EXISTS idx_post_likes_user ON post_likes(user_id);
    END IF;
    
    -- Post Comments indexes
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'post_comments') THEN
        CREATE INDEX IF NOT EXISTS idx_post_comments_post ON post_comments(post_id);
        CREATE INDEX IF NOT EXISTS idx_post_comments_user ON post_comments(user_id);
    END IF;
    
    -- Post Shares indexes
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'post_shares') THEN
        CREATE INDEX IF NOT EXISTS idx_post_shares_post ON post_shares(post_id);
        CREATE INDEX IF NOT EXISTS idx_post_shares_user ON post_shares(user_id);
    END IF;
    
    -- Events indexes
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'events') THEN
        CREATE INDEX IF NOT EXISTS idx_events_ngo ON events(ngo_id);
        CREATE INDEX IF NOT EXISTS idx_events_date ON events(date);
        CREATE INDEX IF NOT EXISTS idx_events_category ON events(category);
    END IF;
    
    -- Event RSVPs indexes
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'event_rsvps') THEN
        CREATE INDEX IF NOT EXISTS idx_event_rsvps_event ON event_rsvps(event_id);
        CREATE INDEX IF NOT EXISTS idx_event_rsvps_user ON event_rsvps(user_id);
    END IF;
    
    -- Volunteer Applications indexes
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'volunteer_applications') THEN
        CREATE INDEX IF NOT EXISTS idx_volunteer_apps_event ON volunteer_applications(event_id);
        CREATE INDEX IF NOT EXISTS idx_volunteer_apps_user ON volunteer_applications(user_id);
        CREATE INDEX IF NOT EXISTS idx_volunteer_apps_status ON volunteer_applications(status);
    END IF;
END $$;

-- Gamification indexes (safe creation)
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'leaderboards') THEN
        CREATE INDEX IF NOT EXISTS idx_leaderboards_category ON leaderboards(category);
        CREATE INDEX IF NOT EXISTS idx_leaderboards_metric ON leaderboards(metric_type);
        CREATE INDEX IF NOT EXISTS idx_leaderboards_rank ON leaderboards(rank_position);
    END IF;
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_badges') THEN
        CREATE INDEX IF NOT EXISTS idx_user_badges_user ON user_badges(user_id);
    END IF;
END $$;

-- Analytics indexes (safe creation)
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'impact_metrics') THEN
        CREATE INDEX IF NOT EXISTS idx_impact_metrics_ngo ON impact_metrics(ngo_id);
        CREATE INDEX IF NOT EXISTS idx_impact_metrics_event ON impact_metrics(event_id);
        CREATE INDEX IF NOT EXISTS idx_impact_metrics_date ON impact_metrics(date);
    END IF;
END $$;

-- Messaging indexes (safe creation)
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'conversations') THEN
        CREATE INDEX IF NOT EXISTS idx_conversations_last_message ON conversations(last_message_at DESC);
    END IF;
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'conversation_participants') THEN
        CREATE INDEX IF NOT EXISTS idx_conv_participants_conv ON conversation_participants(conversation_id);
        CREATE INDEX IF NOT EXISTS idx_conv_participants_user ON conversation_participants(user_id);
    END IF;
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'messages') THEN
        CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
        CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
        CREATE INDEX IF NOT EXISTS idx_messages_created ON messages(created_at DESC);
    END IF;
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'message_reads') THEN
        CREATE INDEX IF NOT EXISTS idx_message_reads_message ON message_reads(message_id);
        CREATE INDEX IF NOT EXISTS idx_message_reads_user ON message_reads(user_id);
    END IF;
END $$;

-- Notifications indexes (safe creation)
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'notifications') THEN
        CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
        CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read);
        CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);
    END IF;
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'content_reports') THEN
        CREATE INDEX IF NOT EXISTS idx_content_reports_status ON content_reports(status);
        CREATE INDEX IF NOT EXISTS idx_content_reports_content ON content_reports(content_type, content_id);
    END IF;
END $$;

-- Donations indexes (safe creation)
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'donations') THEN
        CREATE INDEX IF NOT EXISTS idx_donations_user ON donations(user_id);
        CREATE INDEX IF NOT EXISTS idx_donations_ngo ON donations(ngo_id);
        CREATE INDEX IF NOT EXISTS idx_donations_status ON donations(status);
    END IF;
END $$;

-- Analytics tables indexes (safe creation)
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'analytics_predictions') THEN
        CREATE INDEX IF NOT EXISTS idx_analytics_predictions_type ON analytics_predictions(prediction_type);
        CREATE INDEX IF NOT EXISTS idx_analytics_predictions_entity ON analytics_predictions(entity_id);
        CREATE INDEX IF NOT EXISTS idx_analytics_predictions_valid ON analytics_predictions(valid_until);
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'comparative_metrics') THEN
        CREATE INDEX IF NOT EXISTS idx_comparative_metrics_ngo ON comparative_metrics(ngo_id);
        CREATE INDEX IF NOT EXISTS idx_comparative_metrics_name ON comparative_metrics(metric_name);
        CREATE INDEX IF NOT EXISTS idx_comparative_metrics_period ON comparative_metrics(comparison_period);
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'impact_multipliers') THEN
        CREATE INDEX IF NOT EXISTS idx_impact_multipliers_event ON impact_multipliers(source_event_id);
        CREATE INDEX IF NOT EXISTS idx_impact_multipliers_type ON impact_multipliers(multiplier_type);
        CREATE INDEX IF NOT EXISTS idx_impact_multipliers_category ON impact_multipliers(impact_category);
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sustainability_metrics') THEN
        CREATE INDEX IF NOT EXISTS idx_sustainability_metrics_ngo ON sustainability_metrics(ngo_id);
        CREATE INDEX IF NOT EXISTS idx_sustainability_metrics_type ON sustainability_metrics(metric_type);
        CREATE INDEX IF NOT EXISTS idx_sustainability_metrics_date ON sustainability_metrics(date_measured);
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'search_analytics') THEN
        CREATE INDEX IF NOT EXISTS idx_search_analytics_user ON search_analytics(user_id);
        CREATE INDEX IF NOT EXISTS idx_search_analytics_query ON search_analytics(query);
        CREATE INDEX IF NOT EXISTS idx_search_analytics_created ON search_analytics(created_at DESC);
    END IF;
END $$;

-- ================================================
-- INSERT DEFAULT DATA (Only if not exists)
-- ================================================

-- Insert Default Badges (only if badges table is empty)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM badges) THEN
        INSERT INTO badges (badge_name, description, icon, criteria, level, points) VALUES
        ('First Step', 'Completed your first volunteer hour', '🌟', '{"hours": 1}'::jsonb, 'bronze', 10),
        ('Rising Star', 'Volunteered for 10 hours', '⭐', '{"hours": 10}'::jsonb, 'bronze', 50),
        ('Dedicated Helper', 'Volunteered for 50 hours', '💫', '{"hours": 50}'::jsonb, 'silver', 100),
        ('Community Champion', 'Volunteered for 100 hours', '🏆', '{"hours": 100}'::jsonb, 'gold', 200),
        ('Generous Giver', 'Made your first donation', '💝', '{"donations": 1}'::jsonb, 'bronze', 25),
        ('Patron of Change', 'Donated $100 or more', '💎', '{"total_donated": 100}'::jsonb, 'silver', 150),
        ('Event Enthusiast', 'Attended 5 events', '🎯', '{"events": 5}'::jsonb, 'bronze', 75),
        ('Social Butterfly', 'Created 10 posts', '🦋', '{"posts": 10}'::jsonb, 'bronze', 30),
        ('Impact Creator', 'Created 25 posts', '🚀', '{"posts": 25}'::jsonb, 'silver', 100),
        ('Content Master', 'Created 50 posts', '👑', '{"posts": 50}'::jsonb, 'gold', 250),
        ('Volunteer Leader', 'Organized 3 events', '🎖️', '{"events_organized": 3}'::jsonb, 'gold', 300);
    END IF;
END $$;

-- Insert Default Real-time Counters (only if table is empty)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM real_time_counters) THEN
        INSERT INTO real_time_counters (counter_name, counter_value, description) VALUES
        ('total_volunteer_hours', 0, 'Total volunteer hours across all users'),
        ('total_donations', 0, 'Total donations made'),
        ('total_events', 0, 'Total events created'),
        ('total_posts', 0, 'Total posts created'),
        ('total_users', 0, 'Total registered users'),
        ('total_ngos', 0, 'Total NGOs registered'),
        ('total_impact_lives', 0, 'Total lives impacted'),
        ('total_trees_planted', 0, 'Total trees planted'),
        ('total_meals_served', 0, 'Total meals served'),
        ('total_children_educated', 0, 'Total children educated'),
        ('total_community_members', 0, 'Total community members reached');
    END IF;
END $$;

-- ================================================
-- VERIFICATION
-- ================================================

-- Show all tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Show badges count
SELECT COUNT(*) as badges_count FROM badges;

-- Show counters count  
SELECT COUNT(*) as counters_count FROM real_time_counters;
