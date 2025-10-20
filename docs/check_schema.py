"""
Check current Supabase schema
"""
import os
from supabase import create_client, Client
from dotenv import load_dotenv
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

supabase_url = os.environ['SUPABASE_URL']
supabase_key = os.environ['SUPABASE_SERVICE_ROLE_KEY']

def check_schema():
    """Check what tables and columns exist"""
    try:
        supabase: Client = create_client(supabase_url, supabase_key)
        
        tables_to_check = ['users', 'sessions', 'posts', 'events', 'ngos', 'donations']
        
        for table in tables_to_check:
            try:
                result = supabase.table(table).select('*').limit(1).execute()
                logger.info(f"✓ Table '{table}' exists")
                if result.data:
                    logger.info(f"  Columns: {', '.join(result.data[0].keys())}")
                else:
                    # Try to get schema by attempting an insert with empty data
                    logger.info(f"  Table is empty, attempting to query schema...")
            except Exception as e:
                logger.error(f"✗ Table '{table}' error: {str(e)}")
        
        # Try to create a test user to see what the error says
        logger.info("\nAttempting test user creation to see schema requirements...")
        try:
            test_user = {
                'name': 'Test User',
                'email': f'test_{os.urandom(4).hex()}@test.com',
                'password_hash': 'test_hash',
                'user_type': 'volunteer'
            }
            result = supabase.table('users').insert(test_user).execute()
            logger.info(f"✓ Test user created successfully: {result.data}")
            
            # Delete the test user
            if result.data and len(result.data) > 0:
                user_id = result.data[0]['id']
                supabase.table('users').delete().eq('id', user_id).execute()
                logger.info(f"✓ Test user deleted")
                
        except Exception as e:
            logger.error(f"✗ Test user creation failed: {str(e)}")
            
    except Exception as e:
        logger.error(f"Error: {str(e)}")

if __name__ == "__main__":
    check_schema()
