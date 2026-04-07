import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

class AdminFieldSummaryWidget extends StatefulWidget {
  const AdminFieldSummaryWidget({super.key});

  @override
  State<AdminFieldSummaryWidget> createState() =>
      _AdminFieldSummaryWidgetState();
}

class _AdminFieldSummaryWidgetState extends State<AdminFieldSummaryWidget> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final response = await _dioClient.dio.get(
        '${ApiConstants.dashboard}field-summary',
      );
      if (mounted) {
        setState(() {
          _data = response.data ?? {};
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
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final totalArea = _data['total_area'] ?? 0;
    final harvestToday = _data['harvest_today'] ?? 0;
    final totalProduction = _data['total_production'] ?? 0;
    final blockCount = _data['block_count'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildCard(
            'Total Area',
            '${totalArea} Ha',
            Icons.map,
            Colors.green,
            '${blockCount} Blocks',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            'Harvest Today',
            '${harvestToday} Ton',
            Icons.grass,
            Colors.orange,
            'Realtime',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            'Total Production',
            '${totalProduction} Ton',
            Icons.inventory_2,
            Colors.blue,
            'All time',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            'Active Blocks',
            '$blockCount',
            Icons.grid_view,
            Colors.purple,
            'In operation',
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
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
              // Optional: Trend arrow or similar could go here
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
