import 'package:flutter/material.dart';
import '../widgets/offline_status_indicator.dart';
import '../../data/services/offline_sync_service.dart';
import 'package:nex_app/src/features/dashboard/presentation/user/harvest_entry_screen.dart';
import 'package:nex_app/src/features/dashboard/presentation/user/widgets/user_sidebar.dart';
import 'package:nex_app/src/features/dashboard/presentation/user/widgets/user_top_bar.dart';
import 'package:nex_app/src/features/shared/widgets/adaptive_layout.dart';
import 'package:nex_app/src/features/shared/widgets/bottom_nav_scaffold.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;
  final Color _primaryBlue = const Color(0xFF1B4B8C);
  final OfflineSyncService _syncService = OfflineSyncService();
  final DioClient _dioClient = DioClient();

  // User stats from API
  bool _isLoading = true;
  String _userName = '';
  String _userPosition = '';
  double _totalHarvestToday = 0.0;
  int _entriesToday = 0;
  List<Map<String, dynamic>> _recentHarvests = [];

  // Attendance state
  bool _attendanceLoading = true;
  bool _clockedIn = false;
  bool _clockedOut = false;
  String? _checkInTime;
  String? _checkOutTime;
  String? _attendanceStatus;
  List<Map<String, dynamic>> _attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAttendanceData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);
      final results = await Future.wait([
        _dioClient.dio.get('${ApiConstants.production}user-stats'),
        _dioClient.dio.get('${ApiConstants.production}my-recent?limit=5'),
      ]);

      final statsData = results[0].data;
      final harvestsData = results[1].data as List;

      setState(() {
        _userName = statsData['user_name'] ?? '';
        _userPosition = statsData['user_position'] ?? '-';
        _totalHarvestToday = (statsData['total_harvest_today'] is int)
            ? (statsData['total_harvest_today'] as int).toDouble()
            : (statsData['total_harvest_today'] ?? 0.0);
        _entriesToday = statsData['entries_today'] ?? 0;
        _recentHarvests = harvestsData
            .map((h) => h as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mobileLayout: _buildMobileLayout(),
      tabletLayout:
          _buildDesktopLayout(), // Tablet uses Sidebar but possibly condensed (using Desktop for now as simple step)
      desktopLayout: _buildDesktopLayout(),
    );
  }

  // ==================== MOBILE LAYOUT (Bottom Nav) ====================
  Widget _buildMobileLayout() {
    return BottomNavScaffold(
      selectedIndex: _selectedIndex,
      onIndexChanged: (index) => setState(() => _selectedIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grass_outlined),
          activeIcon: Icon(Icons.grass),
          label: 'Panen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time_outlined),
          activeIcon: Icon(Icons.access_time_filled),
          label: 'Absen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      body: SafeArea(
        child: Column(
          children: [
            // Simplified Top Bar for Mobile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=100',
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budi Santoso',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Pemanen',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  OfflineStatusIndicator(syncService: _syncService),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(child: _buildCurrentPage(isMobile: true)),
          ],
        ),
      ),
    );
  }

  // ==================== DESKTOP LAYOUT (Sidebar) ====================
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          UserSidebar(
            selectedIndex: _selectedIndex,
            onIndexChanged: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(
            child: Column(
              children: [
                UserTopBar(
                  selectedIndex: _selectedIndex,
                  syncService: _syncService,
                ),
                Expanded(child: _buildCurrentPage(isMobile: false)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage({required bool isMobile}) {
    // Shared content logic, but we can inject mobile-specific tweaks if needed
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardPage(isMobile);
      case 1:
        return const HarvestEntryScreen();
      case 2:
        return _buildAttendancePage(isMobile);
      case 3:
        return _buildProfilePage(isMobile);
      default:
        return _buildDashboardPage(isMobile);
    }
  }

  // ==================== DASHBOARD PAGE ====================
  Widget _buildDashboardPage(bool isMobile) {
    final harvestStr = _totalHarvestToday >= 1000
        ? '${(_totalHarvestToday / 1000).toStringAsFixed(1)}k'
        : _totalHarvestToday.toStringAsFixed(2);
    final harvestDisplay = isMobile ? '$harvestStr T' : '$harvestStr Ton';

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting User
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryBlue, const Color(0xFF0D3A6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          isMobile
                              ? 'Target Hari Ini'
                              : 'Selamat Pagi, ${_userName.isNotEmpty ? _userName : "User"}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isMobile)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            harvestDisplay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (!isMobile) ...[
                    const SizedBox(height: 8),
                    Text(
                      _userPosition,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Mobile Quick Action Buttons inside Card
                  if (isMobile)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMobileQuickAction(
                          Icons.qr_code_scanner,
                          'Scan QR',
                          () {},
                        ),
                        _buildMobileQuickAction(
                          Icons.history,
                          'Riwayat',
                          () {},
                        ),
                        _buildMobileQuickAction(Icons.map, 'Peta', () {}),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (isMobile) ...[
              // Mobile Specific Stats (Grid)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Hasil Panen',
                    harvestDisplay,
                    '$_entriesToday entri hari ini',
                    Icons.scale,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Entri Panen',
                    '$_entriesToday',
                    'Hari Ini',
                    Icons.edit_note,
                    Colors.orange,
                  ),
                ],
              ),
            ] else ...[
              // Desktop Stats (Row)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Hasil Panen',
                      harvestDisplay,
                      '$_entriesToday entri hari ini',
                      Icons.scale,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Entri Panen',
                      '$_entriesToday',
                      'Hari Ini',
                      Icons.edit_note,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Riwayat',
                      '${_recentHarvests.length}',
                      'Entri terakhir',
                      Icons.history,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Recent Activity & Notifications
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktivitas Terakhir',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_recentHarvests.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Belum ada aktivitas panen.',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                      else
                        ..._recentHarvests.map((h) {
                          final location = h['location'] ?? '-';
                          final qty = h['quantity'];
                          final unit = h['unit'] ?? '';
                          final date = h['date'] ?? '';
                          final status = h['status'] ?? '';
                          final isHarvested = status == 'Harvested';
                          return _buildActivityItem(
                            'Input Panen - $location',
                            '$qty $unit • $date',
                            '',
                            isHarvested ? Icons.check_circle : Icons.pending,
                            isHarvested ? Colors.green : Colors.orange,
                          );
                        }),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 24),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                          const Row(
                            children: [
                              Icon(Icons.campaign, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Pengumuman',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            'Hati-hati area licin di Blok C-05 karena hujan semalam.',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Rapat pagi besok jam 06:00 di Kantor Divisi.',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileQuickAction(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryBlue),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ==================== ATTENDANCE PAGE ====================
  Future<void> _loadAttendanceData() async {
    try {
      setState(() => _attendanceLoading = true);
      final results = await Future.wait([
        _dioClient.dio.get('${ApiConstants.attendance}today'),
        _dioClient.dio.get('${ApiConstants.attendance}my-history?limit=7'),
      ]);
      final todayData = results[0].data;
      final historyData = results[1].data as List? ?? [];
      setState(() {
        _clockedIn = todayData['clocked_in'] ?? false;
        _clockedOut = todayData['clocked_out'] ?? false;
        _checkInTime = todayData['check_in'];
        _checkOutTime = todayData['check_out'];
        _attendanceStatus = todayData['status'];
        _attendanceHistory = historyData
            .map((h) => h as Map<String, dynamic>)
            .toList();
        _attendanceLoading = false;
      });
    } catch (e) {
      setState(() => _attendanceLoading = false);
    }
  }

  Future<void> _handleClockIn() async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.attendance}clock-in',
      );
      final data = response.data;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Clock in success'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAttendanceData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal absen masuk'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleClockOut() async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.attendance}clock-out',
      );
      final data = response.data;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Clock out success'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAttendanceData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal absen pulang'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAttendancePage(bool isMobile) {
    final now = DateTime.now();
    final dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dateStr =
        '${dayNames[now.weekday - 1]}, ${now.day} ${monthNames[now.month - 1]} ${now.year}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          // Clock In/Out Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_clockedIn && _checkInTime != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Masuk: $_checkInTime',
                    style: TextStyle(color: Colors.green[700], fontSize: 14),
                  ),
                ],
                if (_clockedOut && _checkOutTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Pulang: $_checkOutTime',
                    style: TextStyle(color: Colors.red[700], fontSize: 14),
                  ),
                ],
                const SizedBox(height: 32),
                if (_attendanceLoading)
                  const CircularProgressIndicator()
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildClockButton(
                        'Masuk',
                        Colors.green,
                        !_clockedIn,
                        onTap: _clockedIn ? null : _handleClockIn,
                      ),
                      const SizedBox(width: 40),
                      _buildClockButton(
                        'Pulang',
                        Colors.red,
                        _clockedIn && !_clockedOut,
                        onTap: (_clockedIn && !_clockedOut)
                            ? _handleClockOut
                            : null,
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (_attendanceStatus == 'Terlambat'
                                ? Colors.orange
                                : Colors.blue)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _clockedIn ? Icons.check_circle : Icons.access_time,
                        color: _attendanceStatus == 'Terlambat'
                            ? Colors.orange
                            : Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _clockedIn
                            ? (_attendanceStatus ?? 'Hadir')
                            : 'Belum Absen',
                        style: TextStyle(
                          color: _attendanceStatus == 'Terlambat'
                              ? Colors.orange
                              : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Attendance History
          if (!isMobile) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Kehadiran (7 Hari Terakhir)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            if (_attendanceLoading)
              const Center(child: CircularProgressIndicator())
            else if (_attendanceHistory.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Belum ada riwayat kehadiran.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ..._attendanceHistory.map(
                (h) => _buildAttendanceHistoryItem(
                  h['date'] ?? '-',
                  h['check_in'] ?? '-',
                  h['check_out'] ?? '-',
                  h['status'] ?? '-',
                  h['duration'] ?? '-',
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ==================== PROFILE PAGE ====================
  Widget _buildProfilePage(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=100',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Budi Santoso',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('NIK: EMP-2023-089', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 32),
          _buildProfileItem(Icons.badge, 'Jabatan', 'Pemanen Utama'),
          _buildProfileItem(Icons.business, 'Divisi', 'Kebun Utara - Divisi 2'),
          _buildProfileItem(Icons.phone, 'No. HP', '+62 812 3456 7890'),
          if (!isMobile)
            _buildProfileItem(
              Icons.email,
              'Email',
              'budi.santoso@irostech.com',
            ),
          if (!isMobile)
            _buildProfileItem(Icons.calendar_today, 'Bergabung', '12 Jan 2023'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WIDGET HELPERS ====================

  Widget _buildStatCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          if (time.isNotEmpty)
            Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildClockButton(
    String label,
    Color color,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isActive ? color : color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              Icons.fingerprint,
              size: 40,
              color: isActive ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistoryItem(
    String date,
    String inTime,
    String outTime,
    String status,
    String dur,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (dur != '-')
                  Text(
                    'Durasi: $dur',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inTime,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Masuk',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outTime,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Pulang',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Hadir'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: status == 'Hadir' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100]!,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[700]!),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
