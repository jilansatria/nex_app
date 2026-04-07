"""
Script to seed database with initial data
Run: python seed_db.py
"""
from app.core.database import SessionLocal
from app.db.init_db import init_db


def main() -> None:
    db = SessionLocal()
    try:
        init_db(db)
    finally:
        db.close()


if __name__ == "__main__":
    main()
