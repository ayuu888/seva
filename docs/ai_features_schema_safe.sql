-- ============================================================================
-- AI FEATURES SYSTEM - COMPREHENSIVE SCHEMA
-- ============================================================================
-- This schema creates all tables needed for AI-powered features including
-- volunteer matching, impact prediction, content recommendations, and smart search
-- Safe execution with IF NOT EXISTS checks and column addition for existing tables

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- AI CORE TABLES
-- ============================================================================

-- AI Model Configurations
CREATE TABLE IF NOT EXISTS ai_model_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_name VARCHAR(100) NOT NULL UNIQUE, -- 'gemini-pro', 'openai-gpt-4', etc.
    model_type VARCHAR(50) NOT NULL, -- 'text', 'image', 'embedding'
    provider VARCHAR(50) NOT NULL, -- 'google', 'openai', 'anthropic'
    api_key_name VARCHAR(100), -- Environment variable name for API key
    is_active BOOLEAN DEFAULT TRUE,
    rate_limit_per_minute INTEGER DEFAULT 60,
    cost_per_request DECIMAL(10, 6) DEFAULT 0.001,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI Request Logs (for monitoring and debugging)
CREATE TABLE IF NOT EXISTS ai_request_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    model_name VARCHAR(100) NOT NULL,
    endpoint VARCHAR(100) NOT NULL, -- '/ai/volunteer-matching', '/ai/smart-search', etc.
    request_type VARCHAR(50) NOT NULL, -- 'volunteer_matching', 'impact_prediction', 'recommendations'
    input_tokens INTEGER DEFAULT 0,
    output_tokens INTEGER DEFAULT 0,
    total_tokens INTEGER DEFAULT 0,
    cost DECIMAL(10, 6) DEFAULT 0,
    response_time_ms INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'success', -- 'success', 'error', 'timeout'
    error_message TEXT,
    request_data JSONB,
    response_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI Learning Data (for improving recommendations and matching)
CREATE TABLE IF NOT EXISTS ai_learning_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    data_type VARCHAR(50) NOT NULL, -- 'user_preference', 'volunteer_match', 'content_interaction'
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    entity_id UUID, -- ID of the entity (event, post, ngo, etc.)
    entity_type VARCHAR(50), -- 'event', 'post', 'ngo', 'volunteer'
    interaction_type VARCHAR(50), -- 'like', 'apply', 'attend', 'follow', 'share'
    interaction_value DECIMAL(5, 2), -- Rating or score (1-5)
    context_data JSONB, -- Additional context like location, time, category
    feedback_data JSONB, -- User feedback on AI recommendations
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- VOLUNTEER MATCHING AI TABLES
-- ============================================================================

-- Volunteer Matching Results
CREATE TABLE IF NOT EXISTS ai_volunteer_matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    volunteer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    match_score DECIMAL(5, 2) NOT NULL, -- 0-100 compatibility score
    match_reasons JSONB, -- Reasons for the match (skills, interests, location)
    ai_model_used VARCHAR(100) NOT NULL,
    matching_criteria JSONB, -- Criteria used for matching
    recommended_roles TEXT[], -- Suggested roles for the volunteer
    confidence_level VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high'
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'accepted', 'rejected', 'applied'
    feedback_rating INTEGER CHECK (feedback_rating >= 1 AND feedback_rating <= 5),
    feedback_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(event_id, volunteer_id)
);

-- Volunteer Skill Profiles (AI-enhanced)
CREATE TABLE IF NOT EXISTS ai_volunteer_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    skills_vector FLOAT[], -- Embedding vector for skills
    interests_vector FLOAT[], -- Embedding vector for interests
    experience_level VARCHAR(20) DEFAULT 'beginner', -- 'beginner', 'intermediate', 'advanced', 'expert'
    availability_pattern JSONB, -- When they're typically available
    preferred_roles TEXT[], -- Preferred volunteer roles
    preferred_causes TEXT[], -- Preferred causes/categories
    location_preferences JSONB, -- Location and travel preferences
    ai_confidence_score DECIMAL(5, 2), -- AI confidence in profile accuracy
    last_profile_update TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- IMPACT PREDICTION AI TABLES
-- ============================================================================

-- Impact Prediction Results
CREATE TABLE IF NOT EXISTS ai_impact_predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    ngo_id UUID REFERENCES ngos(id) ON DELETE CASCADE,
    prediction_type VARCHAR(50) NOT NULL, -- 'event_success', 'volunteer_engagement', 'donation_potential'
    success_probability DECIMAL(5, 2) NOT NULL, -- 0-100 probability
    confidence_score DECIMAL(5, 2) NOT NULL, -- 0-100 confidence
    predicted_metrics JSONB, -- Predicted outcomes (volunteer_count, donation_amount, etc.)
    success_factors JSONB, -- Factors that contribute to success
    risk_factors JSONB, -- Factors that might hinder success
    recommendations JSONB, -- AI-generated recommendations
    ai_model_used VARCHAR(100) NOT NULL,
    input_data JSONB, -- Data used for prediction
    actual_outcome JSONB, -- Actual results (filled after event completion)
    prediction_accuracy DECIMAL(5, 2), -- How accurate the prediction was
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Impact Prediction Models (for tracking model performance)
CREATE TABLE IF NOT EXISTS ai_prediction_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_name VARCHAR(100) NOT NULL,
    model_version VARCHAR(20) NOT NULL,
    prediction_type VARCHAR(50) NOT NULL,
    training_data_size INTEGER DEFAULT 0,
    accuracy_score DECIMAL(5, 2) DEFAULT 0,
    precision_score DECIMAL(5, 2) DEFAULT 0,
    recall_score DECIMAL(5, 2) DEFAULT 0,
    f1_score DECIMAL(5, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- CONTENT RECOMMENDATION AI TABLES
-- ============================================================================

-- User Recommendation Profiles
CREATE TABLE IF NOT EXISTS ai_user_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50) NOT NULL, -- 'posts', 'events', 'ngos', 'volunteers'
    entity_id UUID NOT NULL, -- ID of recommended entity
    entity_type VARCHAR(50) NOT NULL, -- 'post', 'event', 'ngo', 'user'
    recommendation_score DECIMAL(5, 2) NOT NULL, -- 0-100 relevance score
    recommendation_reasons JSONB, -- Why this was recommended
    ai_model_used VARCHAR(100) NOT NULL,
    user_interaction VARCHAR(20), -- 'viewed', 'clicked', 'liked', 'shared', 'ignored'
    interaction_timestamp TIMESTAMP WITH TIME ZONE,
    feedback_rating INTEGER CHECK (feedback_rating >= 1 AND feedback_rating <= 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Content Embeddings (for semantic search and recommendations)
CREATE TABLE IF NOT EXISTS ai_content_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL, -- 'post', 'event', 'ngo', 'user'
    content_type VARCHAR(50) NOT NULL, -- 'title', 'description', 'content', 'bio'
    embedding_vector FLOAT[], -- Vector representation of content
    embedding_model VARCHAR(100) NOT NULL,
    content_hash VARCHAR(64), -- Hash of original content for change detection
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, entity_type, content_type)
);

-- Recommendation Feedback
CREATE TABLE IF NOT EXISTS ai_recommendation_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    recommendation_id UUID REFERENCES ai_user_recommendations(id) ON DELETE CASCADE,
    feedback_type VARCHAR(20) NOT NULL, -- 'positive', 'negative', 'neutral'
    feedback_reason VARCHAR(100), -- 'relevant', 'irrelevant', 'already_know', 'not_interested'
    detailed_feedback TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- SMART SEARCH AI TABLES
-- ============================================================================

-- Search Query Analysis
CREATE TABLE IF NOT EXISTS ai_search_queries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    original_query TEXT NOT NULL,
    processed_query TEXT, -- AI-processed/expanded query
    query_intent VARCHAR(100), -- What the user is looking for
    query_category VARCHAR(50), -- 'events', 'ngos', 'volunteers', 'posts'
    search_context JSONB, -- User's search context (location, preferences)
    ai_model_used VARCHAR(100) NOT NULL,
    results_count INTEGER DEFAULT 0,
    user_satisfaction INTEGER CHECK (user_satisfaction >= 1 AND user_satisfaction <= 5),
    clicked_results JSONB, -- Which results the user clicked
    session_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Search Result Rankings
CREATE TABLE IF NOT EXISTS ai_search_rankings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    search_query_id UUID REFERENCES ai_search_queries(id) ON DELETE CASCADE,
    entity_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    ranking_position INTEGER NOT NULL,
    relevance_score DECIMAL(5, 2) NOT NULL,
    ranking_reasons JSONB,
    user_interaction VARCHAR(20), -- 'clicked', 'viewed', 'ignored'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- AI GENERATED CONTENT TABLES
-- ============================================================================

-- AI Generated Content
CREATE TABLE IF NOT EXISTS ai_generated_content (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content_type VARCHAR(50) NOT NULL, -- 'impact_story', 'event_description', 'ngo_bio', 'volunteer_summary'
    source_entity_id UUID, -- ID of the entity this content is about
    source_entity_type VARCHAR(50), -- 'event', 'ngo', 'user', 'project'
    generated_content TEXT NOT NULL,
    ai_model_used VARCHAR(100) NOT NULL,
    generation_prompt TEXT,
    generation_parameters JSONB,
    content_quality_score DECIMAL(5, 2), -- AI-generated quality score
    user_rating INTEGER CHECK (user_rating >= 1 AND user_rating <= 5),
    is_approved BOOLEAN DEFAULT FALSE,
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    approved_at TIMESTAMP WITH TIME ZONE,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI Content Templates
CREATE TABLE IF NOT EXISTS ai_content_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_name VARCHAR(100) NOT NULL,
    template_type VARCHAR(50) NOT NULL, -- 'impact_story', 'event_description', 'volunteer_profile'
    template_prompt TEXT NOT NULL,
    template_parameters JSONB, -- Required parameters for the template
    example_output TEXT,
    usage_count INTEGER DEFAULT 0,
    success_rate DECIMAL(5, 2) DEFAULT 0, -- Percentage of successful generations
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- AI ANALYTICS AND MONITORING TABLES
-- ============================================================================

-- AI Model Performance Metrics
CREATE TABLE IF NOT EXISTS ai_model_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_name VARCHAR(100) NOT NULL,
    metric_type VARCHAR(50) NOT NULL, -- 'accuracy', 'precision', 'recall', 'f1', 'response_time'
    metric_value DECIMAL(10, 4) NOT NULL,
    measurement_period VARCHAR(50) NOT NULL, -- 'hourly', 'daily', 'weekly', 'monthly'
    measurement_date TIMESTAMP WITH TIME ZONE NOT NULL,
    context_data JSONB, -- Additional context for the metric
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI System Health Monitoring
CREATE TABLE IF NOT EXISTS ai_system_health (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    component_name VARCHAR(100) NOT NULL, -- 'gemini_api', 'embedding_service', 'recommendation_engine'
    health_status VARCHAR(20) NOT NULL, -- 'healthy', 'degraded', 'down', 'maintenance'
    response_time_ms INTEGER,
    error_rate DECIMAL(5, 2), -- Error rate percentage
    last_check TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    error_details TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- SAFE COLUMN ADDITIONS FOR EXISTING TABLES
-- ============================================================================

-- Ensure all required columns exist in existing tables
DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ai_model_configs') THEN
        ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS model_type VARCHAR(50) NOT NULL;
        ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS provider VARCHAR(50) NOT NULL;
        ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS api_key_name VARCHAR(100);
        ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
        ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS rate_limit_per_minute INTEGER DEFAULT 60;
        ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS cost_per_request DECIMAL(10, 6) DEFAULT 0.001;
        ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS description TEXT;
        ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- ============================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================================================

-- AI Model Configs indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_model_configs_name') THEN
        CREATE INDEX idx_ai_model_configs_name ON ai_model_configs(model_name);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_model_configs_active') THEN
        CREATE INDEX idx_ai_model_configs_active ON ai_model_configs(is_active);
    END IF;
END $$;

-- AI Request Logs indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_request_logs_user') THEN
        CREATE INDEX idx_ai_request_logs_user ON ai_request_logs(user_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_request_logs_endpoint') THEN
        CREATE INDEX idx_ai_request_logs_endpoint ON ai_request_logs(endpoint);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_request_logs_created') THEN
        CREATE INDEX idx_ai_request_logs_created ON ai_request_logs(created_at DESC);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_request_logs_status') THEN
        CREATE INDEX idx_ai_request_logs_status ON ai_request_logs(status);
    END IF;
END $$;

-- AI Learning Data indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_learning_user') THEN
        CREATE INDEX idx_ai_learning_user ON ai_learning_data(user_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_learning_type') THEN
        CREATE INDEX idx_ai_learning_type ON ai_learning_data(data_type);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_learning_entity') types THEN
        CREATE INDEX idx_ai_learning_entity ON ai_learning_data(entity_id, entity_type);
    END IF;
END $$;

-- Volunteer Matching indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_volunteer_matches_event') THEN
        CREATE INDEX idx_ai_volunteer_matches_event ON ai_volunteer_matches(event_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_volunteer_matches_volunteer') THEN
        CREATE INDEX idx_ai_volunteer_matches_volunteer ON ai_volunteer_matches(volunteer_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_volunteer_matches_score') THEN
        CREATE INDEX idx_ai_volunteer_matches_score ON ai_volunteer_matches(match_score DESC);
    END IF;
END $$;

-- Volunteer Profiles indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_volunteer_profiles_user') THEN
        CREATE INDEX idx_ai_volunteer_profiles_user ON ai_volunteer_profiles(user_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_volunteer_profiles_experience') THEN
        CREATE INDEX idx_ai_volunteer_profiles_experience ON ai_volunteer_profiles(experience_level);
    END IF;
END $$;

-- Impact Predictions indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_impact_predictions_event') THEN
        CREATE INDEX idx_ai_impact_predictions_event ON ai_impact_predictions(event_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_impact_predictions_ngo') THEN
        CREATE INDEX idx_ai_impact_predictions_ngo ON ai_impact_predictions(ngo_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_impact_predictions_type') THEN
        CREATE INDEX idx_ai_impact_predictions_type ON ai_impact_predictions(prediction_type);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_impact_predictions_score') THEN
        CREATE INDEX idx_ai_impact_predictions_score ON ai_impact_predictions(success_probability DESC);
    END IF;
END $$;

-- User Recommendations indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_user_recommendations_user') THEN
        CREATE INDEX idx_ai_user_recommendations_user ON ai_user_recommendations(user_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_user_recommendations_type') THEN
        CREATE INDEX idx_ai_user_recommendations_type ON ai_user_recommendations(recommendation_type);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_user_recommendations_score') THEN
        CREATE INDEX idx_ai_user_recommendations_score ON ai_user_recommendations(recommendation_score DESC);
    END IF;
END $$;

-- Content Embeddings indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_content_embeddings_entity') THEN
        CREATE INDEX idx_ai_content_embeddings_entity ON ai_content_embeddings(entity_id, entity_type);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_content_embeddings_type') THEN
        CREATE INDEX idx_ai_content_embeddings_type ON ai_content_embeddings(content_type);
    END IF;
END $$;

-- Search Queries indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_search_queries_user') THEN
        CREATE INDEX idx_ai_search_queries_user ON ai_search_queries(user_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_search_queries_intent') THEN
        CREATE INDEX idx_ai_search_queries_intent ON ai_search_queries(query_intent);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_search_queries_created') THEN
        CREATE INDEX idx_ai_search_queries_created ON ai_search_queries(created_at DESC);
    END IF;
END $$;

-- Generated Content indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_generated_content_type') THEN
        CREATE INDEX idx_ai_generated_content_type ON ai_generated_content(content_type);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_generated_content_entity') THEN
        CREATE INDEX idx_ai_generated_content_entity ON ai_generated_content(source_entity_id, source_entity_type);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_generated_content_approved') THEN
        CREATE INDEX idx_ai_generated_content_approved ON ai_generated_content(is_approved);
    END IF;
END $$;

-- Model Metrics indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_model_metrics_model') THEN
        CREATE INDEX idx_ai_model_metrics_model ON ai_model_metrics(model_name);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_model_metrics_type') THEN
        CREATE INDEX idx_ai_model_metrics_type ON ai_model_metrics(metric_type);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_model_metrics_date') THEN
        CREATE INDEX idx_ai_model_metrics_date ON ai_model_metrics(measurement_date DESC);
    END IF;
END $$;

-- System Health indexes
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_system_health_component') THEN
        CREATE INDEX idx_ai_system_health_component ON ai_system_health(component_name);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_system_health_status') THEN
        CREATE INDEX idx_ai_system_health_status ON ai_system_health(health_status);
    END IF;
END $$;

-- ============================================================================
-- HELPER FUNCTIONS FOR AI FEATURES
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_ai_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate AI model performance
CREATE OR REPLACE FUNCTION calculate_ai_model_performance(model_name_param VARCHAR(100), days_back INTEGER DEFAULT 30)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'total_requests', COUNT(*),
        'success_rate', ROUND((COUNT(*) FILTER (WHERE status = 'success') * 100.0 / COUNT(*))::DECIMAL, 2),
        'avg_response_time', ROUND(AVG(response_time_ms)::DECIMAL, 2),
        'total_cost', ROUND(SUM(cost)::DECIMAL, 4),
        'avg_tokens_per_request', ROUND(AVG(total_tokens)::DECIMAL, 2)
    ) INTO result
    FROM ai_request_logs
    WHERE model_name = model_name_param
        AND created_at >= NOW() - INTERVAL '1 day' * days_back;
    
    RETURN COALESCE(result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql;

-- Function to get user recommendation score
CREATE OR REPLACE FUNCTION get_user_recommendation_score(user_uuid UUID, entity_uuid UUID, entity_type_param VARCHAR(50))
RETURNS DECIMAL(5, 2) AS $$
DECLARE
    score DECIMAL(5, 2);
BEGIN
    SELECT recommendation_score INTO score
    FROM ai_user_recommendations
    WHERE user_id = user_uuid
        AND entity_id = entity_uuid
        AND entity_type = entity_type_param
    ORDER BY created_at DESC
    LIMIT 1;
    
    RETURN COALESCE(score, 0);
END;
$$ LANGUAGE plpgsql;

-- Function to log AI interaction
CREATE OR REPLACE FUNCTION log_ai_interaction(
    user_uuid UUID,
    interaction_type_param VARCHAR(50),
    entity_uuid UUID,
    entity_type_param VARCHAR(50),
    interaction_value_param DECIMAL(5, 2) DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    interaction_id UUID;
BEGIN
    INSERT INTO ai_learning_data (
        user_id, data_type, entity_id, entity_type, interaction_type, interaction_value
    ) VALUES (
        user_uuid, 'user_interaction', entity_uuid, entity_type_param, 
        interaction_type_param, interaction_value_param
    )
    RETURNING id INTO interaction_id;
    
    RETURN interaction_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================================================

-- Triggers for updated_at columns
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_ai_model_configs_updated_at') THEN
        CREATE TRIGGER update_ai_model_configs_updated_at BEFORE UPDATE ON ai_model_configs
            FOR EACH ROW EXECUTE FUNCTION update_ai_updated_at_column();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_ai_volunteer_matches_updated_at') THEN
        CREATE TRIGGER update_ai_volunteer_matches_updated_at BEFORE UPDATE ON ai_volunteer_matches
            FOR EACH ROW EXECUTE FUNCTION update_ai_updated_at_column();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_ai_volunteer_profiles_updated_at') THEN
        CREATE TRIGGER update_ai_volunteer_profiles_updated_at BEFORE UPDATE ON ai_volunteer_profiles
            FOR EACH ROW EXECUTE FUNCTION update_ai_updated_at_column();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_ai_impact_predictions_updated_at') THEN
        CREATE TRIGGER update_ai_impact_predictions_updated_at BEFORE UPDATE ON ai_impact_predictions
            FOR EACH ROW EXECUTE FUNCTION update_ai_updated_at_column();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_ai_user_recommendations_updated_at') THEN
        CREATE TRIGGER update_ai_user_recommendations_updated_at BEFORE UPDATE ON ai_user_recommendations
            FOR EACH ROW EXECUTE FUNCTION update_ai_updated_at_column();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_ai_content_embeddings_updated_at') THEN
        CREATE TRIGGER update_ai_content_embeddings_updated_at BEFORE UPDATE ON ai_content_embeddings
            FOR EACH ROW EXECUTE FUNCTION update_ai_updated_at_column();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_ai_generated_content_updated_at') THEN
        CREATE TRIGGER update_ai_generated_content_updated_at BEFORE UPDATE ON ai_generated_content
            FOR EACH ROW EXECUTE FUNCTION update_ai_updated_at_column();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_ai_content_templates_updated_at') THEN
        CREATE TRIGGER update_ai_content_templates_updated_at BEFORE UPDATE ON ai_content_templates
            FOR EACH ROW EXECUTE FUNCTION update_ai_updated_at_column();
    END IF;
END $$;

-- ============================================================================
-- INITIAL DATA SETUP
-- ============================================================================

-- Insert default AI model configurations
INSERT INTO ai_model_configs (model_name, model_type, provider, api_key_name, description) 
VALUES 
    ('gemini-pro', 'text', 'google', 'GEMINI_API_KEY', 'Google Gemini Pro for text generation and analysis'),
    ('gemini-pro-vision', 'image', 'google', 'GEMINI_API_KEY', 'Google Gemini Pro Vision for image analysis'),
    ('openai-gpt-4', 'text', 'openai', 'OPENAI_API_KEY', 'OpenAI GPT-4 for advanced text generation'),
    ('openai-embedding', 'embedding', 'openai', 'OPENAI_API_KEY', 'OpenAI embeddings for semantic search')
ON CONFLICT (model_name) DO NOTHING;

-- Insert default AI content templates
INSERT INTO ai_content_templates (template_name, template_type, template_prompt, template_parameters) 
VALUES 
    (
        'impact_story_generator', 
        'impact_story',
        'Generate an inspiring impact story based on the following event data: {event_data}. Focus on the positive change created and include specific metrics where possible.',
        '{"event_data": "JSON object containing event details, volunteer count, and outcomes"}'
    ),
    (
        'volunteer_profile_summary',
        'volunteer_profile',
        'Create a compelling volunteer profile summary highlighting their skills, interests, and impact: {volunteer_data}',
        '{"volunteer_data": "JSON object containing volunteer information, skills, and achievements"}'
    ),
    (
        'event_description_generator',
        'event_description',
        'Write an engaging event description that will attract volunteers: {event_data}',
        '{"event_data": "JSON object containing event details, requirements, and benefits"}'
    )
ON CONFLICT DO NOTHING;

-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'AI Features System Schema Complete!';
    RAISE NOTICE 'Created tables: ai_model_configs, ai_request_logs, ai_learning_data';
    RAISE NOTICE 'Created tables: ai_volunteer_matches, ai_volunteer_profiles, ai_impact_predictions';
    RAISE NOTICE 'Created tables: ai_user_recommendations, ai_content_embeddings, ai_search_queries';
    RAISE NOTICE 'Created tables: ai_generated_content, ai_content_templates, ai_model_metrics';
    RAISE NOTICE 'Added comprehensive indexes for optimal performance';
    RAISE NOTICE 'Set up automatic triggers and helper functions';
    RAISE NOTICE 'AI features system is now fully functional!';
END $$;
