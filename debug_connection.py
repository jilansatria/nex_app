"""
Script untuk mencoba berbagai kombinasi koneksi PostgreSQL
"""
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

# Kemungkinan konfigurasi
POSSIBLE_CONFIGS = [
    {"host": "localhost", "port": 5432, "password": "postgres"},
    {"host": "localhost", "port": 5433, "password": "postgres"},
    {"host": "localhost", "port": 5434, "password": "postgres"},
    {"host": "127.0.0.1", "port": 5432, "password": "postgres"},
    {"host": "127.0.0.1", "port": 5433, "password": "postgres"},
]

DB_USER = "postgres"
DB_NAME = "postgres"  # Default database

def try_connections():
    """Coba berbagai kombinasi koneksi"""
    print("🔍 Mencoba berbagai konfigurasi koneksi PostgreSQL...\n")
    
    for i, config in enumerate(POSSIBLE_CONFIGS, 1):
        host = config["host"]
        port = config["port"]
        password = config["password"]
        
        print(f"[{i}] Testing: host={host}, port={port}, user={DB_USER}, password={password}")
        
        try:
            conn = psycopg2.connect(
                user=DB_USER,
                password=password,
                host=host,
                port=port,
                database=DB_NAME,
                connect_timeout=3
            )
            conn.close()
            
            print(f"    ✅ BERHASIL! Gunakan konfigurasi ini:\n")
            print(f"    POSTGRES_SERVER={host}")
            print(f"    POSTGRES_USER={DB_USER}")
            print(f"    POSTGRES_PASSWORD={password}")
            if port != 5432:
                print(f"    POSTGRES_PORT={port}  # Tambahkan ini ke .env")
            print()
            return True
            
        except psycopg2.OperationalError as e:
            error_msg = str(e).split('\n')[0]
            print(f"    ❌ Gagal: {error_msg}\n")
        except Exception as e:
            print(f"    ❌ Error: {e}\n")
    
    print("\n⚠️  Tidak ada konfigurasi yang berhasil.")
    print("\n💡 Kemungkinan solusi:")
    print("1. Pastikan Anda mengingat password yang diset saat install PostgreSQL")
    print("2. Coba reset password PostgreSQL:")
    print("   - Buka pgAdmin 4")
    print("   - Klik kanan pada PostgreSQL server → Properties → Connection")
    print("   - Atau reinstall PostgreSQL dengan password yang Anda ingat")
    print("3. Atau gunakan authentication 'trust' untuk testing (tidak aman untuk production)")
    
    return False

if __name__ == "__main__":
    success = try_connections()
    if not success:
        print("\n" + "="*60)
        print("LANGKAH ALTERNATIF - Reset Password PostgreSQL:")
        print("="*60)
        print("1. Buka 'Services' (Win+R → services.msc)")
        print("2. Cari 'postgresql-x64-XX' → Klik kanan → Stop")
        print("3. Buka file: C:\\Program Files\\PostgreSQL\\XX\\data\\pg_hba.conf")
        print("4. Ubah semua 'md5' atau 'scram-sha-256' menjadi 'trust'")
        print("5. Restart PostgreSQL service")
        print("6. Sekarang Anda bisa connect tanpa password")
        print("7. Jalankan script test_db_connection.py lagi")
