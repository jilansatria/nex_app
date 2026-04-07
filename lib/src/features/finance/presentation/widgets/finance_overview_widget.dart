import 'package:flutter/material.dart';
import '../../data/repositories/finance_repository.dart';
import '../../domain/entities/finance_entities.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/theme/app_theme.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/widgets/estate_performance_card.dart';

class FinanceOverviewWidget extends StatefulWidget {
  const FinanceOverviewWidget({super.key});

  @override
  State<FinanceOverviewWidget> createState() => _FinanceOverviewWidgetState();
}

class _FinanceOverviewWidgetState extends State<FinanceOverviewWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = FinanceRepository(DioClient());

  List<ExpenseEntity> _expenses = [];
  List<PayrollEntity> _payrolls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final expenses = await _repository.getExpenses();
      final payrolls = await _repository.getPayrolls();
      if (mounted) {
        setState(() {
          _expenses = expenses;
          _payrolls = payrolls;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Summary Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: EstatePerformanceCard(
                  title: 'Total Expenses',
                  value: '\$${_calculateTotalExpenses().toStringAsFixed(0)}',
                  subtitle: 'Monthly target: \$50,000',
                  icon: Icons.account_balance_wallet,
                  color: Colors.red,
                  trend: '-5%',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: EstatePerformanceCard(
                  title: 'Payroll Total',
                  value: '\$${_calculateTotalPayroll().toStringAsFixed(0)}',
                  subtitle: '${_payrolls.length} Records',
                  icon: Icons.calculate,
                  color: Colors.blue,
                  trend: '+2%',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: EstatePerformanceCard(
                  title: 'Budget Remaining',
                  value:
                      '\$${(100000 - _calculateTotalExpenses() - _calculateTotalPayroll()).toStringAsFixed(0)}',
                  subtitle: 'Yearly Plan',
                  icon: Icons.pie_chart,
                  color: Colors.green,
                  trend: 'On Track',
                ),
              ),
            ],
          ),
        ),

        // Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF1B4B8C),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF1B4B8C),
              tabs: const [
                Tab(text: 'Expenses'),
                Tab(text: 'Payroll History'),
              ],
            ),
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildExpenseList(), _buildPayrollList()],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseList() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _expenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long, color: Colors.red),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      expense.description ?? 'No description',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    expense.date.toString().substring(0, 10),
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPayrollList() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _payrolls.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final payroll = _payrolls[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${payroll.userId.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Period: ${payroll.periodStart.toString().substring(0, 10)} to ${payroll.periodEnd.toString().substring(0, 10)}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${payroll.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: payroll.status == 'Paid'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      payroll.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: payroll.status == 'Paid'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateTotalExpenses() {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }

  double _calculateTotalPayroll() {
    return _payrolls.fold(0, (sum, item) => sum + item.totalAmount);
  }
}
