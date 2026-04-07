import 'package:flutter/material.dart';

class EstateCostTable extends StatelessWidget {
  const EstateCostTable({super.key});

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
                'Operational Cost Breakdown by Block',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: Colors.grey[200]!, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(1.5),
            },
            children: [
              _buildHeaderRow(),
              ..._buildDataRows(),
              _buildTotalRow(),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[100]!),
      children: [
        _buildHeaderCell('Block'),
        _buildHeaderCell('Fertilizer'),
        _buildHeaderCell('Labor'),
        _buildHeaderCell('Maintenance'),
        _buildHeaderCell('Harvesting'),
        _buildHeaderCell('Total'),
      ],
    );
  }

  List<TableRow> _buildDataRows() {
    final blockData = [
      {
        'block': 'Block A-1',
        'fertilizer': 'Rp 45M',
        'labor': 'Rp 32M',
        'maintenance': 'Rp 18M',
        'harvesting': 'Rp 25M',
        'total': 'Rp 120M'
      },
      {
        'block': 'Block A-2',
        'fertilizer': 'Rp 38M',
        'labor': 'Rp 28M',
        'maintenance': 'Rp 15M',
        'harvesting': 'Rp 22M',
        'total': 'Rp 103M'
      },
      {
        'block': 'Block B-1',
        'fertilizer': 'Rp 52M',
        'labor': 'Rp 35M',
        'maintenance': 'Rp 20M',
        'harvesting': 'Rp 28M',
        'total': 'Rp 135M'
      },
      {
        'block': 'Block B-2',
        'fertilizer': 'Rp 41M',
        'labor': 'Rp 30M',
        'maintenance': 'Rp 16M',
        'harvesting': 'Rp 24M',
        'total': 'Rp 111M'
      },
      {
        'block': 'Block C-1',
        'fertilizer': 'Rp 47M',
        'labor': 'Rp 31M',
        'maintenance': 'Rp 17M',
        'harvesting': 'Rp 26M',
        'total': 'Rp 121M'
      },
    ];

    return blockData.map((data) {
      return TableRow(
        children: [
          _buildDataCell(data['block']!, isHighlight: true),
          _buildDataCell(data['fertilizer']!),
          _buildDataCell(data['labor']!),
          _buildDataCell(data['maintenance']!),
          _buildDataCell(data['harvesting']!),
          _buildDataCell(data['total']!, isBold: true),
        ],
      );
    }).toList();
  }

  TableRow _buildTotalRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.green[50]!),
      children: [
        _buildDataCell('TOTAL', isBold: true, isHighlight: true),
        _buildDataCell('Rp 223M', isBold: true),
        _buildDataCell('Rp 156M', isBold: true),
        _buildDataCell('Rp 86M', isBold: true),
        _buildDataCell('Rp 125M', isBold: true),
        _buildDataCell('Rp 590M', isBold: true, color: Colors.green),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text,
      {bool isBold = false, bool isHighlight = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
          color: color ?? (isHighlight ? Colors.black87 : Colors.grey[700]),
        ),
        textAlign: isHighlight ? TextAlign.left : TextAlign.center,
      ),
    );
  }
}
