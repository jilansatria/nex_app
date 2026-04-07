---
description: Alur Pengembangan Lengkap Sistem NEX - Integrasi Utama
---

# Workflow Pengembangan NEX - Panduan Integrasi Sistem Utama

Workflow ini adalah panduan utama untuk pengembangan sistem NEX berdasarkan PRD dan Proposal. Ikuti langkah-langkah ini untuk memastikan pengembangan tidak salah arah dan dapat terintegrasi dengan benar.

## Prasyarat
- ✅ PRD NEX PROJECT.pdf telah dibaca dan dipahami
- ✅ NEX Proposal.pdf telah dibaca dan dipahami
- ✅ Backend (nex_backend) dengan FastAPI + PostgreSQL
- ✅ Frontend (nex_app) dengan Flutter (Mobile + Web)

---

## Fase 1: Setup & Verifikasi Environment

### 1.1 Cek Environment Backend
```bash
cd "d:\Kuliah\MAGANG IROSTECH\nex_backend"
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

### 1.2 Verifikasi Koneksi Database
```bash
# Verifikasi koneksi database PostgreSQL
python test_db_connection.py
```
**Hasil yang Diharapkan**: Koneksi berhasil dengan detail info database

### 1.3 Cek Environment Frontend
```bash
cd "d:\Kuliah\MAGANG IROSTECH\nex_app"
flutter doctor
flutter pub get
```
**Hasil yang Diharapkan**: Tidak ada masalah, semua dependencies terinstall

---

## Fase 2: Pengembangan Backend (Berdasarkan Modul PRD)

### 2.1 Fondasi Inti - Autentikasi & Otorisasi
**Prioritas: KRITIKAL**

**2.1.1** Verifikasi Model User & Schema sudah ada:
```bash
cd "d:\Kuliah\MAGANG IROSTECH\nex_backend"
# Cek app/models/user.py dan app/schemas/user.py
```

**2.1.2** Jalankan server backend untuk testing:
```bash
.\venv\Scripts\activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**2.1.3** Test API Endpoints:
- Buka browser: `http://127.0.0.1:8000/docs`
- Verifikasi endpoints: `/auth/login`, `/auth/register`, `/users/me`

### 2.2 Prioritas Pengembangan Modul (Sesuai PRD)
Kembangkan modul dalam urutan berikut untuk memastikan dependency terpenuhi:

**Tier 1 - Fondasi** (Harus diselesaikan terlebih dahulu):
1. ✅ System Setup - Master data, parameter global
2. ✅ Authorization - RBAC, alur approval

**Tier 2 - Operasi Inti** (Bergantung pada Tier 1):
3. Modul Estate/Field - Entry panen, statistik tanaman
4. Modul Mill/Production - Tracking hasil, timbangan
5. Human Resources - Payroll, presensi

**Tier 3 - Keuangan & Analitik** (Bergantung pada Tier 1 & 2):
6. Accounting - Auto-journaling, cash flow
7. Dashboard - Views eksekutif, pemetaan GIS
8. Unit Reporting - Konsolidasi, laporan manajemen

**Tier 4 - Lanjutan** (Peningkatan opsional):
9. Contract Management
10. Special Module - API Gateway, analisis historis

### 2.3 Checklist Pengembangan Modul Backend (per modul)
Untuk setiap modul, ikuti:
- [ ] Buat model database di `app/models/`
- [ ] Buat Pydantic schemas di `app/schemas/`
- [ ] Buat operasi CRUD di `app/crud/`
- [ ] Buat API endpoints di `app/api/endpoints/`
- [ ] Tambahkan routes ke `app/api/api.py`
- [ ] Test dengan FastAPI Docs (`/docs`)
- [ ] Dokumentasikan API di README

---

## Fase 3: Pengembangan Frontend (Berdasarkan PRD & Kebutuhan UI/UX)

### 3.1 Fondasi UI Inti
**3.1.1** Verifikasi Design System sudah ada:
```bash
cd "d:\Kuliah\MAGANG IROSTECH\nex_app"
# Cek lib/shared/theme/ untuk colors, typography, spacing
```

**3.1.2** Verifikasi Struktur Navigasi:
- Admin Dashboard: `lib/features/dashboard/` (Desktop/Tablet)
- User Mobile: `lib/features/mobile/` (Pekerja Lapangan)

### 3.2 Strategi Adaptive UI (KRITIKAL)
Sesuai PRD, implementasi adaptive UI untuk:

**Desktop/Web (Manajemen)**:
- Navigasi Sidebar + TopBar
- Data tables dengan sorting/filtering
- Chart kompleks dan analytics
- Optimasi untuk mouse/keyboard

**Mobile (Pekerja Lapangan)**:
- Bottom navigation dengan tombol besar
- Integrasi kamera untuk capture
- Integrasi GPS
- UI yang disederhanakan, optimasi sentuh
- **Offline-first** dengan local storage (Hive/SQLite)

### 3.3 Prioritas Pengembangan Modul Frontend

**Tier 1 - Autentikasi & Dashboard**:
1. Login Screen (`lib/features/auth/`)
2. Admin Dashboard (`lib/features/dashboard/admin_dashboard_screen.dart`)
3. User Dashboard (`lib/features/dashboard/user_dashboard_screen.dart`)

**Tier 2 - Modul Operasi Inti**:
4. Modul Field/Estate (`lib/features/field/`)
   - Entry panen mobile (MAMPU OFFLINE)
   - Tampilan statistik tanaman
   - Perencanaan penanaman
5. Modul Production/Mill (`lib/features/production/`)
6. Modul HR (`lib/features/hr/`)

**Tier 3 - Keuangan & Pelaporan**:
7. Modul Accounting
8. Dashboard Pelaporan & Analitik

### 3.4 Checklist Modul Frontend (per modul)
- [ ] Buat folder feature di `lib/features/[nama_modul]/`
- [ ] Buat models di `lib/domain/models/`
- [ ] Buat repository di `lib/data/repositories/`
- [ ] Buat API service di `lib/data/services/`
- [ ] Implementasi screens (pisah untuk mobile/desktop jika perlu)
- [ ] Tambahkan routes ke router (`lib/core/router/`)
- [ ] Test di Web: `flutter run -d chrome`
- [ ] Test di Mobile: `flutter run` (Android emulator/device)

---

## Fase 4: Testing Integrasi

### 4.1 Koneksi Backend-Frontend
**4.1.1** Konfigurasi API Base URL di frontend:
- Development: `http://127.0.0.1:8000`
- Production: AWS endpoint (TBD)

**4.1.2** Test Alur Autentikasi:
```bash
# Terminal 1: Jalankan backend
cd nex_backend
uvicorn app.main:app --reload

# Terminal 2: Jalankan frontend
cd nex_app
flutter run -d chrome
```

**4.1.3** Verifikasi:
- Login berhasil dengan JWT token
- Token tersimpan di local storage
- Protected routes memerlukan autentikasi
- API calls menyertakan Authorization header

### 4.2 Testing Integrasi Modul (per modul yang selesai)
- [ ] Backend API mengembalikan format data yang benar
- [ ] Frontend menampilkan data backend dengan benar
- [ ] Operasi CRUD bekerja end-to-end
- [ ] Error handling berfungsi (network errors, validasi)
- [ ] Loading states ditampilkan dengan benar

### 4.3 Testing Fungsionalitas Offline (Khusus Mobile)
- [ ] Data sync ketika online
- [ ] Mode offline memungkinkan entry data
- [ ] Queue sync ketika koneksi pulih
- [ ] Conflict resolution berfungsi

---

## Fase 5: Integrasi Hardware (IoT, Drone, Weighbridge)

### 5.1 Setup API Gateway (Backend)
Buat endpoints di `app/api/endpoints/hardware/` untuk:
- Ingest data drone
- Data sensor IoT (tanah, cuaca, suhu tangki)
- Integrasi weighbridge
- Data tracking GPS/Fleet

### 5.2 Visualisasi Data (Frontend)
Implementasi charts dan maps untuk:
- Pemetaan GIS dari data drone
- Monitoring sensor real-time
- Dashboard tracking fleet

---

## Fase 6: Persiapan Deployment

### 6.1 Deployment Backend (AWS)
- [ ] Setup AWS RDS (PostgreSQL)
- [ ] Setup AWS EC2 atau ECS untuk FastAPI
- [ ] Konfigurasi environment variables
- [ ] Setup CI/CD pipeline
- [ ] Test production endpoints

### 6.2 Deployment Frontend
**Web**:
- [ ] Build: `flutter build web`
- [ ] Deploy ke AWS S3 + CloudFront atau hosting lain
- [ ] Konfigurasi domain

**Mobile**:
- [ ] Build Android: `flutter build apk --release`
- [ ] Test APK di devices
- [ ] Persiapan untuk Play Store (masa depan)

---

## Checkpoint Integrasi Kritikal

### Checkpoint 1: Setelah Modul Tier 1
- ✅ Autentikasi berfungsi end-to-end
- ✅ Dashboard dasar ditampilkan
- ✅ RBAC diimplementasi dan ditest

### Checkpoint 2: Setelah Operasi Inti (Tier 2)
- ✅ Minimal 1 modul (Field/Production/HR) berfungsi penuh
- ✅ Fungsionalitas offline mobile ditest
- ✅ Data mengalir dari lapangan → backend → dashboard

### Checkpoint 3: Sebelum Production
- ✅ Semua modul kritikal selesai
- ✅ Security audit passed
- ✅ Performance testing selesai
- ✅ User acceptance testing (UAT) selesai

---

## Troubleshooting Masalah Integrasi Umum

### Masalah: Frontend tidak bisa connect ke Backend
**Solusi**:
1. Cek backend berjalan: `http://127.0.0.1:8000/docs`
2. Verifikasi CORS settings di `app/main.py`
3. Cek API base URL di config frontend

### Masalah: Database connection error
**Solusi**:
1. Verifikasi PostgreSQL sedang running
2. Cek credentials file `.env`
3. Jalankan: `python test_db_connection.py`

### Masalah: Flutter build errors
**Solusi**:
1. Jalankan: `flutter clean && flutter pub get`
2. Cek `pubspec.yaml` untuk konflik versi
3. Update Flutter: `flutter upgrade`

---

## Dokumen Referensi
- **PRD**: `d:\Kuliah\MAGANG IROSTECH\nex_app\PRD NEX PROJECT.pdf`
- **Proposal**: `d:\Kuliah\MAGANG IROSTECH\nex_app\NEX Proposal.pdf`
- **Implementation Plan**: `d:\Kuliah\MAGANG IROSTECH\implementation_plan.md`
- **Backend README**: `d:\Kuliah\MAGANG IROSTECH\nex_backend\README.md`
- **Frontend README**: `d:\Kuliah\MAGANG IROSTECH\nex_app\README.md`

---

## Referensi Perintah Cepat

```bash
# Backend
cd "d:\Kuliah\MAGANG IROSTECH\nex_backend"
.\venv\Scripts\activate
uvicorn app.main:app --reload

# Frontend Web
cd "d:\Kuliah\MAGANG IROSTECH\nex_app"
flutter run -d chrome

# Frontend Mobile (Android)
flutter run

# Database
python test_db_connection.py
python create_tables.py
```
