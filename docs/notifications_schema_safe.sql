-- ================================================
-- NOTIFICATIONS SYSTEM SCHEMA (SAFE VERSION)
-- For Seva-Setu Platform - Handles existing objects
-- ================================================

-- ================================================
-- NOTIFICATIONS TABLES
-- ================================================

-- Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(100) NOT NULL, -- 'like', 'comment', 'follow', 'event', 'donation', 'system', 'badge', 'challenge'
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    link TEXT, -- URL to related content
    data JSONB DEFAULT '{}', -- Additional notification data
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'notifications') THEN
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS type VARCHAR(100) DEFAULT 'system';
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS title VARCHAR(255);
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS message TEXT;
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS link TEXT;
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS data JSONB DEFAULT '{}';
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS read BOOLEAN DEFAULT FALSE;
        ALTER TABLE notifications ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create indexes safely
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notifications_user') THEN
        CREATE INDEX idx_notifications_user ON notifications(user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notifications_type') THEN
        CREATE INDEX idx_notifications_type ON notifications(type);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notifications_read') THEN
        CREATE INDEX idx_notifications_read ON notifications(read);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notifications_created') THEN
        CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notifications_user_read') THEN
        CREATE INDEX idx_notifications_user_read ON notifications(user_id, read);
    END IF;
END $$;

-- Notification Settings Table (User preferences)
CREATE TABLE IF NOT EXISTS notification_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    in_app_notifications BOOLEAN DEFAULT TRUE,
    -- Notification type preferences
    like_notifications BOOLEAN DEFAULT TRUE,
    comment_notifications BOOLEAN DEFAULT TRUE,
    follow_notifications BOOLEAN DEFAULT TRUE,
    event_notifications BOOLEAN DEFAULT TRUE,
    donation_notifications BOOLEAN DEFAULT TRUE,
    system_notifications BOOLEAN DEFAULT TRUE,
    badge_notifications BOOLEAN DEFAULT TRUE,
    challenge_notifications BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'notification_settings') THEN
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS email_notifications BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS push_notifications BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS in_app_notifications BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS like_notifications BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS comment_notifications BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS follow_notifications BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS event_notifications BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS donation_notifications BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS system_notifications BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS badge_notifications BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS challenge_notifications BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create indexes safely
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notification_settings_user') THEN
        CREATE INDEX idx_notification_settings_user ON notification_settings(user_id);
    END IF;
END $$;

-- Notification Templates Table (For consistent messaging)
CREATE TABLE IF NOT EXISTS notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(100) NOT NULL UNIQUE,
    title_template TEXT NOT NULL,
    message_template TEXT NOT NULL,
    icon VARCHAR(100),
    color VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add missing columns if table already exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'notification_templates') THEN
        ALTER TABLE notification_templates ADD COLUMN IF NOT EXISTS title_template TEXT;
        ALTER TABLE notification_templates ADD COLUMN IF NOT EXISTS message_template TEXT;
        ALTER TABLE notification_templates ADD COLUMN IF NOT EXISTS icon VARCHAR(100);
        ALTER TABLE notification_templates ADD COLUMN IF NOT EXISTS color VARCHAR(50);
        ALTER TABLE notification_templates ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
        ALTER TABLE notification_templates ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create indexes safely
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notification_templates_type') THEN
        CREATE INDEX idx_notification_templates_type ON notification_templates(type);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notification_templates_active') THEN
        CREATE INDEX idx_notification_templates_active ON notification_templates(is_active);
    END IF;
END $$;

-- ================================================
-- FUNCTIONS FOR NOTIFICATIONS SYSTEM
-- ================================================

-- Drop existing functions if they exist to avoid conflicts
DROP FUNCTION IF EXISTS create_notification(UUID, VARCHAR, VARCHAR, TEXT, TEXT, JSONB);
DROP FUNCTION IF EXISTS get_unread_notification_count(UUID);
DROP FUNCTION IF EXISTS mark_notifications_as_read(UUID, UUID[]);
DROP FUNCTION IF EXISTS cleanup_old_notifications(INTEGER);

-- Function to create a notification
CREATE OR REPLACE FUNCTION create_notification(
    p_user_id UUID,
    p_type VARCHAR(100),
    p_title VARCHAR(255),
    p_message TEXT,
    p_link TEXT DEFAULT NULL,
    p_data JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID AS $$
DECLARE
    notification_id UUID;
BEGIN
    -- Check if user has notifications enabled for this type
    IF EXISTS (
        SELECT 1 FROM notification_settings ns 
        WHERE ns.user_id = p_user_id 
        AND (
            (p_type = 'like' AND ns.like_notifications = FALSE) OR
            (p_type = 'comment' AND ns.comment_notifications = FALSE) OR
            (p_type = 'follow' AND ns.follow_notifications = FALSE) OR
            (p_type = 'event' AND ns.event_notifications = FALSE) OR
            (p_type = 'donation' AND ns.donation_notifications = FALSE) OR
            (p_type = 'system' AND ns.system_notifications = FALSE) OR
            (p_type = 'badge' AND ns.badge_notifications = FALSE) OR
            (p_type = 'challenge' AND ns.challenge_notifications = FALSE) OR
            ns.in_app_notifications = FALSE
        )
    ) THEN
        -- User has disabled this notification type, don't create it
        RETURN NULL;
    END IF;

    -- Create the notification
    INSERT INTO notifications (user_id, type, title, message, link, data)
    VALUES (p_user_id, p_type, p_title, p_message, p_link, p_data)
    RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get unread notification count for user
CREATE OR REPLACE FUNCTION get_unread_notification_count(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    unread_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO unread_count
    FROM notifications
    WHERE user_id = p_user_id
    AND read = FALSE;
    
    RETURN COALESCE(unread_count, 0);
END;
$$ LANGUAGE plpgsql;

-- Function to mark notifications as read
CREATE OR REPLACE FUNCTION mark_notifications_as_read(
    p_user_id UUID,
    p_notification_ids UUID[] DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    IF p_notification_ids IS NULL OR array_length(p_notification_ids, 1) IS NULL THEN
        -- Mark all notifications as read for the user
        UPDATE notifications 
        SET read = TRUE, updated_at = NOW()
        WHERE user_id = p_user_id AND read = FALSE;
    ELSE
        -- Mark specific notifications as read
        UPDATE notifications 
        SET read = TRUE, updated_at = NOW()
        WHERE user_id = p_user_id 
        AND id = ANY(p_notification_ids)
        AND read = FALSE;
    END IF;
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- Function to cleanup old notifications
CREATE OR REPLACE FUNCTION cleanup_old_notifications(p_days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM notifications
    WHERE created_at < NOW() - INTERVAL '1 day' * p_days_to_keep;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to create notification from template
CREATE OR REPLACE FUNCTION create_notification_from_template(
    p_user_id UUID,
    p_type VARCHAR(100),
    p_template_data JSONB DEFAULT '{}'::jsonb,
    p_link TEXT DEFAULT NULL,
    p_additional_data JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID AS $$
DECLARE
    notification_id UUID;
    template_record RECORD;
    final_title TEXT;
    final_message TEXT;
BEGIN
    -- Get template
    SELECT * INTO template_record
    FROM notification_templates
    WHERE type = p_type AND is_active = TRUE;
    
    IF NOT FOUND THEN
        -- No template found, create basic notification
        RETURN create_notification(p_user_id, p_type, 
            COALESCE(p_template_data->>'title', 'Notification'),
            COALESCE(p_template_data->>'message', 'You have a new notification'),
            p_link, p_additional_data);
    END IF;
    
    -- Replace template variables with actual data
    final_title := template_record.title_template;
    final_message := template_record.message_template;
    
    -- Simple variable replacement (can be enhanced)
    final_title := REPLACE(final_title, '{user_name}', COALESCE(p_template_data->>'user_name', 'User'));
    final_title := REPLACE(final_title, '{event_name}', COALESCE(p_template_data->>'event_name', 'Event'));
    final_title := REPLACE(final_title, '{ngo_name}', COALESCE(p_template_data->>'ngo_name', 'NGO'));
    final_title := REPLACE(final_title, '{amount}', COALESCE(p_template_data->>'amount', '0'));
    
    final_message := REPLACE(final_message, '{user_name}', COALESCE(p_template_data->>'user_name', 'User'));
    final_message := REPLACE(final_message, '{event_name}', COALESCE(p_template_data->>'event_name', 'Event'));
    final_message := REPLACE(final_message, '{ngo_name}', COALESCE(p_template_data->>'ngo_name', 'NGO'));
    final_message := REPLACE(final_message, '{amount}', COALESCE(p_template_data->>'amount', '0'));
    
    -- Merge template data with additional data
    p_additional_data := p_additional_data || jsonb_build_object(
        'template_id', template_record.id,
        'icon', template_record.icon,
        'color', template_record.color
    );
    
    -- Create notification
    RETURN create_notification(p_user_id, p_type, final_title, final_message, p_link, p_additional_data);
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- INITIAL DATA & TEMPLATES
-- ================================================

-- Insert default notification templates
INSERT INTO notification_templates (type, title_template, message_template, icon, color)
VALUES 
    ('like', 'New Like!', '{user_name} liked your post', 'heart', 'red'),
    ('comment', 'New Comment', '{user_name} commented on your post', 'message-circle', 'blue'),
    ('follow', 'New Follower', '{user_name} started following you', 'user-plus', 'green'),
    ('event', 'Event Update', 'New event: {event_name}', 'calendar', 'purple'),
    ('donation', 'Donation Received', 'Thank you for your donation of ${amount}', 'dollar-sign', 'green'),
    ('system', 'System Notification', '{message}', 'bell', 'gray'),
    ('badge', 'Badge Earned', 'Congratulations! You earned a new badge', 'award', 'yellow'),
    ('challenge', 'Challenge Update', 'New challenge available: {challenge_name}', 'target', 'orange'),
    ('message', 'New Message', 'You have a new message from {user_name}', 'mail', 'blue'),
    ('event_reminder', 'Event Reminder', 'Don\'t forget: {event_name} is coming up', 'clock', 'orange')
ON CONFLICT (type) DO UPDATE SET
    title_template = EXCLUDED.title_template,
    message_template = EXCLUDED.message_template,
    icon = EXCLUDED.icon,
    color = EXCLUDED.color,
    updated_at = NOW();

-- Create default notification settings for existing users
INSERT INTO notification_settings (user_id, email_notifications, push_notifications, in_app_notifications)
SELECT 
    u.id,
    TRUE,
    TRUE,
    TRUE
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM notification_settings ns WHERE ns.user_id = u.id
);

-- ================================================
-- TRIGGERS FOR AUTOMATIC NOTIFICATIONS
-- ================================================

-- Function to trigger notification on post like
CREATE OR REPLACE FUNCTION trigger_post_like_notification()
RETURNS TRIGGER AS $$
DECLARE
    post_author_id UUID;
    liker_name TEXT;
BEGIN
    -- Get post author and liker name
    SELECT p.user_id, u.name INTO post_author_id, liker_name
    FROM posts p
    JOIN users u ON u.id = NEW.user_id
    WHERE p.id = NEW.post_id;
    
    -- Don't notify if user likes their own post
    IF post_author_id != NEW.user_id THEN
        PERFORM create_notification_from_template(
            post_author_id,
            'like',
            jsonb_build_object('user_name', liker_name),
            '/feed'
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to trigger notification on comment
CREATE OR REPLACE FUNCTION trigger_comment_notification()
RETURNS TRIGGER AS $$
DECLARE
    post_author_id UUID;
    commenter_name TEXT;
BEGIN
    -- Get post author and commenter name
    SELECT p.user_id, u.name INTO post_author_id, commenter_name
    FROM posts p
    JOIN users u ON u.id = NEW.user_id
    WHERE p.id = NEW.post_id;
    
    -- Don't notify if user comments on their own post
    IF post_author_id != NEW.user_id THEN
        PERFORM create_notification_from_template(
            post_author_id,
            'comment',
            jsonb_build_object('user_name', commenter_name),
            '/feed'
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to trigger notification on follow
CREATE OR REPLACE FUNCTION trigger_follow_notification()
RETURNS TRIGGER AS $$
DECLARE
    follower_name TEXT;
BEGIN
    -- Get follower name
    SELECT name INTO follower_name
    FROM users
    WHERE id = NEW.follower_id;
    
    -- Notify the user being followed
    PERFORM create_notification_from_template(
        NEW.followed_id,
        'follow',
        jsonb_build_object('user_name', follower_name),
        '/profile/' || NEW.follower_id
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers (only if the referenced tables exist)
DO $$ 
BEGIN
    -- Trigger for post likes (if posts table exists)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'posts') THEN
        DROP TRIGGER IF EXISTS trigger_post_like_notification ON post_likes;
        CREATE TRIGGER trigger_post_like_notification
        AFTER INSERT ON post_likes
        FOR EACH ROW
        EXECUTE FUNCTION trigger_post_like_notification();
    END IF;
    
    -- Trigger for comments (if post_comments table exists)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'post_comments') THEN
        DROP TRIGGER IF EXISTS trigger_comment_notification ON post_comments;
        CREATE TRIGGER trigger_comment_notification
        AFTER INSERT ON post_comments
        FOR EACH ROW
        EXECUTE FUNCTION trigger_comment_notification();
    END IF;
    
    -- Trigger for follows (if user_follows table exists)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_follows') THEN
        DROP TRIGGER IF EXISTS trigger_follow_notification ON user_follows;
        CREATE TRIGGER trigger_follow_notification
        AFTER INSERT ON user_follows
        FOR EACH ROW
        EXECUTE FUNCTION trigger_follow_notification();
    END IF;
END $$;

-- ================================================
-- COMMENTS AND DOCUMENTATION
-- ================================================

COMMENT ON TABLE notifications IS 'User notifications for likes, comments, follows, events, and system messages';
COMMENT ON TABLE notification_settings IS 'User preferences for notification types and delivery methods';
COMMENT ON TABLE notification_templates IS 'Templates for consistent notification messaging across the platform';

COMMENT ON FUNCTION create_notification(UUID, VARCHAR, VARCHAR, TEXT, TEXT, JSONB) IS 'Creates a new notification for a user with type checking';
COMMENT ON FUNCTION get_unread_notification_count(UUID) IS 'Returns the total number of unread notifications for a user';
COMMENT ON FUNCTION mark_notifications_as_read(UUID, UUID[]) IS 'Marks notifications as read for a user (all or specific ones)';
COMMENT ON FUNCTION cleanup_old_notifications(INTEGER) IS 'Removes old notifications to keep database clean';
COMMENT ON FUNCTION create_notification_from_template(UUID, VARCHAR, JSONB, TEXT, JSONB) IS 'Creates notification using predefined templates with variable substitution';
