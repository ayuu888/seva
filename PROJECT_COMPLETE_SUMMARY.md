# Seva Setu Project - Complete Summary

## Project Overview
Seva Setu is a full-stack volunteering platform built with React (frontend) and FastAPI (backend), using Supabase as the database. It connects volunteers with NGOs, allows event management, messaging, notifications, and impact tracking.

**Tech Stack:**
- **Frontend**: React 18, Tailwind CSS, Framer Motion, Axios, React Router, Radix UI, Sonner (toasts)
- **Backend**: Python FastAPI, Supabase (PostgreSQL), Uvicorn, JWT authentication, bcrypt for passwords
- **Database**: Supabase (cloud PostgreSQL) with RLS, indexes, and custom functions
- **Other**: WebSockets (replaced with polling for messaging), CORS, JWT for auth

**Key Features:**
- User authentication (register, login, JWT)
- NGO management and directory
- Event creation and RSVP
- Social feed with posts, likes, comments
- Real-time messaging (polling-based)
- In-app notifications
- Impact measurement and dashboard
- Mobile-responsive design with accessibility

## Architecture

### Backend (Python/FastAPI)
- **Server**: `backend/server.py` - Main FastAPI app with all endpoints
- **Endpoints**:
  - `/api/auth/*` - Login, register, logout, me
  - `/api/posts` - CRUD for posts
  - `/api/events` - Event management, RSVP
  - `/api/ngos` - NGO operations
  - `/api/notifications` - Notification CRUD
  - `/api/conversations` - Messaging (recently added)
  - `/api/messages` - Message operations
  - `/api/impact/*` - Impact metrics, stories, testimonials, case studies
- **CORS**: Allows `http://localhost:3000,3001` with credentials
- **Auth**: JWT stored in localStorage, sent via Authorization header or cookie

### Frontend (React)
- **Main App**: `frontend/src/App.js` - Routes, AuthProvider, API setup
- **Contexts**:
  - `AuthContext.js` - User state, login/logout, Google auth (placeholder)
- **Pages**:
  - `LandingPage.js` - Login/register forms
  - `Feed.js` - Main feed with posts, events sidebar, impact widget
  - `Events.js` - Event list, RSVP
  - `Messages.js` - Conversations, user search, polling for messages
  - `Impact.js` - Dashboard, stories, testimonials, case studies
  - `Profile.js`, `NGODirectory.js`, etc.
- **Components**: `Notifications.js`, `ui/` for buttons, cards, etc.
- **API Setup**: `API = ${BACKEND_URL}/api`, axios interceptors for auth headers

### Database (Supabase)
- **Tables**:
  - `users` - User profiles, auth
  - `ngos` - NGO data, owner_id FK to users
  - `posts` - Social posts, user_id FK
  - `events` - Events, ngo_id FK, attendees via event_attendees
  - `conversations`, `conversation_participants`, `messages` - Messaging
  - `notifications` - In-app notifications
  - `impact_metrics`, `success_stories`, `impact_testimonials`, `case_studies`, `outcome_tracking` - Impact tracking
  - `volunteer_hours`, `donations` - Metrics
  - `presence`, `typing_indicators` - Real-time features
- **Schemas**: Safe, idempotent SQL in `docs/messaging_schema_safe.sql`, `backend/impact_measurement_schema_safe.sql`
- **Seeds**: `docs/simple_seed_data.sql`, `MESSAGING_SEED_DATA.sql`, `backend/impact_seed_data.sql`

## Recent Fixes and Changes (October 20, 2025 Session)

### 1. **Event Management Fixes**
- **Backend**: Added `/api/events/my-registrations` endpoint
- **Backend**: Fixed `create_event` to accept `ngo_id` from payload
- **Database**: Created `event_attendees` table with indexes
- **Frontend**: Updated `Events.js` to fetch registrations, display NGO names, handle date filtering

### 2. **Messaging and Notifications Complete Rewrite**
- **Backend**: Added endpoints for conversations, messages, user search, notifications
- **Database**: Applied messaging schema (conversations, messages, presence, typing)
- **Frontend**: Completely rewrote `Messages.js` with user search, conversation creation, polling-based real-time updates
- **Frontend**: Enhanced `Notifications.js` with unread counts, mark as read

### 3. **Impact Hub Fixes**
- **Database**: Applied impact schema (impact_metrics, success_stories, testimonials, case_studies, outcomes)
- **Database**: Seeded comprehensive impact data
- **Frontend**: Fixed `Impact.js` data fetching, defaulted arrays for robustness
- **Frontend**: Updated `Feed.js` impact widget to read from metrics_by_type

### 4. **Feed and Accessibility Improvements**
- **Frontend**: Fixed image scaling in `Feed.js` (object-contain, max-height, lazy loading)
- **Frontend**: Added a11y to Feed (ARIA labels, touch targets, keyboard navigation)
- **Frontend**: Added loading states and error handling

### 5. **Backend Optimizations**
- **Added pagination** to `/api/posts` and `/api/events` (limit, offset)
- **Fixed presence table** references (changed from 'user_presence' to 'presence')
- **Added `/api/users/search`** for user lookup in messaging

### 6. **Database Seeds Applied**
- **Core seed**: `docs/simple_seed_data.sql` - Users, NGOs, events
- **Messaging seed**: Conversations, messages, participants
- **Impact seed**: Metrics, stories, testimonials, case studies, outcomes, heatmap

## Key Files and Their Purposes

### Backend Files
- `server.py` - Main FastAPI app, all endpoints, CORS, auth middleware
- `messaging_schema_safe.sql` - Safe messaging table creation
- `impact_measurement_schema_safe.sql` - Impact tables creation
- `MESSAGING_SEED_DATA.sql` - Messaging data seed
- `impact_seed_data.sql` - Impact data seed
- `CREATE_EVENT_ATTENDEES_TABLE.sql` - Event attendees table

### Frontend Files
- `App.js` - Routes, API setup (BACKEND_URL = localhost:8001)
- `AuthContext.js` - Auth state, login/logout, register
- `Feed.js` - Main feed, posts, events sidebar, impact widget
- `Events.js` - Event list, RSVP, registration status
- `Messages.js` - Conversations, user search, message sending (rewritten)
- `Impact.js` - Impact dashboard, stories, testimonials (fixed)
- `Notifications.js` - Notification panel, unread counts (enhanced)
- `pages/` - Other pages like Profile, NGODirectory
- `components/` - UI components, animations

### Database Files
- `simple_seed_data.sql` - Core user/NGO/event data
- Schemas and seeds for messaging and impact (applied)

## API Endpoints Summary

### Auth
- POST `/api/auth/register` - Register user
- POST `/api/auth/login` - Login, returns JWT
- POST `/api/auth/logout` - Logout
- GET `/api/auth/me` - Get current user

### Posts
- GET `/api/posts?limit=50&offset=0` - Get posts (paginated)
- POST `/api/posts` - Create post
- POST `/api/posts/{id}/like` - Like/unlike

### Events
- GET `/api/events?limit=50&offset=0` - Get events (paginated)
- POST `/api/events` - Create event (now accepts ngo_id)
- GET `/api/events/my-registrations` - User's registered events
- POST `/api/events/{id}/rsvp` - RSVP to event

### Messaging
- GET `/api/conversations` - Get user's conversations
- POST `/api/conversations` - Create conversation
- GET `/api/conversations/{id}/messages` - Get messages
- POST `/api/messages` - Send message
- GET `/api/users/search?q=` - Search users by name/email

### Notifications
- GET `/api/notifications` - Get notifications
- GET `/api/notifications/unread-count` - Unread count
- PUT `/api/notifications/{id}/read` - Mark as read
- PUT `/api/notifications/mark-all-read` - Mark all read
- DELETE `/api/notifications/{id}` - Delete

### Impact
- GET `/api/impact/dashboard/{ngo_id}` - NGO impact dashboard
- GET `/api/impact/stories` - Success stories
- GET `/api/impact/testimonials` - Testimonials
- GET `/api/impact/case-studies` - Case studies
- GET `/api/impact/outcomes` - Outcome tracking

## Known Issues and Fixes Applied

### Authentication Issues
- **Problem**: 404 on login, invalid credentials
- **Root Cause**: Missing password_hash for seeded users, wrong emails
- **Fix**: Set password_hash and emails for user IDs in database
- **Status**: Fixed (use email 'ayush@example.com' or 'iambatman@example.com', password 'password')

### Event Issues
- **Problem**: Events not showing NGO names, no RSVP
- **Fix**: Added NGO join in `/api/events`, created `event_attendees` table, added `/api/events/my-registrations`
- **Status**: Fixed

### Messaging Issues
- **Problem**: WebSocket broken, no user search, UI crashes
- **Fix**: Replaced with polling, added user search endpoint, rewrote `Messages.js`
- **Status**: Fixed

### Impact Issues
- **Problem**: No data, frontend crashes
- **Fix**: Applied schema, seeded data, fixed frontend fetching
- **Status**: Fixed

### Feed Issues
- **Problem**: Image cropping, no a11y
- **Fix**: Changed to object-contain, added lazy loading, touch targets, ARIA
- **Status**: Fixed

### Performance
- **Fix**: Added pagination, lazy loading, indexes
- **Status**: Optimized

## How to Run the Project

### Backend
```bash
cd backend
source venv/bin/activate
uvicorn server:app --host 0.0.0.0 --port 8001 --reload
```

### Frontend
```bash
cd frontend
PORT=3001 npm start
```

### Database Setup
Run in Supabase SQL Editor (in order):
1. `docs/simple_seed_data.sql` (core data)
2. `backend/impact_measurement_schema_safe.sql` (impact tables)
3. `backend/impact_seed_data.sql` (impact data)
4. `docs/messaging_schema_safe.sql` (messaging tables)
5. `MESSAGING_SEED_DATA.sql` (messaging data)
6. `CREATE_EVENT_ATTENDEES_TABLE.sql` (event attendees)

## Testing Checklist

- [ ] Register/login works
- [ ] Feed shows posts and events
- [ ] Events RSVP works
- [ ] Messages send/receive
- [ ] Notifications load and update
- [ ] Impact dashboard shows data
- [ ] Images scale properly on mobile
- [ ] A11y: touch targets, keyboard nav, ARIA

## Future Improvements
- Real WebSocket for messaging
- Image optimization (CDN, srcset)
- Advanced impact visualizations
- Push notifications
- Mobile app

This summary provides a complete overview of the Seva Setu project, including architecture, fixes, and how to run/test it.
