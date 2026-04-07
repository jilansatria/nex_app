import 'package:equatable/equatable.dart';

class InventoryItemEntity extends Equatable {
  final String id;
  final String name;
  final String entryDate;
  final String condition;
  final String quantity;
  final String expiryDate;

  const InventoryItemEntity({
    required this.id,
    required this.name,
    required this.entryDate,
    required this.condition,
    required this.quantity,
    required this.expiryDate,
  });

  factory InventoryItemEntity.fromJson(Map<String, dynamic> json) {
    return InventoryItemEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      entryDate: json['entry_date'] ?? '-',
      condition: json['condition'] ?? 'Good',
      quantity: json['quantity'] ?? '0',
      expiryDate: json['expiry_date'] ?? '-',
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    entryDate,
    condition,
    quantity,
    expiryDate,
  ];
}
