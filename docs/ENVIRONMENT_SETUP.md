# 🔧 Environment Setup Guide

## **CRITICAL: Required Environment Variables**

### **Backend Environment (.env)**
Create `backend/.env` with these variables:

```bash
# Database Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Alternative: MongoDB (if not using Supabase)
MONGO_URL=mongodb://localhost:27017
DB_NAME=seva_setu

# Authentication
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_ALGORITHM=HS256
JWT_EXPIRATION_DAYS=7

# Payment Processing
STRIPE_API_KEY=sk_test_your-stripe-secret-key

# AI Features (Optional)
GEMINI_API_KEY=your-google-gemini-api-key

# CORS Configuration
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
```

### **Frontend Environment (.env)**
Create `frontend/.env` with:

```bash
# Backend API URL
REACT_APP_BACKEND_URL=http://localhost:8000
```

## **Database Setup Options**

### **Option 1: Supabase (Recommended)**
1. Create a Supabase project at https://supabase.com
2. Get your project URL and service role key
3. Run the migration scripts:
   ```bash
   cd backend
   python setup_supabase.py
   python create_tables.py
   ```

### **Option 2: MongoDB (Fallback)**
1. Install MongoDB locally
2. Update server.py to use MongoDB instead of Supabase
3. Run the seed script:
   ```bash
   cd backend
   python seed.py
   ```

## **Quick Start Commands**

```bash
# 1. Install backend dependencies
cd backend
pip install -r requirements.txt

# 2. Install frontend dependencies
cd ../frontend
npm install

# 3. Start backend (in one terminal)
cd backend
python server.py

# 4. Start frontend (in another terminal)
cd frontend
npm start
```

## **Verification Steps**

1. **Backend Health Check**: Visit http://localhost:8000/health
2. **Frontend Loading**: Visit http://localhost:3000
3. **API Connection**: Check browser console for CORS errors

## **Common Issues & Solutions**

### **Issue: "SUPABASE_URL not found"**
**Solution**: Create `backend/.env` file with proper Supabase credentials

### **Issue: "Cannot resolve '@/App'"**
**Solution**: ✅ Fixed - Updated import paths in index.js

### **Issue: "Stripe API key missing"**
**Solution**: Get Stripe test key from https://dashboard.stripe.com/test/apikeys

### **Issue: "Gemini API key missing"**
**Solution**: Get API key from https://makersuite.google.com/app/apikey (optional)

## **Production Deployment Notes**

- Change `JWT_SECRET` to a strong, random secret
- Use production Stripe keys
- Set proper CORS origins for your domain
- Use environment-specific database URLs
