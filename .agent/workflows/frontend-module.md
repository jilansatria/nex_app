---
description: Panduan Pengembangan Modul Frontend dengan Adaptive UI
---

# Workflow Pengembangan Modul Frontend NEX

Workflow detail untuk pengembangan modul frontend NEX menggunakan Flutter dengan adaptive UI (Mobile + Web).

## Template Pengembangan Modul

### Langkah 1: Buat Struktur Feature
```bash
cd "d:\Kuliah\MAGANG IROSTECH\nex_app"
mkdir lib\features\[nama_modul]
mkdir lib\features\[nama_modul]\screens
mkdir lib\features\[nama_modul]\widgets
mkdir lib\features\[nama_modul]\controllers
```

### Langkah 2: Definisikan Data Model
**Lokasi**: `lib/domain/models/[nama_model].dart`

```dart
class [NamaModel] {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  [NamaModel]({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Dari JSON (API response)
  factory [NamaModel].fromJson(Map<String, dynamic> json) {
    return [NamaModel](
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  // Ke JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Untuk local storage (Hive/SQLite)
  factory [NamaModel].fromLocal(Map<String, dynamic> json) {
    return [NamaModel].fromJson(json);
  }
  
  Map<String, dynamic> toLocal() {
    return toJson();
  }
}
```

### Langkah 3: Buat API Service
**Lokasi**: `lib/data/services/[nama_modul]_service.dart`

```dart
import 'package:dio/dio.dart';
import '../../domain/models/[nama_model].dart';
import '../../core/config/api_config.dart';

class [NamaModul]Service {
  final Dio _dio;
  
  [NamaModul]Service(this._dio);
  
  Future<List<[NamaModel]>> getAll({int skip = 0, int limit = 100}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/[nama_modul]/',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      return (response.data as List)
          .map((json) => [NamaModel].fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data [nama_modul]: $e');
    }
  }
  
  Future<[NamaModel]> getById(int id) async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/[nama_modul]/$id');
      return [NamaModel].fromJson(response.data);
    } catch (e) {
      throw Exception('Gagal mengambil [nama_modul]: $e');
    }
  }
  
  Future<[NamaModel]> create(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/[nama_modul]/',
        data: data,
      );
      return [NamaModel].fromJson(response.data);
    } catch (e) {
      throw Exception('Gagal membuat [nama_modul]: $e');
    }
  }
  
  Future<[NamaModel]> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.baseUrl}/[nama_modul]/$id',
        data: data,
      );
      return [NamaModel].fromJson(response.data);
    } catch (e) {
      throw Exception('Gagal update [nama_modul]: $e');
    }
  }
  
  Future<void> delete(int id) async {
    try {
      await _dio.delete('${ApiConfig.baseUrl}/[nama_modul]/$id');
    } catch (e) {
      throw Exception('Gagal menghapus [nama_modul]: $e');
    }
  }
}
```

### Langkah 4: Buat Repository (dengan Dukungan Offline)
**Lokasi**: `lib/data/repositories/[nama_modul]_repository.dart`

```dart
import '../../domain/models/[nama_model].dart';
import '../services/[nama_modul]_service.dart';
import '../../core/storage/local_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class [NamaModul]Repository {
  final [NamaModul]Service _service;
  final LocalStorage _localStorage;
  
  [NamaModul]Repository(this._service, this._localStorage);
  
  Future<List<[NamaModel]>> getAll({bool forceRefresh = false}) async {
    // Cek konektivitas
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;
    
    if (isOnline || forceRefresh) {
      try {
        // Ambil dari API
        final items = await _service.getAll();
        // Cache secara lokal
        await _localStorage.save('[nama_modul]s', items.map((e) => e.toLocal()).toList());
        return items;
      } catch (e) {
        // Fallback ke cache lokal jika API gagal
        return _getFromLocalStorage();
      }
    } else {
      // Mode offline - gunakan local storage
      return _getFromLocalStorage();
    }
  }
  
  Future<List<[NamaModel]>> _getFromLocalStorage() async {
    final cached = await _localStorage.get('[nama_modul]s');
    if (cached != null && cached is List) {
      return cached.map((json) => [NamaModel].fromLocal(json)).toList();
    }
    return [];
  }
  
  Future<[NamaModel]> create(Map<String, dynamic> data) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;
    
    if (isOnline) {
      return await _service.create(data);
    } else {
      // Queue untuk sync ketika online
      await _localStorage.addToSyncQueue({
        'action': 'create',
        'module': '[nama_modul]',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      // Buat record temporary lokal
      return [NamaModel].fromJson({...data, 'id': -1}); // ID negatif sementara
    }
  }
  
  // Sync operasi yang di-queue
  Future<void> syncPendingOperations() async {
    final queue = await _localStorage.getSyncQueue();
    for (var operation in queue) {
      try {
        if (operation['action'] == 'create') {
          await _service.create(operation['data']);
          await _localStorage.removeFromSyncQueue(operation);
        }
        // Handle update, delete dengan cara yang sama
      } catch (e) {
        // Tetap di queue jika sync gagal
        print('Sync gagal untuk operasi: $e');
      }
    }
  }
}
```

### Langkah 5: Buat State Management (Provider/Riverpod/Bloc)
**Lokasi**: `lib/features/[nama_modul]/controllers/[nama_modul]_controller.dart`

Contoh menggunakan Provider:
```dart
import 'package:flutter/foundation.dart';
import '../../../domain/models/[nama_model].dart';
import '../../../data/repositories/[nama_modul]_repository.dart';

class [NamaModul]Controller extends ChangeNotifier {
  final [NamaModul]Repository _repository;
  
  List<[NamaModel]> _items = [];
  bool _isLoading = false;
  String? _error;
  
  List<[NamaModel]> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  [NamaModul]Controller(this._repository);
  
  Future<void> loadItems({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _items = await _repository.getAll(forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> createItem(Map<String, dynamic> data) async {
    try {
      final newItem = await _repository.create(data);
      _items.add(newItem);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> syncOfflineData() async {
    try {
      await _repository.syncPendingOperations();
      await loadItems(forceRefresh: true);
    } catch (e) {
      _error = 'Sync gagal: $e';
      notifyListeners();
    }
  }
}
```

### Langkah 6: Buat Screen Adaptive UI

#### 6A: Screen Mobile (Pekerja Lapangan)
**Lokasi**: `lib/features/[nama_modul]/screens/[nama_modul]_mobile_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/[nama_modul]_controller.dart';

class [NamaModul]MobileScreen extends StatefulWidget {
  @override
  _[NamaModul]MobileScreenState createState() => _[NamaModul]MobileScreenState();
}

class _[NamaModul]MobileScreenState extends State<[NamaModul]MobileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<[NamaModul]Controller>().loadItems();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('[Nama Modul]'),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              context.read<[NamaModul]Controller>().syncOfflineData();
            },
          ),
        ],
      ),
      body: Consumer<[NamaModul]Controller>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (controller.error != null) {
            return Center(child: Text('Error: ${controller.error}'));
          }
          
          return ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('ID: ${item.id}'),
                // TOMBOL BESAR untuk pekerja lapangan
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              );
            },
          );
        },
      ),
      // FAB BESAR untuk sentuhan mudah
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate ke create screen
        },
        label: Text('Tambah Baru'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
```

#### 6B: Screen Desktop/Web (Manajemen)
**Lokasi**: `lib/features/[nama_modul]/screens/[nama_modul]_desktop_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/[nama_modul]_controller.dart';

class [NamaModul]DesktopScreen extends StatefulWidget {
  @override
  _[NamaModul]DesktopScreenState createState() => _[NamaModul]DesktopScreenState();
}

class _[NamaModul]DesktopScreenState extends State<[NamaModul]DesktopScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<[NamaModul]Controller>().loadItems();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manajemen [Nama Modul]',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<[NamaModul]Controller>().loadItems(forceRefresh: true);
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('Refresh'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Tampilkan dialog create
                      },
                      icon: Icon(Icons.add),
                      label: Text('Tambah Baru'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Data table dengan sorting, filtering
            Expanded(
              child: Consumer<[NamaModul]Controller>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Dibuat Pada')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: controller.items.map((item) {
                        return DataRow(cells: [
                          DataCell(Text(item.id.toString())),
                          DataCell(Text(item.name)),
                          DataCell(Text(item.createdAt.toString())),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    // Aksi edit
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    // Aksi delete
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 6C: Wrapper Adaptive
**Lokasi**: `lib/features/[nama_modul]/screens/[nama_modul]_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '[nama_modul]_mobile_screen.dart';
import '[nama_modul]_desktop_screen.dart';

class [NamaModul]Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Routing adaptive berdasarkan platform
    if (kIsWeb || (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux))) {
      return [NamaModul]DesktopScreen();
    } else {
      return [NamaModul]MobileScreen();
    }
  }
}
```

### Langkah 7: Tambahkan Routing
**Lokasi**: `lib/core/router/app_router.dart`

```dart
import 'package:go_router/go_router.dart';
import '../../features/[nama_modul]/screens/[nama_modul]_screen.dart';

final appRouter = GoRouter(
  routes: [
    // ... routes yang sudah ada
    GoRoute(
      path: '/[nama_modul]',
      builder: (context, state) => [NamaModul]Screen(),
    ),
  ],
);
```

### Langkah 8: Test Modul
// turbo
```bash
cd "d:\Kuliah\MAGANG IROSTECH\nex_app"
flutter run -d chrome
```

---

## Contoh Modul Spesifik (Berdasarkan PRD)

### Contoh 1: Modul Field - Entry Panen (OFFLINE-FIRST)

**Fitur Khusus**:
- Integrasi kamera untuk foto TBS
- GPS auto-capture untuk lokasi
- Offline queue dengan indikator sync
- Tombol besar untuk pekerja lapangan

**Widget yang Dibutuhkan**:
- `CameraCapture widget` (package: camera)
- `GPSLocationPicker widget` (package: geolocator)
- `OfflineSyncIndicator widget` (custom)
- `HarvestEntryForm widget` (target sentuh besar)

### Contoh 2: Modul Production - Dashboard Hasil

**Fitur Khusus**:
- Chart real-time (trend OER/KER)
- Statistik produksi harian
- Integrasi data timbangan
- Export ke Excel/PDF

**Widget yang Dibutuhkan**:
- `ProductionChart widget` (package: fl_chart)
- `StatisticsCard widget`
- `ExportButton widget` (package: pdf)

---

## Checklist Testing

- [ ] UI Mobile berfungsi di Android device/emulator
- [ ] UI Desktop berfungsi di Chrome/Edge
- [ ] Mode offline menyimpan data secara lokal
- [ ] Sync berfungsi ketika konektivitas pulih
- [ ] Loading states ditampilkan dengan benar
- [ ] Pesan error user-friendly
- [ ] Navigasi berfungsi seamless
- [ ] Forms melakukan validasi input
- [ ] Integrasi API berfungsi end-to-end
- [ ] Breakpoint responsif ditest (mobile/tablet/desktop)

---

## Masalah Umum & Solusi

### Masalah: API connection refused
**Solusi**: Pastikan backend berjalan, cek API base URL di config

### Masalah: Data offline tidak sync
**Solusi**: Cek deteksi konektivitas, verifikasi implementasi sync queue

### Masalah: UI overflow di layar kecil
**Solusi**: Gunakan widget `SingleChildScrollView`, `Expanded`, `Flexible`

### Masalah: State tidak update
**Solusi**: Pastikan `notifyListeners()` dipanggil di controller
