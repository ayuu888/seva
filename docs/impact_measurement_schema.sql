-- Impact Measurement Tables for Seva-Setu
-- Add these tables to your existing Supabase schema

-- Impact Metrics Table (Quantitative)
CREATE TABLE IF NOT EXISTS impact_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    metric_type VARCHAR(100) NOT NULL, -- volunteer_hours, donations, people_helped, projects_completed, etc.
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

-- Success Stories Table (Qualitative)
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

-- Case Studies Table
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

-- Long-term Outcome Tracking
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

-- Story Likes
CREATE TABLE IF NOT EXISTS story_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    story_id UUID REFERENCES success_stories(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(story_id, user_id)
);

-- Story Comments
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

-- Create Indexes
CREATE INDEX IF NOT EXISTS idx_impact_metrics_ngo ON impact_metrics(ngo_id);
CREATE INDEX IF NOT EXISTS idx_impact_metrics_date ON impact_metrics(date);
CREATE INDEX IF NOT EXISTS idx_impact_metrics_type ON impact_metrics(metric_type);
CREATE INDEX IF NOT EXISTS idx_success_stories_ngo ON success_stories(ngo_id);
CREATE INDEX IF NOT EXISTS idx_success_stories_featured ON success_stories(featured);
CREATE INDEX IF NOT EXISTS idx_testimonials_ngo ON impact_testimonials(ngo_id);
CREATE INDEX IF NOT EXISTS idx_case_studies_ngo ON case_studies(ngo_id);
CREATE INDEX IF NOT EXISTS idx_outcome_tracking_ngo ON outcome_tracking(ngo_id);
CREATE INDEX IF NOT EXISTS idx_community_growth_ngo ON community_growth(ngo_id);

-- Create updated_at triggers
CREATE TRIGGER update_impact_metrics_updated_at BEFORE UPDATE ON impact_metrics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_success_stories_updated_at BEFORE UPDATE ON success_stories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_case_studies_updated_at BEFORE UPDATE ON case_studies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_outcome_tracking_updated_at BEFORE UPDATE ON outcome_tracking
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
