import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

class AdminProductionChartWidget extends StatefulWidget {
  const AdminProductionChartWidget({super.key});

  @override
  State<AdminProductionChartWidget> createState() =>
      _AdminProductionChartWidgetState();
}

class _AdminProductionChartWidgetState
    extends State<AdminProductionChartWidget> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  List<String> _months = [
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
  List<double> _values = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  double _maxY = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final response = await _dioClient.dio.get(
        '${ApiConstants.dashboard}production-chart',
      );
      final data = response.data;

      if (data != null) {
        if (mounted) {
          setState(() {
            if (data['months'] != null) {
              _months = List<String>.from(data['months']);
            }
            if (data['values'] != null) {
              _values = List<double>.from(
                (data['values'] as List).map((e) => (e as num).toDouble()),
              );
            }
            if (data['max_value'] != null) {
              _maxY = ((data['max_value'] as num).toDouble()) * 1.2;
              if (_maxY < 10) _maxY = 10;
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1B4B8C);

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
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: _maxY / 5,
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
                      interval: _maxY / 5,
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
                      interval: 1,
                      getTitlesWidget: (v, m) {
                        if (v.toInt() >= 0 && v.toInt() < _months.length) {
                          return Text(
                            _months[v.toInt()],
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
                maxY: _maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      _values.length,
                      (index) => FlSpot(index.toDouble(), _values[index]),
                    ),
                    isCurved: true,
                    color: primaryBlue,
                    barWidth: 2,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          primaryBlue.withValues(alpha: 0.3),
                          primaryBlue.withValues(alpha: 0.0),
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
}
