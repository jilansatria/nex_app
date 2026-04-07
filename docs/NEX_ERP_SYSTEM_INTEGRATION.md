# 🏭 NEX ERP — Dokumen Integrasi Sistem Terpadu

> **Tanggal**: 20 Februari 2026
> **Versi**: 2.0 — Implementasi Aktual
> **Prinsip Utama**: Single Source of Truth | Zero Process Skip | Full Audit Trail

---

## 1. RINGKASAN ARSITEKTUR RANTAI DATA

Sistem NEX ERP menghubungkan **6 tahap operasional** secara berurutan, di mana
output dari satu tahap menjadi input satu-satunya untuk tahap berikutnya.
Tidak ada lompatan proses — data panen **TIDAK** bisa langsung masuk ke Sales atau Finance.

```
╔══════════════════════════════════════════════════════════════════════════════════╗
║                         NEX ERP — RANTAI DATA TERPADU                          ║
╠═══════════╦═══════════╦═══════════╦══════════╦══════════╦════════════╦══════════╣
║  TAHAP 1  ║  TAHAP 2  ║  TAHAP 3  ║ TAHAP 4  ║ TAHAP 5  ║  TAHAP 6   ║ KONTROL ║
║  PANEN    ║  TIMBANG  ║ PRODUKSI  ║   STOK   ║   JUAL   ║   UANG     ║  ADMIN  ║
║ (Harvest) ║ (Weigh)   ║ (Process) ║ (Stock)  ║ (Sales)  ║ (Finance)  ║(Monitor)║
╠═══════════╬═══════════╬═══════════╬══════════╬══════════╬════════════╬══════════╣
║  Field    ║  Estate   ║   Mill    ║   Mill   ║  Sales   ║  Finance   ║  Admin   ║
║  Officer  ║  Manager  ║  Manager  ║  Manager ║  Officer ║  Manager   ║         ║
╠═══════════╩═══════════╩═══════════╩══════════╩══════════╩════════════╩══════════╣
║                                                                                ║
║  Production ──▶ WeighbridgeEntry ──▶ MillProductionLog ──▶ Product.current_stock║
║  (harvest)        (netto_kg)         (CPO/Kernel kg)       (InventoryMovement)  ║
║                                                                ▼               ║
║                                                   SalesShipment──▶ Finance     ║
║                                                   (total_price)   (Revenue +   ║
║                                                                    Expense +   ║
║                                                                    Payroll)    ║
║                                                                                ║
║  ╔════════════════════════════════════════════════════════════════╗             ║
║  ║  audit_logs: SETIAP operasi CREATE/UPDATE/APPROVE/CONFIRM    ║             ║
║  ║  dicatat lengkap dengan user_id, action, module, payload     ║             ║
║  ╚════════════════════════════════════════════════════════════════╝             ║
╚════════════════════════════════════════════════════════════════════════════════╝
```

---

## 2. DETAIL INTEGRASI PER TAHAP

---

### TAHAP 1: 🌿 PANEN (Harvest)

| Aspek | Implementasi Aktual |
|-------|-------------------|
| **Role** | `field_officer` |
| **Permission RBAC** | `HARVEST_INPUT`, `ESTATE_READ`, `PRODUCTION_READ` |
| **Model Database** | `Production` (table: `production`) |
| **Modul Backend** | `app/api/v1/endpoints/production.py` |
| **Modul Frontend** | `HarvestEntryScreen` (user dashboard) |
| **API Endpoint** | `POST /api/v1/production/harvest` |

**Data yang Dihasilkan:**

| Field | Tipe | Deskripsi |
|-------|------|-----------|
| `id` | UUID | Primary key, auto-generated |
| `block_id` | UUID (FK→blocks) | Blok kebun asal panen |
| `product_id` | UUID (FK→products) | Produk = FFB (Fresh Fruit Bunch) |
| `quantity` | Float | Jumlah panen dalam Tons |
| `quality_grade` | String | Grade A / Grade B / Unripe |
| `status` | String | `Harvested` (initial) |
| `harvested_by` | UUID (FK→users) | ID Field Officer yang input |
| `date` | DateTime | Tanggal panen |

**Mekanisme Input:**
```
Field Officer membuka HarvestEntryScreen
    → Pilih Block (dropdown dari GET /api/v1/estates/blocks)
    → Pilih Product (FFB)
    → Input Quantity + Quality Grade
    → Submit → POST /api/v1/production/harvest
    → Record tersimpan dengan status = "Harvested"
    → Audit log: CREATE | HARVEST | "Field Officer created harvest for Block X"
```

**Output → Tahap Berikutnya:**
- `Production.block_id` → digunakan Estate Manager sebagai `block_origin` saat timbang
- `Production.quantity` → referensi validasi: apakah berat netto timbangan realistis

**Validasi Proses:**
- Block harus terdaftar di sistem (`blocks.id` valid)
- `quantity > 0`
- `date ≤ hari_ini` (tidak bisa input masa depan)
- Hanya role `field_officer` yang bisa CREATE (RBAC enforced by `RoleChecker`)

**Batasan RBAC — Mencegah Lompatan:**
- Field Officer **TIDAK** memiliki permission `SALES_WRITE`, `FINANCE_WRITE`, `MILL_WRITE`
- Data panen hanya bisa dibaca oleh tahap selanjutnya (Estate Manager punya `PRODUCTION_READ`)

---

### TAHAP 2: ⚖️ TIMBANG (Weighbridge)

| Aspek | Implementasi Aktual |
|-------|-------------------|
| **Role** | `estate_manager` |
| **Permission RBAC** | `MILL_WEIGHBRIDGE`, `MILL_READ`, `ESTATE_READ/WRITE` |
| **Model Database** | `MillWeighbridgeEntry` (table: `mill_weighbridge_entries`) |
| **Modul Backend** | `app/api/v1/endpoints/mill.py` |
| **Modul Frontend** | `WeighbridgeWidget` (estate_manager sidebar index 3) |
| **API Endpoints** | `POST /api/v1/mills/weighbridge` (WeighIn), `PUT /api/v1/mills/weighbridge/{id}/out` (WeighOut) |

**Data yang Dihasilkan:**

| Field | Tipe | Deskripsi |
|-------|------|-----------|
| `id` | UUID | Primary key |
| `mill_id` | UUID (FK→mills) | Pabrik tujuan |
| `ticket_no` | String | Auto-generated, unique |
| `vehicle_plate` | String | Plat nomor truk |
| `estate_origin` | String | **Referensi dari Tahap 1** — Asal kebun |
| `block_origin` | String | **Referensi dari Tahap 1** — Blok asal |
| `weight_in_kg` | Float | Berat kotor (truk + FFB) |
| `weight_out_kg` | Float | Berat kosong (truk saja) |
| `netto_kg` | Float | **COMPUTED: In - Out** |
| `grading_ripe_pct` | Float | % buah masak |
| `grading_unripe_pct` | Float | % buah mentah |
| `grading_overripe_pct` | Float | % buah lewat masak |
| `status` | String | `WeighIn` → `Completed` |

**Alur Proses:**
```
Truk FFB dari kebun tiba di pabrik
    ┌─ WeighIn ─────────────────────────────────────┐
    │  POST /mills/weighbridge                       │
    │  • vehicle_plate, estate_origin, block_origin  │
    │  • weight_in_kg (berat kotor)                  │
    │  • status = "WeighIn"                          │
    │  • Audit: CREATE | WEIGHBRIDGE                 │
    └────────────────────────┬───────────────────────┘
                             │ (truk bongkar FFB)
    ┌─ WeighOut ─────────────┴───────────────────────┐
    │  PUT /mills/weighbridge/{id}/out               │
    │  • weight_out_kg (berat tarra)                 │
    │  • netto_kg = weight_in_kg - weight_out_kg     │
    │  • grading_%  = input manual operator          │
    │  • status = "Completed"                        │
    │  • Audit: UPDATE | WEIGHBRIDGE                 │
    └────────────────────────────────────────────────┘
```

**Koneksi ke Tahap 1 (PANEN → TIMBANG):**
- `estate_origin` + `block_origin` merujuk ke `Production.block_id`
- Operator bisa cross-check: apakah ada record harvest dari blok tersebut hari ini

**Output → Tahap Berikutnya:**
- `SUM(netto_kg) WHERE status='Completed'` → menjadi `ffb_processed_kg` di Tahap 3
- Data grading (ripe/unripe/overripe %) → referensi kualitas FFB di pabrik

**Validasi Proses:**
- `weight_in_kg > 0`
- `vehicle_plate` wajib diisi
- `weight_out_kg <= weight_in_kg` (berat kosong tidak boleh > berat isi)
- Total grading harus logis (sum ≤ 100%)

---

### TAHAP 3: 🏭 PRODUKSI (Mill Processing)

| Aspek | Implementasi Aktual |
|-------|-------------------|
| **Role** | `mill_manager` |
| **Permission RBAC** | `MILL_READ/WRITE`, `MILL_LOGSHEET`, `PRODUCTION_READ/WRITE`, `INVENTORY_READ/WRITE` |
| **Model Database** | `MillProductionLog` (table: `mill_production_logs`) |
| **Modul Backend** | `app/api/v1/endpoints/mill.py` |
| **Modul Frontend** | `ProductionLogWidget` (mill_manager sidebar index 1) |
| **API Endpoints** | `POST /mills/production/log` (create), `PUT /mills/production/{id}/approve` (**trigger otomatis**) |

**Data yang Dihasilkan:**

| Field | Tipe | Deskripsi |
|-------|------|-----------|
| `mill_id` | UUID (FK→mills) | Pabrik pelaksana |
| `date` | DateTime | Tanggal produksi |
| `shift` | String | Shift 1/2/3 |
| `ffb_processed_kg` | Float | **Input dari Tahap 2** — Total FFB diolah |
| `cpo_produced_kg` | Float | Output CPO (kg) |
| `kernel_produced_kg` | Float | Output Kernel (kg) |
| `shell_produced_kg` | Float | Output Cangkang (kg) |
| `fiber_produced_kg` | Float | Output Serabut (kg) |
| `oer_pct` | Float | **Auto-calc**: (CPO / FFB) × 100 |
| `ker_pct` | Float | **Auto-calc**: (Kernel / FFB) × 100 |
| `throughput_ton_hr` | Float | Throughput efisiensi |
| `steam_pressure_bar` | Float | Tekanan boiler (utilitas) |
| `power_consumption_kwh` | Float | Konsumsi listrik (biaya) |
| `status` | String | `Draft` → `Approved` |

**Koneksi ke Tahap 2 (TIMBANG → PRODUKSI):**
```python
# Kalkulasi otomatis saat create:
oer_pct = (cpo_produced_kg / ffb_processed_kg) * 100
ker_pct = (kernel_produced_kg / ffb_processed_kg) * 100

# ffb_processed_kg HARUS berasal dari akumulasi netto_kg weighbridge
# pada tanggal & shift yang bersangkutan
```

**⚡ MEKANISME KRITIS: Approval → Auto Stock Update**

Ini adalah **titik integrasi paling penting** dalam rantai data: PRODUKSI → STOK.
Ketika Mill Manager menekan tombol **"Approve Log"**, sistem secara otomatis:

```python
# file: app/api/v1/endpoints/mill.py — approve_production_log()

log.status = "Approved"
log.approved_by_id = current_user.id

# ── AUTO: Inventory IN untuk CPO ──
cpo_product = db.query(Product).filter(Product.name == "CPO").first()
if cpo_product and log.cpo_produced_kg > 0:
    inventory.adjust_stock(
        db, product_id=cpo_product.id,
        quantity=log.cpo_produced_kg,          # Positif = masuk
        batch_id=f"CPO-{date}-{shift}",
        reference_type="MillProductionLog",    # Traceability
        reference_id=str(log.id),              # Link ke log asli
        user_id=current_user.id,
    )

# ── AUTO: Inventory IN untuk Kernel ──
kernel_product = db.query(Product).filter(Product.name == "Kernel").first()
if kernel_product and log.kernel_produced_kg > 0:
    inventory.adjust_stock(
        db, product_id=kernel_product.id,
        quantity=log.kernel_produced_kg,
        batch_id=f"KER-{date}-{shift}",
        reference_type="MillProductionLog",
        reference_id=str(log.id),
        user_id=current_user.id,
    )

# ── AUDIT LOG ──
audit_log.create(
    db, user_id=current_user.id,
    action="APPROVE", module="MILL_PRODUCTION",
    description=f"Approved production log: CPO={cpo_kg}kg, Kernel={kernel_kg}kg",
    payload={"log_id": str(log_id), "cpo_kg": ..., "kernel_kg": ...}
)
```

**Output → Tahap Berikutnya:**
- `Product.current_stock` (CPO) **bertambah otomatis** via `InventoryMovement(type=IN)`
- `Product.current_stock` (Kernel) **bertambah otomatis** via `InventoryMovement(type=IN)`
- Data ini langsung terlihat oleh Sales Officer

**Validasi Proses:**
- Hanya status `Draft` yang bisa di-approve (idempotent)
- `CPO + Kernel + Shell + Fiber + Effluent ≤ FFB` (mass balance)
- Approval bersifat **irreversible** — sekali approve, stok sudah berubah

---

### TAHAP 4: 📦 STOK (Inventory)

| Aspek | Implementasi Aktual |
|-------|-------------------|
| **Role Utama** | `mill_manager` (WRITE), `sales_officer` (READ) |
| **Permission RBAC** | `INVENTORY_READ/WRITE` |
| **Model Database** | `Product` + `Inventory` + `InventoryMovement` |
| **Modul Backend** | `app/crud/crud_inventory.py` |
| **Tabel Kunci** | `products.current_stock` = **Single Source of Truth** untuk saldo stok |

**Mekanisme Single Source of Truth:**

Stok **TIDAK** pernah diubah secara manual. Setiap perubahan stok melalui `InventoryMovement`:

```
┌─────────────────────────────────────────────────────────────────┐
│                    InventoryMovement Records                     │
├──────────────┬────────┬────────┬─────────────────┬──────────────┤
│ movement_type│quantity│product │ reference_type   │ reference_id │
├──────────────┼────────┼────────┼─────────────────┼──────────────┤
│ IN           │ 3500.0 │ CPO    │ MillProductionLog│ uuid-log-1   │  ← Dari Tahap 3
│ IN           │ 800.0  │ Kernel │ MillProductionLog│ uuid-log-1   │  ← Dari Tahap 3
│ OUT          │-25000.0│ CPO    │ SalesShipment    │ uuid-ship-1  │  ← Ke Tahap 5
│ OUT          │-5000.0 │ Kernel │ SalesShipment    │ uuid-ship-2  │  ← Ke Tahap 5
└──────────────┴────────┴────────┴─────────────────┴──────────────┘
                            │
                            ▼
              Product.current_stock = SUM(all movements)
              → Ini yang dilihat Sales Officer sebelum menjual
```

**Sumber Masuk (IN):**
- Hanya dari `MillProductionLog.approve()` — Tahap 3

**Sumber Keluar (OUT):**
- Hanya dari `SalesShipment.confirm()` — Tahap 5

**Output → Tahap Berikutnya:**
- `Product.current_stock` → menentukan jumlah maksimum yang bisa dijual Sales Officer
- Sales Officer punya `INVENTORY_READ` untuk melihat stok saat ini

---

### TAHAP 5: 🛒 JUAL (Sales)

| Aspek | Implementasi Aktual |
|-------|-------------------|
| **Role** | `sales_officer` |
| **Permission RBAC** | `SALES_READ/WRITE`, `CONTRACT_MANAGE`, `LOGISTICS_MANAGE`, `INVENTORY_READ` |
| **Model Database** | `SalesContract` + `SalesShipment` |
| **Modul Backend** | `app/api/v1/endpoints/sales.py` |
| **Modul Frontend** | `SalesManagementWidget` (sales_officer sidebar index 1) |
| **API Endpoints** | `POST /sales/contracts`, `POST /sales/shipments`, `PUT /sales/shipments/{id}/confirm` |

**Data yang Dihasilkan:**

**SalesContract:**

| Field | Tipe | Deskripsi |
|-------|------|-----------|
| `contract_number` | String | Nomor kontrak unik |
| `buyer_name` | String | Nama pembeli |
| `product_type` | String | `CPO` / `Kernel` / `Shell` |
| `quantity_contracted` | Float | Volume kontrak (Tons) |
| `price_per_kg` | Float | Harga dasar per kg |
| `delivery_start_date` | Date | Awal periode pengiriman |
| `delivery_end_date` | Date | Akhir periode pengiriman |
| `status` | String | `Active` / `Fulfilled` / `Closed` |

**SalesShipment:**

| Field | Tipe | Deskripsi |
|-------|------|-----------|
| `contract_id` | UUID (FK) | Referensi kontrak |
| `do_number` | String | Nomor Delivery Order |
| `quantity_shipped` | Float | Jumlah dikirim (Tons) |
| `ffa_percentage` | Float | Hasil lab FFA (%) |
| `moisture_percentage` | Float | Hasil lab Moisture (%) |
| `dirt_percentage` | Float | Hasil lab Dirt (%) |
| `base_price_unit` | Float | Harga dasar dari kontrak |
| `price_adjustment` | Float | **Auto-calc**: Penalty/Bonus |
| `final_unit_price` | Float | **Auto-calc**: Base + Adjustment |
| `total_price` | Float | **Auto-calc**: Final × Qty × 1000 |
| `status` | String | `Draft` → `Confirmed` |

**Alur Proses Lengkap:**
```
┌─ 1. Buat Kontrak ────────────────────────────┐
│  POST /sales/contracts                        │
│  • Validasi: contract_number unique           │
│  • Audit: CREATE | SALES                      │
└──────────────────────┬────────────────────────┘
                       ▼
┌─ 2. Buat Shipment ───────────────────────────┐
│  POST /sales/shipments                        │
│  • Validasi: contract exists                  │
│  • Validasi: stok cukup?                      │
│    → GET Product.current_stock                │
│    → needed_kg = qty_shipped × 1000           │
│    → IF needed > available → 400 Error        │
│  • Auto-calc: price adjustment dari FFA/      │
│    moisture/dirt                               │
│  • Auto-calc: total_price                     │
│  • Audit: CREATE | SALES                      │
└──────────────────────┬────────────────────────┘
                       ▼
┌─ 3. Quality Update (Opsional) ───────────────┐
│  PUT /sales/shipments/{id}/quality            │
│  • Update FFA, moisture, dirt dari lab        │
│  • Recalculate price adjustment               │
│  • Recalculate total_price                    │
└──────────────────────┬────────────────────────┘
                       ▼
┌─ 4. Confirm Shipment ────────────────────────┐
│  PUT /sales/shipments/{id}/confirm            │
│  • IRREVERSIBLE                               │
│  • ⚡ AUTO: Inventory.adjust_stock(           │
│       quantity = -qty × 1000,                 │
│       reference_type = "SalesShipment"        │  ← STOK → JUAL link
│    )                                          │
│  • Product.current_stock -= qty               │
│  • status = "Confirmed"                       │
│  • Audit: CONFIRM | SALES                     │
│  •                                            │
│  • total_price → INILAH revenue untuk         │
│    Finance (Tahap 6)                          │  ← JUAL → UANG link
└───────────────────────────────────────────────┘
```

**Koneksi ke Tahap 4 (STOK → JUAL):**
- Sales Officer **melihat** stok via `INVENTORY_READ` permission
- Sistem **memvalidasi** stok sebelum membuat shipment
- Saat confirm, stok **berkurang otomatis** via `InventoryMovement(type=OUT)`

**Output → Tahap Berikutnya:**
- `SalesShipment.total_price` → Revenue di Finance
- `SUM(total_price WHERE status IN ['Confirmed','Invoiced'])` = Total Pendapatan

**Batasan RBAC — Mencegah Lompatan:**
- Sales Officer **TIDAK** punya `FINANCE_WRITE` — tidak bisa manipulasi laporan keuangan
- Sales Officer **TIDAK** punya `INVENTORY_WRITE` — tidak bisa memalsukan stok

---

### TAHAP 6: 💰 UANG (Finance)

| Aspek | Implementasi Aktual |
|-------|-------------------|
| **Role** | `finance_manager` |
| **Permission RBAC** | `FINANCE_READ/WRITE`, `SALES_READ`, `PRODUCTION_READ`, `PAYROLL_MANAGE`, `REPORTS_VIEW` |
| **Model Database** | `Expense` + `Payroll` (+ query ke `SalesShipment` & `MillProductionLog`) |
| **Modul Backend** | `app/api/v1/endpoints/finance.py` |
| **Modul Frontend** | `FinancePipelineWidget` (finance_manager sidebar index 3) |
| **API Endpoints** | `GET /finance/pipeline-summary`, `GET /finance/revenue-by-product`, `GET /finance/financial-summary` |

**Finance TIDAK menyimpan data Revenue sendiri.**
Finance **mengambil data langsung** dari modul sumber (Cross-Reference):

```
┌─────────────────────────────────────────────────────────────────────┐
│                    FINANCE CROSS-REFERENCE MODEL                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  REVENUE = SUM(SalesShipment.total_price)                          │
│            WHERE status IN ('Confirmed', 'Invoiced')               │
│            AND shipment_date BETWEEN period_start AND period_end    │
│            ▲                                                        │
│            └── Langsung query tabel sales_shipments                │
│                (Single Source of Truth — data tidak di-copy)        │
│                                                                     │
│  PRODUCTION COST = utility data dari MillProductionLog              │
│    • steam_pressure_bar × unit_cost                                │
│    • power_consumption_kwh × tariff                                │
│    • water_consumption_m3 × tariff                                  │
│    ▲                                                                │
│    └── Langsung query tabel mill_production_logs                   │
│                                                                     │
│  EXPENSES = SUM(Expense.amount) per category per period            │
│    • Fertilizer, Fuel, Maintenance, Labour, Other                  │
│    ▲                                                                │
│    └── Finance Manager input sendiri (FINANCE_WRITE)               │
│                                                                     │
│  PAYROLL = SUM(Payroll.total_amount) WHERE status = 'Paid'         │
│    ▲                                                                │
│    └── Finance Manager kelola sendiri (PAYROLL_MANAGE)             │
│                                                                     │
│  ════════════════════════════════════════════════════════════════   │
│  NET PROFIT = Revenue - Expenses - Payroll                          │
│  ════════════════════════════════════════════════════════════════   │
│                                                                     │
│  REVENUE BY PRODUCT:                                                │
│    CPO Revenue  = SUM(total_price) WHERE contract.product = 'CPO'  │
│    Kernel Rev.  = SUM(total_price) WHERE contract.product = 'Kernel'│
│    ▲                                                                │
│    └── JOIN sales_shipments × sales_contracts                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Data yang Finance Manager Kelola Langsung:**

| Modul | Endpoint | Deskripsi |
|-------|----------|-----------|
| Expense | `POST /finance/expenses` | Input beban operasional |
| Payroll | `POST /finance/payroll` | Generate slip gaji |
| Payroll Pay | `PUT /finance/payroll/{id}/pay` | Tandai gaji dibayar |

**Data yang Finance Manager Baca dari Modul Lain:**

| Data | Sumber | Permission |
|------|--------|-----------|
| Revenue | `SalesShipment.total_price` | `SALES_READ` |
| Production Cost | `MillProductionLog.power/steam/water` | `PRODUCTION_READ` |
| Harvest Volume | `Production.quantity` | (via pipeline-summary) |

**Endpoint Pipeline Summary (Cross-Reference Utama):**
```
GET /api/v1/finance/pipeline-summary?period_start=2026-02-01&period_end=2026-02-20

Response:
{
  "period": {"start": "2026-02-01", "end": "2026-02-20"},
  "chain_data": {
    "harvest_tons": 450.5,         ← dari Production (Tahap 1)
    "ffb_processed_kg": 380000,    ← dari MillProductionLog (Tahap 3)
    "cpo_produced_kg": 85000,      ← dari MillProductionLog (Tahap 3)
    "kernel_produced_kg": 19000    ← dari MillProductionLog (Tahap 3)
  },
  "financials": {
    "revenue": 1250000000,         ← dari SalesShipment (Tahap 5)
    "sales_count": 8,
    "expenses": 320000000,         ← dari Expense (input Finance)
    "payroll": 180000000,          ← dari Payroll (input Finance)
    "total_costs": 500000000,
    "net_profit": 750000000        ← COMPUTED
  }
}
```

---

### KONTROL: 🔒 ADMIN (Full Monitor)

| Aspek | Implementasi Aktual |
|-------|-------------------|
| **Role** | `admin` |
| **Permission RBAC** | **SEMUA permission** (`{p for p in Permission}`) |
| **Modul Frontend** | `PipelineStatusWidget` (admin sidebar index 6) |
| **API Endpoint** | `GET /api/v1/admin/pipeline-status` |

**Kemampuan Admin:**
1. **Monitor seluruh 6 tahap** dalam satu view (Pipeline Status Widget)
2. **Deteksi Bottleneck** otomatis:
   - `> 5 truk menunggu weigh-out` → bottleneck Timbang
   - `> 3 production log pending approval` → bottleneck Produksi
   - `Product.current_stock < Product.min_stock_level` → bottleneck Stok
3. **Manage Users** — CRUD user dan assign role
4. **View Audit Logs** — Semua perubahan sistem tercatat
5. **System Config** — Kelola parameter global

**Admin TIDAK memproses data operasional** — hanya monitoring dan kontrol.

---

## 3. MATRIKS RBAC — PENEGAKAN ALUR BERURUTAN

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  RBAC PERMISSION MATRIX — Menjamin Tidak Ada Lompatan Proses                │
├──────────────────────────────┬─────┬─────┬─────┬─────┬─────┬───────────────┤
│  Endpoint / Action            │ FO  │ EM  │ MM  │ SO  │ FM  │ Admin         │
├──────────────────────────────┼─────┼─────┼─────┼─────┼─────┼───────────────┤
│  POST harvest                 │ ✅  │ ❌  │ ❌  │ ❌  │ ❌  │ ✅            │
│  GET  harvest                 │ ✅  │ ✅  │ ❌  │ ❌  │ ❌  │ ✅            │
│  POST weighbridge             │ ❌  │ ✅  │ ✅  │ ❌  │ ❌  │ ✅            │
│  GET  weighbridge             │ ❌  │ ✅  │ ✅  │ ❌  │ ❌  │ ✅            │
│  POST mill production log     │ ❌  │ ❌  │ ✅  │ ❌  │ ❌  │ ✅            │
│  PUT  mill production approve │ ❌  │ ❌  │ ✅  │ ❌  │ ❌  │ ✅            │
│  GET  inventory               │ ❌  │ ✅  │ ✅  │ ✅  │ ✅  │ ✅            │
│  WRITE inventory (auto only)  │ ❌  │ ❌  │ ✅  │ ❌  │ ❌  │ ✅            │
│  POST sales contract          │ ❌  │ ❌  │ ❌  │ ✅  │ ❌  │ ✅            │
│  POST sales shipment          │ ❌  │ ❌  │ ❌  │ ✅  │ ❌  │ ✅            │
│  PUT  shipment confirm        │ ❌  │ ❌  │ ❌  │ ✅  │ ❌  │ ✅            │
│  GET  sales                   │ ❌  │ ❌  │ ❌  │ ✅  │ ✅  │ ✅            │
│  POST expense                 │ ❌  │ ❌  │ ❌  │ ❌  │ ✅  │ ✅            │
│  POST payroll                 │ ❌  │ ❌  │ ❌  │ ❌  │ ✅  │ ✅            │
│  GET  finance/reports         │ ❌  │ ❌  │ ❌  │ ❌  │ ✅  │ ✅            │
│  GET  pipeline-summary        │ ❌  │ ❌  │ ❌  │ ❌  │ ✅  │ ✅            │
│  GET  pipeline-status (admin) │ ❌  │ ❌  │ ❌  │ ❌  │ ❌  │ ✅            │
│  CRUD users                   │ ❌  │ ❌  │ ❌  │ ❌  │ ❌  │ ✅            │
│  GET  audit logs              │ ❌  │ ❌  │ ❌  │ ❌  │ ❌  │ ✅            │
├──────────────────────────────┴─────┴─────┴─────┴─────┴─────┴───────────────┤
│  FO=Field Officer, EM=Estate Manager, MM=Mill Manager,                      │
│  SO=Sales Officer, FM=Finance Manager                                       │
│                                                                              │
│  ✅ = Punya permission  |  ❌ = Tidak punya permission (403 Forbidden)      │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Mengapa RBAC ini mencegah lompatan:**
- Field Officer hanya bisa CREATE harvest — tidak bisa langsung bikin sales atau expense
- Sales Officer bisa READ inventory (validasi stok) tapi TIDAK bisa WRITE inventory
- Finance Manager bisa READ sales (hitung revenue) tapi TIDAK bisa mengubah data sales
- Setiap role **hanya bisa memproses tahap miliknya** dan **membaca tahap upstream**

---

## 4. RELASI DATA ANTAR TABEL — KUNCI SAMBUNGAN

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     RELASI FOREIGN KEY ANTAR TAHAP                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TAHAP 1 → 2:                                                               │
│    Production.block_id ───────────▶ WeighbridgeEntry.block_origin           │
│    (FK → blocks.id)                (String, referensi nama blok)            │
│    Production.quantity ───────────▶ Validasi: netto realistis?              │
│                                                                             │
│  TAHAP 2 → 3:                                                               │
│    SUM(WeighbridgeEntry.netto_kg)                                           │
│      WHERE status='Completed'    ─▶ MillProductionLog.ffb_processed_kg     │
│      AND date = target_date                                                 │
│                                                                             │
│  TAHAP 3 → 4: ⚡ OTOMATIS ⚡                                               │
│    MillProductionLog.cpo_produced_kg                                        │
│      ON APPROVE ──────────────────▶ InventoryMovement(type=IN, qty=cpo_kg) │
│                                    ▶ Product("CPO").current_stock += cpo_kg │
│    MillProductionLog.kernel_produced_kg                                      │
│      ON APPROVE ──────────────────▶ InventoryMovement(type=IN, qty=ker_kg) │
│                                    ▶ Product("Kernel").current_stock += kg  │
│    reference_type = "MillProductionLog"                                     │
│    reference_id   = log.id          (Full traceability)                     │
│                                                                             │
│  TAHAP 4 → 5:                                                               │
│    Product.current_stock ─────────▶ Validasi: SalesShipment.qty ≤ stock    │
│                                                                             │
│  TAHAP 5 → 4: ⚡ OTOMATIS ⚡                                               │
│    SalesShipment.confirm()                                                  │
│      ON CONFIRM ──────────────────▶ InventoryMovement(type=OUT, qty=-kg)   │
│                                    ▶ Product.current_stock -= qty × 1000   │
│    reference_type = "SalesShipment"                                         │
│    reference_id   = shipment.id     (Full traceability)                     │
│                                                                             │
│  TAHAP 5 → 6: READ-ONLY CROSS REFERENCE                                    │
│    SUM(SalesShipment.total_price) ▶ Finance.revenue (computed, not stored) │
│    SalesContract.product_type ────▶ Finance.revenue_by_product breakdown   │
│    MillProductionLog.utility ─────▶ Finance.production_cost (computed)      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. AUDIT TRAIL — PENCATATAN SETIAP PERUBAHAN STATUS

Setiap operasi CRUD dan perubahan status dicatat di tabel `audit_logs`:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Tabel: audit_logs                                                           │
├──────────┬─────────┬──────────┬──────────────────────────────┬───────────────┤
│ user_id  │ action  │ module   │ description                  │ payload (JSON)│
├──────────┼─────────┼──────────┼──────────────────────────────┼───────────────┤
│ uuid-fo  │ CREATE  │ HARVEST  │ Field Officer input panen    │ {qty, block}  │
│ uuid-em  │ CREATE  │ WEIGH..  │ Truk AB1234 WeighIn 45000kg │ {plate, wt}   │
│ uuid-em  │ UPDATE  │ WEIGH..  │ WeighOut completed netto=..  │ {netto_kg}    │
│ uuid-mm  │ CREATE  │ MILL_P.. │ Production log Shift 1       │ {ffb, cpo}    │
│ uuid-mm  │ APPROVE │ MILL_P.. │ Approved: CPO=3500, Ker=800  │ {log_id, kg}  │
│ uuid-so  │ CREATE  │ SALES    │ Contract SC-2026-001 created │ {buyer, qty}  │
│ uuid-so  │ CREATE  │ SALES    │ Shipment DO-001 for contract │ {ship_id}     │
│ uuid-so  │ CONFIRM │ SALES    │ Confirmed: 25T CPO stock OUT │ {price, qty}  │
│ uuid-fm  │ CREATE  │ FINANCE  │ Expense: Fertilizer 50M      │ {cat, amount} │
│ uuid-fm  │ UPDATE  │ FINANCE  │ Payroll batch marked Paid    │ {payroll_id}  │
│ uuid-ad  │ UPDATE  │ USER     │ Admin changed user role       │ {old, new}    │
└──────────┴─────────┴──────────┴──────────────────────────────┴───────────────┘
```

**Kolom audit_logs:**
- `user_id` → Siapa yang melakukan aksi
- `action` → CREATE, UPDATE, APPROVE, CONFIRM, DELETE
- `module` → HARVEST, WEIGHBRIDGE, MILL_PRODUCTION, SALES, FINANCE, USER
- `description` → Deskripsi human-readable
- `payload` → Detail JSON (UUID, quantities, prices)
- `ip_address` → IP source (opsional)
- `created_at` → Timestamp presisi

---

## 6. FRONTEND ROUTING — SATU DASHBOARD PER ROLE

```dart
// main.dart — Route mapping per role
GoRoute(path: '/user-dashboard',  builder: → UserDashboardScreen)       // Field Officer
GoRoute(path: '/manager/estate',  builder: → ManagerDashboardScreen)    // Estate Manager
GoRoute(path: '/manager/mill',    builder: → ManagerDashboardScreen)    // Mill Manager
GoRoute(path: '/manager/sales',   builder: → ManagerDashboardScreen)    // Sales Officer
GoRoute(path: '/manager/finance', builder: → ManagerDashboardScreen)    // Finance Manager
GoRoute(path: '/dashboard',       builder: → AdminDashboardScreen)      // Admin
```

**Sidebar Mapping per Role:**

| Role | Index 0 | Index 1 | Index 2 | Index 3 | Index 4 |
|------|---------|---------|---------|---------|---------|
| **Field Officer** | Home | Panen (HarvestEntry) | Absen | Profil | — |
| **Estate Manager** | Overview | Harvest & Yield | Block Map | **Weighbridge** | Nursery |
| **Mill Manager** | Overview | **Production Logs** | Machine Status | OER/KER Report | — |
| **Sales Officer** | Overview | **Sales Management** | Logistics (DO) | CPO Prices | — |
| **Finance Manager** | Overview | Budget | Cash Flow | **Pipeline Summary** | — |
| **Admin** | Dashboard | Production | Supply Chain | HR | Warehouse | Fields | **Pipeline** |

---

## 7. PRINSIP DESAIN — RINGKASAN IMPLEMENTASI

| Prinsip | Implementasi Aktual |
|---------|-------------------|
| **Single Source of Truth** | `Product.current_stock` hanya diubah via `InventoryMovement`. Finance.revenue tidak disimpan terpisah — langsung query dari `SalesShipment.total_price`. |
| **Zero Process Skip** | RBAC memastikan Field Officer tidak bisa akses Sales. Data panen HARUS melewati 6 tahap berurutan. Tidak ada endpoint yang "loncat". |
| **Full Audit Trail** | Setiap CREATE, UPDATE, APPROVE, CONFIRM → `audit_log.create()` dipanggil. Payload berisi detail perubahan dalam JSON. |
| **Relasi Data Terpadu** | Foreign Key antar tabel memastikan integritas referensial. `InventoryMovement.reference_type + reference_id` menghubungkan stok ke sumber asalnya. |
| **Approval Workflow** | MillProductionLog: `Draft → Approved` (trigger stock IN). SalesShipment: `Draft → Confirmed` (trigger stock OUT). Keduanya irreversible. |
| **Separation of Concern** | Setiap role hanya punya akses ke tahap miliknya. Cross-read diizinkan (Finance baca Sales), cross-write dilarang. |
| **Automated Data Flow** | 2 titik otomatis kritis: (1) Approve Production → Stock IN, (2) Confirm Shipment → Stock OUT. Manusia hanya trigger, sistem eksekusi. |

---

## 8. DIAGRAM ALUR DATA END-TO-END

```
    FIELD OFFICER              ESTATE MANAGER            MILL MANAGER
    ═══════════                ══════════════            ════════════
         │                          │                        │
    ┌────▼────┐               ┌─────▼─────┐           ┌─────▼─────┐
    │ INPUT   │               │ TIMBANG   │           │ CREATE    │
    │ PANEN   │──block_id────▶│ WEIGHIN   │──netto───▶│ PROD LOG  │
    │ (FFB)   │  quantity     │ WEIGHOUT  │  kg       │ (Draft)   │
    └────┬────┘               └─────┬─────┘           └─────┬─────┘
         │                          │                        │
    audit_log                  audit_log                     │
    CREATE|HARVEST             CREATE|WEIGHBRIDGE            ▼
                                                       ┌─────────┐
                                                       │ APPROVE │
                                                       │ PROD LOG│
                                                       └────┬────┘
                                                            │
                                              ⚡ AUTO ⚡    │
                                              ┌─────────────┘
                                              ▼
                                    ┌──────────────────┐
                                    │ INVENTORY        │
                                    │ Movement IN      │
                                    │ CPO += produced   │
                                    │ Kernel += produced│
                                    │                  │
                                    │ Product.         │
                                    │ current_stock    │  ◄── SINGLE SOURCE OF TRUTH
                                    │ UPDATED          │
                                    └────────┬─────────┘
                                             │
                                             ▼
    SALES OFFICER              ┌─────────────────────────┐
    ═════════════              │ READ: Product.stock     │
         │                     │ VALIDATE: qty ≤ stock   │
    ┌────▼────┐               └─────────────────────────┘
    │ CREATE  │                        │
    │CONTRACT │                        │
    └────┬────┘                        │
         │                             │
    ┌────▼─────┐                       │
    │ CREATE   │◄──────────────────────┘
    │ SHIPMENT │  stock validation
    └────┬─────┘
         │
    ┌────▼──────┐
    │ CONFIRM   │
    │ SHIPMENT  │──── ⚡ AUTO: InventoryMovement(OUT)
    └────┬──────┘     Product.current_stock -= qty
         │
         │  total_price
         ▼
    FINANCE MANAGER
    ═══════════════
         │
    ┌────▼──────────────────────────────┐
    │ PIPELINE SUMMARY                  │
    │                                   │
    │ Revenue = SUM(shipment.price)     │ ← dari Sales (READ-ONLY)
    │ Cost    = Expense + Payroll       │ ← input sendiri
    │ Profit  = Revenue - Cost          │ ← COMPUTED
    │                                   │
    │ Chain:  harvest → ffb → cpo → $   │ ← cross-reference lengkap
    └───────────────────────────────────┘
         │
         ▼
    ┌────────────────────┐
    │      ADMIN         │
    │  Pipeline Status   │
    │  (ALL 6 stages)    │
    │  + Bottleneck Alert│
    │  + Audit Logs      │
    └────────────────────┘
```

---

> **Kesimpulan**: Sistem NEX ERP mengimplementasikan rantai data berurutan yang ketat
> melalui kombinasi **RBAC permission matrix** (mencegah akses lintas tahap),
> **Foreign Key relasi** (menjamin integritas data), **Automated workflows**
> (Approve→StockIN, Confirm→StockOUT), dan **Audit trail** di setiap operasi.
> Tidak ada lompatan proses yang dimungkinkan secara teknis.
