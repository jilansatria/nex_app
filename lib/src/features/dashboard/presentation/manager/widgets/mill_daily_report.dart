import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MillDailyReport extends StatelessWidget {
  const MillDailyReport({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm');
    final currentShift = _getCurrentShift();

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Production Report',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Updated: ${timeFormat.format(now)} | Shift: $currentShift',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () {},
                    tooltip: 'Refresh Data',
                  ),
                  IconButton(
                    icon: const Icon(Icons.print, size: 20),
                    onPressed: () {},
                    tooltip: 'Print Report',
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
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
              4: FlexColumnWidth(1.5),
            },
            children: [
              _buildHeaderRow(),
              _buildDataRow('08:00 - 16:00', '0 Ton', '0 Ton', '0 Ton',
                  '0% / 0%', Colors.grey),
              _buildDataRow('16:00 - 00:00', '0 Ton', '0 Ton', '0 Ton',
                  '0% / 0%', Colors.grey),
              _buildDataRow('00:00 - 08:00', '0 Ton', '0 Ton', '0 Ton',
                  '0% / 0%', Colors.grey),
              _buildTotalRow(),
            ],
          ),
          const SizedBox(height: 20),
          _buildProductionNotes(),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.orange[50]!),
      children: [
        _buildHeaderCell('Shift Time'),
        _buildHeaderCell('FFB Processed'),
        _buildHeaderCell('CPO Produced'),
        _buildHeaderCell('Kernel'),
        _buildHeaderCell('OER / KER'),
      ],
    );
  }

  TableRow _buildDataRow(String shift, String ffb, String cpo, String kernel,
      String rates, Color statusColor) {
    return TableRow(
      children: [
        _buildDataCell(shift, isLeft: true),
        _buildDataCell(ffb),
        _buildDataCell(cpo),
        _buildDataCell(kernel),
        _buildDataCell(rates, color: statusColor),
      ],
    );
  }

  TableRow _buildTotalRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.orange[100]!),
      children: [
        _buildDataCell('TOTAL', isBold: true, isLeft: true),
        _buildDataCell('0 Ton', isBold: true),
        _buildDataCell('0 Ton', isBold: true),
        _buildDataCell('0 Ton', isBold: true),
        _buildDataCell('0% / 0%', isBold: true, color: Colors.grey),
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
      {bool isBold = false, bool isLeft = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
          color: color ?? Colors.black87,
        ),
        textAlign: isLeft ? TextAlign.left : TextAlign.center,
      ),
    );
  }

  Widget _buildProductionNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50]!,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]!),
              const SizedBox(width: 8),
              Text(
                'Production Notes',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.blue[900]!),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildNoteItem(
              '• Clarifier Tank under maintenance (Shift 3) - No impact on production'),
          _buildNoteItem('• OER target achieved: 23.5% (Target: 24.0%)'),
          _buildNoteItem('• Sterilizer pressure optimal throughout all shifts'),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        note,
        style: TextStyle(color: Colors.blue[800]!, fontSize: 11),
      ),
    );
  }

  String _getCurrentShift() {
    final hour = DateTime.now().hour;
    if (hour >= 8 && hour < 16) return 'Shift 1';
    if (hour >= 16 || hour < 0) return 'Shift 2';
    return 'Shift 3';
  }
}
