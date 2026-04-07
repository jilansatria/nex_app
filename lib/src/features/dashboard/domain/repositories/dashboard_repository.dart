import '../entities/production_entity.dart';
import '../entities/dashboard_entity.dart';
import '../entities/hr_entity.dart';
import '../entities/inventory_item_entity.dart';

abstract class DashboardRepository {
  Future<DashboardEntity> getDashboardSummary();
  Future<List<double>> getProductionTrend(); // Last 7 days
  Future<List<ProductionEntity>> getLatestHarvests();
  Future<bool> submitHarvestProduction(Map<String, dynamic> data);
  Future<List<HREntity>> getHRData();
  Future<List<InventoryItemEntity>> getInventoryData();
}
