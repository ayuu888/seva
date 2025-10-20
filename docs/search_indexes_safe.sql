-- ============================================================================
-- GLOBAL SEARCH PERFORMANCE OPTIMIZATION
-- ============================================================================
-- This schema creates optimized indexes for fast global search across the platform
-- Safe execution with IF NOT EXISTS checks to prevent errors

-- Enable required extensions for advanced search
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For trigram similarity search
CREATE EXTENSION IF NOT EXISTS "unaccent"; -- For exotic character handling

-- ============================================================================
-- USERS TABLE SEARCH INDEXES
-- ============================================================================

-- Basic search indexes for user fields
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_name_search') THEN
        CREATE INDEX idx_users_name_search ON users USING gin (to_tsvector('english', name));
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_bio_search') THEN
        CREATE INDEX idx_users_bio_search ON users USING gin (to_tsvector('english', bio));
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_location_search') THEN
        CREATE INDEX idx_users_location_search ON users USING gin (to_tsvector('english', location));
    END IF;
END $$;

-- Trigram indexes for partial matching
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_name_trgm') THEN
        CREATE INDEX idx_users_name_trgm ON users USING gin (name gin_trgm_ops);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_bio_trgm') THEN
        CREATE INDEX idx_users_bio_trgm ON users USING gin (bio gin_trgm_ops);
    END IF;
END $$;

-- Composite indexes for filtered searches
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_location_type') THEN
        CREATE INDEX idx_users_location_type ON users (location, user_type);
    END IF;
END $$;

-- ============================================================================
-- NGOS TABLE SEARCH INDEXES
-- ============================================================================

-- Full-text search indexes for NGO fields
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ngos_name_search') THEN
        CREATE INDEX idx_ngos_name_search ON ngos USING gin (to_tsvector('english', name));
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ngos_description_search') THEN
        CREATE INDEX idx_ngos_description_search ON ngos USING gin (to_tsvector('english', description));
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ngos_category_search') THEN
        CREATE INDEX idx_ngos_category_search ON ngos USING gin (to_tsvector('english', category));
    END IF;
END $$;

-- Trigram indexes for partial matching
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ngos_name_trgm') THEN
        CREATE INDEX idx_ngos_name_trgm ON ngos USING gin (name gin_trgm_ops);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ngos_description_trgm') THEN
        CREATE INDEX idx_ngos_description_trgm ON ngos USING gin (description gin_trgm_ops);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ngos_category_trgm') THEN
        CREATE INDEX idx_ngos_category_trgm ON ngos USING gin (category gin_trgm_ops);
    END IF;
END $$;

-- Composite indexes for filtered searches
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ngos_location_category') THEN
        CREATE INDEX idx_ngos_location_category ON ngos (location, category);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ngos_followers_created') THEN
        CREATE INDEX idx_ngos_followers_created ON ngos (followers_count DESC, created_at DESC);
    END IF;
END $$;

-- ============================================================================
-- EVENTS TABLE SEARCH INDEXES
-- ============================================================================

-- Full-text search indexes for event fields
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_events_title_search') THEN
        CREATE INDEX idx_events_title_search ON events USING gin (to_tsvector('english', title));
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_events_description_search') THEN
        CREATE INDEX idx_events_description_search ON events USING gin (to_tsvector('english', description));
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_events_category_search') THEN
        CREATE INDEX idx_events_category_search ON events USING gin (to_tsvector('english', category));
    END IF;
END $$;

-- Trigram indexes for partial matching
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_events_title_trgm') THEN
        CREATE INDEX idx_events_title_trgm ON events USING gin (title gin_trgm_ops);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_events_description_trgm') THEN
        CREATE INDEX idx_events_description_trgm ON events USING gin (description gin_trgm_ops);
    END IF;
END $$;

-- Date-based indexes for time filtering
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_events_date_location') THEN
        CREATE INDEX idx_events_date_location ON events (date, location);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_events_date_category') THEN
        CREATE INDEX idx_events_date_category ON events (date, category);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_events_upcoming') THEN
        CREATE INDEX idx_events_upcoming ON events (date);
    END IF;
END $$;

-- ============================================================================
-- POSTS TABLE SEARCH INDEXES
-- ============================================================================

-- Full-text search indexes for post content
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_posts_content_search') THEN
        CREATE INDEX idx_posts_content_search ON posts USING gin (to_tsvector('english', content));
    END IF;
END $$;

-- Trigram index for partial content matching
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_posts_content_trgm') THEN
        CREATE INDEX idx_posts_content_trgm ON posts USING gin (content gin_trgm_ops);
    END IF;
END $$;

-- Date-based indexes for time filtering
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_posts_created_user') THEN
        CREATE INDEX idx_posts_created_user ON posts (created_at DESC, user_id);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_posts_recent_content') THEN
        CREATE INDEX idx_posts_recent_content ON posts USING gin (to_tsvector('english', content));
    END IF;
END $$;

-- ============================================================================
-- MESSAGES TABLE SEARCH INDEXES
-- ============================================================================

-- Full-text search indexes for message content
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_messages_content_search') THEN
        CREATE INDEX idx_messages_content_search ON messages USING gin (to_tsvector('english', content));
    END IF;
END $$;

-- Trigram index for partial content matching
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_messages_content_trgm') THEN
        CREATE INDEX idx_messages_content_trgm ON messages USING gin (content gin_trgm_ops);
    END IF;
END $$;

-- Composite indexes for conversation-based searches
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_messages_conversation_created') THEN
        CREATE INDEX idx_messages_conversation_created ON messages (conversation_id, created_at DESC);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_messages_conversation_content') THEN
        CREATE INDEX idx_messages_conversation_content ON messages USING gin (to_tsvector('english', content)) WHERE deleted = false;
    END IF;
END $$;

-- ============================================================================
-- CONVERSATION PARTICIPANTS INDEXES
-- ============================================================================

-- Index for user conversation lookups
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_conversation_participants_user') THEN
        CREATE INDEX idx_conversation_participants_user ON conversation_participants (user_id, conversation_id);
    END IF;
END $$;

-- ============================================================================
-- SEARCH ANALYTICS TABLE
-- ============================================================================

-- Create search analytics table if it doesn't exist
CREATE TABLE IF NOT EXISTS search_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    query TEXT NOT NULL,
    search_type VARCHAR(50) DEFAULT 'all',
    filters JSONB DEFAULT '{}',
    result_count INTEGER DEFAULT 0,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    response_time_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ensure all required columns exist in search_analytics table
DO $$ BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'search_analytics') THEN
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS search_type VARCHAR(50) DEFAULT 'all';
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS filters JSONB DEFAULT '{}';
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS result_count INTEGER DEFAULT 0;
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE SET NULL;
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS session_id VARCHAR(255);
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS ip_address INET;
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS user_agent TEXT;
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS response_time_ms INTEGER;
        ALTER TABLE search_analytics ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Indexes for search analytics (created after table creation)
DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_search_analytics_query') THEN
        CREATE INDEX idx_search_analytics_query ON search_analytics USING gin (to_tsvector('english', query));
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_search_analytics_type_date') THEN
        CREATE INDEX idx_search_analytics_type_date ON search_analytics (search_type, created_at DESC);
    END IF;
END $$;

DO $$ BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_search_analytics_user') THEN
        CREATE INDEX idx_search_analytics_user ON search_analytics (user_id, created_at DESC);
    END IF;
END $$;

-- ============================================================================
-- SEARCH PERFORMANCE FUNCTIONS
-- ============================================================================

-- Function to clean up old search analytics (optional)
CREATE OR REPLACE FUNCTION cleanup_old_search_analytics(days_to_keep INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM search_analytics 
    WHERE created_at < NOW() - INTERVAL '1 day' * days_to_keep;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get search suggestions based on popular queries
CREATE OR REPLACE FUNCTION get_search_suggestions(partial_query TEXT, limit_count INTEGER DEFAULT 10)
RETURNS TABLE(suggestion TEXT, frequency INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sa.query as suggestion,
        COUNT(*) as frequency
    FROM search_analytics sa
    WHERE sa.query ILIKE partial_query || '%'
        AND sa.created_at >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY sa.query
    ORDER BY frequency DESC, sa.query
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to track search analytics
CREATE OR REPLACE FUNCTION track_search_analytics(
    search_query TEXT,
    search_type_param VARCHAR(50),
    filters_param JSONB,
    result_count_param INTEGER,
    user_id_param UUID,
    session_id_param VARCHAR(255),
    ip_address_param INET,
    user_agent_param TEXT,
    response_time_param INTEGER
)
RETURNS UUID AS $$
DECLARE
    analytics_id UUID;
BEGIN
    INSERT INTO search_analytics (
        query, search_type, filters, result_count, user_id, 
        session_id, ip_address, user_agent, response_time_ms
    ) VALUES (
        search_query, search_type_param, filters_param, result_count_param, user_id_param,
        session_id_param, ip_address_param, user_agent_param, response_time_param
    )
    RETURNING id INTO analytics_id;
    
    RETURN analytics_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SEARCH OPTIMIZATION SETTINGS
-- ============================================================================

-- Update PostgreSQL configuration for better search performance
-- These settings can be adjusted based on your server capacity

-- Increase shared_preload_libraries for better full-text search
-- ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements,pg_trgm';

-- Optimize work memory for complex searches
-- ALTER SYSTEM SET work_mem = '256MB';

-- Increase maintenance work memory for index creation
-- ALTER SYSTEM SET maintenance_work_mem = '512MB';

-- ============================================================================
-- SEARCH PERFORMANCE MONITORING
-- ============================================================================

-- View to monitor search performance
CREATE OR REPLACE VIEW search_performance_stats AS
SELECT 
    search_type,
    COUNT(*) as total_searches,
    AVG(result_count) as avg_results,
    AVG(response_time_ms) as avg_response_time,
    MIN(response_time_ms) as min_response_time,
    MAX(response_time_ms) as max_response_time,
    COUNT(DISTINCT user_id) as unique_users,
    DATE_TRUNC('day', created_at) as search_date
FROM search_analytics 
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY search_type, DATE_TRUNC('day', created_at)
ORDER BY search_date DESC, total_searches DESC;

-- View to monitor popular search queries
CREATE OR REPLACE VIEW popular_search_queries AS
SELECT 
    query,
    COUNT(*) as frequency,
    AVG(result_count) as avg_results,
    COUNT(DISTINCT user_id) as unique_users,
    MAX(created_at) as last_searched
FROM search_analytics 
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
    AND LENGTH(query) > 2  -- Ignore very short queries
GROUP BY query
HAVING COUNT(*) > 1  -- Only show queries searched multiple times
ORDER BY frequency DESC, avg_results DESC
LIMIT 100;

-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'Global Search Performance Optimization Complete!';
    RAISE NOTICE 'Created indexes for: Users, NGOs, Events, Posts, Messages';
    RAISE NOTICE 'Added full-text search capabilities with trigram matching';
    RAISE NOTICE 'Set up search analytics and performance monitoring';
    RAISE NOTICE 'All search operations should now be significantly faster!';
END $$;
