import 'package:hive/hive.dart';

part 'estate_local.g.dart';

@HiveType(typeId: 0)
class EstateLocal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String location;

  @HiveField(3)
  final double totalArea;

  EstateLocal({
    required this.id,
    required this.name,
    required this.location,
    required this.totalArea,
  });

  factory EstateLocal.fromJson(Map<String, dynamic> json) {
    return EstateLocal(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      totalArea: (json['total_area'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'total_area': totalArea,
    };
  }
}
