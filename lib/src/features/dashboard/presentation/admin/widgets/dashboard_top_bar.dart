import 'package:flutter/material.dart';
import '../../widgets/offline_status_indicator.dart';
import '../../../data/services/offline_sync_service.dart';

class DashboardTopBar extends StatelessWidget {
  final int selectedIndex;

  const DashboardTopBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    String title = 'Dashboard';
    if (selectedIndex == 1) title = 'Production';
    if (selectedIndex == 4) title = 'Warehouse';

    const primaryBlue = Color(0xFF1B4B8C);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: primaryBlue),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          const Text(
            'Nama Pengguna',
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
          const SizedBox(width: 16),
          OfflineStatusIndicator(syncService: OfflineSyncService()),
        ],
      ),
    );
  }
}
