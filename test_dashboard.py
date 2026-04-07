import urllib.request
import urllib.parse
import json

BASE_URL = "http://127.0.0.1:8000/api/v1"

url = f"{BASE_URL}/auth/login"
data = urllib.parse.urlencode({"username": "admin@nex.com", "password": "admin123"}).encode()
req = urllib.request.Request(url, data=data, method="POST")
with urllib.request.urlopen(req) as response:
    token = json.loads(response.read().decode())["access_token"]

headers = {"Authorization": f"Bearer {token}"}
for role in ["estate", "mill", "finance", "sales"]:
    print(f"\n--- Testing Role: {role} ---")
    req = urllib.request.Request(f"{BASE_URL}/dashboard/manager-summary?role={role}", headers=headers)
    try:
        with urllib.request.urlopen(req) as response:
            print(f"Status: {response.status}")
            print(json.dumps(json.loads(response.read().decode()), indent=2)[:500])
    except urllib.error.HTTPError as e:
        print(f"HTTPError {e.code}: {e.read().decode()}")
    except Exception as e:
        print(f"Error: {e}")
