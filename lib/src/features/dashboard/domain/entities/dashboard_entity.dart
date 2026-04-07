import 'package:equatable/equatable.dart';

class DashboardEntity extends Equatable {
  final double productionTon;
  final double productionTrend; // Percentage
  final double harvestTon;
  final double harvestTrend;
  final double oer;
  final double oerTrend;
  final double rainfall;

  // Admin/Sales fields
  final double totalEarnings;
  final String mostBuyers;
  final double profit;

  const DashboardEntity({
    required this.productionTon,
    required this.productionTrend,
    required this.harvestTon,
    required this.harvestTrend,
    required this.oer,
    required this.oerTrend,
    required this.rainfall,
    this.totalEarnings = 0,
    this.mostBuyers = '-',
    this.profit = 0,
    this.totalEmployees = 0,
    this.presentEmployees = 0,
    this.absentEmployees = 0,
    this.lateEmployees = 0,
  });

  final int totalEmployees;
  final int presentEmployees;
  final int absentEmployees;
  final int lateEmployees;

  @override
  List<Object?> get props => [
    productionTon,
    productionTrend,
    harvestTon,
    harvestTrend,
    oer,
    oerTrend,
    rainfall,
    totalEarnings,
    mostBuyers,
    profit,
    totalEmployees,
    presentEmployees,
    absentEmployees,
    lateEmployees,
  ];
}
