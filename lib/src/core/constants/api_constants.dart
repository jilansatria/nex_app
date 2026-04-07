import 'package:flutter/foundation.dart';

class ApiConstants {
  // Base request URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000'; // Browser prefers localhost
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    // iOS, Windows, macOS, Linux
    return 'http://127.0.0.1:8000';
  }

  // Endpoints
  static const String login = '/api/v1/auth/login';
  static const String users = '/api/v1/users/';
  static const String estates = '/api/v1/estates/';
  static const String production = '/api/v1/production/';
  static const String dashboard = '/api/v1/dashboard/';
  static const String sales = '/api/v1/sales/';
  static const String attendance = '/api/v1/attendance/';
  static const String nursery = '/api/v1/nursery/';
  static const String logistics = '/api/v1/logistics/';
  static const String finance = '/api/v1/finance/';
  static const String procurement = '/api/v1/procurement/';
  static const String gis = '/api/v1/gis/';
  static const String mills = '/api/v1/mills/';
  static const String inventory = '/api/v1/inventory/';
  static const String budgets = '/api/v1/budgets/';

  // ── Data Chain Pipeline endpoints ──
  static const String pipelineStatus = '/api/v1/admin/pipeline-status';
  static const String financePipelineSummary =
      '/api/v1/finance/pipeline-summary';
  static const String financeRevenueByProduct =
      '/api/v1/finance/revenue-by-product';
  static const String millProductionApprove =
      '/api/v1/mills/production'; // /{log_id}/approve

  // ── Mill endpoints ──
  static const String millWeighbridge = '/api/v1/mills/weighbridge';
  static const String millProductionLog = '/api/v1/mills/production/log';

  // ── Sales detail endpoints ──
  static const String salesContracts = '/api/v1/sales/contracts';
  static const String salesShipments = '/api/v1/sales/shipments';
  static const String salesSummary = '/api/v1/sales/summary';

  // ── Finance detail endpoints ──
  static const String financeExpenses = '/api/v1/finance/expenses';
  static const String financePayroll = '/api/v1/finance/payroll';
  static const String financeSummary = '/api/v1/finance/financial-summary';
}
