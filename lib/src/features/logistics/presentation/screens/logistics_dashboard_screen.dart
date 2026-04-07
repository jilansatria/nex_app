import 'package:flutter/material.dart';
import '../../data/repositories/logistics_repository_impl.dart';
import '../../domain/entities/delivery_order_entity.dart';
import 'package:nex_app/src/core/network/dio_client.dart';

class LogisticsOverviewWidget extends StatefulWidget {
  const LogisticsOverviewWidget({super.key});

  @override
  State<LogisticsOverviewWidget> createState() =>
      _LogisticsOverviewWidgetState();
}

class _LogisticsOverviewWidgetState extends State<LogisticsOverviewWidget> {
  final _repository = LogisticsRepositoryImpl(DioClient());
  List<DeliveryOrderEntity> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData(); // Initial load
  }

  Future<void> _loadData() async {
    try {
      final list = await _repository.getDeliveryOrders();
      if (mounted) {
        setState(() {
          _orders = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCreateDialog() {
    final _formKey = GlobalKey<FormState>();
    final _doNumberController = TextEditingController();
    final _driverController = TextEditingController();
    final _licensePlateController = TextEditingController();
    final _tonnageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Delivery Order'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _doNumberController,
                  decoration: const InputDecoration(labelText: 'DO Number'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _driverController,
                  decoration: const InputDecoration(labelText: 'Driver Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _licensePlateController,
                  decoration: const InputDecoration(labelText: 'License Plate'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _tonnageController,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Tonnage (Ton)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final success = await _repository.createDeliveryOrder({
                  "do_number": _doNumberController.text,
                  "driver_name": _driverController.text,
                  "vehicle_plate": _licensePlateController.text,
                  "estimated_tonnage":
                      double.tryParse(_tonnageController.text) ?? 0,
                  "product_type": "TBS",
                });
                if (success && mounted) {
                  Navigator.pop(context);
                  _loadData(); // Refresh list
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, DeliveryOrderEntity order) {
    bool isProcessing = false;
    final _weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('DO #${order.doNumber}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Status', order.status),
                  _buildDetailRow('Driver', order.driverName),
                  _buildDetailRow('Vehicle', order.vehiclePlate),
                  _buildDetailRow(
                    'Est. Tonnage',
                    '${order.estimatedTonnage} Ton',
                  ),
                  if (order.weighbridgeWeight != null)
                    _buildDetailRow(
                      'Received Weight',
                      '${order.weighbridgeWeight} Ton',
                    ),
                  if (order.receivedAt != null)
                    _buildDetailRow(
                      'Received At',
                      order.receivedAt!.substring(0, 16),
                    ),

                  if (order.status != 'Received' &&
                      order.status != 'Rejected') ...[
                    const Divider(height: 32),
                    const Text(
                      'Mill Weighbridge Action',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Actual Weight (Ton)',
                        border: OutlineInputBorder(),
                        suffixText: 'Ton',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                if (order.status != 'Received' && order.status != 'Rejected')
                  ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            if (_weightController.text.isEmpty) return;

                            setDialogState(() => isProcessing = true);

                            final weight = double.tryParse(
                              _weightController.text,
                            );
                            if (weight != null) {
                              final success = await _repository.receiveOrder(
                                order.id,
                                weight,
                              );
                              if (success && mounted) {
                                Navigator.pop(context);
                                _loadData();
                              }
                            }

                            setDialogState(() => isProcessing = false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Receive Order'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logistics & Delivery',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage DOs and shipment tracking',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('New DO'),
                style: ElevatedButton.styleFrom(
                  // Uses theme default, but we can override if needed
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Stats Row (Optional improvement)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildStatChip(
                'Total DOs',
                '${_orders.length}',
                Colors.blue,
                Icons.assignment,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                'Active',
                '${_orders.where((o) => o.status == "Created").length}',
                Colors.orange,
                Icons.local_shipping,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Delivery Orders found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a new DO to get started',
                        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  itemCount: _orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final isCreated = order.status == 'Created';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => _showDetailDialog(context, order),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    order.status,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.local_shipping_outlined,
                                  color: _getStatusColor(order.status),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          order.doNumber,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            order.vehiclePlate,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Driver: ${order.driverName} • Est: ${order.estimatedTonnage} Ton',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        order.status,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      order.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(order.status),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order.issuedAt.substring(
                                      0,
                                      10,
                                    ), // Simple date truncate
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatChip(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Created':
        return Colors.blue[600]!;
      case 'Shipped':
        return Colors.orange[600]!;
      case 'Received':
        return Colors.green[600]!;
      case 'Rejected':
        return Colors.red[600]!;
      default:
        return Colors.grey;
    }
  }
}
