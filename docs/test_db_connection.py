#!/usr/bin/env python3
"""
Simple database connection test
"""

import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv
from pathlib import Path

ROOT_DIR = Path(__file__).parent / "backend"
load_dotenv(ROOT_DIR / '.env')

async def test_db():
    mongo_url = os.environ['MONGO_URL']
    client = AsyncIOMotorClient(mongo_url)
    db = client[os.environ['DB_NAME']]
    
    print(f"MongoDB URL: {mongo_url}")
    print(f"Database: {os.environ['DB_NAME']}")
    
    try:
        # Test connection
        await client.admin.command('ping')
        print("✅ MongoDB connection successful")
        
        # Check collections
        collections = await db.list_collection_names()
        print(f"📋 Collections: {collections}")
        
        # Check users collection
        user_count = await db.users.count_documents({})
        print(f"👥 Users in database: {user_count}")
        
        if user_count > 0:
            # Get a sample user to check structure
            sample_user = await db.users.find_one({}, {"_id": 0})
            print(f"📄 Sample user structure: {list(sample_user.keys()) if sample_user else 'None'}")
        
    except Exception as e:
        print(f"❌ Database error: {e}")
    finally:
        client.close()

if __name__ == "__main__":
    asyncio.run(test_db())