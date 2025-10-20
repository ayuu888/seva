-- ============================================================================
-- IMPACT MEASUREMENT SYSTEM - COMPREHENSIVE SCHEMA
-- ============================================================================
-- This schema creates all tables needed for impact measurement, tracking, and analytics
-- Safe execution with IF NOT EXISTS checks and column addition for existing tables

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- CORE IMPACT MEASUREMENT TABLES
-- ============================================================================

-- Impact Metrics Table (Quantitative tracking)
CREATE TABLE IF NOT EXISTS impact_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    metric_type VARCHAR(100) NOT NULL, -- volunteer_hours, donations, people_helped, projects_completed
    value DECIMAL(15, 2) NOT NULL,
    unit VARCHAR(50), -- hours, dollars, people, projects
    date DATE NOT NULL,
    description TEXT,
    verified BOOLEAN DEFAULT FALSE,
    verified_by UUID REFERENCES users(id) ON DELETE SET NULL,
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Success Stories Table (Qualitative impact)
CREATE TABLE IF NOT EXISTS success_stories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author_id UUID REFERENCES users(id) ON DELETE CASCADE,
    ngo_id UUID REFERENCES ngos(id) ON DELETE SET NULL,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    category VARCHAR(100), -- personal, community, environmental, educational
    images TEXT[] DEFAULT '{}',
    video_url TEXT,
    impact_numbers JSONB DEFAULT '{}', -- {people_helped: 100, hours_spent: 50}
    tags TEXT[] DEFAULT '{}',
    featured BOOLEAN DEFAULT FALSE,
    published BOOLEAN DEFAULT TRUE,
    views_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Impact Testimonials Table
CREATE TABLE IF NOT EXISTS impact_testimonials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    ngo_id UUID REFERENCES ngos(id) ON DELETE SET NULL,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    testimonial TEXT NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    role VARCHAR(100), -- volunteer, beneficiary, donor, partner
    location VARCHAR(255),
    avatar TEXT,
    name VARCHAR(255) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Case Studies Table (Detailed project analysis)
CREATE TABLE IF NOT EXISTS case_studies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    summary TEXT NOT NULL,
    full_content TEXT NOT NULL,
    ngo_id UUID REFERENCES ngos(id) ON DELETE SET NULL,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    author_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Problem Statement
    problem_statement TEXT,
    
    -- Solution & Approach
    solution TEXT,
    approach TEXT,
    
    -- Timeline
    start_date DATE,
    end_date DATE,
    duration_months INTEGER,
    
    -- Impact Data
    beneficiaries_count INTEGER,
    volunteers_involved INTEGER,
    funds_utilized DECIMAL(15, 2),
    
    -- Outcomes
    outcomes JSONB DEFAULT '{}', -- {metric: value}
    challenges TEXT,
    learnings TEXT,
    
    -- Media
    images TEXT[] DEFAULT '{}',
    documents TEXT[] DEFAULT '{}',
    
    -- Metadata
    category VARCHAR(100),
    tags TEXT[] DEFAULT '{}',
    featured BOOLEAN DEFAULT FALSE,
    published BOOLEAN DEFAULT TRUE,
    views_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Outcome Tracking Table (Long-term impact measurement)
CREATE TABLE IF NOT EXISTS outcome_tracking (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    case_study_id UUID REFERENCES case_studies(id) ON DELETE SET NULL,
    
    -- Outcome Details
    outcome_title VARCHAR(255) NOT NULL,
    outcome_description TEXT,
    target_metric VARCHAR(100), -- literacy_rate, health_improvement, income_increase
    baseline_value DECIMAL(15, 2),
    target_value DECIMAL(15, 2),
    current_value DECIMAL(15, 2),
    unit VARCHAR(50),
    
    -- Timeline
    start_date DATE NOT NULL,
    target_date DATE,
    last_measured_date DATE,
    
    -- Status
    status VARCHAR(50) DEFAULT 'in_progress', -- in_progress, achieved, at_risk, delayed
    progress_percentage DECIMAL(5, 2),
    
    -- Updates
    updates JSONB DEFAULT '[]', -- [{date, value, notes}]
    
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Community Growth Tracking
CREATE TABLE IF NOT EXISTS community_growth (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    metric_name VARCHAR(100) NOT NULL, -- total_volunteers, active_members, beneficiaries_served
    value INTEGER NOT NULL,
    date DATE NOT NULL,
    growth_rate DECIMAL(10, 2), -- percentage growth from previous period
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(ngo_id, metric_name, date)
);

-- Story Interactions
CREATE TABLE IF NOT EXISTS story_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    story_id UUID REFERENCES success_stories(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(story_id, user_id)
);

CREATE TABLE IF NOT EXISTS story_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    story_id UUID REFERENCES success_stories(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    user_name VARCHAR(255) NOT NULL,
    user_avatar TEXT,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Impact Dashboard Snapshots (for reporting)
CREATE TABLE IF NOT EXISTS impact_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    snapshot_date DATE NOT NULL,
    
    -- Aggregated Metrics
    total_volunteer_hours DECIMAL(15, 2) DEFAULT 0,
    total_donations DECIMAL(15, 2) DEFAULT 0,
    total_people_helped INTEGER DEFAULT 0,
    total_projects INTEGER DEFAULT 0,
    total_events INTEGER DEFAULT 0,
    total_volunteers INTEGER DEFAULT 0,
    
    -- Growth Metrics
    month_over_month_growth JSONB DEFAULT '{}',
    year_over_year_growth JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(ngo_id, snapshot_date)
);

-- ============================================================================
-- ADVANCED IMPACT ANALYTICS TABLES
-- ============================================================================

-- Impact Events (for timeline and map visualization)
CREATE TABLE IF NOT EXISTS impact_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Impact Heatmap Data
CREATE TABLE IF NOT EXISTS impact_heatmap (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    location_lat DECIMAL(10, 8) NOT NULL,
    location_lng DECIMAL(11, 8) NOT NULL,
    location_name VARCHAR(255),
    country VARCHAR(100),
    activity_count INTEGER DEFAULT 0,
    volunteer_hours DECIMAL(10, 2) DEFAULT 0,
    donation_amount DECIMAL(15, 2) DEFAULT 0,
    people_helped INTEGER DEFAULT 0,
    intensity DECIMAL(5, 2), -- Heat intensity 0-100
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ROI Tracking
CREATE TABLE IF NOT EXISTS impact_roi (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
    calculation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    methodology TEXT,
    notes TEXT
);

-- Predictive Analytics
CREATE TABLE IF NOT EXISTS analytics_predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prediction_type VARCHAR(50) NOT NULL, -- 'volunteer_need', 'donation_trend', 'event_success'
    entity_id UUID, -- ngo_id or event_id
    entity_type VARCHAR(50),
    predicted_value DECIMAL(15, 2),
    confidence_score DECIMAL(5, 2), -- 0-100
    prediction_period VARCHAR(50), -- 'next_week', 'next_month', 'next_quarter'
    factors JSONB, -- Factors considered in prediction
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_until TIMESTAMP WITH TIME ZONE
);

-- Comparative Analytics
CREATE TABLE IF NOT EXISTS comparative_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ngo_id UUID REFERENCES ngos(id),
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15, 2),
    benchmark_average DECIMAL(15, 2),
    percentile DECIMAL(5, 2), -- Where this NGO ranks (0-100)
    comparison_period VARCHAR(50), -- 'weekly', 'monthly', 'yearly'
    period_start DATE,
    period_end DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Impact Multipliers (for advanced analytics)
CREATE TABLE IF NOT EXISTS impact_multipliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ngo_id UUID REFERENCES ngos(id),
    multiplier_type VARCHAR(50) NOT NULL, -- 'volunteer_engagement', 'donation_leverage', 'community_reach'
    base_value DECIMAL(15, 2) NOT NULL,
    multiplier_factor DECIMAL(10, 2) NOT NULL,
    calculated_value DECIMAL(15, 2) NOT NULL,
    calculation_method TEXT,
    calculation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT
);

-- Sustainability Metrics
CREATE TABLE IF NOT EXISTS sustainability_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ngo_id UUID REFERENCES ngos(id),
    metric_name VARCHAR(100) NOT NULL,
    current_value DECIMAL(15, 2),
    target_value DECIMAL(15, 2),
    unit VARCHAR(50),
    measurement_period VARCHAR(50), -- 'monthly', 'quarterly', 'yearly'
    last_measured_date DATE,
    trend_direction VARCHAR(20), -- 'increasing', 'decreasing', 'stable'
    sustainability_score DECIMAL(5, 2), -- 0-100
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- SAFE COLUMN ADDITIONS FOR EXISTING TABLES
-- ============================================================================

-- Ensure all required columns exist in impact_multipliers table
DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'impact_multipliers') THEN
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS ngo_id UUID REFERENCES ngos(id);
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS multiplier_type VARCHAR(50) NOT NULL;
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS base_value DECIMAL(15, 2) NOT NULL;
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS multiplier_factor DECIMAL(10, 2) NOT NULL;
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS calculated_value DECIMAL(15, 2) NOT NULL;
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS calculation_method TEXT;
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS calculation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        ALTER TABLE impact_multipliers ADD COLUMN IF NOT EXISTS notes TEXT;
    END IF;
END $$;

-- Ensure all required columns exist in sustainability_metrics table
DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sustainability_metrics') THEN
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS ngo_id UUID REFERENCES ngos(id);
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS metric_name VARCHAR(100) NOT NULL;
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS current_value DECIMAL(15, 2);
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS target_value DECIMAL(15, 2);
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS unit VARCHAR(50);
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS measurement_period VARCHAR(50);
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS last_measured_date DATE;
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS trend_direction VARCHAR(20);
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS sustainability_score DECIMAL(5, 2);
        ALTER TABLE sustainability_metrics ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Ensure all required columns exist in existing tables
DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'impact_metrics') THEN
        ALTER TABLE impact_metrics ADD COLUMN IF NOT EXISTS verified_by UUID REFERENCES users(id) ON DELETE SET NULL;
        ALTER TABLE impact_metrics ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP WITH TIME ZONE;
        ALTER TABLE impact_metrics ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'success_stories') THEN
        ALTER TABLE success_stories ADD COLUMN IF NOT EXISTS impact_numbers JSONB DEFAULT '{}';
        ALTER TABLE success_stories ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}';
        ALTER TABLE success_stories ADD COLUMN IF NOT EXISTS views_count INTEGER DEFAULT 0;
        ALTER TABLE success_stories ADD COLUMN IF NOT EXISTS likes_count INTEGER DEFAULT 0;
        ALTER TABLE success_stories ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'impact_testimonials') THEN
        ALTER TABLE impact_testimonials ADD COLUMN IF NOT EXISTS rating INTEGER CHECK (rating >= 1 AND rating <= 5);
        ALTER TABLE impact_testimonials ADD COLUMN IF NOT EXISTS role VARCHAR(100);
        ALTER TABLE impact_testimonials ADD COLUMN IF NOT EXISTS location VARCHAR(255);
        ALTER TABLE impact_testimonials ADD COLUMN IF NOT EXISTS avatar TEXT;
        ALTER TABLE impact_testimonials ADD COLUMN IF NOT EXISTS verified BOOLEAN DEFAULT FALSE;
        ALTER TABLE impact_testimonials ADD COLUMN IF NOT EXISTS featured BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'case_studies') THEN
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS problem_statement TEXT;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS solution TEXT;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS approach TEXT;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS start_date DATE;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS end_date DATE;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS duration_months INTEGER;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS beneficiaries_count INTEGER;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS volunteers_involved INTEGER;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS funds_utilized DECIMAL(15, 2);
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS outcomes JSONB DEFAULT '{}';
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS challenges TEXT;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS learnings TEXT;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS images TEXT[] DEFAULT '{}';
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS documents TEXT[] DEFAULT '{}';
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS category VARCHAR(100);
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}';
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS featured BOOLEAN DEFAULT FALSE;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS views_count INTEGER DEFAULT 0;
        ALTER TABLE case_studies ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'outcome_tracking') THEN
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS outcome_title VARCHAR(255) NOT NULL;
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS outcome_description TEXT;
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS target_metric VARCHAR(100);
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS baseline_value DECIMAL(15, 2);
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS target_value DECIMAL(15, 2);
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS current_value DECIMAL(15, 2);
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS unit VARCHAR(50);
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS start_date DATE NOT NULL;
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS target_date DATE;
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS last_measured_date DATE;
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'in_progress';
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS progress_percentage DECIMAL(5, 2);
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS updates JSONB DEFAULT '[]';
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES users(id) ON DELETE SET NULL;
        ALTER TABLE outcome_tracking ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- ============================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================================================

-- Core impact metrics indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_metrics_ngo') THEN
        CREATE INDEX idx_impact_metrics_ngo ON impact_metrics(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_metrics_date') THEN
        CREATE INDEX idx_impact_metrics_date ON impact_metrics(date);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_metrics_type') THEN
        CREATE INDEX idx_impact_metrics_type ON impact_metrics(metric_type);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_metrics_event') THEN
        CREATE INDEX idx_impact_metrics_event ON impact_metrics(event_id);
    END IF;
END $$;

-- Success stories indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_success_stories_ngo') THEN
        CREATE INDEX idx_success_stories_ngo ON success_stories(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_success_stories_featured') THEN
        CREATE INDEX idx_success_stories_featured ON success_stories(featured);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_success_stories_published') THEN
        CREATE INDEX idx_success_stories_published ON success_stories(published);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_success_stories_author') THEN
        CREATE INDEX idx_success_stories_author ON success_stories(author_id);
    END IF;
END $$;

-- Testimonials indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_testimonials_ngo') THEN
        CREATE INDEX idx_testimonials_ngo ON impact_testimonials(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_testimonials_featured') THEN
        CREATE INDEX idx_testimonials_featured ON impact_testimonials(featured);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_testimonials_rating') THEN
        CREATE INDEX idx_testimonials_rating ON impact_testimonials(rating);
    END IF;
END $$;

-- Case studies indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_case_studies_ngo') THEN
        CREATE INDEX idx_case_studies_ngo ON case_studies(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_case_studies_featured') THEN
        CREATE INDEX idx_case_studies_featured ON case_studies(featured);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_case_studies_published') THEN
        CREATE INDEX idx_case_studies_published ON case_studies(published);
    END IF;
END $$;

-- Outcome tracking indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_outcome_tracking_ngo') THEN
        CREATE INDEX idx_outcome_tracking_ngo ON outcome_tracking(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_outcome_tracking_status') THEN
        CREATE INDEX idx_outcome_tracking_status ON outcome_tracking(status);
    END IF;
END $$;

-- Community growth indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_community_growth_ngo') THEN
        CREATE INDEX idx_community_growth_ngo ON community_growth(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_community_growth_metric') THEN
        CREATE INDEX idx_community_growth_metric ON community_growth(metric_name);
    END IF;
END $$;

-- Story interactions indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_story_likes_story') THEN
        CREATE INDEX idx_story_likes_story ON story_likes(story_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_story_likes_user') THEN
        CREATE INDEX idx_story_likes_user ON story_likes(user_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_story_comments_story') THEN
        CREATE INDEX idx_story_comments_story ON story_comments(story_id);
    END IF;
END $$;

-- Impact snapshots indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_snapshots_ngo') THEN
        CREATE INDEX idx_impact_snapshots_ngo ON impact_snapshots(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_snapshots_date') THEN
        CREATE INDEX idx_impact_snapshots_date ON impact_snapshots(snapshot_date);
    END IF;
END $$;

-- Advanced analytics indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_events_type') THEN
        CREATE INDEX idx_impact_events_type ON impact_events(event_type);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_events_location') THEN
        CREATE INDEX idx_impact_events_location ON impact_events(location_lat, location_lng);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_events_created') THEN
        CREATE INDEX idx_impact_events_created ON impact_events(created_at DESC);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_events_ngo') THEN
        CREATE INDEX idx_impact_events_ngo ON impact_events(ngo_id);
    END IF;
END $$;

-- Heatmap indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_heatmap_location') THEN
        CREATE INDEX idx_heatmap_location ON impact_heatmap(location_lat, location_lng);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_heatmap_intensity') THEN
        CREATE INDEX idx_heatmap_intensity ON impact_heatmap(intensity DESC);
    END IF;
END $$;

-- ROI indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_roi_ngo') THEN
        CREATE INDEX idx_roi_ngo ON impact_roi(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_roi_event') THEN
        CREATE INDEX idx_roi_event ON impact_roi(event_id);
    END IF;
END $$;

-- Predictions indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_predictions_type') THEN
        CREATE INDEX idx_predictions_type ON analytics_predictions(prediction_type);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_predictions_entity') THEN
        CREATE INDEX idx_predictions_entity ON analytics_predictions(entity_id);
    END IF;
END $$;

-- Comparative metrics indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_comparative_ngo') THEN
        CREATE INDEX idx_comparative_ngo ON comparative_metrics(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_comparative_metric') THEN
        CREATE INDEX idx_comparative_metric ON comparative_metrics(metric_name);
    END IF;
END $$;

-- Impact multipliers indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_multipliers_ngo') THEN
        CREATE INDEX idx_impact_multipliers_ngo ON impact_multipliers(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_impact_multipliers_type') THEN
        CREATE INDEX idx_impact_multipliers_type ON impact_multipliers(multiplier_type);
    END IF;
END $$;

-- Sustainability metrics indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_sustainability_ngo') THEN
        CREATE INDEX idx_sustainability_ngo ON sustainability_metrics(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_sustainability_metric') THEN
        CREATE INDEX idx_sustainability_metric ON sustainability_metrics(metric_name);
    END IF;
END $$;

-- ============================================================================
-- HELPER FUNCTIONS FOR IMPACT MEASUREMENT
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate impact metrics aggregation
CREATE OR REPLACE FUNCTION calculate_impact_aggregation(ngo_uuid UUID, start_date DATE, end_date DATE)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'total_volunteer_hours', COALESCE(SUM(CASE WHEN metric_type = 'volunteer_hours' THEN value ELSE 0 END), 0),
        'total_donations', COALESCE(SUM(CASE WHEN metric_type = 'donations' THEN value ELSE 0 END), 0),
        'total_people_helped', COALESCE(SUM(CASE WHEN metric_type = 'people_helped' THEN value ELSE 0 END), 0),
        'total_projects', COALESCE(SUM(CASE WHEN metric_type = 'projects_completed' THEN value ELSE 0 END), 0)
    ) INTO result
    FROM impact_metrics
    WHERE ngo_id = ngo_uuid
        AND date BETWEEN start_date AND end_date;
    
    RETURN COALESCE(result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql;

-- Function to update story like count
CREATE OR REPLACE FUNCTION update_story_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE success_stories 
        SET likes_count = likes_count + 1 
        WHERE id = NEW.story_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE success_stories 
        SET likes_count = likes_count - 1 
        WHERE id = OLD.story_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to create impact snapshot
CREATE OR REPLACE FUNCTION create_impact_snapshot(ngo_uuid UUID, snapshot_date DATE)
RETURNS UUID AS $$
DECLARE
    snapshot_id UUID;
    aggregated_metrics JSONB;
BEGIN
    -- Calculate aggregated metrics
    aggregated_metrics := calculate_impact_aggregation(ngo_uuid, snapshot_date - INTERVAL '30 days', snapshot_date);
    
    -- Insert snapshot
    INSERT INTO impact_snapshots (
        ngo_id, snapshot_date,
        total_volunteer_hours, total_donations, total_people_helped, total_projects
    ) VALUES (
        ngo_uuid, snapshot_date,
        COALESCE((aggregated_metrics->>'total_volunteer_hours')::DECIMAL(15,2), 0),
        COALESCE((aggregated_metrics->>'total_donations')::DECIMAL(15,2), 0),
        COALESCE((aggregated_metrics->>'total_people_helped')::INTEGER, 0),
        COALESCE((aggregated_metrics->>'total_projects')::INTEGER, 0)
    )
    ON CONFLICT (ngo_id, snapshot_date) DO UPDATE SET
        total_volunteer_hours = EXCLUDED.total_volunteer_hours,
        total_donations = EXCLUDED.total_donations,
        total_people_helped = EXCLUDED.total_people_helped,
        total_projects = EXCLUDED.total_projects,
        created_at = NOW()
    RETURNING id INTO snapshot_id;
    
    RETURN snapshot_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================================================

-- Triggers for updated_at columns
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_impact_metrics_updated_at') THEN
        CREATE TRIGGER update_impact_metrics_updated_at BEFORE UPDATE ON impact_metrics
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_success_stories_updated_at') THEN
        CREATE TRIGGER update_success_stories_updated_at BEFORE UPDATE ON success_stories
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_case_studies_updated_at') THEN
        CREATE TRIGGER update_case_studies_updated_at BEFORE UPDATE ON case_studies
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_outcome_tracking_updated_at') THEN
        CREATE TRIGGER update_outcome_tracking_updated_at BEFORE UPDATE ON outcome_tracking
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_sustainability_metrics_updated_at') THEN
        CREATE TRIGGER update_sustainability_metrics_updated_at BEFORE UPDATE ON sustainability_metrics
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- Triggers for story likes count
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_story_likes_count_insert') THEN
        CREATE TRIGGER update_story_likes_count_insert AFTER INSERT ON story_likes
            FOR EACH ROW EXECUTE FUNCTION update_story_likes_count();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_story_likes_count_delete') THEN
        CREATE TRIGGER update_story_likes_count_delete AFTER DELETE ON story_likes
            FOR EACH ROW EXECUTE FUNCTION update_story_likes_count();
    END IF;
END $$;

-- ============================================================================
-- INITIAL DATA SETUP
-- ============================================================================

-- Insert default metric types for reference
INSERT INTO impact_metrics (ngo_id, metric_type, value, unit, date, description) 
VALUES 
    (NULL, 'volunteer_hours', 0, 'hours', CURRENT_DATE, 'Default volunteer hours metric type'),
    (NULL, 'donations', 0, 'dollars', CURRENT_DATE, 'Default donations metric type'),
    (NULL, 'people_helped', 0, 'people', CURRENT_DATE, 'Default people helped metric type'),
    (NULL, 'projects_completed', 0, 'projects', CURRENT_DATE, 'Default projects completed metric type')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'Impact Measurement System Schema Complete!';
    RAISE NOTICE 'Created tables: impact_metrics, success_stories, impact_testimonials, case_studies';
    RAISE NOTICE 'Created tables: outcome_tracking, community_growth, story_likes, story_comments';
    RAISE NOTICE 'Created tables: impact_snapshots, impact_events, impact_heatmap, impact_roi';
    RAISE NOTICE 'Created tables: analytics_predictions, comparative_metrics, impact_multipliers, sustainability_metrics';
    RAISE NOTICE 'Added comprehensive indexes for optimal performance';
    RAISE NOTICE 'Set up automatic triggers and helper functions';
    RAISE NOTICE 'Impact measurement system is now fully functional!';
END $$;
