import 'package:equatable/equatable.dart';

class PurchaseOrderEntity extends Equatable {
  final String id;
  final String poNumber;
  final String supplierName;
  final double totalAmount;
  final String status;
  final DateTime date;
  final String? approvedById;
  final String? createdById;
  final List<PurchaseOrderItemEntity> items;

  const PurchaseOrderEntity({
    required this.id,
    required this.poNumber,
    required this.supplierName,
    required this.totalAmount,
    required this.status,
    required this.date,
    this.approvedById,
    this.createdById,
    this.items = const [],
  });

  factory PurchaseOrderEntity.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderEntity(
      id: json['id'],
      poNumber: json['po_number'],
      supplierName: json['supplier_name'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
      date: DateTime.parse(json['date']),
      approvedById: json['approved_by_id'],
      createdById: json['created_by_id'],
      items: (json['items'] as List? ?? [])
          .map((i) => PurchaseOrderItemEntity.fromJson(i))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, poNumber, status, totalAmount];
}

class PurchaseOrderItemEntity extends Equatable {
  final String id;
  final String productId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final double receivedQuantity;

  const PurchaseOrderItemEntity({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.receivedQuantity,
  });

  factory PurchaseOrderItemEntity.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItemEntity(
      id: json['id'],
      productId: json['product_id'],
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      receivedQuantity: (json['received_quantity'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, productId, quantity, totalPrice];
}
