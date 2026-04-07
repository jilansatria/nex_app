import os
import sys

# Add backend directory to path
backend_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(backend_dir)
os.chdir(backend_dir) 

from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.models.user import User
from app.api.deps import get_current_active_user

client = TestClient(app)

# Mock auth
def override_get_current_user():
    db = SessionLocal()
    user = db.query(User).filter(User.email == "estate@nex.com").first()
    db.close()
    return user

app.dependency_overrides[get_current_active_user] = override_get_current_user

def test_weighbridge():
    response = client.get("/api/v1/mills/weighbridge")
    print(f"Status Code: {response.status_code}")
    import json
    try:
        print(f"Response Body: {json.dumps(response.json(), indent=2)}")
    except:
        print(f"Response Body: {response.text}")

if __name__ == "__main__":
    test_weighbridge()
