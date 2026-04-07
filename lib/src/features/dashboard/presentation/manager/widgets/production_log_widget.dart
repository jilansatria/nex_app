import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';
import 'package:nex_app/src/features/dashboard/data/repositories/pipeline_repository.dart';

/// Production Log Widget for Mill Manager (Tahap 3: PRODUKSI).
/// Shows production logs with Approve action that triggers auto Inventory IN.
/// Uses [ApiConstants] and [PipelineRepository] — no hardcoded URLs.
class ProductionLogWidget extends StatefulWidget {
  const ProductionLogWidget({super.key});

  @override
  State<ProductionLogWidget> createState() => _ProductionLogWidgetState();
}

class _ProductionLogWidgetState extends State<ProductionLogWidget> {
  late final PipelineRepository _repo;
  List<dynamic> _logs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = PipelineRepository(DioClient());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = DioClient().dio;
      // Fetch all production logs via mills endpoint
      final res = await dio.get(ApiConstants.millProductionApprove);
      if (mounted) {
        setState(() {
          _logs = (res.data is List) ? res.data as List : [];
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

  Future<void> _approveLog(String id) async {
    try {
      await _repo.approveProductionLog(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('✅ Log Approved — CPO & Kernel auto-added to Inventory!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to approve: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
            Text('Failed to load production logs',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    final drafts = _logs.where((l) => l['status'] != 'Approved').toList();
    final approved = _logs.where((l) => l['status'] == 'Approved').toList();

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
                  Text('Production Logs',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(
                    'Approve logs to auto-update CPO & Kernel inventory stock',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildCountBadge(
                      '${drafts.length}', 'Pending', Colors.orange),
                  const SizedBox(width: 12),
                  _buildCountBadge(
                      '${approved.length}', 'Approved', Colors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Log List
          Expanded(
            child: _logs.isEmpty
                ? const Center(child: Text('No production logs found'))
                : ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      final isApproved = log['status'] == 'Approved';
                      final dateStr = (log['date'] ?? '').toString();
                      final displayDate = dateStr.length >= 10
                          ? dateStr.substring(0, 10)
                          : dateStr;

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: isApproved
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.orange.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isApproved
                                            ? Icons.check_circle
                                            : Icons.pending,
                                        color: isApproved
                                            ? Colors.green
                                            : Colors.orange,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$displayDate — ${log['shift'] ?? 'N/A'}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isApproved
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.orange
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      log['status'] ?? 'Draft',
                                      style: TextStyle(
                                        color: isApproved
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Metrics row
                              Row(
                                children: [
                                  _buildMetric(
                                      'FFB Input',
                                      '${_formatKg(log['ffb_processed_kg'])} kg',
                                      Colors.blue),
                                  _buildMetric(
                                      'CPO Output',
                                      '${_formatKg(log['cpo_produced_kg'])} kg',
                                      Colors.amber[800]!),
                                  _buildMetric(
                                      'Kernel Output',
                                      '${_formatKg(log['kernel_produced_kg'])} kg',
                                      Colors.brown),
                                  if (log['oer_pct'] != null)
                                    _buildMetric(
                                        'OER',
                                        '${(log['oer_pct'] as num).toStringAsFixed(1)}%',
                                        Colors.purple),
                                ],
                              ),

                              // Approve button
                              if (!isApproved) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _approveLog(log['id'].toString()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.verified, size: 18),
                                    label:
                                        const Text('Approve → Auto Stock IN'),
                                  ),
                                ),
                              ],
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

  Widget _buildMetric(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _formatKg(dynamic value) {
    if (value == null) return '0';
    final n = (value as num).toInt();
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
