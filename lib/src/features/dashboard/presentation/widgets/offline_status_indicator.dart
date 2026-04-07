import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/services/network_service.dart';
import '../../data/services/offline_sync_service.dart';

/// Widget untuk menampilkan status koneksi dan sinkronisasi
class OfflineStatusIndicator extends StatefulWidget {
  final OfflineSyncService syncService;

  const OfflineStatusIndicator({super.key, required this.syncService});

  @override
  State<OfflineStatusIndicator> createState() => _OfflineStatusIndicatorState();
}

class _OfflineStatusIndicatorState extends State<OfflineStatusIndicator> {
  final _networkService = NetworkService();
  bool _isOnline = true;
  SyncStatus? _syncStatus;

  @override
  void initState() {
    super.initState();
    _initializeStatus();
    _listenToNetworkChanges();
  }

  Future<void> _initializeStatus() async {
    final online = await _networkService.checkConnection();
    final status = widget.syncService.getSyncStatus();

    if (mounted) {
      setState(() {
        _isOnline = online;
        _syncStatus = status;
      });
    }
  }

  void _listenToNetworkChanges() {
    _networkService.onConnectivityChanged.listen((results) {
      final isOnline = results.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet,
      );
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });

    // Update sync status setiap 10 detik
    Stream.periodic(const Duration(seconds: 10)).listen((_) {
      if (mounted) {
        setState(() {
          _syncStatus = widget.syncService.getSyncStatus();
        });
      }
    });
  }

  Color _getStatusColor() {
    if (!_isOnline) return Colors.red;
    if (_syncStatus?.isSyncing ?? false) return Colors.blue;
    if (_syncStatus?.hasPendingData ?? false) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon() {
    if (!_isOnline) return Icons.cloud_off;
    if (_syncStatus?.isSyncing ?? false) return Icons.sync;
    if (_syncStatus?.hasPendingData ?? false) return Icons.cloud_upload;
    return Icons.cloud_done;
  }

  String _getStatusText() {
    if (!_isOnline) return 'Offline Mode';
    if (_syncStatus?.isSyncing ?? false) return 'Syncing...';
    if (_syncStatus?.hasPendingData ?? false) {
      return '${_syncStatus!.pendingCount} pending';
    }
    return 'All synced';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSyncDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getStatusColor(), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getStatusIcon(), size: 16, color: _getStatusColor()),
            const SizedBox(width: 6),
            Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => OfflineSyncDialog(
        syncService: widget.syncService,
        isOnline: _isOnline,
        syncStatus: _syncStatus,
      ),
    );
  }
}

/// Dialog untuk menampilkan detail status sync dan action
class OfflineSyncDialog extends StatefulWidget {
  final OfflineSyncService syncService;
  final bool isOnline;
  final SyncStatus? syncStatus;

  const OfflineSyncDialog({
    super.key,
    required this.syncService,
    required this.isOnline,
    required this.syncStatus,
  });

  @override
  State<OfflineSyncDialog> createState() => _OfflineSyncDialogState();
}

class _OfflineSyncDialogState extends State<OfflineSyncDialog> {
  bool _isSyncing = false;
  String? _syncMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: widget.isOnline ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          const Text('Sync Status'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'Connection',
            widget.isOnline ? 'Online' : 'Offline',
            widget.isOnline ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Pending Data',
            '${widget.syncStatus?.pendingCount ?? 0} items',
            widget.syncStatus?.hasPendingData ?? false
                ? Colors.orange
                : Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Status',
            widget.syncStatus?.statusMessage ?? 'Unknown',
            Colors.blue,
          ),
          if (_syncMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_syncMessage!, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (widget.isOnline && (widget.syncStatus?.hasPendingData ?? false))
          ElevatedButton(
            onPressed: _isSyncing ? null : () => _handleManualSync(),
            child: _isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sync Now'),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }

  Future<void> _handleManualSync() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = 'Starting sync...';
    });

    try {
      final result = await widget.syncService.forceSyncNow();

      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncMessage = result.message;
        });

        // Close dialog after showing result
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: result.success ? Colors.green : Colors.red,
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncMessage = 'Error: $e';
        });
      }
    }
  }
}
