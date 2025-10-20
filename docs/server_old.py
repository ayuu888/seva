from fastapi import FastAPI, APIRouter, HTTPException, Request, Response, Cookie, Depends, UploadFile, File, Form
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field, ConfigDict, EmailStr
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime, timezone, timedelta
import bcrypt
import jwt
import httpx
import base64
from emergentintegrations.payments.stripe.checkout import StripeCheckout, CheckoutSessionResponse, CheckoutStatusResponse, CheckoutSessionRequest

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection
mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ['DB_NAME']]

# JWT Configuration
JWT_SECRET = os.environ.get('JWT_SECRET', 'seva-setu-secret-key-change-in-production')
JWT_ALGORITHM = 'HS256'
JWT_EXPIRATION_DAYS = 7

# Stripe Configuration
STRIPE_API_KEY = os.environ['STRIPE_API_KEY']

# Create the main app without a prefix
app = FastAPI()

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")

# Authentication Models
class UserRegister(BaseModel):
    name: str
    email: str
    password: str
    user_type: str = "volunteer"  # volunteer, ngo, donor

class UserLogin(BaseModel):
    email: str
    password: str

class User(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    email: str
    user_type: str
    bio: Optional[str] = None
    avatar: Optional[str] = None
    cover_photo: Optional[str] = None
    phone: Optional[str] = None
    website: Optional[str] = None
    location: Optional[str] = None
    social_links: Dict[str, str] = {}  # linkedin, twitter, instagram, github
    skills: List[str] = []
    interests: List[str] = []
    followers_count: int = 0
    following_count: int = 0
    is_private: bool = False
    email_notifications: bool = True
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class Session(BaseModel):
    model_config = ConfigDict(extra="ignore")
    session_token: str
    user_id: str
    email: str
    expires_at: datetime

# NGO Models
class NGO(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    description: str
    category: str  # education, health, environment, etc.
    founded_year: Optional[int] = None
    website: Optional[str] = None
    logo: Optional[str] = None
    cover_image: Optional[str] = None
    gallery: List[str] = []  # Photo gallery
    location: Optional[str] = None
    owner_id: str
    team_members: List[Dict[str, str]] = []  # [{user_id, name, role, avatar}]
    followers_count: int = 0
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: Optional[datetime] = None

class NGOCreate(BaseModel):
    name: str
    description: str
    category: str
    founded_year: Optional[int] = None
    website: Optional[str] = None
    location: Optional[str] = None

class NGOUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    founded_year: Optional[int] = None
    website: Optional[str] = None
    logo: Optional[str] = None
    cover_image: Optional[str] = None
    gallery: Optional[List[str]] = None
    location: Optional[str] = None

class NGOTeamMember(BaseModel):
    user_id: str
    role: str = "member"  # owner, admin, member

# Post Models
class Post(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    author_id: str
    author_name: str
    author_avatar: Optional[str] = None
    author_type: str = "user"  # user or ngo
    content: str
    images: List[str] = []  # Multiple images support
    poll: Optional[Dict[str, Any]] = None  # Poll data: {question, options: [{text, votes}]}
    likes_count: int = 0
    comments_count: int = 0
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: Optional[datetime] = None

class PostCreate(BaseModel):
    content: str
    images: List[str] = []
    poll: Optional[Dict[str, Any]] = None

class PostUpdate(BaseModel):
    content: Optional[str] = None
    images: Optional[List[str]] = None

class Comment(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    post_id: str
    author_id: str
    author_name: str
    author_avatar: Optional[str] = None
    content: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class CommentCreate(BaseModel):
    content: str

# Event Models
class Event(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    ngo_id: str
    ngo_name: str
    title: str
    description: str
    location: str
    location_details: Optional[Dict[str, str]] = {}  # address, city, state, zip
    theme: Optional[str] = None
    date: datetime
    end_date: Optional[datetime] = None
    images: List[str] = []  # Multiple images/gallery
    volunteers_needed: int = 0
    volunteers_registered: int = 0
    category: str = "general"
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: Optional[datetime] = None

class EventCreate(BaseModel):
    title: str
    description: str
    location: str
    location_details: Optional[Dict[str, str]] = {}
    theme: Optional[str] = None
    date: str  # ISO format
    end_date: Optional[str] = None
    images: List[str] = []
    volunteers_needed: int = 10
    category: str = "general"

class EventUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None
    location_details: Optional[Dict[str, str]] = None
    theme: Optional[str] = None
    date: Optional[str] = None
    end_date: Optional[str] = None
    images: Optional[List[str]] = None
    volunteers_needed: Optional[int] = None
    category: Optional[str] = None

class EventRSVP(BaseModel):
    model_config = ConfigDict(extra="ignore")
    event_id: str
    user_id: str
    user_name: str
    status: str = "registered"  # registered, attended, cancelled
    checked_in: bool = False
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

# Follow Models
class Follow(BaseModel):
    model_config = ConfigDict(extra="ignore")
    follower_id: str  # user who follows
    following_id: str  # user/ngo being followed
    following_type: str  # "user" or "ngo"
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

# Activity Models
class Activity(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    user_id: str
    activity_type: str  # post_created, event_joined, donation_made, ngo_followed
    title: str
    description: str
    metadata: Dict[str, Any] = {}
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

# Poll Vote Model
class PollVote(BaseModel):
    model_config = ConfigDict(extra="ignore")
    post_id: str
    user_id: str
    option_index: int
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

# Password Change Model
class PasswordChange(BaseModel):
    current_password: str
    new_password: str

# Image Upload Response
class ImageUploadResponse(BaseModel):
    url: str
    filename: str

# Donation Models
class DonationPackage(BaseModel):
    id: str
    name: str
    amount: float
    description: str

class DonationRequest(BaseModel):
    package_id: str
    origin_url: str
    ngo_id: Optional[str] = None

class PaymentTransaction(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    session_id: str
    user_id: Optional[str] = None
    ngo_id: Optional[str] = None
    amount: float
    currency: str
    payment_status: str  # pending, completed, failed
    metadata: Dict = {}
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

# Donation Packages
DONATION_PACKAGES = {
    "small": {"amount": 10.0, "name": "Small Support", "description": "Help with basic supplies"},
    "medium": {"amount": 50.0, "name": "Medium Support", "description": "Support a program for a month"},
    "large": {"amount": 100.0, "name": "Large Support", "description": "Fund a major initiative"},
}

# Authentication Helper Functions
def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

def create_jwt_token(user_id: str, email: str) -> str:
    payload = {
        'user_id': user_id,
        'email': email,
        'exp': datetime.now(timezone.utc) + timedelta(days=JWT_EXPIRATION_DAYS)
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

def verify_jwt_token(token: str) -> Optional[Dict]:
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

async def get_current_user(request: Request, session_token: Optional[str] = Cookie(None)) -> Optional[User]:
    """Get current user from session token (cookie or header)"""
    token = session_token
    
    # Fallback to Authorization header
    if not token:
        auth_header = request.headers.get('Authorization')
        if auth_header and auth_header.startswith('Bearer '):
            token = auth_header.split(' ')[1]
    
    if not token:
        return None
    
    # Check session in database
    session = await db.sessions.find_one({"session_token": token}, {"_id": 0})
    if not session:
        return None
    
    # Check if session is expired
    expires_at = datetime.fromisoformat(session['expires_at']) if isinstance(session['expires_at'], str) else session['expires_at']
    if expires_at < datetime.now(timezone.utc):
        await db.sessions.delete_one({"session_token": token})
        return None
    
    # Get user
    user = await db.users.find_one({"id": session['user_id']}, {"_id": 0, "password": 0})
    if not user:
        return None
    
    return User(**user)

# Authentication Routes
@api_router.post("/auth/register")
async def register(user: UserRegister):
    # Check if user exists
    existing_user = await db.users.find_one({"email": user.email})
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Create user
    user_data = {
        "id": str(uuid.uuid4()),
        "name": user.name,
        "email": user.email,
        "password": hash_password(user.password),
        "user_type": user.user_type,
        "bio": "",
        "avatar": f"https://api.dicebear.com/7.x/initials/svg?seed={user.name}",
        "cover_photo": None,
        "phone": None,
        "website": None,
        "location": None,
        "social_links": {},
        "skills": [],
        "interests": [],
        "followers_count": 0,
        "following_count": 0,
        "is_private": False,
        "email_notifications": True,
        "created_at": datetime.now(timezone.utc).isoformat()
    }
    
    await db.users.insert_one(user_data)
    
    # Create JWT token
    token = create_jwt_token(user_data['id'], user_data['email'])
    
    # Create session in database
    session = {
        "session_token": token,
        "user_id": user_data['id'],
        "email": user_data['email'],
        "expires_at": (datetime.now(timezone.utc) + timedelta(days=7)).isoformat()
    }
    await db.sessions.insert_one(session)
    
    # Remove password and MongoDB _id from response
    user_data.pop('password')
    user_data.pop('_id', None)
    
    return {"user": user_data, "token": token}

@api_router.post("/auth/login")
async def login(credentials: UserLogin):
    # Find user
    user = await db.users.find_one({"email": credentials.email})
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    # Verify password
    if not verify_password(credentials.password, user['password']):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    # Create JWT token
    token = create_jwt_token(user['id'], user['email'])
    
    # Create session in database
    session = {
        "session_token": token,
        "user_id": user['id'],
        "email": user['email'],
        "expires_at": (datetime.now(timezone.utc) + timedelta(days=7)).isoformat()
    }
    await db.sessions.update_one(
        {"session_token": token},
        {"$set": session},
        upsert=True
    )
    
    # Remove password from response
    user.pop('_id', None)
    user.pop('password')
    
    return {"user": user, "token": token}

@api_router.post("/auth/session")
async def process_google_session(request: Request, response: Response):
    """Process Google OAuth session from Emergent Auth"""
    body = await request.json()
    session_id = body.get('session_id')
    
    if not session_id:
        raise HTTPException(status_code=400, detail="Missing session_id")
    
    # Get user data from Emergent Auth
    async with httpx.AsyncClient() as client:
        try:
            auth_response = await client.get(
                "https://demobackend.emergentagent.com/auth/v1/env/oauth/session-data",
                headers={"X-Session-ID": session_id}
            )
            auth_response.raise_for_status()
            user_data = auth_response.json()
        except Exception as e:
            raise HTTPException(status_code=401, detail=f"Failed to verify session: {str(e)}")
    
    # Check if user exists
    user = await db.users.find_one({"email": user_data['email']})
    
    if not user:
        # Create new user
        user = {
            "id": str(uuid.uuid4()),
            "name": user_data['name'],
            "email": user_data['email'],
            "user_type": "volunteer",
            "bio": "",
            "avatar": user_data.get('picture', f"https://api.dicebear.com/7.x/initials/svg?seed={user_data['name']}"),
            "cover_photo": None,
            "phone": None,
            "website": None,
            "location": None,
            "social_links": {},
            "skills": [],
            "interests": [],
            "followers_count": 0,
            "following_count": 0,
            "is_private": False,
            "email_notifications": True,
            "created_at": datetime.now(timezone.utc).isoformat()
        }
        await db.users.insert_one(user)
    
    # Create session
    session_token = user_data['session_token']
    session = {
        "session_token": session_token,
        "user_id": user['id'],
        "email": user['email'],
        "expires_at": (datetime.now(timezone.utc) + timedelta(days=7)).isoformat()
    }
    await db.sessions.update_one(
        {"session_token": session_token},
        {"$set": session},
        upsert=True
    )
    
    # Set cookie
    response.set_cookie(
        key="session_token",
        value=session_token,
        httponly=True,
        secure=True,
        samesite="none",
        max_age=7 * 24 * 60 * 60,
        path="/"
    )
    
    # Remove MongoDB _id and password
    user.pop('_id', None)
    user.pop('password', None)
    
    return {"user": user, "session_token": session_token}

@api_router.post("/auth/logout")
async def logout(response: Response, session_token: Optional[str] = Cookie(None)):
    if session_token:
        await db.sessions.delete_one({"session_token": session_token})
        response.delete_cookie(key="session_token", path="/")
    return {"message": "Logged out successfully"}

@api_router.get("/auth/me")
async def get_me(request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    return user

# Post Routes
@api_router.post("/posts", response_model=Post)
async def create_post(post: PostCreate, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Initialize poll with vote counts if provided
    poll_data = None
    if post.poll:
        options = post.poll.get('options', [])
        poll_data = {
            "question": post.poll.get('question', ''),
            "options": [{"text": opt, "votes": 0} for opt in options]
        }
    
    post_data = {
        "id": str(uuid.uuid4()),
        "author_id": user.id,
        "author_name": user.name,
        "author_avatar": user.avatar,
        "author_type": "user",
        "content": post.content,
        "images": post.images,
        "poll": poll_data,
        "likes_count": 0,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "updated_at": None
    }
    
    await db.posts.insert_one(post_data)
    
    # Create activity
    await db.activities.insert_one({
        "id": str(uuid.uuid4()),
        "user_id": user.id,
        "activity_type": "post_created",
        "title": "Created a post",
        "description": post.content[:100],
        "metadata": {"post_id": post_data['id']},
        "created_at": datetime.now(timezone.utc).isoformat()
    })
    
    return Post(**post_data)

@api_router.get("/posts", response_model=List[Post])
async def get_posts(limit: int = 50):
    posts = await db.posts.find({}, {"_id": 0}).sort("created_at", -1).to_list(limit)
    for post in posts:
        if isinstance(post.get('created_at'), str):
            post['created_at'] = datetime.fromisoformat(post['created_at'])
    return posts

@api_router.post("/posts/{post_id}/like")
async def like_post(post_id: str, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if already liked
    existing_like = await db.likes.find_one({"post_id": post_id, "user_id": user.id})
    
    if existing_like:
        # Unlike
        await db.likes.delete_one({"post_id": post_id, "user_id": user.id})
        await db.posts.update_one({"id": post_id}, {"$inc": {"likes_count": -1}})
        return {"liked": False}
    else:
        # Like
        await db.likes.insert_one({"post_id": post_id, "user_id": user.id, "created_at": datetime.now(timezone.utc).isoformat()})
        await db.posts.update_one({"id": post_id}, {"$inc": {"likes_count": 1}})
        return {"liked": True}

@api_router.post("/posts/{post_id}/comments", response_model=Comment)
async def create_comment(post_id: str, comment: CommentCreate, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    comment_data = {
        "id": str(uuid.uuid4()),
        "post_id": post_id,
        "author_id": user.id,
        "author_name": user.name,
        "author_avatar": user.avatar,
        "content": comment.content,
        "created_at": datetime.now(timezone.utc).isoformat()
    }
    
    await db.comments.insert_one(comment_data)
    await db.posts.update_one({"id": post_id}, {"$inc": {"comments_count": 1}})
    
    return Comment(**comment_data)

@api_router.get("/posts/{post_id}/comments", response_model=List[Comment])
async def get_comments(post_id: str):
    comments = await db.comments.find({"post_id": post_id}, {"_id": 0}).sort("created_at", 1).to_list(100)
    for comment in comments:
        if isinstance(comment.get('created_at'), str):
            comment['created_at'] = datetime.fromisoformat(comment['created_at'])
    return comments

@api_router.patch("/posts/{post_id}", response_model=Post)
async def update_post(post_id: str, post_update: PostUpdate, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if user owns the post
    post = await db.posts.find_one({"id": post_id}, {"_id": 0})
    if not post or post['author_id'] != user.id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this post")
    
    update_data = {k: v for k, v in post_update.model_dump().items() if v is not None}
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")
    
    update_data['updated_at'] = datetime.now(timezone.utc).isoformat()
    
    await db.posts.update_one({"id": post_id}, {"$set": update_data})
    updated_post = await db.posts.find_one({"id": post_id}, {"_id": 0})
    
    if isinstance(updated_post.get('created_at'), str):
        updated_post['created_at'] = datetime.fromisoformat(updated_post['created_at'])
    if updated_post.get('updated_at') and isinstance(updated_post.get('updated_at'), str):
        updated_post['updated_at'] = datetime.fromisoformat(updated_post['updated_at'])
    
    return Post(**updated_post)

@api_router.delete("/posts/{post_id}")
async def delete_post(post_id: str, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if user owns the post
    post = await db.posts.find_one({"id": post_id}, {"_id": 0})
    if not post or post['author_id'] != user.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this post")
    
    # Delete post and related data
    await db.posts.delete_one({"id": post_id})
    await db.likes.delete_many({"post_id": post_id})
    await db.comments.delete_many({"post_id": post_id})
    await db.poll_votes.delete_many({"post_id": post_id})
    
    return {"message": "Post deleted successfully"}

@api_router.post("/posts/{post_id}/poll/vote")
async def vote_on_poll(post_id: str, option_index: int, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if post exists and has poll
    post = await db.posts.find_one({"id": post_id}, {"_id": 0})
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    
    if not post.get('poll'):
        raise HTTPException(status_code=400, detail="This post doesn't have a poll")
    
    # Check if user already voted
    existing_vote = await db.poll_votes.find_one({"post_id": post_id, "user_id": user.id})
    if existing_vote:
        # Remove old vote
        old_option = existing_vote['option_index']
        await db.posts.update_one(
            {"id": post_id},
            {"$inc": {f"poll.options.{old_option}.votes": -1}}
        )
        await db.poll_votes.delete_one({"post_id": post_id, "user_id": user.id})
    
    # Add new vote
    await db.poll_votes.insert_one({
        "post_id": post_id,
        "user_id": user.id,
        "option_index": option_index,
        "created_at": datetime.now(timezone.utc).isoformat()
    })
    
    await db.posts.update_one(
        {"id": post_id},
        {"$inc": {f"poll.options.{option_index}.votes": 1}}
    )
    
    # Return updated post
    updated_post = await db.posts.find_one({"id": post_id}, {"_id": 0})
    if isinstance(updated_post.get('created_at'), str):
        updated_post['created_at'] = datetime.fromisoformat(updated_post['created_at'])
    
    return Post(**updated_post)

# Event Routes
@api_router.post("/events", response_model=Event)
async def create_event(event: EventCreate, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Get user's NGO (simplified - in production, check if user owns an NGO)
    ngo = await db.ngos.find_one({"owner_id": user.id}, {"_id": 0})
    if not ngo:
        raise HTTPException(status_code=403, detail="You must be an NGO owner to create events")
    
    event_data = {
        "id": str(uuid.uuid4()),
        "ngo_id": ngo['id'],
        "ngo_name": ngo['name'],
        "title": event.title,
        "description": event.description,
        "location": event.location,
        "location_details": event.location_details,
        "theme": event.theme,
        "date": datetime.fromisoformat(event.date.replace('Z', '+00:00')).isoformat(),
        "end_date": datetime.fromisoformat(event.end_date.replace('Z', '+00:00')).isoformat() if event.end_date else None,
        "images": event.images,
        "volunteers_needed": event.volunteers_needed,
        "volunteers_registered": 0,
        "category": event.category,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "updated_at": None
    }
    
    await db.events.insert_one(event_data)
    
    # Create activity
    await db.activities.insert_one({
        "id": str(uuid.uuid4()),
        "user_id": user.id,
        "activity_type": "event_created",
        "title": f"Created event: {event.title}",
        "description": event.description[:100],
        "metadata": {"event_id": event_data['id'], "ngo_id": ngo['id']},
        "created_at": datetime.now(timezone.utc).isoformat()
    })
    
    return Event(**event_data)

@api_router.get("/events", response_model=List[Event])
async def get_events(limit: int = 50):
    events = await db.events.find({}, {"_id": 0}).sort("date", 1).to_list(limit)
    for event in events:
        if isinstance(event.get('created_at'), str):
            event['created_at'] = datetime.fromisoformat(event['created_at'])
        if isinstance(event.get('date'), str):
            event['date'] = datetime.fromisoformat(event['date'])
        if event.get('end_date') and isinstance(event.get('end_date'), str):
            event['end_date'] = datetime.fromisoformat(event['end_date'])
    return events

@api_router.post("/events/{event_id}/rsvp")
async def rsvp_event(event_id: str, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if already registered
    existing_rsvp = await db.event_rsvps.find_one({"event_id": event_id, "user_id": user.id})
    
    if existing_rsvp:
        # Cancel RSVP
        await db.event_rsvps.delete_one({"event_id": event_id, "user_id": user.id})
        await db.events.update_one({"id": event_id}, {"$inc": {"volunteers_registered": -1}})
        return {"registered": False}
    else:
        # Register
        rsvp_data = {
            "event_id": event_id,
            "user_id": user.id,
            "user_name": user.name,
            "status": "registered",
            "checked_in": False,
            "created_at": datetime.now(timezone.utc).isoformat()
        }
        await db.event_rsvps.insert_one(rsvp_data)
        await db.events.update_one({"id": event_id}, {"$inc": {"volunteers_registered": 1}})
        
        # Create activity
        event = await db.events.find_one({"id": event_id}, {"_id": 0})
        await db.activities.insert_one({
            "id": str(uuid.uuid4()),
            "user_id": user.id,
            "activity_type": "event_joined",
            "title": f"Registered for event: {event.get('title', '')}",
            "description": f"Joined the event at {event.get('location', '')}",
            "metadata": {"event_id": event_id},
            "created_at": datetime.now(timezone.utc).isoformat()
        })
        
        return {"registered": True}

@api_router.post("/events/{event_id}/checkin")
async def checkin_event(event_id: str, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if registered
    rsvp = await db.event_rsvps.find_one({"event_id": event_id, "user_id": user.id})
    if not rsvp:
        raise HTTPException(status_code=400, detail="You must register for the event first")
    
    # Check in
    await db.event_rsvps.update_one(
        {"event_id": event_id, "user_id": user.id},
        {"$set": {"checked_in": True, "status": "attended"}}
    )
    
    return {"checked_in": True}

@api_router.patch("/events/{event_id}", response_model=Event)
async def update_event(event_id: str, event_update: EventUpdate, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if user owns the NGO that created the event
    event = await db.events.find_one({"id": event_id}, {"_id": 0})
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    
    ngo = await db.ngos.find_one({"id": event['ngo_id']}, {"_id": 0})
    if not ngo or ngo['owner_id'] != user.id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this event")
    
    update_data = {k: v for k, v in event_update.model_dump().items() if v is not None}
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")
    
    # Handle date conversions
    if 'date' in update_data:
        update_data['date'] = datetime.fromisoformat(update_data['date'].replace('Z', '+00:00')).isoformat()
    if 'end_date' in update_data and update_data['end_date']:
        update_data['end_date'] = datetime.fromisoformat(update_data['end_date'].replace('Z', '+00:00')).isoformat()
    
    update_data['updated_at'] = datetime.now(timezone.utc).isoformat()
    
    await db.events.update_one({"id": event_id}, {"$set": update_data})
    updated_event = await db.events.find_one({"id": event_id}, {"_id": 0})
    
    if isinstance(updated_event.get('created_at'), str):
        updated_event['created_at'] = datetime.fromisoformat(updated_event['created_at'])
    if isinstance(updated_event.get('date'), str):
        updated_event['date'] = datetime.fromisoformat(updated_event['date'])
    if updated_event.get('end_date') and isinstance(updated_event.get('end_date'), str):
        updated_event['end_date'] = datetime.fromisoformat(updated_event['end_date'])
    if updated_event.get('updated_at') and isinstance(updated_event.get('updated_at'), str):
        updated_event['updated_at'] = datetime.fromisoformat(updated_event['updated_at'])
    
    return Event(**updated_event)

@api_router.delete("/events/{event_id}")
async def delete_event(event_id: str, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if user owns the NGO that created the event
    event = await db.events.find_one({"id": event_id}, {"_id": 0})
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    
    ngo = await db.ngos.find_one({"id": event['ngo_id']}, {"_id": 0})
    if not ngo or ngo['owner_id'] != user.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this event")
    
    # Delete event and related data
    await db.events.delete_one({"id": event_id})
    await db.event_rsvps.delete_many({"event_id": event_id})
    
    return {"message": "Event deleted successfully"}

@api_router.get("/events/{event_id}/attendees")
async def get_event_attendees(event_id: str):
    attendees = await db.event_rsvps.find({"event_id": event_id}, {"_id": 0}).to_list(1000)
    return attendees

# NGO Routes
@api_router.post("/ngos", response_model=NGO)
async def create_ngo(ngo: NGOCreate, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    ngo_data = {
        "id": str(uuid.uuid4()),
        "name": ngo.name,
        "description": ngo.description,
        "category": ngo.category,
        "founded_year": ngo.founded_year,
        "website": ngo.website,
        "logo": f"https://api.dicebear.com/7.x/initials/svg?seed={ngo.name}",
        "cover_image": "https://images.unsplash.com/photo-1560220604-1985ebfe28b1?q=85&w=1200",
        "gallery": [],
        "location": ngo.location,
        "owner_id": user.id,
        "team_members": [{
            "user_id": user.id,
            "name": user.name,
            "role": "owner",
            "avatar": user.avatar
        }],
        "followers_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "updated_at": None
    }
    
    await db.ngos.insert_one(ngo_data)
    
    # Create activity
    await db.activities.insert_one({
        "id": str(uuid.uuid4()),
        "user_id": user.id,
        "activity_type": "ngo_created",
        "title": f"Created NGO: {ngo.name}",
        "description": ngo.description[:100],
        "metadata": {"ngo_id": ngo_data['id']},
        "created_at": datetime.now(timezone.utc).isoformat()
    })
    
    return NGO(**ngo_data)

@api_router.get("/ngos", response_model=List[NGO])
async def get_ngos(limit: int = 50):
    ngos = await db.ngos.find({}, {"_id": 0}).sort("created_at", -1).to_list(limit)
    for ngo in ngos:
        if isinstance(ngo.get('created_at'), str):
            ngo['created_at'] = datetime.fromisoformat(ngo['created_at'])
    return ngos

@api_router.get("/ngos/{ngo_id}", response_model=NGO)
async def get_ngo(ngo_id: str):
    ngo = await db.ngos.find_one({"id": ngo_id}, {"_id": 0})
    if not ngo:
        raise HTTPException(status_code=404, detail="NGO not found")
    if isinstance(ngo.get('created_at'), str):
        ngo['created_at'] = datetime.fromisoformat(ngo['created_at'])
    if ngo.get('updated_at') and isinstance(ngo.get('updated_at'), str):
        ngo['updated_at'] = datetime.fromisoformat(ngo['updated_at'])
    return NGO(**ngo)

@api_router.patch("/ngos/{ngo_id}", response_model=NGO)
async def update_ngo(ngo_id: str, ngo_update: NGOUpdate, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if user owns the NGO
    ngo = await db.ngos.find_one({"id": ngo_id}, {"_id": 0})
    if not ngo or ngo['owner_id'] != user.id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this NGO")
    
    update_data = {k: v for k, v in ngo_update.model_dump().items() if v is not None}
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")
    
    update_data['updated_at'] = datetime.now(timezone.utc).isoformat()
    
    await db.ngos.update_one({"id": ngo_id}, {"$set": update_data})
    updated_ngo = await db.ngos.find_one({"id": ngo_id}, {"_id": 0})
    
    if isinstance(updated_ngo.get('created_at'), str):
        updated_ngo['created_at'] = datetime.fromisoformat(updated_ngo['created_at'])
    if updated_ngo.get('updated_at') and isinstance(updated_ngo.get('updated_at'), str):
        updated_ngo['updated_at'] = datetime.fromisoformat(updated_ngo['updated_at'])
    
    return NGO(**updated_ngo)

@api_router.post("/ngos/{ngo_id}/team")
async def add_team_member(ngo_id: str, member: NGOTeamMember, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if user owns the NGO
    ngo = await db.ngos.find_one({"id": ngo_id}, {"_id": 0})
    if not ngo or ngo['owner_id'] != user.id:
        raise HTTPException(status_code=403, detail="Not authorized to manage this NGO")
    
    # Get member user info
    member_user = await db.users.find_one({"id": member.user_id}, {"_id": 0, "password": 0})
    if not member_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Check if already a member
    existing_members = ngo.get('team_members', [])
    if any(m['user_id'] == member.user_id for m in existing_members):
        raise HTTPException(status_code=400, detail="User is already a team member")
    
    # Add team member
    new_member = {
        "user_id": member.user_id,
        "name": member_user['name'],
        "role": member.role,
        "avatar": member_user.get('avatar')
    }
    
    await db.ngos.update_one(
        {"id": ngo_id},
        {"$push": {"team_members": new_member}}
    )
    
    return {"message": "Team member added successfully", "member": new_member}

@api_router.delete("/ngos/{ngo_id}/team/{user_id}")
async def remove_team_member(ngo_id: str, user_id: str, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if user owns the NGO
    ngo = await db.ngos.find_one({"id": ngo_id}, {"_id": 0})
    if not ngo or ngo['owner_id'] != user.id:
        raise HTTPException(status_code=403, detail="Not authorized to manage this NGO")
    
    # Cannot remove owner
    if user_id == ngo['owner_id']:
        raise HTTPException(status_code=400, detail="Cannot remove the owner")
    
    # Remove team member
    await db.ngos.update_one(
        {"id": ngo_id},
        {"$pull": {"team_members": {"user_id": user_id}}}
    )
    
    return {"message": "Team member removed successfully"}

@api_router.post("/ngos/{ngo_id}/follow")
async def follow_ngo(ngo_id: str, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Check if NGO exists
    ngo = await db.ngos.find_one({"id": ngo_id}, {"_id": 0})
    if not ngo:
        raise HTTPException(status_code=404, detail="NGO not found")
    
    # Check if already following
    existing_follow = await db.follows.find_one({
        "follower_id": user.id,
        "following_id": ngo_id,
        "following_type": "ngo"
    })
    
    if existing_follow:
        # Unfollow
        await db.follows.delete_one({
            "follower_id": user.id,
            "following_id": ngo_id,
            "following_type": "ngo"
        })
        await db.ngos.update_one({"id": ngo_id}, {"$inc": {"followers_count": -1}})
        return {"following": False}
    else:
        # Follow
        await db.follows.insert_one({
            "follower_id": user.id,
            "following_id": ngo_id,
            "following_type": "ngo",
            "created_at": datetime.now(timezone.utc).isoformat()
        })
        await db.ngos.update_one({"id": ngo_id}, {"$inc": {"followers_count": 1}})
        
        # Create activity
        await db.activities.insert_one({
            "id": str(uuid.uuid4()),
            "user_id": user.id,
            "activity_type": "ngo_followed",
            "title": f"Followed {ngo['name']}",
            "description": f"Started following {ngo['name']}",
            "metadata": {"ngo_id": ngo_id},
            "created_at": datetime.now(timezone.utc).isoformat()
        })
        
        return {"following": True}

# Donation Routes
@api_router.get("/donations/packages")
async def get_donation_packages():
    return [
        DonationPackage(id=key, **value)
        for key, value in DONATION_PACKAGES.items()
    ]

@api_router.post("/donations/checkout")
async def create_donation_checkout(donation: DonationRequest, request: Request):
    # Validate package
    if donation.package_id not in DONATION_PACKAGES:
        raise HTTPException(status_code=400, detail="Invalid donation package")
    
    # Get amount from server-side definition
    package = DONATION_PACKAGES[donation.package_id]
    amount = package['amount']
    
    # Create Stripe checkout
    host_url = str(request.base_url)
    webhook_url = f"{host_url}api/webhook/stripe"
    stripe_checkout = StripeCheckout(api_key=STRIPE_API_KEY, webhook_url=webhook_url)
    
    # Build success/cancel URLs
    success_url = f"{donation.origin_url}/donation-success?session_id={{CHECKOUT_SESSION_ID}}"
    cancel_url = f"{donation.origin_url}/donations"
    
    # Create checkout session
    checkout_request = CheckoutSessionRequest(
        amount=amount,
        currency="usd",
        success_url=success_url,
        cancel_url=cancel_url,
        metadata={
            "package_id": donation.package_id,
            "package_name": package['name'],
            "ngo_id": donation.ngo_id or ""
        }
    )
    
    session = await stripe_checkout.create_checkout_session(checkout_request)
    
    # Store transaction
    transaction = {
        "id": str(uuid.uuid4()),
        "session_id": session.session_id,
        "user_id": None,  # Will be updated after payment
        "ngo_id": donation.ngo_id,
        "amount": amount,
        "currency": "usd",
        "payment_status": "pending",
        "metadata": checkout_request.metadata,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "updated_at": datetime.now(timezone.utc).isoformat()
    }
    await db.payment_transactions.insert_one(transaction)
    
    return {"url": session.url, "session_id": session.session_id}

@api_router.get("/donations/status/{session_id}")
async def get_donation_status(session_id: str):
    # Get status from Stripe
    stripe_checkout = StripeCheckout(api_key=STRIPE_API_KEY, webhook_url="")
    status = await stripe_checkout.get_checkout_status(session_id)
    
    # Update transaction if completed
    if status.payment_status == "paid":
        existing = await db.payment_transactions.find_one({"session_id": session_id, "payment_status": "completed"})
        if not existing:
            await db.payment_transactions.update_one(
                {"session_id": session_id},
                {
                    "$set": {
                        "payment_status": "completed",
                        "updated_at": datetime.now(timezone.utc).isoformat()
                    }
                }
            )
    
    return status

@api_router.post("/webhook/stripe")
async def stripe_webhook(request: Request):
    body_bytes = await request.body()
    signature = request.headers.get("Stripe-Signature")
    
    stripe_checkout = StripeCheckout(api_key=STRIPE_API_KEY, webhook_url="")
    webhook_response = await stripe_checkout.handle_webhook(body_bytes, signature)
    
    # Update transaction based on webhook
    if webhook_response.payment_status == "paid":
        await db.payment_transactions.update_one(
            {"session_id": webhook_response.session_id},
            {
                "$set": {
                    "payment_status": "completed",
                    "updated_at": datetime.now(timezone.utc).isoformat()
                }
            }
        )
    
    return {"status": "success"}

# User Profile Routes
@api_router.get("/users/{user_id}")
async def get_user_profile(user_id: str):
    user = await db.users.find_one({"id": user_id}, {"_id": 0, "password": 0})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    bio: Optional[str] = None
    avatar: Optional[str] = None
    cover_photo: Optional[str] = None
    phone: Optional[str] = None
    website: Optional[str] = None
    location: Optional[str] = None
    social_links: Optional[Dict[str, str]] = None
    skills: Optional[List[str]] = None
    interests: Optional[List[str]] = None
    is_private: Optional[bool] = None
    email_notifications: Optional[bool] = None

@api_router.patch("/users/{user_id}")
async def update_user_profile(user_id: str, profile: UserProfileUpdate, request: Request, session_token: Optional[str] = Cookie(None)):
    current_user = await get_current_user(request, session_token)
    if not current_user or current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized to update this profile")
    
    # Build update dict with only provided fields
    update_data = {k: v for k, v in profile.model_dump().items() if v is not None}
    
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")
    
    # Update user
    result = await db.users.update_one(
        {"id": user_id},
        {"$set": update_data}
    )
    
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Return updated user
    updated_user = await db.users.find_one({"id": user_id}, {"_id": 0, "password": 0})
    return updated_user

@api_router.get("/users/{user_id}/stats")
async def get_user_stats(user_id: str):
    # Get user stats
    posts_count = await db.posts.count_documents({"author_id": user_id})
    events_registered = await db.event_rsvps.count_documents({"user_id": user_id})
    donations = await db.payment_transactions.find({"user_id": user_id, "payment_status": "completed"}, {"_id": 0}).to_list(1000)
    total_donated = sum(d.get('amount', 0) for d in donations)
    
    return {
        "posts_count": posts_count,
        "events_registered": events_registered,
        "total_donated": total_donated,
        "volunteer_hours": events_registered * 4  # Estimate 4 hours per event
    }

@api_router.get("/users/{user_id}/posts")
async def get_user_posts(user_id: str, limit: int = 20):
    posts = await db.posts.find({"author_id": user_id}, {"_id": 0}).sort("created_at", -1).to_list(limit)
    for post in posts:
        if isinstance(post.get('created_at'), str):
            post['created_at'] = datetime.fromisoformat(post['created_at'])
    return posts

@api_router.post("/users/{user_id}/follow")
async def follow_user(user_id: str, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    if user.id == user_id:
        raise HTTPException(status_code=400, detail="Cannot follow yourself")
    
    # Check if target user exists
    target_user = await db.users.find_one({"id": user_id}, {"_id": 0, "password": 0})
    if not target_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Check if already following
    existing_follow = await db.follows.find_one({
        "follower_id": user.id,
        "following_id": user_id,
        "following_type": "user"
    })
    
    if existing_follow:
        # Unfollow
        await db.follows.delete_one({
            "follower_id": user.id,
            "following_id": user_id,
            "following_type": "user"
        })
        await db.users.update_one({"id": user_id}, {"$inc": {"followers_count": -1}})
        await db.users.update_one({"id": user.id}, {"$inc": {"following_count": -1}})
        return {"following": False}
    else:
        # Follow
        await db.follows.insert_one({
            "follower_id": user.id,
            "following_id": user_id,
            "following_type": "user",
            "created_at": datetime.now(timezone.utc).isoformat()
        })
        await db.users.update_one({"id": user_id}, {"$inc": {"followers_count": 1}})
        await db.users.update_one({"id": user.id}, {"$inc": {"following_count": 1}})
        
        # Create activity
        await db.activities.insert_one({
            "id": str(uuid.uuid4()),
            "user_id": user.id,
            "activity_type": "user_followed",
            "title": f"Followed {target_user['name']}",
            "description": f"Started following {target_user['name']}",
            "metadata": {"user_id": user_id},
            "created_at": datetime.now(timezone.utc).isoformat()
        })
        
        return {"following": True}

@api_router.get("/users/{user_id}/followers")
async def get_user_followers(user_id: str, limit: int = 50):
    # Get follower IDs
    follows = await db.follows.find({
        "following_id": user_id,
        "following_type": "user"
    }, {"_id": 0}).to_list(limit)
    
    follower_ids = [f['follower_id'] for f in follows]
    
    # Get user details
    followers = await db.users.find(
        {"id": {"$in": follower_ids}},
        {"_id": 0, "password": 0, "email": 0}
    ).to_list(limit)
    
    return followers

@api_router.get("/users/{user_id}/following")
async def get_user_following(user_id: str, limit: int = 50):
    # Get following IDs
    follows = await db.follows.find({
        "follower_id": user_id
    }, {"_id": 0}).to_list(limit)
    
    # Separate users and NGOs
    user_ids = [f['following_id'] for f in follows if f['following_type'] == 'user']
    ngo_ids = [f['following_id'] for f in follows if f['following_type'] == 'ngo']
    
    # Get details
    following_users = await db.users.find(
        {"id": {"$in": user_ids}},
        {"_id": 0, "password": 0, "email": 0}
    ).to_list(limit)
    
    following_ngos = await db.ngos.find(
        {"id": {"$in": ngo_ids}},
        {"_id": 0}
    ).to_list(limit)
    
    return {
        "users": following_users,
        "ngos": following_ngos
    }

@api_router.get("/users/{user_id}/activities")
async def get_user_activities(user_id: str, limit: int = 50):
    activities = await db.activities.find(
        {"user_id": user_id},
        {"_id": 0}
    ).sort("created_at", -1).to_list(limit)
    
    for activity in activities:
        if isinstance(activity.get('created_at'), str):
            activity['created_at'] = datetime.fromisoformat(activity['created_at'])
    
    return activities

@api_router.post("/users/change-password")
async def change_password(password_change: PasswordChange, request: Request, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Get user with password
    user_with_password = await db.users.find_one({"id": user.id}, {"_id": 0})
    if not user_with_password:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Verify current password
    if not verify_password(password_change.current_password, user_with_password['password']):
        raise HTTPException(status_code=400, detail="Current password is incorrect")
    
    # Update password
    new_hashed_password = hash_password(password_change.new_password)
    await db.users.update_one(
        {"id": user.id},
        {"$set": {"password": new_hashed_password}}
    )
    
    return {"message": "Password changed successfully"}

@api_router.post("/upload/image")
async def upload_image(file: UploadFile = File(...), request: Request = None, session_token: Optional[str] = Cookie(None)):
    user = await get_current_user(request, session_token)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Read file content
    content = await file.read()
    
    # Convert to base64 data URL
    file_extension = file.filename.split('.')[-1].lower()
    mime_type = f"image/{file_extension}"
    if file_extension == 'jpg':
        mime_type = "image/jpeg"
    
    base64_data = base64.b64encode(content).decode('utf-8')
    data_url = f"data:{mime_type};base64,{base64_data}"
    
    return ImageUploadResponse(url=data_url, filename=file.filename)

# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "Seva-Setu API is running"}

# Include the router in the main app
app.include_router(api_router)

# CORS Configuration - Handle credentials properly
cors_origins = os.environ.get('CORS_ORIGINS', 'http://localhost:3000,http://127.0.0.1:3000')
cors_origins_list = [origin.strip() for origin in cors_origins.split(',')]

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Log CORS configuration for debugging
logger.info(f"CORS Origins configured: {cors_origins_list}")

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=cors_origins_list,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=[
        "Accept",
        "Accept-Language",
        "Content-Language",
        "Content-Type",
        "Authorization",
        "X-Requested-With",
        "Origin",
        "Access-Control-Request-Method",
        "Access-Control-Request-Headers",
    ],
)

@app.on_event("shutdown")
async def shutdown_db_client():
    client.close()
