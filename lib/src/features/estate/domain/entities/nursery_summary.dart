import 'package:equatable/equatable.dart';

class NurserySummary extends Equatable {
  final int totalSeedlings;
  final int preNursery;
  final int mainNursery;
  final int readyToPlant;
  final double mortalityRate;

  const NurserySummary({
    this.totalSeedlings = 0,
    this.preNursery = 0,
    this.mainNursery = 0,
    this.readyToPlant = 0,
    this.mortalityRate = 0.0,
  });

  factory NurserySummary.fromJson(Map<String, dynamic> json) {
    final stages = json['stages'] ?? {};
    return NurserySummary(
      totalSeedlings: json['total_seedlings'] ?? 0,
      preNursery: stages['pre_nursery'] ?? 0,
      mainNursery: stages['main_nursery'] ?? 0,
      readyToPlant: stages['ready_to_plant'] ?? 0,
      mortalityRate: (json['mortality_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    totalSeedlings,
    preNursery,
    mainNursery,
    readyToPlant,
    mortalityRate,
  ];
}
