# Offline Mode Feature - NEX App

## Overview
Fitur Offline Mode memungkinkan pengguna untuk mencatat data harvest (panen) bahkan ketika tidak ada koneksi internet. Data akan disimpan secara lokal dan otomatis disinkronkan ke server ketika koneksi internet tersedia kembali.

## Architecture

### 1. Data Models
Lokasi: `lib/src/features/dashboard/data/models/`

#### EstateLocal (`estate_local.dart`)
Model untuk menyimpan data Estate secara lokal.
```dart
@HiveType(typeId: 0)
class EstateLocal extends HiveObject {
  String id;
  String name;
  String location;
  double totalArea;
}
```

#### BlockLocal (`block_local.dart`)
Model untuk menyimpan data Block (blok lahan) secara lokal.
```dart
@HiveType(typeId: 1)
class BlockLocal extends HiveObject {
  String id;
  String estateId;
  String code;
  double area;
  int palmCount;
}
```

#### HarvestQueue (`harvest_queue.dart`)
Model untuk queue data harvest yang menunggu sinkronisasi.
```dart
@HiveType(typeId: 2)
class HarvestQueue extends HiveObject {
  String localId;
  String blockId;
  double quantity;
  String unit;
  String fieldCode;
  DateTime timestamp;
  bool synced;
}
```

### 2. Services

#### LocalStorageService (`local_storage_service.dart`)
Service untuk mengelola penyimpanan lokal menggunakan Hive database.

**Fungsi Utama:**
- `init()` - Inisialisasi Hive dan register adapters
- `saveEstates()` - Simpan data estates untuk offline access
- `getEstates()` - Ambil data estates dari local storage
- `saveBlocks()` - Simpan data blocks untuk offline access
- `getBlocks()` - Ambil data blocks berdasarkan estate ID
- `addToQueue()` - Tambahkan harvest data ke queue
- `getPendingHarvests()` - Ambil semua harvest yang belum tersinkronisasi
- `markAsSynced()` - Tandai harvest sebagai sudah tersinkronisasi
- `clearSyncedHarvests()` - Hapus harvest yang sudah tersinkronisasi

#### NetworkService (`network_service.dart`)
Service untuk monitoring status koneksi internet.

**Fungsi Utama:**
- `initialize()` - Mulai monitoring koneksi
- `checkConnection()` - Check status koneksi saat ini
- `getConnectionType()` - Dapatkan tipe koneksi (WiFi/Mobile/Ethernet/Offline)
- `onConnectivityChanged` - Stream untuk listen perubahan koneksi

#### OfflineSyncService (`offline_sync_service.dart`)
Service untuk mengelola sinkronisasi data offline ke server.

**Fungsi Utama:**
- `startMonitoring()` - Mulai monitoring dan auto-sync
- `stopMonitoring()` - Stop monitoring
- `syncPendingHarvests()` - Sync semua data yang pending
- `getSyncStatus()` - Dapatkan status sync saat ini
- `forceSyncNow()` - Paksa sync manual langsung

**Auto-Sync Features:**
- Otomatis detect koneksi internet
- Sync setiap 5 menit jika ada pending data
- Sync otomatis ketika koneksi kembali tersedia

## Usage Flow

### 1. Initialization (di main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive untuk offline storage
  await LocalStorageService.init();
  
  // Initialize Network Service
  await NetworkService().initialize();
  
  runApp(MyApp());
}
```

### 2. Save Data untuk Offline Access
```dart
// Simpan estates ketika online
final estates = await fetchEstatesFromAPI();
await LocalStorageService.saveEstates(estates);

// Simpan blocks untuk setiap estate
for (var estate in estates) {
  final blocks = await fetchBlocksFromAPI(estate.id);
  await LocalStorageService.saveBlocks(estate.id, blocks);
}
```

### 3. Submit Harvest Data (Online/Offline)
```dart
// Di Harvest Entry Screen
Future<void> submitHarvest(HarvestData data) async {
  final networkService = NetworkService();
  final isOnline = await networkService.checkConnection();
  
  if (isOnline) {
    // Langsung kirim ke server
    try {
      await repository.submitHarvestProduction(data.toJson());
      // Success
    } catch (e) {
      // Jika gagal, simpan ke queue
      await _saveToQueue(data);
    }
  } else {
    // Simpan ke queue untuk sync nanti
    await _saveToQueue(data);
  }
}

Future<void> _saveToQueue(HarvestData data) async {
  final harvest = HarvestQueue(
    localId: uuid.v4(),
    blockId: data.blockId,
    quantity: data.quantity,
    unit: data.unit,
    fieldCode: data.fieldCode,
    timestamp: DateTime.now(),
    synced: false,
  );
  
  await LocalStorageService.addToQueue(harvest);
}
```

### 4. Setup Auto-Sync (di main screen/dashboard)
```dart
class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late OfflineSyncService _syncService;
  
  @override
  void initState() {
    super.initState();
    
    // Setup sync service
    final repository = context.read<DashboardRepository>();
    _syncService = OfflineSyncService(repository);
    _syncService.startMonitoring();
  }
  
  @override
  void dispose() {
    _syncService.stopMonitoring();
    super.dispose();
  }
  
  // Manual sync button
  Future<void> _handleManualSync() async {
    final result = await _syncService.forceSyncNow();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... UI content
      floatingActionButton: FloatingActionButton(
        onPressed: _handleManualSync,
        child: Icon(Icons.sync),
      ),
    );
  }
}
```

### 5. Display Sync Status
```dart
Widget _buildSyncStatus() {
  final syncStatus = _syncService.getSyncStatus();
  
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: syncStatus.hasPendingData 
        ? Colors.orange.shade100 
        : Colors.green.shade100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(
          syncStatus.isSyncing ? Icons.sync : Icons.cloud_done,
          color: syncStatus.hasPendingData 
            ? Colors.orange 
            : Colors.green,
        ),
        SizedBox(width: 8),
        Text(syncStatus.statusMessage),
      ],
    ),
  );
}
```

## Data Flow Diagram

```
┌─────────────────┐
│  User Action    │
│ (Submit Harvest)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Check Network   │◄──NetworkService
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐  ┌──────────┐
│Online │  │ Offline  │
└───┬───┘  └────┬─────┘
    │           │
    ▼           ▼
┌────────┐  ┌──────────────┐
│API Call│  │ Save to Hive │
└───┬────┘  │    Queue     │
    │       └──────┬───────┘
    │              │
    │              ▼
    │       ┌─────────────┐
    │       │Wait for Sync│
    │       └──────┬──────┘
    │              │
    │    ┌─────────┴──────────┐
    │    │OfflineSyncService  │
    │    │ - Auto Monitor     │
    │    │ - Periodic Check   │
    │    └──────┬─────────────┘
    │           │
    │           ▼
    │    ┌──────────────┐
    └────►  Sync to API  │
         └──────────────┘
```

## Dependencies Required

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^6.1.2
  
dev_dependencies:
  build_runner: ^2.4.13
  hive_generator: ^2.0.1
```

## Build Commands

Generate Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Best Practices

1. **Always Check Connection First**
   - Before API calls, check connection status
   - Fallback to local data when offline

2. **Periodic Sync**
   - Set reasonable sync intervals (default: 5 minutes)
   - Consider battery and data usage

3. **Error Handling**
   - Handle failed syncs gracefully
   - Retry mechanism for failed items
   - Show clear status to users

4. **Data Cleanup**
   - Regularly clear synced data
   - Prevent local storage bloat
   - Keep only recent offline data

5. **User Feedback**
   - Show sync status prominently
   - Indicate offline mode clearly
   - Confirm successful syncs

## Troubleshooting

### Issue: Adapters not found
**Solution:** Run build_runner to generate adapters
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Hive boxes not opening
**Solution:** Ensure init() is called before app starts
```dart
await Hive.initFlutter();
```

### Issue: Data not syncing
**Solution:** Check:
1. Network connection is available
2. OfflineSyncService is started
3. No errors in repository.submitHarvestProduction()

## Future Enhancements

1. **Conflict Resolution**
   - Handle data conflicts when same record edited offline and online
   - Implement last-write-wins or merge strategies

2. **Selective Sync**
   - Allow users to choose what to sync
   - Priority-based sync queue

3. **Compression**
   - Compress offline data to save space
   - Batch uploads for efficiency

4. **Offline Reports**
   - Generate reports from local data
   - Cache frequently accessed data

5. **Partial Sync**
   - Resume interrupted syncs
   - Incremental sync for large datasets
