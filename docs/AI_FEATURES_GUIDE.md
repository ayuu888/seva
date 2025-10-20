# 🤖 AI-Powered Features Documentation

## Overview

Seva-Setu now includes 5 powerful AI features powered by Google's Gemini AI that enhance the volunteer matching, impact prediction, content discovery, and storytelling capabilities of the platform.

---

## 1. Smart Volunteer Matching 🎯

**Endpoint:** `POST /api/ai/volunteer-matching`

**Description:** AI analyzes volunteer profiles (skills, interests, location, bio) and matches them with event requirements to suggest the best-fit volunteers.

**Request:**
```json
{
  "event_id": "event-uuid"
}
```

**Response:**
```json
{
  "matches": [
    {
      "id": "volunteer-uuid",
      "name": "John Doe",
      "match_score": 95,
      "match_reason": "Strong skills in event management and local area knowledge",
      "skills": ["Event Planning", "Communication"],
      "interests": ["Community Service"],
      "location": "New York",
      "bio": "Passionate volunteer..."
    }
  ],
  "total_available": 50
}
```

**Features:**
- Ranks volunteers by compatibility (0-100 score)
- Considers skills, interests, location proximity
- Filters out volunteers who already applied
- Returns top 5 matches with reasons

**Frontend Integration:**
```jsx
import { VolunteerMatchingDialog } from '../components/AIComponents';

<VolunteerMatchingDialog 
  eventId={event.id}
  eventTitle={event.title}
  open={showMatching}
  onClose={() => setShowMatching(false)}
/>
```

---

## 2. Impact Prediction 📊

**Endpoint:** `POST /api/ai/impact-prediction`

**Description:** AI predicts event/project success probability based on team composition, volunteer-to-need ratio, and skill diversity.

**Request:**
```json
{
  "event_id": "event-uuid"
}
```

**Response:**
```json
{
  "prediction": {
    "success_probability": 85,
    "confidence": "high",
    "key_strengths": [
      "Diverse skill set among volunteers",
      "High volunteer-to-need ratio"
    ],
    "potential_risks": [
      "Limited experience in category",
      "Geographic spread of volunteers"
    ],
    "recommendations": [
      "Conduct pre-event training",
      "Set up clear communication channels",
      "Assign team leads by skill area"
    ]
  },
  "team_size": 25,
  "volunteers_needed": 20
}
```

**Features:**
- Success probability (0-100%)
- Confidence level (low/medium/high)
- Identifies team strengths and risks
- Provides actionable recommendations

**Frontend Integration:**
```jsx
import { ImpactPredictionCard } from '../components/AIComponents';

<ImpactPredictionCard 
  eventId={event.id}
  onPredictionReceived={(prediction) => console.log(prediction)}
/>
```

---

## 3. Smart Content Recommendations 🎯

**Endpoint:** `GET /api/ai/recommendations`

**Description:** AI-powered personalized content recommendations based on user interests, skills, and activity history.

**Query Parameters:**
- `type`: 'all' | 'posts' | 'events' | 'ngos' (default: 'all')
- `limit`: number (default: 10)

**Response:**
```json
{
  "posts": [...],
  "events": [...],
  "ngos": [...],
  "ai_reasoning": "Based on your interest in healthcare and event management skills, these opportunities align with your profile..."
}
```

**Features:**
- Analyzes user profile (skills, interests, location)
- Considers past activity (likes, RSVPs, follows)
- Filters out already-followed NGOs
- Provides explanation for recommendations

**Usage Example:**
```javascript
const fetchRecommendations = async () => {
  const response = await axios.get(`${API}/ai/recommendations?type=events&limit=5`);
  setRecommendedEvents(response.data.events);
};
```

---

## 4. Automated Impact Story Generation ✍️

**Endpoint:** `POST /api/ai/generate-impact-story`

**Description:** AI generates compelling impact stories from event or NGO data, including statistics and narrative.

**Request:**
```json
{
  "source_type": "event" | "ngo",
  "source_id": "uuid"
}
```

**Response:**
```json
{
  "title": "Transforming Lives: Community Food Drive Success",
  "content": "In the heart of downtown, 50 dedicated volunteers came together...",
  "key_stats": [
    {"label": "Volunteers", "value": "50+"},
    {"label": "Hours Contributed", "value": "200"},
    {"label": "Families Helped", "value": "150"}
  ],
  "call_to_action": "Join us in our next community service event!",
  "generated_at": "2025-01-09T...",
  "source_type": "event",
  "source_id": "event-uuid",
  "raw_data": {...}
}
```

**Features:**
- Generates engaging titles
- Creates 2-3 paragraph narratives
- Extracts and formats key statistics
- Includes call-to-action
- Works for both events and NGOs

**Frontend Integration:**
```jsx
import { ImpactStoryGenerator } from '../components/AIComponents';

<ImpactStoryGenerator 
  sourceType="event"
  sourceId={event.id}
  onStoryGenerated={(story) => {
    // Use generated story
    console.log(story.title, story.content);
  }}
/>
```

---

## 5. AI Smart Search 🔍

**Endpoint:** `POST /api/ai/smart-search`

**Description:** Semantic search that understands user intent and finds relevant content across posts, events, and NGOs.

**Request:**
```json
{
  "query": "volunteer opportunities for teaching children"
}
```

**Response:**
```json
{
  "query": "volunteer opportunities for teaching children",
  "intent": "User is looking for education-related volunteer opportunities involving children",
  "explanation": "Found events and NGOs focused on child education and tutoring programs",
  "results": {
    "posts": [...],
    "events": [...],
    "ngos": [...]
  }
}
```

**Features:**
- Understands natural language queries
- Identifies search intent
- Semantic matching beyond keyword search
- Returns top 5 results per category
- Provides explanation

**Usage Example:**
```javascript
const smartSearch = async (query) => {
  const response = await axios.post(`${API}/ai/smart-search`, { query });
  console.log('Intent:', response.data.intent);
  console.log('Results:', response.data.results);
};
```

---

## Integration Guide

### 1. Add AI Features to Event Page

```jsx
import { VolunteerMatchingDialog, ImpactPredictionCard } from '../components/AIComponents';

function EventDetail() {
  const [showMatching, setShowMatching] = useState(false);
  
  return (
    <>
      <Button onClick={() => setShowMatching(true)}>
        <Sparkles className="mr-2" />
        Find Best Volunteers
      </Button>
      
      <ImpactPredictionCard eventId={eventId} />
      
      <VolunteerMatchingDialog 
        eventId={eventId}
        eventTitle={event.title}
        open={showMatching}
        onClose={() => setShowMatching(false)}
      />
    </>
  );
}
```

### 2. Add Recommendations to Feed

```jsx
const [recommendations, setRecommendations] = useState([]);

useEffect(() => {
  const fetchRecs = async () => {
    const res = await axios.get(`${API}/ai/recommendations?type=all&limit=5`);
    setRecommendations(res.data);
  };
  fetchRecs();
}, []);

return (
  <div>
    <h3>Recommended for You</h3>
    {recommendations.events?.map(event => <EventCard event={event} />)}
  </div>
);
```

### 3. Add Impact Story to NGO Profile

```jsx
import { ImpactStoryGenerator } from '../components/AIComponents';

function NGOProfile() {
  return (
    <ImpactStoryGenerator 
      sourceType="ngo"
      sourceId={ngoId}
      onStoryGenerated={(story) => {
        // Auto-post to social feed
        createPost({ content: story.content });
      }}
    />
  );
}
```

---

## Configuration

The AI features use Google's Gemini AI. Ensure your `.env` file has:

```bash
GEMINI_API_KEY=your-gemini-api-key
```

Get your API key from: https://makersuite.google.com/app/apikey

---

## Error Handling

All AI endpoints include fallback logic:

1. **Volunteer Matching**: Falls back to showing all available volunteers
2. **Impact Prediction**: Provides basic prediction based on registration ratio
3. **Recommendations**: Falls back to popular content
4. **Story Generation**: Creates simple template-based story
5. **Smart Search**: Falls back to basic text search

---

## Performance Notes

- AI requests typically take 2-5 seconds
- Results are cached where applicable
- Rate limits apply (depends on Gemini API tier)
- Consider adding loading states in UI

---

## Testing

Test AI features:

```bash
# Volunteer Matching
curl -X POST http://localhost:8001/api/ai/volunteer-matching \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"event_id": "EVENT_ID"}'

# Impact Prediction
curl -X POST http://localhost:8001/api/ai/impact-prediction \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"event_id": "EVENT_ID"}'

# Recommendations
curl -X GET "http://localhost:8001/api/ai/recommendations?type=all&limit=5" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Story Generation
curl -X POST http://localhost:8001/api/ai/generate-impact-story \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"source_type": "event", "source_id": "EVENT_ID"}'

# Smart Search
curl -X POST http://localhost:8001/api/ai/smart-search \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"query": "healthcare volunteer opportunities"}'
```

---

## Future Enhancements

Potential AI feature expansions:
- Sentiment analysis on feedback
- Automated report generation
- Chatbot for volunteer queries
- Image recognition for impact photos
- Predictive analytics for donation trends
- Personalized volunteer paths

---

## Support

For issues or questions about AI features:
1. Check backend logs: `tail -f /var/log/supervisor/backend.err.log`
2. Verify Gemini API key is valid
3. Check API rate limits
4. Review fallback behavior in code

---

**Last Updated:** January 2025
**AI Model:** Google Gemini Pro
**Version:** 1.0
