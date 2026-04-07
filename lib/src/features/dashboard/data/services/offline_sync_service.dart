import 'dart:async';
import '../models/harvest_queue.dart';
import '../repositories/dashboard_repository_impl.dart';
import 'local_storage_service.dart';
import 'network_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Added for ConnectivityResult

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  DashboardRepositoryImpl? _repository;
  final NetworkService _networkService = NetworkService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  void initialize(DashboardRepositoryImpl repository) {
    _repository = repository;
    startMonitoring();
  }

  /// Mulai monitoring koneksi internet
  void startMonitoring() {
    _connectivitySubscription = _networkService.onConnectivityChanged.listen((
      results,
    ) {
      final isConnected = !results.contains(ConnectivityResult.none);
      if (isConnected) {
        _scheduleSyncIfNeeded();
      }
    });

    // Juga check secara periodik setiap 5 menit
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _scheduleSyncIfNeeded(),
    );

    // Check langsung saat mulai
    _scheduleSyncIfNeeded();
  }

  /// Stop monitoring
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }

  /// Schedule sync jika ada pending data
  void _scheduleSyncIfNeeded() {
    if (!_isSyncing) {
      final pendingCount = LocalStorageService.getPendingHarvests().length;
      if (pendingCount > 0) {
        syncPendingHarvests();
      }
    }
  }

  /// Sync semua harvest yang pending
  Future<SyncResult> syncPendingHarvests() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync sedang berlangsung',
        totalPending: 0,
        synced: 0,
        failed: 0,
      );
    }

    _isSyncing = true;
    int synced = 0;
    int failed = 0;

    try {
      // Check koneksi menggunakan NetworkService
      final isConnected = await _networkService.checkConnection();

      if (!isConnected) {
        return SyncResult(
          success: false,
          message: 'Tidak ada koneksi internet',
          totalPending: LocalStorageService.getPendingHarvests().length,
          synced: 0,
          failed: 0,
        );
      }

      final pendingHarvests = LocalStorageService.getPendingHarvests();

      if (pendingHarvests.isEmpty) {
        return SyncResult(
          success: true,
          message: 'Tidak ada data yang perlu disinkronkan',
          totalPending: 0,
          synced: 0,
          failed: 0,
        );
      }

      // Sync satu per satu
      for (var harvest in pendingHarvests) {
        try {
          final success = await _repository!.submitHarvestProduction(
            harvest.toJson(),
          );

          if (success) {
            await LocalStorageService.markAsSynced(harvest.localId);
            synced++;
          } else {
            failed++;
          }
        } catch (e) {
          print('Error syncing harvest ${harvest.localId}: $e');
          failed++;
        }
      }

      // Cleanup synced data
      await LocalStorageService.clearSyncedHarvests();

      return SyncResult(
        success: failed == 0,
        message: failed == 0
            ? 'Semua data berhasil disinkronkan'
            : '$synced data berhasil, $failed gagal',
        totalPending: pendingHarvests.length,
        synced: synced,
        failed: failed,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error: $e',
        totalPending: LocalStorageService.getPendingHarvests().length,
        synced: synced,
        failed: failed,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Check status sync
  SyncStatus getSyncStatus() {
    final pendingHarvests = LocalStorageService.getPendingHarvests();
    return SyncStatus(
      isSyncing: _isSyncing,
      pendingCount: pendingHarvests.length,
      lastSyncTime: _getLastSyncTime(pendingHarvests),
    );
  }

  DateTime? _getLastSyncTime(List<HarvestQueue> pendingHarvests) {
    if (pendingHarvests.isEmpty) {
      return null;
    }
    // Return timestamp dari harvest terlama
    try {
      return pendingHarvests
          .map((h) => h.timestamp)
          .reduce((a, b) => a.isBefore(b) ? a : b);
    } catch (e) {
      return null;
    }
  }

  /// Force sync manual
  Future<SyncResult> forceSyncNow() async {
    return await syncPendingHarvests();
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int totalPending;
  final int synced;
  final int failed;

  SyncResult({
    required this.success,
    required this.message,
    required this.totalPending,
    required this.synced,
    required this.failed,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, '
        'total: $totalPending, synced: $synced, failed: $failed)';
  }
}

class SyncStatus {
  final bool isSyncing;
  final int pendingCount;
  final DateTime? lastSyncTime;

  SyncStatus({
    required this.isSyncing,
    required this.pendingCount,
    this.lastSyncTime,
  });

  bool get hasPendingData => pendingCount > 0;

  String get statusMessage {
    if (isSyncing) return 'Sedang sinkronisasi...';
    if (pendingCount == 0) return 'Semua data tersinkronisasi';
    return '$pendingCount data menunggu sinkronisasi';
  }
}
