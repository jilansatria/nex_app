import 'package:equatable/equatable.dart';

class ProductionEntity extends Equatable {
  final String name;
  final String status;
  final String qty;
  final String date;

  const ProductionEntity({
    required this.name,
    required this.status,
    required this.qty,
    required this.date,
  });

  factory ProductionEntity.fromJson(Map<String, dynamic> json) {
    return ProductionEntity(
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      qty: json['qty'] ?? '',
      date: json['date'] ?? '',
    );
  }

  @override
  List<Object?> get props => [name, status, qty, date];
}
