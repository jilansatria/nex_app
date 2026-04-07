import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

/// Repository for Mill module API calls.
/// Covers: Mill Master, Weighbridge, Production Logs, Daily Summary.
class MillRepository {
  final DioClient _dioClient = DioClient();

  // ── Mill Master ──

  Future<List<Map<String, dynamic>>> getMills({
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await _dioClient.dio.get(
      ApiConstants.mills,
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getMill(String millId) async {
    final response = await _dioClient.dio.get('${ApiConstants.mills}$millId');
    return response.data;
  }

  Future<Map<String, dynamic>> createMill({
    required String name,
    required String code,
    required double capacityTonPerHour,
    String? location,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.mills,
      data: {
        'name': name,
        'code': code,
        'capacity_ton_per_hour': capacityTonPerHour,
        if (location != null) 'location': location,
      },
    );
    return response.data;
  }

  // ── Weighbridge ──

  Future<Map<String, dynamic>> weighIn({
    required String millId,
    required String vehiclePlate,
    required double weightInKg,
    String? transporter,
    String? estateOrigin,
    String? blockOrigin,
  }) async {
    final response = await _dioClient.dio.post(
      '${ApiConstants.mills}weighbridge/weigh-in',
      data: {
        'mill_id': millId,
        'vehicle_plate': vehiclePlate,
        'weight_in_kg': weightInKg,
        if (transporter != null) 'transporter': transporter,
        if (estateOrigin != null) 'estate_origin': estateOrigin,
        if (blockOrigin != null) 'block_origin': blockOrigin,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> weighOut({
    required String entryId,
    required double weightOutKg,
    double? gradingUnripePct,
    double? gradingRipePct,
    double? gradingOverripePct,
    double? gradingLongStalkPct,
    double? gradingLooseFruitKg,
    String? notes,
  }) async {
    final response = await _dioClient.dio.put(
      '${ApiConstants.mills}weighbridge/$entryId/weigh-out',
      data: {
        'weight_out_kg': weightOutKg,
        'grading_unripe_pct': gradingUnripePct ?? 0,
        'grading_ripe_pct': gradingRipePct ?? 0,
        'grading_overripe_pct': gradingOverripePct ?? 0,
        'grading_long_stalk_pct': gradingLongStalkPct ?? 0,
        'grading_loose_fruit_kg': gradingLooseFruitKg ?? 0,
        if (notes != null) 'notes': notes,
      },
    );
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getWeighbridgeEntries({
    required String millId,
    String? status,
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await _dioClient.dio.get(
      '${ApiConstants.mills}weighbridge/$millId/entries',
      queryParameters: {
        'skip': skip,
        'limit': limit,
        if (status != null) 'status': status,
      },
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // ── Production Log ──

  Future<Map<String, dynamic>> createProductionLog({
    required String millId,
    required String date,
    required String shift,
    required double ffbProcessedKg,
    required double cpoProducedKg,
    required double kernelProducedKg,
    double? shellProducedKg,
    double? fiberProducedKg,
    double? oilLossesPct,
    double? kernelLossesPct,
    double? steamPressureBar,
    double? powerConsumptionKwh,
    double? waterConsumptionM3,
    String? notes,
  }) async {
    final response = await _dioClient.dio.post(
      '${ApiConstants.mills}production/log',
      data: {
        'mill_id': millId,
        'date': date,
        'shift': shift,
        'ffb_processed_kg': ffbProcessedKg,
        'cpo_produced_kg': cpoProducedKg,
        'kernel_produced_kg': kernelProducedKg,
        'shell_produced_kg': shellProducedKg ?? 0,
        'fiber_produced_kg': fiberProducedKg ?? 0,
        'oil_losses_pct': oilLossesPct ?? 0,
        'kernel_losses_pct': kernelLossesPct ?? 0,
        if (steamPressureBar != null) 'steam_pressure_bar': steamPressureBar,
        if (powerConsumptionKwh != null)
          'power_consumption_kwh': powerConsumptionKwh,
        if (waterConsumptionM3 != null)
          'water_consumption_m3': waterConsumptionM3,
        if (notes != null) 'notes': notes,
      },
    );
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getProductionLogs({
    required String millId,
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await _dioClient.dio.get(
      '${ApiConstants.mills}production/$millId/logs',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getDailySummary({
    required String millId,
    String? targetDate,
  }) async {
    final response = await _dioClient.dio.get(
      '${ApiConstants.mills}production/$millId/daily-summary',
      queryParameters: {if (targetDate != null) 'target_date': targetDate},
    );
    return response.data;
  }
}
