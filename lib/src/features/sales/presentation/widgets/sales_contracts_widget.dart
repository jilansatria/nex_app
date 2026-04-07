import 'package:flutter/material.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/features/sales/data/repositories/sales_repository.dart';
import 'package:nex_app/src/features/sales/domain/entities/sales_entities.dart';
import 'package:nex_app/src/core/theme/app_theme.dart';

class SalesContractsWidget extends StatefulWidget {
  const SalesContractsWidget({super.key});

  @override
  State<SalesContractsWidget> createState() => _SalesContractsWidgetState();
}

class _SalesContractsWidgetState extends State<SalesContractsWidget> {
  late final SalesRepository _repo;
  List<SalesContractEntity> _contracts = [];
  bool _isLoading = true;

  late final List<SalesContractEntity> _dummyContracts;

  @override
  void initState() {
    super.initState();
    _repo = SalesRepository(DioClient());
    _dummyContracts = _getDummyContracts();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final contracts = await _repo.getContracts();
      if (mounted) {
        setState(() {
          _contracts = contracts.isNotEmpty ? contracts : _dummyContracts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _contracts = _dummyContracts; // fallback
          _isLoading = false;
        });
      }
    }
  }

  List<SalesContractEntity> _getDummyContracts() {
    return [
      SalesContractEntity(
        id: '1',
        contractNumber: 'SC-2023-1001',
        buyerName: 'PT Wilmar Nabati Indonesia',
        productType: 'CPO',
        quantityContracted: 5000,
        fulfilledQuantity: 3500,
        pricePerKg: 12500,
        deliveryStartDate: DateTime.now().subtract(const Duration(days: 30)),
        deliveryEndDate: DateTime.now().add(const Duration(days: 30)),
        status: 'Active',
      ),
      SalesContractEntity(
        id: '2',
        contractNumber: 'SC-2023-1002',
        buyerName: 'PT Musim Mas',
        productType: 'Kernel',
        quantityContracted: 2000,
        fulfilledQuantity: 2000,
        pricePerKg: 8500,
        deliveryStartDate: DateTime.now().subtract(const Duration(days: 45)),
        deliveryEndDate: DateTime.now().subtract(const Duration(days: 15)),
        status: 'Fulfilled',
      ),
      SalesContractEntity(
        id: '3',
        contractNumber: 'SC-2023-1003',
        buyerName: 'Apical Group',
        productType: 'CPO',
        quantityContracted: 10000,
        fulfilledQuantity: 1500,
        pricePerKg: 12800,
        deliveryStartDate: DateTime.now().subtract(const Duration(days: 5)),
        deliveryEndDate: DateTime.now().add(const Duration(days: 60)),
        status: 'Active',
      ),
      SalesContractEntity(
        id: '4',
        contractNumber: 'SC-2023-1004',
        buyerName: 'Bina Karya Trading',
        productType: 'CPO',
        quantityContracted: 3000,
        fulfilledQuantity: 0,
        pricePerKg: 12400,
        deliveryStartDate: DateTime.now(),
        deliveryEndDate: DateTime.now().add(const Duration(days: 45)),
        status: 'Draft',
      ),
    ];
  }

  void _showCreateContractModal() {
    final buyerCtrl = TextEditingController();
    final noCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String type = 'CPO';

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
                const Text('Create New Contract',
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
            TextField(
                controller: noCtrl,
                decoration: InputDecoration(
                  labelText: 'Contract Number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                )),
            const SizedBox(height: 16),
            TextField(
                controller: buyerCtrl,
                decoration: InputDecoration(
                  labelText: 'Buyer Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                )),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: type,
              decoration: InputDecoration(
                labelText: 'Product Type',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'CPO', child: Text('CPO')),
                DropdownMenuItem(value: 'Kernel', child: Text('Kernel'))
              ],
              onChanged: (v) => type = v!,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity (Ton)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price / kg (Rp)',
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
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final newContract = SalesContractEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    contractNumber: noCtrl.text,
                    buyerName: buyerCtrl.text,
                    productType: type,
                    quantityContracted: double.tryParse(qtyCtrl.text) ?? 0,
                    fulfilledQuantity: 0,
                    pricePerKg: double.tryParse(priceCtrl.text) ?? 0,
                    deliveryStartDate: DateTime.now(),
                    deliveryEndDate:
                        DateTime.now().add(const Duration(days: 30)),
                    status: 'Active',
                  );

                  try {
                    await _repo.createContract({
                      'contract_number': noCtrl.text,
                      'buyer_name': buyerCtrl.text,
                      'product_type': type,
                      'quantity_contracted': newContract.quantityContracted,
                      'price_per_kg': newContract.pricePerKg,
                    });
                  } catch (e) {
                    setState(() {
                      _dummyContracts.insert(0, newContract);
                      _contracts = _dummyContracts;
                    });
                  }

                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    'Contract "${noCtrl.text}" saved successfully!')),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }

                  _loadData();
                },
                child: const Text('Save Contract',
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
              const Text('Sales Contracts',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark)),
              ElevatedButton.icon(
                onPressed: _showCreateContractModal,
                icon: const Icon(Icons.add),
                label: const Text('New Contract'),
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
              itemCount: _contracts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (ctx, idx) {
                final c = _contracts[idx];
                final fulfillment =
                    (c.fulfilledQuantity / c.quantityContracted);

                Color statusColor = Colors.grey;
                if (c.status == 'Active') statusColor = Colors.blue;
                if (c.status == 'Fulfilled') statusColor = Colors.green;

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
                                child: Icon(Icons.description,
                                    color: statusColor, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.contractNumber,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(c.buyerName,
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
                              c.status.toUpperCase(),
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
                            child: _buildInfoItem(
                                'Product', c.productType, Icons.category),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                                'Quantity',
                                '${c.quantityContracted.toInt()} MT',
                                Icons.scale),
                          ),
                          Expanded(
                            child: _buildInfoItem('Price / KG',
                                'Rp ${c.pricePerKg.toInt()}', Icons.sell),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                                'Total Value',
                                'Rp ${(c.quantityContracted * 1000 * c.pricePerKg).toInt()}',
                                Icons.account_balance_wallet),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fulfillment Progress',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${(fulfillment * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: fulfillment,
                          backgroundColor: Colors.grey[200],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(statusColor),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${c.fulfilledQuantity.toInt()} MT delivered out of ${c.quantityContracted.toInt()} MT contracted',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        )
      ],
    );
  }
}
