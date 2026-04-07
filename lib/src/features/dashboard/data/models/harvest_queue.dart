import 'package:hive/hive.dart';

part 'harvest_queue.g.dart';

@HiveType(typeId: 2)
class HarvestQueue extends HiveObject {
  @HiveField(0)
  final String localId;

  @HiveField(1)
  final String blockId;

  @HiveField(2)
  final double quantity;

  @HiveField(3)
  final String unit;

  @HiveField(4)
  final String fieldCode;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final bool synced;

  HarvestQueue({
    required this.localId,
    required this.blockId,
    required this.quantity,
    required this.unit,
    required this.fieldCode,
    required this.timestamp,
    this.synced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'block_id': blockId,
      'quantity': quantity,
      'unit': unit,
      'field_code': fieldCode,
      'status': 'Harvested',
    };
  }
}
