
import urllib.request
import urllib.parse
import json
import ssl

BASE_URL = "http://127.0.0.1:8000/api/v1"

def login():
    url = f"{BASE_URL}/auth/login"
    data = urllib.parse.urlencode({
        "username": "admin@nex.com", 
        "password": "admin"
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
        # Try admin123 just in case
        return login_alt()

def login_alt():
    print("Trying alternative login with password 'admin123'...")
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
        print("Login alt error:", e)
        return None

def test_dashboard():
    token = login()
    if not token:
        print("Skipping tests due to login failure.")
        return

    headers = {"Authorization": f"Bearer {token}"}

    print("\nTesting KPI Data...")
    try:
        req = urllib.request.Request(f"{BASE_URL}/dashboard/kpi", headers=headers)
        with urllib.request.urlopen(req) as response:
            print(response.status)
            print(json.dumps(json.loads(response.read().decode()), indent=2))
    except Exception as e:
        print("KPI Error:", e)

    print("\nTesting Production Data...")
    try:
        req = urllib.request.Request(f"{BASE_URL}/dashboard/production", headers=headers)
        with urllib.request.urlopen(req) as response:
            print(response.status)
            print(json.dumps(json.loads(response.read().decode()), indent=2))
    except Exception as e:
        print("Production Error:", e)

    print("\nTesting Estates Data...")
    try:
        req = urllib.request.Request(f"{BASE_URL}/estates/", headers=headers)
        with urllib.request.urlopen(req) as response:
            print(response.status)
            print(json.dumps(json.loads(response.read().decode()), indent=2))
    except Exception as e:
        print("Estates Error:", e)

if __name__ == "__main__":
    test_dashboard()
