import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

class SalesDistributionChart extends StatefulWidget {
  const SalesDistributionChart({super.key});

  @override
  State<SalesDistributionChart> createState() => _SalesDistributionChartState();
}

class _SalesDistributionChartState extends State<SalesDistributionChart> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;

  double _totalEarnings = 0;
  double _totalSold = 0;
  String _topBuyer = '-';
  List<Map<String, dynamic>> _distribution = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final response = await _dioClient.dio.get('${ApiConstants.sales}summary');
      final data = response.data;
      setState(() {
        _totalEarnings = (data['total_earnings'] ?? 0).toDouble();
        _totalSold = (data['total_sold'] ?? 0).toDouble();
        _topBuyer = data['top_buyer'] ?? '-';
        _distribution = (data['distribution'] as List? ?? [])
            .map((d) => d as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  static const _chartColors = [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.teal,
    Colors.red,
    Colors.indigo,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          const Text(
            'Sales Distribution by Buyer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_distribution.isEmpty)
            SizedBox(
              height: 280,
              child: Center(
                child: Text(
                  'No sales data to display.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            SizedBox(
              height: 280,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: _buildSections(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildLegend(),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                'Total Sold',
                '${_totalSold.toStringAsFixed(0)} Ton',
                Colors.purple,
              ),
              _buildMetric(
                'Revenue',
                'Rp ${_formatNumber(_totalEarnings)}',
                Colors.blue,
              ),
              _buildMetric('Top Buyer', _topBuyer, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = _distribution.fold<double>(
      0,
      (s, d) => s + ((d['quantity'] ?? 0) as num).toDouble(),
    );
    if (total == 0) return [];

    return _distribution.asMap().entries.map((entry) {
      final i = entry.key;
      final d = entry.value;
      final qty = ((d['quantity'] ?? 0) as num).toDouble();
      final percentage = (qty / total * 100).toStringAsFixed(1);
      final color = _chartColors[i % _chartColors.length];

      return PieChartSectionData(
        value: qty,
        color: color,
        title: '$percentage%',
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 60,
      );
    }).toList();
  }

  List<Widget> _buildLegend() {
    return _distribution.asMap().entries.map((entry) {
      final i = entry.key;
      final d = entry.value;
      final color = _chartColors[i % _chartColors.length];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${d['buyer']} (${((d['quantity'] ?? 0) as num).toStringAsFixed(0)} Ton)',
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatNumber(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
