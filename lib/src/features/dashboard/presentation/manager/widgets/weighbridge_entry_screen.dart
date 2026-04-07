import 'package:flutter/material.dart';
import 'package:nex_app/src/features/dashboard/data/repositories/mill_repository.dart';

/// Weighbridge Entry Screen — Input timbangan masuk/keluar pabrik.
/// Uses a step-based flow: Select Mill → Weigh In → Weigh Out.
class WeighbridgeEntryScreen extends StatefulWidget {
  const WeighbridgeEntryScreen({super.key});

  @override
  State<WeighbridgeEntryScreen> createState() => _WeighbridgeEntryScreenState();
}

class _WeighbridgeEntryScreenState extends State<WeighbridgeEntryScreen> {
  final MillRepository _millRepo = MillRepository();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _vehiclePlateCtrl = TextEditingController();
  final _transporterCtrl = TextEditingController();
  final _estateOriginCtrl = TextEditingController();
  final _weightInCtrl = TextEditingController();
  final _weightOutCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // State
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _mills = [];
  String? _selectedMillId;
  Map<String, dynamic>? _weighInResult;

  // Grading
  double _gradingRipe = 0;
  double _gradingUnripe = 0;
  double _gradingOverripe = 0;

  @override
  void initState() {
    super.initState();
    _loadMills();
  }

  Future<void> _loadMills() async {
    setState(() => _isLoading = true);
    try {
      _mills = await _millRepo.getMills();
      if (_mills.isNotEmpty) {
        _selectedMillId = _mills.first['id'];
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitWeighIn() async {
    if (!_formKey.currentState!.validate() || _selectedMillId == null) return;

    setState(() => _isSubmitting = true);
    try {
      final result = await _millRepo.weighIn(
        millId: _selectedMillId!,
        vehiclePlate: _vehiclePlateCtrl.text.trim(),
        weightInKg: double.parse(_weightInCtrl.text),
        transporter: _transporterCtrl.text.isNotEmpty
            ? _transporterCtrl.text
            : null,
        estateOrigin: _estateOriginCtrl.text.isNotEmpty
            ? _estateOriginCtrl.text
            : null,
      );
      setState(() => _weighInResult = result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Weigh In berhasil! Ticket: ${result['ticket_no']}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal submit Weigh In'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitWeighOut() async {
    if (_weighInResult == null || _weightOutCtrl.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final result = await _millRepo.weighOut(
        entryId: _weighInResult!['id'],
        weightOutKg: double.parse(_weightOutCtrl.text),
        gradingRipePct: _gradingRipe,
        gradingUnripePct: _gradingUnripe,
        gradingOverripePct: _gradingOverripe,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      );
      if (mounted) {
        final nettoKg = result['netto_kg'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Weigh Out selesai! Netto: ${(nettoKg as num).toStringAsFixed(0)} kg',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Reset form
        _vehiclePlateCtrl.clear();
        _transporterCtrl.clear();
        _estateOriginCtrl.clear();
        _weightInCtrl.clear();
        _weightOutCtrl.clear();
        _notesCtrl.clear();
        setState(() {
          _weighInResult = null;
          _gradingRipe = 0;
          _gradingUnripe = 0;
          _gradingOverripe = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal submit Weigh Out'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            const Text(
              'Weighbridge Entry',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _weighInResult == null
                  ? 'Step 1: Timbang Masuk (Weigh In)'
                  : 'Step 2: Timbang Keluar (Weigh Out)',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),

            // ── Step 1: Weigh In ──
            if (_weighInResult == null) ...[
              _buildCard(
                title: 'Data Kendaraan',
                children: [
                  // Mill Selection
                  DropdownButtonFormField<String>(
                    value: _selectedMillId,
                    decoration: const InputDecoration(
                      labelText: 'Pabrik *',
                      prefixIcon: Icon(Icons.factory),
                    ),
                    items: _mills.map((m) {
                      return DropdownMenuItem(
                        value: m['id'] as String,
                        child: Text(m['name'] ?? '-'),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedMillId = v),
                    validator: (v) => v == null ? 'Pilih pabrik' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehiclePlateCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Plat Nomor Kendaraan *',
                      prefixIcon: Icon(Icons.local_shipping),
                      hintText: 'Contoh: B 1234 CD',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _transporterCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Supir / Transporter',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _estateOriginCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Asal Kebun',
                      prefixIcon: Icon(Icons.terrain),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _weightInCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Berat Kotor (kg) *',
                      prefixIcon: Icon(Icons.scale),
                      suffixText: 'kg',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (double.tryParse(v) == null) return 'Masukkan angka';
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitWeighIn,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: const Text('Submit Weigh In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            // ── Step 2: Weigh Out ──
            if (_weighInResult != null) ...[
              // Ticket Info
              _buildCard(
                title: 'Ticket: ${_weighInResult!['ticket_no']}',
                color: Colors.green[50],
                children: [
                  _buildInfoRow(
                    'Plat Nomor',
                    _weighInResult!['vehicle_plate'] ?? '-',
                  ),
                  _buildInfoRow(
                    'Berat Masuk',
                    '${_weighInResult!['weight_in_kg']} kg',
                  ),
                  _buildInfoRow('Status', _weighInResult!['status'] ?? '-'),
                ],
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: 'Data Timbang Keluar',
                children: [
                  TextFormField(
                    controller: _weightOutCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Berat Tarra / Kosong (kg) *',
                      prefixIcon: Icon(Icons.scale),
                      suffixText: 'kg',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Grading (%)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _buildSlider(
                    'Buah Masak',
                    _gradingRipe,
                    Colors.green,
                    (v) => setState(() => _gradingRipe = v),
                  ),
                  _buildSlider(
                    'Buah Mentah',
                    _gradingUnripe,
                    Colors.red,
                    (v) => setState(() => _gradingUnripe = v),
                  ),
                  _buildSlider(
                    'Buah Lewat Masak',
                    _gradingOverripe,
                    Colors.orange,
                    (v) => setState(() => _gradingOverripe = v),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitWeighOut,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: const Text('Complete Weigh Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _vehiclePlateCtrl.dispose();
    _transporterCtrl.dispose();
    _estateOriginCtrl.dispose();
    _weightInCtrl.dispose();
    _weightOutCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}
