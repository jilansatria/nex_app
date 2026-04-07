---
description: Panduan Pengembangan Modul Backend
---

# Workflow Pengembangan Modul Backend NEX

Workflow detail untuk pengembangan modul backend NEX menggunakan FastAPI + PostgreSQL.

## Template Pengembangan Modul

Untuk setiap modul baru, ikuti struktur ini:

### Langkah 1: Definisikan Model Database
**Lokasi**: `app/models/[nama_modul].py`

```python
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.db.base_class import Base
from datetime import datetime

class [NamaModel](Base):
    __tablename__ = "[nama_tabel]"
    
    id = Column(Integer, primary_key=True, index=True)
    # Tambahkan field berdasarkan kebutuhan PRD
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    created_by = Column(Integer, ForeignKey("users.id"))
    
    # Relationships
    creator = relationship("User", back_populates="[nama_modul]s")
```

### Langkah 2: Buat Pydantic Schemas
**Lokasi**: `app/schemas/[nama_modul].py`

```python
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

# Base schema
class [NamaModel]Base(BaseModel):
    # Field umum
    pass

# Create schema (untuk POST requests)
class [NamaModel]Create([NamaModel]Base):
    # Field wajib untuk pembuatan
    pass

# Update schema (untuk PUT/PATCH requests)
class [NamaModel]Update([NamaModel]Base):
    # Semua field optional untuk update
    pass

# Response schema (yang dikembalikan API)
class [NamaModel]Response([NamaModel]Base):
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
```

### Langkah 3: Implementasi Operasi CRUD
**Lokasi**: `app/crud/crud_[nama_modul].py`

```python
from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.[nama_modul] import [NamaModel]
from app.schemas.[nama_modul] import [NamaModel]Create, [NamaModel]Update

class CRUD[NamaModel]:
    def get(self, db: Session, id: int) -> Optional[NamaModel]:
        return db.query([NamaModel]).filter([NamaModel].id == id).first()
    
    def get_multi(self, db: Session, skip: int = 0, limit: int = 100) -> List[[NamaModel]]:
        return db.query([NamaModel]).offset(skip).limit(limit).all()
    
    def create(self, db: Session, obj_in: [NamaModel]Create, user_id: int) -> [NamaModel]:
        db_obj = [NamaModel](**obj_in.dict(), created_by=user_id)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj
    
    def update(self, db: Session, db_obj: [NamaModel], obj_in: [NamaModel]Update) -> [NamaModel]:
        update_data = obj_in.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_obj, field, value)
        db.commit()
        db.refresh(db_obj)
        return db_obj
    
    def delete(self, db: Session, id: int) -> [NamaModel]:
        obj = db.query([NamaModel]).get(id)
        db.delete(obj)
        db.commit()
        return obj

[nama_modul] = CRUD[NamaModel]()
```

### Langkah 4: Buat API Endpoints
**Lokasi**: `app/api/endpoints/[nama_modul].py`

```python
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.api import deps
from app.crud.crud_[nama_modul] import [nama_modul]
from app.schemas.[nama_modul] import [NamaModel]Create, [NamaModel]Update, [NamaModel]Response
from app.models.user import User

router = APIRouter()

@router.get("/", response_model=List[[NamaModel]Response])
def get_[nama_modul]s(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """Dapatkan semua [nama_modul]"""
    items = [nama_modul].get_multi(db, skip=skip, limit=limit)
    return items

@router.get("/{id}", response_model=[NamaModel]Response)
def get_[nama_modul](
    id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """Dapatkan [nama_modul] berdasarkan ID"""
    item = [nama_modul].get(db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="[NamaModel] tidak ditemukan")
    return item

@router.post("/", response_model=[NamaModel]Response)
def create_[nama_modul](
    item_in: [NamaModel]Create,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """Buat [nama_modul] baru"""
    item = [nama_modul].create(db, obj_in=item_in, user_id=current_user.id)
    return item

@router.put("/{id}", response_model=[NamaModel]Response)
def update_[nama_modul](
    id: int,
    item_in: [NamaModel]Update,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """Update [nama_modul]"""
    item = [nama_modul].get(db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="[NamaModel] tidak ditemukan")
    item = [nama_modul].update(db, db_obj=item, obj_in=item_in)
    return item

@router.delete("/{id}")
def delete_[nama_modul](
    id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """Hapus [nama_modul]"""
    item = [nama_modul].delete(db, id=id)
    return {"message": "[NamaModel] berhasil dihapus"}
```

### Langkah 5: Daftarkan Routes
**Lokasi**: `app/api/api.py`

```python
from fastapi import APIRouter
from app.api.endpoints import auth, users, [nama_modul]

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router([nama_modul].router, prefix="/[nama_modul]", tags=["[nama_modul]"])
```

### Langkah 6: Migrasi Database
```bash
# Buat migration
alembic revision --autogenerate -m "Tambah tabel [nama_modul]"

# Review file migration di alembic/versions/

# Terapkan migration
alembic upgrade head
```

### Langkah 7: Test API
// turbo
```bash
cd "d:\Kuliah\MAGANG IROSTECH\nex_backend"
.\venv\Scripts\activate
uvicorn app.main:app --reload
```

Buka browser: `http://127.0.0.1:8000/docs`
Test endpoints:
- GET `/[nama_modul]/` - List semua
- POST `/[nama_modul]/` - Buat baru
- GET `/[nama_modul]/{id}` - Dapatkan berdasarkan ID
- PUT `/[nama_modul]/{id}` - Update
- DELETE `/[nama_modul]/{id}` - Hapus

---

## Contoh Modul Spesifik (Berdasarkan PRD)

### Contoh 1: Modul Field (Entry Panen)

**Model**: `HarvestEntry`
Field:
- estate_id (FK)
- block_id
- date
- janjang_count (Integer) - jumlah janjang
- weight_kg (Float) - berat dalam kg
- worker_id (FK)
- gps_coordinates (String)
- photo_url (String, optional)
- is_synced (Boolean, untuk dukungan offline)

**Kebutuhan Khusus**:
- Harus mendukung entry offline (frontend yang handle ini)
- Backend validasi GPS dalam batas estate
- Auto-calculate statistik per block

### Contoh 2: Modul Production (Tracking Hasil)

**Model**: `ProductionYield`
Field:
- mill_id (FK)
- production_date
- FFB_input_kg (Fresh Fruit Bunch - TBS)
- CPO_output_kg (Crude Palm Oil - CPO)
- OER_percentage (Oil Extraction Rate)
- KER_percentage (Kernel Extraction Rate)
- weather_condition
- shift (pagi/siang/malam)

**Kebutuhan Khusus**:
- Auto-calculate OER = (CPO_output / FFB_input) * 100
- Integrasi dengan data timbangan
- Generasi laporan harian

### Contoh 3: Human Resources (Payroll)

**Model**: `PayrollEntry`
Field:
- employee_id (FK)
- period_start, period_end
- base_salary
- piece_rate_total (untuk pemanen)
- attendance_days
- deductions
- total_payment
- payment_status

**Kebutuhan Khusus**:
- Dukungan perhitungan piece-rate untuk pekerja lapangan
- Integrasi presensi biometrik
- Perhitungan pajak berdasarkan regulasi Indonesia

---

## Checklist Testing (Per Modul)

- [ ] Semua operasi CRUD berfungsi
- [ ] Autentikasi diperlukan untuk semua endpoints
- [ ] Role-based access control diterapkan
- [ ] Validasi input berfungsi (Pydantic)
- [ ] Error handling mengembalikan HTTP codes yang tepat
- [ ] Foreign key constraints diterapkan
- [ ] Database transactions rollback saat error
- [ ] Dokumentasi API auto-generated di /docs
- [ ] Response models sesuai database schema
- [ ] Created/Updated timestamps terisi otomatis

---

## Masalah Umum & Solusi

### Masalah: Foreign key constraint error
**Solusi**: Pastikan tabel/record yang direferensikan ada sebelum membuat

### Masalah: Pydantic validation error
**Solusi**: Cek schema sesuai model, gunakan Optional untuk nullable fields

### Masalah: Import circular dependency
**Solusi**: Gunakan string references di relationships, import TYPE_CHECKING

### Masalah: Migration conflict
**Solusi**: 
```bash
alembic downgrade -1
# Perbaiki file migration
alembic upgrade head
```
