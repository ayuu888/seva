# Seva-Setu Supabase Complete Setup Guide

This guide will help you set up the complete database schema for Seva-Setu on Supabase.

## Prerequisites
- A Supabase account (sign up at https://supabase.com)
- Your Supabase project created

## Step 1: Get Your Credentials

1. Go to https://app.supabase.com
2. Select your project
3. Go to **Settings** → **API**
4. Copy the following:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public** key
   - **service_role** key (⚠️ Keep this secret!)

## Step 2: Update Environment Variables

Add these to your `/app/backend/.env` file:
```bash
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## Step 3: Create Database Tables

Go to your Supabase project → **SQL Editor** → **New Query** and run the following SQL scripts:

### 1. Users Table
```sql
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

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_type ON users(user_type);
```

### 2. NGOs Table
```sql
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

CREATE INDEX idx_ngos_owner ON ngos(owner_id);
CREATE INDEX idx_ngos_category ON ngos(category);
```

### 3. NGO Follows Table
```sql
CREATE TABLE IF NOT EXISTS ngo_follows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  followed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(ngo_id, user_id)
);

CREATE INDEX idx_ngo_follows_ngo ON ngo_follows(ngo_id);
CREATE INDEX idx_ngo_follows_user ON ngo_follows(user_id);
```

### 4. Posts Table
```sql
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

CREATE INDEX idx_posts_user ON posts(user_id);
CREATE INDEX idx_posts_ngo ON posts(ngo_id);
CREATE INDEX idx_posts_created ON posts(created_at DESC);
```

### 5. Post Likes Table
```sql
CREATE TABLE IF NOT EXISTS post_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

CREATE INDEX idx_post_likes_post ON post_likes(post_id);
CREATE INDEX idx_post_likes_user ON post_likes(user_id);
```

### 6. Post Comments Table
```sql
CREATE TABLE IF NOT EXISTS post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_post_comments_post ON post_comments(post_id);
CREATE INDEX idx_post_comments_user ON post_comments(user_id);
```

### 7. Post Shares Table
```sql
CREATE TABLE IF NOT EXISTS post_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  share_text TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_post_shares_post ON post_shares(post_id);
CREATE INDEX idx_post_shares_user ON post_shares(user_id);
```

### 8. Events Table
```sql
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

CREATE INDEX idx_events_ngo ON events(ngo_id);
CREATE INDEX idx_events_date ON events(date);
CREATE INDEX idx_events_category ON events(category);
```

### 9. Event RSVPs Table
```sql
CREATE TABLE IF NOT EXISTS event_rsvps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'attending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

CREATE INDEX idx_event_rsvps_event ON event_rsvps(event_id);
CREATE INDEX idx_event_rsvps_user ON event_rsvps(user_id);
```

### 10. Volunteer Applications Table
```sql
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

CREATE INDEX idx_volunteer_apps_event ON volunteer_applications(event_id);
CREATE INDEX idx_volunteer_apps_user ON volunteer_applications(user_id);
CREATE INDEX idx_volunteer_apps_status ON volunteer_applications(status);
```

### 11. Volunteer Shifts Table
```sql
CREATE TABLE IF NOT EXISTS volunteer_shifts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  volunteers_needed INTEGER DEFAULT 1,
  volunteers_assigned INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_volunteer_shifts_event ON volunteer_shifts(event_id);
```

### 12. Shift Assignments Table
```sql
CREATE TABLE IF NOT EXISTS shift_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shift_id UUID REFERENCES volunteer_shifts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(shift_id, user_id)
);

CREATE INDEX idx_shift_assignments_shift ON shift_assignments(shift_id);
CREATE INDEX idx_shift_assignments_user ON shift_assignments(user_id);
```

### 13. Volunteer Training Table
```sql
CREATE TABLE IF NOT EXISTS volunteer_training (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT DEFAULT 'online',
  content_url TEXT,
  duration_minutes INTEGER,
  required BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_volunteer_training_event ON volunteer_training(event_id);
```

### 14. Training Completions Table
```sql
CREATE TABLE IF NOT EXISTS training_completions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  training_id UUID REFERENCES volunteer_training(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(training_id, user_id)
);

CREATE INDEX idx_training_completions_training ON training_completions(training_id);
CREATE INDEX idx_training_completions_user ON training_completions(user_id);
```

### 15. Volunteer Hours Table
```sql
CREATE TABLE IF NOT EXISTS volunteer_hours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  shift_id UUID REFERENCES volunteer_shifts(id) ON DELETE SET NULL,
  hours DECIMAL NOT NULL,
  date DATE NOT NULL,
  notes TEXT,
  verified BOOLEAN DEFAULT false,
  verified_by UUID REFERENCES users(id),
  verified_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_volunteer_hours_user ON volunteer_hours(user_id);
CREATE INDEX idx_volunteer_hours_event ON volunteer_hours(event_id);
```

### 16. Event Feedback Table
```sql
CREATE TABLE IF NOT EXISTS event_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  feedback TEXT,
  suggestions TEXT,
  would_volunteer_again BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

CREATE INDEX idx_event_feedback_event ON event_feedback(event_id);
CREATE INDEX idx_event_feedback_user ON event_feedback(user_id);
```

### 17. Conversations Table
```sql
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT,
  type TEXT DEFAULT 'direct',
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);
```

### 18. Conversation Participants Table
```sql
CREATE TABLE IF NOT EXISTS conversation_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(conversation_id, user_id)
);

CREATE INDEX idx_conv_participants_conv ON conversation_participants(conversation_id);
CREATE INDEX idx_conv_participants_user ON conversation_participants(user_id);
```

### 19. Messages Table
```sql
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

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);
```

### 20. Message Reads Table
```sql
CREATE TABLE IF NOT EXISTS message_reads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(message_id, user_id)
);

CREATE INDEX idx_message_reads_message ON message_reads(message_id);
CREATE INDEX idx_message_reads_user ON message_reads(user_id);
```

### 21. Message Reactions Table
```sql
CREATE TABLE IF NOT EXISTS message_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  reaction TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(message_id, user_id, reaction)
);

CREATE INDEX idx_message_reactions_message ON message_reactions(message_id);
```

### 22. User Presence Table
```sql
CREATE TABLE IF NOT EXISTS user_presence (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'offline',
  last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_presence_status ON user_presence(status);
```

### 23. Typing Indicators Table
```sql
CREATE TABLE IF NOT EXISTS typing_indicators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  is_typing BOOLEAN DEFAULT false,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(conversation_id, user_id)
);

CREATE INDEX idx_typing_indicators_conv ON typing_indicators(conversation_id);
```

### 24. Donations Table
```sql
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

CREATE INDEX idx_donations_user ON donations(user_id);
CREATE INDEX idx_donations_ngo ON donations(ngo_id);
CREATE INDEX idx_donations_status ON donations(status);
```

### 25. Impact Metrics Table
```sql
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

CREATE INDEX idx_impact_metrics_ngo ON impact_metrics(ngo_id);
CREATE INDEX idx_impact_metrics_event ON impact_metrics(event_id);
CREATE INDEX idx_impact_metrics_date ON impact_metrics(date);
```

### 26. Success Stories Table
```sql
CREATE TABLE IF NOT EXISTS success_stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  author_id UUID REFERENCES users(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT,
  images TEXT[] DEFAULT '{}',
  video_url TEXT,
  impact_numbers JSONB DEFAULT '{}',
  tags TEXT[] DEFAULT '{}',
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  published BOOLEAN DEFAULT true,
  featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_success_stories_ngo ON success_stories(ngo_id);
CREATE INDEX idx_success_stories_published ON success_stories(published);
CREATE INDEX idx_success_stories_featured ON success_stories(featured);
```

### 27. Story Likes Table
```sql
CREATE TABLE IF NOT EXISTS story_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id UUID REFERENCES success_stories(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(story_id, user_id)
);

CREATE INDEX idx_story_likes_story ON story_likes(story_id);
CREATE INDEX idx_story_likes_user ON story_likes(user_id);
```

### 28. Story Comments Table
```sql
CREATE TABLE IF NOT EXISTS story_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id UUID REFERENCES success_stories(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_story_comments_story ON story_comments(story_id);
```

### 29. Testimonials Table
```sql
CREATE TABLE IF NOT EXISTS testimonials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  testimonial TEXT NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  role TEXT NOT NULL,
  location TEXT,
  approved BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_testimonials_ngo ON testimonials(ngo_id);
CREATE INDEX idx_testimonials_approved ON testimonials(approved);
```

### 30. Case Studies Table
```sql
CREATE TABLE IF NOT EXISTS case_studies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  author_id UUID REFERENCES users(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  summary TEXT NOT NULL,
  full_content TEXT NOT NULL,
  problem_statement TEXT,
  solution_approach TEXT,
  implementation_details TEXT,
  results_achieved TEXT,
  lessons_learned TEXT,
  images TEXT[] DEFAULT '{}',
  video_url TEXT,
  category TEXT,
  tags TEXT[] DEFAULT '{}',
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_case_studies_ngo ON case_studies(ngo_id);
CREATE INDEX idx_case_studies_published ON case_studies(published);
```

### 31. Impact Outcomes Table
```sql
CREATE TABLE IF NOT EXISTS impact_outcomes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  case_study_id UUID REFERENCES case_studies(id) ON DELETE CASCADE,
  outcome_type TEXT NOT NULL,
  description TEXT NOT NULL,
  quantitative_data JSONB DEFAULT '{}',
  measurement_method TEXT,
  timeframe TEXT,
  verified BOOLEAN DEFAULT false,
  verified_by UUID REFERENCES users(id),
  verified_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_impact_outcomes_ngo ON impact_outcomes(ngo_id);
CREATE INDEX idx_impact_outcomes_verified ON impact_outcomes(verified);
```

### 32. Notifications Table
```sql
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

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
```

### 33. Trending Posts Table
```sql
CREATE TABLE IF NOT EXISTS trending_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  score DECIMAL NOT NULL DEFAULT 0,
  calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id)
);

CREATE INDEX idx_trending_posts_score ON trending_posts(score DESC);
CREATE INDEX idx_trending_posts_calculated ON trending_posts(calculated_at DESC);
```

### 34. Content Reports Table
```sql
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

CREATE INDEX idx_content_reports_status ON content_reports(status);
CREATE INDEX idx_content_reports_content ON content_reports(content_type, content_id);
```

### 35. Badges Table
```sql
CREATE TABLE IF NOT EXISTS badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  criteria JSONB NOT NULL,
  level TEXT DEFAULT 'bronze',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 36. User Badges Table
```sql
CREATE TABLE IF NOT EXISTS user_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  badge_id UUID REFERENCES badges(id) ON DELETE CASCADE,
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, badge_id)
);

CREATE INDEX idx_user_badges_user ON user_badges(user_id);
```

## Step 4: Enable Row Level Security (RLS)

For production, you should enable RLS on all tables. Here's an example for the users table:

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);
```

Repeat similar policies for other tables as needed.

## Step 5: Create Database Functions

### Function to update trending posts
```sql
CREATE OR REPLACE FUNCTION update_trending_posts()
RETURNS void AS $$
BEGIN
  DELETE FROM trending_posts;
  
  INSERT INTO trending_posts (post_id, score, calculated_at)
  SELECT 
    p.id,
    (p.likes_count * 1.0 + p.comments_count * 2.0 + p.shares_count * 3.0 + p.views_count * 0.1) / 
    (EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 + 2)^1.5 as score,
    NOW()
  FROM posts p
  WHERE p.created_at > NOW() - INTERVAL '7 days'
    AND p.is_flagged = false
  ORDER BY score DESC
  LIMIT 100;
END;
$$ LANGUAGE plpgsql;
```

### Function to create notification
```sql
CREATE OR REPLACE FUNCTION create_notification(
  p_user_id UUID,
  p_type TEXT,
  p_title TEXT,
  p_message TEXT,
  p_link TEXT DEFAULT NULL,
  p_data JSONB DEFAULT '{}'
)
RETURNS UUID AS $$
DECLARE
  notification_id UUID;
BEGIN
  INSERT INTO notifications (user_id, type, title, message, link, data)
  VALUES (p_user_id, p_type, p_title, p_message, p_link, p_data)
  RETURNING id INTO notification_id;
  
  RETURN notification_id;
END;
$$ LANGUAGE plpgsql;
```

## Step 6: Set Up Real-time Subscriptions

Enable real-time for tables that need it:

```sql
-- Enable real-time for notifications
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- Enable real-time for messages
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Enable real-time for typing indicators
ALTER PUBLICATION supabase_realtime ADD TABLE typing_indicators;

-- Enable real-time for user presence
ALTER PUBLICATION supabase_realtime ADD TABLE user_presence;
```

## Step 7: Insert Default Badges

```sql
INSERT INTO badges (name, description, icon, criteria, level) VALUES
('First Step', 'Completed your first volunteer hour', '🌟', '{"hours": 1}', 'bronze'),
('Rising Star', 'Volunteered for 10 hours', '⭐', '{"hours": 10}', 'bronze'),
('Dedicated Helper', 'Volunteered for 50 hours', '💫', '{"hours": 50}', 'silver'),
('Community Champion', 'Volunteered for 100 hours', '🏆', '{"hours": 100}', 'gold'),
('Generous Giver', 'Made your first donation', '💝', '{"donations": 1}', 'bronze'),
('Patron of Change', 'Donated $100 or more', '💎', '{"total_donated": 100}', 'silver'),
('Event Enthusiast', 'Attended 5 events', '🎯', '{"events": 5}', 'bronze'),
('Social Butterfly', 'Created 10 posts', '🦋', '{"posts": 10}', 'bronze');
```

## Step 8: Verify Setup

Run this query to check all tables were created:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

## Troubleshooting

### Connection Issues
- Verify your SUPABASE_URL and keys are correct
- Check that your IP is allowed in Supabase project settings
- Ensure you're using the service_role key for backend operations

### Query Errors
- Make sure all tables are created in order (foreign keys depend on parent tables)
- Check Supabase logs in Dashboard → Logs

### Real-time Not Working
- Verify real-time is enabled for your subscription tier
- Check that tables are added to the publication
- Ensure RLS policies allow the operations

## Next Steps

After completing this setup:
1. Restart your backend server
2. Test the connection with a simple query
3. Start using the API endpoints
4. Monitor the Supabase dashboard for activity

## Support

For issues:
- Check Supabase documentation: https://supabase.com/docs
- Review backend logs: `/var/log/supervisor/backend.err.log`
- Contact support if problems persist
