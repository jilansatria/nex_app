import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

/// Self-contained attendance table widget that fetches data from
/// /attendance/admin/today and /attendance/admin/summary.
/// Used in the Admin HR dashboard section.
class AdminAttendanceWidget extends StatefulWidget {
  const AdminAttendanceWidget({super.key});

  @override
  State<AdminAttendanceWidget> createState() => _AdminAttendanceWidgetState();
}

class _AdminAttendanceWidgetState extends State<AdminAttendanceWidget> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  List<Map<String, dynamic>> _records = [];
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final results = await Future.wait([
        _dioClient.dio.get('${ApiConstants.attendance}admin/today'),
        _dioClient.dio.get('${ApiConstants.attendance}admin/summary'),
      ]);
      setState(() {
        _records = (results[0].data as List? ?? [])
            .map((r) => r as Map<String, dynamic>)
            .toList();
        _summary = results[1].data as Map<String, dynamic>? ?? {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF1B4B8C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fingerprint, size: 20, color: primaryBlue),
            const SizedBox(width: 8),
            const Text(
              'Attendance Integration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (!_isLoading) ...[
              _buildSummaryChip(
                'Hadir',
                '${_summary['present'] ?? 0}',
                Colors.green,
              ),
              const SizedBox(width: 8),
              _buildSummaryChip(
                'Terlambat',
                '${_summary['late'] ?? 0}',
                Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildSummaryChip(
                'Absen',
                '${_summary['absent'] ?? 0}',
                Colors.red,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Real-time attendance data from the system',
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
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _records.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Belum ada data kehadiran hari ini.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Nama Karyawan',
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
                              'Check In',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Check Out',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Jam Kerja',
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
                    ..._records.map((r) => _buildRow(r)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> record) {
    final status = record['status'] ?? '-';
    Color statusColor;
    switch (status) {
      case 'Hadir':
        statusColor = Colors.green;
        break;
      case 'Terlambat':
        statusColor = Colors.orange;
        break;
      case 'Tidak Hadir':
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
            flex: 2,
            child: Text(
              record['name'] ?? '-',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  (record['method'] ?? '') == 'Face Recognition'
                      ? Icons.face
                      : Icons.fingerprint,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    record['method'] ?? '-',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              record['check_in'] ?? '-',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            child: Text(
              record['check_out'] ?? '-',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            child: Text(
              record['work_hours'] ?? '-',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
