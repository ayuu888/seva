-- Impact Measurement Schema (Safe)
-- Run in Supabase SQL Editor

-- Enable extensions (if not already)
create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;

-- impact_metrics
create table if not exists impact_metrics (
  id uuid primary key default gen_random_uuid(),
  ngo_id uuid references ngos(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  metric_type text not null, -- volunteer_hours, donations, people_helped, projects_completed
  value numeric not null default 0,
  unit text not null default 'count',
  date timestamptz default now(),
  description text,
  verified boolean default false,
  created_at timestamptz default now()
);
create index if not exists idx_impact_metrics_ngo on impact_metrics(ngo_id);
create index if not exists idx_impact_metrics_event on impact_metrics(event_id);
create index if not exists idx_impact_metrics_type on impact_metrics(metric_type);

-- success_stories
create table if not exists success_stories (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  content text not null,
  author_id uuid references users(id) on delete set null,
  ngo_id uuid references ngos(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  category text,
  images text[],
  video_url text,
  impact_numbers jsonb,
  tags text[],
  published boolean default true,
  featured boolean default false,
  views_count integer default 0,
  likes_count integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz
);

-- story_comments
create table if not exists story_comments (
  id uuid primary key default gen_random_uuid(),
  story_id uuid references success_stories(id) on delete cascade,
  user_id uuid references users(id) on delete set null,
  user_name text,
  user_avatar text,
  content text not null,
  created_at timestamptz default now()
);
create index if not exists idx_story_comments_story on story_comments(story_id);

-- story_likes
create table if not exists story_likes (
  id uuid primary key default gen_random_uuid(),
  story_id uuid references success_stories(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  created_at timestamptz default now(),
  unique (story_id, user_id)
);

-- impact_testimonials
create table if not exists impact_testimonials (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  ngo_id uuid references ngos(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  testimonial text not null,
  rating integer check (rating between 1 and 5),
  role text,
  location text,
  avatar text,
  name text,
  verified boolean default false,
  featured boolean default false,
  created_at timestamptz default now()
);
create index if not exists idx_testimonials_ngo on impact_testimonials(ngo_id);

-- case_studies
create table if not exists case_studies (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  summary text,
  full_content text,
  ngo_id uuid references ngos(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  author_id uuid references users(id) on delete set null,
  problem_statement text,
  solution text,
  approach text,
  start_date date,
  end_date date,
  beneficiaries_count integer,
  volunteers_involved integer,
  funds_utilized numeric,
  outcomes jsonb,
  challenges text,
  learnings text,
  images text[],
  documents text[],
  category text,
  tags text[],
  published boolean default true,
  featured boolean default false,
  views_count integer default 0,
  created_at timestamptz default now()
);

-- outcome_tracking
create table if not exists outcome_tracking (
  id uuid primary key default gen_random_uuid(),
  ngo_id uuid references ngos(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  case_study_id uuid references case_studies(id) on delete set null,
  outcome_title text not null,
  outcome_description text,
  target_metric text,
  baseline_value numeric not null default 0,
  target_value numeric not null default 0,
  current_value numeric not null default 0,
  unit text not null default 'count',
  start_date date,
  target_date date,
  last_measured_date date,
  status text default 'in_progress', -- in_progress, achieved, at_risk, delayed
  progress_percentage numeric default 0,
  updates jsonb default '[]'::jsonb,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz
);
create index if not exists idx_outcomes_ngo on outcome_tracking(ngo_id);

-- volunteer_hours (minimal)
create table if not exists volunteer_hours (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  hours numeric not null default 0,
  date date default now(),
  verified boolean default false,
  created_at timestamptz default now()
);

-- donations (minimal)
create table if not exists donations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  ngo_id uuid references ngos(id) on delete set null,
  amount numeric not null default 0,
  currency text default 'USD',
  status text default 'completed',
  created_at timestamptz default now()
);

-- impact_events
create table if not exists impact_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,
  title text,
  description text,
  location_lat numeric,
  location_lng numeric,
  user_id uuid references users(id) on delete set null,
  ngo_id uuid references ngos(id) on delete set null,
  is_public boolean default true,
  created_at timestamptz default now()
);

-- impact_heatmap
create table if not exists impact_heatmap (
  id uuid primary key default gen_random_uuid(),
  location_lat numeric not null,
  location_lng numeric not null,
  activity_count integer default 0,
  intensity integer default 0,
  last_updated timestamptz default now()
);
create index if not exists idx_heatmap_cell on impact_heatmap(location_lat, location_lng);

-- impact_roi
create table if not exists impact_roi (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null, -- ngo or event
  entity_id uuid,
  total_donations numeric default 0,
  volunteer_hours numeric default 0,
  volunteer_value numeric default 0,
  direct_impact_value numeric default 0,
  indirect_impact_value numeric default 0,
  roi_percentage numeric default 0,
  calculation_date timestamptz default now(),
  methodology text
);

-- impact_multipliers
create table if not exists impact_multipliers (
  id uuid primary key default gen_random_uuid(),
  source_event_id uuid references events(id) on delete set null,
  label text,
  multiplier_value numeric default 1,
  created_at timestamptz default now()
);
