import 'package:flutter/material.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'icon': Icons.dashboard, 'label': 'Dashboard'},
      {'icon': Icons.factory, 'label': 'Production'},
      {'icon': Icons.local_shipping, 'label': 'Supply Chain'},
      {'icon': Icons.people, 'label': 'Human Resources'},
      {'icon': Icons.warehouse, 'label': 'Warehouse'},
      {'icon': Icons.grass, 'label': 'Fields'},
      {'icon': Icons.account_tree_rounded, 'label': 'Pipeline'},
    ];

    const primaryBlue = Color(0xFF1B4B8C);

    return Container(
      width: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryBlue, Color(0xFF0D3A6B)],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.spa, color: primaryBlue, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Irostech',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = selectedIndex == index;
            return InkWell(
              onTap: () => onIndexChanged(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(item['icon'] as IconData,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
