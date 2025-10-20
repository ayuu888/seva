#!/usr/bin/env python3
"""
Comprehensive Backend Testing for Seva Setu Platform
Tests all newly implemented features including user profiles, follow system, 
posts with polls, NGO management, and event enhancements.
"""

import requests
import json
import base64
import io
from datetime import datetime, timezone
import uuid

# Configuration
BASE_URL = "https://ui-phase-update.preview.emergentagent.com/api"
TEST_USER_1 = {
    "name": "Arjun Sharma",
    "email": f"arjun.test.{uuid.uuid4().hex[:8]}@example.com",
    "password": "SecurePass123!",
    "user_type": "volunteer"
}
TEST_USER_2 = {
    "name": "Priya Patel", 
    "email": f"priya.test.{uuid.uuid4().hex[:8]}@example.com",
    "password": "SecurePass456!",
    "user_type": "volunteer"
}

class SevaSetuTester:
    def __init__(self):
        self.session = requests.Session()
        self.user1_token = None
        self.user1_id = None
        self.user2_token = None
        self.user2_id = None
        self.test_ngo_id = None
        self.test_event_id = None
        self.test_post_id = None
        self.results = []

    def log_result(self, test_name, success, message="", details=None):
        """Log test results"""
        status = "✅ PASS" if success else "❌ FAIL"
        self.results.append({
            "test": test_name,
            "status": status,
            "message": message,
            "details": details
        })
        print(f"{status}: {test_name} - {message}")

    def register_and_login_users(self):
        """Register and login test users"""
        print("\n=== User Registration & Authentication ===")
        
        # Register User 1
        try:
            response = self.session.post(f"{BASE_URL}/auth/register", json=TEST_USER_1)
            if response.status_code == 200:
                data = response.json()
                self.user1_token = data["token"]
                self.user1_id = data["user"]["id"]
                self.log_result("User 1 Registration", True, f"Registered user: {TEST_USER_1['name']}")
            else:
                self.log_result("User 1 Registration", False, f"Status: {response.status_code}, Response: {response.text}")
                return False
        except Exception as e:
            self.log_result("User 1 Registration", False, f"Exception: {str(e)}")
            return False

        # Register User 2
        try:
            response = self.session.post(f"{BASE_URL}/auth/register", json=TEST_USER_2)
            if response.status_code == 200:
                data = response.json()
                self.user2_token = data["token"]
                self.user2_id = data["user"]["id"]
                self.log_result("User 2 Registration", True, f"Registered user: {TEST_USER_2['name']}")
            else:
                self.log_result("User 2 Registration", False, f"Status: {response.status_code}, Response: {response.text}")
                return False
        except Exception as e:
            self.log_result("User 2 Registration", False, f"Exception: {str(e)}")
            return False

        return True

    def test_user_profile_enhancements(self):
        """Test user profile update with new fields"""
        print("\n=== User Profile Enhancements ===")
        
        headers = {"Authorization": f"Bearer {self.user1_token}"}
        profile_update = {
            "bio": "Passionate volunteer working for social causes",
            "phone": "+91-9876543210",
            "website": "https://arjunsharma.dev",
            "location": "Mumbai, Maharashtra",
            "social_links": {
                "linkedin": "https://linkedin.com/in/arjunsharma",
                "twitter": "https://twitter.com/arjunsharma",
                "instagram": "https://instagram.com/arjunsharma"
            },
            "skills": ["Community Outreach", "Event Management", "Social Media"],
            "interests": ["Education", "Environment", "Healthcare"],
            "is_private": False,
            "email_notifications": True
        }
        
        try:
            response = self.session.patch(f"{BASE_URL}/users/{self.user1_id}", 
                                        json=profile_update, headers=headers)
            if response.status_code == 200:
                data = response.json()
                # Verify all fields were updated
                success = (
                    data.get("bio") == profile_update["bio"] and
                    data.get("phone") == profile_update["phone"] and
                    data.get("website") == profile_update["website"] and
                    data.get("location") == profile_update["location"] and
                    data.get("social_links") == profile_update["social_links"] and
                    data.get("skills") == profile_update["skills"] and
                    data.get("interests") == profile_update["interests"] and
                    data.get("is_private") == profile_update["is_private"] and
                    data.get("email_notifications") == profile_update["email_notifications"]
                )
                self.log_result("Profile Update", success, 
                              "All profile fields updated successfully" if success else "Some fields not updated correctly",
                              data)
            else:
                self.log_result("Profile Update", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Profile Update", False, f"Exception: {str(e)}")

    def test_password_change(self):
        """Test password change functionality"""
        print("\n=== Password Change ===")
        
        headers = {"Authorization": f"Bearer {self.user1_token}"}
        password_change = {
            "current_password": TEST_USER_1["password"],
            "new_password": "NewSecurePass789!"
        }
        
        try:
            response = self.session.post(f"{BASE_URL}/users/change-password", 
                                       json=password_change, headers=headers)
            if response.status_code == 200:
                self.log_result("Password Change", True, "Password changed successfully")
                # Update password for future tests
                TEST_USER_1["password"] = password_change["new_password"]
            else:
                self.log_result("Password Change", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Password Change", False, f"Exception: {str(e)}")

    def test_follow_unfollow_users(self):
        """Test follow/unfollow user functionality"""
        print("\n=== Follow/Unfollow Users ===")
        
        headers = {"Authorization": f"Bearer {self.user1_token}"}
        
        # Test follow user
        try:
            response = self.session.post(f"{BASE_URL}/users/{self.user2_id}/follow", headers=headers)
            if response.status_code == 200:
                data = response.json()
                if data.get("following") == True:
                    self.log_result("Follow User", True, f"Successfully followed user {self.user2_id}")
                else:
                    self.log_result("Follow User", False, "Follow response incorrect")
            else:
                self.log_result("Follow User", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Follow User", False, f"Exception: {str(e)}")

        # Test get followers
        try:
            response = self.session.get(f"{BASE_URL}/users/{self.user2_id}/followers")
            if response.status_code == 200:
                followers = response.json()
                if any(f["id"] == self.user1_id for f in followers):
                    self.log_result("Get Followers", True, f"Found {len(followers)} followers")
                else:
                    self.log_result("Get Followers", False, "Follower not found in list")
            else:
                self.log_result("Get Followers", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Get Followers", False, f"Exception: {str(e)}")

        # Test get following
        try:
            response = self.session.get(f"{BASE_URL}/users/{self.user1_id}/following")
            if response.status_code == 200:
                following = response.json()
                users_following = following.get("users", [])
                if any(u["id"] == self.user2_id for u in users_following):
                    self.log_result("Get Following", True, f"Following {len(users_following)} users")
                else:
                    self.log_result("Get Following", False, "Following user not found in list")
            else:
                self.log_result("Get Following", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Get Following", False, f"Exception: {str(e)}")

        # Test unfollow user
        try:
            response = self.session.post(f"{BASE_URL}/users/{self.user2_id}/follow", headers=headers)
            if response.status_code == 200:
                data = response.json()
                if data.get("following") == False:
                    self.log_result("Unfollow User", True, f"Successfully unfollowed user {self.user2_id}")
                else:
                    self.log_result("Unfollow User", False, "Unfollow response incorrect")
            else:
                self.log_result("Unfollow User", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Unfollow User", False, f"Exception: {str(e)}")

    def test_activity_timeline(self):
        """Test activity timeline retrieval"""
        print("\n=== Activity Timeline ===")
        
        try:
            response = self.session.get(f"{BASE_URL}/users/{self.user1_id}/activities")
            if response.status_code == 200:
                activities = response.json()
                self.log_result("Activity Timeline", True, f"Retrieved {len(activities)} activities")
            else:
                self.log_result("Activity Timeline", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Activity Timeline", False, f"Exception: {str(e)}")

    def test_image_upload(self):
        """Test image upload functionality"""
        print("\n=== Image Upload ===")
        
        headers = {"Authorization": f"Bearer {self.user1_token}"}
        
        # Create a simple test image (1x1 pixel PNG)
        test_image_data = base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==")
        
        try:
            files = {"file": ("test_image.png", io.BytesIO(test_image_data), "image/png")}
            response = self.session.post(f"{BASE_URL}/upload/image", files=files, headers=headers)
            if response.status_code == 200:
                data = response.json()
                if data.get("url") and data.get("url").startswith("data:image"):
                    self.log_result("Image Upload", True, f"Image uploaded successfully: {data.get('filename')}")
                    return data.get("url")  # Return for use in other tests
                else:
                    self.log_result("Image Upload", False, "Invalid image URL format")
            else:
                self.log_result("Image Upload", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Image Upload", False, f"Exception: {str(e)}")
        
        return None

    def test_multiple_image_posts(self):
        """Test creating posts with multiple images"""
        print("\n=== Multiple Image Posts ===")
        
        headers = {"Authorization": f"Bearer {self.user1_token}"}
        
        # Get test image URL
        test_image_url = self.test_image_upload()
        if not test_image_url:
            test_image_url = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
        
        post_data = {
            "content": "Check out these amazing photos from our recent community service event! 📸 #CommunityService #Volunteering",
            "images": [test_image_url, test_image_url]  # Multiple images
        }
        
        try:
            response = self.session.post(f"{BASE_URL}/posts", json=post_data, headers=headers)
            if response.status_code == 200:
                data = response.json()
                if len(data.get("images", [])) == 2:
                    self.test_post_id = data.get("id")
                    self.log_result("Multiple Image Post", True, f"Created post with {len(data['images'])} images")
                else:
                    self.log_result("Multiple Image Post", False, "Images not saved correctly")
            else:
                self.log_result("Multiple Image Post", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Multiple Image Post", False, f"Exception: {str(e)}")

    def test_poll_feature(self):
        """Test poll creation and voting"""
        print("\n=== Poll Feature ===")
        
        headers = {"Authorization": f"Bearer {self.user1_token}"}
        
        # Create post with poll
        poll_data = {
            "content": "What's the most important area for NGO focus in 2024? 🤔",
            "poll": {
                "question": "Which cause should we prioritize?",
                "options": ["Education", "Healthcare", "Environment", "Poverty Alleviation"]
            }
        }
        
        try:
            response = self.session.post(f"{BASE_URL}/posts", json=poll_data, headers=headers)
            if response.status_code == 200:
                data = response.json()
                poll_post_id = data.get("id")
                if data.get("poll") and data["poll"].get("question"):
                    self.log_result("Poll Creation", True, f"Created poll with {len(data['poll']['options'])} options")
                    
                    # Test voting on poll
                    try:
                        vote_response = self.session.post(f"{BASE_URL}/posts/{poll_post_id}/poll/vote?option_index=0", 
                                                        headers=headers)
                        if vote_response.status_code == 200:
                            vote_data = vote_response.json()
                            if vote_data.get("poll") and vote_data["poll"]["options"][0]["votes"] == 1:
                                self.log_result("Poll Voting", True, "Successfully voted on poll")
                                
                                # Test changing vote
                                change_vote_response = self.session.post(f"{BASE_URL}/posts/{poll_post_id}/poll/vote?option_index=1", 
                                                                       headers=headers)
                                if change_vote_response.status_code == 200:
                                    change_data = change_vote_response.json()
                                    if (change_data["poll"]["options"][0]["votes"] == 0 and 
                                        change_data["poll"]["options"][1]["votes"] == 1):
                                        self.log_result("Poll Vote Change", True, "Successfully changed vote")
                                    else:
                                        self.log_result("Poll Vote Change", False, "Vote counts not updated correctly")
                                else:
                                    self.log_result("Poll Vote Change", False, f"Status: {change_vote_response.status_code}")
                            else:
                                self.log_result("Poll Voting", False, "Vote count not updated")
                        else:
                            self.log_result("Poll Voting", False, f"Status: {vote_response.status_code}")
                    except Exception as e:
                        self.log_result("Poll Voting", False, f"Exception: {str(e)}")
                else:
                    self.log_result("Poll Creation", False, "Poll data not saved correctly")
            else:
                self.log_result("Poll Creation", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Poll Creation", False, f"Exception: {str(e)}")

    def test_edit_delete_posts(self):
        """Test post editing and deletion"""
        print("\n=== Edit/Delete Posts ===")
        
        headers = {"Authorization": f"Bearer {self.user1_token}"}
        
        if not self.test_post_id:
            self.log_result("Edit Post", False, "No test post available")
            return
        
        # Test edit post
        edit_data = {
            "content": "Updated: Check out these amazing photos from our recent community service event! 📸 #CommunityService #Volunteering #Updated"
        }
        
        try:
            response = self.session.patch(f"{BASE_URL}/posts/{self.test_post_id}", 
                                        json=edit_data, headers=headers)
            if response.status_code == 200:
                data = response.json()
                if "Updated:" in data.get("content", ""):
                    self.log_result("Edit Post", True, "Post content updated successfully")
                else:
                    self.log_result("Edit Post", False, "Post content not updated")
            else:
                self.log_result("Edit Post", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Edit Post", False, f"Exception: {str(e)}")

        # Test delete post
        try:
            response = self.session.delete(f"{BASE_URL}/posts/{self.test_post_id}", headers=headers)
            if response.status_code == 200:
                self.log_result("Delete Post", True, "Post deleted successfully")
            else:
                self.log_result("Delete Post", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Delete Post", False, f"Exception: {str(e)}")

    def test_ngo_management(self):
        """Test NGO creation, updates, and team management"""
        print("\n=== NGO Management ===")
        
        headers = {"Authorization": f"Bearer {self.user1_token}"}
        
        # Create NGO
        ngo_data = {
            "name": "Green Earth Foundation",
            "description": "Dedicated to environmental conservation and sustainable development initiatives across India.",
            "category": "environment",
            "founded_year": 2020,
            "website": "https://greenearthfoundation.org",
            "location": "Delhi, India"
        }
        
        try:
            response = self.session.post(f"{BASE_URL}/ngos", json=ngo_data, headers=headers)
            if response.status_code == 200:
                data = response.json()
                self.test_ngo_id = data.get("id")
                self.log_result("NGO Creation", True, f"Created NGO: {data.get('name')}")
                
                # Test NGO update
                update_data = {
                    "description": "Updated: Dedicated to environmental conservation and sustainable development initiatives across India and neighboring countries.",
                    "gallery": ["https://example.com/photo1.jpg", "https://example.com/photo2.jpg"]
                }
                
                try:
                    update_response = self.session.patch(f"{BASE_URL}/ngos/{self.test_ngo_id}", 
                                                       json=update_data, headers=headers)
                    if update_response.status_code == 200:
                        update_result = update_response.json()
                        if "Updated:" in update_result.get("description", ""):
                            self.log_result("NGO Update", True, "NGO details updated successfully")
                        else:
                            self.log_result("NGO Update", False, "NGO description not updated")
                    else:
                        self.log_result("NGO Update", False, f"Status: {update_response.status_code}")
                except Exception as e:
                    self.log_result("NGO Update", False, f"Exception: {str(e)}")
                
                # Test add team member
                team_member_data = {
                    "user_id": self.user2_id,
                    "role": "admin"
                }
                
                try:
                    team_response = self.session.post(f"{BASE_URL}/ngos/{self.test_ngo_id}/team", 
                                                    json=team_member_data, headers=headers)
                    if team_response.status_code == 200:
                        self.log_result("Add Team Member", True, f"Added team member with role: {team_member_data['role']}")
                        
                        # Test remove team member
                        try:
                            remove_response = self.session.delete(f"{BASE_URL}/ngos/{self.test_ngo_id}/team/{self.user2_id}", 
                                                                headers=headers)
                            if remove_response.status_code == 200:
                                self.log_result("Remove Team Member", True, "Team member removed successfully")
                            else:
                                self.log_result("Remove Team Member", False, f"Status: {remove_response.status_code}")
                        except Exception as e:
                            self.log_result("Remove Team Member", False, f"Exception: {str(e)}")
                    else:
                        self.log_result("Add Team Member", False, f"Status: {team_response.status_code}")
                except Exception as e:
                    self.log_result("Add Team Member", False, f"Exception: {str(e)}")
                
                # Test follow NGO
                try:
                    follow_response = self.session.post(f"{BASE_URL}/ngos/{self.test_ngo_id}/follow", 
                                                      headers={"Authorization": f"Bearer {self.user2_token}"})
                    if follow_response.status_code == 200:
                        follow_data = follow_response.json()
                        if follow_data.get("following") == True:
                            self.log_result("Follow NGO", True, "Successfully followed NGO")
                        else:
                            self.log_result("Follow NGO", False, "Follow response incorrect")
                    else:
                        self.log_result("Follow NGO", False, f"Status: {follow_response.status_code}")
                except Exception as e:
                    self.log_result("Follow NGO", False, f"Exception: {str(e)}")
                    
            else:
                self.log_result("NGO Creation", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("NGO Creation", False, f"Exception: {str(e)}")

    def test_event_management(self):
        """Test event creation, updates, and check-in"""
        print("\n=== Event Management ===")
        
        headers = {"Authorization": f"Bearer {self.user1_token}"}
        
        if not self.test_ngo_id:
            self.log_result("Event Creation", False, "No NGO available for event creation")
            return
        
        # Create event
        event_data = {
            "title": "Tree Plantation Drive 2024",
            "description": "Join us for a massive tree plantation drive to make our city greener and combat climate change.",
            "location": "Central Park, Mumbai",
            "location_details": {
                "address": "Central Park, Bandra West",
                "city": "Mumbai",
                "state": "Maharashtra",
                "zip": "400050"
            },
            "theme": "Environmental Conservation",
            "date": "2024-03-15T09:00:00Z",
            "end_date": "2024-03-15T17:00:00Z",
            "images": ["https://example.com/event1.jpg", "https://example.com/event2.jpg"],
            "volunteers_needed": 50,
            "category": "environment"
        }
        
        try:
            response = self.session.post(f"{BASE_URL}/events", json=event_data, headers=headers)
            if response.status_code == 200:
                data = response.json()
                self.test_event_id = data.get("id")
                self.log_result("Event Creation", True, f"Created event: {data.get('title')}")
                
                # Test event update
                update_data = {
                    "description": "Updated: Join us for a massive tree plantation drive to make our city greener and combat climate change. Refreshments provided!",
                    "volunteers_needed": 75
                }
                
                try:
                    update_response = self.session.patch(f"{BASE_URL}/events/{self.test_event_id}", 
                                                       json=update_data, headers=headers)
                    if update_response.status_code == 200:
                        update_result = update_response.json()
                        if "Updated:" in update_result.get("description", ""):
                            self.log_result("Event Update", True, "Event details updated successfully")
                        else:
                            self.log_result("Event Update", False, "Event description not updated")
                    else:
                        self.log_result("Event Update", False, f"Status: {update_response.status_code}")
                except Exception as e:
                    self.log_result("Event Update", False, f"Exception: {str(e)}")
                
                # Test event RSVP (register)
                try:
                    rsvp_response = self.session.post(f"{BASE_URL}/events/{self.test_event_id}/rsvp", 
                                                    headers={"Authorization": f"Bearer {self.user2_token}"})
                    if rsvp_response.status_code == 200:
                        rsvp_data = rsvp_response.json()
                        if rsvp_data.get("registered") == True:
                            self.log_result("Event RSVP", True, "Successfully registered for event")
                            
                            # Test event check-in
                            try:
                                checkin_response = self.session.post(f"{BASE_URL}/events/{self.test_event_id}/checkin", 
                                                                   headers={"Authorization": f"Bearer {self.user2_token}"})
                                if checkin_response.status_code == 200:
                                    checkin_data = checkin_response.json()
                                    if checkin_data.get("checked_in") == True:
                                        self.log_result("Event Check-in", True, "Successfully checked in to event")
                                    else:
                                        self.log_result("Event Check-in", False, "Check-in response incorrect")
                                else:
                                    self.log_result("Event Check-in", False, f"Status: {checkin_response.status_code}")
                            except Exception as e:
                                self.log_result("Event Check-in", False, f"Exception: {str(e)}")
                        else:
                            self.log_result("Event RSVP", False, "RSVP response incorrect")
                    else:
                        self.log_result("Event RSVP", False, f"Status: {rsvp_response.status_code}")
                except Exception as e:
                    self.log_result("Event RSVP", False, f"Exception: {str(e)}")
                
                # Test get event attendees
                try:
                    attendees_response = self.session.get(f"{BASE_URL}/events/{self.test_event_id}/attendees")
                    if attendees_response.status_code == 200:
                        attendees = attendees_response.json()
                        self.log_result("Get Event Attendees", True, f"Retrieved {len(attendees)} attendees")
                    else:
                        self.log_result("Get Event Attendees", False, f"Status: {attendees_response.status_code}")
                except Exception as e:
                    self.log_result("Get Event Attendees", False, f"Exception: {str(e)}")
                
                # Test event deletion
                try:
                    delete_response = self.session.delete(f"{BASE_URL}/events/{self.test_event_id}", headers=headers)
                    if delete_response.status_code == 200:
                        self.log_result("Event Deletion", True, "Event deleted successfully")
                    else:
                        self.log_result("Event Deletion", False, f"Status: {delete_response.status_code}")
                except Exception as e:
                    self.log_result("Event Deletion", False, f"Exception: {str(e)}")
                    
            else:
                self.log_result("Event Creation", False, f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            self.log_result("Event Creation", False, f"Exception: {str(e)}")

    def run_all_tests(self):
        """Run all backend tests"""
        print("🚀 Starting Seva Setu Backend Testing...")
        print(f"🔗 Testing against: {BASE_URL}")
        
        # Authentication
        if not self.register_and_login_users():
            print("❌ Authentication failed. Stopping tests.")
            return
        
        # Run all feature tests
        self.test_user_profile_enhancements()
        self.test_password_change()
        self.test_follow_unfollow_users()
        self.test_activity_timeline()
        self.test_multiple_image_posts()
        self.test_poll_feature()
        self.test_edit_delete_posts()
        self.test_ngo_management()
        self.test_event_management()
        
        # Print summary
        self.print_summary()

    def print_summary(self):
        """Print test results summary"""
        print("\n" + "="*60)
        print("📊 SEVA SETU BACKEND TEST SUMMARY")
        print("="*60)
        
        passed = sum(1 for r in self.results if "✅ PASS" in r["status"])
        failed = sum(1 for r in self.results if "❌ FAIL" in r["status"])
        total = len(self.results)
        
        print(f"Total Tests: {total}")
        print(f"✅ Passed: {passed}")
        print(f"❌ Failed: {failed}")
        print(f"Success Rate: {(passed/total*100):.1f}%")
        
        if failed > 0:
            print("\n🔍 FAILED TESTS:")
            for result in self.results:
                if "❌ FAIL" in result["status"]:
                    print(f"  • {result['test']}: {result['message']}")
        
        print("\n📋 DETAILED RESULTS:")
        for result in self.results:
            print(f"  {result['status']}: {result['test']}")
            if result['message']:
                print(f"    └─ {result['message']}")

if __name__ == "__main__":
    tester = SevaSetuTester()
    tester.run_all_tests()