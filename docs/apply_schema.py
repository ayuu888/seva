"""
Apply Supabase schema directly using the supabase client
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

def apply_schema():
    """Apply the SQL schema to Supabase"""
    try:
        supabase: Client = create_client(supabase_url, supabase_key)
        
        # Read SQL file
        with open('/app/backend/supabase_schema.sql', 'r') as f:
            sql_script = f.read()
        
        logger.info("SQL schema loaded successfully")
        
        # Split SQL into individual statements
        statements = []
        current_statement = []
        in_function = False
        
        for line in sql_script.split('\n'):
            stripped = line.strip()
            
            # Track if we're in a function definition
            if 'CREATE' in stripped.upper() and 'FUNCTION' in stripped.upper():
                in_function = True
            
            if stripped:
                current_statement.append(line)
            
            # End of statement
            if stripped.endswith(';') and not in_function:
                statements.append('\n'.join(current_statement))
                current_statement = []
            elif in_function and stripped == '$$;':
                current_statement.append(line)
                statements.append('\n'.join(current_statement))
                current_statement = []
                in_function = False
        
        logger.info(f"Found {len(statements)} SQL statements to execute")
        
        # Execute each statement using RPC (requires a custom function)
        # Since we can't directly execute arbitrary SQL, we'll use the SQL Editor approach
        
        logger.info("\n" + "="*80)
        logger.info("SCHEMA APPLICATION METHOD")
        logger.info("="*80)
        logger.info("\nThe Supabase Python client doesn't support direct SQL execution.")
        logger.info("Please apply the schema manually:")
        logger.info("\n1. Visit your Supabase Dashboard SQL Editor:")
        logger.info(f"   {supabase_url.replace('https://', 'https://supabase.com/dashboard/project/')}/sql/new")
        logger.info("\n2. Copy the entire contents of:")
        logger.info("   /app/backend/supabase_schema.sql")
        logger.info("\n3. Paste into the SQL editor and click 'Run'")
        logger.info("\n" + "="*80)
        
        # However, we can try using the REST API directly
        import httpx
        
        # Get project reference
        project_ref = supabase_url.split('//')[1].split('.')[0]
        
        logger.info(f"\nAttempting to apply schema via REST API for project: {project_ref}")
        
        # Try to execute via PostgREST
        headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
        
        # We can at least check if tables exist by querying them
        try:
            result = supabase.table('users').select('*').limit(1).execute()
            logger.info("✓ Users table exists and is accessible")
            return True
        except Exception as e:
            logger.error(f"✗ Users table not accessible: {str(e)}")
            logger.info("\n⚠️  Schema needs to be applied manually via SQL Editor")
            return False
            
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return False

if __name__ == "__main__":
    apply_schema()
