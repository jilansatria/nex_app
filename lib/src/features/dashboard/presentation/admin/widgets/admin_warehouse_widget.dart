import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

class AdminWarehouseWidget extends StatefulWidget {
  const AdminWarehouseWidget({super.key});

  @override
  State<AdminWarehouseWidget> createState() => _AdminWarehouseWidgetState();
}

class _AdminWarehouseWidgetState extends State<AdminWarehouseWidget> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final response = await _dioClient.dio.get(
        '${ApiConstants.dashboard}warehouse-stock',
      );
      final data = response.data;
      if (mounted) {
        setState(() {
          _rows = (data['rows'] as List? ?? [])
              .map((r) => r as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Button Stub
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

          if (_rows.isEmpty)
            const Center(child: Text("No warehouse stock data")),

          ..._rows.map((row) {
            final chartVals = (row['chart_values'] as List? ?? [0, 0, 0])
                .map((e) => (e as num).toDouble())
                .toList();

            return Column(
              children: [
                _buildWarehouseProductCard(
                  row['location'] ?? '-',
                  row['owner'] ?? '-',
                  row['time_left'] ?? '-',
                  row['amount'] ?? '-',
                  row['image'] ?? 'assets/images/sawit_1.jpg', // Fallback
                  chartVals,
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, _) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.more_horiz, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDetailRow('Owner', owner)),
                    Expanded(
                      child: _buildDetailRow(
                        'Time Left',
                        timeLeft,
                        isRed: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Amount', amount, isBlue: true),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Donut Chart
          Column(
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 20,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: Colors.blue,
                        value: chartValues.isNotEmpty ? chartValues[0] : 0,
                        showTitle: false,
                        radius: 8,
                      ),
                      PieChartSectionData(
                        color: Colors.teal,
                        value: chartValues.length > 1 ? chartValues[1] : 0,
                        showTitle: false,
                        radius: 8,
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: chartValues.length > 2 ? chartValues[2] : 0,
                        showTitle: false,
                        radius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _buildWarehouseChartLegend(chartValues),
            ],
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
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isBlue
                ? Colors.blue
                : isRed
                ? Colors.red
                : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseChartLegend(List<double> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendRow(
          Colors.blue,
          'Good',
          '${values.isNotEmpty ? values[0] : 0}%',
        ),
        _buildLegendRow(
          Colors.teal,
          'Fair',
          '${values.length > 1 ? values[1] : 0}%',
        ),
        _buildLegendRow(
          Colors.red,
          'Poor',
          '${values.length > 2 ? values[2] : 0}%',
        ),
      ],
    );
  }

  Widget _buildLegendRow(Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 8, color: Colors.grey[600])),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
