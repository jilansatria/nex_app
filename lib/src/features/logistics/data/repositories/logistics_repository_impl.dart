import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';
import '../../domain/entities/delivery_order_entity.dart';

class LogisticsRepositoryImpl {
  final DioClient _dioClient;

  LogisticsRepositoryImpl(this._dioClient);

  Future<List<DeliveryOrderEntity>> getDeliveryOrders() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.logistics);
      final List<dynamic> data = response.data;
      return data.map((json) => DeliveryOrderEntity.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createDeliveryOrder(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.logistics,
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.logistics}$id/status',
        queryParameters: {'status': status},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> receiveOrder(String id, double weight) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.logistics}$id/receive',
        queryParameters: {'weight': weight},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
