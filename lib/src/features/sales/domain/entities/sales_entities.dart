import 'package:equatable/equatable.dart';

class SalesContractEntity extends Equatable {
  final String id;
  final String contractNumber;
  final String buyerName;
  final String productType;
  final double quantityContracted;
  final double pricePerKg; // Base price
  final DateTime deliveryStartDate;
  final DateTime deliveryEndDate;
  final String status;
  final double
      fulfilledQuantity; // Computed on backend or locally? Backend suggested, but simple list length sum works too.

  const SalesContractEntity({
    required this.id,
    required this.contractNumber,
    required this.buyerName,
    required this.productType,
    required this.quantityContracted,
    required this.pricePerKg,
    required this.deliveryStartDate,
    required this.deliveryEndDate,
    required this.status,
    this.fulfilledQuantity = 0.0,
  });

  factory SalesContractEntity.fromJson(Map<String, dynamic> json) {
    return SalesContractEntity(
      id: json['id'],
      contractNumber: json['contract_number'],
      buyerName: json['buyer_name'],
      productType: json['product_type'],
      quantityContracted: (json['quantity_contracted'] as num).toDouble(),
      pricePerKg: (json['price_per_kg'] as num).toDouble(),
      deliveryStartDate: DateTime.parse(json['delivery_start_date']),
      deliveryEndDate: DateTime.parse(json['delivery_end_date']),
      status: json['status'],
      fulfilledQuantity:
          (json['fulfilled_quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        contractNumber,
        buyerName,
        status,
        quantityContracted,
      ];
}

class SalesShipmentEntity extends Equatable {
  final String id;
  final String doNumber;
  final double quantityShipped;
  final DateTime shipmentDate;
  final String status;

  // Quality
  final double ffa;
  final double moisture;
  final double dirt;

  // Pricing
  final double basePriceUnit;
  final double priceAdjustment;
  final double finalUnitPrice;
  final double totalPrice;

  const SalesShipmentEntity({
    required this.id,
    required this.doNumber,
    required this.quantityShipped,
    required this.shipmentDate,
    required this.status,
    required this.ffa,
    required this.moisture,
    required this.dirt,
    required this.basePriceUnit,
    required this.priceAdjustment,
    required this.finalUnitPrice,
    required this.totalPrice,
  });

  factory SalesShipmentEntity.fromJson(Map<String, dynamic> json) {
    return SalesShipmentEntity(
      id: json['id'] ?? '',
      doNumber: json['do_number'] ?? '-',
      quantityShipped: (json['quantity_shipped'] as num?)?.toDouble() ?? 0.0,
      shipmentDate: json['shipment_date'] != null
          ? DateTime.parse(json['shipment_date'])
          : DateTime.now(),
      status: json['status'] ?? 'Draft',
      ffa: (json['ffa_percentage'] as num?)?.toDouble() ?? 0.0,
      moisture: (json['moisture_percentage'] as num?)?.toDouble() ?? 0.0,
      dirt: (json['dirt_percentage'] as num?)?.toDouble() ?? 0.0,
      basePriceUnit: (json['base_price_unit'] as num?)?.toDouble() ?? 0.0,
      priceAdjustment: (json['price_adjustment'] as num?)?.toDouble() ?? 0.0,
      finalUnitPrice: (json['final_unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, doNumber, quantityShipped, totalPrice];
}
