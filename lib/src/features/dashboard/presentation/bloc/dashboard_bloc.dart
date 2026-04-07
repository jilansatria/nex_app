import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/entities/production_entity.dart';
import '../../domain/entities/hr_entity.dart';
import '../../domain/entities/inventory_item_entity.dart';

// Events
abstract class DashboardEvent {}

class LoadDashboard extends DashboardEvent {}

// States
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardEntity summary;
  final List<double> trend;
  final List<ProductionEntity> latestHarvests;
  final List<HREntity> hrData;
  final List<InventoryItemEntity> inventoryData;

  DashboardLoaded(
    this.summary,
    this.trend,
    this.latestHarvests,
    this.hrData,
    this.inventoryData,
  );
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

// Bloc
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc(this.repository) : super(DashboardInitial()) {
    on<LoadDashboard>((event, emit) async {
      emit(DashboardLoading());
      try {
        final results = await Future.wait([
          repository.getDashboardSummary(),
          repository.getProductionTrend(),
          repository.getLatestHarvests(),
          repository.getHRData(),
          repository.getInventoryData(),
        ]);
        emit(
          DashboardLoaded(
            results[0] as DashboardEntity,
            results[1] as List<double>,
            results[2] as List<ProductionEntity>,
            results[3] as List<HREntity>,
            results[4] as List<InventoryItemEntity>,
          ),
        );
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    });
  }
}
