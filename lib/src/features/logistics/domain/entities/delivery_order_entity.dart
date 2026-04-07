import 'package:equatable/equatable.dart';

class DeliveryOrderEntity extends Equatable {
  final String id;
  final String doNumber;
  final String driverName;
  final String vehiclePlate;
  final String productType;
  final double estimatedTonnage;
  final String status;
  final String issuedAt;
  final double? weighbridgeWeight;
  final String? receivedAt;

  const DeliveryOrderEntity({
    required this.id,
    required this.doNumber,
    required this.driverName,
    required this.vehiclePlate,
    this.productType = 'TBS',
    required this.estimatedTonnage,
    required this.status,
    required this.issuedAt,
    this.weighbridgeWeight,
    this.receivedAt,
  });

  factory DeliveryOrderEntity.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderEntity(
      id: json['id'] as String,
      doNumber: json['do_number'] as String,
      driverName: json['driver_name'] as String,
      vehiclePlate: json['vehicle_plate'] as String,
      productType: json['product_type'] ?? 'TBS',
      estimatedTonnage: (json['estimated_tonnage'] as num).toDouble(),
      status: json['status'] as String,
      issuedAt: json['issued_at'] as String,
      weighbridgeWeight: json['weighbridge_weight'] != null
          ? (json['weighbridge_weight'] as num).toDouble()
          : null,
      receivedAt: json['received_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    doNumber,
    driverName,
    vehiclePlate,
    productType,
    estimatedTonnage,
    status,
    issuedAt,
    weighbridgeWeight,
    receivedAt,
  ];
}
