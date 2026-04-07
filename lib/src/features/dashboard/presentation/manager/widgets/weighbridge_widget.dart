import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

/// Weighbridge Widget for Estate Manager (Tahap 2: TIMBANG).
/// Shows weighbridge entries from the mill endpoint.
/// Uses [ApiConstants.millWeighbridge] — no hardcoded URLs.
class WeighbridgeWidget extends StatefulWidget {
  const WeighbridgeWidget({super.key});

  @override
  State<WeighbridgeWidget> createState() => _WeighbridgeWidgetState();
}

class _WeighbridgeWidgetState extends State<WeighbridgeWidget> {
  List<dynamic> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = DioClient().dio;
      final res = await dio.get(ApiConstants.millWeighbridge);
      if (mounted) {
        setState(() {
          _entries = res.data as List;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Failed to load weighbridge data',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    // Separate entries by status
    final completed =
        _entries.where((e) => e['status'] == 'Completed').toList();
    final pending = _entries.where((e) => e['status'] != 'Completed').toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weighbridge (Timbangan)',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(
                      'Track FFB trucks from estates — validates weight & quality grading',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              Row(
                children: [
                  _buildCountBadge(
                      '${pending.length}', 'Pending', Colors.orange),
                  const SizedBox(width: 12),
                  _buildCountBadge(
                      '${completed.length}', 'Completed', Colors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Data Table
          Expanded(
            child: _entries.isEmpty
                ? const Center(child: Text('No weighbridge entries found'))
                : ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      final isCompleted = entry['status'] == 'Completed';
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: isCompleted
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.orange.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isCompleted
                                      ? Icons.check_circle
                                      : Icons.airport_shuttle,
                                  color: isCompleted
                                      ? Colors.green
                                      : Colors.orange,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Ticket: ${entry['ticket_no'] ?? '-'}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '🚚 ${entry['vehicle_plate'] ?? '-'}',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Estate: ${entry['estate_origin'] ?? '-'} • Block: ${entry['block_origin'] ?? '-'}',
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    if (isCompleted)
                                      Row(
                                        children: [
                                          _buildWeightChip(
                                              'In',
                                              '${entry['weight_in_kg'] ?? 0} kg',
                                              Colors.blue),
                                          const SizedBox(width: 8),
                                          _buildWeightChip(
                                              'Out',
                                              '${entry['weight_out_kg'] ?? 0} kg',
                                              Colors.grey),
                                          const SizedBox(width: 8),
                                          _buildWeightChip(
                                              'Netto',
                                              '${entry['netto_kg'] ?? 0} kg',
                                              Colors.green),
                                        ],
                                      )
                                    else
                                      Row(
                                        children: [
                                          _buildWeightChip(
                                              'In',
                                              '${entry['weight_in_kg'] ?? 0} kg',
                                              Colors.blue),
                                          const SizedBox(width: 8),
                                          _buildWeightChip('Out (Wait Sensor)',
                                              '0 kg', Colors.orange),
                                          const SizedBox(width: 8),
                                          _buildWeightChip(
                                              'Netto', '0 kg', Colors.grey),
                                        ],
                                      ),
                                  ],
                                ),
                              ),

                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  entry['status'] ?? 'Pending',
                                  style: TextStyle(
                                    color: isCompleted
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(count,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildWeightChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('$label: $value',
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
