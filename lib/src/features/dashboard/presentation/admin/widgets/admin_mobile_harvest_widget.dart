import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

/// Self-contained widget showing recent mobile harvest entries.
/// Fetches data from /dashboard/harvest-entries and displays
/// a table with block, GPS, harvester, bunches, weight, time, status columns.
class AdminMobileHarvestWidget extends StatefulWidget {
  const AdminMobileHarvestWidget({super.key});

  @override
  State<AdminMobileHarvestWidget> createState() =>
      _AdminMobileHarvestWidgetState();
}

class _AdminMobileHarvestWidgetState extends State<AdminMobileHarvestWidget> {
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
        '${ApiConstants.dashboard}harvest-entries?limit=10',
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
                    'Blok',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Lokasi GPS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Pemanen',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Janjang (Unit)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Berat (Kg)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Waktu Entry',
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
                'Belum ada data panen.',
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
    final status = row['status'] ?? 'Synced';
    final isSynced = status == 'Harvested' || status == 'Synced';
    final displayStatus = isSynced ? 'Synced' : 'Pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          // Block
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                row['block'] ?? '-',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
            ),
          ),
          // GPS
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    row['gps'] ?? '-',
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Harvester
          Expanded(
            child: Text(
              row['harvester'] ?? '-',
              style: const TextStyle(fontSize: 11),
            ),
          ),
          // Bunches
          Expanded(
            child: Text(
              row['bunches'] ?? '0',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          // Weight
          Expanded(
            child: Text(
              '${row['weight'] ?? '0'} ${row['unit'] ?? 'Ton'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          // Time
          Expanded(
            child: Text(
              row['time'] ?? '-',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          // Status
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
                    displayStatus,
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
}
