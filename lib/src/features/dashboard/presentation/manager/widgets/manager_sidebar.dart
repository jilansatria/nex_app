import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final String role; // 'Estate Manager', 'Mill Manager', 'Finance', 'Sales'

  const ManagerSidebar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> menuItems = [];

    // Define menu items based on role
    if (role == 'estate_manager') {
      menuItems = [
        {'icon': Icons.dashboard, 'label': 'Overview'},
        {'icon': Icons.grass, 'label': 'Harvest & Yield'},
        {'icon': Icons.map, 'label': 'Block Map'},
        {'icon': Icons.scale, 'label': 'Weighbridge'},
        {'icon': Icons.local_florist, 'label': 'Nursery Operations'},
      ];
    } else if (role == 'mill_manager') {
      menuItems = [
        {'icon': Icons.dashboard, 'label': 'Overview'},
        {'icon': Icons.factory, 'label': 'Production Logs'},
        {'icon': Icons.settings, 'label': 'Machine Status'},
        {'icon': Icons.bar_chart, 'label': 'OER/KER Report'},
      ];
    } else if (role == 'finance_manager') {
      menuItems = [
        {'icon': Icons.dashboard, 'label': 'Finance Overview'},
        {'icon': Icons.account_balance_wallet, 'label': 'Budget Control'},
        {'icon': Icons.receipt_long, 'label': 'Operating Expenses'},
        {'icon': Icons.people, 'label': 'Payroll & Bonus'},
      ];
    } else if (role == 'sales_officer') {
      menuItems = [
        {'icon': Icons.dashboard, 'label': 'Sales Overview'},
        {'icon': Icons.assignment, 'label': 'Contracts'},
        {'icon': Icons.local_shipping, 'label': 'Shipments'},
      ];
    }

    final primaryColor = _getRoleColor(role);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.spa, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NEX System',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _getRoleLabel(role),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedIndex == index;
                return InkWell(
                  onTap: () => onIndexChanged(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: primaryColor.withValues(alpha: 0.2),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: isSelected ? primaryColor : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            color: isSelected ? primaryColor : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manager User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Online',
                        style: TextStyle(color: Colors.green, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('access_token');
                    await prefs.remove('role');
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: Icon(Icons.logout, size: 20, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'estate_manager':
        return 'Estate Manager';
      case 'mill_manager':
        return 'Mill Manager';
      case 'finance_manager':
        return 'Finance';
      case 'sales_officer':
        return 'Sales';
      default:
        return 'Manager';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'estate_manager':
        return Colors.green;
      case 'mill_manager':
        return Colors.orange;
      case 'finance_manager':
        return Colors.blue;
      case 'sales_officer':
        return Colors.purple;
      default:
        return Colors.indigo;
    }
  }
}
