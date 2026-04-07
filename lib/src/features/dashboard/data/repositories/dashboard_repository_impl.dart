import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/entities/production_entity.dart';
import '../../domain/entities/hr_entity.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DioClient _dioClient;

  DashboardRepositoryImpl(this._dioClient);

  @override
  Future<DashboardEntity> getDashboardSummary() async {
    try {
      final responses = await Future.wait([
        _dioClient.dio.get('${ApiConstants.dashboard}kpi'),
        _dioClient.dio.get('${ApiConstants.attendance}admin/summary'),
      ]);

      final kpiData = (responses[0].data as List).first;
      final attData = responses[1].data as Map<String, dynamic>;

      return DashboardEntity(
        productionTon: 12000,
        productionTrend: 12.5,
        harvestTon: kpiData['total_products_sold'] is int
            ? (kpiData['total_products_sold'] as int).toDouble()
            : kpiData['total_products_sold'],
        harvestTrend: 5.2,
        oer: 23.5,
        oerTrend: 1.2,
        rainfall: 45,
        totalEarnings: (kpiData['total_earnings'] is int)
            ? (kpiData['total_earnings'] as int).toDouble()
            : (kpiData['total_earnings'] as double),
        mostBuyers: kpiData['most_buyers'] as String,
        profit: (kpiData['profits'] is int)
            ? (kpiData['profits'] as int).toDouble()
            : (kpiData['profits'] as double),
        totalEmployees: attData['total_employees'] ?? 0,
        presentEmployees: attData['present'] ?? 0,
        absentEmployees: attData['absent'] ?? 0,
        lateEmployees: attData['late'] ?? 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<double>> getProductionTrend() async {
    return [100, 150, 400, 480, 350, 420, 380];
  }

  @override
  Future<List<ProductionEntity>> getLatestHarvests() async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.production}recent',
      );
      final List<dynamic> data = response.data;
      return data
          .map(
            (json) => ProductionEntity(
              name: json['location'] ?? 'Unknown',
              status: json['status'] ?? 'Harvested',
              qty: json['quantity']?.toString() ?? '0',
              date: json['date']?.toString().split('T').first ?? '-',
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> submitHarvestProduction(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.production,
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<HREntity>> getHRData() async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.dashboard}hr');
      final List<dynamic> data = response.data;
      return data
          .map(
            (json) => HREntity(
              name: json['name'] ?? '',
              position: json['position'] ?? '',
              startDate: json['start_date'] ?? '-',
              salary: json['salary'] ?? '-',
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<InventoryItemEntity>> getInventoryData() async {
    try {
      final response =
          await _dioClient.dio.get('${ApiConstants.inventory}items');
      final List<dynamic> data = response.data;
      return data.map((json) {
        // Flatten nested product data
        final productName = json['product']?['name'] ?? 'Unknown Product';
        final qty = json['quantity']?.toString() ?? '0';
        final unit = json['product']?['unit'] ?? '';

        return InventoryItemEntity(
          id: json['id']?.toString().substring(0, 8).toUpperCase() ?? '-',
          name: productName,
          entryDate: json['entry_date']?.toString().split('T').first ?? '-',
          condition: json['condition'] ?? 'Good',
          quantity: '$qty $unit'.trim(),
          expiryDate: json['expiry_date']?.toString().split('T').first ?? '-',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
