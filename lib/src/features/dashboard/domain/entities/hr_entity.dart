import 'package:equatable/equatable.dart';

class HREntity extends Equatable {
  final String name;
  final String position;
  final String startDate;
  final String salary;

  const HREntity({
    required this.name,
    required this.position,
    required this.startDate,
    required this.salary,
  });

  factory HREntity.fromJson(Map<String, dynamic> json) {
    return HREntity(
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      startDate: json['start_date'] ?? '-',
      salary: json['salary'] ?? '-',
    );
  }

  @override
  List<Object?> get props => [name, position, startDate, salary];
}
