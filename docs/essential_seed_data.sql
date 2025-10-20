-- Essential Seed Data for Seva Setu
-- Run this in Supabase SQL Editor to populate the database with essential data

-- ============================================================================
-- UPDATE EXISTING USERS WITH PROPER DATA
-- ============================================================================

UPDATE users SET 
  name = 'Ayush Kumar Jha',
  avatar = 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
  bio = 'Passionate about community service and environmental conservation.',
  location = 'Mumbai, India',
  skills = ARRAY['Leadership', 'Teaching', 'Environmental Science'],
  interests = ARRAY['Volunteering', 'Teaching', 'Environment'],
  phone = '+91-98765-43210',
  is_verified = true,
  verification_status = 'verified',
  updated_at = NOW()
WHERE id = '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df';

UPDATE users SET 
  name = 'iambatman',
  avatar = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
  bio = 'Tech enthusiast and social worker. Believe in using technology for social good.',
  location = 'Delhi, India',
  skills = ARRAY['Programming', 'Project Management', 'Mentoring'],
  interests = ARRAY['Technology', 'Education', 'Social Work'],
  phone = '+91-98765-43211',
  is_verified = true,
  verification_status = 'verified',
  updated_at = NOW()
WHERE id = '5cab3330-3c40-4879-a126-bea841a02bb9';

-- ============================================================================
-- UPDATE EXISTING NGOS WITH PROPER DATA
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
-- UPDATE EXISTING EVENTS WITH PROPER DATA
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
-- ADD ESSENTIAL IMPACT DATA
-- ============================================================================

-- Add volunteer hours
INSERT INTO volunteer_hours (id, user_id, event_id, hours, description, date, verified, created_at, updated_at) VALUES
(gen_random_uuid(), '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', '00000000-0000-0000-0000-001376503362', 8, 'Beach cleanup volunteer work', '2024-02-15', true, NOW(), NOW()),
(gen_random_uuid(), '5cab3330-3c40-4879-a126-bea841a02bb9', '00000000-0000-0000-0000-001376503361', 6, 'Digital literacy teaching', '2024-02-20', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Add donations
INSERT INTO donations (id, ngo_id, donor_id, amount, currency, status, created_at, completed_at) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', 500, 'INR', 'completed', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763899', '5cab3330-3c40-4879-a126-bea841a02bb9', 1000, 'INR', 'completed', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days')
ON CONFLICT (id) DO NOTHING;

-- Add success stories
INSERT INTO success_stories (id, ngo_id, title, content, author_id, featured_image, tags, likes_count, published, created_at, updated_at) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', 'Beach Cleanup Success: 500kg Waste Removed', 'Our recent beach cleanup at Marina Beach was a tremendous success! With the help of 45 dedicated volunteers, we managed to remove over 500kg of waste from the beach area.', '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&h=400&fit=crop', ARRAY['Environment', 'Community', 'Beach Cleanup'], 23, true, NOW() - INTERVAL '5 days', NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763899', 'Digital Literacy Program Graduates 50 Seniors', 'We are proud to announce that 50 senior citizens have successfully completed our digital literacy program!', '5cab3330-3c40-4879-a126-bea841a02bb9', 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=400&fit=crop', ARRAY['Education', 'Technology', 'Senior Citizens'], 18, true, NOW() - INTERVAL '3 days', NOW())
ON CONFLICT (id) DO NOTHING;

-- Add impact metrics
INSERT INTO impact_metrics (id, ngo_id, metric_name, metric_type, value, unit, measurement_period, description, created_at, updated_at) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000104763898', 'Total Waste Collected', 'environmental', 2500, 'kg', '2024-01-01 to 2024-03-01', 'Total waste collected from beach cleanups', NOW(), NOW()),
(gen_random_uuid(), '00000000-0000-0000-0000-000104763899', 'People Educated', 'education', 150, 'people', '2024-01-01 to 2024-03-01', 'Total people who completed digital literacy programs', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

SELECT 'Essential seed data updated successfully! The application should now display proper content.' as status;
