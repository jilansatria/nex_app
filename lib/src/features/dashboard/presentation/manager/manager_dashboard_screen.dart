import 'package:flutter/material.dart';
import '../widgets/offline_status_indicator.dart';
import '../../data/services/offline_sync_service.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/widgets/manager_sidebar.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/widgets/estate_harvest_chart.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/widgets/estate_cost_table.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/widgets/estate_performance_card.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/widgets/mill_production_chart.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/widgets/mill_machine_status.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/widgets/mill_daily_report.dart';

import 'package:nex_app/src/features/estate/presentation/nursery/nursery_overview_widget.dart';
import 'package:nex_app/src/features/gis/presentation/screens/gis_map_screen.dart';
import 'package:nex_app/src/features/finance/presentation/widgets/finance_overview_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/widgets/weighbridge_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/widgets/production_log_widget.dart';
import 'package:nex_app/src/features/sales/presentation/widgets/sales_overview_widget.dart';
import 'package:nex_app/src/features/sales/presentation/widgets/sales_contracts_widget.dart';
import 'package:nex_app/src/features/sales/presentation/widgets/sales_shipments_widget.dart';
import 'package:nex_app/src/features/finance/presentation/widgets/finance_budget_widget.dart';
import 'package:nex_app/src/features/finance/presentation/widgets/finance_expense_widget.dart';
import 'package:nex_app/src/features/finance/presentation/widgets/finance_payroll_widget.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

class ManagerDashboardScreen extends StatefulWidget {
  final String role; // 'Estate Manager', 'Mill Manager', 'Finance', 'Sales'

  const ManagerDashboardScreen({super.key, required this.role});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _selectedIndex = 0;
  final DioClient _dioClient = DioClient();

  // Manager summary data from API
  bool _isLoading = true;
  List<Map<String, dynamic>> _kpis = [];
  List<Map<String, dynamic>> _blocks = [];

  @override
  void initState() {
    super.initState();
    _loadManagerData();
  }

  String get _apiRole {
    switch (widget.role) {
      case 'estate_manager':
        return 'estate';
      case 'mill_manager':
        return 'mill';
      case 'finance_manager':
        return 'finance';
      case 'sales_officer':
        return 'sales';
      default:
        return 'estate';
    }
  }

  Future<void> _loadManagerData() async {
    try {
      setState(() => _isLoading = true);
      final response = await _dioClient.dio.get(
        '${ApiConstants.dashboard}manager-summary?role=$_apiRole',
      );
      final data = response.data;
      setState(() {
        _kpis = (data['kpis'] as List? ?? [])
            .map((k) => k as Map<String, dynamic>)
            .toList();
        _blocks = (data['blocks'] as List? ?? [])
            .map((b) => b as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          ManagerSidebar(
            selectedIndex: _selectedIndex,
            onIndexChanged: (index) => setState(() => _selectedIndex = index),
            role: widget.role,
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            _getRoleLabel(widget.role),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          OfflineStatusIndicator(syncService: OfflineSyncService()),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (widget.role == 'estate_manager') return _buildEstateDashboard();
    if (widget.role == 'mill_manager') return _buildMillDashboard();
    if (widget.role == 'finance_manager') return _buildFinanceDashboard();
    if (widget.role == 'sales_officer') return _buildSalesDashboard();
    return const Center(child: Text('Dashboard not found'));
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'estate_manager':
        return 'Estate Manager';
      case 'mill_manager':
        return 'Mill Manager';
      case 'finance_manager':
        return 'Finance';
      case 'sales_officer':
        return 'Sales';
      default:
        return 'Manager';
    }
  }

  // ==================== ESTATE MANAGER DASHBOARD ====================
  Widget _buildEstateDashboard() {
    if (_selectedIndex == 0) {
      // Overview Page
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Estate Performance Overview'),
            const SizedBox(height: 16),
            // KPI Cards Row — from API
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Row(
                children: _kpis.map((kpi) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: EstatePerformanceCard(
                        title: kpi['title'] ?? '',
                        value: kpi['value'] ?? '',
                        subtitle: kpi['subtitle'] ?? '',
                        icon: _mapIcon(kpi['icon'] ?? ''),
                        color: _mapColor(kpi['color'] ?? ''),
                        trend: kpi['trend'] ?? '',
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 32),
            // Harvest Performance Chart
            const EstateHarvestChart(),
            const SizedBox(height: 32),
            // Operational Cost Table
            const EstateCostTable(),
            const SizedBox(height: 24),
            // Block Performance Summary
            _buildSectionTitle('Block Performance Summary'),
            const SizedBox(height: 16),
            _buildBlockPerformanceGrid(),
          ],
        ),
      );
    } else if (_selectedIndex == 1) {
      // Harvest & Yield Detail Page
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Harvest & Yield Analysis'),
            const SizedBox(height: 16),
            const EstateHarvestChart(),
            const SizedBox(height: 24),
            _buildSectionTitle('Daily Harvest Report'),
            const SizedBox(height: 16),
            _buildDailyHarvestTable(),
          ],
        ),
      );
    } else if (_selectedIndex == 2) {
      // Block Map Page
      return const GISMapScreen();
    } else if (_selectedIndex == 3) {
      // Weighbridge Page for Estate Manager
      return const WeighbridgeWidget();
    } else if (_selectedIndex == 4) {
      // Nursery Page
      return const NurseryOverviewWidget();
    }
    return const Center(child: Text('Module under construction'));
  }

  Widget _buildBlockPerformanceGrid() {
    if (_blocks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No block data available.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _blocks.length,
      itemBuilder: (context, index) {
        final block = _blocks[index];
        final statusStr = block['status'] ?? 'Poor';
        final statusColor = _getStatusColor(statusStr);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      block['name'] ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusStr,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Harvest: ${block['harvest'] ?? '-'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                'YPH: ${block['yph'] ?? '-'} Ton/Ha',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyHarvestTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Table(
            border: TableBorder.all(color: Colors.grey[200]!),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[100]!),
                children: ['Date', 'Block', 'FFB (Ton)', 'Workers', 'Status']
                    .map(
                      (h) => Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          h,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    .toList(),
              ),
              ...List.generate(7, (i) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${10 - i} Feb', textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Block ${String.fromCharCode(65 + (i % 3))}-${(i % 2) + 1}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '${120 + (i * 15)}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${20 + i}', textAlign: TextAlign.center),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Completed',
                        style: TextStyle(color: Colors.green),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey[200]!),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[100]!),
            children: ['Item', 'Stock', 'Min. Stock', 'Status']
                .map(
                  (h) => Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      h,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                .toList(),
          ),
          _buildInventoryRow('NPK (15-15-15)', '250 Ton', '200 Ton', true),
          _buildInventoryRow('Urea', '180 Ton', '150 Ton', true),
          _buildInventoryRow('KCl', '45 Ton', '50 Ton', false),
          _buildInventoryRow('Boron', '12 Ton', '15 Ton', false),
        ],
      ),
    );
  }

  TableRow _buildInventoryRow(
    String item,
    String stock,
    String minStock,
    bool isOk,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(item, textAlign: TextAlign.left),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(stock, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(minStock, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            isOk ? 'OK' : 'Low',
            style: TextStyle(
              color: isOk ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ==================== MILL MANAGER DASHBOARD ====================
  Widget _buildMillDashboard() {
    if (_selectedIndex == 0) {
      // Overview Page
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Mill Production Overview'),
            const SizedBox(height: 16),
            // KPI Cards Row — from API
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Row(
                children: _kpis.map((kpi) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: EstatePerformanceCard(
                        title: kpi['title'] ?? '',
                        value: kpi['value'] ?? '',
                        subtitle: kpi['subtitle'] ?? '',
                        icon: _mapIcon(kpi['icon'] ?? ''),
                        color: _mapColor(kpi['color'] ?? ''),
                        trend: kpi['trend'] ?? '',
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 32),
            // Production Chart
            const MillProductionChart(),
            const SizedBox(height: 32),
            // Machine Status
            const MillMachineStatus(),
          ],
        ),
      );
    } else if (_selectedIndex == 1) {
      // Production Logs & Approval Page for Mill Manager
      return const ProductionLogWidget();
    } else if (_selectedIndex == 2) {
      // Machine Status Detail Page
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Machine Status \u0026 Maintenance'),
            const SizedBox(height: 16),
            const MillMachineStatus(),
            const SizedBox(height: 24),
            _buildSectionTitle('Maintenance Schedule'),
            const SizedBox(height: 16),
            _buildMaintenanceSchedule(),
          ],
        ),
      );
    } else if (_selectedIndex == 3) {
      // Daily Report OER/KER Page
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Daily Production Report'),
            const SizedBox(height: 16),
            const MillDailyReport(),
          ],
        ),
      );
    }
    return const Center(child: Text('Module under construction'));
  }

  Widget _buildMaintenanceSchedule() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMaintenanceItem(
            'Sterilizer',
            'Next: 15 Feb 2026',
            'Routine Inspection',
            Colors.green,
          ),
          const Divider(),
          _buildMaintenanceItem(
            'Digester',
            'Next: 12 Feb 2026',
            'Oil Change',
            Colors.blue,
          ),
          const Divider(),
          _buildMaintenanceItem(
            'Screw Press',
            'Next: 18 Feb 2026',
            'Belt Replacement',
            Colors.orange,
          ),
          const Divider(),
          _buildMaintenanceItem(
            'Clarifier Tank',
            'In Progress',
            'Cleaning \u0026 Inspection',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceItem(
    String machine,
    String schedule,
    String task,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              schedule,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FINANCE DASHBOARD ====================
  Widget _buildFinanceDashboard() {
    if (_selectedIndex == 0) {
      return const FinanceOverviewWidget();
    } else if (_selectedIndex == 1) {
      return const FinanceBudgetWidget();
    } else if (_selectedIndex == 2) {
      return const FinanceExpenseWidget();
    } else if (_selectedIndex == 3) {
      return const FinancePayrollWidget();
    }
    return const Center(child: Text('Module under construction'));
  }

  // ==================== SALES DASHBOARD ====================
  Widget _buildSalesDashboard() {
    if (_selectedIndex == 0) {
      return const SalesOverviewWidget();
    } else if (_selectedIndex == 1) {
      return const SalesContractsWidget();
    } else if (_selectedIndex == 2) {
      return const SalesShipmentsWidget();
    }
    return const Center(child: Text('Module under construction'));
  }

  // Helper Widgets
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Icon(Icons.more_vert, color: Colors.grey, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER: Map API icon/color strings ====================
  IconData _mapIcon(String name) {
    const iconMap = {
      'grass': Icons.grass,
      'inventory_2': Icons.inventory_2,
      'map': Icons.map,
      'people': Icons.people,
      'water_drop': Icons.water_drop,
      'factory': Icons.factory,
      'opacity': Icons.opacity,
      'check_circle': Icons.check_circle,
      'attach_money': Icons.attach_money,
      'shopping_cart': Icons.shopping_cart,
      'inventory': Icons.inventory,
      'receipt': Icons.receipt,
      'trending_up': Icons.trending_up,
      'assignment_turned_in': Icons.assignment_turned_in,
      'local_shipping': Icons.local_shipping,
      'pie_chart': Icons.pie_chart,
      'pending_actions': Icons.pending_actions,
      'swap_horiz': Icons.swap_horiz,
      'edit_note': Icons.edit_note,
      'history': Icons.history,
    };
    return iconMap[name] ?? Icons.info;
  }

  Color _mapColor(String name) {
    const colorMap = {
      'green': Colors.green,
      'blue': Colors.blue,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'red': Colors.red,
      'teal': Colors.teal,
    };
    return colorMap[name] ?? Colors.grey;
  }
}
