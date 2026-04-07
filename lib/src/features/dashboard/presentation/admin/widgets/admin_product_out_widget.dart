import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

/// Self-contained Product Out Report widget.
/// Fetches data from /dashboard/product-out and displays a table
/// with product name, status, code, quantity, and date.
class AdminProductOutWidget extends StatefulWidget {
  const AdminProductOutWidget({super.key});

  @override
  State<AdminProductOutWidget> createState() => _AdminProductOutWidgetState();
}

class _AdminProductOutWidgetState extends State<AdminProductOutWidget> {
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
        '${ApiConstants.dashboard}product-out?limit=10',
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

  TextStyle get _headerStyle => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.grey[600],
  );

  @override
  Widget build(BuildContext context) {
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
          // Title Row
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

          // Table Header
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('PRODUCT NAME', style: _headerStyle),
              ),
              Expanded(child: Text('STATUS', style: _headerStyle)),
              Expanded(child: Text('PRODUCT CODE', style: _headerStyle)),
              Expanded(child: Text('QUANTITY', style: _headerStyle)),
              Expanded(child: Text('DATE', style: _headerStyle)),
            ],
          ),
          const Divider(height: 16),

          // Content
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _rows.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Belum ada data produksi.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              : Column(
                  children: [
                    ..._rows.map(_buildRow),
                    const SizedBox(height: 10),
                    // Pagination stub
                    Row(
                      children: [
                        const Icon(
                          Icons.chevron_left,
                          size: 14,
                          color: Colors.grey,
                        ),
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
                        const Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> row) {
    final status = row['status'] ?? 'Harvested';
    Color statusBg;
    Color statusText;
    switch (status) {
      case 'Harvested':
        statusBg = Colors.blue[50]!;
        statusText = _primaryBlue;
        break;
      case 'Processing':
        statusBg = Colors.orange[50]!;
        statusText = Colors.orange;
        break;
      case 'Sold':
        statusBg = Colors.green[50]!;
        statusText = Colors.green;
        break;
      default:
        statusBg = Colors.grey[100]!;
        statusText = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row['name'] ?? '-',
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: TextStyle(fontSize: 9, color: statusText),
              ),
            ),
          ),
          Expanded(
            child: Text(
              row['code'] ?? '-',
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            child: Text(
              row['qty'] ?? '-',
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            child: Text(
              row['date'] ?? '-',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
