import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

/// Self-contained widget showing planting planning schedule.
/// Fetches data from /dashboard/planting-planning and displays
/// a table with project, location, area, type, dates, and status.
class AdminPlantingPlanningWidget extends StatefulWidget {
  const AdminPlantingPlanningWidget({super.key});

  @override
  State<AdminPlantingPlanningWidget> createState() =>
      _AdminPlantingPlanningWidgetState();
}

class _AdminPlantingPlanningWidgetState
    extends State<AdminPlantingPlanningWidget> {
  static const _primaryBlue = Color(0xFF1B4B8C);

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
        '${ApiConstants.dashboard}planting-planning',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
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
        _isLoading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : _buildTable(),
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Lokasi Blok',
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
                    'Jenis',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Target Mulai',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Est. Selesai',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          if (_rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Belum ada rencana penanaman.',
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          else
            ..._rows.map(_buildRow),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> row) {
    final status = row['status'] ?? '-';
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

    final type = row['type'] ?? '-';
    Color typeColor;
    switch (type) {
      case 'Replanting':
        typeColor = Colors.orange;
        break;
      case 'New Opening':
        typeColor = Colors.green;
        break;
      default:
        typeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          // Project
          Expanded(
            child: Text(
              row['project'] ?? '-',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _primaryBlue,
              ),
            ),
          ),
          // Location
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    row['location'] ?? '-',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          // Area
          Expanded(
            child: Text(
              '${row['area'] ?? '-'} Ha',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          // Type
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
            ),
          ),
          // Start Date
          Expanded(
            child: Text(
              row['start_date'] ?? '-',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          // End Date
          Expanded(
            child: Text(
              row['end_date'] ?? '-',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          // Status
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
