import 'package:equatable/equatable.dart';

class PayrollEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double baseSalaryEarned;
  final double harvestBonus;
  final double otherBonus;
  final double deductions;
  final double totalAmount;
  final String status;
  final DateTime? paymentDate;
  final DateTime createdAt;

  const PayrollEntity({
    required this.id,
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.baseSalaryEarned,
    required this.harvestBonus,
    required this.otherBonus,
    required this.deductions,
    required this.totalAmount,
    required this.status,
    this.paymentDate,
    required this.createdAt,
  });

  factory PayrollEntity.fromJson(Map<String, dynamic> json) {
    return PayrollEntity(
      id: json['id'],
      userId: json['user_id'],
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: DateTime.parse(json['period_end']),
      baseSalaryEarned: (json['base_salary_earned'] as num).toDouble(),
      harvestBonus: (json['harvest_bonus'] as num).toDouble(),
      otherBonus: (json['other_bonus'] as num).toDouble(),
      deductions: (json['deductions'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    periodStart,
    periodEnd,
    baseSalaryEarned,
    harvestBonus,
    otherBonus,
    deductions,
    totalAmount,
    status,
    paymentDate,
    createdAt,
  ];
}

class ExpenseEntity extends Equatable {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;
  final String? estateId;
  final String? createdById;

  const ExpenseEntity({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    this.estateId,
    this.createdById,
  });

  factory ExpenseEntity.fromJson(Map<String, dynamic> json) {
    return ExpenseEntity(
      id: json['id'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'],
      estateId: json['estate_id'],
      createdById: json['created_by_id'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    category,
    amount,
    date,
    description,
    estateId,
    createdById,
  ];
}
