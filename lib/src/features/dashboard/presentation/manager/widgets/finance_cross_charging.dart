import 'package:flutter/material.dart';

class FinanceCrossCharging extends StatelessWidget {
  const FinanceCrossCharging({super.key});

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
                'Cross Charging Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: 'This Month',
                items: ['This Month', 'Last Month', 'This Quarter']
                    .map((period) => DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          Table(
            border: TableBorder.all(color: Colors.grey[300]!, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1),
            },
            children: [
              _buildHeaderRow(),
              _buildDataRow('Estate → Mill', 'Transport FFB', 'Rp 45.2M',
                  'Approved', Colors.green),
              _buildDataRow('Mill → Sales', 'CPO Transfer', 'Rp 325.5M',
                  'Approved', Colors.green),
              _buildDataRow('Finance → All', 'Admin Support', 'Rp 18.7M',
                  'Pending', Colors.orange),
              _buildDataRow('IT → All', 'System Maintenance', 'Rp 12.3M',
                  'Pending', Colors.orange),
              _buildDataRow('HR → Estate', 'Recruitment', 'Rp 8.5M', 'Approved',
                  Colors.green),
              _buildTotalRow(),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCards(),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.blue[50]!),
      children: [
        _buildHeaderCell('Transaction'),
        _buildHeaderCell('Description'),
        _buildHeaderCell('Amount'),
        _buildHeaderCell('Status'),
        _buildHeaderCell('Action'),
      ],
    );
  }

  TableRow _buildDataRow(String transaction, String description, String amount,
      String status, Color statusColor) {
    return TableRow(
      children: [
        _buildDataCell(transaction, isLeft: true),
        _buildDataCell(description, isLeft: true),
        _buildDataCell(amount, isBold: true),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: const Icon(Icons.visibility, size: 16),
            onPressed: () {},
            tooltip: 'View Details',
          ),
        ),
      ],
    );
  }

  TableRow _buildTotalRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.blue[100]!),
      children: [
        _buildDataCell('TOTAL', isBold: true, isLeft: true),
        _buildDataCell('', isLeft: true),
        _buildDataCell('Rp 410.2M', isBold: true),
        _buildDataCell(''),
        _buildDataCell(''),
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

  Widget _buildDataCell(String text,
      {bool isBold = false, bool isLeft = false}) {
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

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
              'Total Approved', 'Rp 379.2M', Colors.green, Icons.check_circle),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard('Pending Approval', 'Rp 31.0M',
              Colors.orange, Icons.pending_actions),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
              'Transactions', '5', Colors.blue, Icons.swap_horiz),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
