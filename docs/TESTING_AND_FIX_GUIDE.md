# 🧪 Complete Testing & Fix Guide - Seva-Setu

## 📋 CURRENT STATUS

Based on log analysis, here are all the issues found and their status:

| Issue | Status | Priority | Action Required |
|-------|--------|----------|-----------------|
| Image upload endpoint missing | ✅ FIXED | HIGH | Restart backend |
| Missing database tables (3) | 🔴 TODO | HIGH | Run SQL |
| Missing database columns (2) | 🔴 TODO | HIGH | Run SQL |
| Supabase storage bucket | 🔴 TODO | HIGH | Manual setup |
| Invalid JWT warnings | ℹ️ EXPECTED | LOW | None |
| Sessions table lookup | ℹ️ LEGACY | LOW | Code cleanup |

---

## 🚀 STEP-BY-STEP FIX PROCESS

### **Step 1: Stop Current Backend Server** ⏸️
```bash
# In the terminal running the backend
# Press Ctrl+C to stop
```

### **Step 2: Run Complete Database Fix** 🗄️
1. Go to **Supabase Dashboard**
2. Click **SQL Editor** in left sidebar
3. Click **New Query**
4. Open `COMPLETE_DATABASE_FIX.sql`
5. Copy ALL content
6. Paste in SQL Editor
7. Click **RUN**
8. ✅ You should see success messages

**Expected Output:**
```
=== TABLE VERIFICATION ===
✓ Table "users" exists
✓ Table "ngos" exists
✓ Table "posts" exists
... (all tables shown)
=== END VERIFICATION ===

DATABASE UPDATE COMPLETED SUCCESSFULLY!
```

### **Step 3: Create Supabase Storage Bucket** 📦
1. In Supabase Dashboard
2. Click **Storage** in left sidebar
3. Click **New bucket**
4. Name: `images`
5. **✅ Make it PUBLIC**
6. Click **Create bucket**

**Optional Settings:**
- File size limit: 5MB
- Allowed MIME types: `image/jpeg,image/png,image/gif,image/webp`

### **Step 4: Restart Backend Server** 🔄
```bash
cd backend
py server.py
```

**Expected Output:**
```
INFO:__main__:CORS Origins configured: ['http://localhost:3000', 'http://127.0.0.1:3000']
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8001
```

### **Step 5: Restart Frontend (if needed)** 🔄
```bash
cd frontend
npm start
```

---

## 🧪 SYSTEMATIC TESTING CHECKLIST

### **A. Authentication Tests** 🔐

- [ ] **Test 1: Register New User**
  - Navigate to `/` (landing page)
  - Click "Sign Up"
  - Fill in: Name, Email, Password
  - Click "Create Account"
  - ✅ Should redirect to Feed page
  - ✅ Should show user avatar (or initials) in navigation

- [ ] **Test 2: Login**
  - Logout if logged in
  - Click "Sign In"
  - Enter credentials
  - Click "Login"
  - ✅ Should redirect to Feed page
  - ✅ Should persist after page refresh

- [ ] **Test 3: Logout**
  - Click user avatar → "Logout"
  - ✅ Should redirect to landing page
  - ✅ Should not be able to access protected routes

### **B. Posts & Feed Tests** 📝

- [ ] **Test 4: View Feed**
  - Navigate to `/feed`
  - ✅ Should see posts (or empty state)
  - ✅ Should see upcoming events sidebar
  - ✅ No console errors

- [ ] **Test 5: Create Post (Text Only)**
  - In feed, type in "What's on your mind?"
  - Enter some text
  - Click "Post"
  - ✅ Post should appear immediately
  - ✅ Should show your avatar and name

- [ ] **Test 6: Create Post with Image**
  - In feed, type text
  - Click image upload icon
  - Select an image
  - ✅ Should upload successfully
  - Click "Post"
  - ✅ Post should appear with image
  - **Check backend logs for**: `INFO: Image upload error` (should NOT appear)

- [ ] **Test 7: Like Post**
  - Click heart icon on a post
  - ✅ Like count should increase
  - ✅ Heart should turn red/filled

### **C. Events Tests** 📅

- [ ] **Test 8: View Events**
  - Navigate to `/events`
  - ✅ Should see list of events
  - ✅ Should show event details (title, date, location)

- [ ] **Test 9: RSVP to Event**
  - Click "RSVP" on an event
  - ✅ Button should change to "Cancel RSVP"
  - ✅ Volunteer count should increase

- [ ] **Test 10: Create Event** (if you own an NGO)
  - Click "Create Event"
  - Fill in all fields
  - Click "Create"
  - ✅ Event should appear in list
  - **Check backend logs for**: No `registered_at does not exist` errors

### **D. NGO Tests** 🏢

- [ ] **Test 11: View NGO Directory**
  - Navigate to `/ngos`
  - ✅ Should see list of NGOs
  - ✅ Should show NGO cards with details

- [ ] **Test 12: View NGO Detail**
  - Click on an NGO card
  - ✅ Should navigate to NGO detail page
  - ✅ Should show NGO info, posts, events, team
  - **Check backend logs for**: No `ngo_team_members` errors

- [ ] **Test 13: Follow NGO**
  - On NGO detail page
  - Click "Follow" button
  - ✅ Button should change to "Unfollow"
  - ✅ Follower count should increase
  - **Check backend logs for**: No `Follow NGO error` messages

### **E. User Profile Tests** 👤

- [ ] **Test 14: View Own Profile**
  - Click user avatar → "My Profile"
  - ✅ Should show your profile info
  - ✅ Should show stats (posts, events, volunteer hours)
  - **Check backend logs for**: No `user_follows` or `volunteer_hours` errors

- [ ] **Test 15: Edit Profile**
  - Click "Edit Profile"
  - Change bio or other details
  - Click "Save"
  - ✅ Changes should persist after refresh

- [ ] **Test 16: Follow User**
  - Navigate to another user's profile
  - Click "Follow"
  - ✅ Should show "Unfollow" button
  - ✅ Follower/following counts should update

### **F. Donations Tests** 💰

- [ ] **Test 17: View Donation Packages**
  - Navigate to `/donations`
  - ✅ Should see donation package options
  - ✅ Should be able to select a package

- [ ] **Test 18: Initiate Donation** (Stripe required)
  - Select a donation amount
  - Click "Donate"
  - ⚠️ If Stripe not configured: Will show error
  - ✅ If configured: Should redirect to Stripe checkout

### **G. Impact & Analytics Tests** 📊

- [ ] **Test 19: View Impact Dashboard**
  - Navigate to `/impact`
  - ✅ Should load without errors
  - ✅ Should show impact metrics (or empty state)
  - **Check backend logs for**: No `invalid input syntax for type uuid: "undefined"` errors

---

## 🐛 KNOWN ISSUES & WORKAROUNDS

### Issue 1: "Invalid JWT token" warnings
**Status**: ℹ️ EXPECTED
**Impact**: None (these are expected when not logged in)
**Workaround**: None needed - can be ignored

### Issue 2: Presence duplicate key warnings
**Status**: ⚠️ NON-CRITICAL
**Impact**: Logged as warning but doesn't affect functionality
**Workaround**: Presence updates work via the new `update_user_presence()` function

### Issue 3: Stripe not configured
**Status**: ℹ️ OPTIONAL FEATURE
**Impact**: Donations won't work without Stripe API key
**Workaround**: Add `STRIPE_API_KEY` to `backend/.env` to enable

---

## 📊 ERROR MONITORING

### Where to Check for Errors

1. **Frontend Console** (Browser DevTools):
   - Press F12
   - Go to "Console" tab
   - Look for red errors

2. **Backend Logs** (Terminal):
   - Look for `ERROR:` lines
   - Look for HTTP 4xx/5xx status codes

3. **Network Tab** (Browser DevTools):
   - Go to "Network" tab
   - Filter by "Fetch/XHR"
   - Look for red requests (failed)

### Errors to Watch For

❌ **BAD** (These should NOT appear after fixes):
```
ERROR:__main__:Image upload error
ERROR:__main__:Get user activities error: {'message': 'column event_attendees.registered_at does not exist
ERROR:__main__:Get followers error: {'message': "Could not find the table 'public.user_follows
ERROR:__main__:Get NGO error: {'message': "Could not find the table 'public.ngo_team_members
ERROR:__main__:Follow NGO error: 'NoneType' object is not subscriptable
```

✅ **OK** (These are expected/normal):
```
WARNING:__main__:Invalid JWT token (when not logged in)
WARNING:__main__:Could not update presence (handled gracefully)
ERROR:__main__:Get unread count error (when not logged in)
```

---

## ✅ SUCCESS CRITERIA

### All tests pass if:

1. **Zero 404 errors** for `/api/upload/image`
2. **Zero 500 errors** for NGO detail pages
3. **Zero database schema errors** (missing tables/columns)
4. **Posts with images** upload successfully
5. **User profile** shows correct follower/following counts
6. **Events page** shows registered_at timestamps
7. **NGO following** works without errors
8. **Impact dashboard** loads without UUID errors

---

## 🎯 POST-FIX VERIFICATION

After completing all steps, run this checklist:

```markdown
✅ Backend server is running on port 8001
✅ Frontend is accessible at http://localhost:3000
✅ Can register/login successfully
✅ Can create posts with text
✅ Can upload images
✅ Can view NGOs without 500 errors
✅ Can click into NGO details
✅ Can follow/unfollow NGOs
✅ Can view user profiles with stats
✅ Can RSVP to events
✅ No red errors in browser console
✅ No ERROR lines in backend logs (except expected auth warnings)
```

---

## 📞 TROUBLESHOOTING

### Problem: Image upload still fails
**Check**:
1. Did you create the `images` bucket in Supabase Storage?
2. Is the bucket set to PUBLIC?
3. Did you restart the backend server?

### Problem: Still seeing database errors
**Check**:
1. Did you run `COMPLETE_DATABASE_FIX.sql` in Supabase SQL Editor?
2. Did you see the success message after running it?
3. Try refreshing the Supabase dashboard

### Problem: Cannot follow NGOs
**Check**:
1. Are you logged in?
2. Did the `user_follows` table get created?
3. Check browser console for specific error

### Problem: Frontend won't start
**Solution**:
```bash
cd frontend
npm install --legacy-peer-deps
npm start
```

---

## 📝 FINAL NOTES

- **All fixes are cumulative** - each step builds on the previous
- **Database fixes are permanent** - run SQL only once
- **Server restarts required** - after code changes
- **Storage bucket** - create only once (persists)

**Estimated Time to Complete**: 15-20 minutes

**After completion, your Seva-Setu platform will be 100% functional!** 🎉

