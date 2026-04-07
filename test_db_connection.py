"""
Script untuk test koneksi PostgreSQL dan membuat database jika belum ada
"""
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

# Konfigurasi dari .env
DB_USER = "postgres"
DB_PASSWORD = "postgres"
DB_HOST = "localhost"
DB_PORT = 5433  # Port yang benar
DB_NAME = "nex_db"

def test_connection():
    """Test koneksi ke PostgreSQL"""
    try:
        # Connect ke database postgres (default database)
        print("🔄 Mencoba koneksi ke PostgreSQL...")
        conn = psycopg2.connect(
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT,
            database="postgres"  # Connect ke default database dulu
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()
        
        print("✅ Koneksi ke PostgreSQL berhasil!")
        
        # Cek apakah database nex_db sudah ada
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (DB_NAME,))
        exists = cursor.fetchone()
        
        if exists:
            print(f"✅ Database '{DB_NAME}' sudah ada!")
        else:
            print(f"⚠️  Database '{DB_NAME}' belum ada. Membuat database...")
            cursor.execute(f"CREATE DATABASE {DB_NAME}")
            print(f"✅ Database '{DB_NAME}' berhasil dibuat!")
        
        cursor.close()
        conn.close()
        
        # Test koneksi ke database nex_db
        print(f"\n🔄 Test koneksi ke database '{DB_NAME}'...")
        conn = psycopg2.connect(
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME
        )
        print(f"✅ Koneksi ke database '{DB_NAME}' berhasil!")
        conn.close()
        
        print("\n✅ Semua tes koneksi berhasil! Database siap digunakan.")
        return True
        
    except psycopg2.OperationalError as e:
        print(f"\n❌ ERROR: Tidak bisa connect ke PostgreSQL!")
        print(f"Detail error: {e}")
        print("\n🔍 Kemungkinan masalah:")
        print("1. Password PostgreSQL salah - cek file .env")
        print("2. PostgreSQL service tidak running - cek di Services")
        print("3. Port 5432 digunakan oleh aplikasi lain")
        return False
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        return False

if __name__ == "__main__":
    test_connection()
