-- ================================================
-- GAMIFICATION & ANALYTICS SCHEMA (SAFE VERSION)
-- For Seva-Setu Platform - Handles existing objects
-- ================================================

-- ================================================
-- GAMIFICATION TABLES
-- ================================================

-- Leaderboards tracking
CREATE TABLE IF NOT EXISTS leaderboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL, -- 'volunteer', 'donor', 'ngo'
    metric_type VARCHAR(50) NOT NULL, -- 'hours', 'donations', 'events', 'impact'
    total_value DECIMAL(15, 2) DEFAULT 0,
    rank_position INTEGER,
    last_updated TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes safely
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_leaderboards_category') THEN
        CREATE INDEX idx_leaderboards_category ON leaderboards(category);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_leaderboards_metric') THEN
        CREATE INDEX idx_leaderboards_metric ON leaderboards(metric_type);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_leaderboards_rank') THEN
        CREATE INDEX idx_leaderboards_rank ON leaderboards(rank_position);
    END IF;
END $$;

-- Achievement Badges
CREATE TABLE IF NOT EXISTS badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    badge_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    icon TEXT, -- URL or icon name
    badge_type VARCHAR(100) NOT NULL, -- 'hours_milestone', 'event_completion', 'donation_level', 'streak', 'impact'
    criteria JSONB, -- Criteria to earn badge
    rarity VARCHAR(50) DEFAULT 'common', -- 'common', 'rare', 'epic', 'legendary'
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'badges') THEN
        ALTER TABLE badges ADD COLUMN IF NOT EXISTS description TEXT;
        ALTER TABLE badges ADD COLUMN IF NOT EXISTS icon TEXT;
        ALTER TABLE badges ADD COLUMN IF NOT EXISTS badge_type VARCHAR(100) DEFAULT 'general';
        ALTER TABLE badges ADD COLUMN IF NOT EXISTS criteria JSONB;
        ALTER TABLE badges ADD COLUMN IF NOT EXISTS rarity VARCHAR(50) DEFAULT 'common';
        ALTER TABLE badges ADD COLUMN IF NOT EXISTS points INTEGER DEFAULT 0;
    END IF;
END $$;

-- User Badges (earned)
CREATE TABLE IF NOT EXISTS user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    badge_id UUID REFERENCES badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMP DEFAULT NOW(),
    progress JSONB, -- Current progress towards badge
    UNIQUE(user_id, badge_id)
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_badges') THEN
        ALTER TABLE user_badges ADD COLUMN IF NOT EXISTS progress JSONB;
        ALTER TABLE user_badges ADD COLUMN IF NOT EXISTS earned_at TIMESTAMP DEFAULT NOW();
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_user_badges_user') THEN
        CREATE INDEX idx_user_badges_user ON user_badges(user_id);
    END IF;
END $$;

-- Challenges
CREATE TABLE IF NOT EXISTS challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    challenge_type VARCHAR(50) NOT NULL, -- 'volunteer_hours', 'donations', 'events', 'team'
    target_value DECIMAL(15, 2) NOT NULL,
    current_value DECIMAL(15, 2) DEFAULT 0,
    unit VARCHAR(50), -- 'hours', 'dollars', 'trees', 'meals'
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    created_by UUID REFERENCES users(id),
    ngo_id UUID REFERENCES ngos(id),
    is_global BOOLEAN DEFAULT true,
    reward_badge_id UUID REFERENCES badges(id),
    reward_points INTEGER DEFAULT 0,
    participant_count INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'completed', 'cancelled'
    image_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'challenges') THEN
        ALTER TABLE challenges ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'active';
        ALTER TABLE challenges ADD COLUMN IF NOT EXISTS image_url TEXT;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_challenges_status') THEN
        CREATE INDEX idx_challenges_status ON challenges(status);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_challenges_dates') THEN
        CREATE INDEX idx_challenges_dates ON challenges(start_date, end_date);
    END IF;
END $$;

-- Challenge Participants
CREATE TABLE IF NOT EXISTS challenge_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT NOW(),
    contribution DECIMAL(15, 2) DEFAULT 0,
    completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP,
    UNIQUE(challenge_id, user_id)
);

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_challenge_participants_user') THEN
        CREATE INDEX idx_challenge_participants_user ON challenge_participants(user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_challenge_participants_challenge') THEN
        CREATE INDEX idx_challenge_participants_challenge ON challenge_participants(challenge_id);
    END IF;
END $$;

-- Activity Streaks
CREATE TABLE IF NOT EXISTS activity_streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date DATE,
    streak_type VARCHAR(50) DEFAULT 'daily', -- 'daily', 'weekly'
    total_checkins INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_streaks_user') THEN
        CREATE INDEX idx_streaks_user ON activity_streaks(user_id);
    END IF;
END $$;

-- Community Score
CREATE TABLE IF NOT EXISTS community_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE UNIQUE,
    entity_type VARCHAR(50) NOT NULL, -- 'user', 'ngo'
    total_score INTEGER DEFAULT 0,
    volunteer_score INTEGER DEFAULT 0,
    donation_score INTEGER DEFAULT 0,
    engagement_score INTEGER DEFAULT 0,
    impact_score INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    next_level_points INTEGER DEFAULT 100,
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT check_entity CHECK (
        (entity_type = 'user' AND user_id IS NOT NULL AND ngo_id IS NULL) OR
        (entity_type = 'ngo' AND ngo_id IS NOT NULL AND user_id IS NULL)
    )
);

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_community_scores_type') THEN
        CREATE INDEX idx_community_scores_type ON community_scores(entity_type);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_community_scores_total') THEN
        CREATE INDEX idx_community_scores_total ON community_scores(total_score DESC);
    END IF;
END $$;

-- ================================================
-- REAL-TIME IMPACT TRACKING
-- ================================================

-- Live Counters
CREATE TABLE IF NOT EXISTS live_counters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    counter_name VARCHAR(100) NOT NULL UNIQUE,
    counter_value BIGINT DEFAULT 0,
    counter_type VARCHAR(50), -- 'volunteers', 'donations', 'hours', 'impact'
    last_updated TIMESTAMP DEFAULT NOW()
);

-- Impact Events (for timeline and map)
CREATE TABLE IF NOT EXISTS impact_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(50) NOT NULL, -- 'volunteer_signup', 'donation', 'event_completed', 'milestone'
    title VARCHAR(255) NOT NULL,
    description TEXT,
    user_id UUID REFERENCES users(id),
    ngo_id UUID REFERENCES ngos(id),
    event_id UUID REFERENCES events(id),
    impact_value DECIMAL(15, 2),
    impact_unit VARCHAR(50),
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_name VARCHAR(255),
    country VARCHAR(100),
    metadata JSONB, -- Additional event-specific data
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_events_type') THEN
        CREATE INDEX idx_impact_events_type ON impact_events(event_type);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_events_location') THEN
        CREATE INDEX idx_impact_events_location ON impact_events(location_lat, location_lng);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_events_created') THEN
        CREATE INDEX idx_impact_events_created ON impact_events(created_at DESC);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_events_ngo') THEN
        CREATE INDEX idx_impact_events_ngo ON impact_events(ngo_id);
    END IF;
END $$;

-- Impact Heatmap Data
CREATE TABLE IF NOT EXISTS impact_heatmap (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_lat DECIMAL(10, 8) NOT NULL,
    location_lng DECIMAL(11, 8) NOT NULL,
    location_name VARCHAR(255),
    country VARCHAR(100),
    activity_count INTEGER DEFAULT 0,
    volunteer_hours DECIMAL(10, 2) DEFAULT 0,
    donation_amount DECIMAL(15, 2) DEFAULT 0,
    people_helped INTEGER DEFAULT 0,
    intensity DECIMAL(5, 2), -- Heat intensity 0-100
    last_updated TIMESTAMP DEFAULT NOW()
);

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_heatmap_location') THEN
        CREATE INDEX idx_heatmap_location ON impact_heatmap(location_lat, location_lng);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_heatmap_intensity') THEN
        CREATE INDEX idx_heatmap_intensity ON impact_heatmap(intensity DESC);
    END IF;
END $$;

-- ================================================
-- ANALYTICS TABLES
-- ================================================

-- ROI Tracking
CREATE TABLE IF NOT EXISTS impact_roi (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ngo_id UUID REFERENCES ngos(id),
    event_id UUID REFERENCES events(id),
    calculation_type VARCHAR(50), -- 'event', 'project', 'ngo_overall'
    investment_amount DECIMAL(15, 2) NOT NULL,
    direct_impact_value DECIMAL(15, 2),
    indirect_impact_value DECIMAL(15, 2),
    total_roi DECIMAL(10, 2), -- ROI percentage
    people_impacted INTEGER,
    cost_per_person DECIMAL(10, 2),
    volunteer_hours DECIMAL(10, 2),
    calculation_date TIMESTAMP DEFAULT NOW(),
    methodology TEXT,
    notes TEXT
);

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_roi_ngo') THEN
        CREATE INDEX idx_roi_ngo ON impact_roi(ngo_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_roi_event') THEN
        CREATE INDEX idx_roi_event ON impact_roi(event_id);
    END IF;
END $$;

-- Predictive Analytics
CREATE TABLE IF NOT EXISTS analytics_predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prediction_type VARCHAR(50) NOT NULL, -- 'volunteer_need', 'donation_trend', 'event_success'
    entity_id UUID, -- ngo_id or event_id
    entity_type VARCHAR(50),
    predicted_value DECIMAL(15, 2),
    confidence_score DECIMAL(5, 2), -- 0-100
    prediction_period VARCHAR(50), -- 'next_week', 'next_month', 'next_quarter'
    factors JSONB, -- Factors considered in prediction
    created_at TIMESTAMP DEFAULT NOW(),
    valid_until TIMESTAMP
);

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_predictions_type') THEN
        CREATE INDEX idx_predictions_type ON analytics_predictions(prediction_type);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_predictions_entity') THEN
        CREATE INDEX idx_predictions_entity ON analytics_predictions(entity_id);
    END IF;
END $$;

-- Comparative Analytics
CREATE TABLE IF NOT EXISTS comparative_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ngo_id UUID REFERENCES ngos(id),
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15, 2),
    benchmark_average DECIMAL(15, 2),
    percentile DECIMAL(5, 2), -- Where this NGO ranks (0-100)
    comparison_period VARCHAR(50), -- 'weekly', 'monthly', 'yearly'
    period_start DATE,
    period_end DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'comparative_metrics') THEN
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS period_start DATE;
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS period_end DATE;
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS comparison_period VARCHAR(50);
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS benchmark_average DECIMAL(15, 2);
        ALTER TABLE comparative_metrics ADD COLUMN IF NOT EXISTS percentile DECIMAL(5, 2);
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_comparative_ngo') THEN
        CREATE INDEX idx_comparative_ngo ON comparative_metrics(ngo_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_comparative_period') THEN
        CREATE INDEX idx_comparative_period ON comparative_metrics(period_start, period_end);
    END IF;
END $$;

-- Impact Multiplier Tracking
CREATE TABLE IF NOT EXISTS impact_multipliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_event_id UUID REFERENCES events(id),
    source_donation_id UUID REFERENCES donations(id),
    multiplier_type VARCHAR(50), -- 'ripple_effect', 'community_growth', 'skill_transfer'
    initial_impact DECIMAL(15, 2),
    multiplied_impact DECIMAL(15, 2),
    multiplier_factor DECIMAL(5, 2),
    description TEXT,
    evidence JSONB, -- Supporting data
    created_at TIMESTAMP DEFAULT NOW()
);

-- Sustainability Metrics
CREATE TABLE IF NOT EXISTS sustainability_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ngo_id UUID REFERENCES ngos(id),
    event_id UUID REFERENCES events(id),
    metric_type VARCHAR(50), -- 'carbon_offset', 'waste_reduced', 'water_saved', 'trees_planted'
    value DECIMAL(15, 2),
    unit VARCHAR(50),
    calculation_method TEXT,
    verified BOOLEAN DEFAULT false,
    verified_by VARCHAR(255),
    date_measured DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_sustainability_ngo') THEN
        CREATE INDEX idx_sustainability_ngo ON sustainability_metrics(ngo_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_sustainability_type') THEN
        CREATE INDEX idx_sustainability_type ON sustainability_metrics(metric_type);
    END IF;
END $$;

-- ================================================
-- INITIAL DATA & BADGES
-- ================================================

-- Insert default badges (using the correct column order based on the error)
INSERT INTO badges (badge_name, description, icon, badge_type, criteria, rarity, points)
VALUES 
    ('First Step', 'Complete your first volunteer activity', '🌟', 'event_completion', '{"events": 1}'::jsonb, 'common', 10),
    ('Dedicated Helper', 'Volunteer for 10 hours', '⏰', 'hours_milestone', '{"hours": 10}'::jsonb, 'common', 25),
    ('Time Champion', 'Volunteer for 50 hours', '🏆', 'hours_milestone', '{"hours": 50}'::jsonb, 'rare', 100),
    ('Century Club', 'Volunteer for 100 hours', '💯', 'hours_milestone', '{"hours": 100}'::jsonb, 'epic', 250),
    ('Generous Donor', 'Make your first donation', '💰', 'donation_level', '{"donations": 1}'::jsonb, 'common', 20),
    ('Impact Maker', 'Donate $100 or more', '💎', 'donation_level', '{"amount": 100}'::jsonb, 'rare', 150),
    ('Week Warrior', 'Maintain a 7-day activity streak', '🔥', 'streak', '{"streak": 7}'::jsonb, 'rare', 75),
    ('Month Master', 'Maintain a 30-day activity streak', '⚡', 'streak', '{"streak": 30}'::jsonb, 'epic', 300),
    ('Event Organizer', 'Create 5 events', '📅', 'event_completion', '{"events_created": 5}'::jsonb, 'rare', 100),
    ('Community Builder', 'Help 100 people', '🤝', 'impact', '{"people_helped": 100}'::jsonb, 'epic', 200),
    ('Legend', 'Achieve 1000 impact points', '👑', 'impact', '{"impact_score": 1000}'::jsonb, 'legendary', 1000)
ON CONFLICT (badge_name) DO NOTHING;

-- Update any existing badges that have null descriptions
UPDATE badges SET 
    description = CASE badge_name
        WHEN 'First Step' THEN 'Complete your first volunteer activity'
        WHEN 'Dedicated Helper' THEN 'Volunteer for 10 hours'
        WHEN 'Time Champion' THEN 'Volunteer for 50 hours'
        WHEN 'Century Club' THEN 'Volunteer for 100 hours'
        WHEN 'Generous Donor' THEN 'Make your first donation'
        WHEN 'Impact Maker' THEN 'Donate $100 or more'
        WHEN 'Week Warrior' THEN 'Maintain a 7-day activity streak'
        WHEN 'Month Master' THEN 'Maintain a 30-day activity streak'
        WHEN 'Event Organizer' THEN 'Create 5 events'
        WHEN 'Community Builder' THEN 'Help 100 people'
        WHEN 'Legend' THEN 'Achieve 1000 impact points'
        ELSE description
    END,
    icon = CASE badge_name
        WHEN 'First Step' THEN '🌟'
        WHEN 'Dedicated Helper' THEN '⏰'
        WHEN 'Time Champion' THEN '🏆'
        WHEN 'Century Club' THEN '💯'
        WHEN 'Generous Donor' THEN '💰'
        WHEN 'Impact Maker' THEN '💎'
        WHEN 'Week Warrior' THEN '🔥'
        WHEN 'Month Master' THEN '⚡'
        WHEN 'Event Organizer' THEN '📅'
        WHEN 'Community Builder' THEN '🤝'
        WHEN 'Legend' THEN '👑'
        ELSE icon
    END,
    badge_type = CASE badge_name
        WHEN 'First Step' THEN 'event_completion'
        WHEN 'Dedicated Helper' THEN 'hours_milestone'
        WHEN 'Time Champion' THEN 'hours_milestone'
        WHEN 'Century Club' THEN 'hours_milestone'
        WHEN 'Generous Donor' THEN 'donation_level'
        WHEN 'Impact Maker' THEN 'donation_level'
        WHEN 'Week Warrior' THEN 'streak'
        WHEN 'Month Master' THEN 'streak'
        WHEN 'Event Organizer' THEN 'event_completion'
        WHEN 'Community Builder' THEN 'impact'
        WHEN 'Legend' THEN 'impact'
        ELSE badge_type
    END,
    criteria = CASE badge_name
        WHEN 'First Step' THEN '{"events": 1}'::jsonb
        WHEN 'Dedicated Helper' THEN '{"hours": 10}'::jsonb
        WHEN 'Time Champion' THEN '{"hours": 50}'::jsonb
        WHEN 'Century Club' THEN '{"hours": 100}'::jsonb
        WHEN 'Generous Donor' THEN '{"donations": 1}'::jsonb
        WHEN 'Impact Maker' THEN '{"amount": 100}'::jsonb
        WHEN 'Week Warrior' THEN '{"streak": 7}'::jsonb
        WHEN 'Month Master' THEN '{"streak": 30}'::jsonb
        WHEN 'Event Organizer' THEN '{"events_created": 5}'::jsonb
        WHEN 'Community Builder' THEN '{"people_helped": 100}'::jsonb
        WHEN 'Legend' THEN '{"impact_score": 1000}'::jsonb
        ELSE criteria
    END,
    rarity = CASE badge_name
        WHEN 'First Step' THEN 'common'
        WHEN 'Dedicated Helper' THEN 'common'
        WHEN 'Time Champion' THEN 'rare'
        WHEN 'Century Club' THEN 'epic'
        WHEN 'Generous Donor' THEN 'common'
        WHEN 'Impact Maker' THEN 'rare'
        WHEN 'Week Warrior' THEN 'rare'
        WHEN 'Month Master' THEN 'epic'
        WHEN 'Event Organizer' THEN 'rare'
        WHEN 'Community Builder' THEN 'epic'
        WHEN 'Legend' THEN 'legendary'
        ELSE rarity
    END,
    points = CASE badge_name
        WHEN 'First Step' THEN 10
        WHEN 'Dedicated Helper' THEN 25
        WHEN 'Time Champion' THEN 100
        WHEN 'Century Club' THEN 250
        WHEN 'Generous Donor' THEN 20
        WHEN 'Impact Maker' THEN 150
        WHEN 'Week Warrior' THEN 75
        WHEN 'Month Master' THEN 300
        WHEN 'Event Organizer' THEN 100
        WHEN 'Community Builder' THEN 200
        WHEN 'Legend' THEN 1000
        ELSE points
    END
WHERE badge_name IN ('First Step', 'Dedicated Helper', 'Time Champion', 'Century Club', 'Generous Donor', 'Impact Maker', 'Week Warrior', 'Month Master', 'Event Organizer', 'Community Builder', 'Legend');

-- Initialize live counters
INSERT INTO live_counters (counter_name, counter_value, counter_type)
VALUES 
    ('total_volunteers', 0, 'volunteers'),
    ('total_volunteer_hours', 0, 'hours'),
    ('total_donations', 0, 'donations'),
    ('total_people_helped', 0, 'impact'),
    ('total_events', 0, 'events'),
    ('total_ngos', 0, 'impact'),
    ('trees_planted', 0, 'impact'),
    ('meals_provided', 0, 'impact')
ON CONFLICT (counter_name) DO NOTHING;

-- ================================================
-- FUNCTIONS FOR AUTOMATIC UPDATES
-- ================================================

-- Function to update leaderboard rankings
CREATE OR REPLACE FUNCTION update_leaderboard_rankings()
RETURNS TRIGGER AS $$
BEGIN
    -- Update rankings by recalculating rank positions
    WITH ranked AS (
        SELECT 
            id,
            ROW_NUMBER() OVER (
                PARTITION BY category, metric_type 
                ORDER BY total_value DESC
            ) as new_rank
        FROM leaderboards
    )
    UPDATE leaderboards l
    SET rank_position = r.new_rank,
        last_updated = NOW()
    FROM ranked r
    WHERE l.id = r.id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for leaderboard updates (drop if exists first)
DROP TRIGGER IF EXISTS trigger_update_leaderboard_rankings ON leaderboards;
CREATE TRIGGER trigger_update_leaderboard_rankings
AFTER INSERT OR UPDATE ON leaderboards
FOR EACH STATEMENT
EXECUTE FUNCTION update_leaderboard_rankings();

-- Function to check and award badges
CREATE OR REPLACE FUNCTION check_and_award_badges()
RETURNS TRIGGER AS $$
BEGIN
    -- This is a placeholder - actual badge awarding logic should be in application
    -- But this ensures the trigger exists for future use
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update community scores
CREATE OR REPLACE FUNCTION calculate_level(points INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN FLOOR(SQRT(points / 100.0)) + 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE leaderboards IS 'Tracks rankings for volunteers, donors, and NGOs';
COMMENT ON TABLE badges IS 'Available achievement badges in the system';
COMMENT ON TABLE challenges IS 'Community challenges and goals';
COMMENT ON TABLE activity_streaks IS 'User activity streak tracking';
COMMENT ON TABLE impact_events IS 'Timeline of all impact events for visualization';
COMMENT ON TABLE impact_roi IS 'Return on Investment calculations for impact';
COMMENT ON TABLE sustainability_metrics IS 'Environmental impact tracking';
