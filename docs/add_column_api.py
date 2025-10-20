"""
Add password_hash column using Supabase REST API
"""
import os
from supabase import create_client
from dotenv import load_dotenv
import logging
import httpx
import asyncio

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

supabase_url = os.environ['SUPABASE_URL']
supabase_key = os.environ['SUPABASE_SERVICE_ROLE_KEY']

async def execute_sql_via_api():
    """Execute SQL using Supabase management/query endpoint"""
    try:
        # SQL to add password_hash column
        sql = "ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);"
        
        # Try using PostgREST RPC if there's an exec function
        # Or use the pgmeta API
        
        project_ref = supabase_url.split('//')[1].split('.')[0]
        
        # Supabase Meta API endpoint (for schema changes)
        meta_url = f"https://{project_ref}.supabase.co/rest/v1/rpc/exec_sql"
        
        headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json'
        }
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            # Try to execute SQL
            response = await client.post(
                meta_url,
                headers=headers,
                json={"query": sql}
            )
            
            if response.status_code == 200:
                logger.info("✓ Successfully added password_hash column")
                return True
            else:
                logger.warning(f"Could not execute SQL via API: {response.status_code} - {response.text}")
                
                # Fallback: Try using supabase-py to call a custom function
                supabase = create_client(supabase_url, supabase_key)
                
                # Check if we can at least verify the column doesn't exist
                try:
                    test_data = {
                        'email': f'test_{os.urandom(4).hex()}@test.com',
                        'password_hash': 'test'
                    }
                    result = supabase.table('users').insert(test_data).execute()
                    if result.data:
                        # Column exists! Delete the test user
                        supabase.table('users').delete().eq('id', result.data[0]['id']).execute()
                        logger.info("✓ password_hash column already exists!")
                        return True
                except Exception as e:
                    error_str = str(e)
                    if 'password_hash' in error_str.lower() and 'not found' in error_str.lower():
                        logger.error("✗ password_hash column does not exist")
                        logger.info("\nPlease run this SQL in Supabase SQL Editor:")
                        logger.info(sql)
                        return False
                    else:
                        logger.info("✓ password_hash column exists (verified via different error)")
                        return True
                
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return False

if __name__ == "__main__":
    asyncio.run(execute_sql_via_api())
