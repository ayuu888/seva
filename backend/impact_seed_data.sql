-- Impact Seed Data for Seva Setu (adjust IDs as needed)
-- Run this in Supabase SQL Editor after running impact_measurement_schema_safe.sql

-- Known sample IDs from simple_seed_data.sql (adjust if different in your DB)
-- Users
-- 051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df (Ayush Kumar Jha)
-- 5cab3330-3c40-4879-a126-bea841a02bb9 (iambatman)
-- NGOs
-- 00000000-0000-0000-0000-000104763898 (Green Earth)
-- 00000000-0000-0000-0000-000104763899 (Education For All)
-- 00000000-0000-0000-0000-000104763900 (Healthcare Initiative)
-- Events
-- 00000000-0000-0000-0000-001376503362 (Beach Cleanup)

-- ==============================
-- Impact Metrics (per NGO/event)
-- ==============================
insert into impact_metrics (ngo_id, event_id, metric_type, value, unit, date, description, verified)
values
  ('00000000-0000-0000-0000-000104763898', '00000000-0000-0000-0000-001376503362', 'people_helped', 200, 'people', now() - interval '10 days', 'Beach cleanup beneficiaries (awareness + local vendors)', true),
  ('00000000-0000-0000-0000-000104763898', '00000000-0000-0000-0000-001376503362', 'projects_completed', 1, 'projects', now() - interval '10 days', 'Beach Cleanup Project Completed', true),
  ('00000000-0000-0000-0000-000104763898', null, 'volunteer_hours', 320, 'hours', now() - interval '7 days', 'Accumulated volunteer hours this month', true),
  ('00000000-0000-0000-0000-000104763898', null, 'donations', 2500, 'USD', now() - interval '6 days', 'Online fundraiser', true),
  ('00000000-0000-0000-0000-000104763899', null, 'people_helped', 120, 'people', now() - interval '5 days', 'Digital literacy students', true),
  ('00000000-0000-0000-0000-000104763899', null, 'volunteer_hours', 140, 'hours', now() - interval '4 days', 'Tutoring time', true);

-- ==============================
-- Volunteer Hours
-- ==============================
insert into volunteer_hours (user_id, event_id, hours, date, verified)
values
  ('051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', '00000000-0000-0000-0000-001376503362', 5, now() - interval '9 days', true),
  ('5cab3330-3c40-4879-a126-bea841a02bb9', '00000000-0000-0000-0000-001376503362', 4, now() - interval '9 days', true);

-- ==============================
-- Donations
-- ==============================
insert into donations (user_id, ngo_id, amount, currency, status, created_at)
values
  ('051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', '00000000-0000-0000-0000-000104763898', 500, 'USD', 'completed', now() - interval '6 days'),
  ('5cab3330-3c40-4879-a126-bea841a02bb9', '00000000-0000-0000-0000-000104763899', 300, 'USD', 'completed', now() - interval '3 days');

-- ==============================
-- Success Stories
-- ==============================
insert into success_stories (
  title, content, author_id, ngo_id, event_id, category, images, impact_numbers, tags, published, featured
) values (
  'Waves of Change: Beach Cleanup Impact',
  'Over 200 people benefited from our awareness campaigns and cleanup drive. Local fishermen reported clearer waters near the coast.',
  '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df',
  '00000000-0000-0000-0000-000104763898',
  '00000000-0000-0000-0000-001376503362',
  'Environment',
  array['https://images.unsplash.com/photo-1520975693412-35d1a58b6f57'],
  '{"people_helped": 200, "trash_collected_kg": 200}'::jsonb,
  array['cleanup','ocean'],
  true,
  true
);

-- ==============================
-- Testimonials
-- ==============================
insert into impact_testimonials (
  user_id, ngo_id, event_id, testimonial, rating, role, location, avatar, name, verified, featured
) values (
  '5cab3330-3c40-4879-a126-bea841a02bb9',
  '00000000-0000-0000-0000-000104763898',
  '00000000-0000-0000-0000-001376503362',
  'A wonderful initiative that truly made a difference at our beach!', 5, 'volunteer', 'Chennai, India',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
  'iambatman', true, true
);

-- ==============================
-- Case Studies
-- ==============================
insert into case_studies (
  title, summary, full_content, ngo_id, event_id, author_id, problem_statement, solution, approach,
  start_date, end_date, beneficiaries_count, volunteers_involved, funds_utilized, outcomes, challenges, learnings,
  images, documents, category, tags, published, featured
) values (
  'Sustaining Clean Shores',
  'A case study on long-term impact of recurring cleanups',
  'The project focused on recurring cleanups, community education, and waste segregation awareness.',
  '00000000-0000-0000-0000-000104763898',
  '00000000-0000-0000-0000-001376503362',
  '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df',
  'Excess marine litter at Marina Beach',
  'Monthly cleanup drives + education',
  'Community mobilization + partnerships',
  now() - interval '2 months', now() - interval '1 months',
  200, 50, 1200,
  '{"trash_collected_kg": 200, "awareness_sessions": 5}'::jsonb,
  'Monsoon surges increase litter',
  'Partner with local vendors to reduce single-use plastics',
  array['https://images.unsplash.com/photo-1543429409-5f6e9a73687e'],
  array[]::text[],
  'Environment',
  array['cleanup','education'],
  true,
  true
);

-- ==============================
-- Outcomes
-- ==============================
insert into outcome_tracking (
  ngo_id, event_id, outcome_title, outcome_description, target_metric, baseline_value, target_value, current_value,
  unit, start_date, target_date, last_measured_date, status, progress_percentage, updates, created_by
) values (
  '00000000-0000-0000-0000-000104763898', '00000000-0000-0000-0000-001376503362',
  'Trash Reduction', 'Reduce beach trash by 50% over 3 months', 'trash_collected_kg',
  400, 200, 250, 'kg', now() - interval '2 months', now() + interval '1 months', now() - interval '3 days',
  'in_progress', 50, '[{"date": "2025-10-15", "value": 250, "notes": "Midpoint review"}]',
  '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df'
);

-- ==============================
-- Impact Events & Heatmap
-- ==============================
insert into impact_events (event_type, title, description, location_lat, location_lng, user_id, ngo_id, is_public)
values
 ('cleanup', 'Marina Cleanup', 'Live impact stream update', 13.05, 80.28, '051b2fd3-3e6c-4f4d-8c1f-0cbba94b95df', '00000000-0000-0000-0000-000104763898', true);

insert into impact_heatmap (location_lat, location_lng, activity_count, intensity)
values
 (13.05, 80.28, 5, 40)
ON CONFLICT DO NOTHING;
