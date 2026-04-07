import 'package:equatable/equatable.dart';

class GISBlockEntity extends Equatable {
  final String id;
  final String code;
  final String estateName;
  final double? latitude;
  final double? longitude;
  final double area;
  final DateTime? lastHarvestDate;
  final double yieldTonHa;
  final int healthScore;
  final String statusColor;

  const GISBlockEntity({
    required this.id,
    required this.code,
    required this.estateName,
    this.latitude,
    this.longitude,
    required this.area,
    this.lastHarvestDate,
    required this.yieldTonHa,
    required this.healthScore,
    required this.statusColor,
  });

  factory GISBlockEntity.fromJson(Map<String, dynamic> json) {
    return GISBlockEntity(
      id: json['id'],
      code: json['code'],
      estateName: json['estate_name'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      area: (json['area'] as num).toDouble(),
      lastHarvestDate: json['last_harvest_date'] != null
          ? DateTime.parse(json['last_harvest_date'])
          : null,
      yieldTonHa: (json['yield_ton_ha'] as num).toDouble(),
      healthScore: json['health_score'] as int,
      statusColor: json['status_color'],
    );
  }

  @override
  List<Object?> get props => [id, code, healthScore];
}
