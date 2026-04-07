# 🏗️ NEX ERP — Arsitektur Rantai Data & Alur Peran

> **Prinsip Utama**: Setiap role hanya mengelola tahap data miliknya.
> Output satu tahap = Input tahap berikutnya. Single Source of Truth.

---

## 1. Peta Alur Besar (Role → Data Chain)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        NEX ERP DATA CHAIN                               │
├──────────────┬──────────────┬──────────────┬────────┬────────┬──────────┤
│   PANEN      │   TIMBANG    │   PRODUKSI   │  STOK  │  JUAL  │  UANG   │
│  (Harvest)   │  (Weighing)  │ (Processing) │ (Stock)│ (Sales)│(Finance)│
├──────────────┼──────────────┼──────────────┼────────┼────────┼──────────┤
│ Field Officer│Estate Manager│ Mill Manager │  Mill  │ Sales  │ Finance  │
│              │              │              │Manager │Officer │ Manager  │
└──────┬───────┴──────┬───────┴──────┬───────┴───┬────┴───┬────┴────┬─────┘
       │              │              │           │        │         │
       ▼              ▼              ▼           ▼        ▼         ▼
   Production → Weighbridge → MillProdLog → Inventory → Sales → Finance
   (harvest)    Entry          (CPO/Kernel)  (stock)   Contract  (Revenue
                                                       Shipment   Expense
                                                                  Payroll)
       │              │              │           │        │         │
       └──────────────┴──────────────┴───────────┴────────┴─────────┘
                              │
                         ┌────▼────┐
                         │  ADMIN  │
                         │ (Full   │
                         │ Monitor)│
                         └─────────┘
```

---

## 2. Detail Per Tahap

### TAHAP 1: PANEN (Harvest) — Field Officer

| Aspek | Detail |
|-------|--------|
| **Role** | `field_officer` |
| **Model Backend** | `Production` (table: `production`) |
| **Input** | Block ID, Product ID, Quantity, Quality Grade |
| **Output** | Record harvest → status `Harvested` |
| **API Endpoint** | `POST /api/v1/production/harvest` |
| **RBAC** | Hanya `field_officer` yang bisa CREATE harvest |
| **Validasi** | Block harus ada, quantity > 0, date ≤ hari ini |

**Data yang dihasilkan:**
```json
{
  "block_id": "uuid",
  "product_id": "uuid (FFB)",
  "quantity": 12.5,
  "unit": "Tons",
  "quality_grade": "Grade A",
  "status": "Harvested",
  "harvested_by": "uuid (field_officer)"
}
```

**Output → Input berikutnya:** `production.id` + `production.quantity` menjadi referensi saat timbang di pabrik.

---

### TAHAP 2: TIMBANG (Weighbridge) — Estate Manager

| Aspek | Detail |
|-------|--------|
| **Role** | `estate_manager` |
| **Model Backend** | `MillWeighbridgeEntry` (table: `mill_weighbridge_entries`) |
| **Input dari Tahap 1** | `estate_origin`, `block_origin` (dari Production) |
| **Output** | Netto berat FFB (weight_in - weight_out) |
| **API Endpoint** | `POST /api/v1/mills/weighbridge` |
| **RBAC** | Hanya `estate_manager` yang bisa CREATE/UPDATE weighbridge |
| **Validasi** | weight_in > 0, vehicle_plate wajib, grading total = 100% |

**Alur Timbang:**
```
Truk masuk → WeighIn (berat kotor)
    → Bongkar FFB
        → WeighOut (berat tarra)
            → Netto = In - Out
                → Grading (% ripe, unripe, overripe)
                    → Status: Completed
```

**Output → Input berikutnya:** `netto_kg` + `grading_%` menjadi `ffb_processed_kg` di MillProductionLog.

---

### TAHAP 3: PRODUKSI (Mill Processing) — Mill Manager

| Aspek | Detail |
|-------|--------|
| **Role** | `mill_manager` |
| **Model Backend** | `MillProductionLog` (table: `mill_production_logs`) |
| **Input dari Tahap 2** | `ffb_processed_kg` (sum netto dari weighbridge) |
| **Output** | CPO (kg), Kernel (kg), OER%, KER% |
| **API Endpoint** | `POST /api/v1/mills/{mill_id}/production` |
| **RBAC** | Hanya `mill_manager` yang bisa CREATE production log |
| **Validasi** | CPO + Kernel + Shell + Fiber + Effluent ≤ FFB input |

**Kalkulasi Otomatis:**
```python
oer_pct = (cpo_produced_kg / ffb_processed_kg) * 100
ker_pct = (kernel_produced_kg / ffb_processed_kg) * 100
throughput = ffb_processed_kg / hours_in_shift
```

**Output → Input berikutnya:** `cpo_produced_kg` dan `kernel_produced_kg` → auto masuk Inventory sebagai stock IN.

---

### TAHAP 4: STOK (Inventory) — Mill Manager

| Aspek | Detail |
|-------|--------|
| **Role** | `mill_manager` |
| **Model Backend** | `Inventory` + `InventoryMovement` |
| **Input dari Tahap 3** | Auto-create movement IN saat production log approved |
| **Output** | Current stock (CPO, Kernel, Shell) |
| **API Endpoint** | `GET /api/v1/inventory/`, `POST /api/v1/inventory/movements` |
| **RBAC** | `mill_manager` manage stock, `sales_officer` READ only |

**Auto-Movement dari Produksi:**
```json
{
  "product_id": "uuid (CPO)",
  "movement_type": "IN",
  "quantity": 3500.0,
  "reference_type": "MillProductionLog",
  "reference_id": "uuid"
}
```

**Output → Input berikutnya:** `Product.current_stock` menentukan jumlah yang bisa dijual Sales.

---

### TAHAP 5: JUAL (Sales) — Sales Officer

| Aspek | Detail |
|-------|--------|
| **Role** | `sales_officer` |
| **Model Backend** | `SalesContract` + `SalesShipment` |
| **Input dari Tahap 4** | Available stock (READ Inventory) |
| **Output** | Contract value, Shipment record, total_price |
| **API Endpoint** | `POST /api/v1/sales/contracts`, `POST /api/v1/sales/shipments` |
| **RBAC** | Hanya `sales_officer` yang bisa CREATE contract/shipment |
| **Validasi** | quantity_shipped ≤ current_stock |

**Alur Penjualan:**
```
Cek Stok → Buat Contract → Buat Shipment → Quality Check
    → Hitung final_price (base ± FFA/moisture penalty)
        → Auto stock OUT via InventoryMovement
            → Status: Invoiced
```

**Auto-Movement saat Shipment:**
```json
{
  "product_id": "uuid (CPO)",
  "movement_type": "OUT",
  "quantity": 25.0,
  "reference_type": "SalesShipment",
  "reference_id": "uuid"
}
```

**Output → Input berikutnya:** `total_price` dari shipment → Revenue di Finance.

---

### TAHAP 6: UANG (Finance) — Finance Manager

| Aspek | Detail |
|-------|--------|
| **Role** | `finance_manager` |
| **Model Backend** | `Expense`, `Payroll`, `Budget`, `BudgetLine` |
| **Input dari Tahap 5** | Revenue dari SalesShipment.total_price |
| **Input dari Tahap 3** | Production cost (utility, labour) |
| **Output** | P&L Report, Cash Flow, Budget vs Actual |
| **API Endpoint** | `GET /api/v1/finance/`, `GET /api/v1/reports/` |
| **RBAC** | `finance_manager` full CRUD, others READ summary only |

**Finance menarik data dari:**
```
┌─────────────┐     ┌──────────────────────────────┐
│  Sales      │────→│ Revenue = SUM(total_price)   │
│  Shipments  │     │   WHERE status = 'Invoiced'  │
└─────────────┘     └──────────────────────────────┘

┌─────────────┐     ┌──────────────────────────────┐
│  Production │────→│ Cost = utility + labour +    │
│  Logs       │     │   maintenance per shift       │
└─────────────┘     └──────────────────────────────┘

┌─────────────┐     ┌──────────────────────────────┐
│  Expenses   │────→│ OpEx per category per estate │
└─────────────┘     └──────────────────────────────┘

  Profit = Revenue - (Production Cost + OpEx + Payroll)
```

---

### ADMIN — Full Monitor

| Aspek | Detail |
|-------|--------|
| **Role** | `admin` |
| **Akses** | READ semua tahap + CRUD Users + Audit Log |
| **Dashboard** | Aggregat semua 6 tahap dalam 1 view |
| **API** | `GET /api/v1/admin/pipeline-status` |
| **Superpower** | Override status, force-approve, manage roles |

---

## 3. RBAC Permission Matrix

```
Endpoint/Action           FO   EM   MM   SO   FM   Admin
─────────────────────────────────────────────────────────
POST harvest              ✅   ❌   ❌   ❌   ❌   ✅
GET  harvest              ✅   ✅   ❌   ❌   ❌   ✅
POST weighbridge          ❌   ✅   ❌   ❌   ❌   ✅
GET  weighbridge          ❌   ✅   ✅   ❌   ❌   ✅
POST mill production      ❌   ❌   ✅   ❌   ❌   ✅
GET  mill production      ❌   ❌   ✅   ❌   ✅   ✅
GET  inventory            ❌   ❌   ✅   ✅   ✅   ✅
POST inventory movement   ❌   ❌   ✅   ❌   ❌   ✅
POST sales contract       ❌   ❌   ❌   ✅   ❌   ✅
POST sales shipment       ❌   ❌   ❌   ✅   ❌   ✅
GET  sales                ❌   ❌   ❌   ✅   ✅   ✅
GET  finance/reports      ❌   ❌   ❌   ❌   ✅   ✅
POST expense              ❌   ❌   ❌   ❌   ✅   ✅
POST payroll              ❌   ❌   ❌   ❌   ✅   ✅
GET  audit logs           ❌   ❌   ❌   ❌   ❌   ✅
CRUD users                ❌   ❌   ❌   ❌   ❌   ✅

FO=Field Officer, EM=Estate Manager, MM=Mill Manager,
SO=Sales Officer, FM=Finance Manager
```

---

## 4. Data Flow Chain — Kunci Sambungan Antar Tahap

```
TAHAP 1→2:  Production.block_id → WeighbridgeEntry.block_origin
            Production.quantity  → Validasi netto weighbridge

TAHAP 2→3:  SUM(WeighbridgeEntry.netto_kg) WHERE status='Completed'
            → MillProductionLog.ffb_processed_kg

TAHAP 3→4:  MillProductionLog.cpo_produced_kg
            → InventoryMovement(type=IN, ref=MillProductionLog)
            → Product.current_stock += quantity

TAHAP 4→5:  Product.current_stock → Validasi SalesShipment.quantity
            SalesShipment(confirmed)
            → InventoryMovement(type=OUT, ref=SalesShipment)
            → Product.current_stock -= quantity

TAHAP 5→6:  SUM(SalesShipment.total_price) → Revenue
            + Production cost + Expense → P&L
```

---

## 5. Backend: Perubahan yang Diperlukan

### 5a. Tambah RBAC Middleware (`app/api/deps.py`)

```python
from functools import wraps
from fastapi import HTTPException, status

ROLE_PERMISSIONS = {
    "field_officer":    ["harvest.create", "harvest.read"],
    "estate_manager":   ["weighbridge.create", "weighbridge.read", "harvest.read"],
    "mill_manager":     ["mill_prod.create", "mill_prod.read",
                         "inventory.create", "inventory.read",
                         "weighbridge.read"],
    "sales_officer":    ["sales.create", "sales.read", "inventory.read"],
    "finance_manager":  ["finance.create", "finance.read",
                         "sales.read", "mill_prod.read", "reports.read"],
    "admin":            ["*"],  # Wildcard = full access
}

def require_permission(permission: str):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, current_user=None, **kwargs):
            user_perms = ROLE_PERMISSIONS.get(current_user.role, [])
            if "*" not in user_perms and permission not in user_perms:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Role '{current_user.role}' lacks '{permission}'"
                )
            return await func(*args, current_user=current_user, **kwargs)
        return wrapper
    return decorator
```

### 5b. Auto Stock Movement saat Production Approved

```python
# Di crud_mill.py — saat status production log → "Approved"
async def approve_production_log(db, log_id, approved_by):
    log = db.query(MillProductionLog).get(log_id)
    log.status = "Approved"
    log.approved_by_id = approved_by.id

    # Auto-create Inventory IN movements
    for product_type, qty_field in [
        ("CPO", log.cpo_produced_kg),
        ("Kernel", log.kernel_produced_kg),
    ]:
        product = db.query(Product).filter(Product.name == product_type).first()
        if product and qty_field > 0:
            movement = InventoryMovement(
                product_id=product.id,
                movement_type="IN",
                quantity=qty_field,
                reference_type="MillProductionLog",
                reference_id=str(log.id),
            )
            db.add(movement)
            product.current_stock += qty_field

    db.commit()
```

### 5c. Auto Stock OUT saat Shipment Confirmed

```python
# Di crud_sales.py — saat shipment status → "Confirmed"
async def confirm_shipment(db, shipment_id):
    shipment = db.query(SalesShipment).get(shipment_id)
    product = shipment.product

    if product.current_stock < shipment.quantity_shipped * 1000:
        raise HTTPException(400, "Insufficient stock")

    movement = InventoryMovement(
        product_id=product.id,
        movement_type="OUT",
        quantity=shipment.quantity_shipped * 1000,
        reference_type="SalesShipment",
        reference_id=str(shipment.id),
    )
    db.add(movement)
    product.current_stock -= shipment.quantity_shipped * 1000
    shipment.status = "Confirmed"
    db.commit()
```

### 5d. Finance Aggregation Endpoint

```python
# Endpoint baru: GET /api/v1/finance/pipeline-summary
@router.get("/pipeline-summary")
async def get_pipeline_summary(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
    period_start: date = Query(...),
    period_end: date = Query(...),
):
    require_role(current_user, ["finance_manager", "admin"])

    revenue = db.query(func.sum(SalesShipment.total_price))\
        .filter(SalesShipment.status == "Invoiced",
                SalesShipment.shipment_date.between(period_start, period_end))\
        .scalar() or 0

    expenses = db.query(func.sum(Expense.amount))\
        .filter(Expense.date.between(period_start, period_end))\
        .scalar() or 0

    payroll = db.query(func.sum(Payroll.total_amount))\
        .filter(Payroll.status == "Paid",
                Payroll.period_end.between(period_start, period_end))\
        .scalar() or 0

    return {
        "period": {"start": period_start, "end": period_end},
        "revenue": revenue,
        "expenses": expenses,
        "payroll": payroll,
        "profit": revenue - expenses - payroll,
    }
```

---

## 6. Frontend: Route per Role

```dart
// main.dart — Route mapping
GoRoute(path: '/field-officer',   builder: → FieldOfficerDashboard)   // Harvest
GoRoute(path: '/manager/estate',  builder: → EstateManagerDashboard)  // Weighbridge
GoRoute(path: '/manager/mill',    builder: → MillManagerDashboard)    // Production+Stock
GoRoute(path: '/manager/sales',   builder: → SalesOfficerDashboard)   // Sales
GoRoute(path: '/manager/finance', builder: → FinanceManagerDashboard) // Finance
GoRoute(path: '/dashboard',       builder: → AdminDashboardScreen)    // Full Monitor
```

---

## 7. Audit Trail di Setiap Tahap

Setiap operasi CRUD mencatat ke `audit_logs`:

```json
{
  "user_id": "uuid",
  "action": "CREATE",
  "module": "HARVEST",
  "description": "Field Officer created harvest record for Block A01",
  "payload": { "quantity": 12.5, "block": "A01" }
}
```

---

## 8. Ringkasan: Mengapa Desain Ini Solid

| Prinsip | Implementasi |
|---------|-------------|
| **Separation of Concern** | Setiap role hanya punya akses ke tahap miliknya |
| **Data Continuity** | FK dan referensi antar tabel memastikan rantai tak putus |
| **Single Source of Truth** | `Product.current_stock` di-update via Movement, bukan manual |
| **Auditability** | Setiap aksi tercatat di `audit_logs` |
| **Approval Workflow** | Sistem multi-level approval sudah ada di `approval_*` tables |
| **Finance Cross-Reference** | Finance query langsung ke Sales + Production, bukan copy data |
