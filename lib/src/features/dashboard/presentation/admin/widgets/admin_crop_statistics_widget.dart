import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

/// Self-contained crop statistics widget.
/// Fetches per-block tree productivity data from /dashboard/crop-statistics
/// and displays a table + pie chart.
class AdminCropStatisticsWidget extends StatefulWidget {
  const AdminCropStatisticsWidget({super.key});

  @override
  State<AdminCropStatisticsWidget> createState() =>
      _AdminCropStatisticsWidgetState();
}

class _AdminCropStatisticsWidgetState extends State<AdminCropStatisticsWidget> {
  static const _primaryBlue = Color(0xFF1B4B8C);

  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  List<Map<String, dynamic>> _rows = [];
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final response = await _dioClient.dio.get(
        '${ApiConstants.dashboard}crop-statistics',
      );
      final data = response.data;
      if (mounted) {
        setState(() {
          _rows = (data['rows'] as List? ?? [])
              .map((r) => r as Map<String, dynamic>)
              .toList();
          _summary = data['summary'] as Map<String, dynamic>? ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(Icons.analytics, size: 20, color: _primaryBlue),
            const SizedBox(width: 8),
            const Text(
              'Crop Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Sensus pokok produktif vs non-produktif',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        _isLoading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildTable()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildPieChart()),
                ],
              ),
      ],
    );
  }

  Widget _buildTable() {
    return Container(
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
          // Header
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Luas (Ha)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total Pokok',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Produktif',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Non-Produktif',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '% Produktif',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          if (_rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Belum ada data blok.',
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          else
            ..._rows.map((r) {
              final pctStr = r['percentage'] ?? '0';
              final pctVal = double.tryParse(pctStr) ?? 0;
              final isGood = pctVal >= 88.0;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          r['block'] ?? '-',
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
                        r['area'] ?? '-',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        r['total_trees'] ?? '-',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        r['productive'] ?? '-',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        r['non_productive'] ?? '-',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isGood
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$pctStr%',
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
            }),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final productivePct = (_summary['productive_pct'] as num?)?.toDouble() ?? 0;
    final nonProductivePct =
        (_summary['non_productive_pct'] as num?)?.toDouble() ?? 0;
    final productiveCount = _summary['productive'] ?? 0;
    final nonProductiveCount = _summary['non_productive'] ?? 0;

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
                    value: productivePct,
                    title: '$productivePct%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.red[300]!,
                    value: nonProductivePct,
                    title: '$nonProductivePct%',
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
              _buildLegendRow(
                Colors.green,
                'Produktif: ${_formatNumber(productiveCount)} pokok',
              ),
              const SizedBox(height: 8),
              _buildLegendRow(
                Colors.red[300]!,
                'Non-Produktif: ${_formatNumber(nonProductiveCount)} pokok',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  String _formatNumber(dynamic value) {
    if (value is int) {
      return value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return value.toString();
  }
}
