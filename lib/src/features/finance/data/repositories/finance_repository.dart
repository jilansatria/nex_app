import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';
import '../../domain/entities/finance_entities.dart';

class FinanceRepository {
  final DioClient _dioClient;

  FinanceRepository(this._dioClient);

  Future<List<ExpenseEntity>> getExpenses() async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.finance}expenses',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => ExpenseEntity.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createExpense(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.finance}expenses',
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<PayrollEntity>> getPayrolls() async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.finance}payroll',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => PayrollEntity.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<PayrollEntity?> generatePayroll({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.finance}payroll/generate',
        queryParameters: {
          'user_id': userId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PayrollEntity.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePayrollStatus(String payrollId, String status) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.finance}payroll/$payrollId',
        queryParameters: {'status': status},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
