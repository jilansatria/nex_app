import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/features/dashboard/data/repositories/pipeline_repository.dart';

/// Finance Pipeline Summary for Finance Manager (Tahap 6: UANG).
/// Cross-references: Sales revenue + Production output + Expenses + Payroll.
/// Uses [PipelineRepository] — no hardcoded API calls.
class FinancePipelineWidget extends StatefulWidget {
  const FinancePipelineWidget({super.key});

  @override
  State<FinancePipelineWidget> createState() => _FinancePipelineWidgetState();
}

class _FinancePipelineWidgetState extends State<FinancePipelineWidget> {
  late final PipelineRepository _repo;
  Map<String, dynamic>? _summary;
  List<dynamic>? _revenueBreakdown;
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
      final summary = await _repo.getFinancePipelineSummary();
      final breakdown = await _repo.getRevenueByProduct();
      setState(() {
        _summary = summary;
        _revenueBreakdown = breakdown['breakdown'] as List?;
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
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Failed to load financial data',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(_error!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
          ],
        ),
      );
    }

    final fin = _summary?['financials'] ?? {};
    final chain = _summary?['chain_data'] ?? {};
    final period = _summary?['period'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pipeline Financial Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${period['start'] ?? '-'} → ${period['end'] ?? '-'}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Core Financials — 3 KPI Cards
          Row(
            children: [
              Expanded(
                  child: _buildFinCard('Total Revenue', fin['revenue'],
                      Icons.trending_up, Colors.green)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildFinCard('Total Costs', fin['total_costs'],
                      Icons.money_off, Colors.red)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildFinCard('Net Profit', fin['net_profit'],
                      Icons.account_balance, Colors.blue)),
            ],
          ),
          const SizedBox(height: 24),

          // Details: Revenue Breakdown + Cost & Chain Metrics
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRevenueBreakdown()),
              const SizedBox(width: 24),
              Expanded(flex: 3, child: _buildCostAndChainMetrics(fin, chain)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinCard(
      String title, dynamic amount, IconData icon, Color color) {
    final isNegative = (amount is num) && amount < 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              if (isNegative)
                const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isNegative ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Revenue by Product',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          if (_revenueBreakdown == null || _revenueBreakdown!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('No sales revenue data yet',
                    style: TextStyle(color: Colors.grey[500])),
              ),
            )
          else
            ..._revenueBreakdown!.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['product'] ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            '${r['shipment_count']} shipments • ${r['quantity_tons']} Tons',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      Text(
                        _formatCurrency(r['revenue']),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 14),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildCostAndChainMetrics(
      Map<String, dynamic> fin, Map<String, dynamic> chain) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('Cost Breakdown & Chain Data',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),

          // Costs
          _buildMetricRow('Operational Expenses',
              _formatCurrency(fin['expenses']), Colors.red),
          const SizedBox(height: 12),
          _buildMetricRow(
              'Payroll Costs', _formatCurrency(fin['payroll']), Colors.orange),

          const Divider(height: 32),

          // Chain Data — cross-referenced from other modules
          const Text('Linked Chain Metrics',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Cross-referenced from Production & Harvest modules',
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 12),

          _buildMetricRow('FFB Harvest (Panen)',
              '${_formatNum(chain['harvest_tons'])} Tons', Colors.green[700]!),
          const SizedBox(height: 8),
          _buildMetricRow('FFB Processed (Produksi)',
              '${_formatNum(chain['ffb_processed_kg'])} kg', Colors.blue[700]!),
          const SizedBox(height: 8),
          _buildMetricRow('CPO Produced',
              '${_formatNum(chain['cpo_produced_kg'])} kg', Colors.amber[800]!),
          const SizedBox(height: 8),
          _buildMetricRow(
              'Kernel Produced',
              '${_formatNum(chain['kernel_produced_kg'])} kg',
              Colors.brown[600]!),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: valColor, fontSize: 14)),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';
    final n =
        value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0;
    final str = n.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return n < 0 ? '-Rp $buffer' : 'Rp $buffer';
  }

  String _formatNum(dynamic value) {
    if (value == null) return '0';
    final n =
        value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0;
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
