import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:nex_app/src/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/dashboard_sidebar.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/dashboard_top_bar.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/admin_attendance_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/admin_payroll_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/admin_piece_rate_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/admin_production_chart_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/admin_field_summary_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/admin_crop_statistics_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/admin_mobile_harvest_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/admin_planting_planning_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/admin_product_out_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/admin_supply_chain_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/admin_warehouse_widget.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/widgets/pipeline_status_widget.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(DashboardRepositoryImpl(DioClient()))
        ..add(LoadDashboard()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;
  final Color _primaryBlue = const Color(0xFF1B4B8C);
  final Color _lightBlue = const Color(0xFF4A90D9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          DashboardSidebar(
            selectedIndex: _selectedIndex,
            onIndexChanged: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(
            child: Column(
              children: [
                DashboardTopBar(selectedIndex: _selectedIndex),
                Expanded(
                  child: BlocBuilder<DashboardBloc, DashboardState>(
                    builder: (context, state) {
                      if (state is DashboardLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is DashboardLoaded) {
                        return _buildCurrentPage(state);
                      } else if (state is DashboardError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Gagal Memuat Data Dashboard',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<DashboardBloc>().add(
                                          LoadDashboard(),
                                        );
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage(DashboardLoaded state) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardPage(state);
      case 1:
        return _buildProductionPage(state);
      case 2:
        return _buildSupplyChainPage(state);
      case 3:
        return _buildHumanResourcesPage(state);
      case 4:
        return const AdminWarehouseWidget();
      case 5:
        return _buildFieldPage(state);
      case 6:
        return const PipelineStatusWidget();
      default:
        return _buildDashboardPage(state);
    }
  }

  // ==================== DASHBOARD PAGE ====================
  Widget _buildDashboardPage(DashboardLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, User001!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recap',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          _buildKPICards(state),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildProductTable(state)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildAreaChart(state)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildHumanResourcesTable(state)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildEmployeeDonutChart(state)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildWarehouseTable(state)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildWarehouseDonutChart(state)),
            ],
          ),
          const SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildKPICards(DashboardLoaded state) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Row(
      children: [
        Expanded(
          child: _buildKPICard(
            'Total Earnings',
            currencyFormatter.format(state.summary.totalEarnings),
            '1 month indicator',
            true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildKPICard(
            'Total Number Of Products Sold',
            '${state.summary.harvestTon.toStringAsFixed(1)} Tons',
            'month indicator',
            true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildKPICard(
            'Most Buyers',
            state.summary.mostBuyers,
            '1 month indicator',
            false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildKPICard(
            'Profits',
            '${state.summary.profit}%',
            '1 month indicator',
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    String subtitle,
    bool hasBorder,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: hasBorder ? Border.all(color: _primaryBlue, width: 1) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(fontSize: 8, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTable(DashboardLoaded state) {
    final products = state.latestHarvests
        .map(
          (h) => {
            'name': h.name,
            'status': h.status,
            'qty': h.qty,
            'date': h.date,
          },
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('PRODUCT NAME', style: _headerStyle),
              ),
              Expanded(child: Text('STATUS', style: _headerStyle)),
              Expanded(child: Text('QUANTITY', style: _headerStyle)),
              Expanded(child: Text('DATE', style: _headerStyle)),
              Row(children: _buildTimeFiltersWidgets()),
            ],
          ),
          const Divider(height: 16),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("No recent harvests"),
            ),
          ...products.map((p) => _buildProductRow(p)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Show more..',
                style: TextStyle(color: _primaryBlue, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(Map<String, String> p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(p['name']!, style: _cellStyle)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[50]!,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                p['status']!,
                style: TextStyle(fontSize: 9, color: _primaryBlue),
              ),
            ),
          ),
          Expanded(child: Text(p['qty']!, style: _cellStyle)),
          Expanded(child: Text(p['date']!, style: _cellStyle)),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  List<Widget> _buildTimeFiltersWidgets() {
    return ['1W', '1M', '3M', '1Y'].map((t) {
      final isSelected = t == '1M';
      return Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? _primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          t,
          style: TextStyle(
            fontSize: 9,
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildAreaChart(DashboardLoaded state) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _buildTimeFiltersWidgets(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 200,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.grey[200]!, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, m) {
                        if (v == 1000) {
                          return const Text(
                            '1 bil',
                            style: TextStyle(fontSize: 7, color: Colors.grey),
                          );
                        }
                        if (v == 800) {
                          return const Text(
                            '800 Mil',
                            style: TextStyle(fontSize: 7, color: Colors.grey),
                          );
                        }
                        if (v == 600) {
                          return const Text(
                            '600 Mil',
                            style: TextStyle(fontSize: 7, color: Colors.grey),
                          );
                        }
                        if (v == 400) {
                          return const Text(
                            '400 Mil',
                            style: TextStyle(fontSize: 7, color: Colors.grey),
                          );
                        }
                        if (v == 200) {
                          return const Text(
                            '200 Mil',
                            style: TextStyle(fontSize: 7, color: Colors.grey),
                          );
                        }
                        if (v == 0) {
                          return const Text(
                            '<100\nMil',
                            style: TextStyle(fontSize: 7, color: Colors.grey),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        const d = ['18', '20', '22', '24', '26', '28', '30'];
                        if (v.toInt() < d.length) {
                          return Text(
                            d[v.toInt()],
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.grey,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 1000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 100),
                      FlSpot(1, 150),
                      FlSpot(2, 400),
                      FlSpot(3, 480),
                      FlSpot(4, 350),
                      FlSpot(5, 420),
                      FlSpot(6, 380),
                    ],
                    isCurved: true,
                    color: _primaryBlue,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _primaryBlue.withValues(alpha: 0.4),
                          _primaryBlue.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHumanResourcesTable(DashboardLoaded state) {
    final employees = state.hrData;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Human Resources (${employees.length})',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(flex: 2, child: Text('FULL NAME', style: _headerStyle)),
              Expanded(child: Text('POSITION', style: _headerStyle)),
              Expanded(child: Text('START DATE', style: _headerStyle)),
              Expanded(child: Text('SALARY', style: _headerStyle)),
            ],
          ),
          const Divider(height: 16),
          if (employees.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No employee data',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...employees.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: _lightBlue.withValues(alpha: 0.2),
                            child: Text(
                              e.name.isNotEmpty ? e.name[0] : '?',
                              style: TextStyle(
                                fontSize: 9,
                                color: _primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              e.name,
                              style: _cellStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.position,
                        style: _cellStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(child: Text(e.startDate, style: _cellStyle)),
                    Expanded(child: Text(e.salary, style: _cellStyle)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Showing ${employees.length} employees',
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeDonutChart(DashboardLoaded state) {
    final employees = state.hrData;
    final total = employees.length;

    // Group by position/role for chart
    final roleCounts = <String, int>{};
    for (var e in employees) {
      final role = e.position.isNotEmpty ? e.position : 'Other';
      roleCounts[role] = (roleCounts[role] ?? 0) + 1;
    }

    final chartColors = [
      _primaryBlue,
      _lightBlue,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.grey[400]!,
    ];
    final roleEntries = roleCounts.entries.toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 45,
                    sections: total == 0
                        ? [
                            PieChartSectionData(
                              color: Colors.grey[300]!,
                              value: 1,
                              title: '',
                              radius: 20,
                            ),
                          ]
                        : roleEntries.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final role = entry.value;
                            return PieChartSectionData(
                              color: chartColors[idx % chartColors.length],
                              value: role.value.toDouble(),
                              title: '',
                              radius: 20,
                            );
                          }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Number',
                      style: TextStyle(fontSize: 7, color: Colors.grey[600]),
                    ),
                    Text(
                      'Of Employees',
                      style: TextStyle(fontSize: 7, color: Colors.grey[600]),
                    ),
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildChartLegend(
            roleEntries.asMap().entries.map((entry) {
              final idx = entry.key;
              final role = entry.value;
              final pct = total > 0
                  ? (role.value / total * 100).toStringAsFixed(1)
                  : '0';
              return {
                'color': chartColors[idx % chartColors.length],
                'label': role.key,
                'count': '${role.value}',
                'pct': '$pct%',
              };
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseTable(DashboardLoaded state) {
    final items = state.inventoryData;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Warehouse (${items.length} items)',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No inventory data',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                headingRowHeight: 28,
                dataRowMinHeight: 30,
                dataRowMaxHeight: 34,
                headingTextStyle: _headerStyle,
                dataTextStyle: _cellStyle,
                columns: const [
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('PRODUCT ID')),
                  DataColumn(label: Text('NAME')),
                  DataColumn(label: Text('ENTRY DATE')),
                  DataColumn(label: Text('CONDITION')),
                  DataColumn(label: Text('QUANTITY')),
                  DataColumn(label: Text('EXPIRED DATE')),
                ],
                rows: items
                    .asMap()
                    .entries
                    .map(
                      (entry) => DataRow(
                        cells: [
                          DataCell(Text('${entry.key + 1}')),
                          DataCell(Text(entry.value.id)),
                          DataCell(Text(entry.value.name)),
                          DataCell(Text(entry.value.entryDate)),
                          DataCell(_buildConditionBadge(entry.value.condition)),
                          DataCell(Text(entry.value.quantity)),
                          DataCell(Text(entry.value.expiryDate)),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Showing ${items.length} items',
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionBadge(String cond) {
    Color bgColor, textColor;
    if (cond == 'Good') {
      bgColor = Colors.green[50]!;
      textColor = Colors.green;
    } else if (cond == 'Bad') {
      bgColor = Colors.red[50]!;
      textColor = Colors.red;
    } else {
      bgColor = Colors.orange[50]!;
      textColor = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(cond, style: TextStyle(fontSize: 8, color: textColor)),
    );
  }

  Widget _buildWarehouseDonutChart(DashboardLoaded state) {
    final items = state.inventoryData;
    final total = items.length;

    // Count conditions
    int good = 0, bad = 0, halfGood = 0;
    for (var item in items) {
      if (item.condition == 'Good') {
        good++;
      } else if (item.condition == 'Bad') {
        bad++;
      } else {
        halfGood++;
      }
    }

    final goodPct = total > 0 ? (good / total * 100).toStringAsFixed(0) : '0';
    final badPct = total > 0 ? (bad / total * 100).toStringAsFixed(0) : '0';
    final halfPct =
        total > 0 ? (halfGood / total * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: total == 0
                    ? [
                        PieChartSectionData(
                          color: Colors.grey[300]!,
                          value: 1,
                          title: '',
                          radius: 25,
                        ),
                      ]
                    : [
                        if (good > 0)
                          PieChartSectionData(
                            color: _primaryBlue,
                            value: good.toDouble(),
                            title: '',
                            radius: 25,
                          ),
                        if (bad > 0)
                          PieChartSectionData(
                            color: Colors.red[400]!,
                            value: bad.toDouble(),
                            title: '',
                            radius: 25,
                          ),
                        if (halfGood > 0)
                          PieChartSectionData(
                            color: Colors.orange[400]!,
                            value: halfGood.toDouble(),
                            title: '',
                            radius: 25,
                          ),
                      ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildCategoryLegend([
            {'color': _primaryBlue, 'label': 'Good', 'pct': '$goodPct%'},
            {'color': Colors.red[400]!, 'label': 'Bad', 'pct': '$badPct%'},
            {
              'color': Colors.orange[400]!,
              'label': 'Half Good',
              'pct': '$halfPct%',
            },
          ]),
        ],
      ),
    );
  }

  Widget _buildChartLegend(List<Map<String, dynamic>> items) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Department',
                style: TextStyle(fontSize: 8, color: Colors.grey[600]),
              ),
            ),
            Expanded(
              child: Text(
                'Number Of\nEmployees',
                style: TextStyle(fontSize: 8, color: Colors.grey[600]),
              ),
            ),
            const Text('%', style: TextStyle(fontSize: 8)),
          ],
        ),
        const Divider(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item['label'] as String,
                    style: const TextStyle(fontSize: 9),
                  ),
                ),
                Expanded(
                  child: Text(
                    item['count'] as String,
                    style: const TextStyle(fontSize: 9),
                  ),
                ),
                Text(
                  item['pct'] as String,
                  style: const TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryLegend(List<Map<String, dynamic>> items) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Category',
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
            ),
            const Text('%', style: TextStyle(fontSize: 9)),
          ],
        ),
        const Divider(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item['label'] as String,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                Text(
                  item['pct'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(Icons.spa, color: _primaryBlue, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Irostech',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '7 years of pioneering excellence in\ntechnology, delivering top-quality solutions at\ntheir finest!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 9,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Products',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...[
                      'UAV / Drone',
                      'AGV / Mobile robot',
                      'Smart Sensor',
                      'Software',
                    ].map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          p,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...[
                      'Food Industry Automation',
                      'Agri Industry Automation',
                      'Livestock Industry Automation',
                      'Smart City Industry',
                      'Transportation Industry Automation',
                    ].map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          f,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Company',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...['• Project', '• Contact Us'].map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          c,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Powered by Irostech IT-Solution',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PRODUCTION PAGE ====================
  Widget _buildProductionPage(DashboardLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Production Report',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Filter', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  Row(children: _buildTimeFiltersWidgets()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AdminProductionChartWidget(),
          const SizedBox(height: 16),
          const AdminProductOutWidget(),
        ],
      ),
    );
  }

  Widget _buildProductionChart() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: Colors.grey[200]!, strokeWidth: 1),
            getDrawingVerticalLine: (v) =>
                FlLine(color: Colors.grey[200]!, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (v, m) => Text(
                  '${v.toInt()}',
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (v, m) {
                  const months = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ];
                  if (v.toInt() < months.length) {
                    return Text(
                      months[v.toInt()],
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 10,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 2),
                FlSpot(1, 3),
                FlSpot(2, 2.5),
                FlSpot(3, 4),
                FlSpot(4, 3.5),
                FlSpot(5, 5),
                FlSpot(6, 4.5),
                FlSpot(7, 6),
                FlSpot(8, 5.5),
                FlSpot(9, 7),
                FlSpot(10, 6.5),
                FlSpot(11, 8),
              ],
              isCurved: true,
              color: _primaryBlue,
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    _primaryBlue.withValues(alpha: 0.3),
                    _primaryBlue.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductOutReport() {
    final products = [
      {
        'name': 'Fields A1 - 45',
        'status': 'Harvested',
        'code': 'CropW512-601',
        'qty': '1 Tons',
        'exp': '18.11Mils',
        'date': '28.09.2024',
      },
      {
        'name': 'Fields A4 - B10',
        'status': 'Harvested',
        'code': 'CropBDC-0013',
        'qty': '4 Klos',
        'exp': '45 Mils/m',
        'date': '20.04.2024',
      },
      {
        'name': 'Fields A10 - B3',
        'status': 'Harvested',
        'code': 'CropDBK-V22',
        'qty': '10 Tons',
        'exp': '63 Mils/m',
        'date': '16.05.2024',
      },
      {
        'name': 'Fields C1-C1',
        'status': 'Harvested',
        'code': 'CropBDI-013',
        'qty': '2 Tons',
        'exp': '10 Mils/m',
        'date': '18.09.2024',
      },
      {
        'name': 'Fields C4 - S',
        'status': 'Harvested',
        'code': 'CropV93-G22',
        'qty': '12 Tons',
        'exp': '63 Mils/re',
        'date': '19.04.2024',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Product Out Report',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sort, size: 14),
                    label: const Text('Sort', style: TextStyle(fontSize: 11)),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_alt, size: 14),
                    label: const Text('Filter', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('PRODUCT NAME', style: _headerStyle),
              ),
              Expanded(child: Text('STATUS', style: _headerStyle)),
              Expanded(child: Text('PRODUCT CODE', style: _headerStyle)),
              Expanded(child: Text('QUANTITY', style: _headerStyle)),
              Expanded(child: Text('EXPIRED DATE', style: _headerStyle)),
            ],
          ),
          const Divider(height: 16),
          ...products.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(p['name']!, style: _cellStyle)),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50]!,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        p['status']!,
                        style: TextStyle(fontSize: 9, color: _primaryBlue),
                      ),
                    ),
                  ),
                  Expanded(child: Text(p['code']!, style: _cellStyle)),
                  Expanded(child: Text(p['qty']!, style: _cellStyle)),
                  Expanded(child: Text(p['exp']!, style: _cellStyle)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.chevron_left, size: 14, color: Colors.grey),
              ...List.generate(
                3,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: i == 0 ? _primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 9,
                      color: i == 0 ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== SUPPLY CHAIN PAGE ====================
  Widget _buildSupplyChainPage(DashboardLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          const Text(
            'Supply Chain (Logistik)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Pengadaan (Procurement) dan Manajemen Penyimpanan (Warehouse)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Inventory Control + Procurement Tracking
          const AdminSupplyChainWidget(),
        ],
      ),
    );
  }

  Widget _buildInventoryControlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory_2, size: 20, color: _primaryBlue),
            const SizedBox(width: 8),
            const Text(
              'Inventory Control',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Pelacakan stok pupuk, solar, dan sparepart secara real-time (FIFO/LIFO)',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // Inventory Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildInventorySummaryCard(
                'Pupuk',
                '2,450 Ton',
                '+120 Ton',
                Icons.grass,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInventorySummaryCard(
                'Solar',
                '18,500 L',
                '-450 L',
                Icons.local_gas_station,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInventorySummaryCard(
                'Sparepart',
                '348 Items',
                '+25 Items',
                Icons.build_circle,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Inventory Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Item',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Stok Tersedia',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Metode',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Lokasi Gudang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Table Data
              _buildInventoryRow(
                'Pupuk NPK 15-15-15',
                'Pupuk',
                '850 Ton',
                'FIFO',
                'Gudang A',
                'Normal',
              ),
              _buildInventoryRow(
                'Pupuk Urea',
                'Pupuk',
                '1,200 Ton',
                'FIFO',
                'Gudang A',
                'Normal',
              ),
              _buildInventoryRow(
                'Solar Industri',
                'Solar',
                '18,500 L',
                'FIFO',
                'Tangki B1',
                'Normal',
              ),
              _buildInventoryRow(
                'Solar B35',
                'Solar',
                '5,200 L',
                'FIFO',
                'Tangki B2',
                'Low Stock',
              ),
              _buildInventoryRow(
                'Belt Conveyor',
                'Sparepart',
                '15 Unit',
                'LIFO',
                'Gudang C',
                'Normal',
              ),
              _buildInventoryRow(
                'Filter Oli Mesin',
                'Sparepart',
                '120 Unit',
                'LIFO',
                'Gudang C',
                'Normal',
              ),
              _buildInventoryRow(
                'Bearing 6205',
                'Sparepart',
                '8 Unit',
                'LIFO',
                'Gudang C',
                'Low Stock',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInventorySummaryCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
  ) {
    final isPositive = change.startsWith('+');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                child: Icon(icon, size: 20, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(
    String item,
    String category,
    String stock,
    String method,
    String location,
    String status,
  ) {
    final isLowStock = status == 'Low Stock';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(item, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Text(
              category,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              stock,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: method == 'FIFO'
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                method,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: method == 'FIFO' ? Colors.blue : Colors.purple,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              location,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLowStock
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isLowStock ? Colors.orange : Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcurementTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shopping_cart, size: 20, color: _primaryBlue),
            const SizedBox(width: 8),
            const Text(
              'Procurement Tracking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Pemantauan status barang dari pemesanan hingga barang tiba di gudang (GRN)',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // Procurement Status Cards
        Row(
          children: [
            Expanded(
              child: _buildProcurementStatusCard(
                'Pending Order',
                '12',
                Colors.orange,
                Icons.pending_actions,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProcurementStatusCard(
                'In Transit',
                '8',
                Colors.blue,
                Icons.local_shipping,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProcurementStatusCard(
                'Delivered (GRN)',
                '45',
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProcurementStatusCard(
                'Cancelled',
                '3',
                Colors.red,
                Icons.cancel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Procurement Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PO Number',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Item',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Vendor',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Order Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'ETA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Table Data
              _buildProcurementRow(
                'PO-2024-0012',
                'Pupuk NPK 500 Ton',
                'PT Pupuk Indonesia',
                '5 Feb 2024',
                '12 Feb 2024',
                'In Transit',
              ),
              _buildProcurementRow(
                'PO-2024-0011',
                'Solar B35 10,000 L',
                'PT Pertamina',
                '3 Feb 2024',
                '8 Feb 2024',
                'In Transit',
              ),
              _buildProcurementRow(
                'PO-2024-0010',
                'Filter Oli 200 Unit',
                'CV Sinar Jaya',
                '1 Feb 2024',
                '10 Feb 2024',
                'Pending Order',
              ),
              _buildProcurementRow(
                'PO-2024-0009',
                'Bearing Set 50 Unit',
                'Toko Sparepart Makmur',
                '28 Jan 2024',
                '6 Feb 2024',
                'Delivered (GRN)',
              ),
              _buildProcurementRow(
                'PO-2024-0008',
                'Pupuk Urea 800 Ton',
                'PT Pupuk Indonesia',
                '25 Jan 2024',
                '3 Feb 2024',
                'Delivered (GRN)',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcurementStatusCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProcurementRow(
    String poNumber,
    String item,
    String vendor,
    String orderDate,
    String eta,
    String status,
  ) {
    Color statusColor;
    switch (status) {
      case 'Pending Order':
        statusColor = Colors.orange;
        break;
      case 'In Transit':
        statusColor = Colors.blue;
        break;
      case 'Delivered (GRN)':
        statusColor = Colors.green;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              poNumber,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(item, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Text(
              vendor,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              orderDate,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              eta,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HUMAN RESOURCES PAGE ====================
  Widget _buildHumanResourcesPage(DashboardLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          const Text(
            'Human Resources',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Data karyawan, absensi, tunjangan, potongan, penggajian (payroll), dan audit',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Summary Cards
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildHRSummaryCard(
                  'Total Karyawan',
                  '${state.summary.totalEmployees}',
                  Icons.people,
                  Colors.blue,
                  'Total Registered',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHRSummaryCard(
                  'Hadir Hari Ini',
                  '${state.summary.presentEmployees}',
                  Icons.check_circle,
                  Colors.green,
                  state.summary.totalEmployees > 0
                      ? '${(state.summary.presentEmployees / state.summary.totalEmployees * 100).toStringAsFixed(1)}%'
                      : '0%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHRSummaryCard(
                  'Tidak Hadir',
                  '${state.summary.absentEmployees}',
                  Icons.cancel,
                  Colors.red,
                  state.summary.totalEmployees > 0
                      ? '${(state.summary.absentEmployees / state.summary.totalEmployees * 100).toStringAsFixed(1)}%'
                      : '0%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHRSummaryCard(
                  'Terlambat',
                  '${state.summary.lateEmployees}',
                  Icons.schedule,
                  Colors.orange,
                  'Need Attention',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Attendance Integration Section
          _buildAttendanceSection(),
          const SizedBox(height: 24),

          // Piece-Rate Calculation Section
          _buildPieceRateSection(),
          const SizedBox(height: 24),

          // Payroll Management Section
          _buildPayrollSection(),
        ],
      ),
    );
  }

  Widget _buildHRSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return const AdminAttendanceWidget();
  }

  Widget _buildPieceRateSection() {
    return const AdminPieceRateWidget();
  }

  Widget _buildPayrollSection() {
    return const AdminPayrollWidget();
  }

  // ==================== WAREHOUSE PAGE ====================
  Widget _buildWarehousePage(DashboardLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              icon: Icon(Icons.filter_list, size: 14, color: Colors.grey[700]),
              label: Text(
                'Filter',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildWarehouseProductCard(
            'South Sumatera',
            'Mr. X',
            '186 day(s) left',
            '1 Kilo Tons',
            'assets/images/sawit_1.jpg',
            [60, 25, 15],
          ),
          const SizedBox(height: 12),
          _buildWarehouseProductCard(
            'Bangka Belitung',
            'Mr. Rajih',
            '120 day(s) left',
            '900 Tons',
            'assets/images/sawit_2.png',
            [60, 30, 10],
          ),
          const SizedBox(height: 12),
          _buildWarehouseProductCard(
            'Medan',
            'Ms. Kall',
            '15 day(s) left',
            '1 Kilo Tons',
            'assets/images/sawit_3.jpeg',
            [60, 25, 15],
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseProductCard(
    String location,
    String owner,
    String timeLeft,
    String amount,
    String imagePath,
    List<double> chartValues,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 260,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200]!,
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 28),
          // Product Details - Evenly distributed
          Expanded(
            child: SizedBox(
              height: 160,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailRow(
                          'Location:',
                          location,
                          isBlue: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailRow(
                          'Harvest time:',
                          timeLeft,
                          isRed: true,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildDetailRow('Owner:', owner)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailRow(
                          'Prediction Harvest Amount:',
                          amount,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 28),
          // Chart Card
          Container(
            width: 260,
            height: 160,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 110,
                  width: 110,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 1,
                      centerSpaceRadius: 36,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          color: Colors.deepOrange,
                          value: chartValues[0],
                          showTitle: false,
                          radius: 14,
                        ),
                        PieChartSectionData(
                          color: const Color(0xFF00A3FF),
                          value: chartValues[1],
                          showTitle: false,
                          radius: 14,
                        ),
                        PieChartSectionData(
                          color: Colors.orange[200]!,
                          value: chartValues[2],
                          showTitle: false,
                          radius: 14,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildWarehouseChartLegend(chartValues)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBlue = false,
    bool isRed = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isBlue
                ? _primaryBlue
                : (isRed ? Colors.red : const Color(0xFF1A1C1E)),
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseChartLegend(List<double> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Palm Health',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
            Text(
              '%',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(height: 10, thickness: 0.5),
        _buildLegendRow(Colors.deepOrange, 'Good', '${values[0].toInt()}%'),
        const SizedBox(height: 2),
        _buildLegendRow(
          const Color(0xFF00A3FF),
          'Need a Treatment',
          '${values[1].toInt()}%',
        ),
        const SizedBox(height: 2),
        _buildLegendRow(Colors.orange[200]!, 'Bad', '${values[2].toInt()}%'),
      ],
    );
  }

  Widget _buildLegendRow(Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  TextStyle get _headerStyle => TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
      );
  TextStyle get _cellStyle => const TextStyle(fontSize: 10);
  // ==================== FIELD PAGE ====================
  Widget _buildFieldPage(DashboardLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          const Text(
            'Field (Lapangan)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Data area, hasil panen, statistik, info tanaman, dan rencana tanam',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Summary Cards
          const AdminFieldSummaryWidget(),
          const SizedBox(height: 24),

          // Mobile Harvest Entry Section
          const AdminMobileHarvestWidget(),
          const SizedBox(height: 24),

          // Crop Statistics Section
          const AdminCropStatisticsWidget(),
          const SizedBox(height: 24),

          // Planting Planning Section
          const AdminPlantingPlanningWidget(),
        ],
      ),
    );
  }

  Widget _buildFieldSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHarvestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.phone_android, size: 20, color: _primaryBlue),
            const SizedBox(width: 8),
            const Text(
              'Mobile Harvest Entry',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Input hasil panen (Janjang/Kg) langsung di blok via HP Android - Real-time data entry',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Blok',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Lokasi GPS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Pemanen',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Janjang (Unit)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Berat (Kg)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Waktu Entry',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Table Data
              _buildHarvestEntryRow(
                'A-12',
                '-6.2134, 106.8456',
                'Joko W.',
                '145',
                '1,850',
                '07:24',
                'Synced',
              ),
              _buildHarvestEntryRow(
                'B-08',
                '-6.2145, 106.8462',
                'Supri Y.',
                '168',
                '2,120',
                '07:18',
                'Synced',
              ),
              _buildHarvestEntryRow(
                'C-15',
                '-6.2156, 106.8471',
                'Warno S.',
                '132',
                '1,680',
                '08:02',
                'Pending',
              ),
              _buildHarvestEntryRow(
                'A-09',
                '-6.2128, 106.8449',
                'Paijo H.',
                '189',
                '2,380',
                '06:45',
                'Synced',
              ),
              _buildHarvestEntryRow(
                'D-21',
                '-6.2167, 106.8485',
                'Slamet R.',
                '156',
                '1,980',
                '07:56',
                'Synced',
              ),
              _buildHarvestEntryRow(
                'B-14',
                '-6.2139, 106.8458',
                'Kasim M.',
                '174',
                '2,210',
                '08:15',
                'Pending',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHarvestEntryRow(
    String block,
    String gps,
    String harvester,
    String bunches,
    String weight,
    String time,
    String status,
  ) {
    final isSynced = status == 'Synced';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                block,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    gps,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(harvester, style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            child: Text(
              bunches,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          Expanded(
            child: Text(
              weight,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Expanded(
            child: Text(
              time,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSynced
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSynced ? Icons.cloud_done : Icons.cloud_upload,
                    size: 12,
                    color: isSynced ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSynced ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropStatisticsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Blok',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Luas (Ha)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Total Pokok',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Produktif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Non-Produktif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '% Produktif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Table Data
              _buildCropStatRow(
                'A-12',
                '85',
                '10,200',
                '9,180',
                '1,020',
                '90.0',
              ),
              _buildCropStatRow(
                'B-08',
                '92',
                '11,040',
                '9,936',
                '1,104',
                '90.0',
              ),
              _buildCropStatRow(
                'C-15',
                '78',
                '9,360',
                '7,956',
                '1,404',
                '85.0',
              ),
              _buildCropStatRow(
                'A-09',
                '88',
                '10,560',
                '8,976',
                '1,584',
                '85.0',
              ),
              _buildCropStatRow(
                'D-21',
                '95',
                '11,400',
                '9,690',
                '1,710',
                '85.0',
              ),
              _buildCropStatRow(
                'B-14',
                '82',
                '9,840',
                '8,364',
                '1,476',
                '85.0',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCropStatRow(
    String block,
    String area,
    String total,
    String productive,
    String nonProductive,
    String percentage,
  ) {
    final percentValue = double.parse(percentage);
    final isGood = percentValue >= 88.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                block,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              area,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              total,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              productive,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Expanded(
            child: Text(
              nonProductive,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isGood
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isGood ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropStatisticsPieChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Produktivitas Keseluruhan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: 87.2,
                    title: '87.2%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.red[300]!,
                    value: 12.8,
                    title: '12.8%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Produktif: 89,450 pokok',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.red[300]!,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Non-Produktif: 13,150 pokok',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlantingPlanningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_note, size: 20, color: _primaryBlue),
            const SizedBox(width: 8),
            const Text(
              'Planting Planning',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Jadwal replanting dan pembukaan lahan baru',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Proyek',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Lokasi Blok',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Luas (Ha)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Jenis',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Target Mulai',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Est. Selesai',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Table Data
              _buildPlantingPlanRow(
                'Replanting Phase 3',
                'Blok D-18, D-19, D-20',
                '65',
                'Replanting',
                'Apr 2024',
                'Aug 2024',
                'Planning',
              ),
              _buildPlantingPlanRow(
                'New Land Opening',
                'Area Timur (New)',
                '120',
                'New Opening',
                'Jun 2024',
                'Dec 2024',
                'Survey',
              ),
              _buildPlantingPlanRow(
                'Replanting Phase 2',
                'Blok C-12, C-13',
                '48',
                'Replanting',
                'Feb 2024',
                'Jun 2024',
                'In Progress',
              ),
              _buildPlantingPlanRow(
                'Replanting Phase 1',
                'Blok A-05, A-06',
                '52',
                'Replanting',
                'Jan 2024',
                'Apr 2024',
                'In Progress',
              ),
              _buildPlantingPlanRow(
                'Extension Area',
                'Area Selatan (New)',
                '85',
                'New Opening',
                'Aug 2024',
                'Feb 2025',
                'Planning',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlantingPlanRow(
    String project,
    String location,
    String area,
    String type,
    String startDate,
    String endDate,
    String status,
  ) {
    Color statusColor;
    switch (status) {
      case 'Planning':
        statusColor = Colors.blue;
        break;
      case 'Survey':
        statusColor = Colors.purple;
        break;
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      case 'Completed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    final isReplanting = type == 'Replanting';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              project,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              location,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              area,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isReplanting
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isReplanting ? Colors.orange : Colors.green,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              startDate,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              endDate,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
