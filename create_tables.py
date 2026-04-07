"""
Script to create all database tables and seed initial data
"""
from app.core.database import engine, SessionLocal, Base
from app.db.init_db import init_db

def create_tables():
    print("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    print("✅ Tables created successfully!")
    
    print("\nSeeding initial data...")
    db = SessionLocal()
    try:
        init_db(db)
    except Exception as e:
        print(f"❌ Error seeding data: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_tables()
