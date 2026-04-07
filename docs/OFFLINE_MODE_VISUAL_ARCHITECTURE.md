# Offline Mode - Visual Architecture

## System Components

```
┌─────────────────────────────────────────────────────────────┐
│                         NEX APP                             │
│                    (Flutter Application)                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              │
        ┌─────────────────────┴─────────────────────┐
        │                                           │
        ▼                                           ▼
┌───────────────┐                          ┌────────────────┐
│  UI Layer     │                          │  Data Layer    │
│               │                          │                │
│ - Indicators  │                          │ - Models       │
│ - Dialogs     │                          │ - Services     │
│ - Screens     │                          │ - Repositories │
└───────┬───────┘                          └────────┬───────┘
        │                                           │
        │                                           │
        └─────────────────┬─────────────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────┐
        │    Offline Sync Service         │
        │  - Auto Monitor (5 min)         │
        │  - Network Detection            │
        │  - Sync Queue Management        │
        └─────────┬───────────────┬───────┘
                  │               │
        ┌─────────┘               └──────────┐
        │                                    │
        ▼                                    ▼
┌──────────────┐                    ┌────────────────┐
│Network Service│                   │Local Storage   │
│              │                    │   Service      │
│- WiFi Check  │                    │                │
│- Mobile Check│                    │- Hive Boxes    │
│- Stream      │                    │- CRUD Ops      │
└──────────────┘                    └────────┬───────┘
                                             │
                                             ▼
                                    ┌─────────────────┐
                                    │  Hive Database  │
                                    │                 │
                                    │ - estates       │
                                    │ - blocks        │
                                    │ - harvest_queue │
                                    └─────────────────┘
```

## Data Models Hierarchy

```
HiveObject (Base Class)
    │
    ├── EstateLocal (typeId: 0)
    │   ├── id: String
    │   ├── name: String
    │   ├── location: String
    │   └── totalArea: double
    │
    ├── BlockLocal (typeId: 1)
    │   ├── id: String
    │   ├── estateId: String
    │   ├── code: String
    │   ├── area: double
    │   └── palmCount: int
    │
    └── HarvestQueue (typeId: 2)
        ├── localId: String (UUID)
        ├── blockId: String
        ├── quantity: double
        ├── unit: String
        ├── fieldCode: String
        ├── timestamp: DateTime
        └── synced: bool
```

## Service Interaction Flow

```
┌──────────────────┐
│  User Action     │
│ (Submit Harvest) │
└────────┬─────────┘
         │
         ▼
┌─────────────────────┐
│ ProductionRepository│
│  .submitHarvest()   │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│  NetworkService     │
│  .checkConnection() │
└────────┬────────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐  ┌──────────────────┐
│ ONLINE │  │    OFFLINE       │
└───┬────┘  └────┬─────────────┘
    │            │
    ▼            ▼
┌────────────┐  ┌──────────────────────┐
│ POST       │  │ LocalStorageService  │
│ to API     │  │ .addToQueue()        │
└─────┬──────┘  └──────────┬───────────┘
      │                    │
      │                    ▼
      │            ┌────────────────────┐
      │            │  Hive Database     │
      │            │  harvest_queue     │
      │            └──────────┬─────────┘
      │                       │
      │                       │
      │         ┌─────────────┴──────────┐
      │         │  OfflineSyncService    │
      │         │  Monitoring Started    │
      │         └──────────┬─────────────┘
      │                    │
      │         ┌──────────┴─────────────┐
      │         │                        │
      │         ▼                        ▼
      │   ┌──────────┐         ┌───────────────┐
      │   │Connection│         │ Every 5 min   │
      │   │ Changed  │         │ Timer Check   │
      │   └────┬─────┘         └───────┬───────┘
      │        │                       │
      │        └───────┬───────────────┘
      │                │
      │                ▼
      │         ┌─────────────────┐
      │         │ getPendingHarvest│
      │         └──────┬───────────┘
      │                │
      │                ▼
      │         ┌──────────────────┐
      │         │  Sync to API     │
      │         │  One by One      │
      │         └──────┬───────────┘
      │                │
      │                ▼
      │         ┌──────────────────┐
      │         │ markAsSynced()   │
      │         └──────┬───────────┘
      │                │
      │                ▼
      │         ┌──────────────────┐
      │         │clearSyncedHarvest│
      │         └──────────────────┘
      │
      └──────────────► SUCCESS ✅
```

## UI State Diagram

```
┌───────────────────────────────────────┐
│   OfflineStatusIndicator States       │
└───────────────────────────────────────┘

┌──────────┐
│  ONLINE  │  ──┐
│  No Data │    │
│  🟢      │    │
└──────────┘    │
                │
┌──────────┐    │
│  ONLINE  │    ├──► User Experience
│  Syncing │    │     "Seamless"
│  🔵      │    │
└──────────┘    │
                │
┌──────────┐    │
│  ONLINE  │    │
│  Pending │    │
│  🟠      │    │
└──────────┘    │
                │
┌──────────┐    │
│ OFFLINE  │    │
│  Cached  │  ──┘
│  🔴      │
└──────────┘

Color Legend:
🟢 Green  = All synced, online
🔵 Blue   = Actively syncing
🟠 Orange = Has pending data
🔴 Red    = Offline mode
```

## Sync Process Detail

```
┌─────────────────────────────────────────────────┐
│         Sync Process Flow                       │
└─────────────────────────────────────────────────┘

START
  │
  ▼
┌─────────────────┐
│ Check Network   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
  [No]      [Yes]
    │         │
    │         ▼
    │   ┌─────────────────┐
    │   │ Get Pending     │
    │   │ Harvests        │
    │   └────────┬────────┘
    │            │
    │       ┌────┴────┐
    │       │         │
    │       ▼         ▼
    │   [Empty]   [Has Data]
    │       │         │
    │       │         ▼
    │       │   ┌──────────────┐
    │       │   │ For Each     │
    │       │   │ Harvest      │
    │       │   └──────┬───────┘
    │       │          │
    │       │          ▼
    │       │   ┌──────────────┐
    │       │   │ Try POST     │
    │       │   │ to API       │
    │       │   └──────┬───────┘
    │       │          │
    │       │     ┌────┴────┐
    │       │     │         │
    │       │     ▼         ▼
    │       │  [Success] [Failed]
    │       │     │         │
    │       │     ▼         ▼
    │       │ Mark Synced  Skip
    │       │     │         │
    │       │     └────┬────┘
    │       │          │
    │       │          ▼
    │       │    ┌──────────┐
    │       │    │ Continue │
    │       │    │ Loop     │
    │       │    └─────┬────┘
    │       │          │
    │       │          ▼
    │       │   ┌─────────────┐
    │       │   │ Cleanup     │
    │       │   │ Synced Data │
    │       │   └──────┬──────┘
    │       │          │
    │       └──────────┴──────┐
    │                         │
    └─────────────────────────┘
                              │
                              ▼
                            DONE
```

## File Structure Tree

```
nex_app/
├── lib/
│   └── src/
│       └── features/
│           └── dashboard/
│               ├── data/
│               │   ├── models/
│               │   │   ├── estate_local.dart ✅
│               │   │   ├── estate_local.g.dart (generated)
│               │   │   ├── block_local.dart ✅
│               │   │   ├── block_local.g.dart (generated)
│               │   │   ├── harvest_queue.dart ✅
│               │   │   └── harvest_queue.g.dart (generated)
│               │   │
│               │   ├── services/
│               │   │   ├── local_storage_service.dart ✅
│               │   │   ├── network_service.dart ✅
│               │   │   └── offline_sync_service.dart ✅
│               │   │
│               │   └── repositories/
│               │       ├── dashboard_repository_impl.dart (updated)
│               │       └── production_repository.dart (existing)
│               │
│               └── presentation/
│                   └── widgets/
│                       └── offline_status_indicator.dart ✅
│
└── docs/
    ├── OFFLINE_MODE.md ✅
    ├── OFFLINE_MODE_INTEGRATION_GUIDE.md ✅
    ├── OFFLINE_MODE_SUMMARY.md ✅
    └── OFFLINE_MODE_VISUAL_ARCHITECTURE.md ✅ (this file)
```

## Dependencies Graph

```
┌──────────────────────┐
│   Flutter App        │
└──────────┬───────────┘
           │
           ├─────────────────────────────┐
           │                             │
           ▼                             ▼
┌──────────────────┐         ┌──────────────────┐
│  flutter_bloc    │         │  connectivity    │
│  (State Mgmt)    │         │  _plus           │
└──────────────────┘         └──────────────────┘
           │
           │
           ▼
┌──────────────────┐
│  Hive + Flutter  │
│                  │
│  - hive: ^2.2.3  │
│  - hive_flutter  │
└──────────┬───────┘
           │
           ▼
┌──────────────────┐
│  Code Generation │
│                  │
│  - build_runner  │
│  - hive_generator│
└──────────────────┘
           │
           ▼
┌──────────────────┐
│  Utilities       │
│                  │
│  - uuid: ^4.5.1  │
│  - dio: ^5.4.0   │
└──────────────────┘
```

## Memory Flow

```
App Start
    │
    ▼
Initialize Hive
    │
    ├─► Open Box<EstateLocal>
    ├─► Open Box<BlockLocal>
    └─► Open Box<HarvestQueue>
    │
    ▼
Boxes in Memory
(Lightweight)
    │
    ▼
CRUD Operations
    │
    ├─► Read: O(1) - Very Fast
    ├─► Write: O(1) - Very Fast
    └─► Delete: O(1) - Very Fast
    │
    ▼
Auto-Save to Disk
(Asynchronous)
```

## Sync Timing Diagram

```
Time: ──────────────────────────────────────────►

App Start
│
├─► [00:00] Initialize Services
│
├─► [00:01] Start Monitoring
│
├─► [00:05] First Periodic Check
│             └─► No pending data
│
├─► [00:10] Second Periodic Check
│             └─► No pending data
│
├─► [02:30] User submits harvest (offline)
│             └─► Data queued
│
├─► [02:35] Periodic Check (at 5 min mark)
│             └─► Still offline, skip
│
├─► [03:00] Connection restored
│             └─► Event triggered!
│             └─► Start sync immediately
│             └─► Success! ✅
│
├─► [03:05] Periodic Check
│             └─► No pending data
│
└─► Continue...
```

---

## Legend

```
✅ = Completed
🟢 = Online & Synced
🟠 = Has Pending Data
🔵 = Currently Syncing
🔴 = Offline Mode
```

## Quick Reference

### Colors
- **Green**: Everything is synced, online
- **Orange**: Has data waiting to sync
- **Blue**: Actively syncing right now
- **Red**: Offline, using cached data

### Icons
- **☁️ cloud_done**: All synced
- **☁️ cloud_upload**: Pending upload
- **🔄 sync**: Syncing now
- **☁️ cloud_off**: Offline mode

---

Created: 2026-02-17
Version: 1.0.0
