# Gamification & Analytics Setup Guide

## 🎉 New Features Implemented

We've added three major feature sets to Seva-Setu:

1. **Gamification & Social Proof** 🏆
   - Leaderboards (Volunteers, Donors, NGOs)
   - Achievement Badges System
   - Social Challenges
   - Activity Streaks
   - Community Impact Score

2. **Real-time Impact Visualization** 📊
   - Live Impact Counters
   - Interactive Impact Map (with Leaflet)
   - Impact Heatmap
   - Real-time Donation Ticker
   - Impact Timeline

3. **Advanced Analytics** 📈
   - ROI Calculator
   - Predictive Analytics
   - Comparative Analytics
   - Impact Multiplier
   - Sustainability Metrics

---

## 🚀 Setup Instructions

### Step 1: Database Schema Setup

You need to execute the new database schema in Supabase:

1. Go to your Supabase Dashboard: https://app.supabase.com
2. Select your project
3. Go to **SQL Editor**
4. Copy and paste the contents of `/app/backend/gamification_schema.sql`
5. Click **Run** to execute the schema

This will create all necessary tables:
- `leaderboards` - Rankings for volunteers, donors, NGOs
- `badges` - Available achievement badges
- `user_badges` - Badges earned by users
- `challenges` - Community challenges
- `challenge_participants` - Challenge participation tracking
- `activity_streaks` - User activity streaks
- `community_scores` - Overall impact scores
- `live_counters` - Real-time counters
- `impact_events` - Events for timeline and map
- `impact_heatmap` - Heatmap data
- `impact_roi` - ROI calculations
- `analytics_predictions` - Predictive analytics data
- `comparative_metrics` - Comparative analytics
- `impact_multipliers` - Multiplier effects
- `sustainability_metrics` - Environmental impact

The schema also includes:
- 11 pre-configured achievement badges
- 8 live counters initialized
- Automatic ranking functions
- Triggers for real-time updates

---

### Step 2: Backend Verification

The backend endpoints are already added. Verify they're working:

```bash
# Check backend status
sudo supervisorctl status backend

# Test a gamification endpoint
curl http://localhost:8001/api/gamification/badges

# Test a real-time endpoint
curl http://localhost:8001/api/realtime/counters

# Test an analytics endpoint (requires auth)
curl http://localhost:8001/api/analytics/sustainability
```

---

### Step 3: Frontend Access

The new features are accessible at:
- **Main Page**: http://your-domain/impact-hub

The Impact Hub has three tabs:
1. **Gamification Tab**: Leaderboards, Badges, Challenges, Streaks
2. **Real-time Impact Tab**: Live counters, maps, heatmaps, donation ticker
3. **Analytics Tab**: ROI calculator, predictions, comparisons

You'll also see a new **"Impact Hub"** link in the navigation bar (highlighted in blue/purple gradient).

---

## 📋 API Endpoints Reference

### Gamification Endpoints

```
GET  /api/gamification/leaderboards?category=volunteer&metric_type=hours
GET  /api/gamification/badges
GET  /api/gamification/user-badges/{user_id}
POST /api/gamification/award-badge
GET  /api/gamification/challenges?status=active
POST /api/gamification/challenges
POST /api/gamification/challenges/{id}/join
POST /api/gamification/challenges/{id}/progress
GET  /api/gamification/streaks/{user_id}
POST /api/gamification/streaks/checkin
GET  /api/gamification/community-score?entity_type=user
```

### Real-time Visualization Endpoints

```
GET  /api/realtime/counters
POST /api/realtime/counters/increment
GET  /api/realtime/impact-map
GET  /api/realtime/heatmap
GET  /api/realtime/donation-ticker?limit=20
GET  /api/realtime/timeline?limit=50
POST /api/realtime/impact-event
```

### Analytics Endpoints

```
POST /api/analytics/roi-calculator
GET  /api/analytics/predictions
POST /api/analytics/predictions/generate
GET  /api/analytics/comparative?ngo_id={id}
GET  /api/analytics/impact-multiplier?source_event_id={id}
GET  /api/analytics/sustainability?ngo_id={id}
```

---

## 🎮 How to Use the Features

### Leaderboards
- Automatically updated when users volunteer, donate, or create events
- Filter by category (Volunteer/Donor/NGO) and metric type
- Top 3 positions get special badges (Crown, Silver, Bronze)

### Achievement Badges
- **Pre-configured badges**:
  - First Step (1 event)
  - Dedicated Helper (10 hours)
  - Time Champion (50 hours)
  - Century Club (100 hours)
  - Generous Donor (first donation)
  - Impact Maker ($100+ donation)
  - Week Warrior (7-day streak)
  - Month Master (30-day streak)
  - Event Organizer (5 events created)
  - Community Builder (100 people helped)
  - Legend (1000 impact points)

### Challenges
- Create global or NGO-specific challenges
- Track progress in real-time
- Reward participants with points and badges
- Examples: "Plant 1000 trees this month", "Volunteer 500 hours collectively"

### Activity Streaks
- Check in daily to maintain streak
- Automatic badge awards at milestones
- Tracks current streak, longest streak, and total check-ins

### Live Impact Map
- Visualizes impact events globally using Leaflet/OpenStreetMap
- Click markers to see event details
- Color-coded by event type

### Impact Heatmap
- Shows activity intensity by location
- Circle size represents impact intensity
- Hover for detailed statistics

### ROI Calculator
- Calculate return on investment for events/projects/NGOs
- Shows direct and indirect impact
- Calculates cost per person helped

### Predictive Analytics
- AI-powered predictions for volunteer needs and donation trends
- Confidence scores for each prediction
- Valid for specified time periods

---

## 🔄 WebSocket Real-time Updates

The system uses WebSockets for real-time updates:

```javascript
// WebSocket connection (automatic in components)
ws://your-domain/ws/{user_id}

// Message types:
- counter_update: Live counter updates
- new_challenge: New challenge created
- challenge_completed: Challenge completed
- badge_earned: User earned a badge
- new_impact_event: New impact event for timeline
- new_donation: New donation for ticker
```

---

## 🎨 Frontend Components

All components are ready to use:

```javascript
// Gamification Components
import {
  Leaderboards,
  BadgesDisplay,
  ChallengesCard,
  StreaksWidget,
  CommunityScore
} from '../components/GamificationComponents';

// Real-time Components
import {
  LiveImpactCounter,
  InteractiveImpactMap,
  ImpactHeatmap,
  DonationTicker,
  ImpactTimeline
} from '../components/RealtimeComponents';

// Analytics Components
import {
  ROICalculator,
  PredictiveAnalytics,
  ComparativeAnalytics,
  ImpactMultiplier,
  SustainabilityMetrics,
  AnalyticsDashboard
} from '../components/AnalyticsComponents';
```

---

## 📦 Dependencies Installed

**Backend:**
- supabase-auth (for Supabase integration)

**Frontend:**
- leaflet (map visualization)
- react-leaflet (React wrapper for Leaflet)
- @types/leaflet (TypeScript definitions)
- recharts (already installed, used for charts)

---

## 🧪 Testing the Features

### 1. Test Badges System
```bash
curl http://localhost:8001/api/gamification/badges
```

### 2. Test Leaderboards
```bash
curl "http://localhost:8001/api/gamification/leaderboards?category=volunteer&metric_type=hours"
```

### 3. Test Live Counters
```bash
curl http://localhost:8001/api/realtime/counters
```

### 4. Create a Challenge (requires auth)
```bash
curl -X POST http://localhost:8001/api/gamification/challenges \
  -H "Content-Type: application/json" \
  -b "session_token=YOUR_TOKEN" \
  -d '{
    "title": "Plant 100 Trees",
    "description": "Let'\''s plant 100 trees this month!",
    "challenge_type": "sustainability",
    "target_value": 100,
    "unit": "trees",
    "start_date": "2025-01-20T00:00:00Z",
    "end_date": "2025-02-20T00:00:00Z"
  }'
```

### 5. Check in for Streak (requires auth)
```bash
curl -X POST http://localhost:8001/api/gamification/streaks/checkin \
  -b "session_token=YOUR_TOKEN"
```

---

## 🎯 Next Steps

1. **Execute the database schema** in Supabase
2. **Test the /impact-hub page** in your browser
3. **Create some test data**:
   - Volunteer for events to update leaderboards
   - Make donations to see donation ticker
   - Create challenges for users to join
4. **Monitor WebSocket connections** for real-time updates
5. **Customize** badges, challenges, and analytics as needed

---

## 🐛 Troubleshooting

**Maps not loading?**
- Check console for Leaflet errors
- Ensure internet connection for OpenStreetMap tiles

**WebSocket not connecting?**
- Verify WebSocket URL in components
- Check backend WebSocket endpoint: `ws://your-domain/ws/{user_id}`

**Badges not showing?**
- Verify database schema was executed
- Check if badges table has data

**Real-time updates not working?**
- Check WebSocket connection in browser console
- Verify backend is broadcasting events

---

## 📊 Performance Notes

- Maps and heatmaps load on-demand
- WebSocket connections are managed per user
- Leaderboard rankings update automatically via database triggers
- Live counters cache for 1 minute to reduce database load

---

## 🎨 Customization

### Add New Badges
```sql
INSERT INTO badges (badge_name, badge_description, badge_icon, badge_type, criteria, rarity, points)
VALUES ('Your Badge', 'Description', '🏅', 'custom', '{"requirement": "value"}'::jsonb, 'rare', 50);
```

### Add New Live Counters
```sql
INSERT INTO live_counters (counter_name, counter_value, counter_type)
VALUES ('custom_metric', 0, 'impact');
```

### Create Custom Challenges
Use the POST /api/gamification/challenges endpoint or create directly in database.

---

**All features are now ready to use! 🚀**

The Impact Hub provides a comprehensive view of gamification, real-time impact visualization, and advanced analytics. Users can compete on leaderboards, earn badges, join challenges, maintain streaks, and see their collective impact visualized on interactive maps with AI-powered insights.
