from sqlalchemy import create_engine, text
from app.core.config import settings

def migrate():
    engine = create_engine(settings.SQLALCHEMY_DATABASE_URI)
    with engine.connect() as conn:
        print("Starting manual migration...")
        
        # 1. Update 'production' table
        try:
            conn.execute(text("ALTER TABLE production ADD COLUMN IF NOT EXISTS quality_grade VARCHAR DEFAULT 'Standard'"))
            print("✅ Added quality_grade to production table")
        except Exception as e:
            print(f"⚠️ Error updating production table: {e}")

        # 2. Update 'approval_requests' table to match new industry standard structure
        # Since it was a small table, we can just drop and recreate it or add columns
        # To be safe and since we want 'standard industry' structure:
        try:
            # Add new columns
            conn.execute(text("ALTER TABLE approval_requests ADD COLUMN IF NOT EXISTS workflow_id UUID REFERENCES approval_workflows(id)"))
            conn.execute(text("ALTER TABLE approval_requests ADD COLUMN IF NOT EXISTS total_steps INTEGER DEFAULT 1"))
            conn.execute(text("ALTER TABLE approval_requests ADD COLUMN IF NOT EXISTS notes TEXT"))
            conn.execute(text("ALTER TABLE approval_requests ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"))
            conn.execute(text("ALTER TABLE approval_requests ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"))
            
            # workflow_logs was in old one, but we use approval_steps table now. 
            # We keep it for now to avoid errors if some old code uses it, or just leave it.
            
            print("✅ Updated approval_requests table")
        except Exception as e:
            print(f"⚠️ Error updating approval_requests table: {e}")

        conn.commit()
    print("Migration finished!")

if __name__ == "__main__":
    migrate()
