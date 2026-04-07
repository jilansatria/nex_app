import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';
import '../../domain/entities/sales_entities.dart';

/// Repository pattern for Sales operations.
/// Uses [ApiConstants] for all endpoint URLs — no hardcoded strings.
class SalesRepository {
  final DioClient _dioClient;

  SalesRepository(this._dioClient);

  // ── CONTRACTS ──

  Future<List<SalesContractEntity>> getContracts({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await _dioClient.dio.get(
        ApiConstants.salesContracts,
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((json) => SalesContractEntity.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createContract(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.salesContracts,
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getContractFulfillment(
      String contractId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.salesContracts}/$contractId/fulfillment',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // ── SHIPMENTS ──

  Future<List<SalesShipmentEntity>> getAllShipments() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.salesShipments);
      return (response.data as List)
          .map((json) => SalesShipmentEntity.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<SalesShipmentEntity>> getShipmentsByContract(
      String contractId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.salesShipments,
        queryParameters: {'contract_id': contractId},
      );
      return (response.data as List)
          .map((json) => SalesShipmentEntity.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createShipment(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.salesShipments,
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Confirm a shipment — triggers auto stock deduction.
  /// Returns the updated shipment data or null on error.
  Future<Map<String, dynamic>?> confirmShipment(String shipmentId) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.salesShipments}/$shipmentId/confirm',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Update shipment quality (FFA, moisture, dirt) — recalculates price.
  Future<Map<String, dynamic>?> updateShipmentQuality({
    required String shipmentId,
    required double ffa,
    required double moisture,
    required double dirt,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.salesShipments}/$shipmentId/quality',
        queryParameters: {
          'ffa': ffa,
          'moisture': moisture,
          'dirt': dirt,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // ── SUMMARY ──

  Future<Map<String, dynamic>?> getSalesSummary() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.salesSummary);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
