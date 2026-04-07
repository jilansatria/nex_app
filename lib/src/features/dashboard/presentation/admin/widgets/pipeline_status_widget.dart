import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/features/dashboard/data/repositories/pipeline_repository.dart';

/// Widget that displays the full ERP data chain pipeline status for Admin.
/// Shows all 6 stages: Panen → Timbang → Produksi → Stok → Jual → Uang
class PipelineStatusWidget extends StatefulWidget {
  const PipelineStatusWidget({super.key});

  @override
  State<PipelineStatusWidget> createState() => _PipelineStatusWidgetState();
}

class _PipelineStatusWidgetState extends State<PipelineStatusWidget> {
  late final PipelineRepository _repo;
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = PipelineRepository(DioClient());
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getPipelineStatus();
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildError();
    }
    if (_data == null) {
      return const Center(child: Text('No pipeline data'));
    }

    final pipeline = _data!['pipeline'] as Map<String, dynamic>? ?? {};
    final bottlenecks = (_data!['bottlenecks'] as List?) ?? [];

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.account_tree_rounded,
                    color: Color(0xFF2E7D32), size: 28),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Data Chain Pipeline',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _fetchData,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Tanggal: ${_data!['date'] ?? '-'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Bottleneck alerts
            if (bottlenecks.isNotEmpty) ...[
              _buildBottleneckAlerts(bottlenecks),
              const SizedBox(height: 16),
            ],

            // Pipeline stages
            _buildStageCard(
              icon: Icons.agriculture,
              color: const Color(0xFF4CAF50),
              title: '1. PANEN (Harvest)',
              role: 'Field Officer',
              data: pipeline['1_panen'],
              labels: {
                'harvest_today_tons': 'Panen Hari Ini (Ton)',
                'harvest_month_tons': 'Panen Bulan Ini (Ton)',
                'entries_today': 'Entri Hari Ini',
              },
            ),
            _buildChainArrow(),

            _buildStageCard(
              icon: Icons.scale,
              color: const Color(0xFF2196F3),
              title: '2. TIMBANG (Weighbridge)',
              role: 'Estate Manager',
              data: pipeline['2_timbang'],
              labels: {
                'trucks_today': 'Truk Hari Ini',
                'netto_today_kg': 'Netto Hari Ini (Kg)',
                'pending_weigh_out': 'Menunggu Weigh Out',
              },
            ),
            _buildChainArrow(),

            _buildStageCard(
              icon: Icons.factory,
              color: const Color(0xFFFF9800),
              title: '3. PRODUKSI (Processing)',
              role: 'Mill Manager',
              data: pipeline['3_produksi'],
              labels: {
                'cpo_month_kg': 'CPO Bulan Ini (Kg)',
                'kernel_month_kg': 'Kernel Bulan Ini (Kg)',
                'pending_approval': 'Menunggu Approval',
              },
            ),
            _buildChainArrow(),

            _buildStockStage(pipeline['4_stok']),
            _buildChainArrow(),

            _buildStageCard(
              icon: Icons.shopping_cart,
              color: const Color(0xFF9C27B0),
              title: '5. JUAL (Sales)',
              role: 'Sales Officer',
              data: pipeline['5_jual'],
              labels: {
                'active_contracts': 'Kontrak Aktif',
                'shipments_month': 'Pengiriman Bulan Ini',
                'revenue_month': 'Revenue Bulan Ini (Rp)',
              },
              formatCurrency: ['revenue_month'],
            ),
            _buildChainArrow(),

            _buildStageCard(
              icon: Icons.account_balance,
              color: const Color(0xFFF44336),
              title: '6. UANG (Finance)',
              role: 'Finance Manager',
              data: pipeline['6_uang'],
              labels: {
                'revenue': 'Revenue (Rp)',
                'expenses': 'Expenses (Rp)',
                'payroll': 'Payroll (Rp)',
                'net_profit': 'Net Profit (Rp)',
              },
              formatCurrency: ['revenue', 'expenses', 'payroll', 'net_profit'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottleneckAlerts(List bottlenecks) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Bottleneck Detected',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange[800]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...bottlenecks.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${b['stage']}: ${b['issue']}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStageCard({
    required IconData icon,
    required Color color,
    required String title,
    required String role,
    Map<String, dynamic>? data,
    required Map<String, String> labels,
    List<String> formatCurrency = const [],
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(role,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (data != null)
            ...labels.entries.map((e) {
              final val = data[e.key];
              String display;
              if (val == null) {
                display = '-';
              } else if (formatCurrency.contains(e.key)) {
                display = _formatCurrency(val);
              } else {
                display = _formatNumber(val);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.value,
                        style:
                            TextStyle(color: Colors.grey[700], fontSize: 13)),
                    Text(display,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStockStage(dynamic stockData) {
    final items = (stockData is List) ? stockData : [];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(left: BorderSide(color: Colors.teal, width: 4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.inventory_2, color: Colors.teal, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('4. STOK (Inventory)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Mill Manager',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text('Tidak ada data stok',
                style: TextStyle(color: Colors.grey))
          else
            ...items.map<Widget>((item) {
              final product = item['product'] ?? '-';
              final stock = _formatNumber(item['current_stock_kg']);
              final status = item['status'] ?? 'OK';
              final isLow = status == 'LOW';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          Text(product, style: const TextStyle(fontSize: 13)),
                    ),
                    Text(
                      '$stock Kg',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isLow ? Colors.red : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLow ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isLow ? Colors.red[700] : Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildChainArrow() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(width: 2, height: 16, color: Colors.grey[300]),
            Icon(Icons.arrow_downward, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error ?? 'Unknown error'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
        ],
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '-';
    final num n = value is num ? value : num.tryParse(value.toString()) ?? 0;
    if (n == n.toInt()) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';
    final num n = value is num ? value : num.tryParse(value.toString()) ?? 0;
    // Simple thousands separator
    final str = n.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0 && str[i] != '-') {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }
}
