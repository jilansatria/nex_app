import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MillProductionChart extends StatefulWidget {
  const MillProductionChart({super.key});

  @override
  State<MillProductionChart> createState() => _MillProductionChartState();
}

class _MillProductionChartState extends State<MillProductionChart> {
  String _selectedMetric = 'OER';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Production Efficiency Trend',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'OER', label: Text('OER')),
                  ButtonSegment(value: 'KER', label: Text('KER')),
                  ButtonSegment(value: 'FFB', label: Text('FFB')),
                ],
                selected: {_selectedMetric},
                onSelectionChanged: (Set<String> selected) {
                  setState(() => _selectedMetric = selected.first);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _selectedMetric == 'FFB' ? 100 : 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (_selectedMetric == 'FFB') {
                          return Text('${value.toInt()} Ton',
                              style: const TextStyle(fontSize: 10));
                        }
                        return Text('${value.toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const hours = [
                          '00:00',
                          '04:00',
                          '08:00',
                          '12:00',
                          '16:00',
                          '20:00',
                          '24:00'
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < hours.length) {
                          return Text(hours[value.toInt()],
                              style: const TextStyle(fontSize: 9));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getSpots(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [Colors.orange[700]!, Colors.orange[400]!],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withValues(alpha: 0.3),
                          Colors.orange.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: _selectedMetric == 'FFB' ? 0 : 18,
                maxY: _selectedMetric == 'FFB' ? 600 : 26,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricInfo(),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots() {
    if (_selectedMetric == 'OER') {
      return const [
        FlSpot(0, 0),
        FlSpot(1, 0),
        FlSpot(2, 0),
        FlSpot(3, 0),
        FlSpot(4, 0),
        FlSpot(5, 0),
        FlSpot(6, 0),
      ];
    } else if (_selectedMetric == 'KER') {
      return const [
        FlSpot(0, 0),
        FlSpot(1, 0),
        FlSpot(2, 0),
        FlSpot(3, 0),
        FlSpot(4, 0),
        FlSpot(5, 0),
        FlSpot(6, 0),
      ];
    } else {
      return const [
        FlSpot(0, 0),
        FlSpot(1, 0),
        FlSpot(2, 0),
        FlSpot(3, 0),
        FlSpot(4, 0),
        FlSpot(5, 0),
        FlSpot(6, 0),
      ];
    }
  }

  Widget _buildMetricInfo() {
    String description = '';
    String target = '';
    Color statusColor = Colors.green;

    if (_selectedMetric == 'OER') {
      description = 'Oil Extraction Rate - Ratio CPO yang dihasilkan dari FFB';
      target = 'Target: 24.0% | Current Avg: 0%';
      statusColor = Colors.orange;
    } else if (_selectedMetric == 'KER') {
      description = 'Kernel Extraction Rate - Ratio Kernel yang dihasilkan';
      target = 'Target: 5.5% | Current Avg: 0%';
      statusColor = Colors.blue;
    } else {
      description = 'Fresh Fruit Bunch - Total FFB yang diproses hari ini';
      target = 'Target: 500 Ton | Current: 0 Ton';
      statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            target,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
