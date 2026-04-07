from app.db.init_db import init_db
from app.core.database import SessionLocal

db = SessionLocal()
try:
    init_db(db)
    print("Seeding executed successfully.")
except Exception as e:
    print(f"Error seeding database: {e}")
finally:
    db.close()
