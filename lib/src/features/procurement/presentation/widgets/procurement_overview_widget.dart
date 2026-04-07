import 'package:flutter/material.dart';
import '../../data/repositories/procurement_repository.dart';
import '../../domain/entities/procurement_entities.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/widgets/estate_performance_card.dart';

class ProcurementOverviewWidget extends StatefulWidget {
  const ProcurementOverviewWidget({super.key});

  @override
  State<ProcurementOverviewWidget> createState() =>
      _ProcurementOverviewWidgetState();
}

class _ProcurementOverviewWidgetState extends State<ProcurementOverviewWidget> {
  final _repository = ProcurementRepository(DioClient());
  List<PurchaseOrderEntity> _pos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final pos = await _repository.getPOs();
    if (mounted) {
      setState(() {
        _pos = pos;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Summary Cards
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: EstatePerformanceCard(
                  title: 'Pending Approval',
                  value:
                      '${_pos.where((p) => p.status == "Draft" || p.status == "Pending Approval").length}',
                  subtitle: 'Action Required',
                  icon: Icons.approval,
                  color: Colors.orange,
                  trend: 'High',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: EstatePerformanceCard(
                  title: 'Approved (Open)',
                  value: '${_pos.where((p) => p.status == "Approved").length}',
                  subtitle: 'Awaiting Delivery',
                  icon: Icons.local_shipping,
                  color: Colors.blue,
                  trend: 'Normal',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: EstatePerformanceCard(
                  title: 'Total Spending',
                  value: '\$${_calculateTotalSpending()}',
                  subtitle: 'This Month',
                  icon: Icons.shopping_bag,
                  color: Colors.red,
                  trend: '-2%',
                ),
              ),
            ],
          ),
        ),

        // PO List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _pos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final po = _pos[index];
              return _buildPOCard(po);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPOCard(PurchaseOrderEntity po) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Colors.brown,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        po.supplierName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'PO #${po.poNumber}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(po.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  po.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(po.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${po.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                po.date.toString().substring(0, 10),
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (po.status == 'Draft' || po.status == 'Pending Approval')
                ElevatedButton.icon(
                  onPressed: () => _approvePO(po.id),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              if (po.status == 'Approved') ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _receivePO(po.id),
                  icon: const Icon(Icons.inventory, size: 16),
                  label: const Text('Receive Goods'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _approvePO(String id) async {
    final success = await _repository.approvePO(id);
    if (success) _loadData();
  }

  Future<void> _receivePO(String id) async {
    final success = await _repository.receivePO(id);
    if (success) _loadData();
  }

  Color _getStatusColor(String status) {
    if (status == 'Approved') return Colors.blue;
    if (status == 'Received') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.orange;
  }

  String _calculateTotalSpending() {
    double total = _pos.fold(0, (sum, p) => sum + p.totalAmount);
    return total.toStringAsFixed(0);
  }
}
