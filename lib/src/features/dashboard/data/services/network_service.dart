import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:io';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final _connectivity = Connectivity();
  final _statusController =
      StreamController<List<ConnectivityResult>>.broadcast();

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _statusController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Initialize service dan mulai monitoring
  Future<void> initialize() async {
    // Check initial status
    _isConnected = await checkConnection();

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((results) async {
      _statusController.add(results);
      final connected = await checkConnection();
      if (_isConnected != connected) {
        _isConnected = connected;
      }
    });
  }

  /// Check apakah ada koneksi internet yang aktif
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        return false;
      }

      // Verifikasi internet dengan ping host terpercaya
      // atau mencoba request ke endpoint backend seminimal mungkin.
      // Untuk sekarang kita gunakan cara sederhana: mencoba lookup host.
      try {
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 3));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      } on TimeoutException catch (_) {
        return false;
      }
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Get connection type
  Future<String> getConnectionType() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else {
      return 'Offline';
    }
  }

  void dispose() {
    _statusController.close();
  }
}
