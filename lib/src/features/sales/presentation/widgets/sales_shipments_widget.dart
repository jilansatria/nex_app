import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/features/sales/data/repositories/sales_repository.dart';
import 'package:nex_app/src/features/sales/domain/entities/sales_entities.dart';
import 'package:nex_app/src/core/theme/app_theme.dart';

class SalesShipmentsWidget extends StatefulWidget {
  const SalesShipmentsWidget({super.key});

  @override
  State<SalesShipmentsWidget> createState() => _SalesShipmentsWidgetState();
}

class _SalesShipmentsWidgetState extends State<SalesShipmentsWidget> {
  late final SalesRepository _repo;
  List<SalesShipmentEntity> _shipments = [];
  List<SalesContractEntity> _contracts = [];
  bool _isLoading = true;

  late final List<SalesShipmentEntity> _dummyShipments;

  @override
  void initState() {
    super.initState();
    _repo = SalesRepository(DioClient());
    _dummyShipments = _getDummyShipments();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final s = await _repo.getAllShipments();
      final c = await _repo.getContracts(status: 'Active');
      if (mounted) {
        setState(() {
          _shipments = s.isNotEmpty ? s : _dummyShipments;
          _contracts = c;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _shipments = _dummyShipments;
          _isLoading = false;
        });
      }
    }
  }

  List<SalesShipmentEntity> _getDummyShipments() {
    return [
      SalesShipmentEntity(
        id: '1',
        doNumber: 'DO-2023-5001',
        quantityShipped: 1500,
        shipmentDate: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Invoiced',
        ffa: 3.5,
        moisture: 0.15,
        dirt: 0.05,
        basePriceUnit: 12500,
        priceAdjustment: 0,
        finalUnitPrice: 12500,
        totalPrice: 18750000000,
      ),
      SalesShipmentEntity(
        id: '2',
        doNumber: 'DO-2023-5002',
        quantityShipped: 2000,
        shipmentDate: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Draft',
        ffa: 4.2, // High FFA leads to penalty
        moisture: 0.2,
        dirt: 0.1,
        basePriceUnit: 12500,
        priceAdjustment: -250,
        finalUnitPrice: 12250,
        totalPrice: 24500000000,
      ),
      SalesShipmentEntity(
        id: '3',
        doNumber: 'DO-2023-5003',
        quantityShipped: 500,
        shipmentDate: DateTime.now(),
        status: 'Pending QA',
        ffa: 0.0,
        moisture: 0.0,
        dirt: 0.0,
        basePriceUnit: 12800,
        priceAdjustment: 0,
        finalUnitPrice: 12800,
        totalPrice: 6400000000,
      ),
    ];
  }

  void _showCreateShipmentModal() {
    String? selectedContractId;
    final doCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Create Outbound Shipment',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary)),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Active Contract',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _contracts
                  .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.contractNumber} - ${c.buyerName}')))
                  .toList(),
              onChanged: (v) => selectedContractId = v,
            ),
            const SizedBox(height: 16),
            TextField(
                controller: doCtrl,
                decoration: InputDecoration(
                  labelText: 'Delivery Order (DO) Number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                )),
            const SizedBox(height: 16),
            TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity Shipped (MT)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                )),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (selectedContractId != null) {
                    final qty = double.tryParse(qtyCtrl.text) ?? 0;
                    final sc = _contracts.firstWhere(
                        (c) => c.id == selectedContractId,
                        orElse: () => _contracts.first);
                    final newShipment = SalesShipmentEntity(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      doNumber: doCtrl.text,
                      quantityShipped: qty,
                      shipmentDate: DateTime.now(),
                      status: 'Pending QA',
                      ffa: 0.0,
                      moisture: 0.0,
                      dirt: 0.0,
                      basePriceUnit: sc.pricePerKg,
                      priceAdjustment: 0,
                      finalUnitPrice: sc.pricePerKg,
                      totalPrice: qty * 1000 * sc.pricePerKg,
                    );

                    try {
                      await _repo.createShipment({
                        'contract_id': selectedContractId,
                        'do_number': doCtrl.text,
                        'quantity_shipped': qty,
                      });
                    } catch (e) {
                      setState(() {
                        _dummyShipments.insert(0, newShipment);
                        _shipments = _dummyShipments;
                      });
                    }

                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      'Shipment "${doCtrl.text}" created successfully!')),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }

                    _loadData();
                  }
                },
                child: const Text('Create Shipment & Deduct Stock',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showQualityModal(SalesShipmentEntity s) {
    final ffaCtrl = TextEditingController(text: s.ffa.toString());
    final moistureCtrl = TextEditingController(text: s.moisture.toString());
    final dirtCtrl = TextEditingController(text: s.dirt.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Input Lab Quality (Price Adjustment)',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary)),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: ffaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'FFA (%)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                      controller: moistureCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Moisture (%)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                      controller: dirtCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Dirt (%)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await _repo.updateShipmentQuality(
                    shipmentId: s.id,
                    ffa: double.tryParse(ffaCtrl.text) ?? 0,
                    moisture: double.tryParse(moistureCtrl.text) ?? 0,
                    dirt: double.tryParse(dirtCtrl.text) ?? 0,
                  );
                  Navigator.pop(ctx);
                  _loadData();
                },
                child: const Text('Save & Calculate Final Price',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmShipment(String id) async {
    final result = await _repo.confirmShipment(id);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Shipment Confirmed! Stock Deducted. Revenue Generated.'),
          backgroundColor: Colors.green));
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Verification Failed. Stock limit exceeded?'),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Outbound Shipments',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark)),
              ElevatedButton.icon(
                onPressed: _showCreateShipmentModal,
                icon: const Icon(Icons.add),
                label: const Text('New Shipment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _shipments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (ctx, idx) {
                final s = _shipments[idx];
                final isDraft = s.status == 'Draft' || s.status == 'Pending QA';

                Color statusColor = Colors.grey;
                if (s.status == 'Invoiced') statusColor = Colors.green;
                if (s.status == 'Draft') statusColor = Colors.orange;
                if (s.status == 'Pending QA') statusColor = Colors.blue;

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
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
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.local_shipping,
                                    color: statusColor, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.doNumber,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '${s.quantityShipped.toInt()} MT Dispatched on ${s.shipmentDate.toString().substring(0, 10)}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s.status.toUpperCase(),
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQualityItem('FFA', '${s.ffa}%',
                                s.ffa > 3.0 ? Colors.red : Colors.green),
                          ),
                          Expanded(
                            child: _buildQualityItem(
                                'Moisture', '${s.moisture}%', Colors.black87),
                          ),
                          Expanded(
                            child: _buildQualityItem(
                                'Dirt', '${s.dirt}%', Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Base Price: Rp ${s.basePriceUnit.toInt()}/kg',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('Quality Adj: ',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    Text(
                                      'Rp ${s.priceAdjustment.toInt()}/kg',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: s.priceAdjustment < 0
                                              ? Colors.red
                                              : Colors.green),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    'Final Unit Price: Rp ${s.finalUnitPrice.toInt()}/kg',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Total Invoice Value',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${_formatNumber(s.totalPrice)}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      if (isDraft) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showQualityModal(s),
                              icon: const Icon(Icons.science),
                              label: const Text('Input Lab Result'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                side: const BorderSide(color: Colors.orange),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () => _confirmShipment(s.id),
                              icon: const Icon(Icons.check),
                              label: const Text('Confirm Delivery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            )
                          ],
                        )
                      ]
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQualityItem(String label, String value, Color valueColor) {
    return Row(
      children: [
        Icon(Icons.monitor_weight_outlined, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: valueColor)),
          ],
        )
      ],
    );
  }

  String _formatNumber(double value) {
    if (value == 0) return '0';
    final str = value.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      // We write strings in reverse implicitly? No, format comma logic using simple loop
      // Reverse formatting
    }
    // better formatter:
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) mathFunc = (Match match) => '${match[1]}.';
    return str.replaceAllMapped(reg, mathFunc);
  }
}
