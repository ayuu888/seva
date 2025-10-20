"""
Migration script to move data from MongoDB to Supabase
"""
import os
import asyncio
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from supabase import create_client, Client
from datetime import datetime, timezone
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
load_dotenv()
mongo_url = os.environ['MONGO_URL']
mongo_client = AsyncIOMotorClient(mongo_url)
mongo_db = mongo_client[os.environ['DB_NAME']]
supabase_url = os.environ['SUPABASE_URL']
supabase_key = os.environ['SUPABASE_SERVICE_ROLE_KEY']
supabase: Client = create_client(supabase_url, supabase_key)
async def migrate_users():
    """Migrate users from MongoDB to Supabase"""
    logger.info("Starting users migration...")
    users = await mongo_db.users.find({}).to_list(length=None)
    logger.info(f"Found {len(users)} users to migrate")
    for user in users:
        try:
            user_data = {
                'id': user.get('id'),
                'name': user.get('name'),
                'email': user.get('email'),
                'password_hash': user.get('password'),
                'user_type': user.get('user_type', 'volunteer'),
                'bio': user.get('bio'),
                'avatar': user.get('avatar'),
                'cover_photo': user.get('cover_photo'),
                'phone': user.get('phone'),
                'website': user.get('website'),
                'location': user.get('location'),
                'social_links': user.get('social_links', {}),
                'skills': user.get('skills', []),
                'interests': user.get('interests', []),
                'followers_count': user.get('followers_count', 0),
                'following_count': user.get('following_count', 0),
                'is_private': user.get('is_private', False),
                'email_notifications': user.get('email_notifications', True),
                'created_at': user.get('created_at', datetime.now(timezone.utc)).isoformat() if isinstance(user.get('created_at'), datetime) else datetime.now(timezone.utc).isoformat()
            }
            result = supabase.table('users').upsert(user_data).execute()
            logger.info(f"Migrated user: {user.get('email')}")
        except Exception as e:
            logger.error(f"Error migrating user {user.get('email')}: {str(e)}")
    logger.info("Users migration completed!")
async def migrate_sessions():
    """Migrate sessions from MongoDB to Supabase"""
    logger.info("Starting sessions migration...")
    sessions = await mongo_db.sessions.find({}).to_list(length=None)
    logger.info(f"Found {len(sessions)} sessions to migrate")
    for session in sessions:
        try:
            session_data = {
                'session_token': session.get('session_token'),
                'user_id': session.get('user_id'),
                'email': session.get('email'),
                'expires_at': session.get('expires_at').isoformat() if isinstance(session.get('expires_at'), datetime) else datetime.now(timezone.utc).isoformat()
            }
            result = supabase.table('sessions').upsert(session_data).execute()
            logger.info(f"Migrated session for: {session.get('email')}")
        except Exception as e:
            logger.error(f"Error migrating session: {str(e)}")
    logger.info("Sessions migration completed!")
async def migrate_ngos():
    """Migrate NGOs from MongoDB to Supabase"""
    logger.info("Starting NGOs migration...")
    ngos = await mongo_db.ngos.find({}).to_list(length=None)
    logger.info(f"Found {len(ngos)} NGOs to migrate")
    for ngo in ngos:
        try:
            ngo_data = {
                'id': ngo.get('id'),
                'name': ngo.get('name'),
                'description': ngo.get('description'),
                'category': ngo.get('category'),
                'founded_year': ngo.get('founded_year'),
                'website': ngo.get('website'),
                'logo': ngo.get('logo'),
                'cover_image': ngo.get('cover_image'),
                'gallery': ngo.get('gallery', []),
                'location': ngo.get('location'),
                'owner_id': ngo.get('owner_id'),
                'followers_count': ngo.get('followers_count', 0),
                'created_at': ngo.get('created_at', datetime.now(timezone.utc)).isoformat() if isinstance(ngo.get('created_at'), datetime) else datetime.now(timezone.utc).isoformat()
            }
            result = supabase.table('ngos').upsert(ngo_data).execute()
            logger.info(f"Migrated NGO: {ngo.get('name')}")
            team_members = ngo.get('team_members', [])
            for member in team_members:
                try:
                    member_data = {
                        'ngo_id': ngo.get('id'),
                        'user_id': member.get('user_id'),
                        'role': member.get('role', 'member'),
                        'name': member.get('name'),
                        'avatar': member.get('avatar')
                    }
                    supabase.table('ngo_team_members').upsert(member_data).execute()
                except Exception as e:
                    logger.error(f"Error migrating team member: {str(e)}")
        except Exception as e:
            logger.error(f"Error migrating NGO {ngo.get('name')}: {str(e)}")
    logger.info("NGOs migration completed!")
async def migrate_posts():
    """Migrate posts from MongoDB to Supabase"""
    logger.info("Starting posts migration...")
    posts = await mongo_db.posts.find({}).to_list(length=None)
    logger.info(f"Found {len(posts)} posts to migrate")
    for post in posts:
        try:
            post_data = {
                'id': post.get('id'),
                'author_id': post.get('author_id'),
                'author_name': post.get('author_name'),
                'author_avatar': post.get('author_avatar'),
                'author_type': post.get('author_type', 'user'),
                'content': post.get('content'),
                'images': post.get('images', []),
                'poll': post.get('poll'),
                'likes_count': post.get('likes_count', 0),
                'comments_count': post.get('comments_count', 0),
                'created_at': post.get('created_at', datetime.now(timezone.utc)).isoformat() if isinstance(post.get('created_at'), datetime) else datetime.now(timezone.utc).isoformat()
            }
            result = supabase.table('posts').upsert(post_data).execute()
            logger.info(f"Migrated post: {post.get('id')}")
        except Exception as e:
            logger.error(f"Error migrating post {post.get('id')}: {str(e)}")
    logger.info("Posts migration completed!")
async def migrate_comments():
    """Migrate comments from MongoDB to Supabase"""
    logger.info("Starting comments migration...")
    comments = await mongo_db.comments.find({}).to_list(length=None)
    logger.info(f"Found {len(comments)} comments to migrate")
    for comment in comments:
        try:
            comment_data = {
                'id': comment.get('id'),
                'post_id': comment.get('post_id'),
                'author_id': comment.get('author_id'),
                'author_name': comment.get('author_name'),
                'author_avatar': comment.get('author_avatar'),
                'content': comment.get('content'),
                'created_at': comment.get('created_at', datetime.now(timezone.utc)).isoformat() if isinstance(comment.get('created_at'), datetime) else datetime.now(timezone.utc).isoformat()
            }
            result = supabase.table('comments').upsert(comment_data).execute()
            logger.info(f"Migrated comment: {comment.get('id')}")
        except Exception as e:
            logger.error(f"Error migrating comment: {str(e)}")
    logger.info("Comments migration completed!")
async def migrate_events():
    """Migrate events from MongoDB to Supabase"""
    logger.info("Starting events migration...")
    events = await mongo_db.events.find({}).to_list(length=None)
    logger.info(f"Found {len(events)} events to migrate")
    for event in events:
        try:
            event_data = {
                'id': event.get('id'),
                'ngo_id': event.get('ngo_id'),
                'ngo_name': event.get('ngo_name'),
                'title': event.get('title'),
                'description': event.get('description'),
                'location': event.get('location'),
                'location_details': event.get('location_details', {}),
                'theme': event.get('theme'),
                'date': event.get('date').isoformat() if isinstance(event.get('date'), datetime) else datetime.now(timezone.utc).isoformat(),
                'end_date': event.get('end_date').isoformat() if event.get('end_date') and isinstance(event.get('end_date'), datetime) else None,
                'images': event.get('images', []),
                'volunteers_needed': event.get('volunteers_needed', 0),
                'volunteers_registered': event.get('volunteers_registered', 0),
                'category': event.get('category', 'general'),
                'created_at': event.get('created_at', datetime.now(timezone.utc)).isoformat() if isinstance(event.get('created_at'), datetime) else datetime.now(timezone.utc).isoformat()
            }
            result = supabase.table('events').upsert(event_data).execute()
            logger.info(f"Migrated event: {event.get('title')}")
        except Exception as e:
            logger.error(f"Error migrating event {event.get('title')}: {str(e)}")
    logger.info("Events migration completed!")
async def migrate_event_attendees():
    """Migrate event attendees from MongoDB to Supabase"""
    logger.info("Starting event attendees migration...")
    attendees = await mongo_db.event_attendees.find({}).to_list(length=None)
    logger.info(f"Found {len(attendees)} attendees to migrate")
    for attendee in attendees:
        try:
            attendee_data = {
                'event_id': attendee.get('event_id'),
                'user_id': attendee.get('user_id'),
                'user_name': attendee.get('user_name'),
                'user_avatar': attendee.get('user_avatar'),
                'status': attendee.get('status', 'registered'),
                'registered_at': attendee.get('registered_at', datetime.now(timezone.utc)).isoformat() if isinstance(attendee.get('registered_at'), datetime) else datetime.now(timezone.utc).isoformat(),
                'checked_in_at': attendee.get('checked_in_at').isoformat() if attendee.get('checked_in_at') and isinstance(attendee.get('checked_in_at'), datetime) else None
            }
            result = supabase.table('event_attendees').upsert(attendee_data).execute()
            logger.info(f"Migrated attendee for event: {attendee.get('event_id')}")
        except Exception as e:
            logger.error(f"Error migrating attendee: {str(e)}")
    logger.info("Event attendees migration completed!")
async def migrate_post_likes():
    """Migrate post likes from MongoDB to Supabase"""
    logger.info("Starting post likes migration...")
    likes = await mongo_db.post_likes.find({}).to_list(length=None)
    logger.info(f"Found {len(likes)} likes to migrate")
    for like in likes:
        try:
            like_data = {
                'post_id': like.get('post_id'),
                'user_id': like.get('user_id'),
                'created_at': like.get('created_at', datetime.now(timezone.utc)).isoformat() if isinstance(like.get('created_at'), datetime) else datetime.now(timezone.utc).isoformat()
            }
            result = supabase.table('post_likes').upsert(like_data).execute()
        except Exception as e:
            logger.error(f"Error migrating like: {str(e)}")
    logger.info("Post likes migration completed!")
async def migrate_ngo_followers():
    """Migrate NGO followers from MongoDB to Supabase"""
    logger.info("Starting NGO followers migration...")
    followers = await mongo_db.ngo_followers.find({}).to_list(length=None)
    logger.info(f"Found {len(followers)} followers to migrate")
    for follower in followers:
        try:
            follower_data = {
                'ngo_id': follower.get('ngo_id'),
                'user_id': follower.get('user_id'),
                'followed_at': follower.get('followed_at', datetime.now(timezone.utc)).isoformat() if isinstance(follower.get('followed_at'), datetime) else datetime.now(timezone.utc).isoformat()
            }
            result = supabase.table('ngo_followers').upsert(follower_data).execute()
        except Exception as e:
            logger.error(f"Error migrating follower: {str(e)}")
    logger.info("NGO followers migration completed!")
async def main():
    """Run all migrations"""
    logger.info("=" * 50)
    logger.info("Starting MongoDB to Supabase Migration")
    logger.info("=" * 50)
    try:
        await migrate_users()
        await migrate_sessions()
        await migrate_ngos()
        await migrate_posts()
        await migrate_comments()
        await migrate_events()
        await migrate_event_attendees()
        await migrate_post_likes()
        await migrate_ngo_followers()
        logger.info("=" * 50)
        logger.info("Migration completed successfully!")
        logger.info("=" * 50)
    except Exception as e:
        logger.error(f"Migration failed: {str(e)}")
    finally:
        mongo_client.close()
if __name__ == "__main__":
    asyncio.run(main())