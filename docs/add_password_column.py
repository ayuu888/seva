"""
Add missing columns to Supabase users table
"""
import os
from supabase import create_client
from dotenv import load_dotenv
import logging
import httpx

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

supabase_url = os.environ['SUPABASE_URL']
supabase_key = os.environ['SUPABASE_SERVICE_ROLE_KEY']

def add_password_column():
    """Add password_hash column to users table via SQL"""
    
    project_ref = supabase_url.split('//')[1].split('.')[0]
    
    sql_statements = [
        # Add password_hash column
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);",
        
        # Make password_hash NOT NULL after adding (for new users)
        # But allow NULL for existing users who might be using social auth
        "ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;",
        
        # Add index on email for faster lookups
        "CREATE INDEX IF NOT EXISTS idx_users_email_lookup ON users(email);",
    ]
    
    logger.info("=" * 80)
    logger.info("SQL MIGRATION REQUIRED")
    logger.info("=" * 80)
    logger.info("\nTo add the missing password_hash column, please:")
    logger.info(f"\n1. Visit: https://supabase.com/dashboard/project/{project_ref}/sql/new")
    logger.info("\n2. Paste and run the following SQL:")
    logger.info("\n" + "-" * 80)
    for stmt in sql_statements:
        logger.info(stmt)
    logger.info("-" * 80)
    logger.info("\n3. Or run all at once:")
    logger.info("\n" + "\n".join(sql_statements))
    logger.info("\n" + "=" * 80)
    
    return True

if __name__ == "__main__":
    add_password_column()
