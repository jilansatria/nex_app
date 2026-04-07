import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

/// Self-contained Supply Chain widget combining Inventory Control
/// and Procurement Tracking sections.
/// Fetches data from /dashboard/supply-chain.
class AdminSupplyChainWidget extends StatefulWidget {
  const AdminSupplyChainWidget({super.key});

  @override
  State<AdminSupplyChainWidget> createState() => _AdminSupplyChainWidgetState();
}

class _AdminSupplyChainWidgetState extends State<AdminSupplyChainWidget> {
  static const _primaryBlue = Color(0xFF1B4B8C);

  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  List<Map<String, dynamic>> _summaryCards = [];
  List<Map<String, dynamic>> _inventoryRows = [];
  Map<String, dynamic> _procurementStatus = {};
  List<Map<String, dynamic>> _procurementRows = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final response = await _dioClient.dio.get(
        '${ApiConstants.dashboard}supply-chain',
      );
      final data = response.data;
      if (mounted) {
        setState(() {
          _summaryCards = _castList(data['summary_cards']);
          _inventoryRows = _castList(data['inventory_rows']);
          _procurementStatus =
              data['procurement_status'] as Map<String, dynamic>? ?? {};
          _procurementRows = _castList(data['procurement_rows']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _castList(dynamic data) {
    return (data as List? ?? []).map((r) => r as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInventorySection(),
        const SizedBox(height: 24),
        _buildProcurementSection(),
      ],
    );
  }

  // ==================== INVENTORY CONTROL ====================
  Widget _buildInventorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory_2, size: 20, color: _primaryBlue),
            const SizedBox(width: 8),
            const Text(
              'Inventory Control',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Pelacakan stok pupuk, solar, dan sparepart secara real-time (FIFO/LIFO)',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // Summary Cards
        Row(
          children: _summaryCards.asMap().entries.map((entry) {
            final i = entry.key;
            final card = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 12 : 0),
                child: _buildSummaryCard(card),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Inventory Table
        _buildInventoryTable(),
      ],
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> card) {
    final colorName = card['color'] ?? 'grey';
    final color = _getColor(colorName);
    final iconName = card['icon'] ?? 'inventory_2';
    final icon = _getIcon(iconName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            card['value'] ?? '0',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card['title'] ?? '-',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            card['subtitle'] ?? '',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Item',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Kategori',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Stok Tersedia',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Metode',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lokasi Gudang',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          if (_inventoryRows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Belum ada data inventori.',
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          else
            ..._inventoryRows.map(_buildInventoryRow),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(Map<String, dynamic> row) {
    final status = row['status'] ?? 'Normal';
    final isLowStock = status == 'Low Stock';
    final method = row['method'] ?? 'FIFO';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row['item'] ?? '-',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              row['category'] ?? '-',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              row['stock'] ?? '-',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: method == 'FIFO'
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                method,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: method == 'FIFO' ? Colors.blue : Colors.purple,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              row['location'] ?? '-',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLowStock
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isLowStock ? Colors.orange : Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROCUREMENT TRACKING ====================
  Widget _buildProcurementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shopping_cart, size: 20, color: _primaryBlue),
            const SizedBox(width: 8),
            const Text(
              'Procurement Tracking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Pemantauan status barang dari pemesanan hingga barang tiba di gudang (GRN)',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // Status Cards
        Row(
          children: [
            _buildProcStatusCard(
              'Pending Order',
              '${_procurementStatus['Pending Order'] ?? 0}',
              Colors.orange,
              Icons.pending_actions,
            ),
            const SizedBox(width: 12),
            _buildProcStatusCard(
              'In Transit',
              '${_procurementStatus['In Transit'] ?? 0}',
              Colors.blue,
              Icons.local_shipping,
            ),
            const SizedBox(width: 12),
            _buildProcStatusCard(
              'Delivered (GRN)',
              '${_procurementStatus['Delivered (GRN)'] ?? 0}',
              Colors.green,
              Icons.check_circle,
            ),
            const SizedBox(width: 12),
            _buildProcStatusCard(
              'Cancelled',
              '${_procurementStatus['Cancelled'] ?? 0}',
              Colors.red,
              Icons.cancel,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Procurement Table
        _buildProcurementTable(),
      ],
    );
  }

  Widget _buildProcStatusCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcurementTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'PO Number',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Item',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Vendor',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Order Date',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'ETA',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          if (_procurementRows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Belum ada data procurement.',
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          else
            ..._procurementRows.map(_buildProcurementRow),
        ],
      ),
    );
  }

  Widget _buildProcurementRow(Map<String, dynamic> row) {
    final status = row['status'] ?? '-';
    Color statusColor;
    switch (status) {
      case 'Pending Order':
        statusColor = Colors.orange;
        break;
      case 'In Transit':
        statusColor = Colors.blue;
        break;
      case 'Delivered (GRN)':
        statusColor = Colors.green;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              row['po_number'] ?? '-',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _primaryBlue,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row['item'] ?? '-',
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              row['vendor'] ?? '-',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              row['order_date'] ?? '-',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              row['eta'] ?? '-',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================
  Color _getColor(String name) {
    switch (name) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'grass':
        return Icons.grass;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'oil_barrel':
        return Icons.oil_barrel;
      case 'build_circle':
        return Icons.build_circle;
      default:
        return Icons.inventory_2;
    }
  }
}
