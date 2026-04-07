import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

/// Repository for the ERP Data Chain Pipeline.
/// Provides methods to fetch pipeline status (admin) and finance summary.
class PipelineRepository {
  final DioClient _dio;

  PipelineRepository(this._dio);

  /// [ADMIN] Get full pipeline status across all 6 stages:
  /// Panen → Timbang → Produksi → Stok → Jual → Uang
  Future<Map<String, dynamic>> getPipelineStatus() async {
    try {
      final response = await _dio.dio.get(ApiConstants.pipelineStatus);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch pipeline status: $e');
    }
  }

  /// [FINANCE] Get pipeline financial summary with date range.
  /// Cross-references Sales revenue + Production cost + Expenses + Payroll.
  Future<Map<String, dynamic>> getFinancePipelineSummary({
    String? periodStart,
    String? periodEnd,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (periodStart != null) queryParams['period_start'] = periodStart;
      if (periodEnd != null) queryParams['period_end'] = periodEnd;

      final response = await _dio.dio.get(
        ApiConstants.financePipelineSummary,
        queryParameters: queryParams,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch finance pipeline summary: $e');
    }
  }

  /// [FINANCE] Get revenue breakdown by product type (CPO vs Kernel).
  Future<Map<String, dynamic>> getRevenueByProduct() async {
    try {
      final response = await _dio.dio.get(ApiConstants.financeRevenueByProduct);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch revenue by product: $e');
    }
  }

  /// [MILL_MANAGER] Approve a production log → triggers auto-stock update.
  /// This is the PRODUKSI → STOK link in the data chain.
  Future<Map<String, dynamic>> approveProductionLog(String logId) async {
    try {
      final response = await _dio.dio.put(
        '${ApiConstants.millProductionApprove}/$logId/approve',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to approve production log: $e');
    }
  }
}
