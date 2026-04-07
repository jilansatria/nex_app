import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

/// Repository for Budget module API calls.
/// Covers: Budget CRUD, Line Items, Actuals, Budget vs Actual, Approval.
class BudgetRepository {
  final DioClient _dioClient = DioClient();

  // ── Budget CRUD ──

  Future<List<Map<String, dynamic>>> getBudgets({
    String? costCenterType,
    int? periodYear,
    String? status,
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await _dioClient.dio.get(
      ApiConstants.budgets,
      queryParameters: {
        'skip': skip,
        'limit': limit,
        if (costCenterType != null) 'cost_center_type': costCenterType,
        if (periodYear != null) 'period_year': periodYear,
        if (status != null) 'status': status,
      },
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getBudget(String budgetId) async {
    final response = await _dioClient.dio.get(
      '${ApiConstants.budgets}$budgetId',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> createBudget({
    required String name,
    required int periodYear,
    required int periodMonthStart,
    required int periodMonthEnd,
    required String costCenterType,
    String? costCenterId,
    String? costCenterName,
    List<Map<String, dynamic>>? lines,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.budgets,
      data: {
        'name': name,
        'period_year': periodYear,
        'period_month_start': periodMonthStart,
        'period_month_end': periodMonthEnd,
        'cost_center_type': costCenterType,
        if (costCenterId != null) 'cost_center_id': costCenterId,
        if (costCenterName != null) 'cost_center_name': costCenterName,
        'lines': lines ?? [],
      },
    );
    return response.data;
  }

  // ── Line Items ──

  Future<Map<String, dynamic>> addBudgetLine({
    required String budgetId,
    required String category,
    required int month,
    required double estimatedAmount,
    String? subCategory,
    String? description,
  }) async {
    final response = await _dioClient.dio.post(
      '${ApiConstants.budgets}$budgetId/lines',
      data: {
        'category': category,
        'month': month,
        'estimated_amount': estimatedAmount,
        if (subCategory != null) 'sub_category': subCategory,
        if (description != null) 'description': description,
      },
    );
    return response.data;
  }

  // ── Budget vs Actual ──

  Future<Map<String, dynamic>> updateActual({
    required String lineId,
    required double actualAmount,
    String? notes,
  }) async {
    final response = await _dioClient.dio.put(
      '${ApiConstants.budgets}lines/$lineId/actual',
      queryParameters: {
        'actual_amount': actualAmount,
        if (notes != null) 'notes': notes,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getBudgetVsActual(String budgetId) async {
    final response = await _dioClient.dio.get(
      '${ApiConstants.budgets}$budgetId/vs-actual',
    );
    return response.data;
  }

  // ── Approval ──

  Future<Map<String, dynamic>> approveBudget(String budgetId) async {
    final response = await _dioClient.dio.post(
      '${ApiConstants.budgets}$budgetId/approve',
    );
    return response.data;
  }
}
