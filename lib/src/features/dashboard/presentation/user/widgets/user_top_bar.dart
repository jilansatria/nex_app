import 'package:flutter/material.dart';
import '../../widgets/offline_status_indicator.dart';
import '../../../data/services/offline_sync_service.dart';

class UserTopBar extends StatelessWidget {
  final int selectedIndex;
  final OfflineSyncService syncService;

  const UserTopBar({
    super.key,
    required this.selectedIndex,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    String title = 'Dashboard';
    if (selectedIndex == 0) title = 'My Dashboard';
    if (selectedIndex == 1) title = 'Harvest Entry (Laporan Panen)';
    if (selectedIndex == 2) title = 'My Attendance';
    if (selectedIndex == 3) title = 'My Profile';

    const primaryBlue = Color(0xFF1B4B8C);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          OfflineStatusIndicator(syncService: syncService),
          const SizedBox(width: 16),
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey[600],
                  size: 24,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
