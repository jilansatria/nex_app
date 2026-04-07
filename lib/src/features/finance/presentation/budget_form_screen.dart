import 'package:flutter/material.dart';
import 'package:nex_app/src/features/finance/data/repositories/budget_repository.dart';

/// Budget Form Screen — Create new budget with line items.
/// Allows Finance Manager to define budget per cost center, period, and categories.
class BudgetFormScreen extends StatefulWidget {
  const BudgetFormScreen({super.key});

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final BudgetRepository _budgetRepo = BudgetRepository();
  final _formKey = GlobalKey<FormState>();

  // Budget Header
  final _nameCtrl = TextEditingController();
  int _periodYear = DateTime.now().year;
  int _monthStart = 1;
  int _monthEnd = 12;
  String _costCenterType = 'estate';
  final _costCenterNameCtrl = TextEditingController();

  // Line Items
  final List<Map<String, dynamic>> _lineItems = [];
  bool _isSubmitting = false;

  // Budget Categories
  static const List<String> _categories = [
    'Fertilizer',
    'Labour',
    'Fuel',
    'Maintenance',
    'Transport',
    'Equipment',
    'Chemicals',
    'Utilities',
    'Overhead',
    'Other',
  ];

  void _addLineItem() {
    showDialog(
      context: context,
      builder: (ctx) {
        String category = _categories.first;
        final amountCtrl = TextEditingController();
        final descCtrl = TextEditingController();
        int month = 1;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Line Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => setDialogState(() => category = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: month,
                      decoration: const InputDecoration(labelText: 'Bulan'),
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(_monthName(i + 1)),
                        ),
                      ),
                      onChanged: (v) => setDialogState(() => month = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Estimasi (Rp)',
                        prefixText: 'Rp ',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (amountCtrl.text.isEmpty) return;
                    setState(() {
                      _lineItems.add({
                        'category': category,
                        'month': month,
                        'estimated_amount':
                            double.tryParse(amountCtrl.text) ?? 0,
                        'description': descCtrl.text,
                      });
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double get _totalEstimated => _lineItems.fold(
    0,
    (sum, item) => sum + (item['estimated_amount'] as double),
  );

  Future<void> _submitBudget() async {
    if (!_formKey.currentState!.validate() || _lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi nama budget dan minimal 1 line item'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _budgetRepo.createBudget(
        name: _nameCtrl.text.trim(),
        periodYear: _periodYear,
        periodMonthStart: _monthStart,
        periodMonthEnd: _monthEnd,
        costCenterType: _costCenterType,
        costCenterName: _costCenterNameCtrl.text.trim(),
        lines: _lineItems,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Budget berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear form
        _nameCtrl.clear();
        _costCenterNameCtrl.clear();
        setState(() => _lineItems.clear());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat budget'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Planning',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Buat anggaran baru per cost center',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // ── Budget Header ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Budget',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Budget *',
                      prefixIcon: Icon(Icons.description),
                      hintText: 'Contoh: Budget Semester 1 - Estate Utara',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _periodYear,
                          decoration: const InputDecoration(labelText: 'Tahun'),
                          items: List.generate(5, (i) {
                            final y = DateTime.now().year + i;
                            return DropdownMenuItem(
                              value: y,
                              child: Text('$y'),
                            );
                          }),
                          onChanged: (v) => setState(() => _periodYear = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _monthStart,
                          decoration: const InputDecoration(
                            labelText: 'Bulan Mulai',
                          ),
                          items: List.generate(
                            12,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text(_monthName(i + 1)),
                            ),
                          ),
                          onChanged: (v) => setState(() => _monthStart = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _monthEnd,
                          decoration: const InputDecoration(
                            labelText: 'Bulan Selesai',
                          ),
                          items: List.generate(
                            12,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text(_monthName(i + 1)),
                            ),
                          ),
                          onChanged: (v) => setState(() => _monthEnd = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _costCenterType,
                          decoration: const InputDecoration(
                            labelText: 'Tipe Cost Center',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'estate',
                              child: Text('Estate'),
                            ),
                            DropdownMenuItem(
                              value: 'mill',
                              child: Text('Mill'),
                            ),
                            DropdownMenuItem(
                              value: 'office',
                              child: Text('Office'),
                            ),
                            DropdownMenuItem(
                              value: 'project',
                              child: Text('Project'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _costCenterType = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _costCenterNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama Cost Center',
                            hintText: 'Contoh: PKS Sei Mangkei',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Line Items ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Line Items',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addLineItem,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_lineItems.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada line item',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  else
                    Table(
                      border: TableBorder.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1.5),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(0.5),
                      },
                      children: [
                        // Header
                        TableRow(
                          decoration: BoxDecoration(color: Colors.blue[50]),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Kategori',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Bulan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Estimasi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Data rows
                        ..._lineItems.asMap().entries.map((entry) {
                          final item = entry.value;
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  item['category'] ?? '-',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  _monthName(item['month'] ?? 1),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'Rp ${_formatNumber(item['estimated_amount'] ?? 0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => setState(
                                    () => _lineItems.removeAt(entry.key),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  if (_lineItems.isNotEmpty) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Total Estimasi: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp ${_formatNumber(_totalEstimated)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitBudget,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text('Submit Budget'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return names[m - 1];
  }

  String _formatNumber(double number) {
    if (number >= 1000000000)
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(0)}K';
    return number.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _costCenterNameCtrl.dispose();
    super.dispose();
  }
}
