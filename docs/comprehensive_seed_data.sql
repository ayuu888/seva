-- Comprehensive Seed Data for Seva Setu
-- Run this in Supabase SQL Editor to populate the database with sample data

-- ============================================================================
-- USERS DATA
-- ============================================================================

-- Insert sample users (using existing user IDs from the system)
INSERT INTO users (id, name, email, user_type, avatar, bio, location, skills, interests, phone, date_of_birth, joined_at, last_active, is_verified, verification_status, created_at, updated_at) VALUES
('051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', 'Ayush Kumar Jha', 'ayushkrjha@nullsto.edu.pl', 'user', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face', 'Passionate about community service and environmental conservation. Love organizing beach cleanups and teaching digital literacy.', 'Mumbai, India', ARRAY['Leadership', 'Teaching', 'Environmental Science'], ARRAY['Volunteering', 'Teaching', 'Environment', 'Technology'], '+91-98765-43210', '1995-06-15', '2024-01-15', NOW(), true, 'verified', NOW(), NOW()),
('5cab3330-3c40-4879-a126-bea841a02bb9', 'iambatman', 'ak.matrix123@outlook.com', 'user', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face', 'Tech enthusiast and social worker. Believe in using technology for social good.', 'Delhi, India', ARRAY['Programming', 'Project Management', 'Mentoring'], ARRAY['Technology', 'Education', 'Social Work'], '+91-98765-43211', '1992-03-22', '2024-02-01', NOW(), true, 'verified', NOW(), NOW()),
('0c6a3114-6a1e-4715-b34a-afdef782024a', 'Test User 2', 'test2@example.com', 'user', 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face', 'Active volunteer in healthcare and education sectors.', 'Bangalore, India', ARRAY['Healthcare', 'Teaching', 'Communication'], ARRAY['Healthcare', 'Education', 'Community Service'], '+91-98765-43212', '1988-11-10', '2024-01-20', NOW(), true, 'verified', NOW(), NOW()),
('07b35e32-4dd5-4137-8cc0-b90f7c59a005', 'iambatman', 'ayushjha.unix@gmail.com', 'user', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face', 'Software developer passionate about social impact.', 'Chennai, India', ARRAY['Software Development', 'Data Analysis', 'Training'], ARRAY['Technology', 'Data Science', 'Social Impact'], '+91-98765-43213', '1990-08-05', '2024-01-25', NOW(), true, 'verified', NOW(), NOW()),
('74ab2d63-bcc3-4da4-98f8-60e536154b32', 'Test User', 'test@example.com', 'user', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face', 'Community organizer and event coordinator.', 'Pune, India', ARRAY['Event Management', 'Public Speaking', 'Leadership'], ARRAY['Community Building', 'Events', 'Leadership'], '+91-98765-43214', '1985-12-18', '2024-02-05', NOW(), true, 'verified', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  avatar = EXCLUDED.avatar,
  bio = EXCLUDED.bio,
  skills = EXCLUDED.skills,
  interests = EXCLUDED.interests,
  updated_at = NOW();

-- ============================================================================
-- NGOS DATA (Update existing NGOs with more details)
-- ============================================================================

UPDATE ngos SET 
  description = 'Environmental conservation and sustainability initiatives. We organize beach cleanups, tree planting drives, and environmental awareness campaigns.',
  logo_url = 'https://images.unsplash.com/photo-1569163139394-de7e4c7f8b6e?w=200&h=200&fit=crop',
  website = 'https://greenearth.org',
  email = 'contact@greenearth.org',
  phone = '+91-11-1234-5678',
  location = 'Delhi, India',
  verified = true,
  followers_count = 1250,
  updated_at = NOW()
WHERE id = '00000000-0000-0000-0000-000104763898';

UPDATE ngos SET 
  description = 'Providing quality education to underprivileged children. We run schools, provide scholarships, and conduct digital literacy programs.',
  logo_url = 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=200&h=200&fit=crop',
  website = 'https://educationforall.org',
  email = 'info@educationforall.org',
  phone = '+91-22-2345-6789',
  location = 'Mumbai, India',
  verified = true,
  followers_count = 2100,
  updated_at = NOW()
WHERE id = '00000000-0000-0000-0000-000104763899';

UPDATE ngos SET 
  description = 'Improving healthcare access in rural areas. We provide mobile health clinics, health awareness programs, and medical camps.',
  logo_url = 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=200&h=200&fit=crop',
  website = 'https://healthcareinitiative.org',
  email = 'support@healthcareinitiative.org',
  phone = '+91-80-3456-7890',
  location = 'Bangalore, India',
  verified = false,
  followers_count = 850,
  updated_at = NOW()
WHERE id = '00000000-0000-0000-0000-000104763900';

-- ============================================================================
-- EVENTS DATA (Update existing events with more details)
-- ============================================================================

UPDATE events SET 
  description = 'Join us for a community beach cleanup to protect our marine environment. We will provide all necessary equipment and refreshments.',
  start_date = '2024-03-15T09:00:00+00:00',
  end_date = '2024-03-15T17:00:00+00:00',
  location = 'Marina Beach, Chennai',
  address = 'Marina Beach, Chennai, Tamil Nadu 600001',
  city = 'Chennai',
  state = 'Tamil Nadu',
  country = 'India',
  max_attendees = 50,
  volunteers_needed = 15,
  requires_application = false,
  tags = ARRAY['Environment', 'Beach Cleanup', 'Community Service'],
  requirements = 'Bring sunscreen, hat, and water bottle. We provide gloves and bags.',
  skills_needed = ARRAY['Physical Fitness', 'Team Work'],
  contact_email = 'events@greenearth.org',
  contact_phone = '+91-11-1234-5678',
  updated_at = NOW()
WHERE id = '00000000-0000-0000-0000-001376503362';

UPDATE events SET 
  description = 'Teaching basic computer skills to senior citizens. Help bridge the digital divide and empower our elders with technology.',
  start_date = '2024-03-20T10:00:00+00:00',
  end_date = '2024-03-20T16:00:00+00:00',
  location = 'Community Center, Mumbai',
  address = 'Community Center, Bandra West, Mumbai, Maharashtra 400050',
  city = 'Mumbai',
  state = 'Maharashtra',
  country = 'India',
  max_attendees = 30,
  volunteers_needed = 8,
  requires_application = true,
  tags = ARRAY['Education', 'Digital Literacy', 'Senior Citizens'],
  requirements = 'Basic computer knowledge required. Patience and good communication skills.',
  skills_needed = ARRAY['Teaching', 'Patience', 'Communication'],
  contact_email = 'volunteers@educationforall.org',
  contact_phone = '+91-22-2345-6789',
  updated_at = NOW()
WHERE id = '00000000-0000-0000-0000-001376503361';

UPDATE events SET 
  description = 'Free health checkups for rural communities. Providing basic health screening and medical consultations.',
  start_date = '2024-03-25T08:00:00+00:00',
  end_date = '2024-03-25T18:00:00+00:00',
  location = 'Village Health Center, Karnataka',
  address = 'Village Health Center, Hassan, Karnataka 573201',
  city = 'Hassan',
  state = 'Karnataka',
  country = 'India',
  max_attendees = 100,
  volunteers_needed = 12,
  requires_application = true,
  tags = ARRAY['Healthcare', 'Rural Development', 'Medical Camp'],
  requirements = 'Medical background preferred but not required. Basic first aid knowledge helpful.',
  skills_needed = ARRAY['Healthcare', 'Communication', 'Organization'],
  contact_email = 'healthcare@healthcareinitiative.org',
  contact_phone = '+91-80-3456-7890',
  updated_at = NOW()
WHERE id = '00000000-0000-0000-0000-001376503360';

-- ============================================================================
-- VOLUNTEER HOURS DATA
-- ============================================================================

INSERT INTO volunteer_hours (id, user_id, event_id, hours, description, date, verified, verified_by, verified_at, created_at, updated_at) VALUES
(gen_random_uuid(), '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', '00000000-0000-0000-0000-001376503362', 8, 'Beach cleanup volunteer work', '2024-02-15', true, '00000000-0000-0000-0000-000104763898', NOW(), NOW(), NOW()),
(gen_random_uuid(), '5cab3330-3c40-4879-a126-bea841a02bb9', '00000000-0000-0000-0000-001376503361', 6, 'Digital literacy teaching', '2024-02-20', true, '00000000-0000-0000-0000-000104763899', NOW(), NOW(), NOW()),
(gen_random_uuid(), '0c6a3114-6a1e-4715-b34a-afdef782024a', '00000000-0000-0000-0000-001376503360', 10, 'Health camp assistance', '2024-02-25', true, '00000000-0000-0000-0000-000104763900', NOW(), NOW(), NOW()),
(gen_random_uuid(), '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', '00000000-0000-0000-0000-001376503361', 4, 'Teaching assistance', '2024-02-22', true, '00000000-0000-0000-0000-000104763899', NOW(), NOW(), NOW()),
(gen_random_uuid(), '07b35e32-4dd5-4137-8cc0-b90f7c59a005', '00000000-0000-0000-0000-001376503362', 7, 'Environmental awareness', '2024-02-16', true, '00000000-0000-0000-0000-000104763898', NOW(), NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- DONATIONS DATA
-- ============================================================================

INSERT INTO donations (id, ngo_id, donor_id, amount, currency, status, stripe_session_id, created_at, completed_at) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', 500, 'INR', 'completed', 'cs_test_123456789', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763899', '5cab3330-3c40-4879-a126-bea841a02bb9', 1000, 'INR', 'completed', 'cs_test_987654321', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763900', '0c6a3114-6a1e-4715-b34a-afdef782024a', 750, 'INR', 'completed', 'cs_test_456789123', NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days'),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', '07b35e32-4dd5-4137-8cc0-b90f7c59a005', 300, 'INR', 'completed', 'cs_test_789123456', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763899', '74ab2d63-bcc3-4da4-98f8-60e536154b32', 1200, 'INR', 'completed', 'cs_test_321654987', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SUCCESS STORIES DATA
-- ============================================================================

INSERT INTO success_stories (id, ngo_id, title, content, author_id, featured_image, tags, likes_count, published, created_at, updated_at) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', 'Beach Cleanup Success: 500kg Waste Removed', 'Our recent beach cleanup at Marina Beach was a tremendous success! With the help of 45 dedicated volunteers, we managed to remove over 500kg of waste from the beach area. The impact was immediate - local marine life is already showing signs of recovery, and the beach is cleaner than it has been in years. Special thanks to all volunteers who made this possible!', '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&h=400&fit=crop', ARRAY['Environment', 'Community', 'Beach Cleanup'], 23, true, NOW() - INTERVAL '5 days', NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763899', 'Digital Literacy Program Graduates 50 Seniors', 'We are proud to announce that 50 senior citizens have successfully completed our digital literacy program! These amazing individuals, aged 60-80, have learned to use smartphones, send emails, and even video call their families. The joy on their faces when they made their first video call was priceless. Technology truly knows no age limits!', '5cab3330-3c40-4879-a126-bea841a02bb9', 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=400&fit=crop', ARRAY['Education', 'Technology', 'Senior Citizens'], 18, true, NOW() - INTERVAL '3 days', NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763900', 'Health Camp Serves 200+ Rural Families', 'Our mobile health camp in Hassan district served over 200 families, providing free health checkups and medical consultations. We detected and referred 15 cases for further treatment, potentially saving lives through early detection. The gratitude of the community was overwhelming, and we are committed to expanding this program to more rural areas.', '0c6a3114-6a1e-4715-b34a-afdef782024a', 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=800&h=400&fit=crop', ARRAY['Healthcare', 'Rural Development', 'Medical Camp'], 31, true, NOW() - INTERVAL '7 days', NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- IMPACT TESTIMONIALS DATA
-- ============================================================================

INSERT INTO impact_testimonials (id, ngo_id, author_name, author_role, content, rating, featured, created_at, updated_at) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', 'Priya Sharma', 'Local Resident', 'The beach cleanup organized by Green Earth Foundation has transformed our local beach. My children can now play safely, and we see more marine life returning. The organizers were professional and the event was well-managed. Highly recommend supporting their cause!', 5, true, NOW() - INTERVAL '4 days', NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763899', 'Ramesh Patel', 'Program Graduate', 'At 72, I never thought I would learn to use a smartphone. The Education for All team was patient and encouraging. Now I can video call my grandchildren who live abroad. This program has changed my life!', 5, true, NOW() - INTERVAL '2 days', NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763900', 'Dr. Sunita Reddy', 'Medical Professional', 'As a doctor, I have seen the impact of the Health Care Initiative firsthand. Their mobile health camps reach the most remote areas where medical facilities are scarce. The early detection of health issues they facilitate is saving lives.', 5, true, NOW() - INTERVAL '6 days', NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- CASE STUDIES DATA
-- ============================================================================

INSERT INTO case_studies (id, ngo_id, title, description, challenge, solution, results, tags, featured_image, published, created_at, updated_at) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', 'Marine Conservation Through Community Engagement', 'A comprehensive case study on how community involvement in beach cleanups leads to long-term marine conservation success.', 'Marine pollution was threatening local ecosystem and tourism industry. Lack of community awareness about environmental impact.', 'Implemented regular beach cleanup drives with educational sessions about marine conservation. Engaged local schools and businesses as partners.', 'Reduced beach waste by 60% in 6 months. Increased community participation by 300%. Marine life diversity improved significantly.', ARRAY['Environment', 'Community Engagement', 'Marine Conservation'], 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&h=400&fit=crop', true, NOW() - INTERVAL '8 days', NOW()),
(gen_random_uuid(), '00000000-000671-0000-0000-000104763899', 'Bridging the Digital Divide for Senior Citizens', 'How targeted digital literacy programs can empower senior citizens and reduce social isolation.', 'Senior citizens were increasingly isolated due to lack of digital skills, especially during the pandemic when everything moved online.', 'Developed age-appropriate curriculum with hands-on training, peer support groups, and ongoing technical assistance.', '50 seniors graduated from the program. 80% reported improved communication with family. 60% now use digital services independently.', ARRAY['Education', 'Digital Literacy', 'Senior Citizens', 'Social Inclusion'], 'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=800&h=400&fit=crop', true, NOW() - INTERVAL '5 days', NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- OUTCOME TRACKING DATA
-- ============================================================================

INSERT INTO outcome_tracking (id, ngo_id, event_id, metric_name, target_value, actual_value, unit, measurement_date, notes, created_at, updated_at) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', '00000000-0000-0000-0000-001376503362', 'Waste Collected', 300, 500, 'kg', '2024-02-15', 'Exceeded target by 67% due to high volunteer turnout', NOW(), NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', '00000000-0000-0000-0000-001376503362', 'Volunteers Participated', 30, 45, 'people', '2024-02-15', 'Strong community response to the initiative', NOW(), NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763899', '00000000-0000-0000-0000-001376503361', 'Participants Graduated', 40, 50, 'people', '2024-02-20', 'All participants successfully completed the program', NOW(), NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763899', '00000000-0000-0000-0000-001376503361', 'Digital Skills Acquired', 100, 100, '%', '2024-02-20', '100% of graduates can now use basic digital tools', NOW(), NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763900', '00000000-0000-0000-0000-001376503360', 'Health Checkups Conducted', 150, 200, 'people', '2024-02-25', 'Served more people than expected due to efficient organization', NOW(), NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763900', '00000000-0000-0000-0000-001376503360', 'Cases Referred for Treatment', 10, 15, 'cases', '2024-02-25', 'Early detection helped identify health issues requiring attention', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- IMPACT METRICS DATA
-- ============================================================================

INSERT INTO impact_metrics (id, ngo_id, metric_name, metric_type, value, unit, measurement_period, description, created_at, updated_at) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', 'Total Waste Collected', 'environmental', 2500, 'kg', '2024-01-01 to 2024-03-01', 'Total waste collected from beach cleanups', NOW(), NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', 'Volunteer Hours', 'social', 1200, 'hours', '2024-01-01 to 2024-03-01', 'Total volunteer hours contributed', NOW(), NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763899', 'People Educated', 'education', 150, 'people', '2024-01-01 to 2024-03-01', 'Total people who completed digital literacy programs', NOW(), NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763899', 'Classes Conducted', 'education', 45, 'classes', '2024-01-01 to 2024-03-01', 'Total digital literacy classes conducted', NOW(), NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763900', 'Health Checkups', 'healthcare', 800, 'people', '2024-01-01 to 2024-03-01', 'Total health checkups conducted', NOW(), NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763900', 'Lives Impacted', 'healthcare', 1200, 'people', '2024-01-01 to 2024-03-01', 'Total people reached through health initiatives', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- BADGES DATA (Update existing badges with descriptions)
-- ============================================================================

UPDATE badges SET 
  description = 'Complete your first volunteer activity and start your journey of making a difference',
  icon = '🌟',
  badge_type = 'event_completion',
  criteria = '{"events": 1}',
  rarity = 'common',
  points = 10
WHERE badge_name = 'First Step';

-- Add more badges
INSERT INTO badges (id, badge_name, description, icon, badge_type, criteria, rarity, points, is_active, created_at, updated_at) VALUES
(gen_random_uuid(), 'Environmental Champion', 'Complete 5 environmental volunteer activities', '🌱', 'environmental', '{"environmental_events": 5}', 'rare', 50, true, NOW(), NOW()),
(gen_random_uuid(), 'Education Advocate', 'Help educate 10 people through volunteer work', '📚', 'education', '{"people_educated": 10}', 'rare', 50, true, NOW(), NOW()),
(gen_random_uuid(), 'Healthcare Hero', 'Participate in 3 healthcare volunteer activities', '🏥', 'healthcare', '{"healthcare_events": 3}', 'rare', 40, true, NOW(), NOW()),
(gen_random_uuid(), 'Community Leader', 'Lead or organize 2 community events', '👑', 'leadership', '{"events_led": 2}', 'epic', 100, true, NOW(), NOW()),
(gen_random_uuid(), 'Regular Volunteer', 'Volunteer for 10 consecutive weeks', '⏰', 'consistency', '{"consecutive_weeks": 10}', 'legendary', 200, true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- USER BADGES DATA
-- ============================================================================

INSERT INTO user_badges (id, user_id, badge_id, earned_at, created_at) VALUES
(gen_random_uuid(), '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', (SELECT id FROM badges WHERE badge_name = 'First Step'), NOW() - INTERVAL '10 days', NOW()),
(gen_random_uuid(), '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', (SELECT id FROM badges WHERE badge_name = 'Environmental Champion'), NOW() - INTERVAL '5 days', NOW()),
(gen_random_uuid(), '5cab3330-3c40-4879-a126-bea841a02bb9', (SELECT id FROM badges WHERE badge_name = 'First Step'), NOW() - INTERVAL '8 days', NOW()),
(gen_random_uuid(), '5cab3330-3c40-4879-a126-bea841a02bb9', (SELECT id FROM badges WHERE badge_name = 'Education Advocate'), NOW() - INTERVAL '3 days', NOW()),
(gen_random_uuid(), '0c6a3114-6a1e-4715-b34a-afdef782024a', (SELECT id FROM badges WHERE badge_name = 'First Step'), NOW() - INTERVAL '7 days', NOW()),
(gen_random_uuid(), '0c6a3114-6a1e-4715-b34a-afdef782024a', (SELECT id FROM badges WHERE badge_name = 'Healthcare Hero'), NOW() - INTERVAL '2 days', NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- LEADERBOARD DATA
-- ============================================================================

INSERT INTO leaderboards (id, category, metric_type, period, rankings, updated_at) VALUES
(gen_random_uuid(), 'volunteer', 'hours', 'monthly', '[
  {"user_id": "051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df", "name": "Ayush Kumar Jha", "value": 22, "rank": 1},
  {"user_id": "0c6a3114-6a1e-4715-b34a-afdef782024a", "name": "Test User 2", "value": 10, "rank": 2},
  {"user_id": "07b35e32-4dd5-4137-8cc0-b90f7c59a005", "name": "iambatman", "value": 7, "rank": 3}
]', NOW()),
(gen_random_uuid(), 'ngo', 'impact_score', 'monthly', '[
  {"ngo_id": "00000000-0000-0000-0000-000104763898", "name": "Green Earth Foundation", "value": 1250, "rank": 1},
  {"ngo_id": "00000000-0000-0000-0000-000104763899", "name": "Education for All", "value": 2100, "rank": 2},
  {"ngo_id": "00000000-0000-0000-0000-000104763900", "name": "Health Care Initiative", "value": 850, "rank": 3}
]', NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- NOTIFICATIONS DATA
-- ============================================================================

INSERT INTO notifications (id, user_id, type, title, message, data, read, created_at) VALUES
(gen_random_uuid(), '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', 'achievement', 'Badge Earned!', 'Congratulations! You earned the Environmental Champion badge.', '{"badge_name": "Environmental Champion", "badge_icon": "🌱"}', false, NOW() - INTERVAL '1 day'),
(gen_random_uuid(), '5cab3330-3c40-4879-a126-bea841a02bb9', 'event', 'Event Reminder', 'Digital Literacy Workshop starts tomorrow at 10:00 AM', '{"event_id": "00000000-0000-0000-0000-001376503361", "event_title": "Digital Literacy Workshop"}', false, NOW() - INTERVAL '2 hours'),
(gen_random_uuid(), '0c6a3114-6a1e-4715-b34a-afdef782024a', 'donation', 'Thank You!', 'Your donation of ₹750 has been received. Thank you for supporting our cause!', '{"amount": 750, "currency": "INR", "ngo_name": "Health Care Initiative"}', false, NOW() - INTERVAL '3 hours')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- MESSAGES DATA (Sample conversations)
-- ============================================================================

-- Create a system conversation
INSERT INTO conversations (id, type, title, last_message_at, created_at, updated_at) VALUES
(gen_random_uuid(), 'system', 'System Announcements', NOW() - INTERVAL '1 day', NOW() - INTERVAL '30 days', NOW())
ON CONFLICT (id) DO NOTHING;

-- Add participants to the system conversation
INSERT INTO conversation_participants (id, conversation_id, user_id, role, joined_at) VALUES
(gen_random_uuid(), (SELECT id FROM conversations WHERE type = 'system' LIMIT 1), '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', 'member', NOW() - INTERVAL '30 days'),
(gen_random_uuid(), (SELECT id FROM conversations WHERE type = 'system' LIMIT 1), '5cab3330-3c40-4879-a126-bea841a02bb9', 'member', NOW() - INTERVAL '30 days'),
(gen_random_uuid(), (SELECT id FROM conversations WHERE type = 'system' LIMIT 1), '0c6a3114-6a1e-4715-b34a-afdef782024a', 'member', NOW() - INTERVAL '30 days')
ON CONFLICT (id) DO NOTHING;

-- Add sample messages
INSERT INTO messages (id, conversation_id, user_id, content, message_type, created_at, updated_at) VALUES
(gen_random_uuid(), (SELECT id FROM conversations WHERE type = 'system' LIMIT 1), '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', 'Welcome to Seva Setu! We are excited to have you join our community of volunteers and changemakers.', 'text', NOW() - INTERVAL '30 days', NOW()),
(gen_random_uuid(), (SELECT id FROM conversations WHERE type = 'system' LIMIT 1), '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', 'Check out our upcoming beach cleanup event this weekend! All are welcome to participate.', 'text', NOW() - INTERVAL '5 days', NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================

SELECT 'Seed data insertion completed successfully! The database now contains comprehensive sample data for testing all features.' as status;
