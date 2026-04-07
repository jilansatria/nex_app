
import urllib.request
import urllib.parse
import json
import ssl

BASE_URL = "http://127.0.0.1:8000/api/v1"

def login():
    url = f"{BASE_URL}/auth/login"
    data = urllib.parse.urlencode({
        "username": "admin@nex.com", 
        "password": "admin123"
    }).encode()
    
    try:
        req = urllib.request.Request(url, data=data, method="POST")
        with urllib.request.urlopen(req) as response:
            if response.status == 200:
                body = response.read().decode()
                return json.loads(body)["access_token"]
            else:
                print("Login failed:", response.status)
                return None
    except Exception as e:
        print("Login error:", e)
        return None

def test_submit_harvest():
    token = login()
    if not token:
        print("Skipping tests due to login failure.")
        return

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    # Simulate the payload sent by Flutter
    payload = {
        # 'block_id': '123e4567-e89b-12d3-a456-426614174000', 
        'quantity': 10.5,
        'unit': 'Tons',
        'field_code': 'Mobile Entry',
        'status': 'Harvested'
    }

    print("\nTesting Submit Harvest...")
    try:
        data = json.dumps(payload).encode('utf-8')
        req = urllib.request.Request(f"{BASE_URL}/production/", data=data, headers=headers, method="POST")
        with urllib.request.urlopen(req) as response:
            print(response.status)
            print(response.read().decode())
    except urllib.error.HTTPError as e:
        print(f"HTTP Error {e.code}: {e.read().decode()}")
    except Exception as e:
        print("Submit Error:", e)

if __name__ == "__main__":
    test_submit_harvest()
