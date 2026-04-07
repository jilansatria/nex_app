import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/features/dashboard/data/production_repository.dart';

class HarvestEntryScreen extends StatefulWidget {
  const HarvestEntryScreen({super.key});

  @override
  State<HarvestEntryScreen> createState() => _HarvestEntryScreenState();
}

class _HarvestEntryScreenState extends State<HarvestEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late ProductionRepository _repository;

  List<dynamic> _estates = [];
  List<dynamic> _blocks = [];

  String? _selectedEstateId;
  String? _selectedBlockId;
  final _quantityController = TextEditingController();
  String _selectedUnit = 'Tons';
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _isTokenExpired = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = ProductionRepository(DioClient());
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
      _isTokenExpired = false;
    });
    try {
      final estates = await _repository.getEstates();
      if (estates.isEmpty) {
        setState(() {
          _errorMessage = 'Tidak ada data kebun tersedia.';
          _isInitialLoading = false;
        });
      } else {
        setState(() {
          _estates = estates;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      // Check if it's a 401/403 token error
      bool tokenError = false;
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          tokenError = true;
        }
      }
      setState(() {
        _isTokenExpired = tokenError;
        _errorMessage = tokenError
            ? 'Sesi Anda telah berakhir. Silakan login ulang.'
            : 'Gagal memuat data: $e';
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('role');
    if (mounted) {
      context.go('/login');
    }
  }

  Future<void> _loadBlocks(String estateId) async {
    setState(() {
      _blocks = [];
      _selectedBlockId = null;
    });
    try {
      final blocks = await _repository.getBlocks(estateId);
      setState(() {
        _blocks = blocks;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data blok: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedBlockId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await _repository.submitHarvest(
        blockId: _selectedBlockId!,
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data panen berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        _quantityController.clear();
        setState(() {
          _selectedBlockId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengirim data: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isTokenExpired ? Icons.lock_outline : Icons.error_outline,
                  size: 60,
                  color: _isTokenExpired ? Colors.orange : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _isTokenExpired ? 'Sesi Berakhir' : 'Terjadi Kesalahan',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                if (_isTokenExpired)
                  ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.login),
                    label: const Text('Login Ulang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _loadInitialData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Hasil Panen'),
        backgroundColor: const Color(0xFF0D1B3E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Lokasi Panen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Estate Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kebun (Estate)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.terrain),
                ),
                value: _selectedEstateId,
                items: _estates.map((e) {
                  return DropdownMenuItem<String>(
                    value: e['id']?.toString(),
                    child: Text(e['name']?.toString() ?? 'Unnamed Estate'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedEstateId = val);
                  if (val != null) _loadBlocks(val);
                },
              ),
              const SizedBox(height: 16),

              // Block Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Blok',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.grid_view),
                ),
                value: _selectedBlockId,
                disabledHint: const Text('Pilih kebun terlebih dahulu'),
                items: _blocks.map((b) {
                  return DropdownMenuItem<String>(
                    value: b['id']?.toString(),
                    child: Text(
                      'Blok ${b['code'] ?? '??'} (${b['tree_count'] ?? 0} pohon)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: _selectedEstateId == null
                    ? null
                    : (val) {
                        setState(() => _selectedBlockId = val);
                      },
              ),

              const SizedBox(height: 32),
              const Text(
                'Hasil Panen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Satuan',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 16,
                        ),
                      ),
                      items: ['Tons', 'Kg', 'Janjang'].map((u) {
                        return DropdownMenuItem(
                          value: u,
                          child: Text(u, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedUnit = val!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SIMPAN DATA PANEN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
