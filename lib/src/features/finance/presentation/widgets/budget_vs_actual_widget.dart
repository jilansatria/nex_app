import 'package:flutter/material.dart';
import 'package:nex_app/src/features/finance/data/repositories/budget_repository.dart';

/// Budget vs Actual Dashboard Widget.
/// Displays a visual comparison between planned budget and actual spending,
/// broken down by category with variance indicators.
class BudgetVsActualWidget extends StatefulWidget {
  const BudgetVsActualWidget({super.key});

  @override
  State<BudgetVsActualWidget> createState() => _BudgetVsActualWidgetState();
}

class _BudgetVsActualWidgetState extends State<BudgetVsActualWidget> {
  final BudgetRepository _budgetRepo = BudgetRepository();

  bool _isLoading = true;
  List<Map<String, dynamic>> _budgets = [];
  Map<String, dynamic>? _selectedComparison;
  String? _selectedBudgetId;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    setState(() => _isLoading = true);
    try {
      _budgets = await _budgetRepo.getBudgets(
        periodYear: DateTime.now().year,
        status: 'Approved',
      );
      if (_budgets.isNotEmpty) {
        _selectedBudgetId = _budgets.first['id'];
        await _loadComparison(_selectedBudgetId!);
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadComparison(String budgetId) async {
    try {
      _selectedComparison = await _budgetRepo.getBudgetVsActual(budgetId);
      setState(() {});
    } catch (e) {
      // Handle error
    }
  }

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget vs Actual',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_budgets.isNotEmpty)
                DropdownButton<String>(
                  value: _selectedBudgetId,
                  underline: const SizedBox(),
                  items: _budgets.map((b) {
                    return DropdownMenuItem(
                      value: b['id'] as String,
                      child: Text(
                        b['name'] ?? 'Budget',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => _selectedBudgetId = v);
                    if (v != null) _loadComparison(v);
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_selectedComparison == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Belum ada budget yang diapprove.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else ...[
            // Summary Cards
            Row(
              children: [
                _buildSummaryCard(
                  'Estimasi',
                  _selectedComparison!['total_estimated'] ?? 0,
                  Colors.blue,
                  Icons.account_balance_wallet,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  'Realisasi',
                  _selectedComparison!['total_actual'] ?? 0,
                  Colors.green,
                  Icons.payments,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  'Variance',
                  _selectedComparison!['total_variance'] ?? 0,
                  (_selectedComparison!['total_variance'] ?? 0) >= 0
                      ? Colors.green
                      : Colors.red,
                  Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category Breakdown
            const Text(
              'Breakdown per Kategori',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...(_selectedComparison!['categories'] as List? ?? []).map((cat) {
              final estimated = (cat['estimated'] ?? 0).toDouble();
              final actual = (cat['actual'] ?? 0).toDouble();
              final progress = estimated > 0
                  ? (actual / estimated).clamp(0.0, 1.5)
                  : 0.0;
              final isOverBudget = actual > estimated;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cat['category'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Rp ${_formatNumber(actual)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isOverBudget ? Colors.red : Colors.green,
                              ),
                            ),
                            Text(
                              ' / Rp ${_formatNumber(estimated)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.toDouble(),
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(
                          isOverBudget ? Colors.red : Colors.green,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    num value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: color, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${_formatNumber(value.toDouble())}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    if (number.abs() >= 1000000000)
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    if (number.abs() >= 1000000)
      return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number.abs() >= 1000) return '${(number / 1000).toStringAsFixed(0)}K';
    return number.toStringAsFixed(0);
  }
}
