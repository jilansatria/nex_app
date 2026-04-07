import 'package:hive_flutter/hive_flutter.dart';
import '../models/harvest_queue.dart';

class LocalStorageService {
  static const String _estatesBox = 'estates_cache';
  static const String _blocksBox = 'blocks_cache';
  static const String _harvestQueueBox = 'harvest_queue_cache';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(HarvestQueueAdapter());
    }

    // Use simple dynamic boxes - no adapters needed
    await Hive.openBox(_estatesBox);
    await Hive.openBox(_blocksBox);
    await Hive.openBox<HarvestQueue>(_harvestQueueBox);
  }

  // ========== ESTATES ==========
  static Future<void> saveEstates(List<dynamic> estates) async {
    final box = Hive.box(_estatesBox);
    await box.clear();
    for (var estate in estates) {
      final map = Map<String, dynamic>.from(estate as Map);
      await box.put(map['id'], map);
    }
  }

  static List<Map<String, dynamic>> getEstates() {
    final box = Hive.box(_estatesBox);
    return box.values
        .where((e) => e != null && e is Map)
        .map((e) {
          try {
            return Map<String, dynamic>.from(e as Map);
          } catch (_) {
            return <String, dynamic>{};
          }
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // ========== BLOCKS ==========
  static Future<void> saveBlocks(String estateId, List<dynamic> blocks) async {
    final box = Hive.box(_blocksBox);
    // Remove old blocks for this estate
    final keysToDelete = <dynamic>[];
    for (var entry in box.toMap().entries) {
      try {
        if (entry.value is Map) {
          final map = Map<String, dynamic>.from(entry.value as Map);
          if (map['estate_id'] == estateId) {
            keysToDelete.add(entry.key);
          }
        }
      } catch (e) {
        keysToDelete.add(entry.key); // Clean up corrupted data
      }
    }
    for (var key in keysToDelete) {
      await box.delete(key);
    }

    // Add new blocks
    for (var block in blocks) {
      if (block == null) continue;
      try {
        final map = Map<String, dynamic>.from(block as Map);
        map['estate_id'] = estateId; // Inject estate_id for later filtering
        if (map['id'] != null) {
          await box.put(map['id'], map);
        }
      } catch (e) {
        print('Error saving block: $e');
      }
    }
  }

  static List<Map<String, dynamic>> getBlocks(String estateId) {
    final box = Hive.box(_blocksBox);
    return box.values
        .where((e) => e != null && e is Map)
        .map((e) {
          try {
            return Map<String, dynamic>.from(e as Map);
          } catch (_) {
            return <String, dynamic>{};
          }
        })
        .where((b) => b.isNotEmpty && b['estate_id'] == estateId)
        .toList();
  }

  // ========== HARVEST QUEUE ==========
  static Future<void> addToQueue(HarvestQueue harvest) async {
    final box = Hive.box<HarvestQueue>(_harvestQueueBox);
    await box.put(harvest.localId, harvest);
  }

  static List<HarvestQueue> getPendingHarvests() {
    final box = Hive.box<HarvestQueue>(_harvestQueueBox);
    return box.values.where((h) => !h.synced).toList();
  }

  static Future<void> markAsSynced(String localId) async {
    final box = Hive.box<HarvestQueue>(_harvestQueueBox);
    final harvest = box.get(localId);
    if (harvest != null) {
      final updated = HarvestQueue(
        localId: harvest.localId,
        blockId: harvest.blockId,
        quantity: harvest.quantity,
        unit: harvest.unit,
        fieldCode: harvest.fieldCode,
        timestamp: harvest.timestamp,
        synced: true,
      );
      await box.put(localId, updated);
    }
  }

  static Future<void> clearSyncedHarvests() async {
    final box = Hive.box<HarvestQueue>(_harvestQueueBox);
    final syncedKeys = box.values
        .where((h) => h.synced)
        .map((h) => h.localId)
        .toList();
    for (var key in syncedKeys) {
      await box.delete(key);
    }
  }
}
