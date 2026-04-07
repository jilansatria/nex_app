import 'package:flutter/material.dart';
import 'package:nex_app/src/core/theme/app_theme.dart';

class FinancePayrollWidget extends StatefulWidget {
  const FinancePayrollWidget({super.key});

  @override
  State<FinancePayrollWidget> createState() => _FinancePayrollWidgetState();
}

class _FinancePayrollWidgetState extends State<FinancePayrollWidget> {
  // Dummy Data State
  final List<Map<String, dynamic>> _payrollData = [
    {
      'name': 'John Doe',
      'role': 'Mill Operator',
      'base': 3500,
      'bonus': 500,
      'deduction': 100,
      'status': 'Paid'
    },
    {
      'name': 'Jane Smith',
      'role': 'Estate Manager',
      'base': 5200,
      'bonus': 800,
      'deduction': 0,
      'status': 'Pending'
    },
    {
      'name': 'Ahmad Yusuf',
      'role': 'Logistics Driver',
      'base': 2800,
      'bonus': 300,
      'deduction': 50,
      'status': 'Paid'
    },
    {
      'name': 'Sarah Lee',
      'role': 'HR Officer',
      'base': 3800,
      'bonus': 400,
      'deduction': 0,
      'status': 'Processing'
    },
    {
      'name': 'Budi Santoso',
      'role': 'Field Worker',
      'base': 2100,
      'bonus': 150,
      'deduction': 20,
      'status': 'Paid'
    },
  ];

  bool _isRunningPayroll = false;

  void _exportCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.file_download_done, color: Colors.white),
            SizedBox(width: 8),
            Text('Payroll data exported to CSV successfully!'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _runPayroll() async {
    setState(() => _isRunningPayroll = true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        for (var employee in _payrollData) {
          if (employee['status'] != 'Paid') {
            employee['status'] = 'Paid';
          }
        }
        _isRunningPayroll = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Payroll executed successfully! All pending salaries paid.'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payroll Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _exportCSV,
                    icon: const Icon(Icons.download),
                    label: const Text('Export CSV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isRunningPayroll ? null : _runPayroll,
                    icon: _isRunningPayroll
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(
                        _isRunningPayroll ? 'Processing...' : 'Run Payroll'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.grey[50]),
                  columns: const [
                    DataColumn(
                        label: Text('Employee ID',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Employee Name',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Role',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Base Salary',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Bonus',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Deductions',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Net Pay',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Action',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: List.generate(_payrollData.length, (index) {
                    final p = _payrollData[index];
                    final net = (p['base'] as int) +
                        (p['bonus'] as int) -
                        (p['deduction'] as int);
                    final status = p['status'] as String;

                    Color statusColor = Colors.grey;
                    if (status == 'Paid') statusColor = Colors.green;
                    if (status == 'Pending') statusColor = Colors.orange;
                    if (status == 'Processing') statusColor = Colors.blue;

                    return DataRow(cells: [
                      DataCell(Text('EMP-${1000 + index}')),
                      DataCell(Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                AppTheme.primary.withValues(alpha: 0.1),
                            child: Text((p['name'] as String)[0],
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.primary)),
                          ),
                          const SizedBox(width: 8),
                          Text(p['name'] as String,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      )),
                      DataCell(Text(p['role'] as String)),
                      DataCell(Text('\$${p['base']}')),
                      DataCell(Text('+\$${p['bonus']}',
                          style: const TextStyle(color: Colors.green))),
                      DataCell(Text('-\$${p['deduction']}',
                          style: const TextStyle(color: Colors.red))),
                      DataCell(Text('\$$net',
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(status,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      )),
                      DataCell(IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onPressed: () {},
                      )),
                    ]);
                  }),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
