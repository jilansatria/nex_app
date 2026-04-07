import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

class SalesLogisticsTable extends StatefulWidget {
  const SalesLogisticsTable({super.key});

  @override
  State<SalesLogisticsTable> createState() => _SalesLogisticsTableState();
}

class _SalesLogisticsTableState extends State<SalesLogisticsTable> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentSales = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final response = await _dioClient.dio.get('${ApiConstants.sales}summary');
      final data = response.data;
      setState(() {
        _recentSales = (data['recent_sales'] as List? ?? [])
            .map((s) => s as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Sales Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Sale'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_recentSales.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No sales data available.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            Table(
              border: TableBorder.all(color: Colors.grey[300]!, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1.2),
                4: FlexColumnWidth(1),
              },
              children: [
                _buildHeaderRow(),
                ..._recentSales.map((sale) {
                  return _buildDataRow(
                    sale['buyer_name'] ?? '-',
                    sale['product_name'] ?? '-',
                    '${sale['quantity'] ?? 0}',
                    'Rp ${_formatNumber(sale['total_price'] ?? 0)}',
                    sale['date'] ?? '-',
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic value) {
    final num = (value is int) ? value.toDouble() : (value as double? ?? 0);
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(0)}k';
    }
    return num.toStringAsFixed(0);
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.purple[50]!),
      children: [
        _buildHeaderCell('Buyer'),
        _buildHeaderCell('Product'),
        _buildHeaderCell('Qty (Ton)'),
        _buildHeaderCell('Total Price'),
        _buildHeaderCell('Date'),
      ],
    );
  }

  TableRow _buildDataRow(
    String buyer,
    String product,
    String qty,
    String price,
    String date,
  ) {
    return TableRow(
      children: [
        _buildDataCell(buyer, isLeft: true),
        _buildDataCell(product, isLeft: true),
        _buildDataCell(qty),
        _buildDataCell(price),
        _buildDataCell(date),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(
    String text, {
    bool isBold = false,
    bool isLeft = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        textAlign: isLeft ? TextAlign.left : TextAlign.center,
      ),
    );
  }
}
