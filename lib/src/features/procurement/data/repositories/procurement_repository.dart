import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';
import '../../domain/entities/procurement_entities.dart';

class ProcurementRepository {
  final DioClient _dioClient;

  ProcurementRepository(this._dioClient);

  Future<List<PurchaseOrderEntity>> getPOs() async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.procurement}purchase-orders',
      );
      return (response.data as List)
          .map((json) => PurchaseOrderEntity.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createPO(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.procurement}purchase-orders',
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> approvePO(String id) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.procurement}purchase-orders/$id/approve',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> receivePO(String id) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.procurement}purchase-orders/$id/receive',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
