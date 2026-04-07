import '../../domain/entities/dashboard_entity.dart';
import '../../domain/entities/production_entity.dart';
import '../../domain/entities/hr_entity.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardEntity> getDashboardSummary() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API
    return const DashboardEntity(
      productionTon: 45.2,
      productionTrend: 2.4,
      harvestTon: 1250,
      harvestTrend: -1.2,
      oer: 21.5,
      oerTrend: 0.5,
      rainfall: 12,
    );
  }

  @override
  Future<List<double>> getProductionTrend() async {
    await Future.delayed(const Duration(seconds: 1));
    return [30.0, 35.0, 32.0, 40.0, 38.0, 45.0, 42.0];
  }

  @override
  Future<List<ProductionEntity>> getLatestHarvests() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      const ProductionEntity(
        name: 'Panen Blok A12',
        status: 'Harvested',
        qty: '145',
        date: '2026-02-09',
      ),
      const ProductionEntity(
        name: 'Panen Blok A13',
        status: 'Harvested',
        qty: '98',
        date: '2026-02-09',
      ),
    ];
  }

  @override
  Future<bool> submitHarvestProduction(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // Mock always succeeds
  }

  @override
  Future<List<HREntity>> getHRData() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      const HREntity(
          name: 'Ahmad Fauzi',
          position: 'Field Worker',
          startDate: '2024-01-15',
          salary: 'Rp 4.500.000'),
      const HREntity(
          name: 'Budi Santoso',
          position: 'Supervisor',
          startDate: '2023-06-01',
          salary: 'Rp 6.000.000'),
      const HREntity(
          name: 'Citra Dewi',
          position: 'Admin',
          startDate: '2024-03-10',
          salary: 'Rp 5.000.000'),
    ];
  }

  @override
  Future<List<InventoryItemEntity>> getInventoryData() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      const InventoryItemEntity(
          id: '1',
          name: 'Pupuk NPK',
          entryDate: '2026-01-10',
          condition: 'Good',
          quantity: '500 kg',
          expiryDate: '2027-01-10'),
      const InventoryItemEntity(
          id: '2',
          name: 'Herbisida',
          entryDate: '2026-01-15',
          condition: 'Good',
          quantity: '200 L',
          expiryDate: '2027-06-15'),
      const InventoryItemEntity(
          id: '3',
          name: 'Alat Panen',
          entryDate: '2025-12-01',
          condition: 'Fair',
          quantity: '50 unit',
          expiryDate: '-'),
    ];
  }
}
