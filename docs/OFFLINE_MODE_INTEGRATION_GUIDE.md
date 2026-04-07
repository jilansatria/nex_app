# Offline Mode Integration Guide

## Quick Start Integration

### 1. Initialize di main.dart

```dart
import 'package:flutter/material.dart';
import 'package:nex_app/src/features/dashboard/data/services/local_storage_service.dart';
import 'package:nex_app/src/features/dashboard/data/services/network_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ WAJIB: Initialize Hive untuk offline storage
  await LocalStorageService.init();
  
  // ✅ WAJIB: Initialize Network Service untuk monitoring koneksi
  await NetworkService().initialize();
  
  runApp(const MyApp());
}
```

### 2. Setup Offline Sync di Dashboard/Main Screen

```dart
import 'package:flutter/material.dart';
import 'package:nex_app/src/features/dashboard/data/services/offline_sync_service.dart';
import 'package:nex_app/src/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:nex_app/src/features/dashboard/presentation/widgets/offline_status_indicator.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late OfflineSyncService _syncService;
  
  @override
  void initState() {
    super.initState();
    _initializeOfflineSync();
  }
  
  void _initializeOfflineSync() {
    // Create repository instance
    final dioClient = DioClient(); // Your DioClient instance
    final repository = DashboardRepositoryImpl(dioClient);
    
    // Initialize sync service
    _syncService = OfflineSyncService(repository);
    
    // ✅ Start auto-sync monitoring
    _syncService.startMonitoring();
  }
  
  @override
  void dispose() {
    // ❌ Stop monitoring ketika screen disposed
    _syncService.stopMonitoring();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          // ✅ Add offline status indicator
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: OfflineStatusIndicator(
                syncService: _syncService,
              ),
            ),
          ),
        ],
      ),
      body: YourDashboardContent(),
    );
  }
}
```

### 3. Menggunakan ProductionRepository yang Sudah Terintegrasi

ProductionRepository sudah otomatis handle offline mode. Anda tidak perlu modifikasi kode tambahan!

```dart
import 'package:nex_app/src/features/dashboard/data/production_repository.dart';

class HarvestEntryScreen extends StatefulWidget {
  @override
  State<HarvestEntryScreen> createState() => _HarvestEntryScreenState();
}

class _HarvestEntryScreenState extends State<HarvestEntryScreen> {
  late ProductionRepository _repository;
  
  @override
  void initState() {
    super.initState();
    _repository = ProductionRepository(DioClient());
  }
  
  // Load estates - otomatis gunakan cache jika offline
  Future<void> _loadEstates() async {
    try {
      final estates = await _repository.getEstates();
      // ✅ Jika online: fetch dari API dan cache
      // ✅ Jika offline: gunakan data cache
      setState(() => _estates = estates);
    } catch (e) {
      // Handle error
    }
  }
  
  // Load blocks - otomatis gunakan cache jika offline
  Future<void> _loadBlocks(String estateId) async {
    try {
      final blocks = await _repository.getBlocks(estateId);
      // ✅ Jika online: fetch dari API dan cache
      // ✅ Jika offline: gunakan data cache
      setState(() => _blocks = blocks);
    } catch (e) {
      // Handle error
    }
  }
  
  // Submit harvest - otomatis masuk queue jika offline
  Future<void> _submitHarvest() async {
    try {
      final success = await _repository.submitHarvest(
        blockId: _selectedBlockId!,
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
      );
      
      if (success) {
        // ✅ Jika online: langsung kirim ke server
        // ✅ Jika offline: simpan ke queue, return success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Data berhasil disimpan!')),
        );
      }
    } catch (e) {
      // Handle error
    }
  }
}
```

### 4. (Optional) Manual Sync Button

Jika ingin menambahkan tombol manual sync:

```dart
Widget _buildManualSyncButton() {
  return ElevatedButton.icon(
    onPressed: () async {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Force sync
      final result = await _syncService.forceSyncNow();
      
      // Hide loading
      Navigator.pop(context);
      
      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    },
    icon: Icon(Icons.sync),
    label: Text('Sync Now'),
  );
}
```

### 5. (Optional) Show Pending Count Badge

```dart
Widget _buildPendingBadge() {
  final pendingCount = _repository.getPendingCount();
  
  if (pendingCount == 0) {
    return SizedBox.shrink();
  }
  
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.orange,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '$pendingCount pending',
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
```

## Ringkasan Fitur yang Berjalan Otomatis

### ✅ Auto-Cache Data
- Setiap kali fetch estates atau blocks dari API, **otomatis disimpan ke local storage**
- Data cache digunakan saat offline

### ✅ Auto-Queue Harvest
- Saat submit harvest offline, **otomatis masuk ke queue**
- User tetap mendapat feedback sukses

### ✅ Auto-Sync
- **Monitor koneksi internet** setiap saat
- **Auto-sync setiap 5 menit** jika ada pending data
- **Auto-sync saat koneksi kembali** tersedia

### ✅ Auto-Cleanup
- Setelah sync sukses, **otomatis hapus data yang sudah tersinkronisasi**
- Prevent storage bloat

## Testing Offline Mode

### Test Scenario 1: Offline Submit
1. Matikan koneksi internet (Airplane mode)
2. Buka Harvest Entry Screen
3. Pilih Estate dan Block (dari cache)
4. Submit data harvest
5. ✅ Seharusnya: "Data berhasil disimpan!" muncul
6. Check pending count: seharusnya bertambah

### Test Scenario 2: Auto-Sync
1. Submit beberapa data saat offline
2. Nyalakan koneksi internet
3. Tunggu beberapa detik
4. ✅ Seharusnya: Data otomatis tersinkronisasi
5. Check pending count: seharusnya 0

### Test Scenario 3: Manual Sync
1. Submit data saat offline
2. Nyalakan koneksi internet
3. Tap tombol "Sync Now"
4. ✅ Seharusnya: Dialog sync muncul, data tersinkronisasi
5. Success message ditampilkan

### Test Scenario 4: Cache Usage
1. Saat online, buka Harvest Entry
2. Load estates dan blocks
3. Matikan koneksi internet
4. Restart app atau navigate ke screen lain lalu kembali
5. ✅ Seharusnya: Estates dan blocks masih bisa ditampilkan dari cache

## Troubleshooting

### ❌ Error: "Box not found"
**Solution:** Pastikan `LocalStorageService.init()` dipanggil di `main()` sebelum `runApp()`

### ❌ Error: "Adapter not registered"
**Solution:** Jalankan build_runner untuk generate adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### ❌ Data tidak tersinkronisasi
**Check:**
1. Koneksi internet tersedia?
2. `OfflineSyncService.startMonitoring()` sudah dipanggil?
3. API endpoint benar?
4. Check console untuk error logs

### ❌ Pending count tidak update
**Solution:** Panggil `setState()` setelah submit harvest untuk refresh UI

## Best Practices Checklist

- ✅ Initialize LocalStorageService di main.dart
- ✅ Initialize NetworkService di main.dart
- ✅ Start OfflineSyncService.startMonitoring() di main screen
- ✅ Stop OfflineSyncService di dispose()
- ✅ Tampilkan OfflineStatusIndicator di AppBar
- ✅ Handle errors gracefully dengan try-catch
- ✅ Beri feedback user saat offline (badge, indicator, dll)
- ✅ Test offline scenario sebelum deploy

## Migration Checklist untuk Existing Code

Jika Anda sudah punya kode harvest entry, berikut checklist untuk migrasi:

- [ ] Add dependencies di pubspec.yaml (hive, connectivity_plus, uuid)
- [ ] Run `flutter pub get`
- [ ] Run `build_runner build` untuk generate adapters
- [ ] Update main.dart untuk initialize services
- [ ] Update dashboard/main screen untuk start sync monitoring
- [ ] Replace direct API calls dengan ProductionRepository
- [ ] Add OfflineStatusIndicator ke AppBar
- [ ] Test offline scenarios
- [ ] Update UI untuk show pending count (optional)
- [ ] Add manual sync button (optional)

## Done! 🎉

Dengan langkah-langkah di atas, aplikasi Anda sekarang sudah support Offline Mode!
