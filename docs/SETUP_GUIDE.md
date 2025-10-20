# Seva-Setu Setup Guide

## 🚀 Quick Start

### 1. Backend Setup

1. **Install Python dependencies:**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

2. **Set up environment variables:**
   Create a `.env` file in the `backend/` directory:
   ```bash
   # MongoDB Configuration
   MONGO_URL=mongodb://localhost:27017
   DB_NAME=seva_setu

   # JWT Configuration
   JWT_SECRET=your-secret-key-change-in-production
   JWT_ALGORITHM=HS256
   JWT_EXPIRATION_DAYS=7

   # Stripe Configuration
   STRIPE_API_KEY=your-stripe-secret-key

   # CORS Configuration (IMPORTANT!)
   CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
   ```

3. **Start the backend server:**
   ```bash
   cd backend
   python server.py
   # or
   uvicorn server:app --reload --host 0.0.0.0 --port 8000
   ```

### 2. Frontend Setup

1. **Install dependencies:**
   ```bash
   cd frontend
   npm install
   ```

2. **Set up environment variables:**
   Create a `.env` file in the `frontend/` directory:
   ```bash
   # Backend API URL
   REACT_APP_BACKEND_URL=http://localhost:8000
   ```

3. **Start the frontend:**
   ```bash
   cd frontend
   npm start
   ```

### 3. Database Setup

1. **Install MongoDB** (if running locally)
2. **Seed the database:**
   ```bash
   cd backend
   python seed.py
   ```

## 🔧 CORS Configuration Fix

The main issue was that the backend was configured with `allow_credentials=True` but using wildcard origins (`*`), which browsers don't allow.

### ✅ Fixed Configuration:
- **Specific Origins**: Only allows configured origins instead of wildcard
- **Proper Headers**: Explicitly lists allowed headers
- **Credentials Support**: Maintains cookie and authorization header support
- **Environment-Based**: Uses `CORS_ORIGINS` environment variable for flexibility

### 🌐 Environment Variables:
- **Development**: `CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000`
- **Production**: `CORS_ORIGINS=https://yourdomain.com`

## 🧪 Testing

### Test Backend Connection:
```bash
python test_backend_connection.py
```

### Test Authentication Flow:
1. Open `http://localhost:3000`
2. Try to register/login
3. Check browser network tab for successful API calls
4. Verify protected routes work

## 🐛 Troubleshooting

### CORS Errors:
- ✅ **Fixed**: Specific origins instead of wildcard
- ✅ **Fixed**: Proper credential handling
- ✅ **Added**: Health check endpoint at `/health`

### Authentication Issues:
- ✅ **Fixed**: Axios interceptor adds Bearer tokens
- ✅ **Fixed**: Session management with cookies
- ✅ **Added**: Google OAuth support

### Common Issues:
1. **Backend not running**: Check if server is running on port 8000
2. **MongoDB connection**: Ensure MongoDB is running and accessible
3. **Environment variables**: Verify `.env` files are in correct locations
4. **Port conflicts**: Make sure ports 3000 (frontend) and 8000 (backend) are available

## 📝 API Endpoints

### Health Check:
- `GET /health` - Server health status

### Authentication:
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/session` - Google OAuth session
- `GET /api/auth/me` - Get current user
- `POST /api/auth/logout` - Logout

### Core Features:
- `GET /api/posts` - Get posts feed
- `POST /api/posts` - Create post
- `GET /api/events` - Get events
- `POST /api/events` - Create event
- `GET /api/ngos` - Get NGOs
- `POST /api/ngos` - Create NGO

## 🎯 Next Steps

1. **Start the backend server**
2. **Start the frontend development server**
3. **Test the connection** using the test script
4. **Verify authentication flow** works end-to-end
5. **Test core features** like creating posts and events

The CORS configuration has been fixed and should now allow the frontend to properly communicate with the backend API!
