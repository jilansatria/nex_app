import 'package:hive/hive.dart';

part 'block_local.g.dart';

@HiveType(typeId: 1)
class BlockLocal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String estateId;

  @HiveField(2)
  final String code;

  @HiveField(3)
  final double area;

  @HiveField(4)
  final int palmCount;

  BlockLocal({
    required this.id,
    required this.estateId,
    required this.code,
    required this.area,
    required this.palmCount,
  });

  factory BlockLocal.fromJson(Map<String, dynamic> json) {
    return BlockLocal(
      id: json['id'] as String,
      estateId: json['estate_id'] as String,
      code: json['code'] as String,
      area: (json['area'] as num).toDouble(),
      palmCount: json['palm_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estate_id': estateId,
      'code': code,
      'area': area,
      'palm_count': palmCount,
    };
  }
}
