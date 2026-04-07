import 'package:nex_app/src/core/constants/api_constants.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/features/dashboard/data/services/local_storage_service.dart';
import 'package:nex_app/src/features/dashboard/data/models/harvest_queue.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';

class ProductionRepository {
  final DioClient _dioClient;

  ProductionRepository(this._dioClient);

  Future<List<dynamic>> getEstates() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.estates);
      final estates = response.data as List<dynamic>;
      // Cache to local storage
      try {
        await LocalStorageService.saveEstates(estates);
      } catch (e) {
        print('Failed to cache estates: $e');
      }
      return estates;
    } catch (e) {
      // If offline, use cached data
      final cachedEstates = LocalStorageService.getEstates();
      if (cachedEstates.isNotEmpty) {
        return cachedEstates;
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getBlocks(String estateId) async {
    try {
      final cleanBaseEstates = ApiConstants.estates.endsWith('/')
          ? ApiConstants.estates
          : '${ApiConstants.estates}/';
      final response = await _dioClient.dio.get(
        '$cleanBaseEstates$estateId/blocks',
      );
      final rawData = response.data;
      if (rawData == null) return [];
      final blocks = rawData as List<dynamic>;
      // Cache to local storage
      try {
        await LocalStorageService.saveBlocks(estateId, blocks);
      } catch (e) {
        print('Failed to cache blocks: $e');
      }
      return blocks;
    } catch (e) {
      // If offline, use cached data
      final cachedBlocks = LocalStorageService.getBlocks(estateId);
      if (cachedBlocks.isNotEmpty) {
        return cachedBlocks;
      }
      rethrow;
    }
  }

  Future<bool> submitHarvest({
    required String blockId,
    required double quantity,
    required String unit,
    String? fieldCode,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.production,
        data: {
          'block_id': blockId,
          'quantity': quantity,
          'unit': unit,
          'field_code': fieldCode ?? 'Mobile Entry',
          'status': 'Harvested',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // Don't queue 4xx errors (Client Error)
      if (e is DioException) {
        if (e.response?.statusCode != null &&
            e.response!.statusCode! >= 400 &&
            e.response!.statusCode! < 500) {
          rethrow;
        }
      }

      // If offline or server error, save to queue
      final harvest = HarvestQueue(
        localId: const Uuid().v4(),
        blockId: blockId,
        quantity: quantity,
        unit: unit,
        fieldCode: fieldCode ?? 'Mobile Entry',
        timestamp: DateTime.now(),
      );
      await LocalStorageService.addToQueue(harvest);
      return true; // Return success for offline mode
    }
  }

  Future<int> syncPendingHarvests() async {
    final pending = LocalStorageService.getPendingHarvests();
    int syncedCount = 0;

    for (var harvest in pending) {
      try {
        final response = await _dioClient.dio.post(
          ApiConstants.production,
          data: harvest.toJson(),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          await LocalStorageService.markAsSynced(harvest.localId);
          syncedCount++;
        }
      } catch (e) {
        // Skip failed sync, will retry next time
        continue;
      }
    }

    // Clean up synced harvests
    if (syncedCount > 0) {
      await LocalStorageService.clearSyncedHarvests();
    }

    return syncedCount;
  }

  int getPendingCount() {
    return LocalStorageService.getPendingHarvests().length;
  }
}
