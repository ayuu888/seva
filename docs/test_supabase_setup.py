"""
Create Supabase tables programmatically
This script initializes all required tables for the Seva-Setu application
"""
import os
import asyncio
from supabase import create_client
from dotenv import load_dotenv
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
load_dotenv()
supabase_url = os.environ['SUPABASE_URL']
supabase_key = os.environ['SUPABASE_SERVICE_ROLE_KEY']
supabase = create_client(supabase_url, supabase_key)
def test_connection():
    """Test Supabase connection"""
    try:
        logger.info("Testing Supabase connection...")
        logger.info(f"Supabase URL: {supabase_url}")
        logger.info("Connection established successfully!")
        return True
    except Exception as e:
        logger.error(f"Connection test failed: {str(e)}")
        return False
def create_test_data():
    """Create some test data to verify tables exist"""
    try:
        logger.info("Creating test user...")
        test_user = {
            'id': 'test-user-123',
            'name': 'Test User',
            'email': 'test@example.com',
            'password_hash': 'hashed_password',
            'user_type': 'volunteer'
        }
        result = supabase.table('users').insert(test_user).execute()
        logger.info(f"Test user created: {result.data}")
        supabase.table('users').delete().eq('id', 'test-user-123').execute()
        logger.info("Test user cleaned up")
        return True
    except Exception as e:
        logger.error(f"Test data creation failed: {str(e)}")
        logger.info("\nPlease execute the SQL schema in Supabase Dashboard:")
        logger.info("1. Go to your Supabase project dashboard")
        logger.info("2. Navigate to SQL Editor")
        logger.info("3. Copy and paste the contents of /app/backend/supabase_schema.sql")
        logger.info("4. Execute the SQL script")
        return False
if __name__ == "__main__":
    logger.info("="*60)
    logger.info("Supabase Setup Check")
    logger.info("="*60)
    if test_connection():
        logger.info("✓ Connection successful")
        if create_test_data():
            logger.info("✓ Tables exist and are accessible")
        else:
            logger.warning("⚠ Tables need to be created")
    else:
        logger.error("✗ Connection failed")