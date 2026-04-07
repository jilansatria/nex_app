import 'package:flutter/material.dart';

class BottomNavScaffold extends StatefulWidget {
  final Widget body;
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final List<BottomNavigationBarItem> items;

  const BottomNavScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.items,
  });

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: widget.body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: widget.selectedIndex,
          onTap: widget.onIndexChanged,
          items: widget.items,
          selectedItemColor: const Color(0xFF1B4B8C),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}
